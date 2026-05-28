@tool

## GFNodeStateMachine: 基于场景树的多状态组状态机。
##
## 支持直接子 GFNodeState 组成内部状态组，也支持多个 GFNodeStateGroup 并行工作。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFNodeStateMachine
extends Node


# --- 信号 ---

## 状态组加入后发出。
## [br]
## @api public
## [br]
## @param group: 新加入的状态组。
signal state_group_added(group: GFNodeStateGroup)

## 状态组移除后发出。
## [br]
## @api public
## [br]
## @param group: 被移除的状态组。
signal state_group_removed(group: GFNodeStateGroup)

## 任意状态组切换状态后发出。
## [br]
## @api public
## [br]
## @param group: 发生状态切换的状态组。
## [br]
## @param old_state: 切换前的状态；没有旧状态时为 null。
## [br]
## @param new_state: 切换后的状态；状态组停止时可为 null。
signal state_changed(group: GFNodeStateGroup, old_state: GFNodeState, new_state: GFNodeState)

## 任意状态组中的状态处理状态事件后发出。
## [br]
## @api public
## [br]
## @param group: 处理事件的状态所属状态组。
## [br]
## @param event_id: 状态事件标识。
## [br]
## @param handler_state: 实际处理事件的状态节点。
## [br]
## @param payload: 状态事件载荷。
## [br]
## @schema payload: 状态事件载荷；具体结构由 event_id 和项目逻辑约定。
signal state_event_handled(group: GFNodeStateGroup, event_id: StringName, handler_state: GFNodeState, payload: Variant)


# --- 枚举 ---

## 节点状态机初始状态启动时机。
## [br]
## @api public
enum StartMode {
	## 状态机 ready 时启动，适合需要旧版启动顺序的项目。
	ON_READY,
	## 等待宿主节点 ready 后启动。
	AFTER_HOST_READY,
	## 只加载状态，不自动启动；由外部调用 start()。
	MANUAL,
}


# --- 常量 ---

## 直接子 GFNodeState 组成的内置状态组名称。
## [br]
## @api public
const INTERNAL_GROUP_NAME: StringName = &"_internal"

## 内部状态组节点使用的元数据键。
## [br]
## @api framework_internal
const META_INTERNAL_GROUP: StringName = &"_gf_node_state_machine_internal_group"

const _GF_AUTOLOAD_BASE = preload("res://addons/gf/kernel/core/gf_autoload.gd")
const _GF_NODE_CONTEXT_BASE = preload("res://addons/gf/kernel/core/gf_node_context.gd")
const _GF_NODE_STATE_BASE = preload("res://addons/gf/standard/state_machine/node/gf_node_state.gd")
const _GF_NODE_STATE_GROUP_BASE = preload("res://addons/gf/standard/state_machine/node/gf_node_state_group.gd")
const _GF_NODE_STATE_MACHINE_VALIDATOR_PATH: String = "res://addons/gf/standard/state_machine/node/gf_node_state_machine_validator.gd"


# --- 导出变量 ---

## 可选状态机配置资源。为空时继续使用本节点上的兼容导出项。
## [br]
## @api public
@export var config: GFNodeStateMachineConfig = null:
	set(value):
		config = value
		_queue_configuration_warning_update()

## 内部状态组初始状态名。
## [br]
## @api public
@export var initial_state: StringName = &"":
	set(value):
		initial_state = value
		_queue_configuration_warning_update()

## 内部状态组初始状态参数。
## [br]
## @api public
## [br]
## @schema initial_args: 内部状态组初始状态参数 Dictionary；键和值由初始状态的项目逻辑约定。
@export var initial_args: Dictionary = {}

## ready 时是否自动从子节点加载状态与状态组。
## [br]
## @api public
@export var reload_on_ready: bool = true

## 初始状态启动模式。
## [br]
## @api public
@export var start_mode: StartMode = StartMode.AFTER_HOST_READY:
	set(value):
		start_mode = value
		_queue_configuration_warning_update()

## 运行时重新从子节点加载时，是否尽量恢复各状态组的当前状态。
## [br]
## @api public
@export var preserve_current_state_on_reload: bool = true


