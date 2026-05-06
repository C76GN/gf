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
func has_valid_cache(url: String, ttl_seconds: int = -1) -> bool:
	if url.is_empty():
		return false

	var path := _get_cache_path(url)
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
func get_cached_text(url: String, ttl_seconds: int = -1) -> String:
	if not has_valid_cache(url, ttl_seconds):
		return ""
	return _read_cache_text(url)


## 移除指定 URL 的缓存。
## @param url: 远程资源 URL。
func remove_cache(url: String) -> Error:
	var path := _get_cache_path(url)
	if not FileAccess.file_exists(path):
		return OK
	return DirAccess.remove_absolute(path)


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
	if not force_refresh and has_valid_cache(url, ttl):
		var cached_result := _build_success(url, _read_cache_text(url), true, false, 200, format)
		_finish_immediate(callback, cached_result)
		return

	_pending_requests.append({
		"url": url,
		"callback": callback,
		"ttl_seconds": ttl,
		"headers": headers,
		"format": format,
	})
	_process_next_request()


func _process_next_request() -> void:
	if not _active_request.is_empty() or _pending_requests.is_empty():
		return

	_active_request = _pending_requests.pop_front()
	var error := _start_http_request(_active_request)
	if error != OK:
		_complete_active_request(false, 0, "", "Request failed: %s" % error_string(error))


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
	var callback := request_data["callback"] as Callable
	var result: Dictionary

	if success:
		_write_cache_text(url, content)
		result = _build_success(url, content, false, false, response_code, format)
	else:
		result = _build_failure(url, response_code, error)
		if _has_cache_file(url):
			result = _build_success(url, _read_cache_text(url), true, true, response_code, format)
			result["error"] = error

	_finish_immediate(callback, result)
	_process_next_request()


func _finish_immediate(callback: Callable, result: Dictionary) -> void:
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


func _get_cache_path(url: String) -> String:
	return "%s/%s.cache" % [_get_cache_dir_path(), url.md5_text()]


func _has_cache_file(url: String) -> bool:
	return FileAccess.file_exists(_get_cache_path(url))


func _read_cache_text(url: String) -> String:
	var file := FileAccess.open(_get_cache_path(url), FileAccess.READ)
	if file == null:
		return ""

	var content := file.get_as_text()
	file.close()
	return content


func _write_cache_text(url: String, content: String) -> void:
	_ensure_cache_dir()
	var file := FileAccess.open(_get_cache_path(url), FileAccess.WRITE)
	if file == null:
		push_warning("[GFRemoteCacheUtility] 写入缓存失败：%s" % url)
		return

	file.store_string(content)
	file.close()
	_prune_cache()


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
