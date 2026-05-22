## GFBackgroundWorkUtility: 纯数据后台工作协调器。
##
## 统一协调 CPU/IO 线程工作、ResourceLoader 线程加载和主线程应用回调。
## 默认只允许纯 Variant 输入数据，避免后台线程直接触碰 Node、Resource 或 Callable。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFBackgroundWorkUtility
extends GFUtility


# --- 信号 ---

## 工作进入等待队列时发出。
## [br]
## @api public
## [br]
## @param task: 工作记录。
signal work_queued(task: GFBackgroundWorkTask)

## 工作开始执行时发出。
## [br]
## @api public
## [br]
## @param task: 工作记录。
signal work_started(task: GFBackgroundWorkTask)

## 工作进度变化时发出。
## [br]
## @api public
## [br]
## @param task: 工作记录。
## [br]
## @param progress: 当前进度。
## [br]
## @param message: 进度说明。
signal work_progressed(task: GFBackgroundWorkTask, progress: float, message: String)

## 工作完成时发出。
## [br]
## @api public
## [br]
## @param task: 工作记录。
signal work_completed(task: GFBackgroundWorkTask)

## 工作失败时发出。
## [br]
## @api public
## [br]
## @param task: 工作记录。
signal work_failed(task: GFBackgroundWorkTask)

## 工作取消时发出。
## [br]
## @api public
## [br]
## @param task: 工作记录。
signal work_cancelled(task: GFBackgroundWorkTask)

## 工作结果已在主线程应用时发出。
## [br]
## @api public
## [br]
## @param task: 工作记录。
signal work_applied(task: GFBackgroundWorkTask)


# --- 常量 ---

const _MAX_PAYLOAD_DEPTH: int = 64


# --- 公共变量 ---

## 同时运行的 CPU/IO 线程任务上限。
## [br]
## @api public
var max_threaded_tasks: int = 2:
	set(value):
		max_threaded_tasks = maxi(value, 1)
		_start_queued_thread_tasks()

## 单帧最多执行多少个主线程应用回调。
## [br]
## @api public
var max_apply_per_tick: int = 8:
	set(value):
		max_apply_per_tick = maxi(value, 1)

## 单帧主线程应用回调的最大秒数。小于等于 0 时不启用时间预算；启用时每帧仍至少尝试一个应用回调。
## [br]
## @api public
var max_apply_seconds_per_tick: float = 0.0:
	set(value):
		max_apply_seconds_per_tick = maxf(value, 0.0)

## 最多保留多少个终态任务用于调试快照；设为 0 时不保留历史。
## [br]
## @api public
var max_finished_tasks: int = 128:
	set(value):
		max_finished_tasks = maxi(value, 0)
		_trim_finished_tasks()

## 是否默认允许 Object、Resource、Callable、Signal 或 RID 进入线程 payload。
## 仅迁移旧项目或明确自行保证线程安全时才建议开启。
## [br]
## @api public
var allow_object_payloads: bool = false


# --- 私有变量 ---

var _work_serial: int = 0
var _tasks: Dictionary = {}
var _queued_thread_tasks: Array = []
var _active_thread_tasks: Dictionary = {}
var _resource_requests: Dictionary = {}
var _apply_queue: Array = []
var _finished_tasks: Array = []
var _paused: bool = false


# --- GF 生命周期方法 ---

## 初始化后台工作协调器并启用暂停无关处理。
## [br]
## @api public
func init() -> void:
	ignore_pause = true
	clear_all()


## 推进后台工作完成检查与主线程应用。
## [br]
## @api public
## [br]
## @param _delta: 为兼容统一 tick 签名而保留的参数。
func tick(_delta: float = 0.0) -> void:
	_poll_thread_tasks()
	_poll_resource_requests()
	_process_apply_queue()
	_start_queued_thread_tasks()


## 取消未完成工作、等待线程结束并清理运行时状态。
## [br]
## @api public
func dispose() -> void:
	cancel_all()
	_wait_for_active_thread_tasks()
	clear_all()


# --- 公共方法 ---

