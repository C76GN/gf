## GFCommandSequence: 通用顺序指令执行器。
##
## 可运行 `GFSequenceStep`、`GFCommand` 或任何实现 `execute()` / `resolve()`
## 的对象。它只负责顺序、等待和架构注入，不规定具体业务语义。
class_name GFCommandSequence
extends RefCounted


# --- 信号 ---

## 序列开始执行时发出。
signal sequence_started

## 步骤开始执行时发出。
signal step_started(index: int, step: Variant)

## 步骤执行完毕时发出。
signal step_completed(index: int, step: Variant)

## 序列全部执行完成时发出。
signal sequence_completed

## 序列被取消时发出。
signal sequence_cancelled


# --- 公共变量 ---

## 默认步骤列表。
var steps: Array = []

## 序列上下文。
var context: GFSequenceContext

## 当前是否正在执行。
var is_running: bool = false

## 等待步骤 Signal 的超时时间（秒）。小于等于 0 时表示不启用超时。
var signal_timeout_seconds: float = 30.0

## Signal 超时计时是否跟随 GFTimeUtility 的暂停与 time_scale。
var signal_timeout_respects_time_scale: bool = true


# --- 私有变量 ---

var _cancel_requested: bool = false
var _architecture_ref: WeakRef = null


# --- Godot 生命周期方法 ---

func _init(p_steps: Array = [], p_context: GFSequenceContext = null) -> void:
	steps = p_steps.duplicate()
	context = p_context if p_context != null else GFSequenceContext.new()


# --- 公共方法 ---

## 注入架构。通常由 GFArchitecture 创建或注册时自动调用。
## @param architecture: 架构实例。
func inject_dependencies(architecture: GFArchitecture) -> void:
	_architecture_ref = weakref(architecture) if architecture != null else null
	if context != null:
		context.set_architecture(architecture)


## 运行序列。
## @param p_steps: 可选临时步骤列表；为空时使用 `steps`。
func run(p_steps: Array = []) -> void:
	if is_running:
		push_warning("[GFCommandSequence] 序列正在执行，忽略重复 run()。")
		return

	var run_steps := p_steps if not p_steps.is_empty() else steps
	is_running = true
	_cancel_requested = false
	sequence_started.emit()

	for index: int in range(run_steps.size()):
		if _cancel_requested:
			break

		var step: Variant = run_steps[index]
		if step == null:
			continue

		step_started.emit(index, step)
		var result: Variant = _execute_step(step)
		if _should_wait_for_step(step, result):
			await _await_signal_safely(result as Signal)
			if _cancel_requested:
				break
		step_completed.emit(index, step)

	is_running = false
	if _cancel_requested:
		sequence_cancelled.emit()
	else:
		sequence_completed.emit()


## 请求取消序列。当前正在等待的 Signal 会在下一帧取消检查后停止。
func cancel() -> void:
	_cancel_requested = true


## 设置等待 Signal 的超时时间，并返回自身以便链式调用。
## @param seconds: 超时时间；小于等于 0 时表示不启用超时。
## @param respect_time_scale: 是否跟随 GFTimeUtility 的暂停与 time_scale。
func with_signal_timeout(seconds: float, respect_time_scale: bool = true) -> GFCommandSequence:
	signal_timeout_seconds = maxf(seconds, 0.0)
	signal_timeout_respects_time_scale = respect_time_scale
	return self


# --- 私有/辅助方法 ---

func _execute_step(step: Variant) -> Variant:
	if step is Object:
		_inject_step(step)
		if step is GFSequenceStep:
			return step.execute(context)
		if step.has_method("execute"):
			return step.call("execute")
		if step.has_method("resolve"):
			return step.call("resolve")
	elif step is Callable:
		var callable := step as Callable
		if callable.is_valid():
			return callable.call()
	return null


func _inject_step(step: Object) -> void:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return
	if step.has_method("inject_dependencies"):
		step.call("inject_dependencies", architecture)
	if step.has_method("inject"):
		step.call("inject", architecture)


func _should_wait_for_step(step: Variant, result: Variant) -> bool:
	if not (result is Signal):
		return false
	if step is GFSequenceStep:
		return step.wait_for_result
	return true


func _await_signal_safely(result_signal: Signal) -> void:
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
	if target_obj is Node:
		var node := target_obj as Node
		if not node.is_inside_tree() and result_signal != node.tree_exited:
			_disconnect_signal_if_connected(result_signal, on_resume)
			return
		if result_signal != node.tree_exited:
			node.tree_exited.connect(on_resume, CONNECT_ONE_SHOT)
			tree_exit_signal = node.tree_exited

	var timeout_msec := signal_timeout_seconds * 1000.0
	var elapsed_timeout_msec := 0.0
	var last_timeout_msec := Time.get_ticks_msec()

	while not completed[0] and not _cancel_requested:
		var current_timeout_msec := Time.get_ticks_msec()
		if timeout_msec > 0.0:
			elapsed_timeout_msec += _get_timeout_elapsed_msec(last_timeout_msec, current_timeout_msec)
			if elapsed_timeout_msec >= timeout_msec:
				push_warning("[GFCommandSequence] 等待 Signal 超时，序列将继续执行后续步骤。")
				break
		last_timeout_msec = current_timeout_msec

		if not is_instance_valid(target_obj):
			break
		if target_obj is Node and not (target_obj as Node).is_inside_tree():
			break
		await Engine.get_main_loop().process_frame

	_disconnect_signal_if_connected(result_signal, on_resume)
	_disconnect_signal_if_connected(tree_exit_signal, on_resume)


func _get_timeout_elapsed_msec(previous_msec: int, current_msec: int) -> float:
	var elapsed_msec := float(current_msec - previous_msec)
	if not signal_timeout_respects_time_scale:
		return elapsed_msec

	var time_utility := _get_time_utility()
	if time_utility == null:
		return elapsed_msec
	if time_utility.is_paused:
		return 0.0
	return elapsed_msec * time_utility.time_scale


func _get_time_utility() -> GFTimeUtility:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(GFTimeUtility) as GFTimeUtility


func _disconnect_signal_if_connected(target_signal: Signal, callback: Callable) -> void:
	if target_signal.is_null():
		return
	if not is_instance_valid(target_signal.get_object()):
		return
	if target_signal.is_connected(callback):
		target_signal.disconnect(callback)


func _get_architecture_or_null() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	if context != null:
		return context.get_architecture()
	return GFAutoload.get_architecture_or_null()
