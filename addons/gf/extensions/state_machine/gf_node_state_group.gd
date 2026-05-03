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

## 状态切换被守卫阻止后发出。
signal transition_blocked(from_state: Node, to_state_name: StringName, args: Dictionary, reason: String)

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

## 初始化后是否自动进入 initial_state。关闭后可通过 start() 手动启动。
@export var auto_start: bool = true

## 每个状态组保留的历史状态名数量。
@export_range(1, 256, 1) var history_max_size: int = 32

## push_state 可叠加的最大栈深度。
@export_range(1, 64, 1) var max_stack_depth: int = 8

## 状态组共享黑板。框架不解释其中字段。
@export var blackboard: Dictionary = {}


# --- 私有变量 ---

var _states: Dictionary = {}
var _current_state: Node = null
var _state_stack: Array[Node] = []
var _history: Array[StringName] = []
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
## @param machine: 所属节点状态机。
## @param start_initial_state: 本次初始化是否允许自动进入 initial_state。
func initialize(machine: Object = null, start_initial_state: bool = true) -> void:
	_is_ready = true
	if machine != null:
		_machine_ref = weakref(machine)
		_setup_existing_states()
	if reload_states_on_ready:
		reload_states_from_children()
	if auto_start and start_initial_state:
		start()


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
	if not _can_transition(previous_state, next_state, next_state_name, previous_name, args):
		return
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
			if not _can_enter_state(next_state, previous_name, args):
				_current_state = null
				_emit_transition_blocked(previous_state, next_state_name, args, "enter_guard")
				return

	if not _state_stack.is_empty():
		_clear_stack(next_state_name, args)

	_current_state = next_state
	_current_state.call("enter", previous_name, args)
	_push_history(next_state_name)
	if current_serial == _transition_serial and _current_state == next_state:
		current_state_changed.emit(previous_state, _current_state)


## 暂停当前状态并叠加进入一个子状态。
func push_state(next_state_name: StringName, args: Dictionary = {}) -> void:
	if not _states.has(next_state_name):
		_warn_missing_state(next_state_name)
		return

	if _current_state == null:
		transition_to(next_state_name, args)
		return

	if _is_exiting_current_state:
		push_warning("[GFNodeStateGroup] push_state 失败：当前状态正在退出。")
		return

	if _state_stack.size() >= maxi(max_stack_depth, 1):
		push_warning("[GFNodeStateGroup] push_state 失败：状态栈已达到上限。")
		return

	var next_state := _states[next_state_name] as Node
	if next_state == _current_state:
		push_warning("[GFNodeStateGroup] push_state 失败：不能将当前状态再次压栈。")
		return

	var previous_state := _current_state
	if not previous_state.has_method("pause"):
		push_warning("[GFNodeStateGroup] push_state 失败：当前状态不支持 pause。")
		return

	var previous_name := previous_state.call("get_state_name") as StringName
	if not _can_transition(previous_state, next_state, next_state_name, previous_name, args):
		return
	previous_state.call("pause", next_state_name, args)
	_state_stack.append(previous_state)
	_current_state = next_state
	_current_state.call("enter", previous_name, args)
	_push_history(next_state_name)
	current_state_changed.emit(previous_state, _current_state)


## 退出当前子状态并恢复上一层状态。
func pop_state(args: Dictionary = {}) -> bool:
	if _state_stack.is_empty():
		return false

	if _current_state == null:
		_current_state = _state_stack.pop_back()
		return true

	if _is_exiting_current_state:
		push_warning("[GFNodeStateGroup] pop_state 失败：当前状态正在退出。")
		return false

	var previous_state := _current_state
	var restore_state := _state_stack.pop_back()
	if not restore_state.has_method("resume"):
		push_warning("[GFNodeStateGroup] pop_state 失败：目标状态不支持 resume。")
		_state_stack.append(restore_state)
		return false

	var previous_name := previous_state.call("get_state_name") as StringName
	var restore_name := restore_state.call("get_state_name") as StringName
	if not _can_transition(previous_state, restore_state, restore_name, previous_name, args):
		_state_stack.append(restore_state)
		return false

	_transition_serial += 1
	_is_exiting_current_state = true
	previous_state.call("exit", restore_name, args)
	_is_exiting_current_state = false

	if not _queued_exit_transition.is_empty():
		var queued_state_name := _queued_exit_transition["state_name"] as StringName
		var queued_args := _queued_exit_transition["args"] as Dictionary
		_queued_exit_transition.clear()
		restore_state.call("exit", queued_state_name, queued_args)
		_clear_stack(queued_state_name, queued_args)
		_current_state = null
		transition_to(queued_state_name, queued_args)
		return true

	_current_state = restore_state
	_current_state.call("resume", previous_name, args)
	_push_history(restore_name)
	current_state_changed.emit(previous_state, _current_state)
	return true


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
	_remove_from_stack(state)
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


