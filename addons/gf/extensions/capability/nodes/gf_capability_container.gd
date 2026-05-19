## GFCapabilityContainer: 场景树中的能力组件容器。
##
## 将该节点作为某个 Node 的子节点后，容器内带脚本的子节点会被注册为父节点的能力。
## 需要在当前架构中注册 GFCapabilityUtility。
class_name GFCapabilityContainer
extends Node


# --- 常量 ---

const GF_NODE_CONTEXT_BASE = preload("res://addons/gf/kernel/core/gf_node_context.gd")
const _INSTANCE_GUARD: Script = preload("res://addons/gf/kernel/core/gf_instance_guard.gd")
const GF_CAPABILITY_UTILITY_BASE = preload("res://addons/gf/extensions/capability/core/gf_capability_utility.gd")


# --- 导出变量 ---

## 是否在进入场景树后自动注册已有子节点。
@export var auto_register_children: bool = true

## 是否在子节点顺序变化时自动注册新增子节点。
@export var watch_child_changes: bool = true


# --- 私有变量 ---

var _registered_children: Dictionary = {}
var _is_registering_children: bool = false
var _register_children_deferred_queued: bool = false


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	if not child_order_changed.is_connected(_on_child_order_changed):
		child_order_changed.connect(_on_child_order_changed)

	if auto_register_children:
		_register_children(false)
		_queue_register_children()


func _exit_tree() -> void:
	_unregister_registered_children()
	if child_order_changed.is_connected(_on_child_order_changed):
		child_order_changed.disconnect(_on_child_order_changed)
	_registered_children.clear()
	_is_registering_children = false
	_register_children_deferred_queued = false


# --- 公共方法 ---

## 获取容器服务的能力接收者。
func get_receiver() -> Node:
	return get_parent()


## 立即扫描并注册容器中的子节点能力。
func register_children_now() -> void:
	_register_children()


# --- 私有/辅助方法 ---

func _on_child_order_changed() -> void:
	if watch_child_changes and is_inside_tree():
		_register_children(false)
		_queue_register_children()


func _queue_register_children() -> void:
	if _register_children_deferred_queued:
		return

	_register_children_deferred_queued = true
	call_deferred("_register_children_deferred")


func _register_children_deferred() -> void:
	_register_children_deferred_queued = false
	if not is_inside_tree():
		return

	_register_children(true)


func _register_children(warn_if_missing_utility: bool = true) -> void:
	if _is_registering_children:
		return

	var receiver := get_receiver()
	if not is_instance_valid(receiver):
		return

	var capability_utility := _get_capability_utility()
	if capability_utility == null:
		if warn_if_missing_utility:
			push_warning("[GFCapabilityContainer] 当前架构未注册 GFCapabilityUtility，无法注册子节点能力。")
		return

	_is_registering_children = true
	for child: Node in get_children():
		if _registered_children.has(child.get_instance_id()):
			continue

		var child_script := child.get_script() as Script
		if child_script == null:
			continue

		var capability: Object = capability_utility.add_capability_instance(receiver, child, child_script)
		if capability == child:
			var child_id := child.get_instance_id()
			var exiting_callback := _on_registered_child_tree_exiting.bind(child_id)
			if not child.tree_exiting.is_connected(exiting_callback):
				child.tree_exiting.connect(exiting_callback)
			_registered_children[child_id] = {
				"script": child_script,
				"ref": weakref(child),
				"tree_exiting": exiting_callback,
			}
	_is_registering_children = false


func _unregister_registered_children() -> void:
	if _registered_children.is_empty():
		return

	var receiver := get_receiver()
	if not is_instance_valid(receiver):
		return

	var capability_utility := _get_capability_utility()
	if capability_utility == null:
		return

	var child_ids := _registered_children.keys()
	for child_id_variant: Variant in child_ids:
		_unregister_child_record(int(child_id_variant), receiver, capability_utility)


func _get_capability_utility() -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null

	return architecture.get_utility(GF_CAPABILITY_UTILITY_BASE)


func _get_architecture_or_null() -> GFArchitecture:
	var current_node: Node = self
	while current_node != null:
		if current_node is GF_NODE_CONTEXT_BASE:
			var context := current_node as GF_NODE_CONTEXT_BASE
			var context_architecture := context.get_architecture()
			if context_architecture != null:
				return context_architecture
		current_node = current_node.get_parent()

	return GFAutoload.get_architecture_or_null()


func _unregister_child_record(child_id: int, receiver: Node, capability_utility: Object) -> void:
	if not _registered_children.has(child_id):
		return

	var record := _registered_children[child_id] as Dictionary
	_registered_children.erase(child_id)
	if record == null:
		return

	var child_ref := record.get("ref") as WeakRef
	var child: Node = _INSTANCE_GUARD._get_live_node_from_ref(child_ref)
	var exiting_callback := record.get("tree_exiting") as Callable
	if child != null and exiting_callback.is_valid() and child.tree_exiting.is_connected(exiting_callback):
		child.tree_exiting.disconnect(exiting_callback)

	var child_script := record.get("script") as Script
	if child_script == null:
		return
	if is_instance_valid(receiver) and capability_utility != null:
		if capability_utility.get_capability(receiver, child_script) == child:
			capability_utility.unregister_capability(receiver, child_script)


func _on_registered_child_tree_exiting(child_id: int) -> void:
	var receiver := get_receiver()
	if not is_instance_valid(receiver):
		_registered_children.erase(child_id)
		return

	var capability_utility := _get_capability_utility()
	if capability_utility == null:
		_registered_children.erase(child_id)
		return
	_unregister_child_record(child_id, receiver, capability_utility)
