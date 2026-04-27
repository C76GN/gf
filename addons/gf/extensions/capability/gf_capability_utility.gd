## GFCapabilityUtility: 对象能力组件管理器。
##
## 提供面向任意 Object / Node 的能力挂载、查询、移除、启停、索引查询与依赖补齐能力。
## 能力组合是可选扩展，不改变核心分层容器。
class_name GFCapabilityUtility
extends GFUtility


# --- 信号 ---

## 当能力成功挂载到对象后发出。
signal capability_added(receiver: Object, capability_type: Script, capability: Object)

## 当能力从对象移除前发出。
signal capability_removed(receiver: Object, capability_type: Script, capability: Object)

## 当能力启停状态变化后发出。
signal capability_active_changed(receiver: Object, capability_type: Script, capability: Object, active: bool)


# --- 常量 ---

const META_CAPABILITY_TYPES: StringName = &"_gf_capability_types"
const META_CAPABILITY_ACTIVE: StringName = &"_gf_capability_active"
const META_CAPABILITY_INSTANCE_PREFIX: String = "_gf_capability_"
const META_CAPABILITY_CONTAINER: StringName = &"_gf_capability_container"
const META_ORIGINAL_PROCESS_MODE: StringName = &"_gf_capability_original_process_mode"
const HOOK_GET_REQUIRED_CAPABILITIES: StringName = &"get_required_capabilities"
const HOOK_ON_ADDED: StringName = &"on_gf_capability_added"
const HOOK_ON_REMOVED: StringName = &"on_gf_capability_removed"
const HOOK_ON_ACTIVE_CHANGED: StringName = &"on_gf_capability_active_changed"
const GF_CAPABILITY_CONTAINER_BASE := preload("res://addons/gf/extensions/capability/gf_capability_container.gd")


# --- 私有变量 ---

var _creation_stack: Array[String] = []
var _receiver_refs: Dictionary = {}
var _capability_receivers: Dictionary = {}
var _receiver_groups: Dictionary = {}
var _receiver_group_names: Dictionary = {}


# --- Godot 生命周期方法 ---

func dispose() -> void:
	_creation_stack.clear()
	_receiver_refs.clear()
	_capability_receivers.clear()
	_receiver_groups.clear()
	_receiver_group_names.clear()


# --- 公共方法 ---

## 检查对象是否拥有指定能力。
func has_capability(receiver: Object, capability_type: Script) -> bool:
	return get_capability(receiver, capability_type) != null


## 获取对象上的指定能力。
## 未命中精确类型时，会尝试寻找唯一的子类能力。
func get_capability(receiver: Object, capability_type: Script) -> Object:
	var record := _find_capability_record(receiver, capability_type)
	if record.is_empty():
		return null
	return record["instance"] as Object


## 获取对象当前拥有的所有能力类型。
func get_capability_types(receiver: Object) -> Array[Script]:
	if not is_instance_valid(receiver):
		return [] as Array[Script]

	return _get_capability_type_list(receiver).duplicate()


## 获取所有拥有指定能力的 receiver。
## @param include_subclasses: 为 true 时同时匹配指定能力的子类能力。
func get_receivers_with(capability_type: Script, include_subclasses: bool = true) -> Array[Object]:
	if capability_type == null:
		return [] as Array[Object]

	_prune_invalid_receivers()
	var result: Array[Object] = []
	var seen_ids: Dictionary = {}
	for registered_type: Script in _get_indexed_capability_types(capability_type, include_subclasses):
		var receiver_ids := _capability_receivers.get(registered_type, {}) as Dictionary
		for receiver_id: int in receiver_ids:
			if seen_ids.has(receiver_id):
				continue
			var receiver := _get_receiver_from_id(receiver_id)
			if receiver != null:
				seen_ids[receiver_id] = true
				result.append(receiver)
	return result


