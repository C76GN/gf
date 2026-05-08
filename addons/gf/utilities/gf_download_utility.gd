## GFDownloadUtility: 通用文件下载队列。
##
## 提供顺序下载、临时文件提交、可选续传、SHA-256 校验、暂停、取消和诊断快照。
class_name GFDownloadUtility
extends GFUtility


# --- 信号 ---

## 下载任务开始时发出。
signal download_started(task_id: int, task: GFDownloadTask)

## 下载进度更新时发出。
signal download_progressed(task_id: int, received_bytes: int, total_bytes: int)

## 下载任务成功完成时发出。
signal download_completed(task_id: int, result: Dictionary)

## 下载任务失败时发出。
signal download_failed(task_id: int, result: Dictionary)

## 下载任务被取消时发出。
signal download_cancelled(task_id: int, result: Dictionary)


# --- 公共变量 ---

## HTTP 请求超时时间，单位秒。
var timeout_seconds: float = 30.0

## 临时文件后缀。
var default_temp_suffix: String = ".download"

## 分段续传临时文件后缀。
var default_segment_suffix: String = ".segment"

## 目标文件已存在时默认是否覆盖。
var overwrite_existing: bool = true

## 进度信号最小间隔，单位秒。
var emit_progress_interval_seconds: float = 0.1


# --- 私有变量 ---

var _pending_tasks: Array[GFDownloadTask] = []
var _active_task: GFDownloadTask = null
var _active_request_data: Dictionary = {}
var _http_request: HTTPRequest = null
var _next_task_id: int = 1
var _paused: bool = false
var _results: Dictionary = {}
var _callbacks: Dictionary = {}
var _last_progress_emit_msec: int = 0


# --- Godot 生命周期方法 ---

func init() -> void:
	ignore_pause = true
	_pending_tasks.clear()
	_active_task = null
	_active_request_data.clear()
	_next_task_id = 1
	_paused = false
	_results.clear()
	_callbacks.clear()
	_last_progress_emit_msec = 0


func dispose() -> void:
	clear_queue(true)
	if is_instance_valid(_http_request):
		_http_request.queue_free()
	_http_request = null
	_results.clear()
	_callbacks.clear()
	_next_task_id = 1
	_paused = false


## 驱动下载进度采样。
## @param _delta: 为兼容统一 tick 签名而保留的参数。
func tick(_delta: float = 0.0) -> void:
	if _active_task == null or not is_instance_valid(_http_request):
		return

	var now_msec := Time.get_ticks_msec()
	if now_msec - _last_progress_emit_msec < int(emit_progress_interval_seconds * 1000.0):
		return

	_last_progress_emit_msec = now_msec
	_active_task.received_bytes = int(_http_request.get_downloaded_bytes())
	_active_task.total_bytes = int(_http_request.get_body_size())
	download_progressed.emit(_active_task.task_id, _active_task.received_bytes, _active_task.total_bytes)


# --- 公共方法 ---

## 将下载任务加入队列。
## @param url: 下载 URL。
## @param target_path: 最终写入路径。
## @param callback: 完成、失败或取消时执行的回调，签名为 func(result: Dictionary)。
## @param options: 可选参数，支持 headers、resume、overwrite、expected_sha256、metadata、temp_path、segment_path。
## @return 任务句柄；输入无效时返回 0。
func enqueue_download(
	url: String,
	target_path: String,
	callback: Callable = Callable(),
	options: Dictionary = {}
) -> int:
	if url.is_empty() or target_path.is_empty():
		push_error("[GFDownloadUtility] enqueue_download 失败：url 或 target_path 为空。")
		return 0

	var task := GFDownloadTask.new()
	task.task_id = _next_task_id
	_next_task_id += 1
	task.url = url
	task.target_path = target_path
	task.temp_path = str(options.get("temp_path", target_path + default_temp_suffix))
	task.segment_path = str(options.get("segment_path", task.temp_path + default_segment_suffix))
	task.headers = _normalize_headers(options.get("headers", PackedStringArray()))
	task.expected_sha256 = str(options.get("expected_sha256", "")).to_lower()
	task.resume = bool(options.get("resume", true))
	task.overwrite = bool(options.get("overwrite", overwrite_existing))
	task.metadata = (options.get("metadata", {}) as Dictionary).duplicate(true) if options.get("metadata", {}) is Dictionary else {}
	if callback.is_valid():
		_callbacks[task.task_id] = callback

	_pending_tasks.append(task)
	_try_start_next_download()
	return task.task_id


