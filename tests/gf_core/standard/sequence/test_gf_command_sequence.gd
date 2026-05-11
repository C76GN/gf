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


class UndoableRecordingStep extends RecordingStep:
	func undo() -> void:
		order.append("undo_" + label)


class FailingStep extends GFSequenceStep:
	var order: Array[String] = []
	var label: String = ""
	var result: Dictionary = {}

	func _init(p_order: Array[String], p_label: String, p_error: String = "failed") -> void:
		order = p_order
		label = p_label
		result = {
			"ok": false,
			"error": p_error,
		}

	func execute(_context: GFSequenceContext) -> Variant:
		order.append(label)
		return result


class SuccessFlagFailingStep extends FailingStep:
	func _init(p_order: Array[String], p_label: String) -> void:
		super._init(p_order, p_label)
		result = {
			"success": false,
		}


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


func test_sequence_stop_on_error_reports_failure() -> void:
	var order: Array[String] = []
	var sequence := GFCommandSequence.new([
		RecordingStep.new(order, "before"),
		FailingStep.new(order, "fail", "broken"),
		RecordingStep.new(order, "after"),
	]).with_failure_policy(true, false)
	watch_signals(sequence)

	sequence.run()

	assert_eq(order, ["before", "fail"], "stop_on_error 时失败后不应继续执行后续步骤。")
	assert_true(bool(sequence.last_run_report["failed"]), "运行报告应标记失败。")
	assert_eq(sequence.last_run_report["failed_index"], 1, "运行报告应记录失败步骤索引。")
	assert_eq(sequence.last_run_report["error"], "broken", "运行报告应记录失败原因。")
	assert_eq(sequence.last_run_report["succeeded"], 1, "运行报告应只统计失败前已成功步骤。")
	assert_signal_emitted(sequence, "step_failed", "失败步骤应发出 step_failed。")
	assert_signal_emitted(sequence, "sequence_failed", "stop_on_error 时序列应发出 sequence_failed。")


func test_sequence_rollback_on_failure_undoes_completed_steps_reverse_order() -> void:
	var order: Array[String] = []
	var sequence := GFCommandSequence.new([
		UndoableRecordingStep.new(order, "first"),
		UndoableRecordingStep.new(order, "second"),
		FailingStep.new(order, "fail"),
		RecordingStep.new(order, "after"),
	]).with_failure_policy(true, true)

	sequence.run()

	assert_eq(order, ["first", "second", "fail", "undo_second", "undo_first"], "失败回滚应逆序 undo 已完成步骤。")
	assert_true(bool(sequence.last_run_report["rolled_back"]), "运行报告应标记已回滚。")


func test_sequence_success_false_uses_default_error() -> void:
	var order: Array[String] = []
	var sequence := GFCommandSequence.new([
		SuccessFlagFailingStep.new(order, "fail"),
	]).with_failure_policy(true, false)

	sequence.run()

	assert_true(bool(sequence.last_run_report["failed"]), "success=false 应被识别为失败。")
	assert_eq(sequence.last_run_report["error"], "Step failed.", "缺少错误字段时应提供稳定默认错误。")
