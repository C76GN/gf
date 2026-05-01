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


# --- 公共方法 ---

## 编码消息。
## @param message: 消息载体。
## @return bytes。
func serialize_message(message: GFNetworkMessage) -> PackedByteArray:
	if message == null:
		return PackedByteArray()
	return serialize_dictionary(message.to_dict())


## 解码消息。
## @param bytes: 源 bytes。
## @return 消息载体；失败时返回 null。
func deserialize_message(bytes: PackedByteArray) -> GFNetworkMessage:
	var data := deserialize_dictionary(bytes)
	if data.is_empty():
		return null

	var message := GFNetworkMessage.new()
	message.from_dict(data)
	return message


## 编码字典。
## @param data: 字典。
## @return bytes。
func serialize_dictionary(data: Dictionary) -> PackedByteArray:
	match format:
		Format.JSON:
			return JSON.stringify(data).to_utf8_buffer()
		_:
			return var_to_bytes(data)


## 解码字典。
## @param bytes: 源 bytes。
## @return 字典；失败时返回空字典。
func deserialize_dictionary(bytes: PackedByteArray) -> Dictionary:
	if bytes.is_empty():
		return {}

	match format:
		Format.JSON:
			var parsed: Variant = JSON.parse_string(bytes.get_string_from_utf8())
			return parsed as Dictionary if parsed is Dictionary else {}
		_:
			var value: Variant = bytes_to_var(bytes)
			return value as Dictionary if value is Dictionary else {}
