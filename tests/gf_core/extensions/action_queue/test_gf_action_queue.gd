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


## 执行前判定为无效的测试动作。
class InvalidOrderAction:
	extends OrderAction

	func is_valid() -> bool:
		return false


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


## 手动完成的 Signal 动作，用于测试队列取消。
class ManualSignalAction:
	extends GFVisualAction

	signal completed

	var order_list: Array
	var label: String
	var cancelled: bool = false

	func _init(p_list: Array, p_label: String) -> void:
		order_list = p_list
		label = p_label

	func execute() -> Variant:
		order_list.append(label)
		return completed

	func cancel() -> void:
		cancelled = true

	func complete() -> void:
		completed.emit()


## 可暂停、恢复、完成的测试动作。
class ControllableSignalAction:
	extends ManualSignalAction

	var paused: bool = false
	var resumed: bool = false
	var finished: bool = false

	func pause() -> void:
		paused = true

	func resume() -> void:
		resumed = true

	func finish() -> void:
		finished = true
		complete()


## 记录队列执行前注入到动作中的架构。
class InjectedAction:
	extends GFVisualAction

	var injected_architecture: GFArchitecture = null
	var executed: bool = false

	func inject_dependencies(architecture: GFArchitecture) -> void:
		super.inject_dependencies(architecture)
		injected_architecture = architecture

	func execute() -> Variant:
		executed = true
		return null


## 按标签跳过或替换动作的测试拦截器。
class RewriteInterceptor:
	extends GFActionInterceptor

	var order_list: Array

	func _init(p_order_list: Array) -> void:
		order_list = p_order_list

	func _before_execute(action: Object, _queue: GFActionQueueSystem) -> GFActionInterceptionResult:
		if action is OrderAction:
			var order_action := action as OrderAction
			order_list.append("before:%s" % order_action.label)
			if order_action.label == "SKIP":
				return GFActionInterceptionResult.skip_action()
			if order_action.label == "OLD":
				return GFActionInterceptionResult.replace_with(OrderAction.new(order_list, "NEW"))
		return GFActionInterceptionResult.continue_action()

	func _after_execute(action: Object, _queue: GFActionQueueSystem, _execute_result: Variant) -> GFActionInterceptionResult:
		if action is OrderAction:
			order_list.append("after:%s" % (action as OrderAction).label)
		return GFActionInterceptionResult.continue_action()


## 记录执行顺序的测试拦截器。
class PriorityInterceptor:
	extends GFActionInterceptor

	var order_list: Array
	var label: String

	func _init(p_order_list: Array, p_label: String, p_priority: int) -> void:
		order_list = p_order_list
		label = p_label
		priority = p_priority

	func _before_execute(_action: Object, _queue: GFActionQueueSystem) -> GFActionInterceptionResult:
		order_list.append(label)
		return GFActionInterceptionResult.continue_action()


## 执行指定动作后停止队列的测试拦截器。
class StopAfterInterceptor:
	extends GFActionInterceptor

	func _after_execute(action: Object, _queue: GFActionQueueSystem, _execute_result: Variant) -> GFActionInterceptionResult:
		if action is OrderAction and (action as OrderAction).label == "STOP":
			return GFActionInterceptionResult.stop_queue()
		if action is ManualSignalAction and (action as ManualSignalAction).label == "STOP":
			return GFActionInterceptionResult.stop_queue()
		return GFActionInterceptionResult.continue_action()


class ReplaceWithInjectedInterceptor:
	extends GFActionInterceptor

	var replacement: InjectedAction

	func _init(p_replacement: InjectedAction) -> void:
		replacement = p_replacement

	func _before_execute(_action: Object, _queue: GFActionQueueSystem) -> GFActionInterceptionResult:
		return GFActionInterceptionResult.replace_with(replacement)


class ObserveInjectedReplacementInterceptor:
	extends GFActionInterceptor

	var observed_architecture: GFArchitecture = null

	func _before_execute(action: Object, _queue: GFActionQueueSystem) -> GFActionInterceptionResult:
		if action is InjectedAction:
			observed_architecture = (action as InjectedAction).injected_architecture
		return GFActionInterceptionResult.continue_action()


# --- 私有变量 ---

class ObjectSignalEmitter extends Object:
	signal completed

	func get_completed_signal() -> Signal:
		return completed


class NonNodeDeadlockSignalAction:
	extends GFVisualAction

	var emitter: ObjectSignalEmitter

	func _init(e: ObjectSignalEmitter) -> void:
		emitter = e

	func execute() -> Variant:
		return emitter.get_completed_signal()


