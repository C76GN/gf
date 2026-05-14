## GFSourceSpan: 通用源码或资源文本定位范围。
##
## 用于把校验、导入、生成器或编辑器工具中的问题定位到一个稳定的
## source_path、line、column 范围。行列约定为 1-based，0 表示未知。
class_name GFSourceSpan
extends RefCounted


# --- 常量 ---

const _SCRIPT_PATH: String = "res://addons/gf/standard/foundation/validation/gf_source_span.gd"


# --- 公共变量 ---

## 源文件或资源路径。
var source_path: String = ""

## 起始行号，1-based；0 表示未知。
var line: int = 0

## 起始列号，1-based；0 表示未知。
var column: int = 0

## 同一行内的跨度长度；0 表示未知。
var length: int = 0

## 结束行号，1-based；0 表示未知。
var end_line: int = 0

## 结束列号，1-based；0 表示未知。
var end_column: int = 0

## 可选源码预览。
var preview: String = ""

## 调用方附加元数据。
var metadata: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init(
	p_source_path: String = "",
	p_line: int = 0,
	p_column: int = 0,
	p_length: int = 0
) -> void:
	source_path = p_source_path
	line = maxi(p_line, 0)
	column = maxi(p_column, 0)
	length = maxi(p_length, 0)


# --- 公共方法 ---

## 配置定位范围。
## @param p_source_path: 源文件或资源路径。
## @param p_line: 起始行号，1-based；0 表示未知。
## @param p_column: 起始列号，1-based；0 表示未知。
## @param p_length: 同一行内的跨度长度；0 表示未知。
## @param p_end_line: 结束行号，1-based；0 表示未知。
## @param p_end_column: 结束列号，1-based；0 表示未知。
## @param p_preview: 可选源码预览。
## @param p_metadata: 调用方附加元数据。
## @return 当前定位范围。
func configure(
	p_source_path: String = "",
	p_line: int = 0,
	p_column: int = 0,
	p_length: int = 0,
	p_end_line: int = 0,
	p_end_column: int = 0,
	p_preview: String = "",
	p_metadata: Dictionary = {}
) -> RefCounted:
	source_path = p_source_path
	line = maxi(p_line, 0)
	column = maxi(p_column, 0)
	length = maxi(p_length, 0)
	end_line = maxi(p_end_line, 0)
	end_column = maxi(p_end_column, 0)
	preview = p_preview
	metadata = p_metadata.duplicate(true)
	return self


## 从字典应用字段。
## @param data: 输入字典。`source` 会作为 `source_path` 的兼容别名读取。
func apply_dict(data: Dictionary) -> void:
	source_path = _read_source_path(data, source_path)
	line = _read_non_negative_int(data, "line", line)
	column = _read_non_negative_int(data, "column", column)
	length = _read_non_negative_int(data, "length", length)
	end_line = _read_non_negative_int(data, "end_line", end_line)
	end_column = _read_non_negative_int(data, "end_column", end_column)
	preview = String(data.get("preview", preview))

	var metadata_value: Variant = data.get("metadata", metadata)
	metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}


## 转换为字典。
## @param include_empty_fields: 为 true 时包含空字段。
## @param include_legacy_source_alias: 为 true 时额外写入 `source` 兼容字段。
## @return 字典副本。
func to_dict(include_empty_fields: bool = false, include_legacy_source_alias: bool = false) -> Dictionary:
	var result: Dictionary = {}
	if include_empty_fields or not source_path.is_empty():
		result["source_path"] = source_path
		if include_legacy_source_alias:
			result["source"] = source_path
	if include_empty_fields or line > 0:
		result["line"] = line
	if include_empty_fields or column > 0:
		result["column"] = column
	if include_empty_fields or length > 0:
		result["length"] = length
	if include_empty_fields or end_line > 0:
		result["end_line"] = end_line
	if include_empty_fields or end_column > 0:
		result["end_column"] = end_column
	if include_empty_fields or not preview.is_empty():
		result["preview"] = preview
	if include_empty_fields or not metadata.is_empty():
		result["metadata"] = metadata.duplicate(true)
	return result


