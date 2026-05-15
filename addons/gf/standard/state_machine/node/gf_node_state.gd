## GFNodeState: 基于场景树的状态节点。
##
## 适合需要直接访问动画、碰撞、输入或子节点的状态逻辑。
class_name GFNodeState
extends Node


# --- 信号 ---

## 状态请求切换时发出，由所属状态组或状态机处理。
signal requested_transition(group_name: StringName, state_name: StringName, args: Dictionary)


# --- 常量 ---

const GFAutoloadBase = preload("res://addons/gf/kernel/core/gf_autoload.gd")
const GFNodeContextBase = preload("res://addons/gf/kernel/core/gf_node_context.gd")
const _PHASE_ENTER: StringName = &"enter"
const _PHASE_EXIT: StringName = &"exit"


# --- 导出变量 ---

## 状态注册名。为空时使用节点名称。
@export var state_name: StringName = &""

@export_group("Resource Hooks")
## 进入状态前需要全部通过的条件资源。
@export var enter_conditions: Array[Resource] = []

## 离开状态前需要全部通过的条件资源。
@export var exit_conditions: Array[Resource] = []

## 进入、退出、暂停、恢复和事件处理时调用的可复用行为资源。
@export var behaviors: Array[Resource] = []

@export_group("")


# --- 公共变量 ---

## 状态机宿主节点。通常是 GFNodeStateMachine 的父节点。
var host: Node:
	get:
		return get_host()


# --- 私有变量 ---

var _machine_ref: WeakRef = null
var _group_ref: WeakRef = null
var _event_architectures: Array[GFArchitecture] = []
var _original_process_mode: int = Node.PROCESS_MODE_INHERIT


# --- Godot 生命周期方法 ---

func _ready() -> void:
	_original_process_mode = process_mode
	_set_state_enabled(false)


func _exit_tree() -> void:
	unregister_owner_events()


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
	_run_behaviors_enter(previous_state, args)


## 离开状态。
## @param next_state: 下一个状态名称。
## @param args: 状态切换时传递的可选参数。
func exit(next_state: StringName = &"", args: Dictionary = {}) -> void:
	_exit(next_state, args)
	_run_behaviors_exit(next_state, args)
	unregister_owner_events()
	_set_state_enabled(false)


## 进入栈式子状态时暂停当前状态。
## @param next_state: 下一个状态名称。
## @param args: 状态切换时传递的可选参数。
func pause(next_state: StringName = &"", args: Dictionary = {}) -> void:
	_pause(next_state, args)
	_run_behaviors_pause(next_state, args)
	_set_state_enabled(false)


## 弹出栈式子状态后恢复当前状态。
## @param previous_state: 上一个状态名称。
## @param args: 状态切换时传递的可选参数。
func resume(previous_state: StringName = &"", args: Dictionary = {}) -> void:
	_set_state_enabled(true)
	_resume(previous_state, args)
	_run_behaviors_resume(previous_state, args)


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
	_run_behaviors_initialize()


## 判断是否允许进入状态。
## @param previous_state: 来源状态名。
## @param args: 切换参数。
## @return 允许进入返回 true。
func can_enter(previous_state: StringName = &"", args: Dictionary = {}) -> bool:
	if not _can_enter(previous_state, args):
		return false
	return _evaluate_conditions(enter_conditions, _PHASE_ENTER, previous_state, args)


## 判断是否允许离开状态。
## @param next_state: 目标状态名。
## @param args: 切换参数。
## @return 允许离开返回 true。
func can_exit(next_state: StringName = &"", args: Dictionary = {}) -> bool:
	if not _can_exit(next_state, args):
		return false
	return _evaluate_conditions(exit_conditions, _PHASE_EXIT, next_state, args)


## 获取状态组共享黑板。
## @return 黑板字典；没有状态组时返回空字典。
func get_blackboard() -> Dictionary:
	var group := get_group()
	if group != null and group.has_method("get_blackboard"):
		return group.call("get_blackboard") as Dictionary
	return {}