## 获取当前已挂载的指定能力实例列表。
## @param include_subclasses: 为 true 时同时返回指定能力的子类能力实例。
func get_capabilities(capability_type: Script, include_subclasses: bool = true) -> Array[Object]:
	if capability_type == null:
		return [] as Array[Object]

	_prune_invalid_receivers()
	var result: Array[Object] = []
	var seen_ids: Dictionary = {}
	for registered_type: Script in _get_indexed_capability_types(capability_type, include_subclasses):
		var receiver_ids := _capability_receivers.get(registered_type, {}) as Dictionary
		for receiver_id: int in receiver_ids:
			var receiver := _get_receiver_from_id(receiver_id)
			if receiver == null:
				continue
			var capability := _get_capability_instance(receiver, registered_type)
			if capability != null and not seen_ids.has(capability.get_instance_id()):
				seen_ids[capability.get_instance_id()] = true
				result.append(capability)
	return result


## 把 receiver 加入一个能力查询分组。
func add_receiver_to_group(receiver: Object, group_name: StringName) -> void:
	if not is_instance_valid(receiver) or group_name == &"":
		return

	var receiver_id := _track_receiver(receiver)
	var group_receivers := _get_group_receiver_ids(group_name)
	group_receivers[receiver_id] = true

	if not _receiver_group_names.has(receiver_id):
		_receiver_group_names[receiver_id] = {}
	var group_names := _receiver_group_names[receiver_id] as Dictionary
	group_names[group_name] = true


## 从一个能力查询分组移除 receiver。
func remove_receiver_from_group(receiver: Object, group_name: StringName) -> void:
	if not is_instance_valid(receiver) or group_name == &"":
		return

	var receiver_id := receiver.get_instance_id()
	if _receiver_groups.has(group_name):
		var group_receivers := _receiver_groups[group_name] as Dictionary
		group_receivers.erase(receiver_id)
		if group_receivers.is_empty():
			_receiver_groups.erase(group_name)

	if _receiver_group_names.has(receiver_id):
		var group_names := _receiver_group_names[receiver_id] as Dictionary
		group_names.erase(group_name)
		if group_names.is_empty():
			_receiver_group_names.erase(receiver_id)


## 获取 receiver 当前所属的能力查询分组。
func get_receiver_groups(receiver: Object) -> Array[StringName]:
	if not is_instance_valid(receiver):
		return [] as Array[StringName]

	var receiver_id := receiver.get_instance_id()
	if not _receiver_group_names.has(receiver_id):
		return [] as Array[StringName]

	var result: Array[StringName] = []
	for group_name: StringName in (_receiver_group_names[receiver_id] as Dictionary):
		result.append(group_name)
	return result


## 获取指定分组内的 receiver。
func get_receivers_in_group(group_name: StringName) -> Array[Object]:
	if group_name == &"":
		return [] as Array[Object]

	_prune_invalid_receivers()
	var result: Array[Object] = []
	var group_receivers := _receiver_groups.get(group_name, {}) as Dictionary
	for receiver_id: int in group_receivers:
		var receiver := _get_receiver_from_id(receiver_id)
		if receiver != null:
			result.append(receiver)
	return result


## 获取指定分组内拥有某个能力的 receiver。
func get_receivers_in_group_with(
	group_name: StringName,
	capability_type: Script,
	include_subclasses: bool = true
) -> Array[Object]:
	if group_name == &"" or capability_type == null:
		return [] as Array[Object]

	_prune_invalid_receivers()
	var result: Array[Object] = []
	var group_receivers := _receiver_groups.get(group_name, {}) as Dictionary
	for receiver: Object in get_receivers_with(capability_type, include_subclasses):
		if group_receivers.has(receiver.get_instance_id()):
			result.append(receiver)
	return result


## 给对象挂载指定能力类型。
## provider 可为 Callable、PackedScene、Object；为空时使用 capability_type.new()。
func add_capability(receiver: Object, capability_type: Script, provider: Variant = null) -> Object:
	if not _validate_receiver_and_type(receiver, capability_type, "add_capability"):
		return null

	var existing := get_capability(receiver, capability_type)
	if existing != null:
		return existing

	var creation_key := _get_creation_key(receiver, capability_type)
	if _creation_stack.has(creation_key):
		push_error("[GFCapabilityUtility] 检测到循环能力依赖：%s" % _describe_creation_stack(creation_key))
		return null

	_creation_stack.append(creation_key)
	var should_free_on_failure := _should_free_created_capability_on_failure(provider)
	var capability := _create_capability(capability_type, provider)
	if capability == null:
		_creation_stack.pop_back()
		return null

	if not _ensure_required_capabilities(receiver, capability):
		if should_free_on_failure:
			_free_unregistered_capability(capability)
		_creation_stack.pop_back()
		return null

	_register_capability(receiver, capability_type, capability)
	_creation_stack.pop_back()
	return capability


