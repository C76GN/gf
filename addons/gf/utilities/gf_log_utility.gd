## GFLogUtility: 集中式日志系统。
##
## 取代原生 print / push_error，提供分级日志（DEBUG → FATAL），
## 每条日志同时写入本地按日期命名的日志文件，并通过信号广播给
## 控制台等消费者。启动时自动清理超出保留上限的旧日志文件。
class_name GFLogUtility
extends GFUtility


# --- 枚举 ---

## 日志等级，数值越大越严重。
enum LogLevel {
	## 调试信息
	DEBUG,
	## 一般信息
	INFO,
	## 警告
	WARN,
	## 错误
	ERROR,
	## 致命错误
	FATAL,
}


# --- 信号 ---

## 每次打印日志时发出，供 UI 控制台等消费者捕捉。
## @param level: LogLevel 枚举值。
## @param tag: 日志标签。
## @param message: 日志内容。
signal log_emitted(level: int, tag: String, message: String)


# --- 常量 ---

const _LOG_DIR: String = "user://logs/"

static var _LEVEL_NAMES: PackedStringArray = PackedStringArray([
	"DEBUG",
	"INFO",
	"WARN",
	"ERROR",
	"FATAL",
])


# --- 公共变量 ---

## 最多保留的日志文件数量。
var max_log_files: int:
	get:
		return _max_log_files
	set(value):
		_max_log_files = maxi(value, 1)

## 日志文件自动 flush 间隔。设为 0 时每条日志都立即 flush。
var flush_interval_msec: int = 250

## 是否强制每条日志立即 flush。高可靠日志可开启，默认关闭以减少高频 IO。
var flush_immediately: bool = false

## 最小输出等级。低于该等级的日志不会打印、写文件或发信号。
var min_level: int = LogLevel.DEBUG

## 内存中最多保留的最近日志条数。设为 0 可关闭内存缓存。
var max_memory_entries: int:
	get:
		return _max_memory_entries
	set(value):
		_max_memory_entries = maxi(value, 0)
		_trim_memory_entries()


# --- 私有变量 ---

var _max_log_files: int = 10
var _max_memory_entries: int = 500
var _file: FileAccess
var _log_file_path: String
var _muted_tags: Dictionary = {}
var _last_file_flush_msec: int = 0
var _memory_entries: Array[Dictionary] = []
var _memory_head: int = 0
var _memory_dropped_count: int = 0


# --- Godot 生命周期方法 ---

## 第一阶段初始化：创建日志目录、打开日志文件、清理旧文件。
func init() -> void:
	clear_memory_entries()
	if not DirAccess.dir_exists_absolute(_LOG_DIR):
		DirAccess.make_dir_recursive_absolute(_LOG_DIR)

	var datetime := Time.get_datetime_dict_from_system()
	var file_name := "gf_log_%04d%02d%02d_%02d%02d%02d_%03d.log" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute,
		datetime.second,
		Time.get_ticks_msec() % 1000,
	]
	_log_file_path = _LOG_DIR + file_name

	_file = FileAccess.open(_log_file_path, FileAccess.WRITE)
	if _file == null:
		push_error("[GFLogUtility] 无法创建日志文件：%s，错误码：%s" % [_log_file_path, FileAccess.get_open_error()])
	else:
		_last_file_flush_msec = Time.get_ticks_msec()

	_cleanup_old_logs()


## 销毁时关闭文件句柄。
func dispose() -> void:
	if _file != null:
		_file.flush()
		_file.close()
		_file = null


# --- 公共方法 ---

## 输出 DEBUG 级别日志。
## @param tag: 日志标签（如模块名）。
## @param msg: 日志内容。
func debug(tag: String, msg: String) -> void:
	_log(LogLevel.DEBUG, tag, msg)


## 延迟输出 DEBUG 级别日志。只有日志未被过滤时才调用 message_builder。
## @param tag: 日志标签。
## @param message_builder: 延迟构造日志消息的回调。
func debug_lazy(tag: String, message_builder: Callable) -> void:
	_log_lazy(LogLevel.DEBUG, tag, message_builder)


