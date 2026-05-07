@tool

## GFStorageCodec: 通用存档字典编码与解码策略。
##
## 负责字典序列化、可选压缩、完整性校验和轻量混淆。
## 它不负责路径、槽位、事务提交或云同步。
class_name GFStorageCodec
extends Resource


# --- 枚举 ---

## 存档载荷序列化格式。
enum Format {
	## 稳定排序后的 JSON 文本。
	JSON,
	## Godot Variant 二进制格式。
	BINARY,
}


# --- 常量 ---

const META_KEY: String = "_meta"
const VERSION_KEY: String = "version"
const TIMESTAMP_KEY: String = "timestamp"
const CHECKSUM_KEY: String = "checksum"
const FORMAT_KEY: String = "format"
const COMPRESSION_KEY: String = "compression"

const _COMPRESSION_MODE: int = FileAccess.COMPRESSION_DEFLATE


# --- 导出变量 ---

## 默认序列化格式。
@export var format: Format = Format.JSON

## 是否压缩载荷。
@export var use_compression: bool = false

## 是否在 `_meta.checksum` 中写入 SHA-256 完整性校验。
@export var use_integrity_checksum: bool = false

## 校验失败时是否拒绝读取。
@export var strict_integrity: bool = true

## 启用完整性校验时，是否要求载荷必须包含 `_meta.checksum`。
@export var require_integrity_checksum: bool = false

## 是否写入 `_meta.version` 和 `_meta.timestamp`。
@export var include_metadata: bool = false

## 当前数据版本。
@export var version: int = 1:
	set(value):
		version = maxi(value, 1)

## 轻量 XOR 混淆密钥；为 0 时写入原始 bytes。该字段不提供安全加密能力。
@export var obfuscation_key: int = 0

## 解压时允许的最大输出字节数。
@export var max_decompressed_bytes: int = 64 * 1024 * 1024


# --- 公共方法 ---

## 将字典编码为可写入文件的 bytes。
## @param data: 要编码的数据。
## @param options: 临时覆盖当前 codec 设置的选项字典。
## @return 编码后的 bytes。
func encode(data: Dictionary, options: Dictionary = {}) -> PackedByteArray:
	var payload := data.duplicate(true)
	var active_format := _get_format(options)
	var should_compress := _get_bool_option(options, "use_compression", use_compression)
	var key := _get_int_option(options, "obfuscation_key", obfuscation_key)
	var should_write_checksum := _get_bool_option(options, "use_integrity_checksum", use_integrity_checksum)

	if _get_bool_option(options, "include_metadata", include_metadata) or should_write_checksum:
		_prepare_metadata(payload, active_format, should_compress, should_write_checksum, options)

	var bytes := _serialize_dictionary(payload, active_format)
	if should_compress:
		bytes = bytes.compress(_COMPRESSION_MODE)
	if key != 0:
		bytes = _obfuscate_bytes(bytes, key)
		return Marshalls.raw_to_base64(bytes).to_utf8_buffer()
	return bytes


## 从 bytes 解码字典。
## @param bytes: 文件读取到的 bytes。
## @param options: 临时覆盖当前 codec 设置的选项字典。
## @return 结果字典，包含 ok、data、metadata、integrity_valid、error。
func decode(bytes: PackedByteArray, options: Dictionary = {}) -> Dictionary:
	var active_format := _get_format(options)
	var should_compress := _get_bool_option(options, "use_compression", use_compression)
	var key := _get_int_option(options, "obfuscation_key", obfuscation_key)
	var should_verify_checksum := _get_bool_option(options, "use_integrity_checksum", use_integrity_checksum)
	var should_reject_bad_checksum := _get_bool_option(options, "strict_integrity", strict_integrity)
	var should_require_checksum := _get_bool_option(
		options,
		"require_integrity_checksum",
		require_integrity_checksum
	)
	var payload_bytes := _decode_obfuscation(bytes, key)
	if payload_bytes.is_empty():
		return _make_result(false, {}, "Payload is empty", true)

	if should_compress:
		payload_bytes = payload_bytes.decompress_dynamic(
			_get_int_option(options, "max_decompressed_bytes", max_decompressed_bytes),
			_COMPRESSION_MODE
		)
		if payload_bytes.is_empty() and not bytes.is_empty():
			return _make_result(false, {}, "Decompression failed", true)

	var deserialize_result := _try_deserialize_dictionary(payload_bytes, active_format)
	var data := deserialize_result["data"] as Dictionary
	if not bool(deserialize_result.get("ok", false)) and not payload_bytes.is_empty():
		var fallback_result := _try_legacy_plain_json(bytes)
		if bool(fallback_result.get("ok", false)):
			data = fallback_result["data"] as Dictionary
			deserialize_result = fallback_result

	if not bool(deserialize_result.get("ok", false)) and not payload_bytes.is_empty():
		return _make_result(false, {}, "Decode failed", true)

	var integrity_valid := true
	if should_verify_checksum:
		var has_checksum := has_integrity_checksum(data)
		integrity_valid = has_checksum and verify_integrity(data, active_format)
		if not has_checksum and not should_require_checksum:
			integrity_valid = true
		elif not has_checksum and should_reject_bad_checksum:
			return _make_result(false, data, "Integrity checksum missing", false)
		if not integrity_valid and should_reject_bad_checksum:
			return _make_result(false, data, "Integrity checksum mismatch", false)

	return _make_result(true, data, "", integrity_valid)


