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


# --- 公共方法 ---

## 执行此视觉动作。子类必须重写此方法。
## @return 瞬时动作返回 null；需要等待的动作返回一个 Signal 供 await。
func execute() -> Variant:
	return null


## 将动作标记为显式 fire-and-forget，并返回自身以便链式调用。
func as_fire_and_forget() -> GFVisualAction:
	completion_mode = CompletionMode.FIRE_AND_FORGET
	return self


## 将动作标记为显式等待 Signal，并返回自身以便链式调用。
func as_wait_for_signal() -> GFVisualAction:
	completion_mode = CompletionMode.WAIT_FOR_SIGNAL
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
func await_result_safely(result: Variant) -> void:
	if not should_wait_for_result(result):
		return

	await _await_signal_safely(result as Signal)


# --- 私有/辅助方法 ---

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

	if target_obj is Node:
		var node := target_obj as Node
		if not node.is_inside_tree() and result_signal != node.tree_exited:
			return
		if result_signal != node.tree_exited:
			node.tree_exited.connect(on_resume, CONNECT_ONE_SHOT)

	while not completed[0]:
		if not is_instance_valid(target_obj):
			break
		if target_obj is Node and not (target_obj as Node).is_inside_tree():
			break
		await Engine.get_main_loop().process_frame