# --- 私有变量 ---

var _groups: Dictionary = {}
var _internal_group: GFNodeStateGroup = null
var _group_state_changed_callables: Dictionary = {}
var _group_state_event_handled_callables: Dictionary = {}
var _event_architectures: Array[GFArchitecture] = []
var _is_ready: bool = false
var _reload_queued: bool = false
var _is_reloading: bool = false
var _preserve_reload_state_active: bool = false
var _lifecycle_serial: int = 0


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	_lifecycle_serial += 1
	if not child_entered_tree.is_connected(_on_child_entered_tree):
		child_entered_tree.connect(_on_child_entered_tree)
	if not child_exiting_tree.is_connected(_on_child_exiting_tree):
		child_exiting_tree.connect(_on_child_exiting_tree)
	_queue_configuration_warning_update()


func _ready() -> void:
	if Engine.is_editor_hint():
		_queue_configuration_warning_update()
		return

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
	if child_exiting_tree.is_connected(_on_child_exiting_tree):
		child_exiting_tree.disconnect(_on_child_exiting_tree)
	if Engine.is_editor_hint():
		return
	clear_state_groups()


# --- Godot 回调方法 ---

func _get_configuration_warnings() -> PackedStringArray:
	var validator: Variant = load(_GF_NODE_STATE_MACHINE_VALIDATOR_PATH)
	if validator == null:
		return PackedStringArray()

	var report := validator.validate_machine(self) as GFValidationReport
	var warnings: PackedStringArray = validator.make_configuration_warnings(report)
	return warnings


# --- 公共方法 ---

## 通过路径切换状态。path 可为 "State" 或 "Group/State"。
## [br]
## @api public
## [br]
## @param path: 资源路径或状态路径。
## [br]
## @param args: 状态切换时传递的可选参数。
## [br]
## @schema args: 状态切换参数 Dictionary；键和值由调用方约定。
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
## [br]
## @api public
## [br]
## @param group_name: 能力组或状态组名称。
## [br]
## @param state_name: 目标状态名称。
## [br]
## @param args: 状态切换时传递的可选参数。
## [br]
## @schema args: 状态切换参数 Dictionary；键和值由调用方约定。
func transition_group_to(group_name: StringName, state_name: StringName, args: Dictionary = {}) -> void:
	var group := get_state_group(group_name)
	if group == null:
		push_warning("[GFNodeStateMachine] 切换失败，未找到状态组：%s" % group_name)
		return
	group.call("transition_to", state_name, args)


## 暂停当前内部状态并叠加进入一个子状态。path 可为 "State" 或 "Group/State"。
## [br]
## @api public
## [br]
## @param path: 资源路径或状态路径。
## [br]
## @param args: 状态切换时传递的可选参数。
## [br]
## @schema args: 状态切换参数 Dictionary；键和值由调用方约定。
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
## [br]
## @api public
## [br]
## @param group_name: 能力组或状态组名称。
## [br]
## @param state_name: 目标状态名称。
## [br]
## @param args: 状态切换时传递的可选参数。
## [br]
## @schema args: 状态切换参数 Dictionary；键和值由调用方约定。
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
## [br]
## @api public
## [br]
## @param group_name: 能力组或状态组名称。
## [br]
## @param args: 状态切换时传递的可选参数。
## [br]
## @schema args: 状态切换参数 Dictionary；键和值由调用方约定。
## [br]
## @return: 成功恢复上一层状态时返回 true。
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
## [br]
## @api public
## [br]
## @param args: 启动时传给初始状态的参数；为空时使用各状态组 initial_args。
## [br]
## @schema args: 启动参数 Dictionary；为空时使用各状态组 initial_args。
func start(args: Dictionary = {}) -> void:
	if _groups.is_empty():
		reload_from_children()

	for group: GFNodeStateGroup in _groups.values():
		_start_group_node(group, args)


