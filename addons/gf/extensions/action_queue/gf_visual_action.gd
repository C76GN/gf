## GFVisualAction: 视觉表现动作的抽象基类。
##
## 继承自 RefCounted，代表一个具体的、可 await 的表现动作单元，
## 如移动动画、卡牌翻面、粒子爆炸等。
## 通过将每个视觉动作封装为独立对象，GFActionQueueSystem 可以严格按序
## 或并行地消费它们，从而彻底隔离底层逻辑时序与 UI 表现时序。
##
## 子类必须重写 execute() 以实现具体的视觉逻辑：
##   - 若动作是瞬时的（无需等待），直接执行并返回 null。
##   - 若动作需要等待（如 Tween/动画），返回一个 Signal，
##     外部可 await 此 Signal 以知悉动作结束。
class_name GFVisualAction
extends RefCounted


# --- 枚举 ---

## 队列如何处理 execute() 的返回值。
enum CompletionMode {
	## 自动模式：返回 Signal 时等待，否则视为立即完成。
	AUTO,
	## 显式等待：语义上声明本动作需要等待返回的 Signal。
	WAIT_FOR_SIGNAL,
	## 发出即走：即使 execute() 返回 Signal，队列也不会等待。
	FIRE_AND_FORGET,
}


# --- 公共变量 ---

## 动作完成模式。默认保持旧行为：返回 Signal 则等待，返回 null 则继续。
var completion_mode: CompletionMode = CompletionMode.AUTO

## 等待 Signal 的超时时间（秒）。小于等于 0 时表示不启用超时。
var signal_timeout_seconds: float = 30.0

## Signal 超时计时是否跟随 GFTimeUtility 的暂停与 time_scale。
var signal_timeout_respects_time_scale: bool = true


# --- 私有变量 ---

var _architecture_ref: WeakRef = null


# --- 公共方法 ---

## 执行此视觉动作。子类必须重写此方法。
## @return 瞬时动作返回 null；需要等待的动作返回一个 Signal 供 await。
func execute() -> Variant:
	return null


## 注入当前动作执行所在的架构实例。
## @param architecture: 当前架构。
func inject_dependencies(architecture: GFArchitecture) -> void:
	_architecture_ref = weakref(architecture) if architecture != null else null


## 将动作标记为显式 fire-and-forget，并返回自身以便链式调用。
func as_fire_and_forget() -> GFVisualAction:
	completion_mode = CompletionMode.FIRE_AND_FORGET
	return self


## 将动作标记为显式等待 Signal，并返回自身以便链式调用。
func as_wait_for_signal() -> GFVisualAction:
	completion_mode = CompletionMode.WAIT_FOR_SIGNAL
	return self


## 请求取消动作。基础实现不做处理，复合动作可重写以停止内部等待。
func cancel() -> void:
	pass


## 设置等待 Signal 的超时时间，并返回自身以便链式调用。
## @param seconds: 超时时间；小于等于 0 时表示不启用超时。
## @param respect_time_scale: 是否跟随 GFTimeUtility 的暂停与 time_scale。
func with_signal_timeout(seconds: float, respect_time_scale: bool = true) -> GFVisualAction:
	signal_timeout_seconds = maxf(seconds, 0.0)
	signal_timeout_respects_time_scale = respect_time_scale
	return self


## 根据当前完成模式判断队列是否应该等待 execute() 的返回值。
## @param result: execute() 返回值。
## @return 应等待返回 true。
func should_wait_for_result(result: Variant) -> bool:
	if completion_mode == CompletionMode.FIRE_AND_FORGET:
		return false
	return result is Signal


## 安全等待 execute() 返回的 Signal。
## 当发射源失效或 Node 提前退出树时，会自动结束等待，避免队列永久卡死。
## @param result: execute() 返回值。
## @param should_continue: 可选取消检查回调；返回 false 时立即停止等待。
func await_result_safely(result: Variant, should_continue: Callable = Callable()) -> void:
	if not should_wait_for_result(result):
		return

	await _await_signal_safely(result as Signal, should_continue)


# --- 私有/辅助方法 ---

func _await_signal_safely(result_signal: Signal, should_continue: Callable = Callable()) -> void:
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

	while not completed[0]:
		var current_timeout_msec := Time.get_ticks_msec()
		if timeout_msec > 0.0:
			elapsed_timeout_msec += _get_timeout_elapsed_msec(last_timeout_msec, current_timeout_msec)
			if elapsed_timeout_msec >= timeout_msec:
				push_warning("[GFVisualAction] 等待 Signal 超时，队列将继续执行后续动作。")
				break
		last_timeout_msec = current_timeout_msec

		if should_continue.is_valid() and not bool(should_continue.call()):
			break
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
	if Gf.has_architecture():
		return Gf.get_architecture()
	return null
