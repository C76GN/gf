## GFNetworkFieldSerializer: 网络状态字段编码器。
##
## 将常见 Godot 值归一化为可序列化 Variant。它只处理字段值的形态转换，
## 不规定同步方向、可靠性、预测、回滚或冲突解决策略。
class_name GFNetworkFieldSerializer
extends Resource


# --- 枚举 ---

## 字段值类型。
enum ValueType {
	## 保持原始 Variant。
	VARIANT,
	## 布尔值。
	BOOL,
	## 整数。
	INT,
	## 浮点数。
	FLOAT,
	## 字符串。
	STRING,
	## StringName，编码时使用 String。
	STRING_NAME,
	## Vector2，编码为两个数值。
	VECTOR2,
	## Vector3，编码为三个数值。
	VECTOR3,
	## Vector2i，编码为两个整数。
	VECTOR2I,
	## Vector3i，编码为三个整数。
	VECTOR3I,
	## Color，编码为四个数值。
	COLOR,
}


# --- 导出变量 ---

## 字段值类型。
@export var value_type: ValueType = ValueType.VARIANT

## 浮点量化小数位；小于 0 表示不量化。
@export_range(-1, 8, 1) var quantize_decimals: int = -1

## 是否夹取数值。
@export var clamp_enabled: bool = false

## 数值夹取下限。
@export var min_value: float = 0.0

## 数值夹取上限。
@export var max_value: float = 1.0


# --- 公共方法 ---

## 编码字段值。
## @param value: 原始值。
## @return 可序列化值。
func serialize_value(value: Variant) -> Variant:
	match value_type:
		ValueType.BOOL:
			return bool(value)
		ValueType.INT:
			return int(roundf(_apply_number_policy(float(value))))
		ValueType.FLOAT:
			return _apply_number_policy(float(value))
		ValueType.STRING:
			return str(value)
		ValueType.STRING_NAME:
			return String(value)
		ValueType.VECTOR2:
			return _serialize_vector2(value)
		ValueType.VECTOR3:
			return _serialize_vector3(value)
		ValueType.VECTOR2I:
			return _serialize_vector2i(value)
		ValueType.VECTOR3I:
			return _serialize_vector3i(value)
		ValueType.COLOR:
			return _serialize_color(value)
		_:
			return GFVariantData.duplicate_variant(value)


## 解码字段值。
## @param value: 编码值。
## @return 解码后的值。
func deserialize_value(value: Variant) -> Variant:
	match value_type:
		ValueType.BOOL:
			return bool(value)
		ValueType.INT:
			return int(value)
		ValueType.FLOAT:
			return float(value)
		ValueType.STRING:
			return str(value)
		ValueType.STRING_NAME:
			return StringName(str(value))
		ValueType.VECTOR2:
			return _deserialize_vector2(value)
		ValueType.VECTOR3:
			return _deserialize_vector3(value)
		ValueType.VECTOR2I:
			return _deserialize_vector2i(value)
		ValueType.VECTOR3I:
			return _deserialize_vector3i(value)
		ValueType.COLOR:
			return _deserialize_color(value)
		_:
			return GFVariantData.duplicate_variant(value)


## 复制编码器配置。
## @return 新编码器。
func duplicate_serializer() -> GFNetworkFieldSerializer:
	var serializer := GFNetworkFieldSerializer.new()
	serializer.value_type = value_type
	serializer.quantize_decimals = quantize_decimals
	serializer.clamp_enabled = clamp_enabled
	serializer.min_value = min_value
	serializer.max_value = max_value
	return serializer


# --- 私有/辅助方法 ---

func _apply_number_policy(value: float) -> float:
	var result := value
	if clamp_enabled:
		result = clampf(result, minf(min_value, max_value), maxf(min_value, max_value))
	if quantize_decimals >= 0:
		var scale := pow(10.0, float(quantize_decimals))
		result = roundf(result * scale) / scale
	return result


func _serialize_vector2(value: Variant) -> Array:
	var vector := Vector2.ZERO
	if value is Vector2:
		vector = value as Vector2
	return [
		_apply_number_policy(vector.x),
		_apply_number_policy(vector.y),
	]


func _serialize_vector3(value: Variant) -> Array:
	var vector := Vector3.ZERO
	if value is Vector3:
		vector = value as Vector3
	return [
		_apply_number_policy(vector.x),
		_apply_number_policy(vector.y),
		_apply_number_policy(vector.z),
	]


func _serialize_vector2i(value: Variant) -> Array:
	var vector := Vector2i.ZERO
	if value is Vector2i:
		vector = value as Vector2i
	return [
		vector.x,
		vector.y,
	]


func _serialize_vector3i(value: Variant) -> Array:
	var vector := Vector3i.ZERO
	if value is Vector3i:
		vector = value as Vector3i
	return [
		vector.x,
		vector.y,
		vector.z,
	]


func _serialize_color(value: Variant) -> Array:
	var color := Color.WHITE
	if value is Color:
		color = value as Color
	return [
		_apply_number_policy(color.r),
		_apply_number_policy(color.g),
		_apply_number_policy(color.b),
		_apply_number_policy(color.a),
	]


func _deserialize_vector2(value: Variant) -> Vector2:
	var values := _read_array(value)
	return Vector2(
		float(values[0]) if values.size() > 0 else 0.0,
		float(values[1]) if values.size() > 1 else 0.0
	)


func _deserialize_vector3(value: Variant) -> Vector3:
	var values := _read_array(value)
	return Vector3(
		float(values[0]) if values.size() > 0 else 0.0,
		float(values[1]) if values.size() > 1 else 0.0,
		float(values[2]) if values.size() > 2 else 0.0
	)


func _deserialize_vector2i(value: Variant) -> Vector2i:
	var values := _read_array(value)
	return Vector2i(
		int(values[0]) if values.size() > 0 else 0,
		int(values[1]) if values.size() > 1 else 0
	)


func _deserialize_vector3i(value: Variant) -> Vector3i:
	var values := _read_array(value)
	return Vector3i(
		int(values[0]) if values.size() > 0 else 0,
		int(values[1]) if values.size() > 1 else 0,
		int(values[2]) if values.size() > 2 else 0
	)


func _deserialize_color(value: Variant) -> Color:
	var values := _read_array(value)
	return Color(
		float(values[0]) if values.size() > 0 else 1.0,
		float(values[1]) if values.size() > 1 else 1.0,
		float(values[2]) if values.size() > 2 else 1.0,
		float(values[3]) if values.size() > 3 else 1.0
	)


func _read_array(value: Variant) -> Array:
	if value is Array:
		return value as Array
	if value is PackedFloat32Array:
		return Array(value as PackedFloat32Array)
	if value is PackedFloat64Array:
		return Array(value as PackedFloat64Array)
	if value is PackedInt32Array:
		return Array(value as PackedInt32Array)
	if value is PackedInt64Array:
		return Array(value as PackedInt64Array)
	return []
