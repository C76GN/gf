## GFJobWorker: 通用任务队列消费节点。
##
## 从 `GFJobQueueUtility` 中按批次取出等待任务，并交给项目提供的 Callable 处理。
## Worker 只管理执行节奏和完成/失败写回，不规定任务数据结构或业务语义。
class_name GFJobWorker
extends Node


# --- 信号 ---

## Worker 开始运行时发出。
signal worker_started

## Worker 停止运行时发出。
signal worker_stopped

## 任务处理完成时发出。
## @param job: 被处理的任务。
signal job_processed(job: GFJob)

## 没有可处理任务时发出。
signal worker_idle


# --- 导出变量 ---

## 消费的队列名。
@export var queue_name: StringName = &"default"

## 每次处理的最大任务数量。
@export_range(1, 1024, 1, "or_greater") var batch_size: int = 1

## ready 后是否自动开始。
@export var auto_start: bool = true

## 是否在 physics process 中消费任务。
@export var process_in_physics: bool = false

## SceneTree 暂停时是否继续处理。
@export var process_while_paused: bool = false


# --- 公共变量 ---

## 可选任务队列工具实例；为空时从全局架构查询。
var queue_utility: GFJobQueueUtility = null

## 任务处理器，签名推荐为 `func(job: GFJob) -> Variant`。
var processor: Callable = Callable()


# --- 私有变量 ---

var _running: bool = false
var _processing: bool = false


# --- Godot 生命周期方法 ---

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS if process_while_paused else Node.PROCESS_MODE_INHERIT
	if auto_start:
		start()


func _process(_delta: float) -> void:
	if not process_in_physics:
		process_batch()


func _physics_process(_delta: float) -> void:
	if process_in_physics:
		process_batch()


# --- 公共方法 ---

## 设置任务队列工具实例。
## @param utility: 任务队列工具实例。
func set_queue_utility(utility: GFJobQueueUtility) -> void:
	queue_utility = utility


## 设置任务处理器。
## @param job_processor: 任务处理器。
func set_processor(job_processor: Callable) -> void:
	processor = job_processor


## 开始消费任务。
func start() -> void:
	if _running:
		return
	_running = true
	worker_started.emit()


## 停止消费任务。
func stop() -> void:
	if not _running:
		return
	_running = false
	worker_stopped.emit()


## 检查 Worker 是否正在运行。
## @return 正在运行返回 true。
func is_running() -> bool:
	return _running


## 处理一个任务。
## @return 被处理的任务；没有任务或不可处理时返回 null。
func process_next_job() -> GFJob:
	var utility := _get_queue_utility()
	if utility == null or not processor.is_valid():
		return null
	var job := utility.start_next_job(queue_name)
	if job == null:
		return null

	var result: Variant = processor.call(job)
	if result is Signal:
		result = await (result as Signal)
		if job.is_finished():
			job_processed.emit(job)
			return job
		result = _normalize_signal_result(result)
	_apply_processor_result(utility, job, result)
	job_processed.emit(job)
	return job


## 按 batch_size 处理一批任务。
## @return 实际处理数量。
func process_batch() -> int:
	if not _running or _processing:
		return 0
	if is_inside_tree() and get_tree().paused and not process_while_paused:
		return 0

	_processing = true
	var processed_count := 0
	for _index: int in range(maxi(batch_size, 1)):
		var job := await process_next_job()
		if job == null:
			break
		processed_count += 1
	_processing = false
	if processed_count == 0:
		worker_idle.emit()
	return processed_count


## 获取 Worker 调试快照。
## @return 调试快照。
func get_debug_snapshot() -> Dictionary:
	return {
		"running": _running,
		"processing": _processing,
		"queue_name": String(queue_name),
		"batch_size": batch_size,
		"has_processor": processor.is_valid(),
		"has_queue_utility": _get_queue_utility() != null,
	}


# --- 私有/辅助方法 ---

func _get_queue_utility() -> GFJobQueueUtility:
	if queue_utility != null:
		return queue_utility
	var architecture := GFAutoload.get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(GFJobQueueUtility) as GFJobQueueUtility


func _apply_processor_result(utility: GFJobQueueUtility, job: GFJob, result: Variant) -> void:
	if job == null or job.is_finished():
		return
	if result is Dictionary and not bool((result as Dictionary).get("ok", true)):
		utility.fail_job(job.job_id, String((result as Dictionary).get("error", "")), result)
	elif result is bool and not bool(result):
		utility.fail_job(job.job_id, "", result)
	else:
		utility.complete_job(job.job_id, result)


func _normalize_signal_result(result: Variant) -> Variant:
	if not (result is Array):
		return result

	var values := result as Array
	if values.is_empty():
		return null
	if values.size() == 1:
		return values[0]

	var first_value: Variant = values[0]
	if first_value is Dictionary:
		var data := GFVariantData.duplicate_variant(first_value) as Dictionary
		data["signal_args"] = GFVariantData.duplicate_variant(values)
		return data
	return values
