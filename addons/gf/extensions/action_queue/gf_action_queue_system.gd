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

## 当前队头索引，避免消费队列时频繁 pop_front() 触发数组搬移。##
var _queue_head_index: int = 0


# --- Godot 生命周期方法 ---

func init() -> void:
	_queue.clear()
	_queue_head_index = 0
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

	_push_front_action(action)
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
	_push_front_action(group)
	_try_start_processing()


## 清空队列中尚未执行的动作。##
func clear_queue() -> void:
	_queue.clear()
	_queue_head_index = 0


# --- 私有/辅助方法 ---

func _try_start_processing() -> void:
	if not is_processing:
		_process_queue()


func _process_queue() -> void:
	if not _has_queued_actions():
		return

	is_processing = true

	while _has_queued_actions():
		var action := _dequeue_action()
		if not is_instance_valid(action):
			continue

		_inject_action_dependencies(action)
		var result: Variant = action.execute()
		if action.should_wait_for_result(result):
			await action.await_result_safely(result)

	is_processing = false
	queue_drained.emit()


func _has_queued_actions() -> bool:
	return _queue_head_index < _queue.size()


func _dequeue_action() -> GFVisualAction:
	var action := _queue[_queue_head_index]
	_queue[_queue_head_index] = null
	_queue_head_index += 1
	_compact_queue_if_needed()
	return action


func _push_front_action(action: GFVisualAction) -> void:
	if _queue_head_index > 0:
		_queue_head_index -= 1
		_queue[_queue_head_index] = action
	else:
		_queue.insert(0, action)


func _compact_queue_if_needed() -> void:
	if _queue_head_index < 64 or _queue_head_index * 2 < _queue.size():
		return

	_queue = _queue.slice(_queue_head_index)
	_queue_head_index = 0


func _inject_action_dependencies(action: GFVisualAction) -> void:
	if action.has_method("inject_dependencies"):
		action.inject_dependencies(_get_architecture_or_null())
