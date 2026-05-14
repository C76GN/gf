## GFRemoteCacheUtility: 通用远程文本与 JSON 缓存工具。
##
## 提供 URL 请求、本地 TTL 缓存、失败时陈旧缓存回退和队列化 HTTP 访问。
## 具体内容类型、字段结构和业务策略由项目层自行决定。
class_name GFRemoteCacheUtility
extends GFUtility


# --- 信号 ---

## 请求成功完成时发出。成功使用陈旧缓存回退时也会发出。
signal fetch_completed(url: String, result: Dictionary)

## 请求失败且没有可用缓存时发出。
signal fetch_failed(url: String, result: Dictionary)


# --- 公共变量 ---

## user:// 下的缓存子目录名。
var cache_dir_name: String = "gf_remote_cache"

## 默认缓存有效期，单位秒。单次请求可覆盖。
var default_ttl_seconds: int = 86400

## HTTP 请求超时时间，单位秒。
var timeout_seconds: float = 20.0

## 最大缓存条目数，超过后会按修改时间清理最旧条目。
var max_cache_entries: int = 128

## 最大等待队列长度。小于等于 0 表示不限制。
var max_pending_requests: int = 64

## 自定义缓存 key 构造器。签名为 `func(url: String, headers: PackedStringArray, format: StringName) -> String`。
var cache_key_builder: Callable = Callable()


# --- 私有变量 ---

var _pending_requests: Array[Dictionary] = []
var _active_request: Dictionary = {}
var _http_request: HTTPRequest = null


# --- Godot 生命周期方法 ---

func init() -> void:
	ignore_pause = true
	_ensure_cache_dir()


func dispose() -> void:
	_pending_requests.clear()
	_active_request.clear()
	if is_instance_valid(_http_request):
		_http_request.queue_free()
	_http_request = null


# --- 公共方法 ---

## 获取远程文本。callback 签名为 `func(result: Dictionary) -> void`。
## @param url: 远程资源 URL。
## @param callback: 操作完成或事件触发时执行的回调。
## @param ttl_seconds: 缓存有效期（秒）。
## @param force_refresh: 为 true 时忽略现有缓存并重新请求。
## @param headers: HTTP 请求头字典。
func fetch_text(
	url: String,
	callback: Callable = Callable(),
	ttl_seconds: int = -1,
	force_refresh: bool = false,
	headers: PackedStringArray = PackedStringArray()
) -> void:
	_queue_fetch(url, callback, ttl_seconds, force_refresh, headers, &"text")


## 获取远程 JSON。成功时 result["data"] 为解析结果。
## @param url: 远程资源 URL。
## @param callback: 操作完成或事件触发时执行的回调。
## @param ttl_seconds: 缓存有效期（秒）。
## @param force_refresh: 为 true 时忽略现有缓存并重新请求。
## @param headers: HTTP 请求头字典。
func fetch_json(
	url: String,
	callback: Callable = Callable(),
	ttl_seconds: int = -1,
	force_refresh: bool = false,
	headers: PackedStringArray = PackedStringArray()
) -> void:
	_queue_fetch(url, callback, ttl_seconds, force_refresh, headers, &"json")


## 判断 URL 当前是否存在有效缓存。
## @param url: 远程资源 URL。
## @param ttl_seconds: 缓存有效期（秒）。
## @param headers: HTTP 请求头。
## @param format: 缓存格式标识。
func has_valid_cache(
	url: String,
	ttl_seconds: int = -1,
	headers: PackedStringArray = PackedStringArray(),
	format: StringName = &"text"
) -> bool:
	if url.is_empty():
		return false

	var path := _get_cache_path(_build_cache_key(url, headers, format))
	if not FileAccess.file_exists(path):
		return false

	var ttl := _resolve_ttl(ttl_seconds)
	if ttl <= 0:
		return false

	var modified_time := FileAccess.get_modified_time(path)
	var now := int(Time.get_unix_time_from_system())
	return now - modified_time <= ttl


## 读取有效文本缓存；不存在或过期时返回空字符串。
## @param url: 远程资源 URL。
## @param ttl_seconds: 缓存有效期（秒）。
## @param headers: HTTP 请求头。
func get_cached_text(
	url: String,
	ttl_seconds: int = -1,
	headers: PackedStringArray = PackedStringArray()
) -> String:
	if not has_valid_cache(url, ttl_seconds, headers, &"text"):
		return ""
	return _read_cache_text(_build_cache_key(url, headers, &"text"))


