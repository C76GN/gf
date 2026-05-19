## GFNetworkContractField: 网络契约中的单个 payload 字段。
##
## 字段只描述名称、值类型、必填性和默认值，用于生成器、校验器或项目工具，
## 不规定消息含义、权限或同步策略。
class_name GFNetworkContractField
extends Resource


# --- 枚举 ---

## 字段值类型。
enum ValueType {
	## 任意 Variant。
	VARIANT,
	## 布尔值。
	BOOL,
	## 整数。
	INT,
	## 浮点数。
	FLOAT,
	## 字符串。
	STRING,
	## StringName。
	STRING_NAME,
	## Vector2。
	VECTOR2,
	## Vector3。
	VECTOR3,
	## Vector2i。
	VECTOR2I,
	## Vector3i。
	VECTOR3I,
	## Color。
	COLOR,
	## Dictionary。
	DICTIONARY,
	## Array。
	ARRAY,
	## NodePath。
	NODE_PATH,
	## Object 或 Resource。
	OBJECT,
}


# --- 常量 ---

const GFValidationReportDictionaryBase = preload("res://addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd")


# --- 导出变量 ---

## 字段稳定名称。
@export var field_name: StringName = &""

## 编辑器展示名称。
@export var display_name: String = ""

## 字段值类型。
@export var value_type: ValueType = ValueType.VARIANT

## 是否为必填字段。
@export var required: bool = true

## 是否允许显式 null 值。
@export var allow_null: bool = false

## 可选默认值。生成器会尽量把可表达的默认值写入生成函数签名。
@export var default_value: Variant = null

## Object / Resource 字段的类名提示，仅用于工具校验。
@export var class_name_hint: StringName = &""

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取字段名称。
## @return 字段名称。
func get_field_name() -> StringName:
	return field_name


## 获取展示名称。
## @return 展示名称。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if field_name != &"":
		return String(field_name)
	return "Network Field"


## 获取默认值副本。
## @return 默认值。
func get_default_value() -> Variant:
	return _duplicate_value(default_value)


## 归一化字段值。
## @param value: 输入值。
## @return 归一化后的值。
func normalize_value(value: Variant) -> Variant:
	if value == null and default_value != null:
		return get_default_value()
	return _duplicate_value(value)


## 校验字段定义是否完整。
## @return 校验报告字典。
func validate_definition() -> Dictionary:
	var issues: Array[Dictionary] = []
	if field_name == &"":
		issues.append(_make_issue("error", "empty_field_name", "Network contract field name is empty."))
	return _finalize_report(issues)


## 校验字段值是否符合声明类型。
## @param value: 字段值。
## @return 校验报告字典。
func validate_value(value: Variant) -> Dictionary:
	if value == null:
		if required and not allow_null:
			return _finalize_report([_make_issue("error", "null_not_allowed", "Network contract field does not allow null.")])
		return _finalize_report([])

	var issue := _get_value_type_issue(value)
	if issue.is_empty():
		return _finalize_report([])
	return _finalize_report([issue])


## 描述字段契约。
## @return 描述字典。
func describe() -> Dictionary:
	return {
		"field_name": field_name,
		"display_name": get_display_name(),
		"value_type": value_type,
		"required": required,
		"allow_null": allow_null,
		"default_value": get_default_value(),
		"class_name_hint": class_name_hint,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _get_value_type_issue(value: Variant) -> Dictionary:
	match value_type:
		ValueType.BOOL:
			if not (value is bool):
				return _make_type_issue("bool")
		ValueType.INT:
			if typeof(value) != TYPE_INT:
				return _make_type_issue("int")
		ValueType.FLOAT:
			if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
				return _make_type_issue("float")
		ValueType.STRING:
			if not (value is String):
				return _make_type_issue("String")
		ValueType.STRING_NAME:
			if not (value is StringName):
				return _make_type_issue("StringName")
		ValueType.VECTOR2:
			if not (value is Vector2):
				return _make_type_issue("Vector2")
		ValueType.VECTOR3:
			if not (value is Vector3):
				return _make_type_issue("Vector3")
		ValueType.VECTOR2I:
			if not (value is Vector2i):
				return _make_type_issue("Vector2i")
		ValueType.VECTOR3I:
			if not (value is Vector3i):
				return _make_type_issue("Vector3i")
		ValueType.COLOR:
			if not (value is Color):
				return _make_type_issue("Color")
		ValueType.DICTIONARY:
			if not (value is Dictionary):
				return _make_type_issue("Dictionary")
		ValueType.ARRAY:
			if not (value is Array):
				return _make_type_issue("Array")
		ValueType.NODE_PATH:
			if not (value is NodePath):
				return _make_type_issue("NodePath")
		ValueType.OBJECT:
			if not (value is Object):
				return _make_type_issue("Object")
			if class_name_hint != &"" and not _object_matches_class_hint(value as Object):
				return _make_issue("error", "class_name_mismatch", "Network contract field object class does not match.")
		_:
			pass
	return {}


func _object_matches_class_hint(value: Object) -> bool:
	if value == null or class_name_hint == &"":
		return true

	var hint := String(class_name_hint)
	if value.is_class(hint):
		return true

	var script := value.get_script() as Script
	while script != null:
		if String(script.get_global_name()) == hint or script.resource_path == hint:
			return true
		script = script.get_base_script()
	return false


func _make_type_issue(expected_type: String) -> Dictionary:
	return _make_issue("error", "type_mismatch", "Network contract field expected %s." % expected_type)


func _make_issue(severity: String, kind: String, message: String) -> Dictionary:
	var issue := {
		"severity": severity,
		"kind": kind,
		"field_name": field_name,
		"message": message,
	}
	if field_name != &"":
		issue["path"] = String(field_name)
	return issue


func _finalize_report(issues: Array[Dictionary]) -> Dictionary:
	var report := {
		"subject": "Network contract field",
		"field_name": field_name,
		"issues": issues,
	}
	return GFValidationReportDictionaryBase.finalize_report(report, "Network contract field", {
		"include_issue_count": true,
		"next_actions": _get_validation_next_actions(),
	})


func _get_validation_next_actions() -> Dictionary:
	return {
		"empty_field_name": "Assign every network contract field a stable field_name.",
		"null_not_allowed": "Provide a value or allow null for this network contract field.",
		"type_mismatch": "Send a value matching the declared network contract field type.",
		"class_name_mismatch": "Send an Object or Resource matching class_name_hint.",
	}


func _duplicate_value(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	if value is PackedStringArray:
		return (value as PackedStringArray).duplicate()
	if value is PackedByteArray:
		return (value as PackedByteArray).duplicate()
	if value is PackedFloat32Array:
		return (value as PackedFloat32Array).duplicate()
	if value is PackedFloat64Array:
		return (value as PackedFloat64Array).duplicate()
	if value is PackedInt32Array:
		return (value as PackedInt32Array).duplicate()
	if value is PackedInt64Array:
		return (value as PackedInt64Array).duplicate()
	return value
