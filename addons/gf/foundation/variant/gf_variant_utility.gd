## GFVariantUtility: 通用 Variant、Dictionary 与数组转换辅助。
##
## 该类不依赖 GFArchitecture，适合在 Foundation、Utility 和 Extension 中复用
## 深拷贝、默认值合并以及 JSON 友好的 Godot Variant 转换逻辑。
class_name GFVariantUtility
extends RefCounted


# --- 常量 ---

const JSON_TYPE_KEY: String = "_gf_type"
const JSON_VALUE_KEY: String = "value"


# --- 公共方法 ---

## 深拷贝 Dictionary 或 Array；其他 Variant 原样返回。
## @param value: 待复制的值。
## @return 复制后的值。
static func duplicate_variant(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value


## 深拷贝集合值；语义同 duplicate_variant()，便于集合字段调用处表达意图。
## @param value: 待复制的值。
## @return 复制后的值。
static func duplicate_collection(value: Variant) -> Variant:
	return duplicate_variant(value)


## 将 defaults 中缺失的字段递归合并到 base。
## @param base: 会被原地补齐的目标字典。
## @param defaults: 默认值字典。
## @return 已补齐的 base 字典。
static func deep_merge_defaults(base: Dictionary, defaults: Dictionary) -> Dictionary:
	for key: Variant in defaults.keys():
		if not base.has(key):
			base[key] = duplicate_variant(defaults[key])
			continue
		if base[key] is Dictionary and defaults[key] is Dictionary:
			deep_merge_defaults(base[key], defaults[key])
	return base


## 将 Variant 转为 JSON.stringify() 可安全编码的值。
## @param value: 待转换的 Variant。
## @param options: 可选项；encode_dictionary_keys 为 true 时会保留非字符串字典键。
## @return JSON 兼容值；Godot 专有类型会带类型标记。
static func variant_to_json_compatible(value: Variant, options: Dictionary = {}) -> Variant:
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			return value
		TYPE_STRING_NAME:
			return _make_json_typed_value("StringName", String(value))
		TYPE_NODE_PATH:
			return _make_json_typed_value("NodePath", String(value))
		TYPE_VECTOR2:
			var vector_2: Vector2 = value as Vector2
			return _make_json_typed_value("Vector2", [vector_2.x, vector_2.y])
		TYPE_VECTOR2I:
			var vector_2i: Vector2i = value as Vector2i
			return _make_json_typed_value("Vector2i", [vector_2i.x, vector_2i.y])
		TYPE_VECTOR3:
			var vector_3: Vector3 = value as Vector3
			return _make_json_typed_value("Vector3", [vector_3.x, vector_3.y, vector_3.z])
		TYPE_VECTOR3I:
			var vector_3i: Vector3i = value as Vector3i
			return _make_json_typed_value("Vector3i", [vector_3i.x, vector_3i.y, vector_3i.z])
		TYPE_VECTOR4:
			var vector_4: Vector4 = value as Vector4
			return _make_json_typed_value("Vector4", [vector_4.x, vector_4.y, vector_4.z, vector_4.w])
		TYPE_VECTOR4I:
			var vector_4i: Vector4i = value as Vector4i
			return _make_json_typed_value("Vector4i", [vector_4i.x, vector_4i.y, vector_4i.z, vector_4i.w])
		TYPE_RECT2:
			var rect_2: Rect2 = value as Rect2
			return _make_json_typed_value("Rect2", [rect_2.position.x, rect_2.position.y, rect_2.size.x, rect_2.size.y])
		TYPE_RECT2I:
			var rect_2i: Rect2i = value as Rect2i
			return _make_json_typed_value("Rect2i", [rect_2i.position.x, rect_2i.position.y, rect_2i.size.x, rect_2i.size.y])
		TYPE_COLOR:
			var color: Color = value as Color
			return _make_json_typed_value("Color", [color.r, color.g, color.b, color.a])
		TYPE_PLANE:
			var plane: Plane = value as Plane
			return _make_json_typed_value("Plane", [plane.normal.x, plane.normal.y, plane.normal.z, plane.d])
		TYPE_QUATERNION:
			var quaternion: Quaternion = value as Quaternion
			return _make_json_typed_value("Quaternion", [quaternion.x, quaternion.y, quaternion.z, quaternion.w])
		TYPE_AABB:
			var aabb: AABB = value as AABB
			return _make_json_typed_value("AABB", [aabb.position.x, aabb.position.y, aabb.position.z, aabb.size.x, aabb.size.y, aabb.size.z])
		TYPE_BASIS:
			return _make_json_typed_value("Basis", _basis_to_array(value as Basis))
		TYPE_TRANSFORM2D:
			return _make_json_typed_value("Transform2D", _transform_2d_to_array(value as Transform2D))
		TYPE_TRANSFORM3D:
			var transform_3d: Transform3D = value as Transform3D
			return _make_json_typed_value("Transform3D", {
				"basis": _basis_to_array(transform_3d.basis),
				"origin": [transform_3d.origin.x, transform_3d.origin.y, transform_3d.origin.z],
			})
		TYPE_ARRAY:
			var result_array: Array = []
			for item: Variant in value as Array:
				result_array.append(variant_to_json_compatible(item, options))
			return result_array
		TYPE_DICTIONARY:
			return _dictionary_to_json_compatible(value as Dictionary, options)
		TYPE_PACKED_BYTE_ARRAY:
			return _make_json_typed_value("PackedByteArray", _packed_byte_array_to_array(value as PackedByteArray))
		TYPE_PACKED_INT32_ARRAY:
			return _make_json_typed_value("PackedInt32Array", _packed_int32_array_to_array(value as PackedInt32Array))
		TYPE_PACKED_INT64_ARRAY:
			return _make_json_typed_value("PackedInt64Array", _packed_int64_array_to_array(value as PackedInt64Array))
		TYPE_PACKED_FLOAT32_ARRAY:
			return _make_json_typed_value("PackedFloat32Array", _packed_float32_array_to_array(value as PackedFloat32Array))
		TYPE_PACKED_FLOAT64_ARRAY:
			return _make_json_typed_value("PackedFloat64Array", _packed_float64_array_to_array(value as PackedFloat64Array))
		TYPE_PACKED_STRING_ARRAY:
			return _make_json_typed_value("PackedStringArray", _packed_string_array_to_array(value as PackedStringArray))
		TYPE_PACKED_VECTOR2_ARRAY:
			return _make_json_typed_value("PackedVector2Array", _packed_vector2_array_to_array(value as PackedVector2Array))
		TYPE_PACKED_VECTOR3_ARRAY:
			return _make_json_typed_value("PackedVector3Array", _packed_vector3_array_to_array(value as PackedVector3Array))
		TYPE_PACKED_COLOR_ARRAY:
			return _make_json_typed_value("PackedColorArray", _packed_color_array_to_array(value as PackedColorArray))
		TYPE_PACKED_VECTOR4_ARRAY:
			return _make_json_typed_value("PackedVector4Array", _packed_vector4_array_to_array(value as PackedVector4Array))
		_:
			if String(options.get("unsupported", "null")) == "string":
				return str(value)
	return null


## 从 variant_to_json_compatible() 生成的值恢复 Godot Variant。
## @param value: JSON.parse_string() 后的值。
## @param options: 可选项；decode_typed_markers 为 false 时只递归恢复集合。
## @return 恢复后的 Variant。
static func json_compatible_to_variant(value: Variant, options: Dictionary = {}) -> Variant:
	if value is Array:
		var result_array: Array = []
		for item: Variant in value as Array:
			result_array.append(json_compatible_to_variant(item, options))
		return result_array

	if value is Dictionary:
		var dictionary := value as Dictionary
		if bool(options.get("decode_typed_markers", true)) and _is_json_typed_value(dictionary):
			return _json_typed_value_to_variant(dictionary, options)

		var result: Dictionary = {}
		for key: Variant in dictionary.keys():
			result[key] = json_compatible_to_variant(dictionary[key], options)
		return result

	return value


## 将 Vector2 转成 JSON 友好的数组。
## @param value: 待转换的 Vector2。
## @return [x, y] 数组。
static func vector2_to_array(value: Vector2) -> Array[float]:
	return [value.x, value.y]


## 从数组读取 Vector2，失败时返回 fallback。
## @param value: 输入值。
## @param fallback: 转换失败时返回的值。
## @return Vector2 值。
static func array_to_vector2(value: Variant, fallback: Vector2 = Vector2.ZERO) -> Vector2:
	if not (value is Array):
		return fallback

	var array := value as Array
	if array.size() < 2:
		return fallback
	return Vector2(float(array[0]), float(array[1]))


## 将 Vector3 转成 JSON 友好的数组。
## @param value: 待转换的 Vector3。
## @return [x, y, z] 数组。
static func vector3_to_array(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


## 从数组读取 Vector3，失败时返回 fallback。
## @param value: 输入值。
## @param fallback: 转换失败时返回的值。
## @return Vector3 值。
static func array_to_vector3(value: Variant, fallback: Vector3 = Vector3.ZERO) -> Vector3:
	if not (value is Array):
		return fallback

	var array := value as Array
	if array.size() < 3:
		return fallback
	return Vector3(float(array[0]), float(array[1]), float(array[2]))


## 将 Color 转成 JSON 友好的数组。
## @param value: 待转换的 Color。
## @return [r, g, b, a] 数组。
static func color_to_array(value: Color) -> Array[float]:
	return [value.r, value.g, value.b, value.a]


## 从数组读取 Color，失败时返回 fallback。
## @param value: 输入值。
## @param fallback: 转换失败时返回的值。
## @return Color 值。
static func array_to_color(value: Variant, fallback: Color = Color.WHITE) -> Color:
	if not (value is Array):
		return fallback

	var array := value as Array
	if array.size() < 4:
		return fallback
	return Color(float(array[0]), float(array[1]), float(array[2]), float(array[3]))


# --- 私有/辅助方法 ---

static func _make_json_typed_value(type_name: String, typed_value: Variant) -> Dictionary:
	return {
		JSON_TYPE_KEY: type_name,
		JSON_VALUE_KEY: typed_value,
	}


static func _is_json_typed_value(value: Dictionary) -> bool:
	return value.has(JSON_TYPE_KEY) and value.has(JSON_VALUE_KEY)


static func _dictionary_to_json_compatible(value: Dictionary, options: Dictionary) -> Variant:
	if bool(options.get("encode_dictionary_keys", false)):
		var entries: Array[Dictionary] = []
		for key: Variant in value.keys():
			entries.append({
				"key": variant_to_json_compatible(key, options),
				"value": variant_to_json_compatible(value[key], options),
			})
		return _make_json_typed_value("Dictionary", entries)

	var result: Dictionary = {}
	for key: Variant in value.keys():
		result[_json_key_to_string(key)] = variant_to_json_compatible(value[key], options)
	return result


static func _json_typed_value_to_variant(value: Dictionary, options: Dictionary) -> Variant:
	var type_name := String(value.get(JSON_TYPE_KEY, ""))
	var raw_value: Variant = value.get(JSON_VALUE_KEY)
	match type_name:
		"StringName":
			return StringName(String(raw_value))
		"NodePath":
			return NodePath(String(raw_value))
		"Vector2":
			var vector_2 := _to_array(raw_value)
			return Vector2(_float_at(vector_2, 0), _float_at(vector_2, 1))
		"Vector2i":
			var vector_2i := _to_array(raw_value)
			return Vector2i(_int_at(vector_2i, 0), _int_at(vector_2i, 1))
		"Vector3":
			var vector_3 := _to_array(raw_value)
			return Vector3(_float_at(vector_3, 0), _float_at(vector_3, 1), _float_at(vector_3, 2))
		"Vector3i":
			var vector_3i := _to_array(raw_value)
			return Vector3i(_int_at(vector_3i, 0), _int_at(vector_3i, 1), _int_at(vector_3i, 2))
		"Vector4":
			var vector_4 := _to_array(raw_value)
			return Vector4(_float_at(vector_4, 0), _float_at(vector_4, 1), _float_at(vector_4, 2), _float_at(vector_4, 3))
		"Vector4i":
			var vector_4i := _to_array(raw_value)
			return Vector4i(_int_at(vector_4i, 0), _int_at(vector_4i, 1), _int_at(vector_4i, 2), _int_at(vector_4i, 3))
		"Rect2":
			var rect_2 := _to_array(raw_value)
			return Rect2(_float_at(rect_2, 0), _float_at(rect_2, 1), _float_at(rect_2, 2), _float_at(rect_2, 3))
		"Rect2i":
			var rect_2i := _to_array(raw_value)
			return Rect2i(_int_at(rect_2i, 0), _int_at(rect_2i, 1), _int_at(rect_2i, 2), _int_at(rect_2i, 3))
		"Color":
			var color := _to_array(raw_value)
			return Color(_float_at(color, 0), _float_at(color, 1), _float_at(color, 2), _float_at(color, 3, 1.0))
		"Plane":
			var plane := _to_array(raw_value)
			return Plane(Vector3(_float_at(plane, 0), _float_at(plane, 1), _float_at(plane, 2)), _float_at(plane, 3))
		"Quaternion":
			var quaternion := _to_array(raw_value)
			return Quaternion(_float_at(quaternion, 0), _float_at(quaternion, 1), _float_at(quaternion, 2), _float_at(quaternion, 3, 1.0))
		"AABB":
			var aabb := _to_array(raw_value)
			return AABB(
				Vector3(_float_at(aabb, 0), _float_at(aabb, 1), _float_at(aabb, 2)),
				Vector3(_float_at(aabb, 3), _float_at(aabb, 4), _float_at(aabb, 5))
			)
		"Basis":
			return _array_to_basis(_to_array(raw_value))
		"Transform2D":
			return _array_to_transform_2d(_to_array(raw_value))
		"Transform3D":
			return _dictionary_to_transform_3d(raw_value)
		"Dictionary":
			return _entries_to_dictionary(_to_array(raw_value), options)
		"PackedByteArray":
			return _array_to_packed_byte_array(_to_array(raw_value))
		"PackedInt32Array":
			return _array_to_packed_int32_array(_to_array(raw_value))
		"PackedInt64Array":
			return _array_to_packed_int64_array(_to_array(raw_value))
		"PackedFloat32Array":
			return _array_to_packed_float32_array(_to_array(raw_value))
		"PackedFloat64Array":
			return _array_to_packed_float64_array(_to_array(raw_value))
		"PackedStringArray":
			return _array_to_packed_string_array(_to_array(raw_value))
		"PackedVector2Array":
			return _array_to_packed_vector2_array(_to_array(raw_value))
		"PackedVector3Array":
			return _array_to_packed_vector3_array(_to_array(raw_value))
		"PackedColorArray":
			return _array_to_packed_color_array(_to_array(raw_value))
		"PackedVector4Array":
			return _array_to_packed_vector4_array(_to_array(raw_value))
	return raw_value


static func _json_key_to_string(key: Variant) -> String:
	if key is StringName:
		return String(key)
	return str(key)


static func _to_array(value: Variant) -> Array:
	return value as Array if value is Array else []


static func _float_at(array: Array, index: int, fallback: float = 0.0) -> float:
	return float(array[index]) if index >= 0 and index < array.size() else fallback


static func _int_at(array: Array, index: int, fallback: int = 0) -> int:
	return int(array[index]) if index >= 0 and index < array.size() else fallback


static func _basis_to_array(value: Basis) -> Array[float]:
	return [
		value.x.x,
		value.x.y,
		value.x.z,
		value.y.x,
		value.y.y,
		value.y.z,
		value.z.x,
		value.z.y,
		value.z.z,
	]


static func _array_to_basis(value: Array) -> Basis:
	return Basis(
		Vector3(_float_at(value, 0, 1.0), _float_at(value, 1), _float_at(value, 2)),
		Vector3(_float_at(value, 3), _float_at(value, 4, 1.0), _float_at(value, 5)),
		Vector3(_float_at(value, 6), _float_at(value, 7), _float_at(value, 8, 1.0))
	)


static func _transform_2d_to_array(value: Transform2D) -> Array[float]:
	return [
		value.x.x,
		value.x.y,
		value.y.x,
		value.y.y,
		value.origin.x,
		value.origin.y,
	]


static func _array_to_transform_2d(value: Array) -> Transform2D:
	return Transform2D(
		Vector2(_float_at(value, 0, 1.0), _float_at(value, 1)),
		Vector2(_float_at(value, 2), _float_at(value, 3, 1.0)),
		Vector2(_float_at(value, 4), _float_at(value, 5))
	)


static func _dictionary_to_transform_3d(value: Variant) -> Transform3D:
	if not (value is Dictionary):
		return Transform3D()
	var data := value as Dictionary
	var origin := _to_array(data.get("origin", []))
	return Transform3D(
		_array_to_basis(_to_array(data.get("basis", []))),
		Vector3(_float_at(origin, 0), _float_at(origin, 1), _float_at(origin, 2))
	)


static func _entries_to_dictionary(entries: Array, options: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for entry_value: Variant in entries:
		if not (entry_value is Dictionary):
			continue
		var entry := entry_value as Dictionary
		var key: Variant = json_compatible_to_variant(entry.get("key"), options)
		result[key] = json_compatible_to_variant(entry.get("value"), options)
	return result


static func _packed_byte_array_to_array(value: PackedByteArray) -> Array[int]:
	var result: Array[int] = []
	for item: int in value:
		result.append(item)
	return result


static func _array_to_packed_byte_array(value: Array) -> PackedByteArray:
	var result := PackedByteArray()
	for item: Variant in value:
		result.append(int(item))
	return result


static func _packed_int32_array_to_array(value: PackedInt32Array) -> Array[int]:
	var result: Array[int] = []
	for item: int in value:
		result.append(item)
	return result


static func _array_to_packed_int32_array(value: Array) -> PackedInt32Array:
	var result := PackedInt32Array()
	for item: Variant in value:
		result.append(int(item))
	return result


static func _packed_int64_array_to_array(value: PackedInt64Array) -> Array[int]:
	var result: Array[int] = []
	for item: int in value:
		result.append(item)
	return result


static func _array_to_packed_int64_array(value: Array) -> PackedInt64Array:
	var result := PackedInt64Array()
	for item: Variant in value:
		result.append(int(item))
	return result


static func _packed_float32_array_to_array(value: PackedFloat32Array) -> Array[float]:
	var result: Array[float] = []
	for item: float in value:
		result.append(item)
	return result


static func _array_to_packed_float32_array(value: Array) -> PackedFloat32Array:
	var result := PackedFloat32Array()
	for item: Variant in value:
		result.append(float(item))
	return result


static func _packed_float64_array_to_array(value: PackedFloat64Array) -> Array[float]:
	var result: Array[float] = []
	for item: float in value:
		result.append(item)
	return result


static func _array_to_packed_float64_array(value: Array) -> PackedFloat64Array:
	var result := PackedFloat64Array()
	for item: Variant in value:
		result.append(float(item))
	return result


static func _packed_string_array_to_array(value: PackedStringArray) -> Array[String]:
	var result: Array[String] = []
	for item: String in value:
		result.append(item)
	return result


static func _array_to_packed_string_array(value: Array) -> PackedStringArray:
	var result := PackedStringArray()
	for item: Variant in value:
		result.append(String(item))
	return result


static func _packed_vector2_array_to_array(value: PackedVector2Array) -> Array:
	var result: Array = []
	for item: Vector2 in value:
		result.append([item.x, item.y])
	return result


static func _array_to_packed_vector2_array(value: Array) -> PackedVector2Array:
	var result := PackedVector2Array()
	for item: Variant in value:
		var data := _to_array(item)
		result.append(Vector2(_float_at(data, 0), _float_at(data, 1)))
	return result


static func _packed_vector3_array_to_array(value: PackedVector3Array) -> Array:
	var result: Array = []
	for item: Vector3 in value:
		result.append([item.x, item.y, item.z])
	return result


static func _array_to_packed_vector3_array(value: Array) -> PackedVector3Array:
	var result := PackedVector3Array()
	for item: Variant in value:
		var data := _to_array(item)
		result.append(Vector3(_float_at(data, 0), _float_at(data, 1), _float_at(data, 2)))
	return result


static func _packed_color_array_to_array(value: PackedColorArray) -> Array:
	var result: Array = []
	for item: Color in value:
		result.append([item.r, item.g, item.b, item.a])
	return result


static func _array_to_packed_color_array(value: Array) -> PackedColorArray:
	var result := PackedColorArray()
	for item: Variant in value:
		var data := _to_array(item)
		result.append(Color(_float_at(data, 0), _float_at(data, 1), _float_at(data, 2), _float_at(data, 3, 1.0)))
	return result


static func _packed_vector4_array_to_array(value: PackedVector4Array) -> Array:
	var result: Array = []
	for item: Vector4 in value:
		result.append([item.x, item.y, item.z, item.w])
	return result


static func _array_to_packed_vector4_array(value: Array) -> PackedVector4Array:
	var result := PackedVector4Array()
	for item: Variant in value:
		var data := _to_array(item)
		result.append(Vector4(_float_at(data, 0), _float_at(data, 1), _float_at(data, 2), _float_at(data, 3)))
	return result