## 移除指定 URL 的缓存。
## @param url: 远程资源 URL。
## @param headers: HTTP 请求头。
## @param format: 缓存格式标识。
func remove_cache(
	url: String,
	headers: PackedStringArray = PackedStringArray(),
	format: StringName = &"text"
) -> Error:
	var path := _get_cache_path(_build_cache_key(url, headers, format))
	if not FileAccess.file_exists(path):
		return OK
	return DirAccess.remove_absolute(path)


## 取消匹配 URL、headers 与 format 的等待或进行中请求，返回取消数量。
## @param url: 远程资源 URL。
## @param headers: HTTP 请求头。
## @param format: 缓存格式标识。
func cancel(
	url: String,
	headers: PackedStringArray = PackedStringArray(),
	format: StringName = &"text"
) -> int:
	if url.is_empty():
		return 0

	return _cancel_by_cache_key(_build_cache_key(url, headers, format))


## 取消所有等待或进行中请求，返回取消数量。
func cancel_all() -> int:
	var cancelled := _pending_requests.size()
	_pending_requests.clear()
	if not _active_request.is_empty():
		cancelled += _get_request_callbacks(_active_request).size()
		_cancel_http_request()
		_active_request.clear()
	_process_next_request()
	return cancelled


## 清空当前缓存目录。
func clear_cache() -> void:
	var dir_path := _get_cache_dir_path()
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir():
			DirAccess.remove_absolute("%s/%s" % [dir_path, file_name])
		file_name = dir.get_next()
	dir.list_dir_end()


## 获取远程缓存工具诊断快照。
## @return 诊断快照字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"cache_dir_name": cache_dir_name,
		"cache_dir_path": _get_cache_dir_path(),
		"default_ttl_seconds": default_ttl_seconds,
		"timeout_seconds": timeout_seconds,
		"max_cache_entries": max_cache_entries,
		"max_pending_requests": max_pending_requests,
		"pending_count": _pending_requests.size(),
		"active_url": String(_active_request.get("url", "")),
		"active_cache_key": String(_active_request.get("cache_key", "")),
		"has_active_request": not _active_request.is_empty(),
	}


# --- 私有/辅助方法 ---

func _queue_fetch(
	url: String,
	callback: Callable,
	ttl_seconds: int,
	force_refresh: bool,
	headers: PackedStringArray,
	format: StringName
) -> void:
	if url.is_empty():
		_finish_immediate(callback, _build_failure(url, 0, "URL is empty"))
		return

	var ttl := _resolve_ttl(ttl_seconds)
	var cache_key := _build_cache_key(url, headers, format)
	if not force_refresh and _has_valid_cache_key(cache_key, ttl):
		var cached_result := _build_success(url, _read_cache_text(cache_key), true, false, 200, format)
		_finish_immediate(callback, cached_result)
		return

	if _append_callback_to_existing_request(cache_key, callback):
		return

	if max_pending_requests > 0 and _pending_requests.size() >= max_pending_requests:
		_finish_immediate(callback, _build_failure(url, 0, "Pending request limit exceeded"))
		return

	_pending_requests.append({
		"url": url,
		"callbacks": [callback],
		"ttl_seconds": ttl,
		"headers": headers,
		"format": format,
		"cache_key": cache_key,
	})
	_process_next_request()


func _process_next_request() -> void:
	if not _active_request.is_empty() or _pending_requests.is_empty():
		return

	_active_request = _pending_requests.pop_front()
	var error := _start_http_request(_active_request)
	if error != OK:
		_complete_active_request(false, 0, "", "Request failed: %s" % error_string(error))


func _append_callback_to_existing_request(cache_key: String, callback: Callable) -> bool:
	if not _active_request.is_empty() and String(_active_request.get("cache_key", "")) == cache_key:
		(_active_request["callbacks"] as Array).append(callback)
		return true

	for request_data: Dictionary in _pending_requests:
		if String(request_data.get("cache_key", "")) == cache_key:
			(request_data["callbacks"] as Array).append(callback)
			return true
	return false


