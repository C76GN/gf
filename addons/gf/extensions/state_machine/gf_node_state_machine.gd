## GFNodeStateMachine: 基于场景树的多状态组状态机。
##
## 支持直接子 GFNodeState 组成内部状态组，也支持多个 GFNodeStateGroup 并行工作。
class_name GFNodeStateMachine
extends Node


# --- 信号 ---

## 状态组加入后发出。
signal state_group_added(group: Node)

## 状态组移除后发出。
signal state_group_removed(group: Node)

## 任意状态组切换状态后发出。
signal state_changed(group: Node, old_state: Node, new_state: Node)


# --- 枚举 ---

## 节点状态机初始状态启动时机。
enum StartMode {
	## 状态机 ready 时启动，保持旧版本默认行为。
	ON_READY,
	## 等待宿主节点 ready 后启动。
	AFTER_HOST_READY,
	## 只加载状态，不自动启动；由外部调用 start()。
	MANUAL,
}


# --- 常量 ---

const INTERNAL_GROUP_NAME: StringName = &"_internal"
const META_INTERNAL_GROUP: StringName = &"_gf_node_state_machine_internal_group"
const GFNodeStateGroupBase = preload("res://addons/gf/extensions/state_machine/gf_node_state_group.gd")
const GFNodeStateMachineConfigBase = preload("res://addons/gf/extensions/state_machine/gf_node_state_machine_config.gd")


# --- 导出变量 ---

## 可选状态机配置资源。为空时继续使用本节点上的兼容导出项。
@export var config: GFNodeStateMachineConfig = null

## 内部状态组初始状态名。
@export var initial_state: StringName = &""

## 内部状态组初始状态参数。
@export var initial_args: Dictionary = {}

## ready 时是否自动从子节点加载状态与状态组。
@export var reload_on_ready: bool = true

## 初始状态启动模式。
@export var start_mode: StartMode = StartMode.ON_READY


# --- 私有变量 ---

var _groups: Dictionary = {}
var _internal_group: Node = null
var _group_state_changed_callables: Dictionary = {}
var _is_ready: bool = false
var _reload_queued: bool = false
var _is_reloading: bool = false
var _lifecycle_serial: int = 0


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	_lifecycle_serial += 1
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)


func _ready() -> void:
	_is_ready = true
	if reload_on_ready:
		reload_from_children()
	if start_mode == StartMode.AFTER_HOST_READY:
		_start_after_host_ready()


func _exit_tree() -> void:
	_lifecycle_serial += 1
	_is_ready = false
	_reload_queued = false
	if child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.disconnect(_on_child_entered_tree)
	clear_state_groups()


# --- 公共方法 ---

## 通过路径切换状态。path 可为 "State" 或 "Group/State"。
func transition_to(path: StringName, args: Dictionary = {}) -> void:
	var text := String(path)
	var parts := text.split("/", false)
	if parts.size() == 1:
		transition_group_to(INTERNAL_GROUP_NAME, StringName(parts[0]), args)
	elif parts.size() == 2:
		transition_group_to(StringName(parts[0]), StringName(parts[1]), args)
	else:
		push_error("[GFNodeStateMachine] transition_to 失败：路径格式无效。")


## 切换指定状态组到指定状态。
func transition_group_to(group_name: StringName, state_name: StringName, args: Dictionary = {}) -> void:
	var group := get_state_group(group_name)
	if group == null:
		push_warning("[GFNodeStateMachine] 切换失败，未找到状态组：%s" % group_name)
		return
	group.call("transition_to", state_name, args)


## 暂停当前内部状态并叠加进入一个子状态。path 可为 "State" 或 "Group/State"。
func push_state(path: StringName, args: Dictionary = {}) -> void:
	var text := String(path)
	var parts := text.split("/", false)
	if parts.size() == 1:
		push_group_state(INTERNAL_GROUP_NAME, StringName(parts[0]), args)
	elif parts.size() == 2:
		push_group_state(StringName(parts[0]), StringName(parts[1]), args)
	else:
		push_error("[GFNodeStateMachine] push_state 失败：路径格式无效。")