## 启动指定状态组的初始状态。若尚未加载状态，则会先从子节点加载。
## [br]
## @api public
## [br]
## @param group_name: 要启动的状态组名。
## [br]
## @param args: 启动时传给初始状态的参数；为空时使用该状态组 initial_args。
## [br]
## @schema args: 启动参数 Dictionary；为空时使用该状态组 initial_args。
func start_group(group_name: StringName = INTERNAL_GROUP_NAME, args: Dictionary = {}) -> void:
	if _groups.is_empty():
		reload_from_children()

	var group := get_state_group(group_name)
	if group == null:
		push_warning("[GFNodeStateMachine] start_group 失败，未找到状态组：%s" % group_name)
		return

	_start_group_node(group, args)


## 添加状态组。
## [br]
## @api public
## [br]
## @param group: 所属状态组。
func add_state_group(group: GFNodeStateGroup) -> void:
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
	if group is _GF_NODE_STATE_GROUP_BASE:
		group.call("initialize", self, _should_start_group_on_initialize())
	else:
		group.call("initialize", self)
	state_group_added.emit(group)


## 移除状态组。
## [br]
## @api public
## [br]
## @param group: 所属状态组。
## [br]
## @return: 成功移除已注册状态组时返回 true。
func remove_state_group(group: GFNodeStateGroup) -> bool:
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
## [br]
## @api public
## [br]
## @param group_name: 能力组或状态组名称。
## [br]
## @return: 注册名对应的状态组；不存在时返回 null。
func get_state_group(group_name: StringName) -> GFNodeStateGroup:
	return _groups.get(group_name) as GFNodeStateGroup


## 获取内部状态组当前状态。
## [br]
## @api public
## [br]
## @return: 内部状态组当前状态；未启动或不存在时返回 null。
func get_current_state() -> GFNodeState:
	var group := get_state_group(INTERNAL_GROUP_NAME)
	if group == null:
		return null
	return group.get_current_state()


## 获取指定状态组当前状态。
## [br]
## @api public
## [br]
## @param group_name: 能力组或状态组名称。
## [br]
## @return: 当前状态；未找到状态组或未启动时返回 null。
func get_current_group_state(group_name: StringName = INTERNAL_GROUP_NAME) -> GFNodeState:
	var group := get_state_group(group_name)
	if group == null:
		return null
	return group.get_current_state()


## 获取指定状态组当前状态名。
## [br]
## @api public
## [br]
## @param group_name: 能力组或状态组名称。
## [br]
## @return: 当前状态名；未找到状态组或未启动时返回空 StringName。
func get_current_state_name(group_name: StringName = INTERNAL_GROUP_NAME) -> StringName:
	var group := get_state_group(group_name)
	if group == null or not group.has_method("get_current_state_name"):
		return &""
	return group.call("get_current_state_name") as StringName


## 获取指定状态组状态历史。
## [br]
## @api public
## [br]
## @param group_name: 能力组或状态组名称。
## [br]
## @return: 最近进入过的状态名列表。
## [br]
## @schema return: 状态历史 Array[StringName]，按进入顺序排列。
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
## [br]
## @api public
## [br]
## @param group_name: 能力组或状态组名称。
## [br]
## @return: 指定状态组的暂停栈深度；未找到状态组时返回 0。
func get_stack_depth(group_name: StringName = INTERNAL_GROUP_NAME) -> int:
	var group := get_state_group(group_name)
	if group == null or not group.has_method("get_stack_depth"):
		return 0
	return int(group.call("get_stack_depth"))


## 判断 path 指向的状态是否为当前状态或暂停栈中的状态。
## [br]
## @api public
## [br]
## @param path: 资源路径或状态路径。
## [br]
## @return: 指定状态位于当前状态或暂停栈中时返回 true。
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
## [br]
## @api public
## [br]
## @param group_name: 能力组或状态组名称。
## [br]
## @param args: 状态切换时传递的可选参数。
## [br]
## @schema args: 状态切换参数 Dictionary；键和值由调用方约定。
func restart_group(group_name: StringName = INTERNAL_GROUP_NAME, args: Dictionary = {}) -> void:
	var group := get_state_group(group_name)
	if group == null:
		push_warning("[GFNodeStateMachine] restart_group 失败，未找到状态组：%s" % group_name)
		return
	if not group.has_method("restart"):
		push_warning("[GFNodeStateMachine] restart_group 失败，状态组不支持重启。")
		return
	group.call("restart", args)


