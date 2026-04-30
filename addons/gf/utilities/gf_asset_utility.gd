## GFAssetUtility: 异步资源加载管理器，带 LRU 缓存。
##
## 封装 Godot 的 threaded `ResourceLoader` 请求，
## 用于避免大资源同步加载阻塞主线程，并在完成后统一分发回调与维护缓存。
class_name GFAssetUtility
extends GFUtility


# --- 公共变量 ---

## LRU 缓存最大容量；设为 `0` 时表示禁用缓存。
var max_cache_size: int:
	get:
		return _max_cache_size
	set(value):
		_max_cache_size = maxi(value, 0)
		if _max_cache_size == 0:
			clear_cache()
			return

		_evict_lru()


# --- 私有变量 ---

var _max_cache_size: int = 64

## 正在加载中的请求：`path -> { type_hint: String, callbacks: Array[Callable], cancelled: bool }`。
var _pending: Dictionary = {}

## 资源缓存：`path -> Resource`。
var _cache: Dictionary = {}

## LRU 访问序号，数值越大表示越新。
var _cache_access_order: Dictionary = {}
var _cache_access_serial: int = 0


# --- Godot 生命周期方法 ---

func init() -> void:
	ignore_pause = true
	_pending = {}
	_cache.clear()
	_cache_access_order.clear()
	_cache_access_serial = 0


func dispose() -> void:
	_pending.clear()
	_cache.clear()
	_cache_access_order.clear()
	_cache_access_serial = 0


# --- 公共方法 ---

## 发起异步资源加载。
## @param path: 目标资源路径。
## @param on_loaded: 加载完成后的回调。
## @param type_hint: 可选资源类型提示。
func load_async(path: String, on_loaded: Callable, type_hint: String = "") -> void:
	if path.is_empty() or not on_loaded.is_valid():
		push_error("[GFAssetUtility] 无效的路径或回调。")
		return

	var cached: Resource = get_cached(path)
	if cached != null:
		if not _is_resource_compatible(cached, type_hint):
			push_warning("[GFAssetUtility] 缓存资源类型与请求 type_hint 不匹配：%s (%s)" % [path, type_hint])
			on_loaded.call(null)
			return

		on_loaded.call(cached)
		return

	if _pending.has(path):
		var pending_request := _pending[path] as Dictionary
		var pending_type_hint := String(pending_request.get("type_hint", ""))
		if not _pending_type_hints_are_compatible(pending_type_hint, type_hint):
			push_warning("[GFAssetUtility] 已存在相同路径但 type_hint 不同的加载请求，已拒绝新请求：%s (%s -> %s)" % [path, pending_type_hint, type_hint])
			on_loaded.call(null)
			return

		var callbacks := pending_request.get("callbacks", []) as Array
		if bool(pending_request.get("cancelled", false)):
			callbacks.clear()
			pending_request["cancelled"] = false
		if not _callback_entries_have_callable(callbacks, on_loaded):
			callbacks.append(_make_callback_entry(on_loaded, type_hint))
		return

	var error := _request_threaded(path, type_hint)
	if error != OK:
		push_error("[GFAssetUtility] 无法发起异步加载请求：%s (错误码：%d)" % [path, error])
		on_loaded.call(null)
		return

	_pending[path] = {
		"type_hint": type_hint,
		"callbacks": [_make_callback_entry(on_loaded, type_hint)],
		"cancelled": false,
	}


## 驱动异步加载轮询。
## @param _delta: 为兼容统一 tick 签名而保留的参数。
func tick(_delta: float = 0.0) -> void:
	_poll_pending()


## 获取缓存中的资源。
## @param path: 资源路径。
## @return 命中缓存时返回资源，否则返回 `null`。
func get_cached(path: String) -> Resource:
	if _cache.has(path):
		_touch_cache(path)
		return _cache[path]

	return null


## 检查指定路径是否正在加载中。
## @param path: 资源路径。
## @param type_hint: 可选资源类型提示；为空时只检查路径。
## @return 正在加载时返回 `true`。
func is_loading(path: String, type_hint: String = "") -> bool:
	if not _pending.has(path):
		return false
	var pending_request := _pending[path] as Dictionary
	if bool(pending_request.get("cancelled", false)):
		return false
	if type_hint.is_empty():
		return true

	return String(pending_request.get("type_hint", "")) == type_hint


## 检查指定路径是否已缓存。
## @param path: 资源路径。
## @return 已缓存时返回 `true`。
func is_cached(path: String) -> bool:
	return _cache.has(path)