## 暂停指定状态组当前状态并叠加进入一个子状态。
func push_group_state(group_name: StringName, state_name: StringName, args: Dictionary = {}) -> void:
	var group := get_state_group(group_name)
	if group == null:
		push_warning("[GFNodeStateMachine] push_state 失败，未找到状态组：%s" % group_name)
		return
	if not group.has_method("push_state"):
		push_warning("[GFNodeStateMachine] push_state 失败，状态组不支持栈式状态。")
		return
	group.call("push_state", state_name, args)


## 弹出指定状态组的栈式子状态。
func pop_state(group_name: StringName = INTERNAL_GROUP_NAME, args: Dictionary = {}) -> bool:
	var group := get_state_group(group_name)
	if group == null:
		push_warning("[GFNodeStateMachine] pop_state 失败，未找到状态组：%s" % group_name)
		return false
	if not group.has_method("pop_state"):
		push_warning("[GFNodeStateMachine] pop_state 失败，状态组不支持栈式状态。")
		return false
	return bool(group.call("pop_state", args))


## 启动所有已加载状态组的初始状态。若尚未加载状态，则会先从子节点加载。
## @param args: 启动时传给初始状态的参数；为空时使用各状态组 initial_args。
func start(args: Dictionary = {}) -> void:
	if _groups.is_empty():
		reload_from_children()

	for group: Node in _groups.values():
		_start_group_node(group, args)


## 启动指定状态组的初始状态。若尚未加载状态，则会先从子节点加载。
## @param group_name: 要启动的状态组名。
## @param args: 启动时传给初始状态的参数；为空时使用该状态组 initial_args。
func start_group(group_name: StringName = INTERNAL_GROUP_NAME, args: Dictionary = {}) -> void:
	if _groups.is_empty():
		reload_from_children()

	var group := get_state_group(group_name)
	if group == null:
		push_warning("[GFNodeStateMachine] start_group 失败，未找到状态组：%s" % group_name)
		return

	_start_group_node(group, args)


## 添加状态组。
func add_state_group(group: Node) -> void:
	if not _is_node_state_group(group):
		return

	var key := group.call("get_group_name") as StringName
	if _groups.has(key):
		push_warning("[GFNodeStateMachine] 状态组已存在，已忽略重复添加：%s" % key)
		return

	_groups[key] = group
	var changed_callable := _on_group_current_state_changed.bind(group)
	_group_state_changed_callables[key] = changed_callable
	_connect_state_group_signals(group, changed_callable)
	if group is GFNodeStateGroupBase:
		group.call("initialize", self, _should_start_group_on_initialize())
	else:
		group.call("initialize", self)
	state_group_added.emit(group)


## 移除状态组。
func remove_state_group(group: Node) -> bool:
	if not _is_node_state_group(group):
		return false

	var key := group.call("get_group_name") as StringName
	if not _groups.has(key):
		return false
	var changed_callable: Callable = _group_state_changed_callables.get(key, Callable())
	_disconnect_state_group_signals(group, changed_callable)
	_groups.erase(key)
	_group_state_changed_callables.erase(key)
	state_group_removed.emit(group)
	return true


## 获取状态组。
func get_state_group(group_name: StringName) -> Node:
	return _groups.get(group_name) as Node


## 获取内部状态组当前状态。
func get_current_state() -> Node:
	var group := get_state_group(INTERNAL_GROUP_NAME)
	if group == null:
		return null
	return group.call("get_current_state") as Node


## 获取指定状态组当前状态名。
func get_current_state_name(group_name: StringName = INTERNAL_GROUP_NAME) -> StringName:
	var group := get_state_group(group_name)
	if group == null or not group.has_method("get_current_state_name"):
		return &""
	return group.call("get_current_state_name") as StringName


