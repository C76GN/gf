## GFNetworkMessageValidator: 通用网络消息校验器。
##
## 校验消息类型、包体大小和可选必需载荷字段，避免后端收到明显无效数据。
class_name GFNetworkMessageValidator
extends RefCounted


# --- 常量 ---

const GFNetworkChannelBase = preload("res://addons/gf/extensions/network/gf_network_channel.gd")


# --- 公共变量 ---

## 是否允许空 message_type。
var allow_empty_message_type: bool = false

## 最小包体大小。小于等于 0 表示不限制。
var min_packet_size: int = 1

## 最大包体大小。小于等于 0 表示不限制。
var max_packet_size: int = 0

## 所有消息都必须包含的 payload key。
var required_payload_keys: PackedStringArray = PackedStringArray()


# --- 公共方法 ---

## 校验消息对象。
## @param message: 消息。
## @return 统一校验报告。
func validate_message(message: GFNetworkMessage) -> Dictionary:
	var errors: PackedStringArray = PackedStringArray()
	if message == null:
		errors.append("message_is_null")
		return _make_report(errors)

	if message.message_type == &"" and not allow_empty_message_type:
		errors.append("empty_message_type")
	for key: String in required_payload_keys:
		if not message.payload.has(key):
			errors.append("missing_payload_key:%s" % key)
	return _make_report(errors)


## 校验原始包体。
## @param bytes: 包体。
## @param channel: 可选通道描述。
## @return 统一校验报告。
func validate_bytes(bytes: PackedByteArray, channel: GFNetworkChannelBase = null) -> Dictionary:
	var errors: PackedStringArray = PackedStringArray()
	var byte_count := bytes.size()
	if min_packet_size > 0 and byte_count < min_packet_size:
		errors.append("packet_too_small")

	var effective_max := max_packet_size
	if channel != null and channel.max_packet_size > 0:
		effective_max = channel.max_packet_size if effective_max <= 0 else mini(effective_max, channel.max_packet_size)
	if effective_max > 0 and byte_count > effective_max:
		errors.append("packet_too_large")
	return _make_report(errors)


## 获取调试快照。
## @return 校验器状态。
func get_debug_snapshot() -> Dictionary:
	return {
		"allow_empty_message_type": allow_empty_message_type,
		"min_packet_size": min_packet_size,
		"max_packet_size": max_packet_size,
		"required_payload_keys": required_payload_keys.duplicate(),
	}


# --- 私有/辅助方法 ---

func _make_report(errors: PackedStringArray) -> Dictionary:
	return {
		"ok": errors.is_empty(),
		"errors": errors,
	}
