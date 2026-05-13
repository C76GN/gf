extends RefCounted


# --- 常量 ---

const COMPLETION_MODE_FIRE_AND_FORGET: int = 2
const DEFAULT_SIGNAL_TIMEOUT_SECONDS: float = 30.0
const DEFAULT_SIGNAL_TIMEOUT_RESPECTS_TIME_SCALE: bool = true
const _GF_ASYNC_WAIT_SUPPORT: Script = preload("res://addons/gf/standard/common/gf_async_wait_support.gd")


# --- 公共方法 ---

## 判断对象是否符合动作队列所需的最小协议。
## @param action: 待检查的动作对象。
## @return 符合协议时返回 true。
static func is_action_valid(action: Object) -> bool:
	return is_instance_valid(action) and action.has_method("execute")


## 注入当前动作执行所在的架构。
## @param action: 动作对象。
## @param architecture: 当前架构。
static func inject_dependencies(action: Object, architecture: GFArchitecture) -> void:
	if is_action_valid(action) and action.has_method("inject_dependencies"):
		action.call("inject_dependencies", architecture)


## 判断动作是否可以执行。
## @param action: 动作对象。
## @return 可以执行返回 true。
static func can_execute(action: Object) -> bool:
	if not is_action_valid(action):
		return false
	if action.has_method("can_execute"):
		return bool(action.call("can_execute"))
	if action.has_method("is_valid"):
		return bool(action.call("is_valid"))
	return true


## 执行动作对象。
## @param action: 动作对象。
## @return execute() 返回值。
static func execute(action: Object) -> Variant:
	if not is_action_valid(action):
		return null
	return action.call("execute")


## 将动作切换为发出即走模式。
## @param action: 动作对象。
static func set_fire_and_forget(action: Object) -> void:
	if is_instance_valid(action) and _has_property(action, "completion_mode"):
		action.set("completion_mode", COMPLETION_MODE_FIRE_AND_FORGET)


## 请求取消动作。
## @param action: 动作对象。
static func cancel(action: Object) -> void:
	_call_optional(action, "cancel")


## 请求暂停动作。
## @param action: 动作对象。
static func pause(action: Object) -> void:
	_call_optional(action, "pause")


## 请求恢复动作。
## @param action: 动作对象。
static func resume(action: Object) -> void:
	_call_optional(action, "resume")


## 请求立即完成动作。
## @param action: 动作对象。
static func finish(action: Object) -> void:
	if is_instance_valid(action) and action.has_method("finish"):
		action.call("finish")
	else:
		cancel(action)


## 判断动作执行结果是否需要等待。
## @param action: 动作对象。
## @param result: execute() 返回值。
## @return 需要等待返回 true。
static func should_wait_for_result(action: Object, result: Variant) -> bool:
	if not is_action_valid(action):
		return false
	if action.has_method("should_wait_for_result"):
		return bool(action.call("should_wait_for_result", result))
	if _has_property(action, "completion_mode") and int(action.get("completion_mode")) == COMPLETION_MODE_FIRE_AND_FORGET:
		return false
	return result is Signal


## 安全等待动作返回的 Signal。
## @param action: 动作对象。
## @param result: execute() 返回值。
## @param should_continue: 可选取消检查回调；返回 false 时停止等待。
## @param architecture: 当前架构，用于读取时间缩放工具。
static func await_result_safely(
	action: Object,
	result: Variant,
	should_continue: Callable = Callable(),
	architecture: GFArchitecture = null
) -> void:
	if not should_wait_for_result(action, result):
		return

	await _await_signal_safely(action, result as Signal, should_continue, architecture)


# --- 私有/辅助方法 ---