## 获取指定状态组状态历史。
func get_state_history(group_name: StringName = INTERNAL_GROUP_NAME) -> Array[StringName]:
	var result: Array[StringName] = []
	var group := get_state_group(group_name)
	if group == null or not group.has_method("get_state_history"):
		return result

	var history := group.call("get_state_history") as Array
	for state_name: Variant in history:
		result.append(state_name as StringName)
	return result


## 获取指定状态组暂停栈深度。
func get_stack_depth(group_name: StringName = INTERNAL_GROUP_NAME) -> int:
	var group := get_state_group(group_name)
	if group == null or not group.has_method("get_stack_depth"):
		return 0
	return int(group.call("get_stack_depth"))


## 判断 path 指向的状态是否为当前状态或暂停栈中的状态。
func is_in_state(path: StringName) -> bool:
	var text := String(path)
	var parts := text.split("/", false)
	if parts.size() == 1:
		return _is_group_in_state(INTERNAL_GROUP_NAME, StringName(parts[0]))
	if parts.size() == 2:
		return _is_group_in_state(StringName(parts[0]), StringName(parts[1]))
	push_error("[GFNodeStateMachine] is_in_state 失败：路径格式无效。")
	return false


## 重启指定状态组当前状态。
func restart_group(group_name: StringName = INTERNAL_GROUP_NAME, args: Dictionary = {}) -> void:
	var group := get_state_group(group_name)
	if group == null:
		push_warning("[GFNodeStateMachine] restart_group 失败，未找到状态组：%s" % group_name)
		return
	if not group.has_method("restart"):
		push_warning("[GFNodeStateMachine] restart_group 失败，状态组不支持重启。")
		return
	group.call("restart", args)


## 从子节点重新加载状态和状态组。
func reload_from_children() -> void:
	_is_reloading = true
	clear_state_groups()
	_internal_group = GFNodeStateGroupBase.new()
	_internal_group.name = String(INTERNAL_GROUP_NAME)
	_internal_group.set_meta(META_INTERNAL_GROUP, true)
	_internal_group.set("group_name", INTERNAL_GROUP_NAME)
	_internal_group.set("initial_state", _get_effective_initial_state())
	_internal_group.set("initial_args", _get_effective_initial_args())
	_internal_group.set("history_max_size", _get_effective_history_max_size())
	_internal_group.set("max_stack_depth", _get_effective_max_stack_depth())
	_internal_group.set("reload_states_on_ready", false)
	add_child(_internal_group, true, Node.INTERNAL_MODE_BACK)

	for child: Node in get_children():
		if child == _internal_group or child.get_meta(META_INTERNAL_GROUP, false):
			continue
		if _is_node_state_group(child):
			add_state_group(child)
		elif _is_node_state(child):
			_internal_group.call("add_state", child)

	if not (_internal_group.call("get_states") as Array).is_empty():
		add_state_group(_internal_group)
	else:
		_free_internal_group(_internal_group)
		_internal_group = null
	_is_reloading = false


## 清空所有状态组。
func clear_state_groups(free_groups: bool = false) -> void:
	var old_internal_group := _internal_group
	var groups: Array[Node] = []
	for group: Node in _groups.values():
		groups.append(group)
	for group: Node in groups:
		var key := group.call("get_group_name") as StringName
		var changed_callable: Callable = _group_state_changed_callables.get(key, Callable())
		_disconnect_state_group_signals(group, changed_callable)
	_groups.clear()
	_group_state_changed_callables.clear()
	for group: Node in groups:
		state_group_removed.emit(group)
		if group == _internal_group:
			_free_internal_group(group)
		elif free_groups:
			group.queue_free()
	if old_internal_group != null and is_instance_valid(old_internal_group) and not groups.has(old_internal_group):
		_free_internal_group(old_internal_group)
	_internal_group = null


# --- 私有/辅助方法 ---

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


