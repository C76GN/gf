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

## 正在加载中的请求：`path -> Array[Callable]`。
var _pending: Dictionary = {}

## 资源缓存：`path -> Resource`。
var _cache: Dictionary = {}

## LRU 访问顺序，尾部表示最近使用。
var _cache_order: Array[String] = []


# --- Godot 生命周期方法 ---

func init() -> void:
	_pending = {}
	_cache.clear()
	_cache_order.clear()


func dispose() -> void:
	_pending.clear()
	_cache.clear()
	_cache_order.clear()


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
		on_loaded.call(cached)
		return

	if _pending.has(path):
		var callbacks := _pending[path] as Array
		if not callbacks.has(on_loaded):
			callbacks.append(on_loaded)
		return

	var error := _request_threaded(path, type_hint)
	if error != OK:
		push_error("[GFAssetUtility] 无法发起异步加载请求：%s (错误码：%d)" % [path, error])
		on_loaded.call(null)
		return

	_pending[path] = [on_loaded]


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
## @return 正在加载时返回 `true`。
func is_loading(path: String) -> bool:
	return _pending.has(path)


## 检查指定路径是否已缓存。
## @param path: 资源路径。
## @return 已缓存时返回 `true`。
func is_cached(path: String) -> bool:
	return _cache.has(path)


## 取消指定路径的异步加载请求。
## @param path: 资源路径。
func cancel(path: String) -> void:
	_pending.erase(path)


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
	_cache_order.erase(path)


## 清空全部缓存。
func clear_cache() -> void:
	_cache.clear()
	_cache_order.clear()


## 获取当前缓存数量。
## @return 当前缓存中的资源数。
func get_cache_count() -> int:
	return _cache.size()


# --- 私有/辅助方法 ---

func _poll_pending() -> void:
	if _pending.is_empty():
		return

	var completed_paths: Array[String] = []

	for path in _pending:
		var callbacks := (_pending[path] as Array).duplicate()
		var status := _get_threaded_status(path)

		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				var resource := _take_threaded_resource(path)
				completed_paths.append(path)
				put_cache(path, resource)
				_dispatch_callbacks(callbacks, resource)

			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("[GFAssetUtility] 异步加载失败：%s" % path)
				completed_paths.append(path)
				_dispatch_callbacks(callbacks, null)

			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("[GFAssetUtility] 无效资源：%s" % path)
				completed_paths.append(path)
				_dispatch_callbacks(callbacks, null)

	for path in completed_paths:
		_pending.erase(path)


func _dispatch_callbacks(callbacks: Array, resource: Resource) -> void:
	for callback: Callable in callbacks:
		if callback.is_valid():
			callback.call(resource)


func _touch_cache(path: String) -> void:
	_cache_order.erase(path)
	_cache_order.append(path)


func _evict_lru() -> void:
	while _cache_order.size() > max_cache_size and max_cache_size > 0:
		var oldest_path: String = _cache_order[0]
		_cache_order.remove_at(0)
		_cache.erase(oldest_path)


func _request_threaded(path: String, type_hint: String) -> Error:
	if type_hint.is_empty():
		return ResourceLoader.load_threaded_request(path)

	return ResourceLoader.load_threaded_request(path, type_hint)


func _get_threaded_status(path: String) -> ResourceLoader.ThreadLoadStatus:
	return ResourceLoader.load_threaded_get_status(path)


func _take_threaded_resource(path: String) -> Resource:
	return ResourceLoader.load_threaded_get(path)