## 给对象挂载一个已经存在的能力实例。
func add_capability_instance(receiver: Object, capability: Object, as_type: Script = null) -> Object:
	if not is_instance_valid(receiver):
		push_error("[GFCapabilityUtility] add_capability_instance 失败：receiver 无效。")
		return null
	if not is_instance_valid(capability):
		push_error("[GFCapabilityUtility] add_capability_instance 失败：capability 无效。")
		return null

	var capability_type := as_type
	if capability_type == null:
		capability_type = capability.get_script() as Script
	if capability_type == null:
		push_error("[GFCapabilityUtility] add_capability_instance 失败：能力实例缺少脚本类型。")
		return null

	var existing := get_capability(receiver, capability_type)
	if existing != null:
		if existing == capability:
			return capability
		push_warning("[GFCapabilityUtility] add_capability_instance：目标对象已拥有该能力，已忽略新实例。")
		return existing

	if not _ensure_required_capabilities(receiver, capability):
		return null

	_register_capability(receiver, capability_type, capability)
	return capability


## 实例化 PackedScene 并作为能力挂载。
func add_scene_capability(receiver: Node, scene: PackedScene, as_type: Script = null) -> Object:
	if not is_instance_valid(receiver):
		push_error("[GFCapabilityUtility] add_scene_capability 失败：receiver 无效。")
		return null
	if not is_instance_valid(scene):
		push_error("[GFCapabilityUtility] add_scene_capability 失败：scene 无效。")
		return null

	var node := scene.instantiate() as Node
	if node == null:
		push_error("[GFCapabilityUtility] add_scene_capability 失败：scene 根节点必须是 Node。")
		return null

	var registered := add_capability_instance(receiver, node, as_type)
	if registered != node:
		_free_unregistered_capability(node)
	return registered


## 设置对象上指定能力的启停状态。
func set_capability_active(receiver: Object, capability_type: Script, active: bool) -> void:
	var record := _find_capability_record(receiver, capability_type)
	if record.is_empty():
		return

	var registered_type := record["type"] as Script
	var capability := record["instance"] as Object
	if capability == null:
		return

	if _read_capability_active(capability) == active:
		return

	_apply_capability_active_state(receiver, capability, active, true)
	capability_active_changed.emit(receiver, registered_type, capability, active)


## 查询对象上指定能力当前是否启用。
func is_capability_active(receiver: Object, capability_type: Script) -> bool:
	var record := _find_capability_record(receiver, capability_type)
	if record.is_empty():
		return false

	var capability := record["instance"] as Object
	if capability == null:
		return false
	return _read_capability_active(capability)


## 从对象移除指定能力。
func remove_capability(receiver: Object, capability_type: Script) -> void:
	var record := _find_capability_record(receiver, capability_type)
	if record.is_empty():
		return

	var registered_type := record["type"] as Script
	var capability := record["instance"] as Object
	_call_removed_hook(receiver, capability)
	_remove_capability_record(receiver, registered_type)
	capability_removed.emit(receiver, registered_type, capability)
	_free_registered_capability(capability)


## 清空对象上的所有能力。
func clear_capabilities(receiver: Object) -> void:
	if not is_instance_valid(receiver):
		return

	var capability_types := get_capability_types(receiver)
	for capability_type in capability_types:
		remove_capability(receiver, capability_type)


## 清空 receiver 所属的所有能力查询分组。
func clear_receiver_groups(receiver: Object) -> void:
	if not is_instance_valid(receiver):
		return

	var group_names := get_receiver_groups(receiver)
	for group_name: StringName in group_names:
		remove_receiver_from_group(receiver, group_name)


# --- 私有/辅助方法 ---

