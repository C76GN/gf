@tool

## GF Capability Inspector: 在 Godot Inspector 中管理节点能力。
extends EditorInspectorPlugin


# --- 常量 ---

const META_CAPABILITY_CONTAINER: StringName = &"_gf_capability_container"
const META_CAPABILITY_ACTIVE: StringName = &"_gf_capability_active"
const META_ORIGINAL_PROCESS_MODE: StringName = &"_gf_capability_original_process_mode"
const GF_CAPABILITY_CONTAINER_BASE := preload("res://addons/gf/extensions/capability/gf_capability_container.gd")
const GF_NODE_CAPABILITY_BASE := preload("res://addons/gf/extensions/capability/gf_node_capability.gd")


# --- 公共方法 ---

func _can_handle(object: Object) -> bool:
	return object is Node and not object is GF_CAPABILITY_CONTAINER_BASE


func _parse_begin(object: Object) -> void:
	var target := object as Node
	if target == null:
		return

	var root := VBoxContainer.new()
	root.name = "GFCapabilityInspector"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_custom_control(root)

	var header := HBoxContainer.new()
	root.add_child(header)

	var title := Label.new()
	title.text = "GF Capabilities"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var add_button := MenuButton.new()
	add_button.text = "添加"
	add_button.tooltip_text = "添加 GF 节点能力"
	header.add_child(add_button)
	_populate_add_menu(add_button.get_popup(), target)

	var container := _get_capability_container(target)
	var capabilities := _get_capability_nodes(container)
	if capabilities.is_empty():
		var empty_label := Label.new()
		empty_label.text = "未挂载节点能力"
		empty_label.modulate = Color(0.65, 0.65, 0.65)
		root.add_child(empty_label)
		return

	for capability: Node in capabilities:
		root.add_child(_create_capability_row(target, capability))


# --- 私有/辅助方法 ---

func _populate_add_menu(popup: PopupMenu, target: Node) -> void:
	popup.clear()
	if popup.id_pressed.is_connected(_on_add_menu_id_pressed):
		popup.id_pressed.disconnect(_on_add_menu_id_pressed)

	var candidates := _collect_node_capability_candidates()
	if candidates.is_empty():
		popup.add_disabled_item("未找到 GFNodeCapability")
		return

	for i: int in range(candidates.size()):
		var candidate := candidates[i] as Dictionary
		popup.add_item(String(candidate["label"]), i)
		popup.set_item_metadata(i, candidate)

	popup.id_pressed.connect(_on_add_menu_id_pressed.bind(popup, target), CONNECT_DEFERRED)


func _collect_node_capability_candidates() -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var used_paths: Dictionary = {}

	var global_classes := ProjectSettings.get_global_class_list()
	for global_class: Dictionary in global_classes:
		var class_name_value := String(global_class.get("class", ""))
		var path := String(global_class.get("path", ""))
		if class_name_value.is_empty() or path.is_empty() or used_paths.has(path):
			continue

		var script := load(path) as Script
		if script == null or script == GF_NODE_CAPABILITY_BASE:
			continue
		if not _script_extends_or_equals(script, GF_NODE_CAPABILITY_BASE):
			continue

		used_paths[path] = true
		candidates.append({
			"kind": "script",
			"label": class_name_value,
			"path": path,
			"default_name": class_name_value,
		})

	for scene_candidate: Dictionary in _collect_scene_capability_candidates(used_paths):
		candidates.append(scene_candidate)

	candidates.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return String(left["label"]) < String(right["label"])
	)
	return candidates


func _collect_scene_capability_candidates(used_paths: Dictionary) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var filesystem := EditorInterface.get_resource_filesystem()
	if filesystem == null:
		return candidates

	var root_dir := filesystem.get_filesystem()
	if root_dir == null:
		return candidates

	var dir_stack: Array[EditorFileSystemDirectory] = [root_dir]
	while not dir_stack.is_empty():
		var current_dir := dir_stack.pop_back()
		for i: int in range(current_dir.get_subdir_count()):
			dir_stack.append(current_dir.get_subdir(i))

		for i: int in range(current_dir.get_file_count()):
			if current_dir.get_file_type(i) != "PackedScene":
				continue

			var path := _join_resource_path(current_dir.get_path(), current_dir.get_file(i))
			if used_paths.has(path):
				continue

			var script := _get_scene_root_script(path)
			if script == null or not _script_extends_or_equals(script, GF_NODE_CAPABILITY_BASE):
				continue

			used_paths[path] = true
			var display_name := path.get_file().get_basename().to_pascal_case()
			candidates.append({
				"kind": "scene",
				"label": "%s 场景" % display_name,
				"path": path,
				"default_name": display_name,
			})

	return candidates


func _get_scene_root_script(path: String) -> Script:
	var packed_scene := load(path) as PackedScene
	if packed_scene == null:
		return null

	var state := packed_scene.get_state()
	if state == null:
		return null

	for node_index: int in range(state.get_node_count()):
		if not state.get_node_path(node_index, true).is_empty():
			continue

		for property_index: int in range(state.get_node_property_count(node_index)):
			if state.get_node_property_name(node_index, property_index) == &"script":
				return state.get_node_property_value(node_index, property_index) as Script

	return null


func _join_resource_path(dir_path: String, file_name: String) -> String:
	if dir_path.ends_with("/"):
		return dir_path + file_name
	return "%s/%s" % [dir_path, file_name]


