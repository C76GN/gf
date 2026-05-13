## GFBatchedLogSink: 结构化日志批量转发 sink。
##
## 该 sink 只负责清洗、缓冲和分批，把实际传输交给 sender_callback 或 batch_ready 信号。
## 它不绑定任何远端服务、HTTP 协议或业务字段。
class_name GFBatchedLogSink
extends GFLogSink


# --- 信号 ---

## 批次准备好时发出。
## @param batch: 日志批次数组。
signal batch_ready(batch: Array[Dictionary])


# --- 导出变量 ---

## 每批最多包含的日志条数。
@export var batch_size: int = 20:
	set(value):
		batch_size = maxi(value, 1)

## 队列最多保留的日志条数，超出时丢弃最旧条目。
@export var max_queue_size: int = 500:
	set(value):
		max_queue_size = maxi(value, 1)
		_trim_queue()

## 自动 flush 间隔。设为 0 时只按 batch_size 或显式 flush。
@export var flush_interval_msec: int = 1000:
	set(value):
		flush_interval_msec = maxi(value, 0)

## 是否在转发前移除 text 字段，减少重复载荷。
@export var omit_formatted_text: bool = false

## 发送时附加到批次外层的元数据。
@export var metadata: Dictionary = {}


# --- 公共变量 ---

## 项目提供的发送回调，签名建议为 func(payload: Dictionary) -> Dictionary。
var sender_callback: Callable = Callable()


# --- 私有变量 ---

var _queue: Array[Dictionary] = []
var _dropped_count: int = 0
var _last_flush_msec: int = 0


# --- 公共方法 ---

## 初始化 sink。
## @param _owner: 持有该 sink 的日志工具。
func init(_owner: Object) -> void:
	_last_flush_msec = Time.get_ticks_msec()


## 写入一条结构化日志。
## @param entry: 日志条目字典。
func write(entry: Dictionary) -> void:
	var sanitized := GFLogUtility.sanitize_log_value(entry.duplicate(true)) as Dictionary
	if sanitized == null:
		return
	if omit_formatted_text:
		sanitized.erase("text")

	_queue.append(sanitized)
	_trim_queue()
	if _queue.size() >= batch_size or _should_flush_by_interval():
		flush()


## 发送当前队列中的一批日志。
func flush() -> void:
	if _queue.is_empty():
		_last_flush_msec = Time.get_ticks_msec()
		return

	var take_count := mini(batch_size, _queue.size())
	var batch: Array[Dictionary] = []
	for _index: int in range(take_count):
		batch.append(_queue.pop_front())

	_last_flush_msec = Time.get_ticks_msec()
	var payload := {
		"logs": batch,
		"metadata": metadata.duplicate(true),
		"dropped_count": _dropped_count,
	}
	if sender_callback.is_valid():
		sender_callback.call(payload)
	batch_ready.emit(batch)


## 关闭 sink 并尽力 flush。
func shutdown() -> void:
	flush()


## 获取队列中的日志数量。
## @return 待发送日志数量。
func get_pending_count() -> int:
	return _queue.size()


## 获取因队列上限丢弃的日志数量。
## @return 丢弃数量。
func get_dropped_count() -> int:
	return _dropped_count


## 获取调试快照。
## @return sink 状态字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"pending_count": _queue.size(),
		"dropped_count": _dropped_count,
		"batch_size": batch_size,
		"max_queue_size": max_queue_size,
		"flush_interval_msec": flush_interval_msec,
		"has_sender_callback": sender_callback.is_valid(),
	}


# --- 私有/辅助方法 ---

func _trim_queue() -> void:
	while _queue.size() > max_queue_size:
		_queue.pop_front()
		_dropped_count += 1


func _should_flush_by_interval() -> bool:
	if flush_interval_msec <= 0:
		return false
	return Time.get_ticks_msec() - _last_flush_msec >= flush_interval_msec
