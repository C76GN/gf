## GFJobWorker: 通用任务队列消费节点。
##
## 从 `GFJobQueueUtility` 中按批次取出等待任务，并交给项目提供的 Callable 处理。
## Worker 只管理执行节奏和完成/失败写回，不规定任务数据结构或业务语义。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFJobWorker
extends Node


# --- 信号 ---

## Worker 开始运行时发出。
## [br]
## @api public
signal worker_started

## Worker 停止运行时发出。
## [br]
## @api public
signal worker_stopped

## 任务处理完成时发出。
## [br]
## @api public
## [br]
## @param job: 被处理的任务。
signal job_processed(job: GFJob)

## 没有可处理任务时发出。
## [br]
## @api public
signal worker_idle


# --- 常量 ---

const _GF_ASYNC_WAIT_SUPPORT: Script = preload("res://addons/gf/standard/common/gf_async_wait_support.gd")


# --- 导出变量 ---

## 消费的队列名。
## [br]
## @api public
@export var queue_name: StringName = &"default"

## 每次处理的最大任务数量。
## [br]
## @api public
@export_range(1, 1024, 1, "or_greater") var batch_size: int = 1

## ready 后是否自动开始。
## [br]
## @api public
@export var auto_start: bool = true

## 是否在 physics process 中消费任务。
## [br]
## @api public
@export var process_in_physics: bool = false

## SceneTree 暂停时是否继续处理。
## [br]
## @api public
@export var process_while_paused: bool = false

## 等待异步任务处理器 Signal 的最长秒数。小于等于 0 时不启用超时。
## [br]
## @api public
@export var signal_timeout_seconds: float = 30.0

## Signal 超时计时是否跟随 GFTimeUtility 的暂停与 time_scale。
## [br]
## @api public
@export var signal_timeout_respects_time_scale: bool = true


# --- 公共变量 ---

## 可选任务队列工具实例；为空时从全局架构查询。
## [br]
## @api public
var queue_utility: GFJobQueueUtility = null

## 任务处理器，签名推荐为 `func(job: GFJob) -> Variant`。
## [br]
## @api public
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
## [br]
## @api public
## [br]
## @param utility: 任务队列工具实例。
func set_queue_utility(utility: GFJobQueueUtility) -> void:
	queue_utility = utility


## 设置任务处理器。
## [br]
## @api public
## [br]
## @param job_processor: 任务处理器。
func set_processor(job_processor: Callable) -> void:
	processor = job_processor


## 开始消费任务。
## [br]
## @api public
func start() -> void:
	if _running:
		return
	_running = true
	worker_started.emit()


## 停止消费任务。
## [br]
## @api public
func stop() -> void:
	if not _running:
		return
	_running = false
	worker_stopped.emit()


## 检查 Worker 是否正在运行。
## [br]
## @api public
## [br]
## @return 正在运行返回 true。
func is_running() -> bool:
	return _running


## 处理一个任务。
## [br]
## @api public
## [br]
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
		var wait_result := await _await_processor_signal_result(result as Signal)
		if not bool(wait_result.get("completed", false)):
			if not job.is_finished():
				utility.fail_job(job.job_id, "processor_signal_cancelled_or_timeout", wait_result)
			job_processed.emit(job)
			return job
		if job.is_finished():
			job_processed.emit(job)
			return job
		result = wait_result.get("result")
	_apply_processor_result(utility, job, result)
	job_processed.emit(job)
	return job


## 按 batch_size 处理一批任务。
## [br]
## @api public
## [br]
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
## [br]
## @api public
## [br]
## @return 调试快照。
## [br]
## @schema return: Dictionary，包含 running、processing、queue_name、batch_size、has_processor 和 has_queue_utility。
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


func _await_processor_signal_result(result_signal: Signal) -> Dictionary:
	var guard_node := self if is_inside_tree() else null
	var wait_result: Dictionary = await _GF_ASYNC_WAIT_SUPPORT.await_signal_payload_safely(
		result_signal,
		_should_continue_waiting,
		_get_time_utility(),
		signal_timeout_seconds,
		signal_timeout_respects_time_scale,
		"[GFJobWorker] 等待任务处理器 Signal 超时，任务将标记为失败。",
		guard_node
	)
	var completed := bool(wait_result.get("completed", false))
	return {
		"completed": completed,
		"result": _normalize_signal_result(wait_result.get("args", [])) if completed else null,
		"reason": "completed" if completed else "cancelled_or_timeout",
	}


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


func _get_time_utility() -> GFTimeUtility:
	var architecture := GFAutoload.get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(GFTimeUtility) as GFTimeUtility


func _should_continue_waiting() -> bool:
	return _running or _processing or not is_inside_tree()