## 获取当前状态名。
func get_current_state_name() -> StringName:
	if _current_state == null:
		return &""
	return _current_state.call("get_state_name") as StringName


## 获取状态切换历史。
func get_state_history() -> Array[StringName]:
	var result: Array[StringName] = []
	for state_name: StringName in _history:
		result.append(state_name)
	return result


## 获取当前暂停栈深度。
func get_stack_depth() -> int:
	return _state_stack.size()


## 获取状态组共享黑板。
## @return 黑板字典。
func get_blackboard() -> Dictionary:
	return blackboard


## 判断指定状态是否为当前状态或暂停栈中的状态。
func is_in_state(query_state_name: StringName) -> bool:
	if get_current_state_name() == query_state_name:
		return true

	for state: Node in _state_stack:
		if state.call("get_state_name") == query_state_name:
			return true

	return false


## 重启当前状态；若当前没有状态，则尝试进入初始状态。
func restart(args: Dictionary = {}) -> void:
	if _current_state == null:
		start(args)
		return

	transition_to(get_current_state_name(), args)


## 进入初始状态。若已有当前状态则保持不变。
## @param args: 启动时传给初始状态的参数；为空时使用 initial_args。
func start(args: Dictionary = {}) -> void:
	if _current_state != null or initial_state == &"":
		return

	transition_to(initial_state, args if not args.is_empty() else initial_args)


## 获取所有状态。
func get_states() -> Array[Node]:
	var result: Array[Node] = []
	for state: Node in _states.values():
		result.append(state)
	return result


## 清空状态。
func clear_states(free_states: bool = false) -> void:
	var states := get_states()
	_exit_active_states_for_clear()
	_states.clear()
	_current_state = null
	_state_stack.clear()
	_history.clear()
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


func _setup_existing_states() -> void:
	for state: Node in _states.values():
		state.call("setup", _get_machine(), self)


func _exit_active_states_for_clear() -> void:
	var current_state := _current_state
	var stacked_states := _state_stack.duplicate()
	_is_exiting_current_state = true
	if current_state != null and current_state.has_method("exit"):
		current_state.call("exit", &"", {})
	for state_variant: Variant in stacked_states:
		var state := state_variant as Node
		if state != null and state != current_state and state.has_method("exit"):
			state.call("exit", &"", {})
	_is_exiting_current_state = false
	_queued_exit_transition.clear()


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


func _can_transition(
	previous_state: Node,
	next_state: Node,
	next_state_name: StringName,
	previous_state_name: StringName,
	args: Dictionary
) -> bool:
	if not _can_exit_state(previous_state, next_state_name, args):
		_emit_transition_blocked(previous_state, next_state_name, args, "exit_guard")
		return false
	if not _can_enter_state(next_state, previous_state_name, args):
		_emit_transition_blocked(previous_state, next_state_name, args, "enter_guard")
		return false
	return true


func _can_exit_state(state: Node, next_state_name: StringName, args: Dictionary) -> bool:
	if state == null or not state.has_method("can_exit"):
		return true
	return bool(state.call("can_exit", next_state_name, args))


func _can_enter_state(state: Node, previous_state_name: StringName, args: Dictionary) -> bool:
	if state == null or not state.has_method("can_enter"):
		return true
	return bool(state.call("can_enter", previous_state_name, args))


func _emit_transition_blocked(from_state: Node, to_state_name: StringName, args: Dictionary, reason: String) -> void:
	transition_blocked.emit(from_state, to_state_name, args.duplicate(true), reason)


func _push_history(state_name: StringName) -> void:
	_history.append(state_name)
	_trim_history()


func _trim_history() -> void:
	var max_size := maxi(history_max_size, 1)
	while _history.size() > max_size:
		_history.pop_front()


func _clear_stack(next_state_name: StringName, args: Dictionary) -> void:
	while not _state_stack.is_empty():
		var state := _state_stack.pop_back()
		if state != null and is_instance_valid(state) and state.has_method("exit"):
			state.call("exit", next_state_name, args)


func _remove_from_stack(state: Node) -> void:
	var index := _state_stack.find(state)
	while index != -1:
		_state_stack.remove_at(index)
		index = _state_stack.find(state)


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
		if auto_start:
			start()


func _on_child_entered_tree(_child: Node) -> void:
	_queue_reload_from_children()
