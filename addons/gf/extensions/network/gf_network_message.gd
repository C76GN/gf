## GFNetworkMessage: 通用网络消息载体。
##
## 只描述传输元信息和字典载荷，不绑定具体协议、后端或业务消息类型。
class_name GFNetworkMessage
extends RefCounted


# --- 公共变量 ---

## 消息类型标识。
var message_type: StringName = &""

## 发送端自增序号。
var sequence: int = 0

## 逻辑 tick 或帧号。
var tick: int = 0

## 发送者标识。
var sender_id: int = -1

## 消息载荷。
var payload: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init(
	p_message_type: StringName = &"",
	p_payload: Dictionary = {},
	p_sequence: int = 0,
	p_tick: int = 0,
	p_sender_id: int = -1
) -> void:
	message_type = p_message_type
	payload = p_payload.duplicate(true)
	sequence = p_sequence
	tick = p_tick
	sender_id = p_sender_id


# --- 公共方法 ---

## 转为可序列化字典。
## @return 字典载荷。
func to_dict() -> Dictionary:
	return {
		"type": message_type,
		"sequence": sequence,
		"tick": tick,
		"sender_id": sender_id,
		"payload": payload.duplicate(true),
	}


## 从字典恢复。
## @param data: 字典载荷。
func from_dict(data: Dictionary) -> void:
	message_type = StringName(data.get("type", &""))
	sequence = int(data.get("sequence", 0))
	tick = int(data.get("tick", 0))
	sender_id = int(data.get("sender_id", -1))
	var payload_variant: Variant = data.get("payload", {})
	payload = (payload_variant as Dictionary).duplicate(true) if payload_variant is Dictionary else {}
