## GFAsyncWaitSupport: 内部异步等待辅助。
##
## 提供 Signal 安全断开和受 GFTimeUtility 影响的超时增量计算，供流程、序列和动作队列复用。
extends RefCounted


# --- 公共方法 ---

## 安全等待 Signal，并在发射源失效、保护节点离树、取消回调返回 false 或超时时结束等待。
## @param result_signal: 要等待的 Signal。
## @param should_continue: 可选继续等待检查；返回 false 时停止等待。
## @param time_utility: 可选时间工具。
## @param timeout_seconds: 超时时间；小于等于 0 时不启用。
## @param respect_time_scale: 是否跟随暂停和 time_scale。
## @param timeout_warning: 超时时输出的 warning；为空时不输出。
## @param guard_node: 可选生命周期保护节点。
## @return Signal 正常发出或 tree_exited 保护触发时返回 true。
static func await_signal_safely(
	result_signal: Signal,
	should_continue: Callable = Callable(),
	time_utility: GFTimeUtility = null,
	timeout_seconds: float = 30.0,
	respect_time_scale: bool = true,
	timeout_warning: String = "",
	guard_node: Node = null
) -> bool:
	var result := await _await_signal_state_safely(
		result_signal,
		should_continue,
		time_utility,
		timeout_seconds,
		respect_time_scale,
		timeout_warning,
		guard_node,
		false
	)
	return bool(result.get("completed", false))


## 安全等待 Signal，并保留 Signal 发射时携带的参数。
## @param result_signal: 要等待的 Signal。
## @param should_continue: 可选继续等待检查；返回 false 时停止等待。
## @param time_utility: 可选时间工具。
## @param timeout_seconds: 超时时间；小于等于 0 时不启用。
## @param respect_time_scale: 是否跟随暂停和 time_scale。
## @param timeout_warning: 超时时输出的 warning；为空时不输出。
## @param guard_node: 可选生命周期保护节点。
## @return 包含 completed 与 args 的等待结果。
static func await_signal_payload_safely(
	result_signal: Signal,
	should_continue: Callable = Callable(),
	time_utility: GFTimeUtility = null,
	timeout_seconds: float = 30.0,
	respect_time_scale: bool = true,
	timeout_warning: String = "",
	guard_node: Node = null
) -> Dictionary:
	return await _await_signal_state_safely(
		result_signal,
		should_continue,
		time_utility,
		timeout_seconds,
		respect_time_scale,
		timeout_warning,
		guard_node,
		true
	)


## 计算超时累计增量。
## @param previous_msec: 上一次采样时间。
## @param current_msec: 当前采样时间。
## @param time_utility: 可选时间工具。
## @param respect_time_scale: 是否跟随暂停和 time_scale。
## @return 超时增量毫秒。
static func get_timeout_elapsed_msec(
	previous_msec: int,
	current_msec: int,
	time_utility: GFTimeUtility,
	respect_time_scale: bool
) -> float:
	var elapsed_msec := float(current_msec - previous_msec)
	if not respect_time_scale:
		return elapsed_msec
	if time_utility == null:
		return elapsed_msec
	if time_utility.is_paused:
		return 0.0
	return elapsed_msec * time_utility.time_scale


## 创建可忽略 Signal 参数的恢复回调。
## @param target_signal: 目标信号。
## @param callback: 原始无参恢复回调。
## @return 可连接到目标信号的回调。
static func make_signal_resume_callable(target_signal: Signal, callback: Callable) -> Callable:
	var argument_count := get_signal_argument_count(target_signal)
	if argument_count <= 0:
		return callback
	return callback.unbind(argument_count)


## 获取信号定义中的参数数量。
## @param target_signal: 目标信号。
## @return 参数数量。
static func get_signal_argument_count(target_signal: Signal) -> int:
	if target_signal.is_null():
		return 0
	var target_obj: Object = target_signal.get_object()
	if not is_instance_valid(target_obj):
		return 0

	var target_name := StringName(target_signal.get_name())
	for signal_info: Dictionary in target_obj.get_signal_list():
		if StringName(signal_info.get("name", "")) != target_name:
			continue
		var args: Array = signal_info.get("args", [])
		return args.size()
	return 0


## 若信号已连接指定回调，则安全断开。
## @param target_signal: 目标信号。
## @param callback: 回调。
static func disconnect_signal_if_connected(target_signal: Signal, callback: Callable) -> void:
	if target_signal.is_null():
		return
	if not is_instance_valid(target_signal.get_object()):
		return
	if target_signal.is_connected(callback):
		target_signal.disconnect(callback)


# --- 私有/辅助方法 ---

