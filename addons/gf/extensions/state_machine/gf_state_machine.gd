## GFStateMachine: 纯代码分层有限状态机。
##
## 继承自 RefCounted，不依赖 Node 树，可在 GFSystem 或 GFUtility 中直接持有。
## 支持平铺 FSM，也支持通过 parent_state_name 组成父子状态层级；切换时会
## 按最近公共祖先执行退出/进入链，并允许事件从当前叶子状态向父状态上抛。
## context 通常是拥有它的 GFSystem/GFUtility 实例，仅用于生命周期守卫；
## 未传入 context 时，状态机仍可通过全局 Gf 访问框架依赖。
##
## 使用示例：
##   var _fsm := GFStateMachine.new(self)
##   _fsm.add_state(&"Grounded", GroundedState.new())
##   _fsm.add_state(&"Idle", IdleState.new(), &"Grounded")
##   _fsm.add_state(&"Run", RunState.new(), &"Grounded")
##   _fsm.start(&"Idle")
class_name GFStateMachine
extends RefCounted


# --- 信号 ---

## 当状态成功切换后发出。
## @param from_state: 离开的叶子状态名，初始切换时为空字符串。
## @param to_state: 进入的新叶子状态名。
signal state_changed(from_state: StringName, to_state: StringName)

## 当状态守卫阻止切换时发出。
## @param from_state: 当前叶子状态名。
## @param to_state: 请求进入的目标叶子状态名。
## @param msg: 状态切换参数。
## @param reason: 阻止原因，常见为 exit_guard 或 enter_guard。
signal transition_blocked(from_state: StringName, to_state: StringName, msg: Dictionary, reason: StringName)

## 当状态事件被某个激活状态处理后发出。
## @param event_id: 状态事件标识。
## @param handler_state: 处理该事件的状态名。
## @param payload: 状态事件载荷。
signal state_event_handled(event_id: StringName, handler_state: StringName, payload: Variant)


# --- 公共变量 ---

## 当前激活的叶子状态注册名。
var current_state_name: StringName = &""

## 状态机共享黑板。框架不解释其中字段。
var blackboard: Dictionary = {}


# --- 私有变量 ---

## 已注册的所有状态，Key 为 StringName，Value 为 GFState 实例。
var _states: Dictionary = {}

## 状态父级索引，Key 为子状态名，Value 为父状态名。
var _state_parents: Dictionary = {}

## 当前激活状态路径，按 root -> leaf 排列。
var _active_path: Array[StringName] = []

## 当前激活的叶子状态实例。
var _current_state: GFState = null

## 用于守卫框架依赖访问的上下文对象弱引用。
## 使用弱引用避免 RefCounted 环状引用。
var _context_ref: WeakRef = null
var _transition_serial: int = 0
var _is_exiting_current_state: bool = false
var _queued_exit_transition: Dictionary = {}


# --- Godot 生命周期方法 ---

## 创建状态机并注入框架上下文。
## @param context: 可选上下文对象，用于守卫 get_model/get_system/get_utility 调用。
func _init(context: Object = null) -> void:
	_context_ref = weakref(context) if context != null else null


# --- 公共方法 ---

## 注册一个状态。注册后，状态机会自动注入自身引用。
## @param state_name: 用于标识和切换该状态的唯一名称。
## @param state: GFState 实例。
## @param parent_state_name: 可选父状态名；为空表示根状态。
func add_state(state_name: StringName, state: GFState, parent_state_name: StringName = &"") -> void:
	if state_name == &"":
		push_warning("[GFStateMachine] 注册状态失败，state_name 为空。")
		return
	if state == null:
		push_warning("[GFStateMachine] 注册状态失败，state 为空：%s" % state_name)
		return

	var normalized_parent := _normalize_parent_state_name(state_name, parent_state_name)
	var old_state := _states.get(state_name) as GFState
	var is_replacing_current := old_state != null and old_state == _current_state and old_state != state
	var is_replacing_active_ancestor := (
		old_state != null
		and old_state != state
		and _active_path.has(state_name)
		and not is_replacing_current
	)

	if is_replacing_active_ancestor:
		stop()
	elif is_replacing_current:
		old_state.exit()

	if old_state != null and old_state != state:
		old_state.dispose()

	state.setup(self, state_name)
	_states[state_name] = state
	_set_parent_state_name(state_name, normalized_parent)

	if is_replacing_current:
		_active_path = _build_state_path(state_name)
		_set_current_from_active_path()
		state.enter()