func _validate_receiver_and_type(receiver: Object, capability_type: Script, context: String) -> bool:
	if not is_instance_valid(receiver):
		push_error("[GFCapabilityUtility] %s 失败：receiver 无效。" % context)
		return false
	if capability_type == null:
		push_error("[GFCapabilityUtility] %s 失败：capability_type 为空。" % context)
		return false
	return true


func _create_capability(capability_type: Script, provider: Variant) -> Object:
	if provider is Callable:
		var value: Variant = (provider as Callable).call()
		if value is Object:
			return value as Object
		push_error("[GFCapabilityUtility] provider Callable 必须返回 Object。")
		return null

	if provider is PackedScene:
		var node := (provider as PackedScene).instantiate() as Node
		if node == null:
			push_error("[GFCapabilityUtility] provider PackedScene 的根节点必须是 Node。")
		return node

	if provider is Object:
		return provider as Object

	if not capability_type.can_instantiate():
		push_error("[GFCapabilityUtility] 能力类型不可实例化：%s" % _get_script_key(capability_type))
		return null

	return capability_type.new() as Object


func _should_free_created_capability_on_failure(provider: Variant) -> bool:
	return provider == null or provider is Callable or provider is PackedScene


func _ensure_required_capabilities(receiver: Object, capability: Object) -> bool:
	var required_types := _get_required_capabilities(capability)
	for required_type in required_types:
		if required_type == null:
			continue
		if get_capability(receiver, required_type) != null:
			continue
		var required_capability := add_capability(receiver, required_type)
		if required_capability == null:
			push_error("[GFCapabilityUtility] 依赖能力创建失败：%s" % _get_script_key(required_type))
			return false
	return true


func _get_required_capabilities(capability: Object) -> Array[Script]:
	if capability == null or not capability.has_method(HOOK_GET_REQUIRED_CAPABILITIES):
		return [] as Array[Script]

	var raw_value: Variant = capability.call(HOOK_GET_REQUIRED_CAPABILITIES)
	var result: Array[Script] = []
	if raw_value is Array:
		for item: Variant in raw_value:
			if item is Script:
				result.append(item as Script)
			elif item != null:
				push_warning("[GFCapabilityUtility] get_required_capabilities() 包含非 Script 项，已跳过。")
	return result


func _register_capability(receiver: Object, capability_type: Script, capability: Object) -> void:
	var types := _get_capability_type_list(receiver)
	types.append(capability_type)
	_set_capability_instance(receiver, capability_type, capability)
	_track_capability_index(receiver, capability_type)
	_inject_if_needed(capability)
	_attach_node_capability(receiver, capability)
	_apply_capability_active_state(receiver, capability, _read_capability_active(capability), false)
	_call_added_hook(receiver, capability)
	capability_added.emit(receiver, capability_type, capability)


func _get_capability_type_list(receiver: Object) -> Array[Script]:
	if not receiver.has_meta(META_CAPABILITY_TYPES):
		receiver.set_meta(META_CAPABILITY_TYPES, [] as Array[Script])

	return receiver.get_meta(META_CAPABILITY_TYPES) as Array[Script]


func _find_capability_record(receiver: Object, capability_type: Script) -> Dictionary:
	if not _validate_receiver_and_type(receiver, capability_type, "get_capability"):
		return {}

	var exact_instance := _get_capability_instance(receiver, capability_type)
	if exact_instance != null:
		return {
			"type": capability_type,
			"instance": exact_instance,
		}

	var matches: Array[Dictionary] = []
	for registered_type in _get_capability_type_list(receiver):
		if _script_extends_or_equals(registered_type, capability_type):
			var instance := _get_capability_instance(receiver, registered_type)
			if instance != null:
				matches.append({
					"type": registered_type,
					"instance": instance,
				})

	if matches.size() == 1:
		return matches[0]
	if matches.size() > 1:
		push_warning("[GFCapabilityUtility] get_capability(%s) 匹配到多个能力，请使用更具体类型查询。" % _get_script_key(capability_type))

	return {}


func _set_capability_instance(receiver: Object, capability_type: Script, capability: Object) -> void:
	receiver.set_meta(_get_capability_meta_name(capability_type), capability)


