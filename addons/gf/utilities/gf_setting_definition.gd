## GFSettingDefinition: 单个运行时设置项的声明。
##
## 只描述稳定键、默认值、值类型和持久化策略，不绑定具体 UI 或业务含义。
class_name GFSettingDefinition
extends Resource


# --- 枚举 ---

## 设置值类型，用于运行时输入钳制和持久化恢复。
enum ValueType {
	## 不做类型转换。
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
	## Vector2。
	VECTOR2,
	## Vector2i。
	VECTOR2I,
	## Color。
	COLOR,
	## Dictionary。
	DICTIONARY,
	## Array。
	ARRAY,
}


# --- 导出变量 ---

## 设置项稳定键。建议使用 `category/name` 形式。
@export var key: StringName = &""

## 默认值。
@export var default_value: Variant = null

## 值类型。
@export var value_type: ValueType = ValueType.ANY

## 是否参与持久化保存。
@export var persistent: bool = true

## 可选元数据，供设置界面分组、排序或展示使用。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取稳定设置键。
## @return 设置键；未显式设置时尝试使用资源路径。
func get_setting_key() -> StringName:
	if key != &"":
		return key
	if not resource_path.is_empty():
		return StringName(resource_path)
	return &""


## 将输入值转换为当前定义要求的类型。
## @param value: 输入值。
## @return 转换后的值。
func coerce_value(value: Variant) -> Variant:
	match value_type:
		ValueType.BOOL:
			return bool(value)
		ValueType.INT:
			return int(value)
		ValueType.FLOAT:
			return float(value)
		ValueType.STRING:
			return String(value)
		ValueType.STRING_NAME:
			return StringName(value)
		ValueType.VECTOR2:
			return _coerce_vector2(value)
		ValueType.VECTOR2I:
			return _coerce_vector2i(value)
		ValueType.COLOR:
			return _coerce_color(value)
		ValueType.DICTIONARY:
			return (value as Dictionary).duplicate(true) if value is Dictionary else {}
		ValueType.ARRAY:
			return (value as Array).duplicate(true) if value is Array else []
		_:
			return value


## 检查值是否符合声明类型。
## @param value: 待检查值。
## @return 符合时返回 true。
func is_value_valid(value: Variant) -> bool:
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
		ValueType.VECTOR2:
			return value is Vector2
		ValueType.VECTOR2I:
			return value is Vector2i
		ValueType.COLOR:
			return value is Color
		ValueType.DICTIONARY:
			return value is Dictionary
		ValueType.ARRAY:
			return value is Array
		_:
			return true


## 创建同内容拷贝，避免运行时修改污染共享资源。
## @return 新定义。
func duplicate_definition() -> GFSettingDefinition:
	var definition := GFSettingDefinition.new()
	definition.key = key
	definition.default_value = _duplicate_collection(default_value)
	definition.value_type = value_type
	definition.persistent = persistent
	definition.metadata = metadata.duplicate(true)
	return definition


# --- 私有/辅助方法 ---

func _coerce_vector2(value: Variant) -> Vector2:
	if value is Vector2:
		return value as Vector2
	if value is Vector2i:
		var vector2i := value as Vector2i
		return Vector2(vector2i.x, vector2i.y)
	if value is Dictionary:
		var data := value as Dictionary
		return Vector2(float(data.get("x", 0.0)), float(data.get("y", 0.0)))
	return Vector2.ZERO


func _coerce_vector2i(value: Variant) -> Vector2i:
	if value is Vector2i:
		return value as Vector2i
	if value is Vector2:
		var vector2 := value as Vector2
		return Vector2i(roundi(vector2.x), roundi(vector2.y))
	if value is Dictionary:
		var data := value as Dictionary
		return Vector2i(int(data.get("x", 0)), int(data.get("y", 0)))
	return Vector2i.ZERO


func _coerce_color(value: Variant) -> Color:
	if value is Color:
		return value as Color
	if value is Dictionary:
		var data := value as Dictionary
		return Color(
			float(data.get("r", 1.0)),
			float(data.get("g", 1.0)),
			float(data.get("b", 1.0)),
			float(data.get("a", 1.0))
		)
	if typeof(value) == TYPE_STRING:
		return Color(String(value))
	return Color.WHITE


func _duplicate_collection(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value
