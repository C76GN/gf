## GFNodeSerializer: 节点序列化器基类。
##
## 用于把通用节点状态拆成可组合的序列化片段。具体项目可以继承该类，
## 在不修改存档图编排逻辑的前提下接入自己的节点状态。
class_name GFNodeSerializer
extends Resource


# --- 导出变量 ---

## 序列化器稳定标识。
@export var serializer_id: StringName = &""

## 编辑器展示名称。
@export var display_name: String = ""

## 可选 Godot 类名过滤。为空时由子类自行判断。
@export var supported_class_name: String = ""


# --- 公共方法 ---

## 获取序列化器标识。
## @return 稳定标识。
func get_serializer_id() -> StringName:
	if serializer_id != &"":
		return serializer_id
	if not resource_path.is_empty():
		return StringName(resource_path)
	return StringName(get_script().resource_path)


## 判断当前序列化器是否支持节点。
## @param node: 待序列化节点。
## @return 支持时返回 true。
func supports_node(node: Node) -> bool:
	if node == null:
		return false
	if supported_class_name.is_empty():
		return true
	return node.is_class(supported_class_name)


## 采集节点数据。
## @param _node: 待序列化节点。
## @param _context: 调用上下文字典。
## @return 可写入存档的字典。
func gather(_node: Node, _context: Dictionary = {}) -> Dictionary:
	return {}


## 应用节点数据。
## @param _node: 目标节点。
## @param _payload: 当前序列化器的数据。
## @param _context: 调用上下文字典。
## @return 结果字典。
func apply(_node: Node, _payload: Dictionary, _context: Dictionary = {}) -> Dictionary:
	return make_result(true)


## 构造统一结果。
## @param ok: 是否成功。
## @param error: 错误描述。
## @return 结果字典。
func make_result(ok: bool, error: String = "") -> Dictionary:
	return {
		"ok": ok,
		"error": error,
	}


# --- 私有/辅助方法 ---

func _copy_property_to_payload(node: Object, payload: Dictionary, property_name: String) -> void:
	if _has_property(node, property_name):
		payload[property_name] = node.get(property_name)


func _copy_properties_to_payload(node: Object, payload: Dictionary, property_names: PackedStringArray) -> void:
	for property_name: String in property_names:
		_copy_property_to_payload(node, payload, property_name)


func _apply_property_from_payload(node: Object, payload: Dictionary, property_name: String) -> void:
	if payload.has(property_name) and _has_property(node, property_name):
		node.set(property_name, payload[property_name])


func _apply_properties_from_payload(node: Object, payload: Dictionary, property_names: PackedStringArray) -> void:
	for property_name: String in property_names:
		_apply_property_from_payload(node, payload, property_name)


func _gather_property_specs(node: Object, specs: Array[Dictionary]) -> Dictionary:
	var result: Dictionary = {}
	for spec: Dictionary in specs:
		var key := String(spec.get("key", spec.get("property", "")))
		var property_name := String(spec.get("property", key))
		if key.is_empty() or property_name.is_empty() or not _has_property(node, property_name):
			continue
		result[key] = _encode_property_value(node.get(property_name), StringName(spec.get("kind", &"")))
	return result


func _apply_property_specs(node: Object, payload: Dictionary, specs: Array[Dictionary]) -> void:
	for spec: Dictionary in specs:
		var key := String(spec.get("key", spec.get("property", "")))
		var property_name := String(spec.get("property", key))
		if key.is_empty() or property_name.is_empty() or not payload.has(key) or not _has_property(node, property_name):
			continue
		node.set(property_name, _decode_property_value(
			payload[key],
			node.get(property_name),
			StringName(spec.get("kind", &""))
		))


func _has_property(object: Object, property_name: String) -> bool:
	if object == null:
		return false
	for property: Dictionary in object.get_property_list():
		if String(property.get("name", "")) == property_name:
			return true
	return false


func _vector2_to_array(value: Vector2) -> Array[float]:
	return GFVariantUtility.vector2_to_array(value)


func _array_to_vector2(value: Variant, fallback: Vector2) -> Vector2:
	return GFVariantUtility.array_to_vector2(value, fallback)


func _vector3_to_array(value: Vector3) -> Array[float]:
	return GFVariantUtility.vector3_to_array(value)


func _array_to_vector3(value: Variant, fallback: Vector3) -> Vector3:
	return GFVariantUtility.array_to_vector3(value, fallback)


func _color_to_array(value: Color) -> Array[float]:
	return GFVariantUtility.color_to_array(value)


func _array_to_color(value: Variant, fallback: Color) -> Color:
	return GFVariantUtility.array_to_color(value, fallback)


func _encode_property_value(value: Variant, kind: StringName) -> Variant:
	match kind:
		&"vector2":
			return _vector2_to_array(value as Vector2)
		&"vector3":
			return _vector3_to_array(value as Vector3)
		&"color":
			return _color_to_array(value as Color)
		_:
			return value


func _decode_property_value(value: Variant, fallback: Variant, kind: StringName) -> Variant:
	match kind:
		&"vector2":
			return _array_to_vector2(value, fallback as Vector2)
		&"vector3":
			return _array_to_vector3(value, fallback as Vector3)
		&"color":
			return _array_to_color(value, fallback as Color)
		&"float":
			return float(value)
		&"int":
			return int(value)
		&"bool":
			return bool(value)
		_:
			return value