static func _await_signal_state_safely(
	result_signal: Signal,
	should_continue: Callable,
	time_utility: GFTimeUtility,
	timeout_seconds: float,
	respect_time_scale: bool,
	timeout_warning: String,
	guard_node: Node,
	capture_payload: bool
) -> Dictionary:
	if result_signal.is_null():
		return {
			"completed": false,
			"args": [],
		}

	var target_obj: Object = result_signal.get_object()
	if not is_instance_valid(target_obj):
		return {
			"completed": false,
			"args": [],
		}

	var completion_state := {
		"completed": false,
		"args": [],
	}
	var on_resume := func() -> void:
		completion_state["completed"] = true
	var result_callback := _make_signal_capture_callable(result_signal, completion_state) if capture_payload else make_signal_resume_callable(result_signal, on_resume)
	var tree_exit_callback := on_resume
	var guard_exit_callback := on_resume

	result_signal.connect(result_callback, CONNECT_ONE_SHOT)

	var tree_exit_signal := Signal()
	var guard_exit_signal := Signal()
	if target_obj is Node:
		var node := target_obj as Node
		if not node.is_inside_tree() and result_signal != node.tree_exited:
			disconnect_signal_if_connected(result_signal, result_callback)
			return completion_state
		if result_signal != node.tree_exited:
			tree_exit_callback = make_signal_resume_callable(node.tree_exited, on_resume)
			node.tree_exited.connect(tree_exit_callback, CONNECT_ONE_SHOT)
			tree_exit_signal = node.tree_exited

	if is_instance_valid(guard_node) and result_signal != guard_node.tree_exited and tree_exit_signal != guard_node.tree_exited:
		if not guard_node.is_inside_tree():
			disconnect_signal_if_connected(result_signal, result_callback)
			disconnect_signal_if_connected(tree_exit_signal, tree_exit_callback)
			return completion_state
		guard_exit_callback = make_signal_resume_callable(guard_node.tree_exited, on_resume)
		guard_node.tree_exited.connect(guard_exit_callback, CONNECT_ONE_SHOT)
		guard_exit_signal = guard_node.tree_exited

	var timeout_msec := maxf(timeout_seconds, 0.0) * 1000.0
	var elapsed_timeout_msec := 0.0
	var last_timeout_msec := Time.get_ticks_msec()
	var timed_out := false
	var tree := Engine.get_main_loop() as SceneTree

	while not bool(completion_state.get("completed", false)):
		if tree == null:
			break

		var current_timeout_msec := Time.get_ticks_msec()
		if timeout_msec > 0.0:
			elapsed_timeout_msec += get_timeout_elapsed_msec(
				last_timeout_msec,
				current_timeout_msec,
				time_utility,
				respect_time_scale
			)
			if elapsed_timeout_msec >= timeout_msec:
				timed_out = true
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
		await tree.process_frame

	disconnect_signal_if_connected(result_signal, result_callback)
	disconnect_signal_if_connected(tree_exit_signal, tree_exit_callback)
	disconnect_signal_if_connected(guard_exit_signal, guard_exit_callback)

	if timed_out and not timeout_warning.is_empty():
		push_warning(timeout_warning)
	return completion_state


static func _make_signal_capture_callable(target_signal: Signal, completion_state: Dictionary) -> Callable:
	match get_signal_argument_count(target_signal):
		0:
			return func() -> void:
				completion_state["completed"] = true
				completion_state["args"] = []
		1:
			return func(first: Variant) -> void:
				completion_state["completed"] = true
				completion_state["args"] = [first]
		2:
			return func(first: Variant, second: Variant) -> void:
				completion_state["completed"] = true
				completion_state["args"] = [first, second]
		3:
			return func(first: Variant, second: Variant, third: Variant) -> void:
				completion_state["completed"] = true
				completion_state["args"] = [first, second, third]
		4:
			return func(first: Variant, second: Variant, third: Variant, fourth: Variant) -> void:
				completion_state["completed"] = true
				completion_state["args"] = [first, second, third, fourth]
		5:
			return func(first: Variant, second: Variant, third: Variant, fourth: Variant, fifth: Variant) -> void:
				completion_state["completed"] = true
				completion_state["args"] = [first, second, third, fourth, fifth]
		6:
			return func(first: Variant, second: Variant, third: Variant, fourth: Variant, fifth: Variant, sixth: Variant) -> void:
				completion_state["completed"] = true
				completion_state["args"] = [first, second, third, fourth, fifth, sixth]
		7:
			return func(first: Variant, second: Variant, third: Variant, fourth: Variant, fifth: Variant, sixth: Variant, seventh: Variant) -> void:
				completion_state["completed"] = true
				completion_state["args"] = [first, second, third, fourth, fifth, sixth, seventh]
		8:
			return func(first: Variant, second: Variant, third: Variant, fourth: Variant, fifth: Variant, sixth: Variant, seventh: Variant, eighth: Variant) -> void:
				completion_state["completed"] = true
				completion_state["args"] = [first, second, third, fourth, fifth, sixth, seventh, eighth]
		_:
			return make_signal_resume_callable(target_signal, func() -> void:
				completion_state["completed"] = true
				completion_state["args"] = []
			)
