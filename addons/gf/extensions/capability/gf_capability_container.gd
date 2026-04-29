## GFCapabilityContainer: 场景树中的能力组件容器。
##
## 将该节点作为某个 Node 的子节点后，容器内带脚本的子节点会被注册为父节点的能力。
## 需要在当前架构中注册 GFCapabilityUtility。
class_name GFCapabilityContainer
extends Node


# --- 常量 ---

const GF_NODE_CONTEXT_BASE = preload("res://addons/gf/core/gf_node_context.gd")
const _CAPABILITY_UTILITY_PATH: String = "res://addons/gf/extensions/capability/gf_capability_utility.gd"


# --- 导出变量 ---

## 是否在进入场景树后自动注册已有子节点。
@export var auto_register_children: bool = true

## 是否在子节点顺序变化时自动注册新增子节点。
@export var watch_child_changes: bool = true


# --- 私有变量 ---

var _registered_children: Dictionary = {}
var _is_registering_children: bool = false


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	if not child_order_changed.is_connected(_on_child_order_changed):
		child_order_changed.connect(_on_child_order_changed)

	if auto_register_children:
		call_deferred("_register_children")


func _exit_tree() -> void:
	if child_order_changed.is_connected(_on_child_order_changed):
		child_order_changed.disconnect(_on_child_order_changed)
	_registered_children.clear()
	_is_registering_children = false


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
		call_deferred("_register_children")


func _register_children() -> void:
	if _is_registering_children:
		return

	var receiver := get_receiver()
	if not is_instance_valid(receiver):
		return

	var capability_utility := _get_capability_utility()
	if capability_utility == null:
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
			_registered_children[child.get_instance_id()] = child_script
	_is_registering_children = false


func _get_capability_utility() -> Object:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null

	var capability_utility_script := load(_CAPABILITY_UTILITY_PATH) as Script
	if capability_utility_script == null:
		return null

	return architecture.get_utility(capability_utility_script)


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