## 序列化字典。JSON 格式会递归排序字典键。
## @param data: 要序列化的数据。
## @param p_format: 目标格式。
## @return bytes。
func serialize_dictionary(data: Dictionary, p_format: Format = Format.JSON) -> PackedByteArray:
	return _serialize_dictionary(data, p_format)


## 反序列化字典。
## @param bytes: 源 bytes。
## @param p_format: 源格式。
## @return 字典；失败时返回空字典。
func deserialize_dictionary(bytes: PackedByteArray, p_format: Format = Format.JSON) -> Dictionary:
	return _deserialize_dictionary(bytes, p_format)


## 计算当前数据按指定格式序列化后的 SHA-256。
## @param data: 输入数据。
## @param p_format: 序列化格式。
## @return checksum hex 字符串。
func calculate_checksum(data: Dictionary, p_format: Format = Format.JSON) -> String:
	var bytes := _serialize_dictionary(data, p_format)
	var hashing := HashingContext.new()
	hashing.start(HashingContext.HASH_SHA256)
	hashing.update(bytes)
	return hashing.finish().hex_encode()


## 校验 `_meta.checksum`。
## @param data: 包含可选 `_meta.checksum` 的字典。
## @param p_format: checksum 计算使用的格式。
## @return 缺少 checksum 或校验通过时返回 true。
func verify_integrity(data: Dictionary, p_format: Format = Format.JSON) -> bool:
	var metadata := get_metadata(data)
	if not metadata.has(CHECKSUM_KEY):
		return true

	var expected := String(metadata.get(CHECKSUM_KEY, ""))
	var copy := data.duplicate(true)
	var copy_metadata := get_metadata(copy)
	copy_metadata.erase(CHECKSUM_KEY)
	if copy_metadata.is_empty():
		copy.erase(META_KEY)
	else:
		copy[META_KEY] = copy_metadata

	return calculate_checksum(copy, p_format) == expected


## 获取存档元信息副本。
## @param data: 存档数据。
## @return `_meta` 字典副本；不存在时为空字典。
func get_metadata(data: Dictionary) -> Dictionary:
	var metadata_variant: Variant = data.get(META_KEY, {})
	if metadata_variant is Dictionary:
		return (metadata_variant as Dictionary).duplicate(true)
	return {}


## 判断字典是否包含完整性 checksum。
## @param data: 存档数据。
## @return 包含 `_meta.checksum` 时返回 true。
func has_integrity_checksum(data: Dictionary) -> bool:
	return get_metadata(data).has(CHECKSUM_KEY)


# --- 私有/辅助方法 ---