func _is_node_state_group(node: Node) -> bool:
	if node == null:
		return false
	if node is GFNodeStateGroupBase:
		return true
	if not node.has_method("get_group_name"):
		return false
	if not node.has_method("transition_to"):
		return false
	if not node.has_method("initialize"):
		return false
	if not node.has_method("get_current_state"):
		return false
	if not node.has_method("get_states"):
		return false
	if not node.has_method("add_state"):
		return false
	if not node.has_method("clear_states"):
		return false
	if not node.get("current_state_changed") is Signal:
		return false
	return node.get("requested_transition") is Signal


func _connect_state_group_signals(group: Node, changed_callable: Callable) -> void:
	var changed_signal: Signal = group.get("current_state_changed")
	var transition_signal: Signal = group.get("requested_transition")
	if changed_callable.is_valid() and not changed_signal.is_connected(changed_callable):
		changed_signal.connect(changed_callable)
	if not transition_signal.is_connected(transition_group_to):
		transition_signal.connect(transition_group_to)


func _disconnect_state_group_signals(group: Node, changed_callable: Callable) -> void:
	var changed_signal: Signal = group.get("current_state_changed")
	var transition_signal: Signal = group.get("requested_transition")
	if changed_callable.is_valid() and changed_signal.is_connected(changed_callable):
		changed_signal.disconnect(changed_callable)
	if transition_signal.is_connected(transition_group_to):
		transition_signal.disconnect(transition_group_to)


func _start_group_node(group: Node, args: Dictionary) -> void:
	if group.has_method("start"):
		group.call("start", args)
		return

	var initial_state_name := StringName(group.get("initial_state"))
	if initial_state_name == &"":
		return
	group.call("transition_to", initial_state_name, args)


func _should_start_group_on_initialize() -> bool:
	match start_mode:
		StartMode.ON_READY:
			return true
		StartMode.AFTER_HOST_READY:
			return _is_host_ready()
		StartMode.MANUAL:
			return false
		_:
			return true


func _is_host_ready() -> bool:
	var host := get_parent()
	return host == null or host.is_node_ready()


func _is_lifecycle_current(lifecycle_serial: int) -> bool:
	return _lifecycle_serial == lifecycle_serial and is_inside_tree()


func _start_after_host_ready() -> void:
	var current_serial := _lifecycle_serial
	var host := get_parent()
	if host != null and not host.is_node_ready():
		await host.ready
	if not _is_lifecycle_current(current_serial):
		return
	if start_mode != StartMode.AFTER_HOST_READY:
		return

	start()


func _on_group_current_state_changed(
	old_state: Node,
	new_state: Node,
	group: Node
) -> void:
	state_changed.emit(group, old_state, new_state)


func _queue_reload_from_children() -> void:
	if not _is_ready or not reload_on_ready or _reload_queued or _is_reloading:
		return

	_reload_queued = true
	call_deferred("_reload_from_children_deferred")


func _free_internal_group(group: Node) -> void:
	if group == null or not is_instance_valid(group):
		return
	group.call("clear_states", false)
	var parent := group.get_parent()
	if parent != null:
		parent.remove_child(group)
	group.free()


func _is_group_in_state(group_name: StringName, state_name: StringName) -> bool:
	var group := get_state_group(group_name)
	if group == null or not group.has_method("is_in_state"):
		return false
	return bool(group.call("is_in_state", state_name))


func _get_effective_initial_state() -> StringName:
	if config != null:
		return config.initial_state
	return initial_state


func _get_effective_initial_args() -> Dictionary:
	if config != null:
		return config.initial_args
	return initial_args


func _get_effective_history_max_size() -> int:
	if config != null:
		return maxi(config.history_max_size, 1)
	return 32


func _get_effective_max_stack_depth() -> int:
	if config != null:
		return maxi(config.max_stack_depth, 1)
	return 8


func _reload_from_children_deferred() -> void:
	_reload_queued = false
	if _is_ready and reload_on_ready:
		reload_from_children()


func _on_child_entered_tree(_child: Node) -> void:
	_queue_reload_from_children()
