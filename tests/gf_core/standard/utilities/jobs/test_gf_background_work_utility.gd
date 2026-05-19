## 测试 GFBackgroundWorkUtility 的纯数据后台工作协调行为。
extends GutTest


# --- 常量 ---

const GFBackgroundWorkTaskScript = preload("res://addons/gf/standard/utilities/jobs/gf_background_work_task.gd")
const GFBackgroundWorkUtilityScript = preload("res://addons/gf/standard/utilities/jobs/gf_background_work_utility.gd")


# --- 内部类 ---

class PureWorker:
	extends RefCounted

	func double_value(data: Variant) -> Dictionary:
		var input := data as Dictionary
		return {
			"value": int(input.get("value", 0)) * 2,
		}

	func fail_work(_data: Variant) -> Dictionary:
		return {
			"ok": false,
			"error": "worker_failed",
		}


# --- 私有变量 ---

var _applied_value: int = 0
var _applied_resource: Resource = null
var _slow_apply_count: int = 0


# --- 测试生命周期方法 ---

func before_each() -> void:
	_applied_value = 0
	_applied_resource = null
	_slow_apply_count = 0


# --- 测试用例 ---

func test_cpu_work_runs_on_thread_and_applies_on_tick() -> void:
	var utility: Variant = GFBackgroundWorkUtilityScript.new()
	utility.init()
	watch_signals(utility)

	var worker := PureWorker.new()
	var task: Variant = utility.submit_cpu_work(
		Callable(worker, "double_value"),
		{"value": 21},
		Callable(self, "_apply_value")
	)

	await _pump_until_finished(utility, task)

	assert_eq(task.status, GFBackgroundWorkTaskScript.Status.COMPLETED, "CPU 工作应完成。")
	assert_eq(_applied_value, 42, "主线程应用回调应读取后台结果。")
	assert_signal_emitted(utility, "work_started", "线程工作启动时应发出信号。")
	assert_signal_emitted(utility, "work_applied", "主线程应用完成时应发出信号。")
	utility.dispose()


func test_failed_worker_marks_task_failed() -> void:
	var utility: Variant = GFBackgroundWorkUtilityScript.new()
	utility.init()
	var worker := PureWorker.new()

	var task: Variant = utility.submit_io_work(Callable(worker, "fail_work"))

	await _pump_until_finished(utility, task)

	assert_eq(task.status, GFBackgroundWorkTaskScript.Status.FAILED, "ok=false 的后台结果应转为 failed。")
	assert_eq(task.error_message, "worker_failed", "失败原因应写入任务。")
	utility.dispose()


func test_object_payload_is_rejected_by_default() -> void:
	var utility: Variant = GFBackgroundWorkUtilityScript.new()
	utility.init()
	var worker := PureWorker.new()
	var node := Node.new()

	var task: Variant = utility.submit_cpu_work(Callable(worker, "double_value"), {"node": node})

	assert_eq(task.status, GFBackgroundWorkTaskScript.Status.FAILED, "默认不应允许 Object 进入线程 payload。")
	assert_string_contains(task.error_message, "payload", "失败原因应说明 payload 不安全。")
	node.free()
	utility.dispose()


func test_pause_and_cancel_waiting_thread_task() -> void:
	var utility: Variant = GFBackgroundWorkUtilityScript.new()
	utility.init()
	utility.pause()
	var worker := PureWorker.new()

	var first: Variant = utility.submit_cpu_work(
		Callable(worker, "double_value"),
		{"value": 1},
		Callable(),
		{"id": "first"}
	)
	var high_priority: Variant = utility.submit_cpu_work(
		Callable(worker, "double_value"),
		{"value": 2},
		Callable(),
		{"id": "high", "priority": 10}
	)
	var front: Variant = utility.submit_cpu_work(
		Callable(worker, "double_value"),
		{"value": 3},
		Callable(),
		{"id": "front", "front": true}
	)
	var queued_ids := utility.get_debug_snapshot()["queued_ids"] as PackedStringArray

	assert_eq(first.status, GFBackgroundWorkTaskScript.Status.QUEUED, "暂停时 CPU 工作应留在等待队列。")
	assert_eq(queued_ids, PackedStringArray(["high", "front", "first"]), "等待队列应按 priority 和 front 排序。")
	assert_same(high_priority, utility.get_task(&"high"), "自定义 ID 应可取回对应任务。")
	assert_true(utility.cancel_work(front.work_id), "等待任务应可取消。")
	assert_eq(front.status, GFBackgroundWorkTaskScript.Status.CANCELLED, "取消后应进入 cancelled。")
	assert_eq(utility.get_debug_snapshot()["queued_count"], 2, "取消等待任务后队列应移除该任务。")
	utility.cancel_all()
	utility.dispose()


