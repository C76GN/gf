# GFInstanceGuard: 内部实例生命周期守卫工具。
#
# 用于从 Variant、WeakRef 或 instance_id 中安全解析仍有效的 Object / Node / Control。
# 该脚本不声明 class_name，作为 kernel 内部基础 helper 由上层模块按需 preload。
extends RefCounted


# --- 私有/辅助方法 ---

static func _get_live_object(value: Variant) -> Object:
	if typeof(value) != TYPE_OBJECT:
		return null
	if not is_instance_valid(value):
		return null
	var object: Object = value
	return object


static func _get_live_node(value: Variant) -> Node:
	var object: Object = _get_live_object(value)
	if object == null or not (object is Node):
		return null
	var node: Node = object
	return node


static func _get_live_control(value: Variant) -> Control:
	var node: Node = _get_live_node(value)
	if node == null or not (node is Control):
		return null
	var control: Control = node
	return control


static func _get_live_object_from_ref(object_ref: WeakRef) -> Object:
	if object_ref == null:
		return null
	return _get_live_object(object_ref.get_ref())


static func _get_live_node_from_ref(object_ref: WeakRef) -> Node:
	if object_ref == null:
		return null
	return _get_live_node(object_ref.get_ref())


static func _get_live_control_from_ref(object_ref: WeakRef) -> Control:
	if object_ref == null:
		return null
	return _get_live_control(object_ref.get_ref())


static func _get_live_object_from_id(instance_id: int) -> Object:
	return _get_live_object(instance_from_id(instance_id))


static func _get_live_node_from_id(instance_id: int) -> Node:
	return _get_live_node(instance_from_id(instance_id))
