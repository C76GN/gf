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

## 步骤报告失败时发出。
signal step_failed(index: int, step: Variant, error: String)

## 序列全部执行完成时发出。
signal sequence_completed

## 序列因步骤失败而停止时发出。
signal sequence_failed(report: Dictionary)

## 序列被取消时发出。
signal sequence_cancelled


# --- 常量 ---

const _GF_ASYNC_WAIT_SUPPORT: Script = preload("res://addons/gf/standard/common/gf_async_wait_support.gd")


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

## 步骤返回失败结果时是否停止后续步骤。
var stop_on_error: bool = false

## stop_on_error 生效后，是否对已完成且实现 undo() 的步骤逆序回滚。
var rollback_on_failure: bool = false

## 最近一次运行报告。
var last_run_report: Dictionary = {}


# --- 私有变量 ---

var _cancel_requested: bool = false
var _architecture_ref: WeakRef = null
var _current_step: Variant = null


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
	var completed_steps: Array = []
	var results: Array[Dictionary] = []
	var failed := false
	var failed_index := -1
	var failed_error := ""
	sequence_started.emit()

	for index: int in range(run_steps.size()):
		if _cancel_requested:
			break

		var step: Variant = run_steps[index]
		if step == null:
			continue

		_current_step = step
		step_started.emit(index, step)
		var result: Variant = _execute_step(step)
		if _cancel_requested:
			break
		if _should_wait_for_step(step, result):
			result = await _await_signal_result_safely(result as Signal)
			if _cancel_requested:
				break
		var step_error := _get_step_error(result)
		if not step_error.is_empty():
			failed = true
			failed_index = index
			failed_error = step_error
			results.append(_make_step_report(index, false, step_error, result))
			step_failed.emit(index, step, step_error)
			if stop_on_error:
				break
			step_completed.emit(index, step)
			_current_step = null
			continue

		step_completed.emit(index, step)
		completed_steps.append(step)
		results.append(_make_step_report(index, true, "", result))
		_current_step = null

	_current_step = null
	var rolled_back := false
	if failed and stop_on_error and rollback_on_failure:
		await _rollback_steps(completed_steps)
		rolled_back = true
	is_running = false

	last_run_report = {
		"cancelled": _cancel_requested,
		"failed": failed,
		"failed_index": failed_index,
		"error": failed_error,
		"succeeded": completed_steps.size(),
		"rolled_back": rolled_back,
		"results": results,
	}
	if _cancel_requested:
		sequence_cancelled.emit()
	elif failed and stop_on_error:
		sequence_failed.emit(last_run_report)
	else:
		sequence_completed.emit()


## 请求取消序列。当前步骤实现取消入口时会先收到取消请求，正在等待的 Signal 会在下一帧取消检查后停止。
func cancel() -> void:
	if _cancel_requested:
		return
	_cancel_requested = true
	_cancel_current_step()


## 设置等待 Signal 的超时时间，并返回自身以便链式调用。
## @param seconds: 超时时间；小于等于 0 时表示不启用超时。
## @param respect_time_scale: 是否跟随 GFTimeUtility 的暂停与 time_scale。
func with_signal_timeout(seconds: float, respect_time_scale: bool = true) -> GFCommandSequence:
	signal_timeout_seconds = maxf(seconds, 0.0)
	signal_timeout_respects_time_scale = respect_time_scale
	return self


## 设置失败处理策略，并返回自身以便链式调用。
## @param should_stop_on_error: 是否在失败结果后停止。
## @param should_rollback_on_failure: 是否逆序调用已完成步骤 undo()。
## @return 当前序列。
func with_failure_policy(
	should_stop_on_error: bool = true,
	should_rollback_on_failure: bool = false
) -> GFCommandSequence:
	stop_on_error = should_stop_on_error
	rollback_on_failure = should_rollback_on_failure
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


func _cancel_current_step() -> void:
	if _current_step == null:
		return

	if _current_step is GFSequenceStep:
		(_current_step as GFSequenceStep).cancel(context)
		return

	var step := _current_step as Object
	if step != null and step.has_method("cancel"):
		step.call("cancel")


func _get_step_error(result: Variant) -> String:
	if not (result is Dictionary):
		return ""

	var data := result as Dictionary
	var failed := false
	if data.has("ok") and not bool(data.get("ok", true)):
		failed = true
	if data.has("success") and not bool(data.get("success", true)):
		failed = true

	var status := String(data.get("status", "")).to_lower()
	if status == "error" or status == "failed" or status == "failure":
		failed = true

	if not failed:
		return ""

	var error_value: Variant = data.get("error", data.get("message", data.get("reason", "")))
	if error_value is Dictionary or error_value is Array:
		return JSON.stringify(error_value)

	var error := String(error_value)
	return error if not error.is_empty() else "Step failed."


func _make_step_report(index: int, ok: bool, error: String, result: Variant) -> Dictionary:
	return {
		"index": index,
		"ok": ok,
		"error": error,
		"result": result,
	}


func _rollback_steps(completed_steps: Array) -> void:
	for index: int in range(completed_steps.size() - 1, -1, -1):
		var step := completed_steps[index] as Object
		if step == null or not step.has_method("undo"):
			continue
		_inject_step(step)
		var result: Variant = step.call("undo")
		if result is Signal:
			await _await_signal_safely(result as Signal)


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
	await _GF_ASYNC_WAIT_SUPPORT.await_signal_safely(
		result_signal,
		_should_continue_waiting,
		_get_time_utility(),
		signal_timeout_seconds,
		signal_timeout_respects_time_scale,
		"[GFCommandSequence] 等待 Signal 超时，序列将继续执行后续步骤。"
	)


func _await_signal_result_safely(result_signal: Signal) -> Variant:
	var wait_result: Dictionary = await _GF_ASYNC_WAIT_SUPPORT.await_signal_payload_safely(
		result_signal,
		_should_continue_waiting,
		_get_time_utility(),
		signal_timeout_seconds,
		signal_timeout_respects_time_scale,
		"[GFCommandSequence] 等待 Signal 超时，序列将继续执行后续步骤。"
	)
	if not bool(wait_result.get("completed", false)):
		return null
	return _normalize_signal_result(wait_result.get("args", []))


func _normalize_signal_result(args: Variant) -> Variant:
	if not (args is Array):
		return args
	var values := args as Array
	if values.is_empty():
		return null
	if values.size() == 1:
		return values[0]
	return values


func _get_time_utility() -> GFTimeUtility:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(GFTimeUtility) as GFTimeUtility


func _should_continue_waiting() -> bool:
	return not _cancel_requested


func _get_architecture_or_null() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	if context != null:
		return context.get_architecture()
	return GFAutoload.get_architecture_or_null()
