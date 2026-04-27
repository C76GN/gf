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


# --- 私有变量 ---

var _max_log_files: int = 10
var _file: FileAccess
var _log_file_path: String
var _muted_tags: Dictionary = {}
var _last_file_flush_msec: int = 0


# --- Godot 生命周期方法 ---

## 第一阶段初始化：创建日志目录、打开日志文件、清理旧文件。
func init() -> void:
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


## 输出 INFO 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
func info(tag: String, msg: String) -> void:
	_log(LogLevel.INFO, tag, msg)


## 输出 WARN 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
func warn(tag: String, msg: String) -> void:
	_log(LogLevel.WARN, tag, msg)


## 输出 ERROR 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
func error(tag: String, msg: String) -> void:
	_log(LogLevel.ERROR, tag, msg)


## 输出 FATAL 级别日志。
## @param tag: 日志标签。
## @param msg: 日志内容。
func fatal(tag: String, msg: String) -> void:
	_log(LogLevel.FATAL, tag, msg)


## 动态设置是否忽略特定标签的日志。
## @param tag: 要静音的标签。
## @param muted: 是否静音。如果为 true，该 tag 的日志将不再打印及记录。
func set_tag_muted(tag: String, muted: bool) -> void:
	_muted_tags[tag] = muted


## 检查指定标签是否被静音。
## @param tag: 日志标签。
func is_tag_muted(tag: String) -> bool:
	return _muted_tags.get(tag, false)


# --- 私有方法 ---

func _log(level: int, tag: String, msg: String) -> void:
	if _muted_tags.get(tag, false):
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


func _cleanup_old_logs() -> void:
	var dir := DirAccess.open(_LOG_DIR)
	if dir == null:
		return

	var files: PackedStringArray = PackedStringArray()
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".log"):
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
