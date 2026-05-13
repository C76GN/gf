## GFConfigRangeValidationRule: 数值范围校验规则。
##
## 用于声明字段数值上下限。上下限可以单独启用，比较方式可选择是否包含边界。
class_name GFConfigRangeValidationRule
extends GFConfigValidationRule


# --- 导出变量 ---

## 是否检查最小值。
@export var has_minimum: bool = false

## 最小值。
@export var minimum: float = 0.0

## 最小值是否包含边界。
@export var inclusive_minimum: bool = true

## 是否检查最大值。
@export var has_maximum: bool = false

## 最大值。
@export var maximum: float = 0.0

## 最大值是否包含边界。
@export var inclusive_maximum: bool = true


# --- 公共方法 ---

## 导出规则摘要。
## @return 规则摘要字典。
func describe() -> Dictionary:
	var result := super.describe()
	result["has_minimum"] = has_minimum
	result["minimum"] = minimum
	result["inclusive_minimum"] = inclusive_minimum
	result["has_maximum"] = has_maximum
	result["maximum"] = maximum
	result["inclusive_maximum"] = inclusive_maximum
	return result


# --- 可重写钩子 ---

func _get_default_rule_id() -> StringName:
	return &"range"


func _validate_value(value: Variant, context: Dictionary, report: Dictionary) -> void:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		_add_issue(report, context, "range_invalid_type", "范围校验只支持 int 或 float。")
		return

	var number := float(value)
	if is_nan(number) or is_inf(number):
		_add_issue(report, context, "range_invalid_number", "数值必须是有限数字。")
		return
	if has_minimum and not _passes_minimum(number):
		_add_issue(report, context, "range_below_minimum", "数值小于允许范围。")
	if has_maximum and not _passes_maximum(number):
		_add_issue(report, context, "range_above_maximum", "数值大于允许范围。")


# --- 私有/辅助方法 ---

func _passes_minimum(value: float) -> bool:
	return value >= minimum if inclusive_minimum else value > minimum


func _passes_maximum(value: float) -> bool:
	return value <= maximum if inclusive_maximum else value < maximum