static func _await_signal_safely(
	action: Object,
	result_signal: Signal,
	should_continue: Callable,
	architecture: GFArchitecture
) -> void:
	if result_signal.is_null():
		return

	var target_obj: Object = result_signal.get_object()
	if not is_instance_valid(target_obj):
		return

	var completed := [false]
	var on_resume := func(_arg1 = null, _arg2 = null, _arg3 = null, _arg4 = null) -> void:
		completed[0] = true

	result_signal.connect(on_resume, CONNECT_ONE_SHOT)

	var tree_exit_signal := Signal()
	var guard_exit_signal := Signal()
	if target_obj is Node:
		var node := target_obj as Node
		if not node.is_inside_tree() and result_signal != node.tree_exited:
			_GF_ASYNC_WAIT_SUPPORT.disconnect_signal_if_connected(result_signal, on_resume)
			return
		if result_signal != node.tree_exited:
			node.tree_exited.connect(on_resume, CONNECT_ONE_SHOT)
			tree_exit_signal = node.tree_exited

	var guard_node := _get_wait_guard_node(action)
	if is_instance_valid(guard_node) and result_signal != guard_node.tree_exited and tree_exit_signal != guard_node.tree_exited:
		if not guard_node.is_inside_tree():
			_GF_ASYNC_WAIT_SUPPORT.disconnect_signal_if_connected(result_signal, on_resume)
			_GF_ASYNC_WAIT_SUPPORT.disconnect_signal_if_connected(tree_exit_signal, on_resume)
			return
		guard_node.tree_exited.connect(on_resume, CONNECT_ONE_SHOT)
		guard_exit_signal = guard_node.tree_exited

	var timeout_msec := _get_signal_timeout_seconds(action) * 1000.0
	var elapsed_timeout_msec := 0.0
	var last_timeout_msec := Time.get_ticks_msec()

	while not completed[0]:
		var current_timeout_msec := Time.get_ticks_msec()
		if timeout_msec > 0.0:
			elapsed_timeout_msec += _get_timeout_elapsed_msec(action, last_timeout_msec, current_timeout_msec, architecture)
			if elapsed_timeout_msec >= timeout_msec:
				push_warning("[GFActionQueueSystem] 等待动作 Signal 超时，队列将继续执行后续动作。")
				break
		last_timeout_msec = current_timeout_msec

		if should_continue.is_valid() and not bool(should_continue.call()):
			break
		if not is_instance_valid(target_obj):
			break
		if target_obj is Node and not (target_obj as Node).is_inside_tree():
			break
		if guard_node != null and (not is_instance_valid(guard_node) or not guard_node.is_inside_tree()):
			break
		await Engine.get_main_loop().process_frame

	_GF_ASYNC_WAIT_SUPPORT.disconnect_signal_if_connected(result_signal, on_resume)
	_GF_ASYNC_WAIT_SUPPORT.disconnect_signal_if_connected(tree_exit_signal, on_resume)
	_GF_ASYNC_WAIT_SUPPORT.disconnect_signal_if_connected(guard_exit_signal, on_resume)


static func _call_optional(action: Object, method_name: StringName) -> void:
	if is_instance_valid(action) and action.has_method(method_name):
		action.call(method_name)


static func _has_property(action: Object, property_name: StringName) -> bool:
	if not is_instance_valid(action):
		return false
	for property_info: Dictionary in action.get_property_list():
		if property_info.get("name", &"") == property_name:
			return true
	return false


static func _get_wait_guard_node(action: Object) -> Node:
	if is_instance_valid(action) and action.has_method("get_wait_guard_node"):
		return action.call("get_wait_guard_node") as Node
	return null


static func _get_signal_timeout_seconds(action: Object) -> float:
	if _has_property(action, "signal_timeout_seconds"):
		return maxf(float(action.get("signal_timeout_seconds")), 0.0)
	return DEFAULT_SIGNAL_TIMEOUT_SECONDS


static func _get_timeout_elapsed_msec(
	action: Object,
	previous_msec: int,
	current_msec: int,
	architecture: GFArchitecture
) -> float:
	return _GF_ASYNC_WAIT_SUPPORT.get_timeout_elapsed_msec(
		previous_msec,
		current_msec,
		_get_time_utility(architecture),
		_get_signal_timeout_respects_time_scale(action)
	)


static func _get_signal_timeout_respects_time_scale(action: Object) -> bool:
	if _has_property(action, "signal_timeout_respects_time_scale"):
		return bool(action.get("signal_timeout_respects_time_scale"))
	return DEFAULT_SIGNAL_TIMEOUT_RESPECTS_TIME_SCALE


static func _get_time_utility(architecture: GFArchitecture) -> GFTimeUtility:
	if architecture == null:
		architecture = GFAutoload.get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(GFTimeUtility) as GFTimeUtility