## 提交 CPU 纯数据后台工作。
## [br]
## @param worker: 后台线程回调，签名推荐为 func(input_data: Variant) -> Variant。
## [br]
## @param input_data: 输入数据。默认只允许纯 Variant 容器和值。
## [br]
## @param apply_callback: 主线程应用回调，签名推荐为 func(task: GFBackgroundWorkTask) -> Variant。
## [br]
## @param options: 可选配置，支持 id、priority、metadata、front、allow_object_payloads。
## [br]
## @return 工作记录；参数无效时返回 failed 状态任务。
## [br]
## @api public
## [br]
## @schema input_data: Variant，复制到工作线程的纯数据载荷；显式允许对象载荷时除外。
## [br]
## @schema options: Dictionary，包含 id: StringName/String、priority: int、metadata: Dictionary、front: bool 和 allow_object_payloads: bool。
func submit_cpu_work(
	worker: Callable,
	input_data: Variant = null,
	apply_callback: Callable = Callable(),
	options: Dictionary = {}
) -> GFBackgroundWorkTask:
	return _submit_threaded_work(GFBackgroundWorkTask.Kind.CPU, worker, input_data, apply_callback, options)


## 提交 IO 纯数据后台工作。
## [br]
## @param worker: 后台线程回调，签名推荐为 func(input_data: Variant) -> Variant。
## [br]
## @param input_data: 输入数据。默认只允许纯 Variant 容器和值。
## [br]
## @param apply_callback: 主线程应用回调，签名推荐为 func(task: GFBackgroundWorkTask) -> Variant。
## [br]
## @param options: 可选配置，支持 id、priority、metadata、front、allow_object_payloads。
## [br]
## @return 工作记录；参数无效时返回 failed 状态任务。
## [br]
## @api public
## [br]
## @schema input_data: Variant，复制到工作线程的纯数据载荷；显式允许对象载荷时除外。
## [br]
## @schema options: Dictionary，包含 id: StringName/String、priority: int、metadata: Dictionary、front: bool 和 allow_object_payloads: bool。
func submit_io_work(
	worker: Callable,
	input_data: Variant = null,
	apply_callback: Callable = Callable(),
	options: Dictionary = {}
) -> GFBackgroundWorkTask:
	return _submit_threaded_work(GFBackgroundWorkTask.Kind.IO, worker, input_data, apply_callback, options)


## 提交 ResourceLoader 后台资源加载。
## [br]
## @param path: 资源路径。
## [br]
## @param type_hint: 可选资源类型提示。
## [br]
## @param apply_callback: 主线程应用回调，签名推荐为 func(task: GFBackgroundWorkTask) -> Variant。
## [br]
## @param options: 可选配置，支持 id、priority、metadata。
## [br]
## @return 工作记录；参数无效或请求失败时返回 failed 状态任务。
## [br]
## @api public
## [br]
## @schema options: Dictionary，包含 id: StringName/String、priority: int 和 metadata: Dictionary。
func submit_resource_load(
	path: String,
	type_hint: String = "",
	apply_callback: Callable = Callable(),
	options: Dictionary = {}
) -> GFBackgroundWorkTask:
	var task: Variant = _create_task(GFBackgroundWorkTask.Kind.RESOURCE, Callable(), apply_callback, options)
	task.resource_path = path
	task.resource_type_hint = type_hint

	if path.is_empty():
		_fail_task(task, "[GFBackgroundWorkUtility] submit_resource_load 失败：资源路径为空。")
		return task as GFBackgroundWorkTask

	if not _register_task(task):
		_fail_task(task, "[GFBackgroundWorkUtility] submit_resource_load 失败：工作 ID 已存在。")
		return task as GFBackgroundWorkTask

	work_queued.emit(task)
	_start_resource_task(task)
	return task as GFBackgroundWorkTask


## 取消指定工作。
## [br]
## @api public
## [br]
## @param work_id: 工作 ID。
## [br]
## @return 取消成功返回 true。
func cancel_work(work_id: StringName) -> bool:
	var task: Variant = get_task(work_id)
	if task == null or task.is_finished():
		return false

	task.cancel_requested = true
	if task.status == GFBackgroundWorkTask.Status.QUEUED:
		_queued_thread_tasks.erase(task)
		_cancel_task(task)
		return true

	if task.status == GFBackgroundWorkTask.Status.APPLYING:
		_apply_queue.erase(task)
		_cancel_task(task)
		return true

	return true