func _create_capability_row(target: Node, capability: Node) -> Control:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var active_check := CheckBox.new()
	active_check.button_pressed = _read_editor_capability_active(capability)
	active_check.tooltip_text = "启用或停用能力"
	active_check.toggled.connect(_on_capability_active_toggled.bind(capability), CONNECT_DEFERRED)
	row.add_child(active_check)

	var label := Label.new()
	label.text = _get_capability_display_name(capability)
	label.tooltip_text = capability.get_path()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	var edit_button := Button.new()
	edit_button.text = "编辑"
	edit_button.tooltip_text = "在 Inspector 中编辑该能力"
	edit_button.pressed.connect(_on_capability_edit_pressed.bind(capability), CONNECT_DEFERRED)
	row.add_child(edit_button)

	var remove_button := Button.new()
	remove_button.text = "移除"
	remove_button.tooltip_text = "移除该能力节点"
	remove_button.pressed.connect(_on_capability_remove_pressed.bind(target, capability), CONNECT_DEFERRED)
	row.add_child(remove_button)

	return row


func _get_capability_display_name(capability: Node) -> String:
	var script := capability.get_script() as Script
	if script != null:
		var global_name := script.get_global_name()
		if global_name != &"":
			return String(global_name)
	return capability.name


func _get_capability_container(target: Node) -> Node:
	for child in target.get_children(true):
		if _is_capability_container(child):
			return child as Node
	return null


func _get_or_create_capability_container(target: Node) -> Node:
	var existing := _get_capability_container(target)
	if existing != null:
		return existing

	var container := GF_CAPABILITY_CONTAINER_BASE.new() as Node
	container.name = "GFCapabilityContainer"
	container.set_meta(META_CAPABILITY_CONTAINER, true)
	target.add_child(container, true, Node.INTERNAL_MODE_BACK)
	_set_owner_recursive(container, EditorInterface.get_edited_scene_root())
	return container


func _is_capability_container(node: Node) -> bool:
	return (
		node is GF_CAPABILITY_CONTAINER_BASE
		or bool(node.get_meta(META_CAPABILITY_CONTAINER, false))
	)


func _get_capability_nodes(container: Node) -> Array[Node]:
	var result: Array[Node] = []
	if container == null:
		return result

	for child in container.get_children():
		var node := child as Node
		if node != null and node.get_script() != null:
			result.append(node)
	return result


func _create_capability_node(candidate: Dictionary) -> Node:
	var path := String(candidate["path"])
	match String(candidate["kind"]):
		"script":
			var script := load(path) as Script
			if script == null:
				return null
			var instance := script.new() as Node
			if instance == null:
				push_error("[GF Framework] 能力脚本必须能实例化为 Node：%s" % path)
			return instance

		"scene":
			var packed_scene := load(path) as PackedScene
			if packed_scene == null:
				return null
			return packed_scene.instantiate() as Node

	return null


func _add_capability_node(target: Node, candidate: Dictionary) -> void:
	if not is_instance_valid(target):
		return

	var node := _create_capability_node(candidate)
	if node == null:
		return

	var container := _get_or_create_capability_container(target)
	node.name = _make_unique_child_name(container, String(candidate["default_name"]))
	container.add_child(node, true, Node.INTERNAL_MODE_BACK)
	_set_owner_recursive(node, EditorInterface.get_edited_scene_root())
	EditorInterface.inspect_object(node)


func _remove_capability_node(target: Node, capability: Node) -> void:
	if not is_instance_valid(capability):
		return

	var container := capability.get_parent()
	capability.queue_free()
	if is_instance_valid(target):
		EditorInterface.inspect_object(target)
	if is_instance_valid(container) and container.get_child_count() <= 1:
		container.queue_free()


func _make_unique_child_name(parent: Node, base_name: String) -> String:
	var clean_name := base_name if not base_name.is_empty() else "Capability"
	if not parent.has_node(NodePath(clean_name)):
		return clean_name

	var index: int = 2
	while parent.has_node(NodePath("%s%d" % [clean_name, index])):
		index += 1
	return "%s%d" % [clean_name, index]


func _set_owner_recursive(node: Node, owner: Node) -> void:
	if owner == null:
		return

	node.owner = owner
	for child: Node in node.get_children():
		_set_owner_recursive(child, owner)


func _read_editor_capability_active(capability: Node) -> bool:
	if "active" in capability:
		return bool(capability.get("active"))
	if capability.has_meta(META_CAPABILITY_ACTIVE):
		return bool(capability.get_meta(META_CAPABILITY_ACTIVE))
	return true


func _set_editor_capability_active(capability: Node, active: bool) -> void:
	if "active" in capability:
		capability.set("active", active)
	capability.set_meta(META_CAPABILITY_ACTIVE, active)
	_set_node_tree_active_state(capability, active)


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


func _script_extends_or_equals(candidate: Script, expected: Script) -> bool:
	var current := candidate
	while current != null:
		if current == expected:
			return true
		current = current.get_base_script()
	return false


# --- 信号处理函数 ---

func _on_add_menu_id_pressed(id: int, popup: PopupMenu, target: Node) -> void:
	var index := popup.get_item_index(id)
	if index < 0:
		return

	var candidate := popup.get_item_metadata(index) as Dictionary
	if candidate.is_empty():
		return
	_add_capability_node(target, candidate)


func _on_capability_active_toggled(active: bool, capability: Node) -> void:
	if is_instance_valid(capability):
		_set_editor_capability_active(capability, active)


func _on_capability_edit_pressed(capability: Node) -> void:
	if is_instance_valid(capability):
		EditorInterface.inspect_object(capability)


func _on_capability_remove_pressed(target: Node, capability: Node) -> void:
	_remove_capability_node(target, capability)