class InvalidCompletedSignalAction:
	extends GFVisualAction

	var order_list: Array
	var label: String

	func _init(p_order_list: Array, p_label: String) -> void:
		order_list = p_order_list
		label = p_label

	func execute() -> Variant:
		order_list.append(label)
		var emitter := ObjectSignalEmitter.new()
		var result := emitter.get_completed_signal()
		emitter.free()
		return result


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


## 验证 clear_queue(true) 会终止当前等待并丢弃后续队列。
func test_clear_queue_can_stop_current_waiting_action() -> void:
	var order: Array = []
	var waiting_action := ManualSignalAction.new(order, "WAIT")
	_system.enqueue(waiting_action)
	_system.enqueue(OrderAction.new(order, "AFTER"))

	await get_tree().process_frame
	assert_true(_system.is_processing, "队列应正在等待当前 Signal 动作。")

	watch_signals(_system)
	_system.clear_queue(true)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(waiting_action.cancelled, "stop_current 应向当前动作发送 cancel。")
	assert_false(_system.is_processing, "stop_current 后队列不应继续处于处理中。")
	assert_eq(order, ["WAIT"], "stop_current 后未执行的后续动作应被丢弃。")
	assert_signal_emitted(_system, "queue_drained", "stop_current 清空运行中队列时应发出排空信号。")


## 验证取消当前动作组时会递归取消正在等待的子动作。
func test_clear_queue_propagates_cancel_to_group_children() -> void:
	var order: Array = []
	var waiting_action := ManualSignalAction.new(order, "WAIT_CHILD")
	var group := GFVisualActionGroup.new([waiting_action], false)
	_system.enqueue(group)

	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(_system.is_processing, "动作组应正在等待子动作 Signal。")

	_system.clear_queue(true)
	await get_tree().process_frame

	assert_true(waiting_action.cancelled, "取消动作组时应向子动作传播 cancel。")


func test_current_action_controls_delegate_to_running_action() -> void:
	var order: Array = []
	var waiting_action := ControllableSignalAction.new(order, "WAIT")
	_system.enqueue(waiting_action)

	await get_tree().process_frame
	assert_eq(_system.get_current_action(), waiting_action, "等待 Signal 时应可查询当前动作。")

	assert_true(_system.pause_current_action(), "存在当前动作时暂停应返回 true。")
	assert_true(waiting_action.paused, "pause_current_action 应委托给当前动作。")

	assert_true(_system.resume_current_action(), "存在当前动作时恢复应返回 true。")
	assert_true(waiting_action.resumed, "resume_current_action 应委托给当前动作。")

	_system.finish_current_action()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(waiting_action.finished, "finish_current_action 应委托给当前动作。")
	assert_false(_system.is_processing, "完成当前动作后队列应恢复空闲。")
	assert_null(_system.get_current_action(), "完成后不应保留当前动作。")


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


func test_parallel_group_completion_waits_for_launch_loop() -> void:
	var order: Array = []
	var group := GFVisualActionGroup.new([
		InvalidCompletedSignalAction.new(order, "WAIT_INVALID"),
		OrderAction.new(order, "SECOND"),
	], true)
	var completion := group.execute() as Signal
	completion.connect(func() -> void:
		order.append("DONE")
	)

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order, ["WAIT_INVALID", "SECOND", "DONE"], "并行动作组应在启动循环结束后再报告完成。")


func test_repeat_action_yields_during_unbounded_immediate_repeats() -> void:
	var order: Array = []
	var factory := func() -> Object:
		return OrderAction.new(order, "R")
	var repeat := GFRepeatAction.new(factory, 0)
	repeat.max_immediate_iterations_per_frame = 2
	repeat.execute()

	await get_tree().process_frame
	assert_eq(order.size(), 2, "无限瞬时重复应按单帧预算让出主循环。")

	await get_tree().process_frame
	assert_eq(order.size(), 4, "让出主循环后应继续下一批重复。")

	repeat.cancel()
	await get_tree().process_frame


func test_wait_action_cancel_suppresses_completion_signal() -> void:
	var wait_action := GFWaitAction.new(0.01)
	var completed: Array[bool] = []
	var completion := wait_action.execute() as Signal
	completion.connect(func() -> void:
		completed.append(true)
	)

	wait_action.cancel()
	await get_tree().create_timer(0.05).timeout

	assert_true(completed.is_empty(), "取消等待动作后，旧 SceneTreeTimer 不应再触发动作完成信号。")


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


