## GFNotificationUtility: 通用运行时通知队列。
##
## 只管理通知数据、队列、去重和生命周期信号，不规定 Toast、HUD 或编辑器 UI 样式。
class_name GFNotificationUtility
extends GFUtility


# --- 信号 ---

## 通知进入队列时发出。
signal notification_queued(notification: Dictionary)

## 通知开始展示时发出。
signal notification_started(notification: Dictionary)

## 通知结束时发出。
signal notification_finished(notification: Dictionary, reason: String)


# --- 枚举 ---

## 通知等级。
enum Level {
	INFO,
	SUCCESS,
	WARNING,
	ERROR,
}


# --- 公共变量 ---

## 默认展示时长。
var default_duration_seconds: float = 3.0

## 最大排队数量。
var max_queue_size: int = 32

## 是否抑制同 key 或同消息重复入队。
var suppress_duplicates: bool = true


# --- 私有变量 ---

var _queue: Array[Dictionary] = []
var _active_notification: Dictionary = {}
var _active_remaining_seconds: float = 0.0
var _next_notification_id: int = 1


# --- Godot 生命周期方法 ---

func tick(delta: float) -> void:
	if _active_notification.is_empty():
		_start_next_notification()
		return

	_active_remaining_seconds -= maxf(delta, 0.0)
	if _active_remaining_seconds <= 0.0:
		dismiss_active("timeout")


func dispose() -> void:
	clear_notifications("disposed")


# --- 公共方法 ---

## 推入通知。
## @param message: 通知正文。
## @param title: 通知标题。
## @param level: 通知等级。
## @param options: 可选参数，支持 duration_seconds、key、metadata。
## @return 通知 id；被去重抑制时返回已有通知 id。
func push_notification(
	message: String,
	title: String = "",
	level: Level = Level.INFO,
	options: Dictionary = {}
) -> int:
	if message.is_empty() and title.is_empty():
		return 0

	var duplicate_id := _find_duplicate_notification_id(message, options)
	if suppress_duplicates and duplicate_id > 0:
		return duplicate_id

	var notification := _make_notification(message, title, level, options)
	_queue.append(notification)
	_trim_queue()
	notification_queued.emit(notification.duplicate(true))
	if _active_notification.is_empty():
		_start_next_notification()
	return int(notification["id"])


## 结束当前通知。
## @param reason: 结束原因。
func dismiss_active(reason: String = "dismissed") -> void:
	if _active_notification.is_empty():
		return

	var finished := _active_notification.duplicate(true)
	_active_notification.clear()
	_active_remaining_seconds = 0.0
	notification_finished.emit(finished, reason)
	_start_next_notification()


## 清空当前通知和等待队列。
## @param reason: 结束原因。
func clear_notifications(reason: String = "cleared") -> void:
	if not _active_notification.is_empty():
		var finished := _active_notification.duplicate(true)
		notification_finished.emit(finished, reason)
	_active_notification.clear()
	_active_remaining_seconds = 0.0
	_queue.clear()


## 获取当前通知。
## @return 当前通知副本。
func get_active_notification() -> Dictionary:
	return _active_notification.duplicate(true)


## 获取等待队列。
## @return 通知副本数组。
func get_queue() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for notification: Dictionary in _queue:
		result.append(notification.duplicate(true))
	return result


## 获取调试快照。
## @return 通知队列状态。
func get_debug_snapshot() -> Dictionary:
	return {
		"active": get_active_notification(),
		"queue": get_queue(),
		"queue_size": _queue.size(),
		"active_remaining_seconds": _active_remaining_seconds,
		"max_queue_size": max_queue_size,
	}


# --- 私有/辅助方法 ---

func _make_notification(
	message: String,
	title: String,
	level: Level,
	options: Dictionary
) -> Dictionary:
	var metadata_variant: Variant = options.get("metadata", {})
	var metadata := (metadata_variant as Dictionary).duplicate(true) if metadata_variant is Dictionary else {}
	var notification := {
		"id": _next_notification_id,
		"key": String(options.get("key", message)),
		"title": title,
		"message": message,
		"level": level,
		"duration_seconds": maxf(float(options.get("duration_seconds", default_duration_seconds)), 0.0),
		"created_at_unix": Time.get_unix_time_from_system(),
		"metadata": metadata,
	}
	_next_notification_id += 1
	return notification


func _start_next_notification() -> void:
	if not _active_notification.is_empty() or _queue.is_empty():
		return

	_active_notification = _queue.pop_front()
	_active_remaining_seconds = float(_active_notification.get("duration_seconds", default_duration_seconds))
	notification_started.emit(_active_notification.duplicate(true))
	if _active_remaining_seconds <= 0.0:
		dismiss_active("timeout")


func _trim_queue() -> void:
	var max_size := maxi(max_queue_size, 1)
	while _queue.size() > max_size:
		var dropped := _queue.pop_front()
		notification_finished.emit(dropped.duplicate(true), "dropped")


func _find_duplicate_notification_id(message: String, options: Dictionary) -> int:
	var key := String(options.get("key", message))
	if _matches_notification(_active_notification, key, message):
		return int(_active_notification.get("id", 0))

	for notification: Dictionary in _queue:
		if _matches_notification(notification, key, message):
			return int(notification.get("id", 0))
	return 0


func _matches_notification(notification: Dictionary, key: String, message: String) -> bool:
	if notification.is_empty():
		return false
	return String(notification.get("key", "")) == key or String(notification.get("message", "")) == message
