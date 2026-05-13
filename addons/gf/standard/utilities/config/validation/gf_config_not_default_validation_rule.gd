## GFConfigNotDefaultValidationRule: 非默认值校验规则。
##
## 用于要求字段显式填写有效值。默认值可以按类型推导，也可以由项目指定。
class_name GFConfigNotDefaultValidationRule
extends GFConfigValidationRule


# --- 导出变量 ---

## 是否按输入值类型推导默认值。
@export var use_type_default: bool = true

## use_type_default 为 false 时使用的默认值。
@export var default_value: Variant = null


# --- Godot 生命周期方法 ---

func _init() -> void:
	allow_null = false


# --- 公共方法 ---

## 导出规则摘要。
## @return 规则摘要字典。
func describe() -> Dictionary:
	var result := super.describe()
	result["use_type_default"] = use_type_default
	result["default_value"] = GFVariantData.duplicate_variant(default_value)
	return result


# --- 可重写钩子 ---

func _get_default_rule_id() -> StringName:
	return &"not_default"


func _validate_value(value: Variant, context: Dictionary, report: Dictionary) -> void:
	var compared_default: Variant = _get_type_default(value) if use_type_default else default_value
	if _make_variant_key(value) == _make_variant_key(compared_default):
		_add_issue(report, context, "default_value_not_allowed", "值不能等于默认值。")


# --- 私有/辅助方法 ---

func _get_type_default(value: Variant) -> Variant:
	match typeof(value):
		TYPE_BOOL:
			return false
		TYPE_INT:
			return 0
		TYPE_FLOAT:
			return 0.0
		TYPE_STRING:
			return ""
		TYPE_STRING_NAME:
			return &""
		TYPE_ARRAY:
			return []
		TYPE_DICTIONARY:
			return {}
		TYPE_VECTOR2:
			return Vector2.ZERO
		TYPE_VECTOR2I:
			return Vector2i.ZERO
		TYPE_VECTOR3:
			return Vector3.ZERO
		TYPE_VECTOR3I:
			return Vector3i.ZERO
		TYPE_COLOR:
			return Color()
		_:
			return null
