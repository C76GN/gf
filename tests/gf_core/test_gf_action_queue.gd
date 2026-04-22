## 测试 GFActionQueueSystem 的 push_front、push_front_parallel 功能。
extends GutTest


# --- 辅助子类 ---

## 立即完成的测试动作，记录执行顺序。
class OrderAction:
	extends GFVisualAction

	var order_list: Array
	var label: String

	func _init(p_list: Array, p_label: String) -> void:
		order_list = p_list
		label = p_label

	func execute() -> Variant:
		order_list.append(label)
		return null


## 模拟死锁信号动作。
class DeadlockSignalAction:
	extends GFVisualAction

	var emitter: Node

	func _init(e: Node) -> void:
		emitter = e

	func execute() -> Variant:
		return emitter.tree_exited # 返回一个永远不会在正常 await 中恢复的信号，除非手动触发 tree_exited


## 返回 Signal 但可被显式标记为 fire-and-forget 的测试动作。
class SignalOrderAction:
	extends GFVisualAction

	var order_list: Array
	var label: String
	var emitter: Node

	func _init(p_list: Array, p_label: String, p_emitter: Node) -> void:
		order_list = p_list
		label = p_label
		emitter = p_emitter

	func execute() -> Variant:
		order_list.append(label)
		return emitter.tree_exited


# --- 私有变量 ---

class ObjectSignalEmitter extends Object:
	signal completed


class NonNodeDeadlockSignalAction:
	extends GFVisualAction

	var emitter: ObjectSignalEmitter

	func _init(e: ObjectSignalEmitter) -> void:
		emitter = e

	func execute() -> Variant:
		return emitter.completed


var _system: GFActionQueueSystem


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_system = GFActionQueueSystem.new()
	_system.init()


func after_each() -> void:
	_system = null


# --- 测试：push_front ---

## 验证 push_front 的动作在 enqueue 的动作之前执行。
## 通过 is_processing 标志防止自动消费，以构建完整的队列后再统一处理。
func test_push_front_executes_before_enqueue() -> void:
	var order: Array = []
	_system.is_processing = true
	_system.enqueue(OrderAction.new(order, "A"))
	_system.enqueue(OrderAction.new(order, "B"))
	_system.push_front(OrderAction.new(order, "FRONT"))
	_system.is_processing = false
	_system.enqueue(OrderAction.new(order, "END"))

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order.size(), 4, "应有 4 个动作被执行。")
	assert_eq(order[0], "FRONT", "push_front 的动作应最先执行。")
	assert_eq(order[1], "A", "enqueue 的第一个动作应第二执行。")
	assert_eq(order[2], "B", "enqueue 的第二个动作应第三执行。")
	assert_eq(order[3], "END", "触发处理的动作应最后执行。")


## 验证多次 push_front 保持后进先出的顺序。
func test_multiple_push_front_lifo() -> void:
	var order: Array = []
	_system.is_processing = true
	_system.push_front(OrderAction.new(order, "C"))
	_system.push_front(OrderAction.new(order, "B"))
	_system.push_front(OrderAction.new(order, "A"))
	_system.is_processing = false
	_system.enqueue(OrderAction.new(order, "END"))

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order.size(), 4, "应有 4 个动作被执行。")
	assert_eq(order[0], "A", "最后 push_front 的应最先执行。")
	assert_eq(order[1], "B", "第二个 push_front 的应第二执行。")
	assert_eq(order[2], "C", "最早 push_front 的应第三执行。")
	assert_eq(order[3], "END", "触发处理的动作应最后执行。")


## 验证空队列 push_front 能正常启动处理。
func test_push_front_on_empty_queue() -> void:
	var order: Array = []
	_system.push_front(OrderAction.new(order, "ONLY"))

	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(order.has("ONLY"), "空队列 push_front 应正常执行。")


## 验证无效动作不会导致崩溃。
func test_push_front_null_action() -> void:
	_system.push_front(null)
	assert_true(true, "传入 null 不应崩溃。")


## 验证 clear_queue 清空后 push_front 仍可工作。
func test_clear_then_push_front() -> void:
	var order: Array = []
	_system.is_processing = true
	_system.enqueue(OrderAction.new(order, "OLD"))
	_system.clear_queue()
	_system.is_processing = false
	_system.push_front(OrderAction.new(order, "NEW"))

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order.size(), 1, "应只有 1 个动作被执行。")
	assert_eq(order[0], "NEW", "clear 后 push_front 应正常执行。")


