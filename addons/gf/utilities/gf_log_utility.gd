## GFLogUtility: 集中式日志系统。
##
## 取代原生 print / push_error，提供分级日志（DEBUG → FATAL），
## 每条日志同时写入本地按日期命名的日志文件，进入内存环形缓存，
## 并通过信号和可插拔 sink 广播结构化日志条目。
class_name GFLogUtility
extends GFUtility


# --- 信号 ---

## 每次打印日志时发出，供 UI 控制台等消费者捕捉。
## @param level: LogLevel 枚举值。
## @param tag: 日志标签。
## @param message: 日志内容。
signal log_emitted(level: int, tag: String, message: String)

## 每次打印日志时发出完整结构化条目。
## @param entry: 日志条目副本。
signal log_entry_emitted(entry: Dictionary)

## 初始化时检测到上次运行未干净关闭后发出。
## @param marker: 上次运行留下的标记数据。
signal previous_crash_detected(marker: Dictionary)


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


# --- 常量 ---

const GFLogSink = preload("res://addons/gf/utilities/gf_log_sink.gd")
const _LOG_DIR: String = "user://logs/"
const _CRASH_MARKER_PATH: String = _LOG_DIR + "gf_log_running.marker"
const _MAX_SANITIZE_DEPTH: int = 8
const _MAX_SANITIZE_STRING_LENGTH: int = 2048

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

## 是否写入运行中标记，用于下一次启动时判断上次是否未干净关闭。
var crash_marker_enabled: bool = true

## 当前日志 trace id。为空时 init() 会生成一个短 id。
var trace_id: String = ""


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
var _sinks: Array[GFLogSink] = []
var _is_initialized: bool = false
var _global_context: Dictionary = {}
var _global_context_provider: Callable = Callable()
var _last_shutdown_was_clean: bool = true
var _previous_crash_marker: Dictionary = {}


# --- Godot 生命周期方法 ---

## 第一阶段初始化：创建日志目录、打开日志文件、清理旧文件。
func init() -> void:
	clear_memory_entries()
	if not DirAccess.dir_exists_absolute(_LOG_DIR):
		DirAccess.make_dir_recursive_absolute(_LOG_DIR)

	if trace_id.is_empty():
		trace_id = _generate_trace_id()
	_check_previous_crash_marker()
	_write_crash_marker()

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
	_is_initialized = true
	if not _last_shutdown_was_clean:
		previous_crash_detected.emit(_previous_crash_marker.duplicate(true))
	for sink: GFLogSink in _sinks:
		if sink != null:
			sink.init(self)


## 销毁时关闭文件句柄。
func dispose() -> void:
	flush_sinks()
	for sink: GFLogSink in _sinks:
		if sink != null:
			sink.shutdown()

	if _file != null:
		_file.flush()
		_file.close()
		_file = null

	_is_initialized = false
	_mark_shutdown_clean()


# --- 公共方法 ---

## 输出 DEBUG 级别日志。
## @param tag: 日志标签（如模块名）。
## @param msg: 日志内容。
## @param context: 结构化上下文字典。
func debug(tag: String, msg: String, context: Dictionary = {}) -> void:
	_log(LogLevel.DEBUG, tag, msg, context)


## 延迟输出 DEBUG 级别日志。只有日志未被过滤时才调用 message_builder。
## @param tag: 日志标签。
## @param message_builder: 延迟构造日志消息的回调。
## @param context_builder: 延迟构造结构化上下文的回调。
func debug_lazy(tag: String, message_builder: Callable, context_builder: Callable = Callable()) -> void:
	_log_lazy(LogLevel.DEBUG, tag, message_builder, context_builder)


## 输出 INFO 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
## @param context: 结构化上下文字典。
func info(tag: String, msg: String, context: Dictionary = {}) -> void:
	_log(LogLevel.INFO, tag, msg, context)


## 延迟输出 INFO 级别日志。只有日志未被过滤时才调用 message_builder。
## @param tag: 日志标签。
## @param message_builder: 延迟构造日志消息的回调。
## @param context_builder: 延迟构造结构化上下文的回调。
func info_lazy(tag: String, message_builder: Callable, context_builder: Callable = Callable()) -> void:
	_log_lazy(LogLevel.INFO, tag, message_builder, context_builder)


