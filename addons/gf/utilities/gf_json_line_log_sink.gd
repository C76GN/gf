## GFJsonLineLogSink: 把结构化日志条目写入 JSON Lines 文件。
##
## 该 sink 只负责把 GFLogUtility 传入的条目序列化为一行一个 JSON 对象，
## 不规定采集服务、上传时机或业务字段 schema。
class_name GFJsonLineLogSink
extends GFLogSink


# --- 导出变量 ---

## 输出文件路径。留空时会根据 GFLogUtility 当前日志文件派生同名 `.jsonl` 文件。
@export var file_path: String = ""

## 是否在写入前移除 `text` 字段，减少重复存储。
@export var omit_formatted_text: bool = false

## 文件自动 flush 间隔。设为 0 时每条日志都会立即 flush。
@export var flush_interval_msec: int = 250

## 是否强制每条 JSONL 日志立即 flush。
@export var flush_immediately: bool = false

## 使用默认派生路径时最多保留的 JSONL 文件数量。
@export var max_jsonl_files: int = 10:
	set(value):
		max_jsonl_files = maxi(value, 1)


# --- 私有变量 ---

var _file: FileAccess
var _effective_file_path: String = ""
var _last_flush_msec: int = 0
var _uses_default_file_path: bool = false


# --- 公共方法 ---

## 初始化 sink 并打开 JSONL 文件。
## @param owner: 持有该 sink 的日志工具。
func init(owner: Object) -> void:
	_effective_file_path = _resolve_file_path(owner)
	_ensure_parent_dir(_effective_file_path)
	_file = FileAccess.open(_effective_file_path, FileAccess.WRITE)
	if _file == null:
		push_error("[GFJsonLineLogSink] 无法创建日志文件：%s，错误码：%s" % [
			_effective_file_path,
			FileAccess.get_open_error(),
		])
	else:
		_last_flush_msec = Time.get_ticks_msec()

	if _uses_default_file_path:
		_cleanup_old_jsonl_files()


## 写入一条结构化日志。
## @param entry: 日志条目字典。
func write(entry: Dictionary) -> void:
	if _file == null:
		return

	var payload := _sanitize_for_json(entry.duplicate(true))
	if payload is Dictionary and omit_formatted_text:
		(payload as Dictionary).erase("text")

	_file.store_line(JSON.stringify(payload))
	_flush_if_needed()


## 刷新尚未写出的 JSONL 内容。
func flush() -> void:
	if _file != null:
		_file.flush()
		_last_flush_msec = Time.get_ticks_msec()


## 关闭文件句柄。
func shutdown() -> void:
	if _file != null:
		_file.flush()
		_file.close()
		_file = null


## 获取当前实际输出路径。
## @return JSONL 文件路径。
func get_file_path() -> String:
	return _effective_file_path


# --- 私有/辅助方法 ---

func _resolve_file_path(owner: Object) -> String:
	_uses_default_file_path = file_path.is_empty()
	if not file_path.is_empty():
		return file_path

	if owner != null and owner.has_method("get_log_file_path"):
		var owner_path := String(owner.call("get_log_file_path"))
		if not owner_path.is_empty():
			return owner_path.get_basename() + ".jsonl"

	return "user://logs/gf_log_%d.jsonl" % Time.get_ticks_msec()


func _ensure_parent_dir(path: String) -> void:
	var base_dir := path.get_base_dir()
	if base_dir.is_empty() or base_dir == ".":
		return

	if not DirAccess.dir_exists_absolute(base_dir):
		DirAccess.make_dir_recursive_absolute(base_dir)


func _flush_if_needed() -> void:
	if _file == null:
		return

	var now := Time.get_ticks_msec()
	if (
		flush_immediately
		or flush_interval_msec <= 0
		or now - _last_flush_msec >= flush_interval_msec
	):
		_file.flush()
		_last_flush_msec = now


func _cleanup_old_jsonl_files() -> void:
	var base_dir := _effective_file_path.get_base_dir()
	var dir := DirAccess.open(base_dir)
	if dir == null:
		return

	var files := PackedStringArray()
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.begins_with("gf_log_") and file_name.ends_with(".jsonl"):
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	if files.size() <= max_jsonl_files:
		return

	files.sort()
	var to_remove := files.size() - max_jsonl_files
	for index: int in range(to_remove):
		DirAccess.remove_absolute(base_dir.path_join(files[index]))


func _sanitize_for_json(value: Variant, depth: int = 0) -> Variant:
	if depth > 16:
		return "<max_depth>"

	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			return value
		TYPE_STRING_NAME, TYPE_NODE_PATH:
			return String(value)
		TYPE_ARRAY:
			var result: Array = []
			for item: Variant in value as Array:
				result.append(_sanitize_for_json(item, depth + 1))
			return result
		TYPE_DICTIONARY:
			var result: Dictionary = {}
			var source := value as Dictionary
			for key: Variant in source.keys():
				result[String(key)] = _sanitize_for_json(source[key], depth + 1)
			return result
		TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY, TYPE_PACKED_COLOR_ARRAY:
			var result: Array = []
			for item: Variant in value:
				result.append(_sanitize_for_json(item, depth + 1))
			return result
		_:
			return var_to_str(value)