## 设置已注册状态的父状态。
## @param state_name: 要调整父级的状态名。
## @param parent_state_name: 新父状态名；为空表示根状态。
## @return 设置成功返回 true。
func set_state_parent(state_name: StringName, parent_state_name: StringName = &"") -> bool:
	if not _states.has(state_name):
		push_warning("[GFStateMachine] 设置父状态失败，未找到状态：%s" % state_name)
		return false

	var normalized_parent := _normalize_parent_state_name(state_name, parent_state_name)
	if normalized_parent != parent_state_name:
		return false

	_set_parent_state_name(state_name, normalized_parent)
	if _active_path.has(state_name):
		_active_path = _build_state_path(current_state_name)
	return true


## 启动状态机并进入初始状态。
## @param initial_state_name: 首个要进入的状态名。
## @param msg: 传递给初始状态 enter() 的可选参数字典。
func start(initial_state_name: StringName, msg: Dictionary = {}) -> void:
	if not _states.has(initial_state_name):
		push_warning("[GFStateMachine] 启动失败，未找到状态：%s" % initial_state_name)
		return

	_queued_exit_transition.clear()
	_transition_to_state(initial_state_name, msg, false)


## 切换到指定状态。分层状态会按最近公共祖先执行退出/进入链。
## @param state_name: 目标状态的注册名。
## @param msg: 传递给目标状态 enter() 的可选参数字典。
func change_state(state_name: StringName, msg: Dictionary = {}) -> void:
	if not _states.has(state_name):
		push_warning("[GFStateMachine] 切换失败，未找到状态：%s" % state_name)
		return

	if _is_exiting_current_state:
		_transition_serial += 1
		_queued_exit_transition = {
			"state_name": state_name,
			"msg": msg,
		}
		return

	_transition_to_state(state_name, msg, true)


## 驱动当前状态的 update() 逻辑，应在宿主的 _process() 中调用。
## @param delta: 上一帧的时间间隔（秒）。
## @param include_ancestors: 为 true 时按 root -> leaf 顺序更新整条激活路径。
func update(delta: float, include_ancestors: bool = false) -> void:
	if include_ancestors:
		for state_name: StringName in _active_path:
			var state := _states.get(state_name) as GFState
			if state != null:
				state.update(delta)
		return

	if _current_state != null:
		_current_state.update(delta)


## 从当前叶子状态开始向父状态上抛事件，直到某个状态返回 true。
## @param event_id: 状态事件标识。
## @param payload: 状态事件载荷。
## @return 有状态处理该事件时返回 true。
func dispatch_state_event(event_id: StringName, payload: Variant = null) -> bool:
	for index in range(_active_path.size() - 1, -1, -1):
		var state_name := _active_path[index]
		var state := _states.get(state_name) as GFState
		if state != null and state.handle_state_event(event_id, payload):
			state_event_handled.emit(event_id, state_name, payload)
			return true
	return false


## 停止状态机，按 leaf -> root 顺序调用当前激活路径的 exit() 并清空状态。
func stop() -> void:
	_exit_active_path_to(0, &"", {}, false)
	_active_path.clear()
	_set_current_from_active_path()
	_queued_exit_transition.clear()


## 释放状态机持有的所有引用，避免 RefCounted 环状引用。
func dispose() -> void:
	stop()

	for state_variant: Variant in _states.values():
		var state := state_variant as GFState
		if state != null:
			state.dispose()

	_states.clear()
	_state_parents.clear()
	blackboard.clear()
	_context_ref = null


## 获取状态实例。
## @param state_name: 要查询的状态名。
## @return 已注册状态实例；不存在时返回 null。
func get_state(state_name: StringName) -> GFState:
	return _states.get(state_name) as GFState


## 获取当前叶子状态实例。
## @return 当前叶子状态；未启动时返回 null。
func get_current_state() -> GFState:
	return _current_state


## 判断状态是否已注册。
## @param state_name: 要查询的状态名。
## @return 已注册返回 true。
func has_state(state_name: StringName) -> bool:
	return _states.has(state_name)


## 获取已注册状态名列表。
## @return 状态名列表副本。
func get_state_names() -> Array[StringName]:
	var result: Array[StringName] = []
	for state_name: StringName in _states.keys():
		result.append(state_name)
	return result


## 获取指定状态的父状态名。
## @param state_name: 要查询的状态名。
## @return 父状态名；没有父级或状态不存在时返回空 StringName。
func get_parent_state_name(state_name: StringName) -> StringName:
	return _state_parents.get(state_name, &"") as StringName


## 获取当前激活状态路径，按 root -> leaf 排列。
## @return 激活状态路径副本。
func get_active_state_path() -> Array[StringName]:
	return _copy_path(_active_path)


## 判断指定状态是否在当前激活路径中。
## @param state_name: 要查询的状态名。
## @return 处于当前激活路径中返回 true。
func is_in_state(state_name: StringName) -> bool:
	return _active_path.has(state_name)


## 获取共享黑板。
## @return 状态机黑板字典。
func get_blackboard() -> Dictionary:
	return blackboard


