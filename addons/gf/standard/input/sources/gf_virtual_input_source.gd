## GFVirtualInputSource: 可编程虚拟输入源。
##
## 用于测试、回放、AI 控制或项目自定义输入桥接，向 GFInputMappingUtility
## 注入抽象动作值；它不读取 InputMap，也不规定具体设备或玩法语义。
## [br]
## @api public
## [br]
## @category runtime_handle
## [br]
## @since 3.17.0
class_name GFVirtualInputSource
extends RefCounted


# --- 公共变量 ---

## 虚拟输入源标识。
## [br]
## @api public
var source_id: StringName = &"virtual"

## 玩家索引；小于 0 时只写入全局动作状态。
## [br]
## @api public
var player_index: int = -1


# --- 私有变量 ---

var _input_mapping_ref: WeakRef = null


# --- Godot 生命周期方法 ---

func _init(
	input_mapping: GFInputMappingUtility = null,
	p_source_id: StringName = &"virtual",
	p_player_index: int = -1
) -> void:
	var _configure_result_40: Variant = configure(input_mapping, p_source_id, p_player_index)


# --- 公共方法 ---

## 配置虚拟输入源。
## [br]
## @api public
## [br]
## @param input_mapping: 输入映射工具。
## [br]
## @param p_source_id: 虚拟输入源标识。
## [br]
## @param p_player_index: 玩家索引。
## [br]
## @return 当前输入源。
func configure(
	input_mapping: GFInputMappingUtility,
	p_source_id: StringName = &"virtual",
	p_player_index: int = -1
) -> GFVirtualInputSource:
	_input_mapping_ref = weakref(input_mapping) if input_mapping != null else null
	source_id = p_source_id if p_source_id != &"" else &"virtual"
	player_index = p_player_index
	return self


## 写入动作值。
## [br]
## @api public
## [br]
## @param action_id: 动作标识。
## [br]
## @param value: 动作值。
## [br]
## @schema value: Variant，GFInputMappingUtility 接受的动作值，通常为 bool、float、Vector2 或 Vector3。
## [br]
## @return 写入成功返回 true。
func set_action_value(action_id: StringName, value: Variant) -> bool:
	var input_mapping: GFInputMappingUtility = _get_input_mapping()
	if input_mapping == null:
		return false
	return GFVariantData.to_bool(input_mapping.call("set_virtual_action_value", action_id, value, source_id, player_index))


## 为指定玩家写入动作值。
## [br]
## @api public
## [br]
## @param action_id: 动作标识。
## [br]
## @param value: 动作值。
## [br]
## @param next_player_index: 玩家索引。
## [br]
## @schema value: Variant，GFInputMappingUtility 接受的动作值，通常为 bool、float、Vector2 或 Vector3。
## [br]
## @return 写入成功返回 true。
func set_action_value_for_player(action_id: StringName, value: Variant, next_player_index: int) -> bool:
	var input_mapping: GFInputMappingUtility = _get_input_mapping()
	if input_mapping == null:
		return false
	return GFVariantData.to_bool(input_mapping.call("set_virtual_action_value", action_id, value, source_id, next_player_index))


## 按下布尔动作。
## [br]
## @api public
## [br]
## @param action_id: 动作标识。
## [br]
## @param strength: 输入强度。
## [br]
## @return 写入成功返回 true。
func press(action_id: StringName, strength: float = 1.0) -> bool:
	return set_action_value(action_id, maxf(strength, 0.0))


## 释放动作。
## [br]
## @api public
## [br]
## @param action_id: 动作标识。
## [br]
## @return 写入成功返回 true。
func release(action_id: StringName) -> bool:
	return set_action_value(action_id, false)


## 写入一维轴动作。
## [br]
## @api public
## [br]
## @param action_id: 动作标识。
## [br]
## @param value: 一维轴值。
## [br]
## @return 写入成功返回 true。
func set_axis_1d(action_id: StringName, value: float) -> bool:
	return set_action_value(action_id, value)


## 写入二维轴动作。
## [br]
## @api public
## [br]
## @param action_id: 动作标识。
## [br]
## @param value: 二维轴值。
## [br]
## @return 写入成功返回 true。
func set_axis_2d(action_id: StringName, value: Vector2) -> bool:
	return set_action_value(action_id, value)


## 写入三维轴动作。
## [br]
## @api public
## [br]
## @param action_id: 动作标识。
## [br]
## @param value: 三维轴值。
## [br]
## @return 写入成功返回 true。
func set_axis_3d(action_id: StringName, value: Vector3) -> bool:
	return set_action_value(action_id, value)


## 清除指定动作贡献。
## [br]
## @api public
## [br]
## @param action_id: 动作标识。
## [br]
## @return 清除成功返回 true。
func clear_action(action_id: StringName) -> bool:
	var input_mapping: GFInputMappingUtility = _get_input_mapping()
	if input_mapping == null:
		return false
	return GFVariantData.to_bool(input_mapping.call("clear_virtual_action", action_id, source_id, player_index))


## 清除指定玩家的动作贡献。
## [br]
## @api public
## [br]
## @param action_id: 动作标识。
## [br]
## @param next_player_index: 玩家索引。
## [br]
## @return 清除成功返回 true。
func clear_action_for_player(action_id: StringName, next_player_index: int) -> bool:
	var input_mapping: GFInputMappingUtility = _get_input_mapping()
	if input_mapping == null:
		return false
	return GFVariantData.to_bool(input_mapping.call("clear_virtual_action", action_id, source_id, next_player_index))


## 清除当前虚拟源的所有动作贡献。
## [br]
## @api public
func clear_all() -> void:
	var input_mapping: GFInputMappingUtility = _get_input_mapping()
	if input_mapping != null:
		input_mapping.call("clear_virtual_source", source_id)


## 获取当前虚拟源快照。
## [br]
## @api public
## [br]
## @schema return: Dictionary，包含 source_id: StringName、player_index: int，以及当前虚拟输入贡献的 actions: Array[Dictionary]。
## [br]
## @return 快照字典。
func get_snapshot() -> Dictionary:
	var input_mapping: GFInputMappingUtility = _get_input_mapping()
	if input_mapping == null:
		return {
			"source_id": source_id,
			"player_index": player_index,
			"actions": [],
		}
	var snapshot: Variant = input_mapping.call("get_virtual_source_snapshot", source_id)
	return GFVariantData.to_dictionary(snapshot)


# --- 私有/辅助方法 ---

func _get_input_mapping() -> GFInputMappingUtility:
	if _input_mapping_ref == null:
		return null
	var input_mapping: Variant = _input_mapping_ref.get_ref()
	if input_mapping is GFInputMappingUtility:
		return input_mapping
	return null
