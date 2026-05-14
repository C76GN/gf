## GFNetworkSerializer: 通用网络消息编码器。
##
## 提供 Variant 二进制与 JSON 两种编码方式，供不同网络后端复用。
class_name GFNetworkSerializer
extends RefCounted


# --- 枚举 ---

## 消息编码格式。
enum Format {
	## Godot Variant 二进制编码。
	BINARY,
	## UTF-8 JSON 编码。
	JSON,
}


# --- 公共变量 ---

## 默认编码格式。
var format: Format = Format.BINARY

## JSON 格式下是否使用 GFVariantJsonCodec 的类型化 Godot Variant 编码。
var use_typed_json_codec: bool = false

## 传给 GFVariantJsonCodec JSON codec 的可选配置。
var json_codec_options: Dictionary = {}


# --- 公共方法 ---

## 编码消息。
## @param message: 消息载体。
## @return 字节数组。
func serialize_message(message: GFNetworkMessage) -> PackedByteArray:
	if message == null:
		return PackedByteArray()
	return serialize_dictionary(message.to_dict())


## 解码消息。
## @param bytes: 源 bytes。
## @return 消息载体；失败时返回 null。
func deserialize_message(bytes: PackedByteArray) -> GFNetworkMessage:
	var result := deserialize_message_result(bytes)
	if not bool(result.get("ok", false)):
		return null
	return result.get("data") as GFNetworkMessage


## 解码消息并返回结果字典。
## @param bytes: 源 bytes。
## @return 包含 ok、data、error 的结果字典。
func deserialize_message_result(bytes: PackedByteArray) -> Dictionary:
	var dictionary_result := deserialize_dictionary_result(bytes)
	if not bool(dictionary_result.get("ok", false)):
		return dictionary_result

	var data := dictionary_result.get("data", {}) as Dictionary
	if data == null or data.is_empty():
		return _make_failure("empty_message")

	var message := GFNetworkMessage.new()
	message.from_dict(data)
	return _make_success(message)


## 编码字典。
## @param data: 字典。
## @return 字节数组。
func serialize_dictionary(data: Dictionary) -> PackedByteArray:
	match format:
		Format.JSON:
			var json_value: Variant = GFVariantJsonCodec.variant_to_json_compatible(data, json_codec_options) if use_typed_json_codec else data
			return JSON.stringify(json_value).to_utf8_buffer()
		_:
			return var_to_bytes(data)


## 解码字典并返回结果字典。
## @param bytes: 源 bytes。
## @return 包含 ok、data、error 的结果字典；合法空字典会返回 ok=true。
func deserialize_dictionary_result(bytes: PackedByteArray) -> Dictionary:
	if bytes.is_empty():
		return _make_failure("empty_bytes")

	match format:
		Format.JSON:
			var parsed: Variant = JSON.parse_string(bytes.get_string_from_utf8())
			if use_typed_json_codec:
				parsed = GFVariantJsonCodec.json_compatible_to_variant(parsed, json_codec_options)
			if not (parsed is Dictionary):
				return _make_failure("json_not_dictionary")
			return _make_success((parsed as Dictionary).duplicate(true))
		_:
			var value: Variant = bytes_to_var(bytes)
			if not (value is Dictionary):
				return _make_failure("binary_not_dictionary")
			return _make_success((value as Dictionary).duplicate(true))


# --- 私有/辅助方法 ---

func _make_success(data: Variant) -> Dictionary:
	return {
		"ok": true,
		"data": data,
		"error": "",
	}


func _make_failure(error: String) -> Dictionary:
	return {
		"ok": false,
		"data": {},
		"error": error,
	}
