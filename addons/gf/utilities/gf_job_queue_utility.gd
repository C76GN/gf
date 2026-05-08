## GFJobQueueUtility: 通用任务队列工具。
##
## 提供等待、激活、完成、失败、取消、进度和调试快照能力。
## 队列不绑定执行线程或业务语义，具体执行由调用方决定。
class_name GFJobQueueUtility
extends GFUtility


# --- 信号 ---

## 任务进入等待队列时发出。
## @param job: 任务记录。
signal job_enqueued(job: GFJob)

## 任务开始执行时发出。
## @param job: 任务记录。
signal job_started(job: GFJob)

## 任务进度变化时发出。
## @param job: 任务记录。
## @param progress: 当前进度。
## @param message: 进度说明。
signal job_progressed(job: GFJob, progress: float, message: String)

## 任务完成时发出。
## @param job: 任务记录。
signal job_completed(job: GFJob)

## 任务失败时发出。
## @param job: 任务记录。
signal job_failed(job: GFJob)

## 任务取消时发出。
## @param job: 任务记录。
signal job_cancelled(job: GFJob)


# --- 公共变量 ---

## 保留的完成任务数量。
var max_completed_jobs: int = 64

## 保留的失败任务数量。
var max_failed_jobs: int = 64


# --- 私有变量 ---

var _job_serial: int = 0
var _queues: Dictionary = {}
var _jobs: Dictionary = {}
var _completed_jobs: Array[GFJob] = []
var _failed_jobs: Array[GFJob] = []
var _paused_queues: Dictionary = {}


# --- Godot 生命周期方法 ---

func init() -> void:
	clear_all()


func dispose() -> void:
	clear_all()


# --- 公共方法 ---

## 追加一个等待任务。
## @param queue_name: 队列名。
## @param data: 任务输入数据。
## @param metadata: 项目自定义元数据。
## @param front: 是否插入到队列头部。
## @return 新任务记录。
func enqueue(
	queue_name: StringName = &"default",
	data: Variant = null,
	metadata: Dictionary = {},
	front: bool = false
) -> GFJob:
	var effective_queue := queue_name if queue_name != &"" else &"default"
	_job_serial += 1
	var job := GFJob.new()
	job.job_id = StringName("%s:%d" % [String(effective_queue), _job_serial])
	job.queue_name = effective_queue
	job.data = data
	job.metadata = metadata.duplicate(true)
	job.created_msec = Time.get_ticks_msec()

	var queue := _ensure_queue(effective_queue)
	if front:
		queue.push_front(job)
	else:
		queue.append(job)
	_jobs[job.job_id] = job
	job_enqueued.emit(job)
	return job


## 从队列取出下一个等待任务并标记为执行中。
## @param queue_name: 队列名。
## @return 任务记录；没有可执行任务时返回 null。
func start_next_job(queue_name: StringName = &"default") -> GFJob:
	var effective_queue := queue_name if queue_name != &"" else &"default"
	if is_queue_paused(effective_queue):
		return null

	var queue := _ensure_queue(effective_queue)
	while not queue.is_empty():
		var job := queue.pop_front() as GFJob
		if job == null or job.status != GFJob.Status.WAITING:
			continue
		job.status = GFJob.Status.ACTIVE
		job.started_msec = Time.get_ticks_msec()
		job_started.emit(job)
		return job
	return null


## 使用回调立即处理下一个等待任务。回调返回 false 或 ok=false 字典时标记失败。
## @param queue_name: 队列名。
## @param processor: 任务处理回调。
## @return 被处理的任务；没有可执行任务时返回 null。
func run_next_job(queue_name: StringName, processor: Callable) -> GFJob:
	if not processor.is_valid():
		return null
	var job := start_next_job(queue_name)
	if job == null:
		return null

	var value: Variant = processor.call(job)
	if value is Dictionary and not bool((value as Dictionary).get("ok", true)):
		fail_job(job.job_id, String((value as Dictionary).get("error", "")), value)
	elif value == false:
		fail_job(job.job_id, "", value)
	else:
		complete_job(job.job_id, value)
	return job


## 更新任务进度。
## @param job_id: 任务 ID。
## @param progress: 当前进度。
## @param message: 进度说明。
## @return 更新成功返回 true。
func update_job_progress(job_id: StringName, progress: float, message: String = "") -> bool:
	var job := get_job(job_id)
	if job == null or job.is_finished():
		return false
	job.progress = clampf(progress, 0.0, 1.0)
	job_progressed.emit(job, job.progress, message)
	return true


## 标记任务完成。
## @param job_id: 任务 ID。
## @param result: 任务结果。
## @return 完成成功返回 true。
func complete_job(job_id: StringName, result: Variant = null) -> bool:
	var job := get_job(job_id)
	if job == null or job.is_finished():
		return false
	job.status = GFJob.Status.COMPLETED
	job.progress = 1.0
	job.result = result
	job.finished_msec = Time.get_ticks_msec()
	_completed_jobs.append(job)
	_trim_finished_jobs(_completed_jobs, maxi(max_completed_jobs, 0))
	job_completed.emit(job)
	return true