func _cancel_by_cache_key(cache_key: String) -> int:
	var cancelled := 0
	var next_pending: Array[Dictionary] = []
	for request_data: Dictionary in _pending_requests:
		if String(request_data.get("cache_key", "")) == cache_key:
			cancelled += _get_request_callbacks(request_data).size()
		else:
			next_pending.append(request_data)
	_pending_requests = next_pending

	if not _active_request.is_empty() and String(_active_request.get("cache_key", "")) == cache_key:
		cancelled += _get_request_callbacks(_active_request).size()
		_cancel_http_request()
		_active_request.clear()
		_process_next_request()
	return cancelled


func _cancel_http_request() -> void:
	if is_instance_valid(_http_request):
		_http_request.cancel_request()


func _get_request_callbacks(request_data: Dictionary) -> Array:
	var callbacks: Variant = request_data.get("callbacks", [])
	return callbacks as Array if callbacks is Array else []


func _start_http_request(request_data: Dictionary) -> Error:
	var request := _ensure_http_request()
	if request == null:
		return ERR_UNAVAILABLE

	request.timeout = timeout_seconds
	return request.request(
		String(request_data["url"]),
		request_data["headers"] as PackedStringArray
	)


func _ensure_http_request() -> HTTPRequest:
	if is_instance_valid(_http_request):
		return _http_request

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null

	_http_request = HTTPRequest.new()
	_http_request.name = "GFRemoteCacheHTTPRequest"
	_http_request.request_completed.connect(_on_request_completed)
	tree.root.add_child(_http_request)
	return _http_request


func _complete_active_request(
	success: bool,
	response_code: int,
	content: String,
	error: String
) -> void:
	if _active_request.is_empty():
		return

	var request_data := _active_request.duplicate(true)
	_active_request.clear()

	var url := String(request_data["url"])
	var format := request_data["format"] as StringName
	var callbacks := _get_request_callbacks(request_data)
	var cache_key := String(request_data["cache_key"])
	var result: Dictionary

	if success:
		result = _build_success(url, content, false, false, response_code, format)
		if bool(result.get("success", false)):
			_write_cache_text(cache_key, content)
		elif _has_cache_file(cache_key):
			var parse_error := String(result.get("error", ""))
			result = _build_success(url, _read_cache_text(cache_key), true, true, response_code, format)
			result["error"] = parse_error
	else:
		result = _build_failure(url, response_code, error)
		if _has_cache_file(cache_key):
			result = _build_success(url, _read_cache_text(cache_key), true, true, response_code, format)
			result["error"] = error

	_finish_callbacks(callbacks, result)
	_process_next_request()


func _finish_immediate(callback: Callable, result: Dictionary) -> void:
	_finish_callbacks([callback], result)


func _finish_callbacks(callbacks: Array, result: Dictionary) -> void:
	for callback: Callable in callbacks:
		if callback.is_valid():
			callback.call(result)

	var url := String(result.get("url", ""))
	if bool(result.get("success", false)):
		fetch_completed.emit(url, result)
	else:
		fetch_failed.emit(url, result)


func _build_success(
	url: String,
	content: String,
	from_cache: bool,
	stale: bool,
	response_code: int,
	format: StringName
) -> Dictionary:
	var result := {
		"success": true,
		"url": url,
		"content": content,
		"data": null,
		"from_cache": from_cache,
		"stale": stale,
		"response_code": response_code,
		"error": "",
	}

	if format == &"json":
		var json := JSON.new()
		var parse_error := json.parse(content)
		if parse_error != OK:
			result["success"] = false
			result["error"] = "JSON parse failed: %s" % json.get_error_message()
		else:
			result["data"] = json.data

	return result


func _build_failure(url: String, response_code: int, error: String) -> Dictionary:
	return {
		"success": false,
		"url": url,
		"content": "",
		"data": null,
		"from_cache": false,
		"stale": false,
		"response_code": response_code,
		"error": error,
	}


func _resolve_ttl(ttl_seconds: int) -> int:
	if ttl_seconds >= 0:
		return ttl_seconds
	return maxi(default_ttl_seconds, 0)


func _ensure_cache_dir() -> void:
	var dir_path := _get_cache_dir_path()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)


func _get_cache_dir_path() -> String:
	return "user://%s" % cache_dir_name


