## GFNodeState: 基于场景树的状态节点。
##
## 适合需要直接访问动画、碰撞、输入或子节点的状态逻辑。
class_name GFNodeState
extends Node


# --- 信号 ---

## 状态请求切换时发出，由所属状态组或状态机处理。
signal requested_transition(group_name: StringName, state_name: StringName, args: Dictionary)


# --- 导出变量 ---

## 状态注册名。为空时使用节点名称。
@export var state_name: StringName = &""


# --- 公共变量 ---

## 状态机宿主节点。通常是 GFNodeStateMachine 的父节点。
var host: Node:
	get:
		return get_host()


# --- 私有变量 ---

var _machine_ref: WeakRef = null
var _group_ref: WeakRef = null
var _original_process_mode: int = Node.PROCESS_MODE_INHERIT


# --- Godot 生命周期方法 ---

func _ready() -> void:
	_original_process_mode = process_mode
	_set_state_enabled(false)


# --- 公共方法 ---

## 由状态组调用，注入状态机与状态组引用。
## @param machine: 关联的节点状态机。
## @param group: 所属状态组。
func setup(machine: Object, group: Object) -> void:
	_machine_ref = weakref(machine) if machine != null else null
	_group_ref = weakref(group) if group != null else null


## 获取所属状态机。
func get_machine() -> Object:
	if _machine_ref == null:
		return null
	return _machine_ref.get_ref()


## 获取所属状态组。
func get_group() -> Object:
	if _group_ref == null:
		return null
	return _group_ref.get_ref()


## 获取状态机宿主节点。若无状态机，则退回到状态组父节点或当前父节点。
func get_host() -> Node:
	var machine := get_machine() as Node
	if machine != null and machine.get_parent() != null:
		return machine.get_parent()

	var group := get_group() as Node
	if group != null and group.get_parent() != null:
		return group.get_parent()

	return get_parent()


## 获取实际注册名。
func get_state_name() -> StringName:
	if state_name != &"":
		return state_name
	return StringName(name)


## 进入状态。
## @param previous_state: 上一个状态名称。
## @param args: 状态切换时传递的可选参数。
func enter(previous_state: StringName = &"", args: Dictionary = {}) -> void:
	_set_state_enabled(true)
	_enter(previous_state, args)


## 离开状态。
## @param next_state: 下一个状态名称。
## @param args: 状态切换时传递的可选参数。
func exit(next_state: StringName = &"", args: Dictionary = {}) -> void:
	_exit(next_state, args)
	_set_state_enabled(false)


## 进入栈式子状态时暂停当前状态。
## @param next_state: 下一个状态名称。
## @param args: 状态切换时传递的可选参数。
func pause(next_state: StringName = &"", args: Dictionary = {}) -> void:
	_pause(next_state, args)
	_set_state_enabled(false)


## 弹出栈式子状态后恢复当前状态。
## @param previous_state: 上一个状态名称。
## @param args: 状态切换时传递的可选参数。
func resume(previous_state: StringName = &"", args: Dictionary = {}) -> void:
	_set_state_enabled(true)
	_resume(previous_state, args)


## 请求切换状态。path 可为 "State" 或 "Group/State"。
## @param path: 资源路径或状态路径。
## @param args: 状态切换时传递的可选参数。
func transition_to(path: StringName, args: Dictionary = {}) -> void:
	var text := String(path)
	var parts := text.split("/", false)
	if parts.size() == 1:
		var group := get_group()
		var group_name: StringName = &""
		if group != null and group.has_method("get_group_name"):
			group_name = group.call("get_group_name")
		requested_transition.emit(group_name, StringName(parts[0]), args)
	elif parts.size() == 2:
		requested_transition.emit(StringName(parts[0]), StringName(parts[1]), args)
	else:
		push_error("[GFNodeState] transition_to 失败：路径格式无效。")


## 状态初始化 Hook。状态加入状态组时调用一次。
func initialize() -> void:
	_initialize()


## 判断是否允许进入状态。
## @param previous_state: 来源状态名。
## @param args: 切换参数。
## @return 允许进入返回 true。
func can_enter(previous_state: StringName = &"", args: Dictionary = {}) -> bool:
	return _can_enter(previous_state, args)


## 判断是否允许离开状态。
## @param next_state: 目标状态名。
## @param args: 切换参数。
## @return 允许离开返回 true。
func can_exit(next_state: StringName = &"", args: Dictionary = {}) -> bool:
	return _can_exit(next_state, args)


## 获取状态组共享黑板。
## @return 黑板字典；没有状态组时返回空字典。
func get_blackboard() -> Dictionary:
	var group := get_group()
	if group != null and group.has_method("get_blackboard"):
		return group.call("get_blackboard") as Dictionary
	return {}


## 状态初始化扩展点。
func _initialize() -> void:
	pass


## 状态进入守卫扩展点。
func _can_enter(_previous_state: StringName = &"", _args: Dictionary = {}) -> bool:
	return true


## 状态退出守卫扩展点。
func _can_exit(_next_state: StringName = &"", _args: Dictionary = {}) -> bool:
	return true


## 状态进入扩展点。
func _enter(_previous_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


## 状态退出扩展点。
func _exit(_next_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


## 状态被栈式子状态覆盖时的扩展点。
func _pause(_next_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


## 状态从栈式子状态恢复时的扩展点。
func _resume(_previous_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


# --- 私有/辅助方法 ---

func _set_state_enabled(enabled: bool) -> void:
	if enabled:
		process_mode = _original_process_mode
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