## 获取状态机调试快照。
## @return 包含当前状态、激活路径、父子关系和黑板副本的字典。
func get_state_snapshot() -> Dictionary:
	return {
		"current_state": current_state_name,
		"active_path": get_active_state_path(),
		"states": get_state_names(),
		"parents": _state_parents.duplicate(true),
		"blackboard": blackboard.duplicate(true),
	}


## 代理获取框架内的 Model 实例。
## @param model_type: 模型的脚本类型。
## @return 模型实例，若上下文或架构无效则返回 null。
func get_model(model_type: Script) -> Object:
	var architecture := _get_available_architecture("Model")
	if architecture == null:
		return null
	return architecture.get_model(model_type)


## 代理获取框架内的 System 实例。
## @param system_type: 系统的脚本类型。
## @return 系统实例，若上下文或架构无效则返回 null。
func get_system(system_type: Script) -> Object:
	var architecture := _get_available_architecture("System")
	if architecture == null:
		return null
	return architecture.get_system(system_type)


## 代理获取框架内的 Utility 实例。
## @param utility_type: 工具的脚本类型。
## @return 工具实例，若上下文或架构无效则返回 null。
func get_utility(utility_type: Script) -> Object:
	var architecture := _get_available_architecture("Utility")
	if architecture == null:
		return null
	return architecture.get_utility(utility_type)


## 代理向框架发送命令。
## @param command: 要发送的命令实例。
## @return 命令执行结果；上下文或架构无效时返回 null。
func send_command(command: Object) -> Variant:
	var architecture := _get_available_architecture("Command")
	if architecture == null:
		return null
	return architecture.send_command(command)


## 代理向框架发送查询。
## @param query: 要发送的查询实例。
## @return 查询结果；上下文或架构无效时返回 null。
func send_query(query: Object) -> Variant:
	var architecture := _get_available_architecture("Query")
	if architecture == null:
		return null
	return architecture.send_query(query)


## 代理发送类型事件。
## @param event_instance: 要分发的事件实例。
func send_event(event_instance: Object) -> void:
	var architecture := _get_available_architecture("Event")
	if architecture != null:
		architecture.send_event(event_instance)


## 代理发送轻量级 StringName 事件。
## @param event_id: StringName 事件标识符。
## @param payload: 可选的事件附加数据。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	var architecture := _get_available_architecture("Event")
	if architecture != null:
		architecture.send_simple_event(event_id, payload)


# --- 私有/辅助方法 ---

func _transition_to_state(state_name: StringName, msg: Dictionary, emit_changed: bool) -> void:
	var target_path := _build_state_path(state_name)
	if target_path.is_empty():
		return

	var common_count := _get_common_prefix_count(_active_path, target_path)
	if _paths_equal(_active_path, target_path) and common_count > 0:
		common_count -= 1

	var block_reason := _get_transition_block_reason(target_path, common_count, msg)
	if block_reason != &"":
		transition_blocked.emit(current_state_name, state_name, msg.duplicate(true), block_reason)
		return

	_transition_serial += 1
	var current_serial := _transition_serial
	var from_name := current_state_name

	if not _exit_active_path_to(common_count, state_name, msg):
		return

	for index in range(common_count, target_path.size()):
		var entering_state_name := target_path[index]
		var entering_state := _states.get(entering_state_name) as GFState
		if entering_state == null:
			return

		_active_path.append(entering_state_name)
		_set_current_from_active_path()
		entering_state.enter(msg)
		if current_serial != _transition_serial or current_state_name != entering_state_name:
			return

	if emit_changed and current_serial == _transition_serial and current_state_name == state_name:
		state_changed.emit(from_name, state_name)


func _exit_active_path_to(
	common_count: int,
	next_state_name: StringName,
	msg: Dictionary,
	process_queued_transition: bool = true
) -> bool:
	if _active_path.size() <= common_count:
		return true

	_is_exiting_current_state = true
	var keep_count := common_count
	for index in range(_active_path.size() - 1, common_count - 1, -1):
		var exiting_state_name := _active_path[index]
		var exiting_state := _states.get(exiting_state_name) as GFState
		if exiting_state != null:
			exiting_state.exit()
		if not _queued_exit_transition.is_empty():
			keep_count = index
			break
	_is_exiting_current_state = false

	_active_path = _copy_path_prefix(_active_path, keep_count)
	_set_current_from_active_path()

	if _queued_exit_transition.is_empty():
		return true
	if not process_queued_transition:
		_queued_exit_transition.clear()
		return true

	var queued_state_name := _queued_exit_transition.get("state_name", &"") as StringName
	var queued_msg := _queued_exit_transition.get("msg", {}) as Dictionary
	_queued_exit_transition.clear()
	_transition_to_state(queued_state_name, queued_msg, true)
	return false


