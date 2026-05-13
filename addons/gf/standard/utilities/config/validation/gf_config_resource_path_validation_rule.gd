## GFConfigResourcePathValidationRule: Godot 资源路径校验规则。
##
## 用于检查配置字段中的 `res://` 路径是否存在，并可按扩展名限制资源类型。
class_name GFConfigResourcePathValidationRule
extends GFConfigValidationRule


# --- 导出变量 ---

## 空字符串是否直接视为通过。
@export var allow_empty: bool = true

## 是否要求路径以 res:// 开头。
@export var require_resource_prefix: bool = true

## 允许的扩展名。为空时不限制扩展名，可写 png 或 .png。
@export var allowed_extensions: PackedStringArray = PackedStringArray()

## 是否使用 ResourceLoader.exists() 检查导入资源。
@export var use_resource_loader: bool = true

## ResourceLoader 检查失败时是否再用 FileAccess.file_exists() 检查原始文件。
@export var use_file_access_fallback: bool = true


# --- 公共方法 ---

## 导出规则摘要。
## @return 规则摘要字典。
func describe() -> Dictionary:
	var result := super.describe()
	result["allow_empty"] = allow_empty
	result["require_resource_prefix"] = require_resource_prefix
	result["allowed_extensions"] = allowed_extensions.duplicate()
	result["use_resource_loader"] = use_resource_loader
	result["use_file_access_fallback"] = use_file_access_fallback
	return result


# --- 可重写钩子 ---

func _get_default_rule_id() -> StringName:
	return &"resource_path"


func _validate_value(value: Variant, context: Dictionary, report: Dictionary) -> void:
	if typeof(value) != TYPE_STRING and typeof(value) != TYPE_STRING_NAME:
		_add_issue(report, context, "resource_path_invalid_type", "资源路径校验只支持 String 或 StringName。")
		return

	var path := String(value).strip_edges()
	if path.is_empty() and allow_empty:
		return
	if require_resource_prefix and not path.begins_with("res://"):
		_add_issue(report, context, "resource_path_invalid_prefix", "资源路径必须以 res:// 开头。")
		return
	if not _extension_allowed(path):
		_add_issue(report, context, "resource_path_extension_not_allowed", "资源路径扩展名不在允许范围内。")
		return
	if not _path_exists(path):
		_add_issue(report, context, "resource_path_missing", "资源路径不存在：%s。" % path)


# --- 私有/辅助方法 ---

func _extension_allowed(path: String) -> bool:
	if allowed_extensions.is_empty():
		return true

	var extension := path.get_extension().to_lower()
	for allowed_extension: String in allowed_extensions:
		var normalized := allowed_extension.strip_edges().trim_prefix(".").to_lower()
		if normalized == extension:
			return true
	return false


func _path_exists(path: String) -> bool:
	if use_resource_loader and ResourceLoader.exists(path):
		return true
	if use_file_access_fallback and FileAccess.file_exists(path):
		return true
	return false
