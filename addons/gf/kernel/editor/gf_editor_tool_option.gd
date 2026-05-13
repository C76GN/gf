@tool

## GFEditorToolOption: 编辑器工具选项声明。
##
## 用通用字段描述工具面板需要的一个选项，不绑定具体 UI 控件或资源类型。
class_name GFEditorToolOption
extends Resource


# --- 枚举 ---

## 编辑器工具选项的通用值类型。
enum ValueType {
	## 不做类型约束。
	ANY,
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
	## Color。
	COLOR,
	## Vector2。
	VECTOR2,
	## Vector2i。
	VECTOR2I,
	## NodePath。
	NODE_PATH,
	## 从 choices 中选择。
	OPTION,
}


# --- 导出变量 ---

## 选项稳定标识。
@export var option_id: StringName = &""

## 选项显示名称。
@export var label: String = ""

## 选项提示文本。
@export_multiline var tooltip: String = ""

## 选项值类型。
@export var value_type: ValueType = ValueType.ANY

## 默认值。
@export var default_value: Variant = null

## 数值最小值。
@export var min_value: float = 0.0

## 数值最大值。
@export var max_value: float = 1.0

## 数值步长。
@export var step: float = 0.01

## 可选项列表。`value_type` 为 OPTION 时用于校验。
@export var choices: Array = []

## 可选元数据，供工具 UI、持久化或项目层扩展使用。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取稳定选项标识。
## @return 选项标识。
func get_option_id() -> StringName:
	return option_id


## 检查选项声明是否有效。
## @return 有效返回 true。
func is_valid_definition() -> bool:
	return option_id != &""


## 规范化输入值。
## @param value: 输入值。
## @return 规范化后的值。
func normalize_value(value: Variant) -> Variant:
	if value == null:
		return _duplicate_variant(default_value)

	match value_type:
		ValueType.BOOL:
			return bool(value)
		ValueType.INT:
			return clampi(int(value), roundi(min_value), roundi(max_value))
		ValueType.FLOAT:
			return clampf(float(value), min_value, max_value)
		ValueType.STRING:
			return String(value)
		ValueType.STRING_NAME:
			return StringName(String(value))
		ValueType.COLOR:
			return value if value is Color else default_value
		ValueType.VECTOR2:
			return value if value is Vector2 else default_value
		ValueType.VECTOR2I:
			return value if value is Vector2i else default_value
		ValueType.NODE_PATH:
			return value if value is NodePath else NodePath(String(value))
		ValueType.OPTION:
			return value if choices.is_empty() or choices.has(value) else _duplicate_variant(default_value)
		_:
			return _duplicate_variant(value)


## 检查值是否符合选项声明。
## @param value: 待检查值。
## @return 符合声明时返回 true。
func is_value_valid(value: Variant) -> bool:
	if value == null:
		return true
	match value_type:
		ValueType.ANY:
			return true
		ValueType.BOOL:
			return typeof(value) == TYPE_BOOL
		ValueType.INT:
			return typeof(value) == TYPE_INT
		ValueType.FLOAT:
			return typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT
		ValueType.STRING:
			return typeof(value) == TYPE_STRING
		ValueType.STRING_NAME:
			return typeof(value) == TYPE_STRING_NAME
		ValueType.COLOR:
			return value is Color
		ValueType.VECTOR2:
			return value is Vector2
		ValueType.VECTOR2I:
			return value is Vector2i
		ValueType.NODE_PATH:
			return value is NodePath
		ValueType.OPTION:
			return choices.is_empty() or choices.has(value)
		_:
			return true


## 创建同内容拷贝。
## @return 新选项声明。
func duplicate_option() -> GFEditorToolOption:
	var option := GFEditorToolOption.new()
	option.option_id = option_id
	option.label = label
	option.tooltip = tooltip
	option.value_type = value_type
	option.default_value = _duplicate_variant(default_value)
	option.min_value = min_value
	option.max_value = max_value
	option.step = step
	option.choices = choices.duplicate(true)
	option.metadata = metadata.duplicate(true)
	return option


## 导出选项声明摘要。
## @return 选项声明字典。
func describe() -> Dictionary:
	return {
		"option_id": option_id,
		"label": label,
		"tooltip": tooltip,
		"value_type": value_type,
		"default_value": _duplicate_variant(default_value),
		"min_value": min_value,
		"max_value": max_value,
		"step": step,
		"choices": choices.duplicate(true),
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _duplicate_variant(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value
