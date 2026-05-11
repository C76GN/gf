## GFNetworkSnapshot: 通用网络状态快照。
##
## 保存 tick、peer_id、纯字典状态和元数据，可用于同步、回放、插值或项目自定义差量流程。
class_name GFNetworkSnapshot
extends RefCounted


# --- 公共变量 ---

## 快照所属 tick。
var tick: int = 0

## 快照来源 peer；-1 表示未指定。
var peer_id: int = -1

## 快照状态字典。
var state: Dictionary = {}

## 项目自定义元数据。
var metadata: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init(
	p_tick: int = 0,
	p_state: Dictionary = {},
	p_peer_id: int = -1,
	p_metadata: Dictionary = {}
) -> void:
	tick = p_tick
	state = p_state.duplicate(true)
	peer_id = p_peer_id
	metadata = p_metadata.duplicate(true)


# --- 公共方法 ---

## 转为字典。
## @return 快照字典。
func to_dict() -> Dictionary:
	return {
		"tick": tick,
		"peer_id": peer_id,
		"state": state.duplicate(true),
		"metadata": metadata.duplicate(true),
	}


## 从字典恢复。
## @param data: 快照字典。
func from_dict(data: Dictionary) -> void:
	tick = int(data.get("tick", 0))
	peer_id = int(data.get("peer_id", -1))
	var state_value: Variant = data.get("state", {})
	state = (state_value as Dictionary).duplicate(true) if state_value is Dictionary else {}
	var metadata_value: Variant = data.get("metadata", {})
	metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}


## 复制快照。
## @return 新快照。
func duplicate_snapshot() -> GFNetworkSnapshot:
	return GFNetworkSnapshot.new(tick, state, peer_id, metadata)


## 检查状态字段是否存在。
## @param key: 字段名。
## @return 存在返回 true。
func has_value(key: StringName) -> bool:
	return state.has(key) or state.has(String(key))


## 读取状态字段。
## @param key: 字段名。
## @param default_value: 缺失时返回的默认值。
## @return 字段值。
func get_value(key: StringName, default_value: Variant = null) -> Variant:
	if state.has(key):
		return state[key]
	return state.get(String(key), default_value)


## 设置状态字段。
## @param key: 字段名。
## @param value: 字段值。
func set_value(key: StringName, value: Variant) -> void:
	state[key] = GFVariantData.duplicate_variant(value)


## 删除状态字段。
## @param key: 字段名。
func erase_value(key: StringName) -> void:
	state.erase(key)
	state.erase(String(key))


## 生成当前快照到目标快照的浅层差量。
## @param target: 目标快照。
## @return 差量字典。
func make_delta_to(target: GFNetworkSnapshot) -> Dictionary:
	if target == null:
		return {
			"ok": false,
			"error": "Target snapshot is null.",
		}

	var set_values: Dictionary = {}
	var erase_keys: Array = []
	for key: Variant in target.state.keys():
		if not state.has(key) or state[key] != target.state[key]:
			set_values[key] = GFVariantData.duplicate_variant(target.state[key])
	for key: Variant in state.keys():
		if not target.state.has(key):
			erase_keys.append(GFVariantData.duplicate_variant(key))
	return {
		"ok": true,
		"from_tick": tick,
		"to_tick": target.tick,
		"peer_id": target.peer_id,
		"set": set_values,
		"erase": erase_keys,
		"metadata": target.metadata.duplicate(true),
	}


## 应用浅层差量并返回新快照。
## @param delta: make_delta_to() 生成的差量字典。
## @return 新快照。
func apply_delta(delta: Dictionary) -> GFNetworkSnapshot:
	var next_snapshot := duplicate_snapshot()
	var set_values := delta.get("set", {}) as Dictionary
	if set_values != null:
		for key: Variant in set_values.keys():
			next_snapshot.state[key] = GFVariantData.duplicate_variant(set_values[key])

	var erase_values: Variant = delta.get("erase", PackedStringArray())
	if erase_values is PackedStringArray:
		for key: String in erase_values:
			next_snapshot.state.erase(key)
			next_snapshot.state.erase(StringName(key))
	elif erase_values is Array:
		for key_variant: Variant in erase_values:
			next_snapshot.state.erase(key_variant)
			next_snapshot.state.erase(StringName(str(key_variant)))

	next_snapshot.tick = int(delta.get("to_tick", next_snapshot.tick))
	next_snapshot.peer_id = int(delta.get("peer_id", next_snapshot.peer_id))
	var metadata_value: Variant = delta.get("metadata", next_snapshot.metadata)
	next_snapshot.metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}
	return next_snapshot


## 打包为网络消息。
## @param message_type: 消息类型。
## @param channel_id: 逻辑通道标识。
## @return 网络消息。
func make_message(message_type: StringName = &"snapshot", channel_id: StringName = &"") -> GFNetworkMessage:
	return GFNetworkMessage.new(message_type, to_dict(), 0, tick, peer_id, channel_id)
