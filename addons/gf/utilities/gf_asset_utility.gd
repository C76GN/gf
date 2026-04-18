# addons/gf/utilities/gf_asset_utility.gd

## GFAssetUtility: 异步资源加载管理器，带 LRU 缓存淘汰。
##
## 继承自 GFUtility，封装 Godot 的 ResourceLoader.load_threaded_request
## 提供简洁、易用的异步资源加载接口，避免在主线程阻塞大型资源（如场景、音频、图集）。
##
## LRU 缓存管理：
##   已加载的资源会被缓存。当缓存超出 max_cache_size 时，
##   最近最少使用的资源将被自动淘汰以节省内存。
##   调用 get_cached(path) 可从缓存中获取已加载的资源并刷新其访问顺序。
##
## 工作流程：
##   1. 调用 load_async(path, callback) 发起后台加载请求。
##   2. 内部在每帧轮询 ResourceLoader.load_threaded_get_status()。
##   3. 加载完成时，资源自动进入 LRU 缓存，并通过 callback 回传给调用方。
##
## 注意：宿主节点需每帧调用 tick() 以驱动轮询，
## 或者将此 Utility 连接到一个有 _process 能力的节点。
class_name GFAssetUtility
extends GFUtility


# --- 公共变量 ---

## LRU 缓存最大容量。超出时自动淘汰最久未使用的资源。
## 设为 0 表示禁用缓存。
var max_cache_size: int = 64


# --- 私有变量 ---

## 正在加载中的请求字典。Key 为资源路径，Value 为回调函数列表。
var _pending: Dictionary = {}

## LRU 缓存字典。Key 为资源路径 (String)，Value 为 Resource。
var _cache: Dictionary = {}

## LRU 访问顺序列表。尾部为最近访问，头部为最久未访问。
var _cache_order: Array[String] = []


# --- Godot 生命周期方法 ---

## 第一阶段初始化：清空待加载队列和缓存。
func init() -> void:
	_pending = {}
	_cache.clear()
	_cache_order.clear()


## 销毁阶段：清理所有状态。
func dispose() -> void:
	_pending.clear()
	_cache.clear()
	_cache_order.clear()


# --- 公共方法 ---

## 发起一个异步资源加载请求。加载完成后将自动调用 on_loaded 回调。
## 若资源已在缓存中，则直接从缓存取出并回调，不发起后台加载。
## @param path: 要加载的资源路径（res://...）。
## @param on_loaded: 加载完成后的回调，签名为 func(resource: Resource)。
## @param type_hint: 可选的资源类型提示字符串，提升加载性能。
func load_async(path: String, on_loaded: Callable, type_hint: String = "") -> void:
	if path.is_empty() or not on_loaded.is_valid():
		push_error("[GFAssetUtility] 无效的路径或回调函数。")
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

	var error: Error
	if type_hint.is_empty():
		error = ResourceLoader.load_threaded_request(path)
	else:
		error = ResourceLoader.load_threaded_request(path, type_hint)

	if error != OK:
		push_error("[GFAssetUtility] 无法发起异步加载请求，路径：%s (错误码：%d)" % [path, error])
		return

	_pending[path] = [on_loaded]


## 驱动异步加载轮询。宿主的 _process() 中应调用此方法（或通过信号连接）。
## @param _delta: 传入 _process(delta) 的帧时间（此处不使用，保持签名统一）。
func tick(_delta: float = 0.0) -> void:
	_poll_pending()


## 从 LRU 缓存中获取已加载的资源，并刷新其访问顺序。
## @param path: 资源路径。
## @return 缓存中的资源，如果未缓存则返回 null。
func get_cached(path: String) -> Resource:
	if _cache.has(path):
		_touch_cache(path)
		return _cache[path]
	return null


## 检查指定路径是否正在异步加载中。
## @param path: 要查询的资源路径。
## @return 正在加载中返回 true。
func is_loading(path: String) -> bool:
	return _pending.has(path)


## 检查指定路径是否已在缓存中。
## @param path: 要查询的资源路径。
## @return 已缓存返回 true。
func is_cached(path: String) -> bool:
	return _cache.has(path)


## 取消指定路径的异步加载请求（若尚未完成）。
## @param path: 要取消的资源路径。
func cancel(path: String) -> void:
	_pending.erase(path)


## 手动将资源放入 LRU 缓存。
## @param path: 资源路径。
## @param resource: 资源实例。
func put_cache(path: String, resource: Resource) -> void:
	if max_cache_size <= 0:
		return
	_cache[path] = resource
	_touch_cache(path)
	_evict_lru()


## 手动从缓存中移除指定路径的资源。
## @param path: 要移除的资源路径。
func remove_cache(path: String) -> void:
	_cache.erase(path)
	_cache_order.erase(path)


## 清空 LRU 缓存。
func clear_cache() -> void:
	_cache.clear()
	_cache_order.clear()


## 获取当前缓存中的资源数量。
## @return 缓存的资源数。
func get_cache_count() -> int:
	return _cache.size()


# --- 私有/辅助方法 ---

## 轮询所有待加载请求的状态，完成后加入缓存并调用回调。
func _poll_pending() -> void:
	if _pending.is_empty():
		return

	var completed_paths: Array[String] = []

	for path in _pending:
		var status := ResourceLoader.load_threaded_get_status(path)

		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				var resource: Resource = ResourceLoader.load_threaded_get(path)
				var callbacks := (_pending[path] as Array).duplicate()
				completed_paths.append(path)

				put_cache(path, resource)

				for callback: Callable in callbacks:
					if callback.is_valid():
						callback.call(resource)

			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("[GFAssetUtility] 异步加载失败，路径：%s" % path)
				completed_paths.append(path)

			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("[GFAssetUtility] 无效资源，路径：%s" % path)
				completed_paths.append(path)

	for path in completed_paths:
		_pending.erase(path)


## 刷新指定路径在 LRU 访问顺序中的位置（移至尾部，标记为最近使用）。
## @param path: 资源路径。
func _touch_cache(path: String) -> void:
	_cache_order.erase(path)
	_cache_order.append(path)


## 当缓存超出容量时，淘汰最久未使用的资源。
func _evict_lru() -> void:
	while _cache_order.size() > max_cache_size and max_cache_size > 0:
		var oldest_path: String = _cache_order[0]
		_cache_order.remove_at(0)
		_cache.erase(oldest_path)
