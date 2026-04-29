## 测试通用回合流程系统的阶段推进与行动排序。
extends GutTest


# --- 辅助类 ---

class RecordingPhase extends GFTurnPhase:
	var order: Array[String] = []

	func _init(p_phase_id: StringName, p_order: Array[String]) -> void:
		phase_id = p_phase_id
		order = p_order

	func enter(_context: GFTurnContext) -> void:
		order.append("enter:%s" % phase_id)

	func execute(_context: GFTurnContext) -> Variant:
		order.append("execute:%s" % phase_id)
		return null

	func exit(_context: GFTurnContext) -> void:
		order.append("exit:%s" % phase_id)


class RecordingAction extends GFTurnAction:
	var order: Array[String] = []

	func _init(p_label: String, p_priority: int, p_sort_value: float, p_order: Array[String]) -> void:
		action_id = StringName(p_label)
		priority = p_priority
		sort_value = p_sort_value
		order = p_order

	func resolve(_context: GFTurnContext) -> Variant:
		order.append(String(action_id))
		return null


class ValueActor extends Object:
	var speed: float = 7.0


# --- 测试方法 ---

## 验证阶段推进会调用 enter/execute/exit 生命周期。
func test_advance_phase_runs_phase_lifecycle() -> void:
	var order: Array[String] = []
	var system := GFTurnFlowSystem.new()
	system.set_phases([
		RecordingPhase.new(&"prepare", order),
	])

	system.start()
	system.advance_phase()

	assert_eq(order, [
		"enter:prepare",
		"execute:prepare",
		"exit:prepare",
	], "阶段推进应按生命周期顺序调用。")
	assert_eq(system.context.round_index, 1, "首次进入第 0 阶段应推进轮次。")


## 验证行动默认按 priority 与 sort_value 降序解析。
func test_resolve_actions_sorts_by_priority_and_sort_value() -> void:
	var order: Array[String] = []
	var system := GFTurnFlowSystem.new()

	system.enqueue_action(RecordingAction.new("low", 0, 100.0, order))
	system.enqueue_action(RecordingAction.new("fast", 1, 20.0, order))
	system.enqueue_action(RecordingAction.new("slow", 1, 10.0, order))
	system.resolve_actions()

	assert_eq(order, ["fast", "slow", "low"], "行动应优先按 priority 再按 sort_value 降序解析。")
	assert_true(system.context.actions.is_empty(), "解析后待处理行动应被清空。")
	assert_null(system.context.current_actor, "解析完成后 current_actor 应复位。")


## 验证上下文可安全读取参与者排序值。
func test_turn_context_reads_actor_value() -> void:
	var actor := ValueActor.new()

	var context := GFTurnContext.new()
	context.add_actor(actor)

	assert_eq(context.get_actor_value(actor, &"speed"), 7.0, "应能从对象属性读取值。")
	assert_eq(context.get_actor_value(null, &"speed", 0.0), 0.0, "空对象应返回 fallback。")

	actor.free()