## 取消下载任务。
## @param task_id: 任务句柄。
## @param delete_temp: 是否删除临时文件。
## @return 找到并取消任务时返回 true。
func cancel(task_id: int, delete_temp: bool = false) -> bool:
	if task_id <= 0:
		return false

	if _active_task != null and _active_task.task_id == task_id:
		var task := _active_task
		if is_instance_valid(_http_request):
			_http_request.cancel_request()
		_active_task = null
		_active_request_data.clear()
		task.status = GFDownloadTask.Status.CANCELLED
		task.error = "cancelled"
		if delete_temp:
			_delete_task_temp_files(task)
		_finish_task(task, false, true)
		_try_start_next_download()
		return true

	for index: int in range(_pending_tasks.size() - 1, -1, -1):
		var task := _pending_tasks[index]
		if task.task_id == task_id:
			_pending_tasks.remove_at(index)
			task.status = GFDownloadTask.Status.CANCELLED
			task.error = "cancelled"
			if delete_temp:
				_delete_task_temp_files(task)
			_finish_task(task, false, true)
			return true
	return false


## 设置下载队列暂停状态。暂停时不会启动新任务，当前任务会保留临时文件并回到队首。
## @param value: 是否暂停。
func set_paused(value: bool) -> void:
	if _paused == value:
		return

	_paused = value
	if _paused:
		_pause_active_task()
	else:
		_try_start_next_download()


## 暂停下载队列。
func pause() -> void:
	set_paused(true)


## 恢复下载队列。
func resume() -> void:
	set_paused(false)


## 检查下载队列是否暂停。
## @return 暂停时返回 true。
func is_paused() -> bool:
	return _paused


## 清空等待队列，可选取消当前任务。
## @param cancel_active: 是否取消当前任务。
## @param delete_temp: 是否删除临时文件。
func clear_queue(cancel_active: bool = false, delete_temp: bool = false) -> void:
	for task: GFDownloadTask in _pending_tasks:
		task.status = GFDownloadTask.Status.CANCELLED
		task.error = "cancelled"
		if delete_temp:
			_delete_task_temp_files(task)
		_finish_task(task, false, true)
	_pending_tasks.clear()

	if cancel_active and _active_task != null:
		cancel(_active_task.task_id, delete_temp)


## 获取当前正在下载的任务拷贝。
## @return 当前任务；没有任务时返回 null。
func get_active_task() -> GFDownloadTask:
	return _active_task.duplicate_task() if _active_task != null else null


## 获取等待队列中的任务 ID。
## @return 任务 ID 列表。
func get_queued_task_ids() -> PackedInt32Array:
	var result := PackedInt32Array()
	for task: GFDownloadTask in _pending_tasks:
		result.append(task.task_id)
	return result


## 获取指定任务最近结果。
## @param task_id: 任务句柄。
## @return 结果字典；不存在时返回空字典。
func get_result(task_id: int) -> Dictionary:
	return (_results.get(task_id, {}) as Dictionary).duplicate(true)


## 获取下载工具诊断快照。
## @return 诊断快照字典。
func get_debug_snapshot() -> Dictionary:
	var queued_ids := PackedInt32Array()
	for task: GFDownloadTask in _pending_tasks:
		queued_ids.append(task.task_id)

	return {
		"paused": _paused,
		"queued_count": _pending_tasks.size(),
		"queued_task_ids": queued_ids,
		"active_task": _active_task.to_dict() if _active_task != null else {},
		"result_count": _results.size(),
	}


