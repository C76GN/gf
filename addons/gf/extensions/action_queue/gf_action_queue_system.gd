## GFActionQueueSystem: 逻辑与表现解耦的动作队列系统。##
## 负责串行或并行消费 `GFVisualAction`，并在等待 Signal 时对发射源失效做防死锁保护。##
class_name GFActionQueueSystem
extends GFSystem


# --- 信号 ---

## 当队列从有内容变为全部执行完毕时发出。##
signal queue_drained


# --- 公共变量 ---

## 是否正在处理队列。##
var is_processing: bool = false


# --- 私有变量 ---

## 内部动作队列。##
var _queue: Array[GFVisualAction] = []


# --- Godot 生命周期方法 ---

func init() -> void:
	_queue.clear()
	is_processing = false


# --- 公共方法 ---

## 将一个动作加入顺序队列。##
func enqueue(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	_queue.push_back(action)
	_try_start_processing()


## 将一个动作以显式 fire-and-forget 模式加入队列。##
func enqueue_fire_and_forget(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	action.completion_mode = GFVisualAction.CompletionMode.FIRE_AND_FORGET
	enqueue(action)


## 将一批动作加入队列并并行执行。##
func enqueue_parallel(actions: Array[GFVisualAction]) -> void:
	if actions.is_empty():
		return

	var group := GFVisualActionGroup.new(actions, true)
	_queue.push_back(group)
	_try_start_processing()


## 将一个动作插入队列头部。##
func push_front(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	_queue.push_front(action)
	_try_start_processing()


## 将一个动作以显式 fire-and-forget 模式插入队列头部。##
func push_front_fire_and_forget(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	action.completion_mode = GFVisualAction.CompletionMode.FIRE_AND_FORGET
	push_front(action)


## 将一批并行动作插入队列头部。##
func push_front_parallel(actions: Array[GFVisualAction]) -> void:
	if actions.is_empty():
		return

	var group := GFVisualActionGroup.new(actions, true)
	_queue.push_front(group)
	_try_start_processing()


## 清空队列中尚未执行的动作。##
func clear_queue() -> void:
	_queue.clear()


# --- 私有/辅助方法 ---

func _try_start_processing() -> void:
	if not is_processing:
		_process_queue()


func _process_queue() -> void:
	if _queue.is_empty():
		return

	is_processing = true

	while not _queue.is_empty():
		var action: GFVisualAction = _queue.pop_front()
		if not is_instance_valid(action):
			continue

		var result: Variant = action.execute()
		if action.should_wait_for_result(result):
			await _await_action_result(result as Signal)

	is_processing = false
	queue_drained.emit()


func _await_action_result(result_signal: Signal) -> void:
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