## 取消指定路径的异步加载请求。
## @param path: 资源路径。
## @param type_hint: 可选资源类型提示；为空时取消该路径的当前请求。
func cancel(path: String, type_hint: String = "") -> void:
	if not _pending.has(path):
		return

	var pending_request := _pending[path] as Dictionary
	var pending_type_hint := String(pending_request.get("type_hint", ""))
	if not type_hint.is_empty() and pending_type_hint != type_hint:
		return

	var callbacks := pending_request.get("callbacks", []) as Array
	callbacks.clear()
	pending_request["cancelled"] = true


## 手动写入缓存。
## @param path: 资源路径。
## @param resource: 要缓存的资源实例。
func put_cache(path: String, resource: Resource) -> void:
	if max_cache_size <= 0:
		return

	_cache[path] = resource
	_touch_cache(path)
	_evict_lru()


## 手动移除缓存项。
## @param path: 资源路径。
func remove_cache(path: String) -> void:
	_cache.erase(path)
	_cache_access_order.erase(path)


## 清空全部缓存。
func clear_cache() -> void:
	_cache.clear()
	_cache_access_order.clear()
	_cache_access_serial = 0


## 获取当前缓存数量。
## @return 当前缓存中的资源数。
func get_cache_count() -> int:
	return _cache.size()


# --- 私有/辅助方法 ---

func _poll_pending() -> void:
	if _pending.is_empty():
		return

	var pending_paths: Array = _pending.keys()
	for path: String in pending_paths:
		if not _pending.has(path):
			continue

		var pending_request := _pending[path] as Dictionary
		var callbacks := (pending_request.get("callbacks", []) as Array).duplicate()
		var cancelled := bool(pending_request.get("cancelled", false))
		var status := _get_threaded_status(path)

		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				var resource := _take_threaded_resource(path)
				_pending.erase(path)
				if resource != null:
					put_cache(path, resource)
				if not cancelled:
					_dispatch_callbacks(callbacks, resource)

			ResourceLoader.THREAD_LOAD_FAILED:
				_pending.erase(path)
				if not cancelled:
					push_error("[GFAssetUtility] 异步加载失败：%s" % path)
					_dispatch_callbacks(callbacks, null)

			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				_pending.erase(path)
				if not cancelled:
					push_error("[GFAssetUtility] 无效资源：%s" % path)
					_dispatch_callbacks(callbacks, null)


func _dispatch_callbacks(callbacks: Array, resource: Resource) -> void:
	for callback_entry: Variant in callbacks:
		var entry := callback_entry as Dictionary
		var callback: Callable = Callable()
		var type_hint := ""
		if entry != null:
			callback = entry.get("callable", Callable())
			type_hint = String(entry.get("type_hint", ""))
		elif callback_entry is Callable:
			callback = callback_entry as Callable
		if callback.is_valid():
			callback.call(resource if resource == null or _is_resource_compatible(resource, type_hint) else null)


func _is_resource_compatible(resource: Resource, type_hint: String) -> bool:
	return type_hint.is_empty() or resource.is_class(type_hint)


func _pending_type_hints_are_compatible(pending_type_hint: String, requested_type_hint: String) -> bool:
	return (
		pending_type_hint == requested_type_hint
		or pending_type_hint.is_empty()
		or requested_type_hint.is_empty()
	)


func _make_callback_entry(callback: Callable, type_hint: String) -> Dictionary:
	return {
		"callable": callback,
		"type_hint": type_hint,
	}


func _callback_entries_have_callable(callbacks: Array, callback: Callable) -> bool:
	for callback_entry: Variant in callbacks:
		var entry := callback_entry as Dictionary
		if entry != null and entry.get("callable", Callable()) == callback:
			return true
		if callback_entry is Callable and callback_entry == callback:
			return true
	return false


func _touch_cache(path: String) -> void:
	_cache_access_serial += 1
	_cache_access_order[path] = _cache_access_serial


func _evict_lru() -> void:
	while _cache.size() > max_cache_size and max_cache_size > 0:
		var oldest_path := _get_oldest_cached_path()
		if not _cache.has(oldest_path):
			return

		_cache.erase(oldest_path)
		_cache_access_order.erase(oldest_path)


func _get_oldest_cached_path() -> String:
	var oldest_path := ""
	var oldest_access := 0
	var has_oldest := false
	for path: String in _cache:
		var access := int(_cache_access_order.get(path, 0))
		if not has_oldest or access < oldest_access:
			oldest_path = path
			oldest_access = access
			has_oldest = true

	return oldest_path


func _request_threaded(path: String, type_hint: String) -> Error:
	if type_hint.is_empty():
		return ResourceLoader.load_threaded_request(path)

	return ResourceLoader.load_threaded_request(path, type_hint)


func _get_threaded_status(path: String) -> ResourceLoader.ThreadLoadStatus:
	return ResourceLoader.load_threaded_get_status(path)


func _take_threaded_resource(path: String) -> Resource:
	return ResourceLoader.load_threaded_get(path)