func test_resource_load_uses_threaded_resource_loader_and_applies_on_tick() -> void:
	var utility: Variant = GFBackgroundWorkUtilityScript.new()
	utility.init()

	var task: Variant = utility.submit_resource_load(
		"res://addons/gf/standard/utilities/jobs/gf_job.gd",
		"Script",
		Callable(self, "_apply_resource")
	)

	await _pump_until_finished(utility, task, 180)

	assert_eq(task.status, GFBackgroundWorkTaskScript.Status.COMPLETED, "资源线程加载应完成。")
	assert_not_null(task.result, "资源加载结果不应为空。")
	assert_true(task.result is Script, "测试资源应作为 Script 加载。")
	assert_same(_applied_resource, task.result, "主线程应用应收到同一资源。")
	utility.dispose()


func test_apply_queue_respects_time_budget_after_first_callback() -> void:
	var utility: Variant = GFBackgroundWorkUtilityScript.new()
	utility.init()
	utility.max_apply_per_tick = 8
	utility.max_apply_seconds_per_tick = 0.000001

	var first: Variant = _make_apply_task(&"first")
	var second: Variant = _make_apply_task(&"second")
	utility._tasks[first.work_id] = first
	utility._tasks[second.work_id] = second
	utility._apply_queue.append(first)
	utility._apply_queue.append(second)

	utility.tick()

	assert_eq(_slow_apply_count, 1, "时间预算启用时同一帧至少执行一个 apply。")
	assert_eq(first.status, GFBackgroundWorkTaskScript.Status.COMPLETED, "第一个 apply 应完成。")
	assert_eq(second.status, GFBackgroundWorkTaskScript.Status.APPLYING, "超出时间预算后应保留后续 apply。")
	assert_eq(utility.get_debug_snapshot()["apply_count"], 1, "后续 apply 应留在队列中。")

	utility.max_apply_seconds_per_tick = 0.0
	utility.tick()

	assert_eq(_slow_apply_count, 2, "关闭时间预算后应继续处理剩余 apply。")
	assert_eq(second.status, GFBackgroundWorkTaskScript.Status.COMPLETED, "第二个 apply 应完成。")
	utility.dispose()


# --- 私有/辅助方法 ---

func _apply_value(task: Variant) -> bool:
	var result := task.result as Dictionary
	_applied_value = int(result.get("value", 0))
	return true


func _apply_slow_task(_task: Variant) -> bool:
	var started_usec := Time.get_ticks_usec()
	while Time.get_ticks_usec() - started_usec < 2000:
		pass
	_slow_apply_count += 1
	return true


func _apply_resource(task: Variant) -> bool:
	_applied_resource = task.result as Resource
	return _applied_resource != null


func _make_apply_task(work_id: StringName) -> Variant:
	var task: Variant = GFBackgroundWorkTaskScript.new()
	task.work_id = work_id
	task.kind = GFBackgroundWorkTaskScript.Kind.CPU
	task.status = GFBackgroundWorkTaskScript.Status.APPLYING
	task._apply_callback = Callable(self, "_apply_slow_task")
	return task


func _pump_until_finished(
	utility: Variant,
	task: Variant,
	max_frames: int = 120
) -> void:
	for _frame in range(max_frames):
		utility.tick()
		if task.is_finished():
			return
		await get_tree().process_frame
	utility.tick()
