# GFInstanceGuard: 内部实例生命周期守卫工具。
#
# 用于从 Variant、WeakRef 或 instance_id 中安全解析仍有效的 Object / Node / Control。
# 该脚本不声明 class_name，作为 kernel 内部基础 helper 由上层模块按需 preload。
extends RefCounted


# --- 私有/辅助方法 ---

static func _get_live_object(value: Variant) -> Object:
	if not is_instance_valid(value):
		return null
	if not (value is Object):
		return null
	return value as Object


static func _get_live_node(value: Variant) -> Node:
	var object := _get_live_object(value)
	if object == null or not (object is Node):
		return null
	return object as Node


static func _get_live_control(value: Variant) -> Control:
	var node := _get_live_node(value)
	if node == null or not (node is Control):
		return null
	return node as Control


static func _get_live_object_from_ref(reference: WeakRef) -> Object:
	if reference == null:
		return null
	return _get_live_object(reference.get_ref())


static func _get_live_node_from_ref(reference: WeakRef) -> Node:
	if reference == null:
		return null
	return _get_live_node(reference.get_ref())


static func _get_live_control_from_ref(reference: WeakRef) -> Control:
	if reference == null:
		return null
	return _get_live_control(reference.get_ref())


static func _get_live_object_from_id(instance_id: int) -> Object:
	return _get_live_object(instance_from_id(instance_id))


static func _get_live_node_from_id(instance_id: int) -> Node:
	return _get_live_node(instance_from_id(instance_id))
