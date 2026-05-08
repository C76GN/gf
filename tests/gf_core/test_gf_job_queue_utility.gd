## 测试 GFJobQueueUtility 的通用任务队列行为。
extends GutTest


func test_job_queue_lifecycle_progress_and_snapshot() -> void:
	var utility := GFJobQueueUtility.new()
	utility.init()
	watch_signals(utility)

	var job := utility.enqueue(&"import", {"path": "res://data.json"}, {"kind": "json"})
	assert_eq(job.status, GFJob.Status.WAITING, "新任务应进入 waiting 状态。")
	assert_signal_emitted(utility, "job_enqueued", "入队时应发出信号。")

	var started := utility.start_next_job(&"import")
	assert_same(started, job, "start_next_job 应取出队列头任务。")
	assert_eq(job.status, GFJob.Status.ACTIVE, "启动后任务应进入 active 状态。")
	assert_signal_emitted(utility, "job_started", "启动时应发出信号。")

	assert_true(utility.update_job_progress(job.job_id, 0.5, "half"), "执行中任务应允许更新进度。")
	assert_almost_eq(job.progress, 0.5, 0.001, "进度应写入任务。")
	assert_signal_emitted(utility, "job_progressed", "更新进度时应发出信号。")

	assert_true(utility.complete_job(job.job_id, {"ok": true}), "执行中任务应允许完成。")
	assert_eq(job.status, GFJob.Status.COMPLETED, "完成后任务应进入 completed 状态。")
	assert_true(job.is_finished(), "完成任务应进入终态。")
	assert_signal_emitted(utility, "job_completed", "完成时应发出信号。")

	var snapshot := utility.get_debug_snapshot()
	assert_eq(snapshot["completed_count"], 1, "调试快照应统计完成任务。")
	assert_eq((job.to_dict()["metadata"] as Dictionary)["kind"], "json", "任务字典应保留 metadata。")
	utility.dispose()


func test_job_queue_pause_cancel_and_run_failure() -> void:
	var utility := GFJobQueueUtility.new()
	utility.init()

	var waiting := utility.enqueue(&"main", null)
	utility.pause_queue(&"main")
	assert_null(utility.start_next_job(&"main"), "暂停队列不应启动任务。")
	utility.resume_queue(&"main")
	assert_true(utility.cancel_job(waiting.job_id), "等待任务应可取消。")
	assert_eq(waiting.status, GFJob.Status.CANCELLED, "取消后任务应进入 cancelled 状态。")

	var failed := utility.enqueue(&"main", null)
	var processed := utility.run_next_job(&"main", func(_job: GFJob) -> Dictionary:
		return {"ok": false, "error": "failed"}
	)

	assert_same(processed, failed, "run_next_job 应处理下一个任务。")
	assert_eq(failed.status, GFJob.Status.FAILED, "处理器返回 ok=false 时应标记失败。")
	assert_eq(failed.error_message, "failed", "失败错误文本应写入任务。")
	assert_eq(utility.get_debug_snapshot()["failed_count"], 1, "调试快照应统计失败任务。")
	utility.dispose()
