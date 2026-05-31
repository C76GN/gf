## GFNetworkSerializer: 通用网络消息编码器。
##
## 提供 Variant 二进制与 JSON 两种编码方式，供不同网络后端复用。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.17.0
class_name GFNetworkSerializer
extends RefCounted


# --- 枚举 ---

## 消息编码格式。
## [br]
## @api public
enum Format {
	## Godot Variant 二进制编码。
	BINARY,
	## UTF-8 JSON 编码。
	JSON,
}


# --- 公共变量 ---

## 默认编码格式。
## [br]
## @api public
var format: Format = Format.BINARY

## JSON 格式下是否使用 GFVariantJsonCodec 的类型化 Godot Variant 编码。
## [br]
## @api public
var use_typed_json_codec: bool = false

## 传给 GFVariantJsonCodec JSON codec 的可选配置。
## [br]
## @api public
## [br]
## @schema json_codec_options: Dictionary，传给 GFVariantJsonCodec 的 JSON 编码/解码选项。
var json_codec_options: Dictionary = {}


# --- 公共方法 ---

## 编码消息。
## [br]
## @api public
## [br]
## @param message: 消息载体。
## [br]
## @return 字节数组。
func serialize_message(message: GFNetworkMessage) -> PackedByteArray:
	if message == null:
		return PackedByteArray()
	return serialize_dictionary(message.to_dict())


## 解码消息。
## [br]
## @api public
## [br]
## @param bytes: 源 bytes。
## [br]
## @return 消息载体；失败时返回 null。
func deserialize_message(bytes: PackedByteArray) -> GFNetworkMessage:
	var result: Dictionary = deserialize_message_result(bytes)
	if not GFVariantData.get_option_bool(result, "ok"):
		return null
	return _get_network_message_value(GFVariantData.get_option_value(result, "data"))


## 解码消息并返回结果字典。
## [br]
## @api public
## [br]
## @param bytes: 源 bytes。
## [br]
## @return 包含 ok、data、error 的结果字典。
## [br]
## @schema return: Dictionary，包含 ok、data、error；data 为 GFNetworkMessage 或空字典。
func deserialize_message_result(bytes: PackedByteArray) -> Dictionary:
	var dictionary_result: Dictionary = deserialize_dictionary_result(bytes)
	if not GFVariantData.get_option_bool(dictionary_result, "ok"):
		return dictionary_result

	var data: Dictionary = GFVariantData.get_option_dictionary(dictionary_result, "data")
	if data.is_empty():
		return _make_failure("empty_message")

	var message: GFNetworkMessage = GFNetworkMessage.new()
	message.from_dict(data)
	return _make_success(message)


## 编码字典。
## [br]
## @api public
## [br]
## @param data: 字典。
## [br]
## @return 字节数组。
## [br]
## @schema data: Dictionary，待编码的消息或项目自定义字典。
func serialize_dictionary(data: Dictionary) -> PackedByteArray:
	match format:
		Format.JSON:
			var json_value: Variant = GFVariantJsonCodec.variant_to_json_compatible(data, json_codec_options) if use_typed_json_codec else data
			return JSON.stringify(json_value).to_utf8_buffer()
		_:
			return var_to_bytes(data)


## 解码字典并返回结果字典。
## [br]
## @api public
## [br]
## @param bytes: 源 bytes。
## [br]
## @return 包含 ok、data、error 的结果字典；合法空字典会返回 ok=true。
## [br]
## @schema return: Dictionary，包含 ok、data、error；data 为解码后的 Dictionary。
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
			return _make_success(GFVariantData.to_dictionary(parsed))
		_:
			var value: Variant = bytes_to_var(bytes)
			if not (value is Dictionary):
				return _make_failure("binary_not_dictionary")
			return _make_success(GFVariantData.to_dictionary(value))


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


func _get_network_message_value(value: Variant) -> GFNetworkMessage:
	if value is GFNetworkMessage:
		var message: GFNetworkMessage = value
		return message
	return null