# --- 测试：并行队列与组合 ---

## 验证 enqueue_parallel 的子动作被一并执行。
func test_enqueue_parallel() -> void:
	var order: Array = []
	var act1 := OrderAction.new(order, "P1")
	var act2 := OrderAction.new(order, "P2")
	_system.enqueue_parallel([act1, act2])

	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(order.has("P1"), "并行 P1 应执行。")
	assert_true(order.has("P2"), "并行 P2 应执行。")


## 验证顺序动作组中的瞬时动作会在同一轮队列处理中完整排空。
func test_enqueue_sequence_group_with_immediate_actions_drains() -> void:
	var order: Array = []
	var group := GFVisualActionGroup.new([
		OrderAction.new(order, "S1"),
		OrderAction.new(order, "S2"),
	], false)

	_system.enqueue(group)

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order, ["S1", "S2"], "顺序动作组应按顺序执行所有瞬时动作。")
	assert_false(_system.is_processing, "顺序动作组执行完成后，队列应正常排空。")


## 验证显式 fire-and-forget 动作即使返回 Signal，也不会阻塞后续队列。
func test_enqueue_fire_and_forget_does_not_wait_for_signal() -> void:
	var order: Array = []
	var node := Node.new()
	add_child_autofree(node)

	_system.enqueue_fire_and_forget(SignalOrderAction.new(order, "ASYNC_FAF", node))
	_system.enqueue(OrderAction.new(order, "NEXT"))

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order, ["ASYNC_FAF", "NEXT"], "fire-and-forget 动作不应阻塞后续动作。")
	assert_false(_system.is_processing, "队列应在 fire-and-forget 后正常排空。")


## 验证 push_front_parallel 能置顶插队执行。
func test_push_front_parallel() -> void:
	var order: Array = []
	# 为了测试插队，我们要利用一个需要稍微等待的动作或者在第一帧塞入
	_system.is_processing = true
	_system.enqueue(OrderAction.new(order, "END"))
	_system.push_front_parallel([OrderAction.new(order, "P1"), OrderAction.new(order, "P2")])
	_system.is_processing = false
	_system._try_start_processing()

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order.size(), 3, "共有3个动作。")
	assert_true(order.find("P1") < order.find("END"), "P1 应当在 END 之前")
	assert_true(order.find("P2") < order.find("END"), "P2 应当在 END 之前")


# --- 测试：防死锁安全网 (Task 5) ---

## 模拟动作返回的信号发射器被意外释放，验证队列不会永久卡死。
func test_no_deadlock_on_freed_non_node_emitter() -> void:
	var emitter := ObjectSignalEmitter.new()
	_system.enqueue(NonNodeDeadlockSignalAction.new(emitter))

	await get_tree().process_frame
	assert_true(_system.is_processing, "队列应进入等待非 Node 信号的处理中状态。")

	emitter.free()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_false(_system.is_processing, "非 Node 发射源被释放后，队列也应自动恢复，避免死锁。")


func test_no_deadlock_on_freed_node() -> void:
	var node := Node.new()
	add_child_autofree(node)

	var action := DeadlockSignalAction.new(node)
	_system.enqueue(action)

	# 启动处理
	await get_tree().process_frame

	# 此时队列应正在等待 node 的信号
	assert_true(_system.is_processing, "队列应处于处理中。")

	# 模拟节点被销毁 (由外部逻辑触发)
	node.free()

	# 等待几帧让系统响应处理
	await get_tree().process_frame
	await get_tree().process_frame

	assert_false(_system.is_processing, "队列应在节点销毁后自动恢复并结束处理，不产生死锁。")


func test_sequence_group_no_deadlock_on_freed_node() -> void:
	var order: Array = []
	var node := Node.new()
	add_child_autofree(node)

	var group := GFVisualActionGroup.new([
		DeadlockSignalAction.new(node),
		OrderAction.new(order, "AFTER"),
	], false)
	_system.enqueue(group)

	await get_tree().process_frame
	assert_true(_system.is_processing, "顺序动作组应进入等待状态。")

	node.free()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order, ["AFTER"], "等待源失效后，顺序动作组应继续执行后续动作。")
	assert_false(_system.is_processing, "顺序动作组在等待源销毁后也应自动恢复。")