## 创建当前定位范围的深拷贝。
## @return 新定位范围。
func duplicate_span() -> RefCounted:
	var span := get_script().new() as RefCounted
	span.call("apply_dict", to_dict(true))
	return span


## 检查是否没有任何定位信息。
## @return 没有路径且没有位置时返回 true。
func is_empty() -> bool:
	return source_path.is_empty() and line <= 0 and column <= 0 and length <= 0 and end_line <= 0 and end_column <= 0


## 检查是否有源路径。
## @return 有源路径时返回 true。
func has_source_path() -> bool:
	return not source_path.is_empty()


## 检查是否有起始行号。
## @return 有起始行号时返回 true。
func has_position() -> bool:
	return line > 0


## 获取有效结束行。
## @return 显式 end_line 或起始行。
func get_effective_end_line() -> int:
	if end_line > 0:
		return end_line
	return line


## 获取有效结束列。
## @return 显式 end_column，或根据 column 与 length 推导出的列号。
func get_effective_end_column() -> int:
	if end_column > 0:
		return end_column
	if column <= 0:
		return 0
	if length > 0:
		return column + length
	return column


## 生成人类可读定位文本。
## @return 例如 `res://table.csv:4:2`。
func get_location_text() -> String:
	var label := source_path
	if label.is_empty():
		label = "source"
	if line > 0 and column > 0:
		return "%s:%d:%d" % [label, line, column]
	if line > 0:
		return "%s:%d" % [label, line]
	return label


## 将定位字段写入目标字典。
## @param target: 目标字典。
## @param include_empty_fields: 为 true 时包含空字段。
## @param include_legacy_source_alias: 为 true 时额外写入 `source` 兼容字段。
## @return 目标字典。
func merge_into_dictionary(
	target: Dictionary,
	include_empty_fields: bool = false,
	include_legacy_source_alias: bool = false
) -> Dictionary:
	var span_dict := to_dict(include_empty_fields, include_legacy_source_alias)
	for field_key: Variant in span_dict.keys():
		target[field_key] = GFVariantData.duplicate_variant(span_dict[field_key])
	return target


## 从字典创建定位范围。
## @param data: 输入字典。
## @return 新定位范围。
static func from_dict(data: Dictionary) -> RefCounted:
	var span := _new_span()
	span.call("apply_dict", data)
	return span


## 从问题对象或问题字典创建定位范围。
## @param issue: GFValidationIssue 或问题字典。
## @return 新定位范围。
static func from_issue(issue: Variant) -> RefCounted:
	if issue is Dictionary:
		var data := issue as Dictionary
		if data.get("source_span") is Dictionary:
			var nested_span := from_dict(data.get("source_span") as Dictionary)
			nested_span.call("apply_dict", data)
			return nested_span
		return from_dict(data)
	if issue is Object and (issue as Object).has_method("get_source_span"):
		var source_span: Variant = (issue as Object).call("get_source_span")
		if source_span is Object and (source_span as Object).has_method("duplicate_span"):
			return (source_span as Object).call("duplicate_span") as RefCounted
	return _new_span()


## 创建定位范围。
## @param p_source_path: 源文件或资源路径。
## @param p_line: 起始行号，1-based；0 表示未知。
## @param p_column: 起始列号，1-based；0 表示未知。
## @param p_length: 同一行内的跨度长度；0 表示未知。
## @return 新定位范围。
static func make(
	p_source_path: String = "",
	p_line: int = 0,
	p_column: int = 0,
	p_length: int = 0
) -> RefCounted:
	var span := _new_span()
	span.call("configure", p_source_path, p_line, p_column, p_length)
	return span


# --- 私有/辅助方法 ---

static func _new_span() -> RefCounted:
	return (load(_SCRIPT_PATH) as Script).new() as RefCounted


static func _read_source_path(data: Dictionary, default_value: String = "") -> String:
	if data.has("source_path"):
		return String(data.get("source_path", ""))
	if data.has("source"):
		return String(data.get("source", ""))
	return default_value


static func _read_non_negative_int(data: Dictionary, field_name: String, default_value: int) -> int:
	if not data.has(field_name):
		return default_value
	return maxi(int(data.get(field_name, default_value)), 0)