## 处理状态事件。返回 false 时事件会继续交给同组的暂停栈状态。
## @param event_id: 状态事件标识。
## @param payload: 状态事件载荷。
## @return 已处理返回 true。
func handle_state_event(event_id: StringName, payload: Variant = null) -> bool:
	if _handle_state_event(event_id, payload):
		return true
	return _run_behaviors_handle_state_event(event_id, payload)


## 获取当前状态可用的架构实例。
## @return 架构实例；状态未挂入可解析上下文时返回 null。
func get_architecture_or_null() -> GFArchitecture:
	return _get_architecture_or_null()


## 通过当前状态上下文获取 Model。
## @param model_type: 模型脚本类型。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 模型实例。
func get_model(model_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_model(model_type, require_ready)


## 通过当前状态上下文获取 System。
## @param system_type: 系统脚本类型。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 系统实例。
func get_system(system_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_system(system_type, require_ready)


## 通过当前状态上下文获取 Utility。
## @param utility_type: 工具脚本类型。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 工具实例。
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(utility_type, require_ready)


## 仅从当前状态所属架构获取 Model，不回退父级架构。
## @param model_type: 模型脚本类型。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 当前架构中的模型实例。
func get_local_model(model_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_local_model(model_type, require_ready)


## 仅从当前状态所属架构获取 System，不回退父级架构。
## @param system_type: 系统脚本类型。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 当前架构中的系统实例。
func get_local_system(system_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_local_system(system_type, require_ready)


## 仅从当前状态所属架构获取 Utility，不回退父级架构。
## @param utility_type: 工具脚本类型。
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## @return 当前架构中的工具实例。
func get_local_utility(utility_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_local_utility(utility_type, require_ready)


## 向当前状态上下文发送命令。
## @param command: 要发送的命令实例。
## @return 命令执行结果；无可用架构时返回 null。
func send_command(command: Object) -> Variant:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.send_command(command)


## 向当前状态上下文发送查询。
## @param query: 要发送的查询实例。
## @return 查询结果；无可用架构时返回 null。
func send_query(query: Object) -> Variant:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.send_query(query)


## 发送类型事件。
## @param event_instance: 要分发的事件实例。
func send_event(event_instance: Object) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.send_event(event_instance)


## 发送轻量级 StringName 事件。
## @param event_id: StringName 事件标识符。
## @param payload: 可选的事件附加数据。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.send_simple_event(event_id, payload)


## 注册类型事件监听器，默认以当前状态作为 owner。
## @param event_type: 要监听的脚本类型。
## @param callback: 回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_event(event_type: Script, callback: Callable, priority: int = 0) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.register_event_owned(self, event_type, callback, priority)
		_remember_event_architecture(architecture)


## 注销类型事件监听器。
## @param event_type: 要注销的脚本类型。
## @param callback: 要移除的回调函数。
func unregister_event(event_type: Script, callback: Callable) -> void:
	for architecture: GFArchitecture in _get_tracked_event_architectures():
		architecture.unregister_event(event_type, callback)


## 注册可赋值类型事件监听器，默认以当前状态作为 owner。
## @param base_event_type: 要监听的基类脚本类型。
## @param callback: 回调函数。
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_assignable_event(base_event_type: Script, callback: Callable, priority: int = 0) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.register_assignable_event_owned(self, base_event_type, callback, priority)
		_remember_event_architecture(architecture)


## 注销可赋值类型事件监听器。
## @param base_event_type: 注册时使用的基类脚本类型。
## @param callback: 要移除的回调函数。
func unregister_assignable_event(base_event_type: Script, callback: Callable) -> void:
	for architecture: GFArchitecture in _get_tracked_event_architectures():
		architecture.unregister_assignable_event(base_event_type, callback)


## 注册轻量级 StringName 事件监听器，默认以当前状态作为 owner。
## @param event_id: StringName 事件标识符。
## @param callback: 回调函数，签名为 func(payload: Variant)。
func register_simple_event(event_id: StringName, callback: Callable) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.register_simple_event_owned(self, event_id, callback)
		_remember_event_architecture(architecture)


## 注销轻量级 StringName 事件监听器。
## @param event_id: StringName 事件标识符。
## @param callback: 要移除的回调函数。
func unregister_simple_event(event_id: StringName, callback: Callable) -> void:
	for architecture: GFArchitecture in _get_tracked_event_architectures():
		architecture.unregister_simple_event(event_id, callback)


## 注销当前状态通过事件代理注册过的全部监听器。
func unregister_owner_events() -> void:
	for architecture: GFArchitecture in _get_tracked_event_architectures():
		architecture.unregister_owner_events(self)
	_event_architectures.clear()


# --- 虚方法（由子类重写） ---

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


## 状态事件处理扩展点。
func _handle_state_event(_event_id: StringName, _payload: Variant = null) -> bool:
	return false


# --- 私有/辅助方法 ---

func _evaluate_conditions(
	conditions: Array[Resource],
	phase: StringName,
	peer_state: StringName,
	args: Dictionary
) -> bool:
	for condition: Resource in conditions:
		if condition != null and condition.has_method("evaluate") and not condition.call("evaluate", self, phase, peer_state, args):
			return false
	return true


func _run_behaviors_initialize() -> void:
	for behavior: Resource in behaviors:
		if behavior != null and behavior.has_method("initialize"):
			behavior.call("initialize", self)


func _run_behaviors_enter(previous_state: StringName, args: Dictionary) -> void:
	for behavior: Resource in behaviors:
		if behavior != null and behavior.has_method("enter"):
			behavior.call("enter", self, previous_state, args)


func _run_behaviors_exit(next_state: StringName, args: Dictionary) -> void:
	for behavior: Resource in behaviors:
		if behavior != null and behavior.has_method("exit"):
			behavior.call("exit", self, next_state, args)


func _run_behaviors_pause(next_state: StringName, args: Dictionary) -> void:
	for behavior: Resource in behaviors:
		if behavior != null and behavior.has_method("pause"):
			behavior.call("pause", self, next_state, args)


func _run_behaviors_resume(previous_state: StringName, args: Dictionary) -> void:
	for behavior: Resource in behaviors:
		if behavior != null and behavior.has_method("resume"):
			behavior.call("resume", self, previous_state, args)


func _run_behaviors_handle_state_event(event_id: StringName, payload: Variant) -> bool:
	for behavior: Resource in behaviors:
		if behavior != null and behavior.has_method("handle_state_event") and bool(behavior.call("handle_state_event", self, event_id, payload)):
			return true
	return false


func _set_state_enabled(enabled: bool) -> void:
	if enabled:
		process_mode = _original_process_mode
	else:
		process_mode = Node.PROCESS_MODE_DISABLED


func _get_architecture_or_null() -> GFArchitecture:
	var machine := get_machine()
	if machine != null and machine.has_method("get_architecture_or_null"):
		var machine_architecture := machine.call("get_architecture_or_null") as GFArchitecture
		if machine_architecture != null:
			return machine_architecture

	var context := _find_nearest_context()
	if context != null:
		var context_architecture := context.get_architecture()
		if context_architecture != null:
			return context_architecture

	return GFAutoloadBase.get_architecture_or_null()


func _find_nearest_context() -> GFNodeContextBase:
	var current_node: Node = self
	while current_node != null:
		if current_node is GFNodeContextBase:
			return current_node as GFNodeContextBase
		current_node = current_node.get_parent()
	return null


func _remember_event_architecture(architecture: GFArchitecture) -> void:
	if architecture == null or not is_instance_valid(architecture):
		return
	if not _event_architectures.has(architecture):
		_event_architectures.append(architecture)


func _get_tracked_event_architectures() -> Array[GFArchitecture]:
	var result: Array[GFArchitecture] = []
	var live_architectures: Array[GFArchitecture] = []
	for architecture: GFArchitecture in _event_architectures:
		if architecture != null and is_instance_valid(architecture):
			result.append(architecture)
			live_architectures.append(architecture)
	_event_architectures = live_architectures
	return result