func _prepare_metadata(
	payload: Dictionary,
	active_format: Format,
	should_compress: bool,
	should_write_checksum: bool,
	options: Dictionary
) -> void:
	var metadata := get_metadata(payload)
	var should_include_metadata := _get_bool_option(options, "include_metadata", include_metadata)
	if should_include_metadata:
		metadata[VERSION_KEY] = _get_int_option(options, "version", version)
		metadata[TIMESTAMP_KEY] = Time.get_datetime_string_from_system(true, true)
		metadata[FORMAT_KEY] = _format_to_string(active_format)
		if should_compress:
			metadata[COMPRESSION_KEY] = "deflate"

	if metadata.is_empty():
		payload.erase(META_KEY)
	else:
		payload[META_KEY] = metadata

	if should_write_checksum:
		metadata.erase(CHECKSUM_KEY)
		if metadata.is_empty():
			payload.erase(META_KEY)
		else:
			payload[META_KEY] = metadata
		metadata[CHECKSUM_KEY] = calculate_checksum(payload, active_format)
		payload[META_KEY] = metadata


func _serialize_dictionary(data: Dictionary, p_format: Format) -> PackedByteArray:
	match p_format:
		Format.BINARY:
			return var_to_bytes(data)
		_:
			return JSON.stringify(_sort_value_recursive(data)).to_utf8_buffer()


func _deserialize_dictionary(bytes: PackedByteArray, p_format: Format) -> Dictionary:
	var result := _try_deserialize_dictionary(bytes, p_format)
	return result["data"] as Dictionary


func _try_deserialize_dictionary(bytes: PackedByteArray, p_format: Format) -> Dictionary:
	match p_format:
		Format.BINARY:
			var value: Variant = bytes_to_var(bytes)
			if value is Dictionary:
				return { "ok": true, "data": value as Dictionary }
			return { "ok": false, "data": {} }
		_:
			var parsed: Variant = JSON.parse_string(bytes.get_string_from_utf8())
			if parsed is Dictionary:
				return { "ok": true, "data": _normalize_numbers(parsed) as Dictionary }
			return { "ok": false, "data": {} }


func _sort_value_recursive(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		var dictionary := value as Dictionary
		var keys := dictionary.keys()
		keys.sort_custom(func(left: Variant, right: Variant) -> bool:
			return String(left) < String(right)
		)
		for key: Variant in keys:
			result[key] = _sort_value_recursive(dictionary[key])
		return result
	if value is Array:
		var result: Array = []
		for item: Variant in value:
			result.append(_sort_value_recursive(item))
		return result
	return value


func _normalize_numbers(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		var dictionary := value as Dictionary
		for key: Variant in dictionary.keys():
			result[key] = _normalize_numbers(dictionary[key])
		return result
	if value is Array:
		var result: Array = []
		for item: Variant in value:
			result.append(_normalize_numbers(item))
		return result
	if typeof(value) == TYPE_FLOAT:
		var float_value := float(value)
		if is_equal_approx(float_value, floorf(float_value)):
			return int(float_value)
	return value


func _decode_obfuscation(bytes: PackedByteArray, key: int) -> PackedByteArray:
	if key == 0:
		return bytes

	var raw := Marshalls.base64_to_raw(bytes.get_string_from_utf8())
	if raw.is_empty() and not bytes.is_empty():
		return bytes
	return _obfuscate_bytes(raw, key)


func _obfuscate_bytes(bytes: PackedByteArray, key: int) -> PackedByteArray:
	var result := PackedByteArray(bytes)
	var key_byte := key & 0xff
	for index: int in range(result.size()):
		result[index] = result[index] ^ key_byte
	return result


func _try_legacy_plain_json(bytes: PackedByteArray) -> Dictionary:
	var parsed: Variant = JSON.parse_string(bytes.get_string_from_utf8())
	if parsed is Dictionary:
		return { "ok": true, "data": parsed as Dictionary }
	return { "ok": false, "data": {} }


func _make_result(ok: bool, data: Dictionary, error: String, integrity_valid: bool) -> Dictionary:
	return {
		"ok": ok,
		"data": data,
		"metadata": get_metadata(data),
		"integrity_valid": integrity_valid,
		"error": error,
	}


func _get_format(options: Dictionary) -> Format:
	return int(options.get("format", format)) as Format


func _get_bool_option(options: Dictionary, key: String, fallback: bool) -> bool:
	return bool(options.get(key, fallback))


func _get_int_option(options: Dictionary, key: String, fallback: int) -> int:
	return int(options.get(key, fallback))


func _format_to_string(p_format: Format) -> String:
	match p_format:
		Format.BINARY:
			return "binary"
		_:
			return "json"
