## GFNodeStateBehavior: 节点状态的可复用生命周期行为资源。
##
## 行为资源可挂到 GFNodeState 上复用进入、退出、暂停、恢复和事件处理逻辑。
## 它不替代状态脚本；状态脚本仍负责业务状态的主要控制权。
class_name GFNodeStateBehavior
extends Resource


# --- 导出变量 ---

## 行为标识，便于调试或项目工具识别。
@export var behavior_id: StringName = &""

## 是否启用该行为。
@export var enabled: bool = true

## 项目自定义元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 初始化行为。
## @param state: 行为所属状态。
func initialize(state: Node) -> void:
	if enabled:
		_initialize(state)


## 状态进入后调用。
## @param state: 行为所属状态。
## @param previous_state: 来源状态名。
## @param args: 状态切换参数。
func enter(state: Node, previous_state: StringName = &"", args: Dictionary = {}) -> void:
	if enabled:
		_enter(state, previous_state, args)


## 状态退出前调用。
## @param state: 行为所属状态。
## @param next_state: 目标状态名。
## @param args: 状态切换参数。
func exit(state: Node, next_state: StringName = &"", args: Dictionary = {}) -> void:
	if enabled:
		_exit(state, next_state, args)


## 状态被栈式子状态覆盖时调用。
## @param state: 行为所属状态。
## @param next_state: 目标状态名。
## @param args: 状态切换参数。
func pause(state: Node, next_state: StringName = &"", args: Dictionary = {}) -> void:
	if enabled:
		_pause(state, next_state, args)


## 状态从栈式子状态恢复后调用。
## @param state: 行为所属状态。
## @param previous_state: 来源状态名。
## @param args: 状态切换参数。
func resume(state: Node, previous_state: StringName = &"", args: Dictionary = {}) -> void:
	if enabled:
		_resume(state, previous_state, args)


## 处理状态事件。
## @param state: 行为所属状态。
## @param event_id: 状态事件标识。
## @param payload: 状态事件载荷。
## @return 已处理返回 true。
func handle_state_event(state: Node, event_id: StringName, payload: Variant = null) -> bool:
	if not enabled:
		return false
	return _handle_state_event(state, event_id, payload)


# --- 虚方法（由子类重写） ---

## 行为初始化扩展点。
func _initialize(_state: Node) -> void:
	pass


## 状态进入行为扩展点。
func _enter(_state: Node, _previous_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


## 状态退出行为扩展点。
func _exit(_state: Node, _next_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


## 状态暂停行为扩展点。
func _pause(_state: Node, _next_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


## 状态恢复行为扩展点。
func _resume(_state: Node, _previous_state: StringName = &"", _args: Dictionary = {}) -> void:
	pass


## 状态事件行为扩展点。
func _handle_state_event(_state: Node, _event_id: StringName, _payload: Variant = null) -> bool:
	return false
