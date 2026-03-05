# tests/gf_core/test_gf_action_queue.gd

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


# --- 私有变量 ---

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
