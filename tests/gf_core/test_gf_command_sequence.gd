## 测试 GFCommandSequence 的顺序执行、上下文传递与 Signal 等待。
extends GutTest


# --- 辅助类 ---

class RecordingStep extends GFSequenceStep:
	var order: Array[String] = []
	var label: String = ""

	func _init(p_order: Array[String], p_label: String) -> void:
		order = p_order
		label = p_label

	func execute(context: GFSequenceContext) -> Variant:
		order.append(label)
		context.set_value(StringName(label), true)
		return null


class ManualSignalStep extends GFSequenceStep:
	signal completed

	var order: Array[String] = []
	var label: String = ""

	func _init(p_order: Array[String], p_label: String) -> void:
		order = p_order
		label = p_label

	func execute(_context: GFSequenceContext) -> Variant:
		order.append(label)
		return completed


# --- 测试方法 ---

## 验证同步步骤按顺序执行并共享上下文。
func test_sequence_runs_steps_in_order() -> void:
	var order: Array[String] = []
	var context := GFSequenceContext.new()
	var sequence := GFCommandSequence.new([
		RecordingStep.new(order, "first"),
		RecordingStep.new(order, "second"),
	], context)

	sequence.run()

	assert_eq(order, ["first", "second"], "同步步骤应按声明顺序执行。")
	assert_true(context.get_value(&"first", false), "步骤应能写入共享上下文。")
	assert_false(sequence.is_running, "同步执行完成后不应保持 running。")


## 验证返回 Signal 的步骤会阻塞后续步骤直到完成。
func test_sequence_waits_for_signal_step() -> void:
	var order: Array[String] = []
	var wait_step := ManualSignalStep.new(order, "wait")
	var sequence := GFCommandSequence.new([
		RecordingStep.new(order, "before"),
		wait_step,
		RecordingStep.new(order, "after"),
	])

	sequence.run()
	assert_eq(order, ["before", "wait"], "Signal 未完成前不应执行后续步骤。")
	assert_true(sequence.is_running, "等待 Signal 时序列应保持运行中。")

	var completed := [false]
	var on_completed := func() -> void:
		completed[0] = true
	sequence.sequence_completed.connect(on_completed, CONNECT_ONE_SHOT)
	wait_step.completed.emit()
	await get_tree().process_frame

	assert_eq(order, ["before", "wait", "after"], "Signal 完成后应继续执行后续步骤。")
	assert_true(completed[0], "序列应发出完成信号。")
	assert_false(sequence.is_running, "完成后应清除 running 状态。")


## 验证可取消正在等待的序列。
func test_sequence_cancel_stops_following_steps_after_wait() -> void:
	var order: Array[String] = []
	var wait_step := ManualSignalStep.new(order, "wait")
	var sequence := GFCommandSequence.new([
		RecordingStep.new(order, "before"),
		wait_step,
		RecordingStep.new(order, "after"),
	])

	sequence.run()
	sequence.cancel()
	var cancelled := [false]
	var on_cancelled := func() -> void:
		cancelled[0] = true
	sequence.sequence_cancelled.connect(on_cancelled, CONNECT_ONE_SHOT)
	wait_step.completed.emit()
	await get_tree().process_frame

	assert_eq(order, ["before", "wait"], "取消后不应执行后续步骤。")
	assert_true(cancelled[0], "序列应发出取消信号。")


## 验证取消等待中的序列不需要等外部 Signal 触发。
func test_sequence_cancel_breaks_wait_without_signal() -> void:
	var order: Array[String] = []
	var wait_step := ManualSignalStep.new(order, "wait")
	var sequence := GFCommandSequence.new([
		wait_step,
		RecordingStep.new(order, "after"),
	])

	sequence.run()
	await get_tree().process_frame
	sequence.cancel()
	await get_tree().process_frame

	assert_eq(order, ["wait"], "取消后不应等待外部 Signal 才停止。")
	assert_false(sequence.is_running, "取消检查后序列应停止运行。")


## 验证 Signal 超时后序列会继续后续步骤。
func test_sequence_signal_timeout_continues() -> void:
	var order: Array[String] = []
	var wait_step := ManualSignalStep.new(order, "wait")
	var sequence := GFCommandSequence.new([
		wait_step,
		RecordingStep.new(order, "after"),
	]).with_signal_timeout(0.001)

	sequence.run()
	await get_tree().create_timer(0.05).timeout
	await get_tree().process_frame

	assert_push_warning("[GFCommandSequence] 等待 Signal 超时，序列将继续执行后续步骤。")
	assert_eq(order, ["wait", "after"], "Signal 超时后应继续执行后续步骤。")
