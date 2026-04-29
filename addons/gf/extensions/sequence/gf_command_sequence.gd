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
			await (result as Signal)
		step_completed.emit(index, step)

	is_running = false
	if _cancel_requested:
		sequence_cancelled.emit()
	else:
		sequence_completed.emit()


## 请求取消序列。当前正在等待的外部 Signal 触发后，序列会停止后续步骤。
func cancel() -> void:
	_cancel_requested = true


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


func _get_architecture_or_null() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	if context != null:
		return context.get_architecture()
	if Gf.has_architecture():
		return Gf.get_architecture()
	return null