## 取消全部未完成工作。
## [br]
## @api public
func cancel_all() -> void:
	var task_values := _tasks.values()
	for task_variant: Variant in task_values:
		var task: Variant = task_variant
		if task != null and not task.is_finished():
			cancel_work(task.work_id)


## 暂停启动新的 CPU/IO 线程工作；已运行和资源加载中的工作会继续推进。
## [br]
## @api public
func pause() -> void:
	_paused = true


## 恢复启动新的 CPU/IO 线程工作。
## [br]
## @api public
func resume() -> void:
	_paused = false
	_start_queued_thread_tasks()


## 检查是否暂停。
## [br]
## @api public
## [br]
## @return 暂停时返回 true。
func is_paused() -> bool:
	return _paused


## 更新工作进度。
## [br]
## @api public
## [br]
## @param work_id: 工作 ID。
## [br]
## @param progress: 当前进度。
## [br]
## @param message: 进度说明。
## [br]
## @return 更新成功返回 true。
func update_work_progress(work_id: StringName, progress: float, message: String = "") -> bool:
	var task: Variant = get_task(work_id)
	if task == null or task.is_finished():
		return false
	task.progress = clampf(progress, 0.0, 1.0)
	work_progressed.emit(task, task.progress, message)
	return true


## 获取工作。
## [br]
## @api public
## [br]
## @param work_id: 工作 ID。
## [br]
## @return 工作记录；不存在时返回 null。
func get_task(work_id: StringName) -> GFBackgroundWorkTask:
	return _tasks.get(work_id) as GFBackgroundWorkTask


## 清理已完成的历史工作记录。
## [br]
## @api public
func clear_finished_tasks() -> void:
	for task: Variant in _finished_tasks:
		if task != null:
			_tasks.erase(task.work_id)
	_finished_tasks.clear()


## 清空全部工作。调用前应确保不再需要正在执行的线程结果。
## [br]
## @api public
func clear_all() -> void:
	_work_serial = 0
	_tasks.clear()
	_queued_thread_tasks.clear()
	_active_thread_tasks.clear()
	_resource_requests.clear()
	_apply_queue.clear()
	_finished_tasks.clear()
	_paused = false


## 获取调试快照。
## [br]
## @api public
## [br]
## @return 调试快照字典。
## [br]
## @schema return: Dictionary，包含任务计数、queued_ids、running_thread_ids、resource_paths、apply_ids、finished_ids、暂停状态和 apply 时间预算。
func get_debug_snapshot() -> Dictionary:
	return {
		"task_count": _tasks.size(),
		"queued_count": _queued_thread_tasks.size(),
		"running_thread_count": _active_thread_tasks.size(),
		"resource_request_count": _resource_requests.size(),
		"apply_count": _apply_queue.size(),
		"finished_count": _finished_tasks.size(),
		"is_paused": _paused,
		"queued_ids": _task_ids(_queued_thread_tasks),
		"running_thread_ids": _active_thread_task_ids(),
		"resource_paths": PackedStringArray(_resource_requests.keys()),
		"apply_ids": _task_ids(_apply_queue),
		"finished_ids": _task_ids(_finished_tasks),
		"max_apply_seconds_per_tick": max_apply_seconds_per_tick,
	}


# --- 私有/辅助方法 ---

func _submit_threaded_work(
	kind: int,
	worker: Callable,
	input_data: Variant,
	apply_callback: Callable,
	options: Dictionary
) -> GFBackgroundWorkTask:
	var task: Variant = _create_task(kind, worker, apply_callback, options)
	if not worker.is_valid():
		_fail_task(task, "[GFBackgroundWorkUtility] 提交后台工作失败：worker 无效。")
		return task as GFBackgroundWorkTask

	var allow_payload_objects := allow_object_payloads or bool(options.get("allow_object_payloads", false))
	if not allow_payload_objects and not _is_thread_payload_safe(input_data):
		_fail_task(task, "[GFBackgroundWorkUtility] 提交后台工作失败：payload 只能包含纯 Variant 数据。")
		return task as GFBackgroundWorkTask

	task.input_data = GFVariantData.duplicate_variant(input_data)
	if not _register_task(task):
		_fail_task(task, "[GFBackgroundWorkUtility] 提交后台工作失败：工作 ID 已存在。")
		return task as GFBackgroundWorkTask

	_insert_queued_thread_task(task, bool(options.get("front", false)))
	work_queued.emit(task)
	_start_queued_thread_tasks()
	return task as GFBackgroundWorkTask