func _build_cache_key(url: String, headers: PackedStringArray, format: StringName) -> String:
	if cache_key_builder.is_valid():
		return String(cache_key_builder.call(url, headers, format))

	var sorted_headers := headers.duplicate()
	sorted_headers.sort()
	return JSON.stringify([String(format), url, sorted_headers])


func _get_cache_path(cache_key: String) -> String:
	return "%s/%s.cache" % [_get_cache_dir_path(), cache_key.md5_text()]


func _get_cache_temp_path(cache_key: String) -> String:
	return "%s.tmp" % _get_cache_path(cache_key)


func _get_cache_backup_path(cache_key: String) -> String:
	return "%s.bak" % _get_cache_path(cache_key)


func _has_valid_cache_key(cache_key: String, ttl_seconds: int) -> bool:
	if cache_key.is_empty():
		return false

	var path := _get_cache_path(cache_key)
	if not FileAccess.file_exists(path):
		return false

	var ttl := _resolve_ttl(ttl_seconds)
	if ttl <= 0:
		return false

	var modified_time := FileAccess.get_modified_time(path)
	var now := int(Time.get_unix_time_from_system())
	return now - modified_time <= ttl


func _has_cache_file(cache_key: String) -> bool:
	return FileAccess.file_exists(_get_cache_path(cache_key))


func _read_cache_text(cache_key: String) -> String:
	var file := FileAccess.open(_get_cache_path(cache_key), FileAccess.READ)
	if file == null:
		return ""

	var content := file.get_as_text()
	file.close()
	return content


func _write_cache_text(cache_key: String, content: String) -> Error:
	_ensure_cache_dir()
	var path := _get_cache_path(cache_key)
	var temp_path := _get_cache_temp_path(cache_key)
	var backup_path := _get_cache_backup_path(cache_key)

	DirAccess.remove_absolute(temp_path)
	DirAccess.remove_absolute(backup_path)

	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_warning("[GFRemoteCacheUtility] 写入缓存失败：%s" % cache_key)
		return FileAccess.get_open_error()

	file.store_string(content)
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		DirAccess.remove_absolute(temp_path)
		push_warning("[GFRemoteCacheUtility] 写入缓存失败：%s" % cache_key)
		return write_error

	if FileAccess.file_exists(path):
		var backup_error := DirAccess.rename_absolute(path, backup_path)
		if backup_error != OK:
			DirAccess.remove_absolute(temp_path)
			push_warning("[GFRemoteCacheUtility] 写入缓存失败：%s" % cache_key)
			return backup_error

	var commit_error := DirAccess.rename_absolute(temp_path, path)
	if commit_error != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_path, path)
		DirAccess.remove_absolute(temp_path)
		push_warning("[GFRemoteCacheUtility] 写入缓存失败：%s" % cache_key)
		return commit_error

	DirAccess.remove_absolute(backup_path)
	_prune_cache()
	return OK


func _prune_cache() -> void:
	var max_entries := maxi(max_cache_entries, 1)
	var dir_path := _get_cache_dir_path()
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return

	var entries: Array[Dictionary] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.ends_with(".cache"):
			var path := "%s/%s" % [dir_path, file_name]
			entries.append({
				"path": path,
				"modified_time": FileAccess.get_modified_time(path),
			})
		elif not dir.current_is_dir() and (file_name.ends_with(".cache.tmp") or file_name.ends_with(".cache.bak")):
			DirAccess.remove_absolute("%s/%s" % [dir_path, file_name])
		file_name = dir.get_next()
	dir.list_dir_end()

	if entries.size() <= max_entries:
		return

	entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return int(left["modified_time"]) < int(right["modified_time"])
	)

	while entries.size() > max_entries:
		var entry := entries.pop_front() as Dictionary
		DirAccess.remove_absolute(String(entry["path"]))


# --- 信号处理函数 ---

func _on_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	var content := body.get_string_from_utf8()
	if result != HTTPRequest.RESULT_SUCCESS:
		_complete_active_request(false, response_code, content, "HTTP request result: %d" % result)
		return

	if response_code < 200 or response_code >= 300:
		_complete_active_request(false, response_code, content, "HTTP %d: %s" % [response_code, content])
		return

	_complete_active_request(true, response_code, content, "")