# --- 私有/辅助方法 ---

func _try_start_next_download() -> void:
	if _paused or _active_task != null or _pending_tasks.is_empty():
		return

	var task := _pending_tasks.pop_front()
	if FileAccess.file_exists(task.target_path) and not task.overwrite:
		task.status = GFDownloadTask.Status.COMPLETED
		_finish_task(task, true, false, { "from_existing_file": true })
		_try_start_next_download()
		return

	_ensure_parent_dir(task.temp_path)
	_ensure_parent_dir(task.target_path)
	_active_task = task
	_active_task.status = GFDownloadTask.Status.RUNNING
	_active_request_data = _build_request_data(task)
	var error := _start_http_request(_active_request_data)
	if error != OK:
		_active_task = null
		_active_request_data.clear()
		task.status = GFDownloadTask.Status.FAILED
		task.error = "Request failed: %s" % error_string(error)
		_finish_task(task, false, false)
		_try_start_next_download()
		return

	_last_progress_emit_msec = 0
	download_started.emit(task.task_id, task.duplicate_task())


func _build_request_data(task: GFDownloadTask) -> Dictionary:
	var resume_offset := 0
	if task.resume and FileAccess.file_exists(task.temp_path):
		resume_offset = _get_file_size(task.temp_path)

	var request_headers := task.headers.duplicate()
	var download_file := task.temp_path
	if resume_offset > 0:
		request_headers.append("Range: bytes=%d-" % resume_offset)
		download_file = task.segment_path

	return {
		"task_id": task.task_id,
		"url": task.url,
		"headers": request_headers,
		"download_file": download_file,
		"resume_offset": resume_offset,
	}


func _start_http_request(request_data: Dictionary) -> Error:
	var request := _ensure_http_request()
	if request == null:
		return ERR_UNAVAILABLE

	request.timeout = timeout_seconds
	request.download_file = str(request_data["download_file"])
	return request.request(
		str(request_data["url"]),
		request_data["headers"] as PackedStringArray
	)


func _ensure_http_request() -> HTTPRequest:
	if is_instance_valid(_http_request):
		return _http_request

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null

	_http_request = HTTPRequest.new()
	_http_request.name = "GFDownloadHTTPRequest"
	_http_request.request_completed.connect(_on_request_completed)
	tree.root.add_child(_http_request)
	return _http_request


func _complete_active_download(
	success: bool,
	response_code: int,
	error: String = ""
) -> void:
	if _active_task == null:
		return

	var task := _active_task
	var request_data := _active_request_data.duplicate(true)
	_active_task = null
	_active_request_data.clear()
	task.response_code = response_code

	if success:
		var commit_error := _commit_download_file(task, request_data, response_code)
		if commit_error == OK:
			task.status = GFDownloadTask.Status.COMPLETED
			task.error = ""
			_finish_task(task, true, false)
		else:
			task.status = GFDownloadTask.Status.FAILED
			task.error = "Commit failed: %s" % error_string(commit_error)
			_finish_task(task, false, false)
	else:
		task.status = GFDownloadTask.Status.FAILED
		task.error = error
		_finish_task(task, false, false)

	_try_start_next_download()


func _commit_download_file(task: GFDownloadTask, request_data: Dictionary, response_code: int) -> Error:
	var resume_offset := int(request_data.get("resume_offset", 0))
	if resume_offset > 0:
		if response_code == 206:
			var append_error := _append_file(task.segment_path, task.temp_path)
			if append_error != OK:
				return append_error
			DirAccess.remove_absolute(task.segment_path)
		elif FileAccess.file_exists(task.segment_path):
			if FileAccess.file_exists(task.temp_path):
				DirAccess.remove_absolute(task.temp_path)
			var replace_error := DirAccess.rename_absolute(task.segment_path, task.temp_path)
			if replace_error != OK:
				return replace_error

	if not _verify_checksum(task):
		return ERR_INVALID_DATA

	if FileAccess.file_exists(task.target_path):
		if not task.overwrite:
			return ERR_ALREADY_EXISTS
		var remove_error := DirAccess.remove_absolute(task.target_path)
		if remove_error != OK:
			return remove_error

	return DirAccess.rename_absolute(task.temp_path, task.target_path)