## 输出 WARN 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
## @param context: 结构化上下文字典。
func warn(tag: String, msg: String, context: Dictionary = {}) -> void:
	_log(LogLevel.WARN, tag, msg, context)


## 延迟输出 WARN 级别日志。只有日志未被过滤时才调用 message_builder。
## @param tag: 日志标签。
## @param message_builder: 延迟构造日志消息的回调。
## @param context_builder: 延迟构造结构化上下文的回调。
func warn_lazy(tag: String, message_builder: Callable, context_builder: Callable = Callable()) -> void:
	_log_lazy(LogLevel.WARN, tag, message_builder, context_builder)


## 输出 ERROR 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
## @param context: 结构化上下文字典。
func error(tag: String, msg: String, context: Dictionary = {}) -> void:
	_log(LogLevel.ERROR, tag, msg, context)


## 延迟输出 ERROR 级别日志。只有日志未被过滤时才调用 message_builder。
## @param tag: 日志标签。
## @param message_builder: 延迟构造日志消息的回调。
## @param context_builder: 延迟构造结构化上下文的回调。
func error_lazy(tag: String, message_builder: Callable, context_builder: Callable = Callable()) -> void:
	_log_lazy(LogLevel.ERROR, tag, message_builder, context_builder)


## 输出 FATAL 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
## @param context: 结构化上下文字典。
func fatal(tag: String, msg: String, context: Dictionary = {}) -> void:
	_log(LogLevel.FATAL, tag, msg, context)


## 延迟输出 FATAL 级别日志。只有日志未被过滤时才调用 message_builder。
## @param tag: 日志标签。
## @param message_builder: 延迟构造日志消息的回调。
## @param context_builder: 延迟构造结构化上下文的回调。
func fatal_lazy(tag: String, message_builder: Callable, context_builder: Callable = Callable()) -> void:
	_log_lazy(LogLevel.FATAL, tag, message_builder, context_builder)


## 输出指定等级日志。
## @param level: LogLevel 枚举值。
## @param tag: 日志标签。
## @param msg: 日志内容。
## @param context: 结构化上下文字典。
func log(level: int, tag: String, msg: String, context: Dictionary = {}) -> void:
	_log(level, tag, msg, context)


## 设置当前 trace id。
## @param value: 新 trace id；为空时会重新生成。
func set_trace_id(value: String) -> void:
	trace_id = value if not value.is_empty() else _generate_trace_id()
	if _is_initialized and crash_marker_enabled:
		_write_crash_marker()


## 获取当前 trace id。
## @return trace id 字符串。
func get_trace_id() -> String:
	if trace_id.is_empty():
		trace_id = _generate_trace_id()
	return trace_id


## 设置全局日志上下文字典。每条日志都会合并该字典，单条日志上下文优先级更高。
## @param context: 全局上下文字典。
func set_global_context(context: Dictionary) -> void:
	_global_context = _sanitize_log_value(context) as Dictionary


## 设置全局日志上下文提供者。每条日志输出时会调用一次，返回 Dictionary 时参与合并。
## @param provider: 上下文提供者，签名为 `func() -> Dictionary`。
func set_global_context_provider(provider: Callable) -> void:
	_global_context_provider = provider


## 清空全局日志上下文和上下文提供者。
func clear_global_context() -> void:
	_global_context.clear()
	_global_context_provider = Callable()


## 获取全局日志上下文字典副本。
## @return 全局上下文字典副本。
func get_global_context() -> Dictionary:
	return _global_context.duplicate(true)


## 获取上次运行是否干净关闭。
## @return 没有检测到运行中标记时返回 true。
func was_previous_shutdown_clean() -> bool:
	return _last_shutdown_was_clean


## 获取上次未干净关闭时留下的标记数据。
## @return crash marker 副本。
func get_previous_crash_marker() -> Dictionary:
	return _previous_crash_marker.duplicate(true)


## 动态设置是否忽略特定标签的日志。
## @param tag: 要静音的标签。
## @param muted: 是否静音。如果为 true，该 tag 的日志将不再打印及记录。
func set_tag_muted(tag: String, muted: bool) -> void:
	_muted_tags[tag] = muted