## 输出 INFO 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
func info(tag: String, msg: String) -> void:
	_log(LogLevel.INFO, tag, msg)


## 延迟输出 INFO 级别日志。只有日志未被过滤时才调用 message_builder。
## @param tag: 日志标签。
## @param message_builder: 延迟构造日志消息的回调。
func info_lazy(tag: String, message_builder: Callable) -> void:
	_log_lazy(LogLevel.INFO, tag, message_builder)


## 输出 WARN 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
func warn(tag: String, msg: String) -> void:
	_log(LogLevel.WARN, tag, msg)


## 延迟输出 WARN 级别日志。只有日志未被过滤时才调用 message_builder。
## @param tag: 日志标签。
## @param message_builder: 延迟构造日志消息的回调。
func warn_lazy(tag: String, message_builder: Callable) -> void:
	_log_lazy(LogLevel.WARN, tag, message_builder)


## 输出 ERROR 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
func error(tag: String, msg: String) -> void:
	_log(LogLevel.ERROR, tag, msg)


## 延迟输出 ERROR 级别日志。只有日志未被过滤时才调用 message_builder。
## @param tag: 日志标签。
## @param message_builder: 延迟构造日志消息的回调。
func error_lazy(tag: String, message_builder: Callable) -> void:
	_log_lazy(LogLevel.ERROR, tag, message_builder)


## 输出 FATAL 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
func fatal(tag: String, msg: String) -> void:
	_log(LogLevel.FATAL, tag, msg)


## 延迟输出 FATAL 级别日志。只有日志未被过滤时才调用 message_builder。
## @param tag: 日志标签。
## @param message_builder: 延迟构造日志消息的回调。
func fatal_lazy(tag: String, message_builder: Callable) -> void:
	_log_lazy(LogLevel.FATAL, tag, message_builder)


## 动态设置是否忽略特定标签的日志。
## @param tag: 要静音的标签。
## @param muted: 是否静音。如果为 true，该 tag 的日志将不再打印及记录。
func set_tag_muted(tag: String, muted: bool) -> void:
	_muted_tags[tag] = muted


## 检查指定标签是否被静音。
## @param tag: 日志标签。
func is_tag_muted(tag: String) -> bool:
	return _muted_tags.get(tag, false)


## 获取最近的内存日志条目。
## @param count: 读取数量；小于 0 表示全部。
## @return 从旧到新的日志条目数组。
func get_recent_entries(count: int = -1) -> Array[Dictionary]:
	var size := _memory_entries.size()
	if count < 0 or count >= size:
		return get_entries(0, -1)
	return get_entries(size - count, count)


## 按偏移读取内存日志条目。
## @param offset: 从最旧条目开始的偏移。
## @param count: 读取数量；小于 0 表示直到末尾。
## @return 从旧到新的日志条目数组。
func get_entries(offset: int = 0, count: int = -1) -> Array[Dictionary]:
	var safe_offset := clampi(offset, 0, _memory_entries.size())
	var end := _memory_entries.size() if count < 0 else mini(safe_offset + count, _memory_entries.size())
	var result: Array[Dictionary] = []
	for logical_index in range(safe_offset, end):
		var physical_index := _memory_logical_to_physical(logical_index)
		if physical_index >= 0 and physical_index < _memory_entries.size():
			result.append(_memory_entries[physical_index].duplicate(true))
	return result


## 获取当前内存日志条目数量。
## @return 条目数量。
func get_memory_entry_count() -> int:
	return _memory_entries.size()


## 获取因内存上限被丢弃的日志条目数量。
## @return 丢弃数量。
func get_dropped_memory_entry_count() -> int:
	return _memory_dropped_count


## 清空内存日志缓存。
func clear_memory_entries() -> void:
	_memory_entries.clear()
	_memory_head = 0
	_memory_dropped_count = 0


