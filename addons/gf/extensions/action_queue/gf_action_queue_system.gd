## GFActionQueueSystem: 逻辑与表现解耦的动作队列系统。
## 负责串行或并行消费 `GFVisualAction`，并在等待 Signal 时对发射源失效做防死锁保护。
class_name GFActionQueueSystem
extends GFSystem


# --- 信号 ---

## 当队列从有内容变为全部执行完毕时发出。
signal queue_drained


# --- 公共变量 ---

## 是否正在处理队列。
var is_processing: bool = false


# --- 私有变量 ---

## 内部动作队列。
var _queue: Array[GFVisualAction] = []

## 当前队头索引，避免消费队列时频繁 pop_front() 触发数组搬移。
var _queue_head_index: int = 0

## 当前处理轮次，用于取消正在等待 Signal 的旧消费协程。
var _processing_serial: int = 0

## 当前正在执行或等待的动作。
var _current_action: GFVisualAction = null

## 按名称分流的子队列。
var _named_queues: Dictionary = {}

## 当前队列绑定节点的弱引用。
var _linked_node_ref: WeakRef = null


# --- Godot 生命周期方法 ---

func init() -> void:
	_processing_serial += 1
	_queue.clear()
	_queue_head_index = 0
	_current_action = null
	_named_queues.clear()
	_linked_node_ref = null
	is_processing = false


func dispose() -> void:
	clear_queue(true)
	clear_all_named_queues(true)


# --- 公共方法 ---

## 将一个动作加入顺序队列。
func enqueue(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	_queue.push_back(action)
	_try_start_processing()


## 将一个动作以显式 fire-and-forget 模式加入队列。
func enqueue_fire_and_forget(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	action.completion_mode = GFVisualAction.CompletionMode.FIRE_AND_FORGET
	enqueue(action)


## 将一批动作加入队列并并行执行。
func enqueue_parallel(actions: Array[GFVisualAction]) -> void:
	if actions.is_empty():
		return

	var group := GFVisualActionGroup.new(actions, true)
	_queue.push_back(group)
	_try_start_processing()


## 将一个动作插入队列头部。
func push_front(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	_push_front_action(action)
	_try_start_processing()


## 将一个动作以显式 fire-and-forget 模式插入队列头部。
func push_front_fire_and_forget(action: GFVisualAction) -> void:
	if not is_instance_valid(action):
		return

	action.completion_mode = GFVisualAction.CompletionMode.FIRE_AND_FORGET
	push_front(action)


## 将一批并行动作插入队列头部。
func push_front_parallel(actions: Array[GFVisualAction]) -> void:
	if actions.is_empty():
		return

	var group := GFVisualActionGroup.new(actions, true)
	_push_front_action(group)
	_try_start_processing()


## 清空队列中尚未执行的动作。
## @param stop_current: 为 true 时同时取消当前正在等待 Signal 的动作队列消费。
func clear_queue(stop_current: bool = false) -> void:
	var was_processing := is_processing
	_queue.clear()
	_queue_head_index = 0
	if stop_current:
		_processing_serial += 1
		_cancel_current_action()
		is_processing = false
		if was_processing:
			queue_drained.emit()


## 获取或创建一个命名动作队列。
func get_named_queue(queue_name: StringName) -> GFActionQueueSystem:
	if queue_name == &"":
		push_error("[GFActionQueueSystem] get_named_queue 失败：queue_name 为空。")
		return null
	if _named_queues.has(queue_name):
		return _named_queues[queue_name] as GFActionQueueSystem

	var queue := GFActionQueueSystem.new()
	var architecture := _get_architecture_or_null()
	queue.init()
	if architecture != null:
		queue.inject_dependencies(architecture)
	_named_queues[queue_name] = queue
	return queue


## 创建或获取一个绑定到节点生命周期的命名队列。
func get_linked_queue(queue_name: StringName, linked_node: Node) -> GFActionQueueSystem:
	var queue := get_named_queue(queue_name)
	if queue == null:
		return null
	queue.bind_to_node(linked_node)
	return queue


## 将当前队列绑定到节点生命周期；节点失效后队列会停止并清空。
func bind_to_node(linked_node: Node) -> void:
	_linked_node_ref = weakref(linked_node) if linked_node != null else null


## 将动作加入指定命名队列。
func enqueue_to(queue_name: StringName, action: GFVisualAction) -> void:
	var queue := get_named_queue(queue_name)
	if queue != null:
		queue.enqueue(action)


## 将动作以 fire-and-forget 模式加入指定命名队列。
func enqueue_fire_and_forget_to(queue_name: StringName, action: GFVisualAction) -> void:
	var queue := get_named_queue(queue_name)
	if queue != null:
		queue.enqueue_fire_and_forget(action)


## 将一批动作加入指定命名队列并行执行。
func enqueue_parallel_to(queue_name: StringName, actions: Array[GFVisualAction]) -> void:
	var queue := get_named_queue(queue_name)
	if queue != null:
		queue.enqueue_parallel(actions)


## 将动作插入指定命名队列头部。
func push_front_to(queue_name: StringName, action: GFVisualAction) -> void:
	var queue := get_named_queue(queue_name)
	if queue != null:
		queue.push_front(action)


## 清理指定命名队列。
func clear_named_queue(queue_name: StringName, stop_current: bool = false) -> void:
	var queue := _named_queues.get(queue_name) as GFActionQueueSystem
	if queue != null:
		queue.clear_queue(stop_current)


## 清理所有命名队列。
func clear_all_named_queues(stop_current: bool = false) -> void:
	for queue: GFActionQueueSystem in _named_queues.values():
		if queue != null:
			queue.clear_queue(stop_current)
	_named_queues.clear()


## 跳过当前动作并继续消费后续动作。
func skip_current_action() -> void:
	_processing_serial += 1
	_cancel_current_action()
	is_processing = false
	_try_start_processing()


## 驱动命名队列的生命周期清理。
func tick(_delta: float) -> void:
	if _linked_node_ref != null and _linked_node_ref.get_ref() == null:
		clear_queue(true)
	for queue_name: StringName in _named_queues.keys():
		var queue := _named_queues[queue_name] as GFActionQueueSystem
		if queue == null:
			_named_queues.erase(queue_name)
			continue
		queue.tick(_delta)


# --- 私有/辅助方法 ---

func _try_start_processing() -> void:
	if not is_processing:
		_process_queue()


func _process_queue() -> void:
	if not _has_queued_actions():
		return

	is_processing = true
	var current_serial := _processing_serial

	while current_serial == _processing_serial and _has_queued_actions():
		var action := _dequeue_action()
		if not is_instance_valid(action):
			continue

		_current_action = action
		_inject_action_dependencies(action)
		var result: Variant = action.execute()
		if action.should_wait_for_result(result):
			await action.await_result_safely(result, _is_processing_serial_current.bind(current_serial))

		if current_serial != _processing_serial:
			return
		if _current_action == action:
			_current_action = null

	_current_action = null
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


func _is_processing_serial_current(serial: int) -> bool:
	return serial == _processing_serial


func _cancel_current_action() -> void:
	if is_instance_valid(_current_action):
		_current_action.cancel()
	_current_action = null
