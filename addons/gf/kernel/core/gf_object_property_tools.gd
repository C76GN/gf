## GFObjectPropertyTools: Godot Object 属性访问辅助。
##
## 集中处理属性列表查询、属性路径读写、可写性判断和基础类型校验。
## 它不负责属性绑定、自动派发、表达式执行或业务字段解释。
class_name GFObjectPropertyTools
extends RefCounted


# --- 公共方法 ---

## 获取对象属性信息列表。
## @param object: 目标对象。
## @param usage_filter: 属性 usage 过滤掩码；小于 0 时不过滤。
## @return 属性信息字典列表副本。
static func get_property_infos(object: Object, usage_filter: int = -1) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not is_instance_valid(object):
		return result

	for property_info: Dictionary in object.get_property_list():
		if usage_filter >= 0 and (int(property_info.get("usage", 0)) & usage_filter) == 0:
			continue
		result.append(property_info.duplicate(true))
	return result


## 获取对象属性信息映射。
## @param object: 目标对象。
## @param usage_filter: 属性 usage 过滤掩码；小于 0 时不过滤。
## @return 以属性名为键的属性信息字典。
static func get_property_info_map(object: Object, usage_filter: int = -1) -> Dictionary:
	var result: Dictionary = {}
	for property_info: Dictionary in get_property_infos(object, usage_filter):
		var property_name := StringName(property_info.get("name", ""))
		if property_name != &"":
			result[property_name] = property_info
	return result


## 获取对象属性名列表。
## @param object: 目标对象。
## @param usage_filter: 属性 usage 过滤掩码；小于 0 时不过滤。
## @return 属性名列表。
static func get_property_names(object: Object, usage_filter: int = -1) -> PackedStringArray:
	var result := PackedStringArray()
	for property_info: Dictionary in get_property_infos(object, usage_filter):
		var property_name := String(property_info.get("name", ""))
		if not property_name.is_empty():
			result.append(property_name)
	return result


## 获取单个属性信息。
## @param object: 目标对象。
## @param property_name: 属性名。
## @return 属性信息字典副本；不存在时返回空字典。
static func get_property_info(object: Object, property_name: StringName) -> Dictionary:
	if property_name == &"" or not is_instance_valid(object):
		return {}
	for property_info: Dictionary in object.get_property_list():
		if StringName(property_info.get("name", "")) == property_name:
			return property_info.duplicate(true)
	return {}


## 检查对象是否声明了指定属性。
## @param object: 目标对象。
## @param property_name: 属性名。
## @return 属性存在时返回 true。
static func has_property(object: Object, property_name: StringName) -> bool:
	return not get_property_info(object, property_name).is_empty()


## 检查对象是否声明了属性路径的根属性。
## @param object: 目标对象。
## @param property_path: 属性路径。
## @return 根属性存在时返回 true。
static func has_property_path(object: Object, property_path: NodePath) -> bool:
	return has_property(object, get_root_property_name(property_path))


## 判断属性信息是否可写。
## @param property_info: Godot 属性信息字典。
## @return 未标记为只读时返回 true。
static func is_property_writable(property_info: Dictionary) -> bool:
	if property_info.is_empty():
		return false
	var usage := int(property_info.get("usage", 0))
	return (usage & PROPERTY_USAGE_READ_ONLY) == 0


## 检查对象属性路径是否可写。
## @param object: 目标对象。
## @param property_path: 属性路径。
## @return 根属性存在且未标记为只读时返回 true。
static func can_write_property(object: Object, property_path: NodePath) -> bool:
	return is_property_writable(get_property_info(object, get_root_property_name(property_path)))


## 读取对象属性路径。
## @param object: 目标对象。
## @param property_path: 属性路径。
## @param default_value: 对象、路径或根属性无效时返回的默认值。
## @return 属性值或默认值。
static func read_property(
	object: Object,
	property_path: NodePath,
	default_value: Variant = null
) -> Variant:
	if not is_instance_valid(object) or property_path.is_empty():
		return default_value
	if not has_property_path(object, property_path):
		return default_value
	return object.get_indexed(property_path)


## 写入对象属性路径。
## @param object: 目标对象。
## @param property_path: 属性路径。
## @param value: 请求写入的值。
## @param options: 可选项，支持 check_writable、check_type、coerce_value。
## @return 写入结果字典，包含 ok、error、property_name、old_value 与 new_value。
static func write_property(
	object: Object,
	property_path: NodePath,
	value: Variant,
	options: Dictionary = {}
) -> Dictionary:
	if not is_instance_valid(object):
		return _make_write_result(false, "Object is null.")
	if property_path.is_empty():
		return _make_write_result(false, "Property path is empty.")

	var root_property := get_root_property_name(property_path)
	var property_info := get_property_info(object, root_property)
	if property_info.is_empty():
		return _make_write_result(false, "Missing property: %s" % String(root_property), root_property)
	if bool(options.get("check_writable", true)) and not is_property_writable(property_info):
		return _make_write_result(false, "Property is not writable: %s" % String(root_property), root_property)

	var old_value: Variant = object.get_indexed(property_path)
	var property_type := _get_effective_property_type(property_path, property_info, old_value)
	var value_to_write: Variant = value
	if bool(options.get("check_type", true)) and not value_matches_property_type(value, property_type):
		return _make_write_result(false, "Property type mismatch: %s" % String(root_property), root_property, old_value)
	if bool(options.get("coerce_value", true)):
		value_to_write = coerce_property_value(value, property_type)

	object.set_indexed(property_path, value_to_write)
	return _make_write_result(true, "", root_property, old_value, object.get_indexed(property_path))


