## GFConfigSetValidationRule: 值集合校验规则。
##
## 用于限制字段值必须出现在一个显式白名单中，不解释白名单背后的业务含义。
class_name GFConfigSetValidationRule
extends GFConfigValidationRule


# --- 导出变量 ---

## 允许出现的值列表。
@export var allowed_values: Array = []

## 字符串比较是否区分大小写。
@export var case_sensitive: bool = true


# --- 公共方法 ---

## 导出规则摘要。
## @return 规则摘要字典。
func describe() -> Dictionary:
	var result := super.describe()
	result["allowed_values"] = GFVariantData.duplicate_variant(allowed_values)
	result["case_sensitive"] = case_sensitive
	return result


# --- 可重写钩子 ---

func _get_default_rule_id() -> StringName:
	return &"set"


func _validate_value(value: Variant, context: Dictionary, report: Dictionary) -> void:
	var lookup := _build_lookup()
	if not lookup.has(_make_comparison_key(value)):
		_add_issue(report, context, "set_value_not_allowed", "值不在允许集合中。")


# --- 私有/辅助方法 ---

func _build_lookup() -> Dictionary:
	var lookup: Dictionary = {}
	for value: Variant in allowed_values:
		lookup[_make_comparison_key(value)] = true
	return lookup


func _make_comparison_key(value: Variant) -> String:
	if not case_sensitive and (typeof(value) == TYPE_STRING or typeof(value) == TYPE_STRING_NAME):
		return "string:%s" % String(value).to_lower()
	return _make_variant_key(value)