## 标记任务失败。
## @param job_id: 任务 ID。
## @param error_message: 错误文本。
## @param result: 可选失败结果。
## @return 标记成功返回 true。
func fail_job(job_id: StringName, error_message: String = "", result: Variant = null) -> bool:
	var job := get_job(job_id)
	if job == null or job.is_finished():
		return false
	job.status = GFJob.Status.FAILED
	job.error_message = error_message
	job.result = result
	job.finished_msec = Time.get_ticks_msec()
	_failed_jobs.append(job)
	_trim_finished_jobs(_failed_jobs, maxi(max_failed_jobs, 0))
	job_failed.emit(job)
	return true


## 取消任务。
## @param job_id: 任务 ID。
## @return 取消成功返回 true。
func cancel_job(job_id: StringName) -> bool:
	var job := get_job(job_id)
	if job == null or job.is_finished():
		return false
	_remove_waiting_job_from_queue(job)
	job.status = GFJob.Status.CANCELLED
	job.finished_msec = Time.get_ticks_msec()
	job_cancelled.emit(job)
	return true


## 暂停指定队列。
## @param queue_name: 队列名。
func pause_queue(queue_name: StringName = &"default") -> void:
	_paused_queues[queue_name if queue_name != &"" else &"default"] = true


## 恢复指定队列。
## @param queue_name: 队列名。
func resume_queue(queue_name: StringName = &"default") -> void:
	_paused_queues.erase(queue_name if queue_name != &"" else &"default")


## 检查队列是否暂停。
## @param queue_name: 队列名。
## @return 暂停时返回 true。
func is_queue_paused(queue_name: StringName = &"default") -> bool:
	return bool(_paused_queues.get(queue_name if queue_name != &"" else &"default", false))


## 获取任务。
## @param job_id: 任务 ID。
## @return 任务记录；不存在时返回 null。
func get_job(job_id: StringName) -> GFJob:
	return _jobs.get(job_id) as GFJob


## 获取队列中的等待任务。
## @param queue_name: 队列名。
## @return 等待任务列表副本。
func get_waiting_jobs(queue_name: StringName = &"default") -> Array[GFJob]:
	var queue := _ensure_queue(queue_name if queue_name != &"" else &"default")
	return queue.duplicate()


## 清空指定队列中的等待任务。
## @param queue_name: 队列名。
## @param cancel_jobs: 是否把等待任务标记为取消。
func clear_queue(queue_name: StringName = &"default", cancel_jobs: bool = true) -> void:
	var effective_queue := queue_name if queue_name != &"" else &"default"
	var queue := _ensure_queue(effective_queue)
	if cancel_jobs:
		var jobs_to_cancel: Array[GFJob] = queue.duplicate()
		for job: GFJob in jobs_to_cancel:
			cancel_job(job.job_id)
	else:
		for job: GFJob in queue:
			_jobs.erase(job.job_id)
	queue.clear()


## 清空全部队列与历史任务。
func clear_all() -> void:
	_job_serial = 0
	_queues.clear()
	_jobs.clear()
	_completed_jobs.clear()
	_failed_jobs.clear()
	_paused_queues.clear()


## 获取调试快照。
## @return 调试快照字典。
func get_debug_snapshot() -> Dictionary:
	var queue_info: Dictionary = {}
	for queue_name: StringName in _queues.keys():
		var queue := _queues[queue_name] as Array[GFJob]
		var waiting_jobs: Array[GFJob] = queue if queue != null else []
		queue_info[String(queue_name)] = {
			"waiting_count": waiting_jobs.size(),
			"is_paused": is_queue_paused(queue_name),
			"waiting_job_ids": _job_ids(waiting_jobs),
		}
	return {
		"job_count": _jobs.size(),
		"queue_count": _queues.size(),
		"completed_count": _completed_jobs.size(),
		"failed_count": _failed_jobs.size(),
		"queues": queue_info,
	}


# --- 私有/辅助方法 ---

func _ensure_queue(queue_name: StringName) -> Array[GFJob]:
	if not _queues.has(queue_name):
		_queues[queue_name] = [] as Array[GFJob]
	return _queues[queue_name] as Array[GFJob]


func _remove_waiting_job_from_queue(job: GFJob) -> void:
	var queue := _queues.get(job.queue_name) as Array[GFJob]
	if queue != null:
		queue.erase(job)


func _trim_finished_jobs(jobs: Array[GFJob], limit: int) -> void:
	while jobs.size() > limit:
		var removed := jobs.pop_front() as GFJob
		if removed != null:
			_jobs.erase(removed.job_id)


func _job_ids(jobs: Array[GFJob]) -> PackedStringArray:
	var result := PackedStringArray()
	for job: GFJob in jobs:
		if job != null:
			result.append(String(job.job_id))
	return result