func _create_task(
	kind: int,
	worker: Callable,
	apply_callback: Callable,
	options: Dictionary
) -> Variant:
	_work_serial += 1
	var task: Variant = GFBackgroundWorkTask.new()
	task.kind = kind
	task.work_id = StringName(str(options.get("id", "")))
	if task.work_id == &"":
		task.work_id = StringName("%s:%d" % [GFBackgroundWorkTask.kind_name(kind), _work_serial])
	task.priority = int(options.get("priority", 0))
	var metadata := options.get("metadata", {}) as Dictionary
	task.metadata = metadata.duplicate(true) if metadata != null else {}
	task.created_msec = Time.get_ticks_msec()
	task._worker_callback = worker
	task._apply_callback = apply_callback
	return task


func _register_task(task: Variant) -> bool:
	if task == null or task.work_id == &"" or _tasks.has(task.work_id):
		return false
	_tasks[task.work_id] = task
	return true


func _start_queued_thread_tasks() -> void:
	if _paused:
		return

	while _active_thread_tasks.size() < max_threaded_tasks and not _queued_thread_tasks.is_empty():
		var task: Variant = _queued_thread_tasks.pop_front()
		if task == null or task.status != GFBackgroundWorkTask.Status.QUEUED:
			continue
		if task.cancel_requested:
			_cancel_task(task)
			continue
		_start_thread_task(task)


func _insert_queued_thread_task(task: Variant, front: bool) -> void:
	var insert_index := _queued_thread_tasks.size()
	for i in range(_queued_thread_tasks.size()):
		var current: Variant = _queued_thread_tasks[i]
		if current == null:
			insert_index = i
			break
		if int(task.priority) > int(current.priority):
			insert_index = i
			break
		if front and int(task.priority) == int(current.priority):
			insert_index = i
			break
	_queued_thread_tasks.insert(insert_index, task)


func _start_thread_task(task: Variant) -> void:
	var thread := Thread.new()
	var error := thread.start(Callable(self, "_run_threaded_task").bind(task._worker_callback, task.input_data))
	if error != OK:
		_fail_task(task, "[GFBackgroundWorkUtility] 启动线程失败：%d。" % error)
		return

	task.status = GFBackgroundWorkTask.Status.RUNNING
	task.started_msec = Time.get_ticks_msec()
	_active_thread_tasks[task.work_id] = {
		"task": task,
		"thread": thread,
	}
	work_started.emit(task)


func _poll_thread_tasks() -> void:
	var active_ids := _active_thread_tasks.keys()
	for work_id: StringName in active_ids:
		var entry := _active_thread_tasks.get(work_id) as Dictionary
		if entry == null:
			continue
		var thread := entry.get("thread") as Thread
		if thread == null or thread.is_alive():
			continue

		var result_variant: Variant = thread.wait_to_finish()
		_active_thread_tasks.erase(work_id)
		var task: Variant = entry.get("task")
		_finish_thread_task(task, result_variant)


func _finish_thread_task(task: Variant, result_variant: Variant) -> void:
	if task == null or task.is_finished():
		return
	if task.cancel_requested:
		_cancel_task(task)
		return

	var result := result_variant as Dictionary
	if result == null:
		_fail_task(task, "[GFBackgroundWorkUtility] 后台工作返回了无效结果。", result_variant)
		return
	if not bool(result.get("ok", false)):
		_fail_task(task, str(result.get("error", "background work failed")), result.get("result", result))
		return

	task.result = result.get("result")
	_queue_apply_or_complete(task)


func _run_threaded_task(worker: Callable, input_data: Variant) -> Dictionary:
	var value: Variant = worker.call(input_data)
	if value is Dictionary and not bool((value as Dictionary).get("ok", true)):
		return {
			"ok": false,
			"error": str((value as Dictionary).get("error", "")),
			"result": value,
		}
	if value is bool and not bool(value):
		return {
			"ok": false,
			"error": "",
			"result": value,
		}
	return {
		"ok": true,
		"result": value,
	}