## 检查指定标签是否被静音。
## @param tag: 日志标签。
func is_tag_muted(tag: String) -> bool:
	return _muted_tags.get(tag, false)


## 注册日志 sink。
## @param sink: 要注册的 sink 实例。
func add_sink(sink: GFLogSink) -> void:
	if sink == null or _sinks.has(sink):
		return

	_sinks.append(sink)
	if _is_initialized:
		sink.init(self)


## 注销日志 sink。
## @param sink: 要注销的 sink 实例。
## @param shutdown: 是否调用 sink.shutdown()。
func remove_sink(sink: GFLogSink, shutdown: bool = true) -> void:
	var index := _sinks.find(sink)
	if index < 0:
		return

	_sinks.remove_at(index)
	if shutdown and sink != null:
		sink.shutdown()


## 清空所有日志 sink。
## @param shutdown: 是否调用每个 sink 的 shutdown()。
func clear_sinks(shutdown: bool = true) -> void:
	if shutdown:
		for sink: GFLogSink in _sinks:
			if sink != null:
				sink.shutdown()
	_sinks.clear()


## 获取已注册日志 sink。
## @return sink 列表副本。
func get_sinks() -> Array[GFLogSink]:
	var result: Array[GFLogSink] = []
	for sink: GFLogSink in _sinks:
		result.append(sink)
	return result


## 刷新所有日志 sink。
func flush_sinks() -> void:
	for sink: GFLogSink in _sinks:
		if sink != null:
			sink.flush()


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


## 获取当前日志文件路径。
## @return 日志文件路径。
func get_log_file_path() -> String:
	return _log_file_path


## 清空内存日志缓存。
func clear_memory_entries() -> void:
	_memory_entries.clear()
	_memory_head = 0
	_memory_dropped_count = 0


## 清洗任意值，使它适合进入结构化日志和 JSON sink。
## @param value: 要清洗的值。
## @return 清洗后的值。
static func sanitize_log_value(value: Variant) -> Variant:
	return _sanitize_log_value(value)


# --- 私有方法 ---

func _log(level: int, tag: String, msg: String, context: Dictionary = {}) -> void:
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
	var entry := _make_entry(timestamp, level, level_str, tag, msg, context)
	var formatted := String(entry["text"])
	_append_memory_entry(entry)

	if _file != null:
		_file.store_line(formatted)
		_flush_file_if_needed(level)

	match level:
		LogLevel.ERROR, LogLevel.FATAL:
			push_error(formatted)
		LogLevel.WARN:
			push_warning(formatted)
		_:
			print(formatted)

	_write_sinks(entry)
	log_emitted.emit(level, tag, msg)
	log_entry_emitted.emit(entry.duplicate(true))


func _log_lazy(
	level: int,
	tag: String,
	message_builder: Callable,
	context_builder: Callable = Callable()
) -> void:
	if not _should_log(level, tag):
		return
	if not message_builder.is_valid():
		push_error("[GFLogUtility] lazy 日志收到无效 message_builder。")
		return

	var context: Dictionary = {}
	if context_builder.is_valid():
		var context_variant: Variant = context_builder.call()
		if context_variant is Dictionary:
			context = (context_variant as Dictionary).duplicate(true)

	_log(level, tag, String(message_builder.call()), context)


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


func _make_entry(
	timestamp: String,
	level: int,
	level_name: String,
	tag: String,
	message: String,
	context: Dictionary
) -> Dictionary:
	var safe_context := _merge_log_context(context)
	var text := "[%s][%s][%s] %s" % [timestamp, level_name, tag, message]
	if not safe_context.is_empty():
		text += " " + JSON.stringify(safe_context)

	return {
		"timestamp": timestamp,
		"unix_time": Time.get_unix_time_from_system(),
		"ticks_msec": Time.get_ticks_msec(),
		"trace_id": get_trace_id(),
		"level": level,
		"level_name": level_name,
		"tag": tag,
		"message": message,
		"context": safe_context,
		"text": text,
	}


func _write_sinks(entry: Dictionary) -> void:
	for sink: GFLogSink in _sinks:
		if sink != null:
			sink.write(entry.duplicate(true))


