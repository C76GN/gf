## GFNetworkSnapshot: 通用网络状态快照。
##
## 保存 tick、peer_id、纯字典状态和元数据，可用于同步、回放、插值或项目自定义差量流程。
## [br]
## @api public
## [br]
## @category value_object
## [br]
## @since 3.17.0
class_name GFNetworkSnapshot
extends RefCounted


# --- 公共变量 ---

## 快照所属 tick。
## [br]
## @api public
var tick: int = 0

## 快照来源 peer；-1 表示未指定。
## [br]
## @api public
var peer_id: int = -1

## 快照状态字典。
## [br]
## @api public
## [br]
## @schema state: Dictionary[StringName|String, Variant]，保存项目自定义同步状态。
var state: Dictionary = {}

## 项目自定义元数据。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary，保存项目自定义快照元数据。
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
## [br]
## @api public
## [br]
## @return 快照字典。
## [br]
## @schema return: Dictionary，包含 tick、peer_id、state、metadata。
func to_dict() -> Dictionary:
	return {
		"tick": tick,
		"peer_id": peer_id,
		"state": state.duplicate(true),
		"metadata": metadata.duplicate(true),
	}


## 从字典恢复。
## [br]
## @api public
## [br]
## @param data: 快照字典。
## [br]
## @schema data: Dictionary，包含 tick、peer_id、state、metadata。
func from_dict(data: Dictionary) -> void:
	tick = int(data.get("tick", 0))
	peer_id = int(data.get("peer_id", -1))
	var state_value: Variant = data.get("state", {})
	state = (state_value as Dictionary).duplicate(true) if state_value is Dictionary else {}
	var metadata_value: Variant = data.get("metadata", {})
	metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}


## 复制快照。
## [br]
## @api public
## [br]
## @return 新快照。
func duplicate_snapshot() -> GFNetworkSnapshot:
	return GFNetworkSnapshot.new(tick, state, peer_id, metadata)


## 检查状态字段是否存在。
## [br]
## @api public
## [br]
## @param key: 字段名。
## [br]
## @return 存在返回 true。
func has_value(key: StringName) -> bool:
	return state.has(key) or state.has(String(key))


## 读取状态字段。
## [br]
## @api public
## [br]
## @param key: 字段名。
## [br]
## @param default_value: 缺失时返回的默认值。
## [br]
## @return 字段值。
## [br]
## @schema default_value: Variant，状态字段缺失时返回的默认值。
## [br]
## @schema return: Variant，字段值或 default_value。
func get_value(key: StringName, default_value: Variant = null) -> Variant:
	if state.has(key):
		return state[key]
	return state.get(String(key), default_value)


## 设置状态字段。
## [br]
## @api public
## [br]
## @param key: 字段名。
## [br]
## @param value: 字段值。
## [br]
## @schema value: Variant，字段值，会通过 GFVariantData.duplicate_variant() 复制后保存。
func set_value(key: StringName, value: Variant) -> void:
	state[key] = GFVariantData.duplicate_variant(value)


## 删除状态字段。
## [br]
## @api public
## [br]
## @param key: 字段名。
func erase_value(key: StringName) -> void:
	state.erase(key)
	state.erase(String(key))


## 生成当前快照到目标快照的浅层差量。
## [br]
## @api public
## [br]
## @param target: 目标快照。
## [br]
## @return 差量字典。
## [br]
## @schema return: Dictionary，成功时包含 ok、from_tick、to_tick、peer_id、set、erase、metadata；失败时包含 ok、error。
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
## [br]
## @api public
## [br]
## @param delta: make_delta_to() 生成的差量字典。
## [br]
## @return 新快照。
## [br]
## @schema delta: Dictionary，make_delta_to() 返回的差量结构。
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
## [br]
## @api public
## [br]
## @param message_type: 消息类型。
## [br]
## @param channel_id: 逻辑通道标识。
## [br]
## @return 网络消息。
func make_message(message_type: StringName = &"snapshot", channel_id: StringName = &"") -> GFNetworkMessage:
	return GFNetworkMessage.new(message_type, to_dict(), 0, tick, peer_id, channel_id)