func _start_resource_task(task: Variant) -> void:
	var path: String = task.resource_path
	if _resource_requests.has(path):
		var request := _resource_requests[path] as Dictionary
		var pending_type_hint := String(request.get("type_hint", ""))
		if not _type_hints_are_compatible(pending_type_hint, task.resource_type_hint):
			_fail_task(task, "[GFBackgroundWorkUtility] 相同资源路径已有不同 type_hint 的加载请求：%s。" % path)
			return

		var tasks := request.get("tasks", []) as Array
		tasks.append(task)
		_start_task_without_thread(task)
		return

	var error := _request_threaded_resource(path, task.resource_type_hint)
	if error != OK:
		_fail_task(task, "[GFBackgroundWorkUtility] 发起资源线程加载失败：%s (%d)。" % [path, error])
		return

	_resource_requests[path] = {
		"type_hint": task.resource_type_hint,
		"tasks": [task],
	}
	_start_task_without_thread(task)


func _start_task_without_thread(task: Variant) -> void:
	task.status = GFBackgroundWorkTask.Status.RUNNING
	task.started_msec = Time.get_ticks_msec()
	work_started.emit(task)


func _poll_resource_requests() -> void:
	var paths := _resource_requests.keys()
	for path: String in paths:
		if not _resource_requests.has(path):
			continue

		var request := _resource_requests[path] as Dictionary
		var progress: Array = []
		var status := ResourceLoader.load_threaded_get_status(path, progress)
		var ratio: float = progress[0] if progress.size() > 0 else 0.0
		var tasks := request.get("tasks", []) as Array
		for task: Variant in tasks:
			if task != null and not task.cancel_requested and not task.is_finished():
				update_work_progress(task.work_id, ratio)

		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				pass

			ResourceLoader.THREAD_LOAD_LOADED:
				var resource := ResourceLoader.load_threaded_get(path)
				_resource_requests.erase(path)
				for task: Variant in tasks:
					_finish_resource_task(task, resource)

			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				_resource_requests.erase(path)
				for task: Variant in tasks:
					if task != null and task.cancel_requested:
						_cancel_task(task)
					else:
						_fail_task(task, "[GFBackgroundWorkUtility] 资源线程加载失败：%s。" % path)


func _finish_resource_task(task: Variant, resource: Resource) -> void:
	if task == null or task.is_finished():
		return
	if task.cancel_requested:
		_cancel_task(task)
		return
	if resource == null:
		_fail_task(task, "[GFBackgroundWorkUtility] 资源线程加载完成但结果为空：%s。" % task.resource_path)
		return

	task.result = resource
	task.progress = 1.0
	_queue_apply_or_complete(task)


func _queue_apply_or_complete(task: Variant) -> void:
	if task.cancel_requested:
		_cancel_task(task)
		return
	if task._apply_callback.is_valid():
		task.status = GFBackgroundWorkTask.Status.APPLYING
		_apply_queue.append(task)
		return
	_complete_task(task)


func _process_apply_queue() -> void:
	var remaining := maxi(max_apply_per_tick, 1)
	var started_usec := Time.get_ticks_usec()
	var applied_count := 0
	while remaining > 0 and not _apply_queue.is_empty():
		if _is_apply_time_budget_exhausted(started_usec, applied_count):
			break

		remaining -= 1
		var task: Variant = _apply_queue.pop_front()
		if task == null or task.is_finished():
			continue
		if task.cancel_requested:
			_cancel_task(task)
			continue

		var value: Variant = task._apply_callback.call(task)
		applied_count += 1
		task.apply_result = value
		if value is Dictionary and not bool((value as Dictionary).get("ok", true)):
			_fail_task(task, str((value as Dictionary).get("error", "")), value)
			continue
		if value is bool and not bool(value):
			_fail_task(task, "", value)
			continue

		work_applied.emit(task)
		_complete_task(task)


