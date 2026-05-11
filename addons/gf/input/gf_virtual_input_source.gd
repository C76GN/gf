## GFVirtualInputSource: 可编程虚拟输入源。
##
## 用于测试、回放、AI 控制或项目自定义输入桥接，向 GFInputMappingUtility
## 注入抽象动作值；它不读取 InputMap，也不规定具体设备或玩法语义。
class_name GFVirtualInputSource
extends RefCounted


# --- 公共变量 ---

## 虚拟输入源标识。
var source_id: StringName = &"virtual"

## 玩家索引；小于 0 时只写入全局动作状态。
var player_index: int = -1


# --- 私有变量 ---

var _input_utility_ref: WeakRef = null


# --- Godot 生命周期方法 ---

func _init(
	input_utility: Object = null,
	p_source_id: StringName = &"virtual",
	p_player_index: int = -1
) -> void:
	configure(input_utility, p_source_id, p_player_index)


# --- 公共方法 ---

## 配置虚拟输入源。
## @param input_utility: 输入映射工具。
## @param p_source_id: 虚拟输入源标识。
## @param p_player_index: 玩家索引。
## @return 当前输入源。
func configure(
	input_utility: Object,
	p_source_id: StringName = &"virtual",
	p_player_index: int = -1
) -> GFVirtualInputSource:
	_input_utility_ref = weakref(input_utility) if input_utility != null else null
	source_id = p_source_id if p_source_id != &"" else &"virtual"
	player_index = p_player_index
	return self


## 写入动作值。
## @param action_id: 动作标识。
## @param value: 动作值。
## @return 写入成功返回 true。
func set_action_value(action_id: StringName, value: Variant) -> bool:
	var input_utility := _get_input_utility()
	if input_utility == null:
		return false
	return bool(input_utility.call("set_virtual_action_value", action_id, value, source_id, player_index))


## 为指定玩家写入动作值。
## @param action_id: 动作标识。
## @param value: 动作值。
## @param next_player_index: 玩家索引。
## @return 写入成功返回 true。
func set_action_value_for_player(action_id: StringName, value: Variant, next_player_index: int) -> bool:
	var input_utility := _get_input_utility()
	if input_utility == null:
		return false
	return bool(input_utility.call("set_virtual_action_value", action_id, value, source_id, next_player_index))


## 按下布尔动作。
## @param action_id: 动作标识。
## @param strength: 输入强度。
## @return 写入成功返回 true。
func press(action_id: StringName, strength: float = 1.0) -> bool:
	return set_action_value(action_id, maxf(strength, 0.0))


## 释放动作。
## @param action_id: 动作标识。
## @return 写入成功返回 true。
func release(action_id: StringName) -> bool:
	return set_action_value(action_id, false)


## 写入一维轴动作。
## @param action_id: 动作标识。
## @param value: 一维轴值。
## @return 写入成功返回 true。
func set_axis_1d(action_id: StringName, value: float) -> bool:
	return set_action_value(action_id, value)


## 写入二维轴动作。
## @param action_id: 动作标识。
## @param value: 二维轴值。
## @return 写入成功返回 true。
func set_axis_2d(action_id: StringName, value: Vector2) -> bool:
	return set_action_value(action_id, value)


## 写入三维轴动作。
## @param action_id: 动作标识。
## @param value: 三维轴值。
## @return 写入成功返回 true。
func set_axis_3d(action_id: StringName, value: Vector3) -> bool:
	return set_action_value(action_id, value)


## 清除指定动作贡献。
## @param action_id: 动作标识。
## @return 清除成功返回 true。
func clear_action(action_id: StringName) -> bool:
	var input_utility := _get_input_utility()
	if input_utility == null:
		return false
	return bool(input_utility.call("clear_virtual_action", action_id, source_id, player_index))


## 清除指定玩家的动作贡献。
## @param action_id: 动作标识。
## @param next_player_index: 玩家索引。
## @return 清除成功返回 true。
func clear_action_for_player(action_id: StringName, next_player_index: int) -> bool:
	var input_utility := _get_input_utility()
	if input_utility == null:
		return false
	return bool(input_utility.call("clear_virtual_action", action_id, source_id, next_player_index))


## 清除当前虚拟源的所有动作贡献。
func clear_all() -> void:
	var input_utility := _get_input_utility()
	if input_utility != null:
		input_utility.call("clear_virtual_source", source_id)


## 获取当前虚拟源快照。
## @return 快照字典。
func get_snapshot() -> Dictionary:
	var input_utility := _get_input_utility()
	if input_utility == null:
		return {
			"source_id": source_id,
			"player_index": player_index,
			"actions": [],
		}
	return input_utility.call("get_virtual_source_snapshot", source_id) as Dictionary


# --- 私有/辅助方法 ---

func _get_input_utility() -> Object:
	if _input_utility_ref == null:
		return null
	return _input_utility_ref.get_ref()
