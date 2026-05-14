## GFNodePropertySerializer: 通用节点属性序列化器。
##
## 通过显式属性白名单保存和恢复节点属性，适合项目层快速接入简单状态。
class_name GFNodePropertySerializer
extends GFNodeSerializer


# --- 导出变量 ---

## 需要保存的属性名。
@export var properties: PackedStringArray = PackedStringArray()

## 应用数据时遇到缺失属性是否跳过。
@export var skip_missing_properties: bool = true


# --- Godot 生命周期方法 ---

func _init() -> void:
	serializer_id = &"gf.property"


# --- 公共方法 ---

## 采集节点的可保存状态。
## @param node: 目标节点。
## @param _context: 操作上下文字典，默认实现不直接使用。
func gather(node: Node, _context: Dictionary = {}) -> Dictionary:
	if node == null:
		return {}

	var available := _get_property_names(node)
	var result: Dictionary = {}
	for property_name: String in properties:
		if not available.has(property_name):
			continue
		result[property_name] = node.get(property_name)
	return result


## 将序列化数据应用到节点。
## @param node: 目标节点。
## @param payload: 随事件或交互传递的数据。
## @param _context: 操作上下文字典，默认实现不直接使用。
func apply(node: Node, payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	if node == null:
		return make_result(false, "Node is null.")

	var available := _get_property_infos(node)
	for property_variant: Variant in payload.keys():
		var property_name := String(property_variant)
		if not available.has(property_name):
			if skip_missing_properties:
				continue
			return make_result(false, "Missing property: %s" % property_name)
		var property_info := available[property_name] as Dictionary
		if not _can_write_property(property_info):
			return make_result(false, "Property is not writable: %s" % property_name)
		var value: Variant = payload[property_variant]
		if not _value_matches_property_type(value, int(property_info.get("type", TYPE_NIL))):
			return make_result(false, "Property type mismatch: %s" % property_name)
		node.set(property_name, _coerce_property_value(value, int(property_info.get("type", TYPE_NIL))))

	return make_result(true)


# --- 私有/辅助方法 ---

func _get_property_names(node: Object) -> Dictionary:
	var result: Dictionary = {}
	for property: Dictionary in node.get_property_list():
		result[String(property.get("name", ""))] = true
	return result


func _get_property_infos(node: Object) -> Dictionary:
	var result: Dictionary = {}
	for property: Dictionary in node.get_property_list():
		result[String(property.get("name", ""))] = property
	return result


func _can_write_property(property_info: Dictionary) -> bool:
	var usage := int(property_info.get("usage", 0))
	return (usage & PROPERTY_USAGE_READ_ONLY) == 0


func _value_matches_property_type(value: Variant, property_type: int) -> bool:
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


func _coerce_property_value(value: Variant, property_type: int) -> Variant:
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