## 派发状态事件。group_name 为空时会按已注册状态组顺序广播到所有组。
## [br]
## @api public
## [br]
## @param event_id: 状态事件标识。
## [br]
## @param payload: 状态事件载荷。
## [br]
## @param group_name: 可选目标状态组名；为空表示所有状态组。
## [br]
## @schema payload: 状态事件载荷；具体结构由 event_id 和项目逻辑约定。
## [br]
## @return: 有状态处理该事件时返回 true。
func dispatch_state_event(event_id: StringName, payload: Variant = null, group_name: StringName = &"") -> bool:
	if group_name != &"":
		var group := get_state_group(group_name)
		if group == null:
			return false
		return group.dispatch_state_event(event_id, payload)

	for group: GFNodeStateGroup in _groups.values():
		if group.dispatch_state_event(event_id, payload):
			return true
	return false


## 获取节点状态机调试快照。
## [br]
## @api public
## [br]
## @return: 包含所有状态组当前状态、历史、栈深度和黑板副本的字典。
## [br]
## @schema return: 调试快照 Dictionary，包含 groups 和 internal_group 字段；groups 的键为状态组名，值为 GFNodeStateGroup.get_state_snapshot() 返回的状态组快照。
func get_state_snapshot() -> Dictionary:
	var groups: Dictionary = {}
	for group_key: Variant in _groups.keys():
		var group := _groups[group_key] as GFNodeStateGroup
		if group == null:
			continue
		groups[group_key] = group.get_state_snapshot()
	return {
		"groups": groups,
		"internal_group": INTERNAL_GROUP_NAME,
	}


## 获取当前状态机可用的架构实例。
## [br]
## @api public
## [br]
## @return: 架构实例；状态机未挂入可解析上下文时返回 null。
func get_architecture_or_null() -> GFArchitecture:
	return _get_architecture_or_null()


