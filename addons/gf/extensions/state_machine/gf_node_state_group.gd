## GFNodeStateGroup: 管理一组互斥激活的节点状态。
##
## 一个状态组内同一时间只有一个 GFNodeState 处于启用状态。
class_name GFNodeStateGroup
extends Node


# --- 信号 ---

## 状态加入组后发出。
signal state_added(state: Node)

## 状态从组中移除后发出。
signal state_removed(state: Node)

## 当前状态切换后发出。
signal current_state_changed(old_state: Node, new_state: Node)

## 子状态请求跨组切换时发出。
signal requested_transition(group_name: StringName, state_name: StringName, args: Dictionary)


# --- 导出变量 ---

## 状态组注册名。为空时使用节点名称。
@export var group_name: StringName = &""

## 初始状态名。
@export var initial_state: StringName = &""

## 初始状态参数。
@export var initial_args: Dictionary = {}

## ready 时是否自动从子节点加载状态。
@export var reload_states_on_ready: bool = true


# --- 私有变量 ---

var _states: Dictionary = {}
var _current_state: Node = null
var _machine_ref: WeakRef = null
var _is_ready: bool = false
var _reload_queued: bool = false
var _transition_serial: int = 0
var _is_exiting_current_state: bool = false
var _queued_exit_transition: Dictionary = {}


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)


func _ready() -> void:
	if get_parent() != null and get_parent().has_method("transition_group_to"):
		return
	_is_ready = true
	initialize()


func _exit_tree() -> void:
	_is_ready = false
	_reload_queued = false
	if child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.disconnect(_on_child_entered_tree)
	clear_states(false)


# --- 公共方法 ---

## 初始化状态组。
func initialize(machine: Object = null) -> void:
	_is_ready = true
	if machine != null:
		_machine_ref = weakref(machine)
	if reload_states_on_ready:
		reload_states_from_children()
	if initial_state != &"" and _current_state == null:
		transition_to(initial_state, initial_args)


## 获取状态组注册名。
func get_group_name() -> StringName:
	if group_name != &"":
		return group_name
	return StringName(name)


## 切换到指定状态。
func transition_to(next_state_name: StringName, args: Dictionary = {}) -> void:
	if not _states.has(next_state_name):
		_warn_missing_state(next_state_name)
		return

	if _is_exiting_current_state:
		_transition_serial += 1
		_queued_exit_transition = {
			"state_name": next_state_name,
			"args": args,
		}
		return

	_transition_serial += 1
	var current_serial := _transition_serial
	var next_state := _states[next_state_name] as Node
	var previous_state := _current_state
	var previous_name: StringName = &""
	if previous_state != null:
		previous_name = previous_state.call("get_state_name")
	if previous_state != null:
		_is_exiting_current_state = true
		previous_state.call("exit", next_state_name, args)
		_is_exiting_current_state = false
		if not _queued_exit_transition.is_empty():
			next_state_name = _queued_exit_transition["state_name"]
			args = _queued_exit_transition["args"]
			_queued_exit_transition.clear()
			current_serial = _transition_serial
			if not _states.has(next_state_name):
				_current_state = null
				_warn_missing_state(next_state_name)
				return
			next_state = _states[next_state_name] as Node

	_current_state = next_state
	_current_state.call("enter", previous_name, args)
	if current_serial == _transition_serial and _current_state == next_state:
		current_state_changed.emit(previous_state, _current_state)


## 添加状态节点。
func add_state(state: Node) -> void:
	if not _is_node_state(state):
		return

	var key := state.call("get_state_name") as StringName
	if _states.has(key):
		push_warning("[GFNodeStateGroup] 状态已存在，已忽略重复添加：%s" % key)
		return

	state.call("setup", _get_machine(), self)
	var transition_signal: Signal = state.get("requested_transition")
	if not transition_signal.is_connected(_on_state_requested_transition):
		transition_signal.connect(_on_state_requested_transition)
	_states[key] = state
	state.call("initialize")
	state_added.emit(state)


## 移除状态节点。
func remove_state(state: Node) -> bool:
	if not _is_node_state(state):
		return false

	var key := state.call("get_state_name") as StringName
	if not _states.has(key):
		return false
	if _current_state == state:
		state.call("exit", &"", {})
		_current_state = null
	var transition_signal: Signal = state.get("requested_transition")
	if transition_signal.is_connected(_on_state_requested_transition):
		transition_signal.disconnect(_on_state_requested_transition)
	_states.erase(key)
	state_removed.emit(state)
	return true


## 获取状态。
func get_state(query_state_name: StringName) -> Node:
	return _states.get(query_state_name) as Node


## 获取当前状态。
func get_current_state() -> Node:
	return _current_state


## 获取所有状态。
func get_states() -> Array[Node]:
	var result: Array[Node] = []
	for state: Node in _states.values():
		result.append(state)
	return result


## 清空状态。
func clear_states(free_states: bool = false) -> void:
	var states := get_states()
	_states.clear()
	_current_state = null
	_is_exiting_current_state = false
	_queued_exit_transition.clear()
	for state: Node in states:
		var transition_signal: Signal = state.get("requested_transition")
		if transition_signal.is_connected(_on_state_requested_transition):
			transition_signal.disconnect(_on_state_requested_transition)
		state_removed.emit(state)
		if free_states:
			state.queue_free()


## 从子节点重新加载状态。
func reload_states_from_children() -> void:
	clear_states()
	for child: Node in get_children():
		if _is_node_state(child):
			add_state(child)


# --- 私有/辅助方法 ---

func _get_machine() -> Object:
	if _machine_ref == null:
		return null
	return _machine_ref.get_ref()


func _is_node_state(node: Node) -> bool:
	if node == null:
		return false
	if not node.has_method("get_state_name"):
		return false
	if not node.has_method("setup"):
		return false
	if not node.has_method("initialize"):
		return false
	if not node.has_method("enter"):
		return false
	if not node.has_method("exit"):
		return false
	return node.get("requested_transition") is Signal


func _warn_missing_state(state_name: StringName) -> void:
	push_warning("[GFNodeStateGroup] 切换失败，未找到状态：%s" % state_name)


func _on_state_requested_transition(
	target_group_name: StringName,
	target_state_name: StringName,
	args: Dictionary
) -> void:
	if target_group_name == &"" or target_group_name == get_group_name():
		transition_to(target_state_name, args)
	else:
		requested_transition.emit(target_group_name, target_state_name, args)


func _queue_reload_from_children() -> void:
	if not _is_ready or not reload_states_on_ready or _reload_queued:
		return

	_reload_queued = true
	call_deferred("_reload_from_children_deferred")


func _reload_from_children_deferred() -> void:
	_reload_queued = false
	if _is_ready and reload_states_on_ready:
		reload_states_from_children()
		if initial_state != &"" and _current_state == null:
			transition_to(initial_state, initial_args)


func _on_child_entered_tree(_child: Node) -> void:
	_queue_reload_from_children()
