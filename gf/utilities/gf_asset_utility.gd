# gf/utilities/gf_asset_utility.gd

## GFAssetUtility: 异步资源加载管理器。
##
## 继承自 GFUtility，封装 Godot 的 ResourceLoader.load_threaded_request
## 提供简洁、易用的异步资源加载接口，避免在主线程阻塞大型资源（如场景、音频、图集）。
##
## 工作流程：
##   1. 调用 load_async(path, callback) 发起后台加载请求。
##   2. 内部在每帧轮询 ResourceLoader.load_threaded_get_status()。
##   3. 加载完成时，通过 callback 将资源实例回传给调用方。
##
## 注意：宿主节点需每帧调用 tick() 以驱动轮询，
## 或者将此 Utility 连接到一个有 _process 能力的节点。
class_name GFAssetUtility
extends GFUtility


# --- 私有变量 ---

## 正在加载中的请求字典。Key 为资源路径，Value 为回调函数 (Callable)。
var _pending: Dictionary = {}


# --- Godot 生命周期方法 ---

## 第一阶段初始化：清空待加载队列。
func init() -> void:
	_pending = {}


## 销毁阶段：清理所有未完成的加载请求（不会中断后台线程，Godot 会自动管理）。
func dispose() -> void:
	_pending.clear()


# --- 公共方法 ---

## 发起一个异步资源加载请求。加载完成后将自动调用 on_loaded 回调。
## @param path: 要加载的资源路径（res://...）。
## @param on_loaded: 加载完成后的回调，签名为 func(resource: Resource)。
## @param type_hint: 可选的资源类型提示字符串，提升加载性能。
func load_async(path: String, on_loaded: Callable, type_hint: String = "") -> void:
	if path.is_empty() or not on_loaded.is_valid():
		push_error("[GFAssetUtility] 无效的路径或回调函数。")
		return

	if _pending.has(path):
		return

	var error: Error
	if type_hint.is_empty():
		error = ResourceLoader.load_threaded_request(path)
	else:
		error = ResourceLoader.load_threaded_request(path, type_hint)

	if error != OK:
		push_error("[GFAssetUtility] 无法发起异步加载请求，路径：%s (错误码：%d)" % [path, error])
		return

	_pending[path] = on_loaded


## 驱动异步加载轮询。宿主的 _process() 中应调用此方法（或通过信号连接）。
## @param _delta: 传入 _process(delta) 的帧时间（此处不使用，保持签名统一）。
func tick(_delta: float = 0.0) -> void:
	_poll_pending()


## 检查指定路径是否正在异步加载中。
## @param path: 要查询的资源路径。
## @return 正在加载中返回 true。
func is_loading(path: String) -> bool:
	return _pending.has(path)


## 取消指定路径的异步加载请求（若尚未完成）。
## @param path: 要取消的资源路径。
func cancel(path: String) -> void:
	_pending.erase(path)


# --- 私有/辅助方法 ---

## 轮询所有待加载请求的状态，完成后调用回调并清理。
func _poll_pending() -> void:
	if _pending.is_empty():
		return

	var completed_paths: Array[String] = []

	for path in _pending:
		var status := ResourceLoader.load_threaded_get_status(path)

		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				var resource: Resource = ResourceLoader.load_threaded_get(path)
				var callback: Callable = _pending[path]
				completed_paths.append(path)

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