func test_action_queue_skips_invalid_action_before_execute() -> void:
	var order: Array = []
	_system.enqueue(InvalidOrderAction.new(order, "SKIP"))
	_system.enqueue(OrderAction.new(order, "RUN"))

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order, ["RUN"], "执行前失效的动作应被跳过。")


func test_action_queue_injects_scoped_architecture_into_actions() -> void:
	var parent_arch := GFArchitecture.new()
	var child_arch := GFArchitecture.new(parent_arch)
	var action_queue := GFActionQueueSystem.new()
	await child_arch.register_system_instance(action_queue)
	await child_arch.init()

	var action := InjectedAction.new()
	action_queue.enqueue(action)

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(action.injected_architecture, child_arch, "ActionQueue 应把自身所属架构注入到动作。")

	child_arch.dispose()
	parent_arch.dispose()


func test_action_interceptor_can_skip_and_replace_actions() -> void:
	var order: Array = []
	_system.add_interceptor(RewriteInterceptor.new(order))

	_system.enqueue(OrderAction.new(order, "SKIP"))
	_system.enqueue(OrderAction.new(order, "OLD"))

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order, ["before:SKIP", "before:OLD", "NEW", "after:NEW"], "拦截器应能跳过和替换动作。")


func test_replaced_action_is_injected_before_following_interceptors() -> void:
	var arch := GFArchitecture.new()
	_system.inject_dependencies(arch)
	var replacement := InjectedAction.new()
	var observer := ObserveInjectedReplacementInterceptor.new()
	var replacer := ReplaceWithInjectedInterceptor.new(replacement)
	replacer.priority = 10
	observer.priority = 0
	_system.add_interceptor(replacer)
	_system.add_interceptor(observer)

	_system.enqueue(OrderAction.new([], "OLD"))
	await get_tree().process_frame
	await get_tree().process_frame

	assert_same(observer.observed_architecture, arch, "替换动作进入后续拦截器前应完成依赖注入。")
	assert_true(replacement.executed, "替换动作应被实际执行。")

	arch.dispose()


func test_action_interceptors_run_by_priority() -> void:
	var order: Array = []
	_system.add_interceptor(PriorityInterceptor.new(order, "low", 0))
	_system.add_interceptor(PriorityInterceptor.new(order, "high", 10))
	_system.enqueue(OrderAction.new(order, "RUN"))

	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order, ["high", "low", "RUN"], "拦截器应按高优先级优先执行。")


func test_action_interceptor_can_stop_remaining_queue() -> void:
	var order: Array = []
	var stop_action := ManualSignalAction.new(order, "STOP")
	_system.add_interceptor(StopAfterInterceptor.new())

	_system.enqueue(stop_action)
	await get_tree().process_frame
	_system.enqueue(OrderAction.new(order, "AFTER"))

	stop_action.complete()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_eq(order, ["STOP"], "after 拦截器停止队列后不应执行后续动作。")
	assert_false(_system.is_processing, "停止后队列应回到空闲状态。")


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


func test_signal_timeout_allows_queue_to_continue() -> void:
	var order: Array = []
	var emitter := ObjectSignalEmitter.new()
	var action := NonNodeDeadlockSignalAction.new(emitter).with_signal_timeout(0.001)
	_system.enqueue(action)
	_system.enqueue(OrderAction.new(order, "AFTER_TIMEOUT"))

	await get_tree().create_timer(0.05).timeout
	await get_tree().process_frame

	assert_push_warning("[GFActionQueueSystem] 等待动作 Signal 超时，队列将继续执行后续动作。")
	assert_eq(order, ["AFTER_TIMEOUT"], "Signal 超时后队列应继续执行后续动作。")
	assert_false(_system.is_processing, "Signal 超时后队列不应继续卡在处理中。")


func test_signal_timeout_respects_time_utility_pause() -> void:
	var arch := GFArchitecture.new()
	var time_utility := GFTimeUtility.new()
	var queue := GFActionQueueSystem.new()
	await arch.register_utility_instance(time_utility)
	await arch.register_system_instance(queue)
	await arch.init()

	var order: Array = []
	var emitter := ObjectSignalEmitter.new()
	var action := NonNodeDeadlockSignalAction.new(emitter).with_signal_timeout(0.001)
	time_utility.is_paused = true
	queue.enqueue(action)
	queue.enqueue(OrderAction.new(order, "AFTER_TIMEOUT"))

	await get_tree().create_timer(0.03).timeout
	await get_tree().process_frame

	assert_true(queue.is_processing, "GFTimeUtility 暂停时，Signal 超时计时不应继续推进。")
	assert_true(order.is_empty(), "暂停期间队列不应因超时执行后续动作。")

	time_utility.is_paused = false
	await get_tree().create_timer(0.03).timeout
	await get_tree().process_frame

	assert_push_warning("[GFActionQueueSystem] 等待动作 Signal 超时，队列将继续执行后续动作。")
	assert_eq(order, ["AFTER_TIMEOUT"], "恢复时间后，Signal 超时应继续推进并执行后续动作。")
	assert_false(queue.is_processing, "恢复时间并超时后队列应排空。")

	arch.dispose()


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