func _append_memory_entry(entry: Dictionary) -> void:
	if _max_memory_entries <= 0:
		_memory_dropped_count += 1
		return

	if _memory_entries.size() < _max_memory_entries:
		_memory_entries.append(entry.duplicate(true))
		_memory_head = _memory_entries.size() % _max_memory_entries
		return

	_memory_entries[_memory_head] = entry.duplicate(true)
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


func _merge_log_context(context: Dictionary) -> Dictionary:
	var merged := _global_context.duplicate(true)
	if _global_context_provider.is_valid():
		var provided: Variant = _global_context_provider.call()
		if provided is Dictionary:
			for key: Variant in (provided as Dictionary).keys():
				merged[key] = (provided as Dictionary)[key]

	for key: Variant in context.keys():
		merged[key] = context[key]
	if not merged.has("trace_id"):
		merged["trace_id"] = get_trace_id()
	return _sanitize_log_value(merged) as Dictionary


static func _sanitize_log_value(value: Variant, depth: int = 0) -> Variant:
	if depth >= _MAX_SANITIZE_DEPTH:
		return "<max_depth>"

	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT:
			return value
		TYPE_STRING:
			return _truncate_log_string(String(value))
		TYPE_STRING_NAME, TYPE_NODE_PATH:
			return _truncate_log_string(String(value))
		TYPE_DICTIONARY:
			var result: Dictionary = {}
			var source := value as Dictionary
			for key: Variant in source.keys():
				result[String(key)] = _sanitize_log_value(source[key], depth + 1)
			return result
		TYPE_ARRAY:
			var result: Array = []
			for item: Variant in (value as Array):
				result.append(_sanitize_log_value(item, depth + 1))
			return result
		TYPE_PACKED_BYTE_ARRAY:
			return {
				"type": "PackedByteArray",
				"size": (value as PackedByteArray).size(),
			}
		TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY:
			return {
				"type": type_string(typeof(value)),
				"size": value.size(),
			}
		TYPE_PACKED_STRING_ARRAY:
			var strings: Array = []
			for item: String in (value as PackedStringArray):
				strings.append(_sanitize_log_value(item, depth + 1))
			return strings
		TYPE_OBJECT:
			var object := value as Object
			if object == null:
				return null
			var payload := {
				"type": object.get_class(),
				"id": object.get_instance_id(),
			}
			if object is Node:
				var node := object as Node
				payload["name"] = node.name
				payload["path"] = str(node.get_path()) if node.is_inside_tree() else ""
			return payload
		_:
			return _truncate_log_string(str(value))


static func _truncate_log_string(value: String) -> String:
	if value.length() <= _MAX_SANITIZE_STRING_LENGTH:
		return value
	return value.substr(0, _MAX_SANITIZE_STRING_LENGTH) + "...<truncated>"


func _check_previous_crash_marker() -> void:
	_previous_crash_marker.clear()
	if not crash_marker_enabled:
		_last_shutdown_was_clean = true
		return
	if not FileAccess.file_exists(_CRASH_MARKER_PATH):
		_last_shutdown_was_clean = true
		return

	_last_shutdown_was_clean = false
	var content := FileAccess.get_file_as_string(_CRASH_MARKER_PATH)
	var parsed: Variant = JSON.parse_string(content)
	if parsed is Dictionary:
		_previous_crash_marker = _sanitize_log_value(parsed) as Dictionary


func _write_crash_marker() -> void:
	if not crash_marker_enabled:
		return

	var file := FileAccess.open(_CRASH_MARKER_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({
		"trace_id": get_trace_id(),
		"started_at": Time.get_datetime_string_from_system(true, true),
		"ticks_msec": Time.get_ticks_msec(),
	}))
	file.close()


func _mark_shutdown_clean() -> void:
	if FileAccess.file_exists(_CRASH_MARKER_PATH):
		DirAccess.remove_absolute(_CRASH_MARKER_PATH)


func _generate_trace_id() -> String:
	var source := "%s:%s:%s" % [
		Time.get_unix_time_from_system(),
		Time.get_ticks_usec(),
		randi(),
	]
	return source.sha256_text().substr(0, 16)
