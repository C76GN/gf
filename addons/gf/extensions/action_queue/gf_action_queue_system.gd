# addons/gf/extensions/action_queue/gf_action_queue_system.gd

## GFActionQueueSystem: 逻辑与表现解耦的动画队列管理系统。
##
## 继承自 GFSystem，遵守三阶段初始化协议。
## 负责接收 GFVisualAction 并将其排入队列，然后以单消费者模式顺序消费，
## 彻底隔离底层逻辑时序（立即触发）与 UI 表现时序（动画等待）。
##
## 支持两种入队模式：
##   - enqueue(action): 顺序模式，动作完成后才执行下一个。
##   - enqueue_parallel(actions): 并行模式，将一批动作封装为一个同步点，
##     待所有并行动作均完成后，再继续队列中的下一项。
class_name GFActionQueueSystem
extends GFSystem


# --- 信号 ---

## 当队列从有内容变为全部执行完毕时发出。
signal queue_drained


# --- 公共变量 ---

## 是否正在处理队列。
var is_processing: bool = false


# --- 私有变量 ---

## 内部动作队列。元素为 GFVisualAction（顺序）或 Array[GFVisualAction]（并行批次）。
var _queue: Array = []


# --- Godot 生命周期方法 ---

## 第一阶段初始化：清空队列状态。
func init() -> void:
	_queue = []
	is_processing = false


# --- 公共方法 ---

## 将一个动作加入顺序队列，前一个动作完成后才执行。
## @param action: 要入队的 GFVisualAction 实例。
func enqueue(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	_queue.push_back(action)
	_try_start_processing()


## 将一批动作加入队列，这批动作会并行执行，全部完成后才继续队列中的下一项。
## @param actions: 要并行执行的 GFVisualAction 实例数组。
func enqueue_parallel(actions: Array[GFVisualAction]) -> void:
	if actions.is_empty():
		return

	_queue.push_back(actions)
	_try_start_processing()


## 将一个动作插入队列头部（下一个执行）。
## 适用于"后发先至"的堆栈结算逻辑，如卡牌游戏的连锁效果。
## @param action: 要插入的 GFVisualAction 实例。
func push_front(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	_queue.push_front(action)
	_try_start_processing()


## 将一批并行动作插入队列头部（下一批执行）。
## @param actions: 要并行执行的 GFVisualAction 实例数组。
func push_front_parallel(actions: Array[GFVisualAction]) -> void:
	if actions.is_empty():
		return

	_queue.push_front(actions)
	_try_start_processing()


## 清空队列中尚未执行的动作（不中断正在执行的动作）。
func clear_queue() -> void:
	_queue.clear()


# --- 私有/辅助方法 ---

## 若当前未在处理队列，则启动处理协程。
func _try_start_processing() -> void:
	if not is_processing:
		_process_queue()


## 核心队列处理协程。以单消费者模式顺序消费队列中的所有动作。
func _process_queue() -> void:
	if _queue.is_empty():
		return

	is_processing = true

	while not _queue.is_empty():
		var item: Variant = _queue.pop_front()

		if item is GFVisualAction:
			await _execute_single(item)

		elif item is Array:
			await _execute_parallel(item as Array)

	is_processing = false
	queue_drained.emit()


## 执行单个动作并等待其完成。
## @param action: 要执行的 GFVisualAction。
func _execute_single(action: GFVisualAction) -> void:
	var result: Variant = action.execute()

	if result is Signal:
		await result


## 并行执行一批动作并等待所有动作全部完成。
## @param actions: 要并行执行的动作数组。
func _execute_parallel(actions: Array) -> void:
	if actions.is_empty():
		return

	var signals: Array[Signal] = []

	for action in actions:
		if action is GFVisualAction:
			var result: Variant = action.execute()

			if result is Signal:
				signals.append(result as Signal)

	for sig in signals:
		await sig