func _get_capability_instance(receiver: Object, capability_type: Script) -> Object:
	if receiver == null or capability_type == null:
		return null

	var meta_name := _get_capability_meta_name(capability_type)
	if not receiver.has_meta(meta_name):
		return null

	var capability := receiver.get_meta(meta_name) as Object
	if is_instance_valid(capability):
		return capability

	receiver.remove_meta(meta_name)
	_get_capability_type_list(receiver).erase(capability_type)
	_remove_capability_index(receiver.get_instance_id(), capability_type)
	return null


func _remove_capability_record(receiver: Object, capability_type: Script) -> void:
	_get_capability_type_list(receiver).erase(capability_type)
	_remove_capability_index(receiver.get_instance_id(), capability_type)
	var meta_name := _get_capability_meta_name(capability_type)
	if receiver.has_meta(meta_name):
		receiver.remove_meta(meta_name)


func _attach_node_capability(receiver: Object, capability: Object) -> void:
	if not (receiver is Node) or not (capability is Node):
		return

	var receiver_node := receiver as Node
	var capability_node := capability as Node
	var container := _get_or_create_container(receiver_node)
	if capability_node.get_parent() == container:
		return

	if capability_node.get_parent() != null:
		capability_node.reparent(container, false)
	else:
		container.add_child(capability_node, true, Node.INTERNAL_MODE_BACK)


func _get_or_create_container(receiver: Node) -> Node:
	for child in receiver.get_children(true):
		if _is_capability_container(child):
			return child as Node

	var container := Node.new()
	container.name = "GFCapabilityContainer"
	container.set_meta(META_CAPABILITY_CONTAINER, true)
	container.set_script(GF_CAPABILITY_CONTAINER_BASE)
	receiver.add_child(container, true, Node.INTERNAL_MODE_BACK)
	return container


func _is_capability_container(node: Node) -> bool:
	return (
		node is GF_CAPABILITY_CONTAINER_BASE
		or bool(node.get_meta(META_CAPABILITY_CONTAINER, false))
	)


func _read_capability_active(capability: Object) -> bool:
	if capability == null:
		return false
	if "active" in capability:
		return bool(capability.get("active"))
	if capability.has_meta(META_CAPABILITY_ACTIVE):
		return bool(capability.get_meta(META_CAPABILITY_ACTIVE))
	return true


func _apply_capability_active_state(receiver: Object, capability: Object, active: bool, notify_hook: bool) -> void:
	if capability == null:
		return

	if "active" in capability:
		capability.set("active", active)
	capability.set_meta(META_CAPABILITY_ACTIVE, active)
	if capability is Node:
		_set_node_tree_active_state(capability as Node, active)
	if notify_hook:
		_call_active_changed_hook(receiver, capability, active)


func _set_node_tree_active_state(node: Node, active: bool) -> void:
	_set_node_active_state(node, active)
	for child: Node in node.get_children():
		_set_node_tree_active_state(child, active)


func _set_node_active_state(node: Node, active: bool) -> void:
	if not node.has_meta(META_ORIGINAL_PROCESS_MODE):
		node.set_meta(META_ORIGINAL_PROCESS_MODE, node.process_mode)

	if active:
		node.process_mode = node.get_meta(META_ORIGINAL_PROCESS_MODE)
	else:
		node.process_mode = Node.PROCESS_MODE_DISABLED


func _track_capability_index(receiver: Object, capability_type: Script) -> void:
	var receiver_id := _track_receiver(receiver)
	var receiver_ids := _get_capability_receiver_ids(capability_type)
	receiver_ids[receiver_id] = true


func _track_receiver(receiver: Object) -> int:
	var receiver_id := receiver.get_instance_id()
	_receiver_refs[receiver_id] = weakref(receiver)
	return receiver_id


func _remove_capability_index(receiver_id: int, capability_type: Script) -> void:
	if not _capability_receivers.has(capability_type):
		return

	var receiver_ids := _capability_receivers[capability_type] as Dictionary
	receiver_ids.erase(receiver_id)
	if receiver_ids.is_empty():
		_capability_receivers.erase(capability_type)


func _get_capability_receiver_ids(capability_type: Script) -> Dictionary:
	if not _capability_receivers.has(capability_type):
		_capability_receivers[capability_type] = {}
	return _capability_receivers[capability_type] as Dictionary