## 检查值是否可写入指定 Variant 类型。
## @param value: 输入值。
## @param property_type: Variant.Type 常量。
## @return 类型兼容时返回 true。
static func value_matches_property_type(value: Variant, property_type: int) -> bool:
	if value == null or property_type == TYPE_NIL:
		return true
	match property_type:
		TYPE_BOOL:
			return typeof(value) == TYPE_BOOL
		TYPE_INT:
			return typeof(value) == TYPE_INT
		TYPE_FLOAT:
			return typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT
		TYPE_STRING:
			return typeof(value) == TYPE_STRING or typeof(value) == TYPE_STRING_NAME
		TYPE_STRING_NAME:
			return typeof(value) == TYPE_STRING_NAME or typeof(value) == TYPE_STRING
		TYPE_VECTOR2:
			return value is Vector2
		TYPE_VECTOR2I:
			return value is Vector2i
		TYPE_RECT2:
			return value is Rect2
		TYPE_RECT2I:
			return value is Rect2i
		TYPE_VECTOR3:
			return value is Vector3
		TYPE_VECTOR3I:
			return value is Vector3i
		TYPE_TRANSFORM2D:
			return value is Transform2D
		TYPE_VECTOR4:
			return value is Vector4
		TYPE_VECTOR4I:
			return value is Vector4i
		TYPE_PLANE:
			return value is Plane
		TYPE_QUATERNION:
			return value is Quaternion
		TYPE_AABB:
			return value is AABB
		TYPE_BASIS:
			return value is Basis
		TYPE_TRANSFORM3D:
			return value is Transform3D
		TYPE_PROJECTION:
			return value is Projection
		TYPE_COLOR:
			return value is Color
		TYPE_NODE_PATH:
			return value is NodePath or typeof(value) == TYPE_STRING
		TYPE_DICTIONARY:
			return value is Dictionary
		TYPE_ARRAY:
			return value is Array
		TYPE_PACKED_BYTE_ARRAY:
			return value is PackedByteArray
		TYPE_PACKED_INT32_ARRAY:
			return value is PackedInt32Array
		TYPE_PACKED_INT64_ARRAY:
			return value is PackedInt64Array
		TYPE_PACKED_FLOAT32_ARRAY:
			return value is PackedFloat32Array
		TYPE_PACKED_FLOAT64_ARRAY:
			return value is PackedFloat64Array
		TYPE_PACKED_STRING_ARRAY:
			return value is PackedStringArray
		TYPE_PACKED_VECTOR2_ARRAY:
			return value is PackedVector2Array
		TYPE_PACKED_VECTOR3_ARRAY:
			return value is PackedVector3Array
		TYPE_PACKED_COLOR_ARRAY:
			return value is PackedColorArray
		TYPE_OBJECT:
			return value is Object
		_:
			return typeof(value) == property_type


## 将值转换为指定 Variant 类型的基础兼容形式。
## @param value: 输入值。
## @param property_type: Variant.Type 常量。
## @return 转换后的值；不支持转换时返回原值。
static func coerce_property_value(value: Variant, property_type: int) -> Variant:
	match property_type:
		TYPE_FLOAT:
			return float(value)
		TYPE_STRING:
			return String(value)
		TYPE_STRING_NAME:
			return StringName(value)
		TYPE_NODE_PATH:
			if typeof(value) == TYPE_STRING:
				return NodePath(value)
			return value
		_:
			return value


## 获取属性路径的根属性名。
## @param property_path: 属性路径。
## @return 根属性名；无效路径返回空 StringName。
static func get_root_property_name(property_path: NodePath) -> StringName:
	if property_path.is_empty():
		return &""
	if property_path.get_name_count() > 0:
		return StringName(property_path.get_name(0))
	if property_path.get_subname_count() > 0:
		return StringName(property_path.get_subname(0))
	return StringName(String(property_path))


# --- 私有/辅助方法 ---

static func _get_effective_property_type(
	property_path: NodePath,
	property_info: Dictionary,
	current_value: Variant
) -> int:
	if _is_direct_property_path(property_path):
		return int(property_info.get("type", TYPE_NIL))
	if current_value != null:
		return typeof(current_value)
	return TYPE_NIL


static func _is_direct_property_path(property_path: NodePath) -> bool:
	return property_path.get_name_count() <= 1 and property_path.get_subname_count() == 0


static func _make_write_result(
	ok: bool,
	error_message: String = "",
	property_name: StringName = &"",
	old_value: Variant = null,
	new_value: Variant = null
) -> Dictionary:
	return {
		"ok": ok,
		"error": error_message,
		"property_name": property_name,
		"old_value": old_value,
		"new_value": new_value,
	}