# --- 私有方法 ---

func _log(level: int, tag: String, msg: String) -> void:
	if not _should_log(level, tag):
		return
		
	var level_str: String = _LEVEL_NAMES[level] if level < _LEVEL_NAMES.size() else "UNKNOWN"
	var datetime := Time.get_datetime_dict_from_system()
	var timestamp := "%04d-%02d-%02d %02d:%02d:%02d" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute,
		datetime.second,
	]
	var formatted := "[%s][%s][%s] %s" % [timestamp, level_str, tag, msg]
	_append_memory_entry(timestamp, level, level_str, tag, msg, formatted)

	# 写入文件
	if _file != null:
		_file.store_line(formatted)
		_flush_file_if_needed(level)

	# 控制台输出
	match level:
		LogLevel.ERROR, LogLevel.FATAL:
			push_error(formatted)
		LogLevel.WARN:
			push_warning(formatted)
		_:
			print(formatted)

	log_emitted.emit(level, tag, msg)


func _log_lazy(level: int, tag: String, message_builder: Callable) -> void:
	if not _should_log(level, tag):
		return
	if not message_builder.is_valid():
		push_error("[GFLogUtility] lazy 日志收到无效 message_builder。")
		return

	_log(level, tag, String(message_builder.call()))


func _should_log(level: int, tag: String) -> bool:
	if level < LogLevel.DEBUG:
		return false
	if level < min_level:
		return false
	if _muted_tags.get(tag, false):
		return false
	return true


func _cleanup_old_logs() -> void:
	var dir := DirAccess.open(_LOG_DIR)
	if dir == null:
		return

	var files: PackedStringArray = PackedStringArray()
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.begins_with("gf_log_") and file_name.ends_with(".log"):
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	if files.size() <= max_log_files:
		return

	files.sort()
	var to_remove: int = files.size() - max_log_files
	for i in range(to_remove):
		var path := _LOG_DIR + files[i]
		DirAccess.remove_absolute(path)


func _flush_file_if_needed(level: int) -> void:
	if _file == null:
		return

	var now := Time.get_ticks_msec()
	if (
		flush_immediately
		or flush_interval_msec <= 0
		or level >= LogLevel.ERROR
		or now - _last_file_flush_msec >= flush_interval_msec
	):
		_file.flush()
		_last_file_flush_msec = now


func _append_memory_entry(
	timestamp: String,
	level: int,
	level_name: String,
	tag: String,
	message: String,
	text: String
) -> void:
	if _max_memory_entries <= 0:
		_memory_dropped_count += 1
		return

	var entry := {
		"timestamp": timestamp,
		"level": level,
		"level_name": level_name,
		"tag": tag,
		"message": message,
		"text": text,
	}
	if _memory_entries.size() < _max_memory_entries:
		_memory_entries.append(entry)
		_memory_head = _memory_entries.size() % _max_memory_entries
		return

	_memory_entries[_memory_head] = entry
	_memory_head = (_memory_head + 1) % _max_memory_entries
	_memory_dropped_count += 1


func _trim_memory_entries() -> void:
	if _max_memory_entries <= 0:
		_memory_dropped_count += _memory_entries.size()
		_memory_entries.clear()
		_memory_head = 0
		return

	if _memory_entries.size() <= _max_memory_entries:
		return

	var retained_count := _max_memory_entries
	var dropped_count := _memory_entries.size() - retained_count
	var retained: Array[Dictionary] = []
	for entry: Dictionary in get_recent_entries(retained_count):
		retained.append(entry)

	_memory_entries = retained
	_memory_head = _memory_entries.size() % _max_memory_entries
	_memory_dropped_count += dropped_count


func _memory_logical_to_physical(logical_index: int) -> int:
	if _memory_entries.is_empty():
		return -1
	if _max_memory_entries <= 0 or _memory_entries.size() < _max_memory_entries:
		return logical_index
	return (_memory_head + logical_index) % _memory_entries.size()