func _append_file(source_path: String, target_path: String) -> Error:
	if not FileAccess.file_exists(source_path):
		return OK

	var source := FileAccess.open(source_path, FileAccess.READ)
	if source == null:
		return FileAccess.get_open_error()
	var target := FileAccess.open(target_path, FileAccess.READ_WRITE)
	if target == null:
		source.close()
		return FileAccess.get_open_error()

	target.seek_end()
	target.store_buffer(source.get_buffer(source.get_length()))
	source.close()
	target.close()
	return OK


func _verify_checksum(task: GFDownloadTask) -> bool:
	if task.expected_sha256.is_empty():
		return true
	if not FileAccess.file_exists(task.temp_path):
		task.error = "checksum failed: temp file missing"
		return false

	var actual := FileAccess.get_sha256(task.temp_path).to_lower()
	if actual != task.expected_sha256:
		task.error = "checksum mismatch"
		return false
	return true


func _finish_task(
	task: GFDownloadTask,
	success: bool,
	cancelled: bool,
	extra: Dictionary = {}
) -> void:
	var result := task.to_dict()
	result["success"] = success
	result["cancelled"] = cancelled
	for key: Variant in extra.keys():
		result[key] = extra[key]

	_results[task.task_id] = result.duplicate(true)
	var callback := _callbacks.get(task.task_id, Callable()) as Callable
	_callbacks.erase(task.task_id)
	if callback != null and callback.is_valid():
		callback.call(result.duplicate(true))

	if cancelled:
		download_cancelled.emit(task.task_id, result)
	elif success:
		download_completed.emit(task.task_id, result)
	else:
		download_failed.emit(task.task_id, result)


func _pause_active_task() -> void:
	if _active_task == null:
		return

	var task := _active_task
	task.status = GFDownloadTask.Status.PAUSED
	if is_instance_valid(_http_request):
		_http_request.cancel_request()
	_active_task = null
	_active_request_data.clear()
	_pending_tasks.push_front(task)


func _normalize_headers(value: Variant) -> PackedStringArray:
	if value is PackedStringArray:
		return (value as PackedStringArray).duplicate()
	if value is Array:
		var result := PackedStringArray()
		for item: Variant in value:
			result.append(str(item))
		return result
	if value is Dictionary:
		var result := PackedStringArray()
		var data := value as Dictionary
		for key: Variant in data.keys():
			result.append("%s: %s" % [str(key), str(data[key])])
		return result
	return PackedStringArray()


func _delete_task_temp_files(task: GFDownloadTask) -> void:
	if FileAccess.file_exists(task.temp_path):
		DirAccess.remove_absolute(task.temp_path)
	if FileAccess.file_exists(task.segment_path):
		DirAccess.remove_absolute(task.segment_path)


func _get_file_size(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return 0
	var size := int(file.get_length())
	file.close()
	return size


func _ensure_parent_dir(path: String) -> void:
	var dir_path := path.get_base_dir()
	if dir_path.is_empty() or DirAccess.dir_exists_absolute(dir_path):
		return
	DirAccess.make_dir_recursive_absolute(dir_path)


# --- 信号处理函数 ---

func _on_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	_body: PackedByteArray
) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		_complete_active_download(false, response_code, "HTTP request result: %d" % result)
		return

	if response_code < 200 or response_code >= 300:
		_complete_active_download(false, response_code, "HTTP %d" % response_code)
		return

	_complete_active_download(true, response_code)
