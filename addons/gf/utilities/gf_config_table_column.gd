## GFConfigTableColumn: 导表字段声明。
##
## 只描述字段名、值类型、必填性、空值策略和默认值，不绑定任何具体业务表。
class_name GFConfigTableColumn
extends Resource


# --- 枚举 ---

## 导表字段值类型，用于导入与运行时校验。
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

## 字段名。建议和导表列名保持一致。
@export var field_name: StringName = &""

## 字段值类型。
@export var value_type: ValueType = ValueType.ANY

## 是否必须出现在记录中。
@export var required: bool = false

## 是否允许 null 值。
@export var allow_null: bool = true

## 字段缺省值。`GFConfigTableSchema.coerce_record()` 会在缺字段时使用。
@export var default_value: Variant = null

## 可选元数据，供编辑器、导入器或项目层扩展使用。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取稳定字段键。
## @return 字段名。
func get_field_key() -> StringName:
	return field_name


## 将输入值转换为当前列要求的类型。
## @param value: 输入值。
## @return 转换后的值。
func coerce_value(value: Variant) -> Variant:
	if value == null:
		return null

	match value_type:
		ValueType.BOOL:
			return _coerce_bool(value)
		ValueType.INT:
			return int(value)
		ValueType.FLOAT:
			return float(value)
		ValueType.STRING:
			return str(value)
		ValueType.STRING_NAME:
			return StringName(str(value))
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


## 检查输入值是否符合当前列声明。
## @param value: 待检查值。
## @return 符合声明时返回 true。
func is_value_valid(value: Variant) -> bool:
	if value == null:
		return allow_null

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


## 创建同内容拷贝，避免运行时修改污染共享 Resource。
## @return 新字段声明。
func duplicate_column() -> GFConfigTableColumn:
	var column: GFConfigTableColumn = GFConfigTableColumn.new()
	column.field_name = field_name
	column.value_type = value_type
	column.required = required
	column.allow_null = allow_null
	column.default_value = _duplicate_collection(default_value)
	column.metadata = metadata.duplicate(true)
	return column


## 导出字段声明摘要。
## @return 字段声明字典。
func describe() -> Dictionary:
	return {
		"field_name": field_name,
		"value_type": value_type,
		"required": required,
		"allow_null": allow_null,
		"default_value": _duplicate_collection(default_value),
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _coerce_bool(value: Variant) -> bool:
	if typeof(value) == TYPE_STRING:
		var text := str(value).strip_edges().to_lower()
		return text == "true" or text == "1" or text == "yes" or text == "on"
	return bool(value)


func _coerce_vector2(value: Variant) -> Vector2:
	if value is Vector2:
		return value as Vector2
	if value is Vector2i:
		var vector2i := value as Vector2i
		return Vector2(vector2i.x, vector2i.y)
	if value is Dictionary:
		var data := value as Dictionary
		return Vector2(float(data.get("x", 0.0)), float(data.get("y", 0.0)))
	if value is Array:
		var values := value as Array
		if values.size() >= 2:
			return Vector2(float(values[0]), float(values[1]))
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
	if value is Array:
		var values := value as Array
		if values.size() >= 2:
			return Vector2i(int(values[0]), int(values[1]))
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
	if value is Array:
		var values := value as Array
		if values.size() >= 3:
			return Color(
				float(values[0]),
				float(values[1]),
				float(values[2]),
				float(values[3]) if values.size() >= 4 else 1.0
			)
	if typeof(value) == TYPE_STRING:
		return Color(str(value))
	return Color.WHITE


func _duplicate_collection(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value
