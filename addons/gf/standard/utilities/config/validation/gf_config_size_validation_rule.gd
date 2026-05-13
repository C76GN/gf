## GFConfigSizeValidationRule: 长度或数量校验规则。
##
## 用于校验 String、Array、Dictionary、PackedArray 字段，或整表记录数量。
class_name GFConfigSizeValidationRule
extends GFConfigValidationRule


# --- 导出变量 ---

## 是否检查最小数量。
@export var has_minimum_size: bool = false

## 最小数量。
@export var minimum_size: int = 0

## 是否检查最大数量。
@export var has_maximum_size: bool = false

## 最大数量。
@export var maximum_size: int = 0


# --- 公共方法 ---

## 导出规则摘要。
## @return 规则摘要字典。
func describe() -> Dictionary:
	var result := super.describe()
	result["has_minimum_size"] = has_minimum_size
	result["minimum_size"] = minimum_size
	result["has_maximum_size"] = has_maximum_size
	result["maximum_size"] = maximum_size
	return result


# --- 可重写钩子 ---

func _get_default_rule_id() -> StringName:
	return &"size"


func _validate_value(value: Variant, context: Dictionary, report: Dictionary) -> void:
	var size := _get_value_size(value)
	if size < 0:
		_add_issue(report, context, "size_invalid_type", "数量校验只支持 String、Array、Dictionary 或 PackedArray。")
		return
	_validate_size(size, context, report, "size_out_of_range")


func _validate_table(rows: Array[Dictionary], context: Dictionary, report: Dictionary) -> void:
	_validate_size(rows.size(), context, report, "table_size_out_of_range")


# --- 私有/辅助方法 ---

func _validate_size(size: int, context: Dictionary, report: Dictionary, code: String) -> void:
	if has_minimum_size and size < minimum_size:
		_add_issue(report, context, code, "数量小于允许范围。")
	if has_maximum_size and size > maximum_size:
		_add_issue(report, context, code, "数量大于允许范围。")


func _get_value_size(value: Variant) -> int:
	match typeof(value):
		TYPE_STRING, TYPE_STRING_NAME:
			return String(value).length()
		TYPE_ARRAY:
			return (value as Array).size()
		TYPE_DICTIONARY:
			return (value as Dictionary).size()
		TYPE_PACKED_BYTE_ARRAY:
			return (value as PackedByteArray).size()
		TYPE_PACKED_INT32_ARRAY:
			return (value as PackedInt32Array).size()
		TYPE_PACKED_INT64_ARRAY:
			return (value as PackedInt64Array).size()
		TYPE_PACKED_FLOAT32_ARRAY:
			return (value as PackedFloat32Array).size()
		TYPE_PACKED_FLOAT64_ARRAY:
			return (value as PackedFloat64Array).size()
		TYPE_PACKED_STRING_ARRAY:
			return (value as PackedStringArray).size()
		TYPE_PACKED_VECTOR2_ARRAY:
			return (value as PackedVector2Array).size()
		TYPE_PACKED_VECTOR3_ARRAY:
			return (value as PackedVector3Array).size()
		TYPE_PACKED_COLOR_ARRAY:
			return (value as PackedColorArray).size()
		_:
			return -1