## 通过当前状态机上下文获取 Model。
## [br]
## @api public
## [br]
## @param model_type: 模型脚本类型。
## [br]
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## [br]
## @return: 模型实例；不可用时返回 null。
func get_model(model_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_model(model_type, require_ready)


## 通过当前状态机上下文获取 System。
## [br]
## @api public
## [br]
## @param system_type: 系统脚本类型。
## [br]
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## [br]
## @return: 系统实例；不可用时返回 null。
func get_system(system_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_system(system_type, require_ready)


## 通过当前状态机上下文获取 Utility。
## [br]
## @api public
## [br]
## @param utility_type: 工具脚本类型。
## [br]
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## [br]
## @return: 工具实例；不可用时返回 null。
func get_utility(utility_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(utility_type, require_ready)


## 仅从当前状态机所属架构获取 Model，不回退父级架构。
## [br]
## @api public
## [br]
## @param model_type: 模型脚本类型。
## [br]
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## [br]
## @return: 当前架构中的模型实例；不可用时返回 null。
func get_local_model(model_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_local_model(model_type, require_ready)


## 仅从当前状态机所属架构获取 System，不回退父级架构。
## [br]
## @api public
## [br]
## @param system_type: 系统脚本类型。
## [br]
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## [br]
## @return: 当前架构中的系统实例；不可用时返回 null。
func get_local_system(system_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_local_system(system_type, require_ready)


## 仅从当前状态机所属架构获取 Utility，不回退父级架构。
## [br]
## @api public
## [br]
## @param utility_type: 工具脚本类型。
## [br]
## @param require_ready: 为 true 时，仅返回已完成 ready 阶段的实例。
## [br]
## @return: 当前架构中的工具实例；不可用时返回 null。
func get_local_utility(utility_type: Script, require_ready: bool = false) -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_local_utility(utility_type, require_ready)


## 向当前状态机上下文发送命令。
## [br]
## @api public
## [br]
## @param command: 要发送的命令实例。
## [br]
## @return: 命令执行结果；无可用架构时返回 null。
## [br]
## @schema return: 命令返回值；具体结构由 GFCommand 实现决定。
func send_command(command: Object) -> Variant:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.send_command(command)


## 向当前状态机上下文发送查询。
## [br]
## @api public
## [br]
## @param query: 要发送的查询实例。
## [br]
## @return: 查询结果；无可用架构时返回 null。
## [br]
## @schema return: 查询返回值；具体结构由 GFQuery 实现决定。
func send_query(query: Object) -> Variant:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.send_query(query)


## 发送类型事件。
## [br]
## @api public
## [br]
## @param event_instance: 要分发的事件实例。
func send_event(event_instance: Object) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.send_event(event_instance)


## 发送轻量级 StringName 事件。
## [br]
## @api public
## [br]
## @param event_id: StringName 事件标识符。
## [br]
## @param payload: 可选的事件附加数据。
## [br]
## @schema payload: 轻量事件载荷；具体结构由 event_id 和项目逻辑约定。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.send_simple_event(event_id, payload)


## 注册带拥有者的类型事件监听器。
## [br]
## @api public
## [br]
## @param owner: 监听器拥有者。
## [br]
## @param event_type: 要监听的脚本类型。
## [br]
## @param callback: 回调函数。
## [br]
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_event_owned(owner: Object, event_type: Script, callback: Callable, priority: int = 0) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.register_event_owned(owner, event_type, callback, priority)
		_remember_event_architecture(architecture)


## 注销类型事件监听器。
## [br]
## @api public
## [br]
## @param event_type: 要注销的脚本类型。
## [br]
## @param callback: 要移除的回调函数。
func unregister_event(event_type: Script, callback: Callable) -> void:
	for architecture: GFArchitecture in _get_tracked_event_architectures():
		architecture.unregister_event(event_type, callback)


## 注册带拥有者的可赋值类型事件监听器。
## [br]
## @api public
## [br]
## @param owner: 监听器拥有者。
## [br]
## @param base_event_type: 要监听的基类脚本类型。
## [br]
## @param callback: 回调函数。
## [br]
## @param priority: 回调优先级，数值越大越先执行，默认为 0。
func register_assignable_event_owned(
	owner: Object,
	base_event_type: Script,
	callback: Callable,
	priority: int = 0
) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.register_assignable_event_owned(owner, base_event_type, callback, priority)
		_remember_event_architecture(architecture)


## 注销可赋值类型事件监听器。
## [br]
## @api public
## [br]
## @param base_event_type: 注册时使用的基类脚本类型。
## [br]
## @param callback: 要移除的回调函数。
func unregister_assignable_event(base_event_type: Script, callback: Callable) -> void:
	for architecture: GFArchitecture in _get_tracked_event_architectures():
		architecture.unregister_assignable_event(base_event_type, callback)


## 注册带拥有者的轻量级 StringName 事件监听器。
## [br]
## @api public
## [br]
## @param owner: 监听器拥有者。
## [br]
## @param event_id: StringName 事件标识符。
## [br]
## @param callback: 回调函数，签名为 func(payload: Variant)。
func register_simple_event_owned(owner: Object, event_id: StringName, callback: Callable) -> void:
	var architecture := _get_architecture_or_null()
	if architecture != null:
		architecture.register_simple_event_owned(owner, event_id, callback)
		_remember_event_architecture(architecture)


## 注销轻量级 StringName 事件监听器。
## [br]
## @api public
## [br]
## @param event_id: StringName 事件标识符。
## [br]
## @param callback: 要移除的回调函数。
func unregister_simple_event(event_id: StringName, callback: Callable) -> void:
	for architecture: GFArchitecture in _get_tracked_event_architectures():
		architecture.unregister_simple_event(event_id, callback)


## 注销指定拥有者通过状态机事件代理注册过的全部监听器。
## [br]
## @api public
## [br]
## @param owner: 要清理监听器的拥有者。
func unregister_owner_events(owner: Object) -> void:
	for architecture: GFArchitecture in _get_tracked_event_architectures():
		architecture.unregister_owner_events(owner)


## 从子节点重新加载状态和状态组。
## [br]
## @api public
func reload_from_children() -> void:
	if Engine.is_editor_hint():
		_queue_configuration_warning_update()
		return

	var should_preserve_state := preserve_current_state_on_reload and not _groups.is_empty()
	var state_snapshot := _capture_state_snapshot() if should_preserve_state else {}
	_preserve_reload_state_active = should_preserve_state
	_is_reloading = true
	clear_state_groups()
	_internal_group = _GF_NODE_STATE_GROUP_BASE.new() as GFNodeStateGroup
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
			add_state_group(child as GFNodeStateGroup)
		elif _is_node_state(child):
			_internal_group.add_state(child as GFNodeState)

	if not (_internal_group.call("get_states") as Array).is_empty():
		add_state_group(_internal_group)
	else:
		_free_internal_group(_internal_group)
		_internal_group = null
	_is_reloading = false
	_preserve_reload_state_active = false
	if should_preserve_state:
		_restore_state_snapshot(state_snapshot)


## 清空所有状态组。
## [br]
## @api public
## [br]
## @param free_groups: 清理状态组时是否释放节点。
func clear_state_groups(free_groups: bool = false) -> void:
	var old_internal_group := _internal_group
	var groups: Array[GFNodeStateGroup] = []
	for group: GFNodeStateGroup in _groups.values():
		groups.append(group)
	for group: GFNodeStateGroup in groups:
		var key := group.call("get_group_name") as StringName
		var changed_callable: Callable = _group_state_changed_callables.get(key, Callable())
		_disconnect_state_group_signals(group, changed_callable)
	_groups.clear()
	_group_state_changed_callables.clear()
	_group_state_event_handled_callables.clear()
	for group: GFNodeStateGroup in groups:
		group.stop()
		state_group_removed.emit(group)
		if group == _internal_group:
			_free_internal_group(group)
		elif free_groups:
			_queue_free_detached(group)
	if old_internal_group != null and is_instance_valid(old_internal_group) and not groups.has(old_internal_group):
		_free_internal_group(old_internal_group)
	_internal_group = null


# --- 私有/辅助方法 ---

func _get_architecture_or_null() -> GFArchitecture:
	var context := _find_nearest_context()
	if context != null:
		var context_architecture := context.get_architecture()
		if context_architecture != null:
			return context_architecture

	return _GF_AUTOLOAD_BASE.get_architecture_or_null()


func _find_nearest_context() -> _GF_NODE_CONTEXT_BASE:
	var current_node: Node = self
	while current_node != null:
		if current_node is _GF_NODE_CONTEXT_BASE:
			return current_node as _GF_NODE_CONTEXT_BASE
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


func _is_node_state(node: Node) -> bool:
	return node is _GF_NODE_STATE_BASE


func _is_node_state_group(node: Node) -> bool:
	return node is _GF_NODE_STATE_GROUP_BASE


func _connect_state_group_signals(group: GFNodeStateGroup, changed_callable: Callable) -> void:
	var changed_signal: Signal = group.get("current_state_changed")
	var transition_signal: Signal = group.get("requested_transition")
	if changed_callable.is_valid() and not changed_signal.is_connected(changed_callable):
		changed_signal.connect(changed_callable)
	if not transition_signal.is_connected(transition_group_to):
		transition_signal.connect(transition_group_to)
	if group.get("state_event_handled") is Signal:
		var key := group.call("get_group_name") as StringName
		var handled_signal: Signal = group.get("state_event_handled")
		var handled_callable := _on_group_state_event_handled.bind(group)
		_group_state_event_handled_callables[key] = handled_callable
		if not handled_signal.is_connected(handled_callable):
			handled_signal.connect(handled_callable)


func _disconnect_state_group_signals(group: GFNodeStateGroup, changed_callable: Callable) -> void:
	var changed_signal: Signal = group.get("current_state_changed")
	var transition_signal: Signal = group.get("requested_transition")
	if changed_callable.is_valid() and changed_signal.is_connected(changed_callable):
		changed_signal.disconnect(changed_callable)
	if transition_signal.is_connected(transition_group_to):
		transition_signal.disconnect(transition_group_to)
	if group.get("state_event_handled") is Signal:
		var key := group.call("get_group_name") as StringName
		var handled_signal: Signal = group.get("state_event_handled")
		var handled_callable: Callable = _group_state_event_handled_callables.get(key, Callable())
		if handled_signal.is_connected(handled_callable):
			handled_signal.disconnect(handled_callable)
		_group_state_event_handled_callables.erase(key)


func _start_group_node(group: GFNodeStateGroup, args: Dictionary) -> void:
	if group.has_method("start"):
		group.call("start", args)
		return

	var initial_state_name := StringName(group.get("initial_state"))
	if initial_state_name == &"":
		return
	group.call("transition_to", initial_state_name, args)


func _should_start_group_on_initialize() -> bool:
	if _preserve_reload_state_active:
		return false
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
	old_state: GFNodeState,
	new_state: GFNodeState,
	group: GFNodeStateGroup
) -> void:
	state_changed.emit(group, old_state, new_state)


func _on_group_state_event_handled(
	event_id: StringName,
	handler_state: GFNodeState,
	payload: Variant,
	group: GFNodeStateGroup
) -> void:
	state_event_handled.emit(group, event_id, handler_state, payload)


func _queue_reload_from_children() -> void:
	if not _is_ready or not reload_on_ready or _reload_queued or _is_reloading:
		return

	_reload_queued = true
	call_deferred("_reload_from_children_deferred")


func _free_internal_group(group: GFNodeStateGroup) -> void:
	if group == null or not is_instance_valid(group):
		return
	group.call("clear_states", false)
	var parent := group.get_parent()
	if parent != null:
		parent.remove_child(group)
	group.free()


func _queue_free_detached(node: Node) -> void:
	if not is_instance_valid(node):
		return
	var parent := node.get_parent()
	if parent != null:
		parent.remove_child(node)
	if not node.is_queued_for_deletion():
		node.queue_free()


func _is_group_in_state(group_name: StringName, state_name: StringName) -> bool:
	var group := get_state_group(group_name)
	if group == null or not group.has_method("is_in_state"):
		return false
	return group.is_in_state(state_name)


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


func _queue_configuration_warning_update() -> void:
	if not Engine.is_editor_hint():
		return
	call_deferred("update_configuration_warnings")


func _reload_from_children_deferred() -> void:
	_reload_queued = false
	if Engine.is_editor_hint():
		_queue_configuration_warning_update()
		return
	if _is_ready and reload_on_ready:
		reload_from_children()


func _on_child_entered_tree(child: Node) -> void:
	if Engine.is_editor_hint():
		if _should_reload_for_child(child):
			_queue_configuration_warning_update()
		return

	if _should_reload_for_child(child):
		_queue_reload_from_children()


func _on_child_exiting_tree(child: Node) -> void:
	if Engine.is_editor_hint():
		if _should_reload_for_child(child):
			_queue_configuration_warning_update()
		return

	if _should_reload_for_child(child):
		_queue_reload_from_children()


func _should_reload_for_child(child: Node) -> bool:
	if child.get_meta(META_INTERNAL_GROUP, false):
		return false
	return _is_node_state(child) or _is_node_state_group(child)


func _capture_state_snapshot() -> Dictionary:
	var result: Dictionary = {}
	for group_key: Variant in _groups.keys():
		var group := _groups[group_key] as GFNodeStateGroup
		if group == null or not group.has_method("get_current_state_name"):
			continue
		var current_state_name := group.call("get_current_state_name") as StringName
		if current_state_name == &"":
			continue
		result[group_key] = {
			"current_state": current_state_name,
		}
	return result


func _restore_state_snapshot(snapshot: Dictionary) -> void:
	for group_key: Variant in _groups.keys():
		var group := _groups[group_key] as GFNodeStateGroup
		if group == null:
			continue

		var group_snapshot := snapshot.get(group_key, {}) as Dictionary
		var current_state_name := StringName(group_snapshot.get("current_state", &"")) if group_snapshot != null else &""
		if current_state_name != &"" and group.has_method("get_state") and group.call("get_state", current_state_name) != null:
			group.call("transition_to", current_state_name, {})
		elif _should_start_group_on_initialize():
			_start_group_node(group, {})