func _complete_task(task: Variant) -> void:
	if task == null or task.is_finished():
		return
	task.status = GFBackgroundWorkTask.Status.COMPLETED
	task.progress = 1.0
	task.finished_msec = Time.get_ticks_msec()
	_finished_tasks.append(task)
	_trim_finished_tasks()
	work_completed.emit(task)


func _fail_task(task: Variant, error_message: String = "", result: Variant = null) -> void:
	if task == null or task.is_finished():
		return
	_queued_thread_tasks.erase(task)
	_apply_queue.erase(task)
	task.status = GFBackgroundWorkTask.Status.FAILED
	task.error_message = error_message
	task.result = result
	task.finished_msec = Time.get_ticks_msec()
	_finished_tasks.append(task)
	_trim_finished_tasks()
	work_failed.emit(task)


func _cancel_task(task: Variant) -> void:
	if task == null or task.is_finished():
		return
	_queued_thread_tasks.erase(task)
	_apply_queue.erase(task)
	task.status = GFBackgroundWorkTask.Status.CANCELLED
	task.finished_msec = Time.get_ticks_msec()
	_finished_tasks.append(task)
	_trim_finished_tasks()
	work_cancelled.emit(task)


func _wait_for_active_thread_tasks() -> void:
	for work_id: StringName in _active_thread_tasks.keys():
		var entry := _active_thread_tasks.get(work_id) as Dictionary
		if entry == null:
			continue
		var thread := entry.get("thread") as Thread
		var result_variant: Variant = null
		if thread != null:
			result_variant = thread.wait_to_finish()
		var task: Variant = entry.get("task")
		_finish_thread_task(task, result_variant)
	_active_thread_tasks.clear()


func _trim_finished_tasks() -> void:
	var limit := maxi(max_finished_tasks, 0)
	while _finished_tasks.size() > limit:
		var removed: Variant = _finished_tasks.pop_front()
		if removed != null and removed.is_finished():
			_tasks.erase(removed.work_id)


func _is_apply_time_budget_exhausted(started_usec: int, applied_count: int) -> bool:
	if max_apply_seconds_per_tick <= 0.0 or applied_count <= 0:
		return false
	var elapsed_seconds := float(Time.get_ticks_usec() - started_usec) / 1000000.0
	return elapsed_seconds >= max_apply_seconds_per_tick


func _is_thread_payload_safe(value: Variant, depth: int = 0) -> bool:
	if depth > _MAX_PAYLOAD_DEPTH:
		return false

	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_STRING_NAME:
			return true
		TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_RECT2, TYPE_RECT2I, TYPE_VECTOR3, TYPE_VECTOR3I:
			return true
		TYPE_TRANSFORM2D, TYPE_VECTOR4, TYPE_VECTOR4I, TYPE_PLANE, TYPE_QUATERNION, TYPE_AABB:
			return true
		TYPE_BASIS, TYPE_TRANSFORM3D, TYPE_PROJECTION, TYPE_COLOR, TYPE_NODE_PATH:
			return true
		TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY:
			return true
		TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY:
			return true
		TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY:
			return true
		TYPE_PACKED_COLOR_ARRAY, TYPE_PACKED_VECTOR4_ARRAY:
			return true
		TYPE_ARRAY:
			var array := value as Array
			for item: Variant in array:
				if not _is_thread_payload_safe(item, depth + 1):
					return false
			return true
		TYPE_DICTIONARY:
			var dictionary := value as Dictionary
			for key: Variant in dictionary.keys():
				if not _is_thread_payload_safe(key, depth + 1):
					return false
				if not _is_thread_payload_safe(dictionary[key], depth + 1):
					return false
			return true
	return false


func _request_threaded_resource(path: String, type_hint: String) -> Error:
	if type_hint.is_empty():
		return ResourceLoader.load_threaded_request(path)
	return ResourceLoader.load_threaded_request(path, type_hint)


func _type_hints_are_compatible(left: String, right: String) -> bool:
	return left.is_empty() or right.is_empty() or left == right


func _task_ids(tasks: Array) -> PackedStringArray:
	var result := PackedStringArray()
	for task: Variant in tasks:
		if task != null:
			result.append(String(task.work_id))
	return result


func _active_thread_task_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for work_id: StringName in _active_thread_tasks.keys():
		result.append(String(work_id))
	return result
