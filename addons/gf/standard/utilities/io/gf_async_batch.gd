## GFAsyncBatch: 通用异步结果批处理器。
##
## 用于等待一组 GFHttpResponse 或手动标记的异步任务完成，并统一汇总结果。
## 它不负责调度具体任务，只观察任务何时完成。
## [br]
## @api public
## [br]
## @category runtime_handle
## [br]
## @since 3.17.0
class_name GFAsyncBatch
extends RefCounted


# --- 信号 ---

## 单个条目完成后发出。
## [br]
## @api public
## [br]
## @param key: 条目标识。
## [br]
## @param result: 条目结果。
## [br]
## @schema key: Variant，调用方持有的条目标识，会作为结果字典的键。
## [br]
## @schema result: Variant，已完成条目的结果。
signal item_completed(key: Variant, result: Variant)

## 全部条目完成后发出。
## [br]
## @api public
## [br]
## @param results: 批处理结果字典。
## [br]
## @schema results: Dictionary，将每个被等待的 key 映射到对应完成结果。
signal completed(results: Dictionary)


# --- 私有变量 ---

var _items: Dictionary = {}
var _completed: bool = false
var _watched_responses: Dictionary = {}


# --- 公共方法 ---

## 添加一个等待条目。
## [br]
## @api public
## [br]
## @param key: 条目标识。
## [br]
## @param metadata: 条目元数据。
## [br]
## @return 是否添加成功。
## [br]
## @schema key: Variant，调用方持有的条目标识，会作为结果字典的键。
## [br]
## @schema metadata: Dictionary，调用方持有并关联到该条目的元数据。
func add_item(key: Variant, metadata: Dictionary = {}) -> bool:
	if _items.has(key):
		return false
	if _completed:
		return false

	_items[key] = {
		"done": false,
		"result": null,
		"metadata": metadata.duplicate(true),
	}
	return true


## 监听 GFHttpResponse。
## [br]
## @api public
## [br]
## @param response: 响应对象。
## [br]
## @param key: 条目标识；为空时使用响应 URL。
## [br]
## @return 是否开始监听。
## [br]
## @schema key: Variant，调用方持有的条目标识；为 null 时使用 response.url。
func watch_response(response: GFHttpResponse, key: Variant = null) -> bool:
	if response == null:
		return false

	var item_key: Variant = key
	if item_key == null:
		item_key = response.url
	if not add_item(item_key, response.metadata):
		return false

	if response.is_finished():
		mark_completed(item_key, response)
	else:
		var callback := _on_response_completed.bind(item_key)
		_watched_responses[item_key] = {
			"response": response,
			"callback": callback,
		}
		response.completed.connect(callback, CONNECT_ONE_SHOT)
	return true


## 手动标记条目完成。
## [br]
## @api public
## [br]
## @param key: 条目标识。
## [br]
## @param result: 条目结果。
## [br]
## @return 是否成功标记。
## [br]
## @schema key: Variant，调用方持有的条目标识，会作为结果字典的键。
## [br]
## @schema result: Variant，已完成条目的结果。
func mark_completed(key: Variant, result: Variant = null) -> bool:
	if not _items.has(key):
		return false

	var item := _items[key] as Dictionary
	if bool(item.get("done", false)):
		return false

	item["done"] = true
	item["result"] = result
	_items[key] = item
	_disconnect_watched_response(key)
	item_completed.emit(key, result)
	_emit_completed_if_ready()
	return true


## 是否所有条目都已完成。
## [br]
## @api public
## [br]
## @return 所有条目完成时返回 true。
func is_completed() -> bool:
	return _completed


## 获取条目数量。
## [br]
## @api public
## [br]
## @return 当前批处理中的条目数量。
func get_count() -> int:
	return _items.size()


## 获取已完成条目数量。
## [br]
## @api public
## [br]
## @return 已完成条目的数量。
func get_completed_count() -> int:
	var count := 0
	for item_variant: Variant in _items.values():
		var item := item_variant as Dictionary
		if item != null and bool(item.get("done", false)):
			count += 1
	return count


## 获取结果字典。
## [br]
## @api public
## [br]
## @return key -> result 的字典副本。
## [br]
## @schema return: Dictionary，将每个被等待的 key 映射到对应完成结果或 null。
func get_results() -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in _items.keys():
		var item := _items[key] as Dictionary
		result[key] = item.get("result") if item != null else null
	return result


## 清空批处理。
## [br]
## @api public
func clear() -> void:
	_disconnect_all_watched_responses()
	_items.clear()
	_completed = false


## 获取调试快照。
## [br]
## @api public
## [br]
## @return 调试信息字典。
## [br]
## @schema return: Dictionary，包含 count、completed_count、completed 和 keys。
func get_debug_snapshot() -> Dictionary:
	return {
		"count": get_count(),
		"completed_count": get_completed_count(),
		"completed": _completed,
		"keys": _items.keys(),
	}


# --- 私有/辅助方法 ---

func _emit_completed_if_ready() -> void:
	if _completed:
		return
	if _items.is_empty():
		return
	if get_completed_count() != _items.size():
		return

	_completed = true
	completed.emit(get_results())


func _disconnect_watched_response(key: Variant) -> void:
	var entry := _watched_responses.get(key, {}) as Dictionary
	_watched_responses.erase(key)
	if entry == null or entry.is_empty():
		return

	var response := entry.get("response") as GFHttpResponse
	var callback := entry.get("callback", Callable()) as Callable
	if response != null and callback.is_valid() and response.completed.is_connected(callback):
		response.completed.disconnect(callback)


func _disconnect_all_watched_responses() -> void:
	for key: Variant in _watched_responses.keys():
		_disconnect_watched_response(key)
	_watched_responses.clear()


# --- 信号处理函数 ---

func _on_response_completed(response: GFHttpResponse, key: Variant) -> void:
	_disconnect_watched_response(key)
	mark_completed(key, response)