# --- 测试：命名队列 ---

func test_named_queues_run_independently() -> void:
	var order: Array = []

	_system.enqueue_to(&"battle", OrderAction.new(order, "BATTLE"))
	_system.enqueue_to(&"dialogue", OrderAction.new(order, "DIALOGUE"))

	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(order.has("BATTLE"), "命名队列 battle 应执行动作。")
	assert_true(order.has("DIALOGUE"), "命名队列 dialogue 应执行动作。")
	assert_false(_system.get_named_queue(&"battle").is_processing, "battle 队列应排空。")
	assert_false(_system.get_named_queue(&"dialogue").is_processing, "dialogue 队列应排空。")


func test_linked_queue_clears_when_node_is_released() -> void:
	var node := Node.new()
	add_child(node)
	var queue := _system.get_linked_queue(&"linked", node)
	var order: Array = []
	var waiting_action := ManualSignalAction.new(order, "WAIT")
	queue.enqueue(waiting_action)

	await get_tree().process_frame
	assert_true(queue.is_processing, "绑定队列应进入等待状态。")

	node.free()
	_system.tick(0.016)
	await get_tree().process_frame

	assert_true(waiting_action.cancelled, "绑定节点释放后队列应取消当前动作。")
	assert_false(queue.is_processing, "绑定节点释放后队列应停止处理。")


func test_dispose_releases_named_queue_dependency_scope() -> void:
	var arch := GFArchitecture.new()
	var parent_queue := GFActionQueueSystem.new()
	await arch.register_system_instance(parent_queue)
	await arch.init()
	var named_queue := parent_queue.get_named_queue(&"scene")
	var order: Array = []
	var waiting_action := ManualSignalAction.new(order, "WAIT")
	named_queue.enqueue(waiting_action)

	await get_tree().process_frame
	assert_true(named_queue.is_processing, "命名子队列应进入等待状态。")

	arch.dispose()
	assert_true(waiting_action.cancelled, "父队列销毁时应取消命名子队列当前动作。")
	assert_false(named_queue.is_processing, "父队列销毁后命名子队列不应继续处理。")

	var injected_action := InjectedAction.new()
	named_queue.enqueue(injected_action)

	assert_null(injected_action.injected_architecture, "已被父队列销毁的命名子队列不应继续持有旧架构。")
	assert_push_error("[GFSystem] 依赖作用域已释放，无法继续访问架构。")


func test_skip_current_action_continues_with_next_action() -> void:
	var order: Array = []
	var waiting_action := ManualSignalAction.new(order, "WAIT")
	_system.enqueue(waiting_action)
	_system.enqueue(OrderAction.new(order, "NEXT"))

	await get_tree().process_frame
	_system.skip_current_action()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(waiting_action.cancelled, "skip_current_action 应取消当前动作。")
	assert_eq(order, ["WAIT", "NEXT"], "skip_current_action 后应继续执行后续动作。")


func test_debug_snapshot_reports_queue_and_named_queue_state() -> void:
	_system.is_processing = true
	_system.enqueue(OrderAction.new([], "A"))
	var named_queue := _system.get_named_queue(&"named")
	named_queue.is_processing = true
	_system.enqueue_to(&"named", OrderAction.new([], "B"))

	var snapshot := _system.get_debug_snapshot()
	var named_queues := snapshot["named_queues"] as Dictionary
	var named_snapshot := named_queues[&"named"] as Dictionary

	assert_eq(int(snapshot["queued_count"]), 1, "快照应报告主队列待执行数量。")
	assert_eq(int(snapshot["named_queue_count"]), 1, "快照应报告命名队列数量。")
	assert_eq(int(named_snapshot["queued_count"]), 1, "命名队列快照应报告自身待执行数量。")


func test_tween_action_step_reports_invalid_property() -> void:
	var node := Node2D.new()
	add_child_autofree(node)
	var step := GFTweenActionStep.new()
	step.property_name = ^"missing_property"
	step.target_value = Vector2.ONE

	assert_false(step.can_apply_to(node), "不存在的属性不应通过配置校验。")
	assert_true(step.get_validation_error(node).contains("Property not found"), "校验错误应指出缺失属性。")
