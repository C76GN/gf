## GFConfigRegexValidationRule: 字符串正则校验规则。
##
## 用于检查字符串字段是否匹配给定表达式，可选择部分匹配或完整匹配。
class_name GFConfigRegexValidationRule
extends GFConfigValidationRule


# --- 导出变量 ---

## 正则表达式。
@export var pattern: String = ""

## 是否要求整个字符串都匹配。
@export var require_full_match: bool = false

## 空字符串是否直接视为通过。
@export var allow_empty: bool = true


# --- 公共方法 ---

## 导出规则摘要。
## @return 规则摘要字典。
func describe() -> Dictionary:
	var result := super.describe()
	result["pattern"] = pattern
	result["require_full_match"] = require_full_match
	result["allow_empty"] = allow_empty
	return result


# --- 可重写钩子 ---

func _get_default_rule_id() -> StringName:
	return &"regex"


func _validate_value(value: Variant, context: Dictionary, report: Dictionary) -> void:
	if typeof(value) != TYPE_STRING and typeof(value) != TYPE_STRING_NAME:
		_add_issue(report, context, "regex_invalid_type", "正则校验只支持 String 或 StringName。")
		return

	var text := String(value)
	if text.is_empty() and allow_empty:
		return
	if pattern.is_empty():
		_add_issue(report, context, "regex_empty_pattern", "正则表达式为空。")
		return

	var regex := RegEx.new()
	var error := regex.compile(pattern)
	if error != OK:
		_add_issue(report, context, "regex_compile_failed", "正则表达式无法编译：%s。" % error_string(error))
		return

	var matched := regex.search(text)
	if matched == null:
		_add_issue(report, context, "regex_mismatch", "字符串不符合正则表达式。")
		return
	if require_full_match and (matched.get_start() != 0 or matched.get_end() != text.length()):
		_add_issue(report, context, "regex_mismatch", "字符串不完整匹配正则表达式。")