func _get_transition_block_reason(
	target_path: Array[StringName],
	common_count: int,
	msg: Dictionary
) -> StringName:
	var target_state_name := target_path[target_path.size() - 1]
	for index in range(_active_path.size() - 1, common_count - 1, -1):
		var active_state := _states.get(_active_path[index]) as GFState
		if active_state != null and not active_state.can_exit(target_state_name, msg):
			return &"exit_guard"

	var previous_state_name := current_state_name
	for index in range(common_count, target_path.size()):
		var target_state := _states.get(target_path[index]) as GFState
		if target_state != null and not target_state.can_enter(previous_state_name, msg):
			return &"enter_guard"

	return &""


func _normalize_parent_state_name(state_name: StringName, parent_state_name: StringName) -> StringName:
	if parent_state_name == &"":
		return &""
	if parent_state_name == state_name:
		push_error("[GFStateMachine] 父状态不能指向自身：%s" % state_name)
		return &""
	if not _states.has(parent_state_name):
		push_warning("[GFStateMachine] 父状态尚未注册，已按根状态注册：%s -> %s" % [state_name, parent_state_name])
		return &""
	if _creates_parent_cycle(state_name, parent_state_name):
		push_error("[GFStateMachine] 检测到循环状态父级：%s -> %s" % [state_name, parent_state_name])
		return &""
	return parent_state_name


func _set_parent_state_name(state_name: StringName, parent_state_name: StringName) -> void:
	if parent_state_name == &"":
		_state_parents.erase(state_name)
	else:
		_state_parents[state_name] = parent_state_name


func _creates_parent_cycle(state_name: StringName, parent_state_name: StringName) -> bool:
	var current_name := parent_state_name
	var visited: Dictionary = {}
	while current_name != &"":
		if current_name == state_name:
			return true
		if visited.has(current_name):
			return true
		visited[current_name] = true
		current_name = _state_parents.get(current_name, &"") as StringName
	return false


func _build_state_path(state_name: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	var current_name := state_name
	var visited: Dictionary = {}
	while current_name != &"":
		if visited.has(current_name):
			push_error("[GFStateMachine] 检测到循环状态父级，无法构建状态路径：%s" % state_name)
			result.clear()
			return result
		if not _states.has(current_name):
			push_warning("[GFStateMachine] 状态路径包含未注册状态：%s" % current_name)
			result.clear()
			return result

		result.insert(0, current_name)
		visited[current_name] = true
		current_name = _state_parents.get(current_name, &"") as StringName
	return result


func _get_common_prefix_count(left: Array[StringName], right: Array[StringName]) -> int:
	var count := mini(left.size(), right.size())
	for index in range(count):
		if left[index] != right[index]:
			return index
	return count


func _paths_equal(left: Array[StringName], right: Array[StringName]) -> bool:
	if left.size() != right.size():
		return false
	for index in range(left.size()):
		if left[index] != right[index]:
			return false
	return true


func _copy_path(path: Array[StringName]) -> Array[StringName]:
	var result: Array[StringName] = []
	for state_name: StringName in path:
		result.append(state_name)
	return result


func _copy_path_prefix(path: Array[StringName], count: int) -> Array[StringName]:
	var result: Array[StringName] = []
	var safe_count := clampi(count, 0, path.size())
	for index in range(safe_count):
		result.append(path[index])
	return result


func _set_current_from_active_path() -> void:
	if _active_path.is_empty():
		_current_state = null
		current_state_name = &""
		return

	current_state_name = _active_path[_active_path.size() - 1]
	_current_state = _states.get(current_state_name) as GFState


func _get_context() -> Object:
	if _context_ref == null:
		return null
	return _context_ref.get_ref()


func _get_available_architecture(dependency_name: String) -> GFArchitecture:
	var context := _get_context()
	if _context_ref != null and not is_instance_valid(context):
		push_error("[GFStateMachine] 上下文无效，无法获取 %s。" % dependency_name)
		return null

	if context != null:
		var context_architecture := _get_context_architecture(context)
		if context_architecture != null:
			return context_architecture

	var global_architecture := GFAutoload.get_architecture_or_null()
	if global_architecture == null:
		push_error("[GFStateMachine] 架构尚未初始化，无法获取 %s。" % dependency_name)
		return null

	return global_architecture


func _get_context_architecture(context: Object) -> GFArchitecture:
	if context.has_method("get_architecture_or_null"):
		return context.call("get_architecture_or_null") as GFArchitecture
	if context.has_method("_get_architecture_or_null"):
		return context.call("_get_architecture_or_null") as GFArchitecture
	if context.has_method("get_architecture"):
		return context.call("get_architecture") as GFArchitecture
	return null