func _get_group_receiver_ids(group_name: StringName) -> Dictionary:
	if not _receiver_groups.has(group_name):
		_receiver_groups[group_name] = {}
	return _receiver_groups[group_name] as Dictionary


func _get_indexed_capability_types(capability_type: Script, include_subclasses: bool) -> Array[Script]:
	var result: Array[Script] = []
	for registered_type: Script in _capability_receivers:
		if registered_type == capability_type:
			result.append(registered_type)
		elif include_subclasses and _script_extends_or_equals(registered_type, capability_type):
			result.append(registered_type)
	return result


func _get_receiver_from_id(receiver_id: int) -> Object:
	var receiver_ref := _receiver_refs.get(receiver_id) as WeakRef
	if receiver_ref == null:
		return null

	var receiver := receiver_ref.get_ref() as Object
	if receiver != null and is_instance_valid(receiver):
		return receiver
	_remove_receiver_index(receiver_id)
	return null


func _prune_invalid_receivers() -> void:
	var receiver_ids := _receiver_refs.keys()
	for receiver_id: int in receiver_ids:
		_get_receiver_from_id(receiver_id)


func _remove_receiver_index(receiver_id: int) -> void:
	_receiver_refs.erase(receiver_id)

	for capability_type: Script in _capability_receivers.keys():
		var receiver_ids := _capability_receivers[capability_type] as Dictionary
		receiver_ids.erase(receiver_id)
		if receiver_ids.is_empty():
			_capability_receivers.erase(capability_type)

	for group_name: StringName in _receiver_groups.keys():
		var group_receivers := _receiver_groups[group_name] as Dictionary
		group_receivers.erase(receiver_id)
		if group_receivers.is_empty():
			_receiver_groups.erase(group_name)

	_receiver_group_names.erase(receiver_id)


func _inject_if_needed(capability: Object) -> void:
	var architecture := _get_architecture_or_null()
	if capability == null or architecture == null:
		return

	if capability.has_method("inject_dependencies"):
		capability.inject_dependencies(architecture)
	if capability.has_method("inject"):
		capability.inject(architecture)


func _call_added_hook(receiver: Object, capability: Object) -> void:
	if capability != null and capability.has_method(HOOK_ON_ADDED):
		capability.call(HOOK_ON_ADDED, receiver)


func _call_removed_hook(receiver: Object, capability: Object) -> void:
	if capability != null and capability.has_method(HOOK_ON_REMOVED):
		capability.call(HOOK_ON_REMOVED, receiver)


func _call_active_changed_hook(receiver: Object, capability: Object, active: bool) -> void:
	if capability != null and capability.has_method(HOOK_ON_ACTIVE_CHANGED):
		capability.call(HOOK_ON_ACTIVE_CHANGED, receiver, active)


func _free_unregistered_capability(capability: Object) -> void:
	_free_capability(capability, false)


func _free_registered_capability(capability: Object) -> void:
	_free_capability(capability, true)


func _free_capability(capability: Object, detach_node: bool) -> void:
	if not is_instance_valid(capability):
		return

	if capability is Node:
		var node := capability as Node
		if detach_node and node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.queue_free()
	elif capability is RefCounted:
		pass
	else:
		capability.free()


func _get_capability_meta_name(capability_type: Script) -> StringName:
	return StringName(META_CAPABILITY_INSTANCE_PREFIX + _get_script_key(capability_type).md5_text())


func _get_script_key(script: Script) -> String:
	if script == null:
		return "<null>"

	var global_name := script.get_global_name()
	if global_name != &"":
		return String(global_name)
	if not script.resource_path.is_empty():
		return script.resource_path
	return str(script.get_instance_id())


func _get_creation_key(receiver: Object, capability_type: Script) -> String:
	return "%s:%s" % [receiver.get_instance_id(), _get_script_key(capability_type)]


func _describe_creation_stack(next_key: String) -> String:
	var display_stack := _creation_stack.duplicate()
	display_stack.append(next_key)
	return " -> ".join(display_stack)


func _script_extends_or_equals(candidate: Script, expected: Script) -> bool:
	var current := candidate
	while current != null:
		if current == expected:
			return true
		current = current.get_base_script()
	return false
