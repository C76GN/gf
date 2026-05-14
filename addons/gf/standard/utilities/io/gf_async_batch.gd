## GFAsyncBatch: 通用异步结果批处理器。
##
## 用于等待一组 GFHttpResponse 或手动标记的异步任务完成，并统一汇总结果。
## 它不负责调度具体任务，只观察任务何时完成。
class_name GFAsyncBatch
extends RefCounted


# --- 信号 ---

## 单个条目完成后发出。
## @param key: 条目标识。
## @param result: 条目结果。
signal item_completed(key: Variant, result: Variant)

## 全部条目完成后发出。
## @param results: 批处理结果字典。
signal completed(results: Dictionary)


# --- 常量 ---

const GFHttpResponseBase = preload("res://addons/gf/standard/utilities/io/gf_http_response.gd")


# --- 私有变量 ---

var _items: Dictionary = {}
var _completed: bool = false
var _watched_responses: Dictionary = {}


# --- 公共方法 ---

## 添加一个等待条目。
## @param key: 条目标识。
## @param metadata: 条目元数据。
## @return 是否添加成功。
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
## @param response: 响应对象。
## @param key: 条目标识；为空时使用响应 URL。
## @return 是否开始监听。
func watch_response(response: GFHttpResponseBase, key: Variant = null) -> bool:
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
## @param key: 条目标识。
## @param result: 条目结果。
## @return 是否成功标记。
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
func is_completed() -> bool:
	return _completed


## 获取条目数量。
func get_count() -> int:
	return _items.size()


## 获取已完成条目数量。
func get_completed_count() -> int:
	var count := 0
	for item_variant: Variant in _items.values():
		var item := item_variant as Dictionary
		if item != null and bool(item.get("done", false)):
			count += 1
	return count


## 获取结果字典。
## @return key -> result 的字典副本。
func get_results() -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in _items.keys():
		var item := _items[key] as Dictionary
		result[key] = item.get("result") if item != null else null
	return result


## 清空批处理。
func clear() -> void:
	_disconnect_all_watched_responses()
	_items.clear()
	_completed = false


## 获取调试快照。
## @return 调试信息字典。
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

	var response := entry.get("response") as GFHttpResponseBase
	var callback := entry.get("callback", Callable()) as Callable
	if response != null and callback.is_valid() and response.completed.is_connected(callback):
		response.completed.disconnect(callback)


func _disconnect_all_watched_responses() -> void:
	for key: Variant in _watched_responses.keys():
		_disconnect_watched_response(key)
	_watched_responses.clear()


# --- 信号处理函数 ---

func _on_response_completed(response: GFHttpResponseBase, key: Variant) -> void:
	_disconnect_watched_response(key)
	mark_completed(key, response)
