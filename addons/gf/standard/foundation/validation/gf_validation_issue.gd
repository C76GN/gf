## GFValidationIssue: 通用校验问题条目。
##
## 用于描述配置、资源、节点树、存档载荷或编辑器工具中的单个问题。它只记录
## 严重级别、问题类别、定位信息和附加字段，不决定项目如何展示或修复问题。
class_name GFValidationIssue
extends RefCounted


# --- 枚举 ---

## 校验问题严重级别。
enum Severity {
	## 信息提示，不影响健康状态。
	INFO,
	## 警告，报告仍可继续使用，但不再视为完全健康。
	WARNING,
	## 错误，报告不应视为通过。
	ERROR,
}


# --- 公共变量 ---

## 严重级别。
var severity: Severity = Severity.ERROR

## 通用问题类别。推荐使用稳定的 snake_case 标识。
var kind: StringName = &""

## 可选错误码。用于兼容或桥接已有 code 风格报告。
var code: StringName = &""

## 可选定位键，例如行号、资源 key、节点 key 或调用方自定义标识。
var key: Variant = null

## 可选路径，例如资源路径、节点路径或数据路径。
var path: String = ""

## 可选主题，用于标记问题所属对象或报告域。
var subject: String = ""

## 面向开发者或工具 UI 的简短说明。
var message: String = ""

## 可选元数据。框架不解释该字段。
var metadata: Dictionary = {}

## 额外上下文字段。用于无损保留已有报告中的自定义字段。
var extra_fields: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init(
	p_severity: Variant = Severity.ERROR,
	p_kind: StringName = &"",
	p_message: String = "",
	p_key: Variant = null,
	p_path: String = "",
	p_metadata: Dictionary = {}
) -> void:
	severity = normalize_severity(p_severity)
	kind = p_kind
	message = p_message
	key = p_key
	path = p_path
	metadata = p_metadata.duplicate(true)


# --- 公共方法 ---

## 配置问题条目并返回自身，便于链式构造。
## @param p_severity: 严重级别，可传入 Severity、int 或字符串。
## @param p_kind: 问题类别。
## @param p_message: 问题说明。
## @param p_key: 可选定位键。
## @param p_path: 可选路径。
## @param p_metadata: 可选元数据。
## @return 当前问题条目。
func configure(
	p_severity: Variant,
	p_kind: StringName,
	p_message: String,
	p_key: Variant = null,
	p_path: String = "",
	p_metadata: Dictionary = {}
) -> RefCounted:
	severity = normalize_severity(p_severity)
	kind = p_kind
	message = p_message
	key = p_key
	path = p_path
	metadata = p_metadata.duplicate(true)
	return self


## 从字典应用字段。
## @param data: 输入字典。
func apply_dict(data: Dictionary) -> void:
	severity = normalize_severity(data.get("severity", severity))
	kind = _read_string_name(data, "kind", _read_string_name(data, "code", _read_string_name(data, "type", kind)))
	code = _read_string_name(data, "code", code)
	key = GFVariantData.duplicate_variant(data.get("key", key))
	path = String(data.get("path", path))
	subject = String(data.get("subject", subject))
	message = String(data.get("message", message))

	var metadata_value: Variant = data.get("metadata", metadata)
	metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}
	extra_fields.clear()
	for field_key: Variant in data.keys():
		if _is_reserved_field(String(field_key)):
			continue
		extra_fields[field_key] = GFVariantData.duplicate_variant(data[field_key])


## 转换为字典。
## @param include_empty_fields: 为 true 时包含空的可选字段。
## @return 字典副本。
func to_dict(include_empty_fields: bool = false) -> Dictionary:
	var result := {
		"severity": severity_to_string(severity),
		"message": message,
	}
	var kind_key := get_kind_key()
	if include_empty_fields or not kind_key.is_empty():
		result["kind"] = kind_key
	if include_empty_fields or code != &"":
		result["code"] = String(code)
	if include_empty_fields or key != null:
		result["key"] = GFVariantData.duplicate_variant(key)
	if include_empty_fields or not path.is_empty():
		result["path"] = path
	if include_empty_fields or not subject.is_empty():
		result["subject"] = subject

	for field_key: Variant in extra_fields.keys():
		if _is_reserved_field(String(field_key)):
			continue
		result[field_key] = GFVariantData.duplicate_variant(extra_fields[field_key])

	if include_empty_fields or not metadata.is_empty():
		result["metadata"] = metadata.duplicate(true)
	return result


## 创建当前问题条目的深拷贝。
## @return 新问题条目。
func duplicate_issue() -> RefCounted:
	var issue := get_script().new() as RefCounted
	issue.call("apply_dict", to_dict(true))
	return issue


## 获取统计用问题类别。
## @return 优先返回 kind，其次返回 code，最后返回 unknown。
func get_kind_key() -> String:
	if kind != &"":
		return String(kind)
	if code != &"":
		return String(code)
	return "unknown"


## 是否为错误。
## @return 严重级别为 ERROR 时返回 true。
func is_error() -> bool:
	return severity == Severity.ERROR


## 是否为警告。
## @return 严重级别为 WARNING 时返回 true。
func is_warning() -> bool:
	return severity == Severity.WARNING


## 是否为信息。
## @return 严重级别为 INFO 时返回 true。
func is_info() -> bool:
	return severity == Severity.INFO


## 将任意输入归一为 Severity。
## @param value: Severity、int 或字符串。
## @return 归一后的严重级别。
static func normalize_severity(value: Variant) -> Severity:
	if value == null:
		return Severity.ERROR
	if typeof(value) == TYPE_INT:
		return clampi(int(value), Severity.INFO, Severity.ERROR) as Severity

	var text := String(value).strip_edges().to_lower()
	match text:
		"info", "information", "note":
			return Severity.INFO
		"warn", "warning":
			return Severity.WARNING
		"error", "err", "fatal":
			return Severity.ERROR
		_:
			return Severity.ERROR


## 将严重级别转换为稳定字符串。
## @param value: Severity、int 或字符串。
## @return info、warning 或 error。
static func severity_to_string(value: Variant) -> String:
	match normalize_severity(value):
		Severity.INFO:
			return "info"
		Severity.WARNING:
			return "warning"
		_:
			return "error"


## 从字典创建问题条目。
## @param data: 输入字典。
## @return 新问题条目。
static func from_dict(data: Dictionary) -> RefCounted:
	var issue := (load("res://addons/gf/standard/foundation/validation/gf_validation_issue.gd") as Script).new() as RefCounted
	issue.call("apply_dict", data)
	return issue


# --- 私有/辅助方法 ---

static func _read_string_name(data: Dictionary, field_name: String, default_value: StringName = &"") -> StringName:
	if not data.has(field_name):
		return default_value
	var value: Variant = data.get(field_name, "")
	if value == null:
		return default_value
	return StringName(String(value))


static func _is_reserved_field(field_name: String) -> bool:
	return (
		field_name == "severity"
		or field_name == "kind"
		or field_name == "code"
		or field_name == "key"
		or field_name == "path"
		or field_name == "subject"
		or field_name == "message"
		or field_name == "metadata"
	)
