@tool

## GF Capability Inspector: 在 Godot Inspector 中管理节点能力。
extends EditorInspectorPlugin


# --- 常量 ---

const META_CAPABILITY_CONTAINER: StringName = &"_gf_capability_container"
const META_CAPABILITY_ACTIVE: StringName = &"_gf_capability_active"
const META_ORIGINAL_PROCESS_MODE: StringName = &"_gf_capability_original_process_mode"
const CAPABILITY_EXTENSION_ID: String = "gf.capability"
const GF_CAPABILITY_CONTAINER_SCRIPT_PATH: String = "res://addons/gf/extensions/capability/nodes/gf_capability_container.gd"
const GF_NODE_CAPABILITY_SCRIPT_PATH: String = "res://addons/gf/extensions/capability/nodes/gf_node_capability.gd"
const GF_NODE_2D_CAPABILITY_SCRIPT_PATH: String = "res://addons/gf/extensions/capability/nodes/gf_node_2d_capability.gd"
const GF_NODE_3D_CAPABILITY_SCRIPT_PATH: String = "res://addons/gf/extensions/capability/nodes/gf_node_3d_capability.gd"
const GF_CONTROL_CAPABILITY_SCRIPT_PATH: String = "res://addons/gf/extensions/capability/nodes/gf_control_capability.gd"
const GF_CAPABILITY_RECIPE_SCRIPT_PATH: String = "res://addons/gf/extensions/capability/recipes/gf_capability_recipe.gd"
const GF_EXTENSION_SETTINGS_BASE := preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")
const GF_EDITOR_TYPE_INDEX_BASE := preload("res://addons/gf/kernel/editor/gf_editor_type_index.gd")
const _GF_VALIDATION_REPORT_SCRIPT = preload("res://addons/gf/standard/foundation/validation/gf_validation_report.gd")
const _SCRIPT_TYPE_INSPECTOR: Script = preload("res://addons/gf/kernel/core/gf_script_type_inspector.gd")


# --- Godot 回调方法 ---

func _can_handle(object: Object) -> bool:
	if not _is_capability_extension_enabled():
		return false

	var node := object as Node
	if node == null:
		return false
	if bool(node.get_meta(META_CAPABILITY_CONTAINER, false)):
		return false

	var container_script := _get_capability_container_script()
	if container_script == null:
		return false

	var script := node.get_script() as Script
	return script == null or not _SCRIPT_TYPE_INSPECTOR.script_extends_or_equals(script, container_script)


func _parse_begin(object: Object) -> void:
	var target := object as Node
	if target == null:
		return

	var root := VBoxContainer.new()
	root.name = "GFCapabilityInspector"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL

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

	var recipe_button := MenuButton.new()
	recipe_button.text = "Recipe"
	recipe_button.tooltip_text = "应用 GFCapabilityRecipe 中的节点能力条目"
	header.add_child(recipe_button)
	_populate_recipe_menu(recipe_button.get_popup(), target)

	var validate_button := Button.new()
	validate_button.text = "校验"
	validate_button.tooltip_text = "检查节点能力依赖"
	validate_button.pressed.connect(_on_validate_capabilities_pressed.bind(target), CONNECT_DEFERRED)
	header.add_child(validate_button)

	var capabilities := _get_capability_nodes(target)
	if capabilities.is_empty():
		var empty_label := Label.new()
		empty_label.text = "未挂载节点能力"
		empty_label.modulate = Color(0.65, 0.65, 0.65)
		root.add_child(empty_label)
		add_custom_control(root)
		return

	for capability: Node in capabilities:
		if not is_instance_valid(capability):
			continue
		root.add_child(_create_capability_row(target, capability))

	add_custom_control(root)


# --- 私有/辅助方法 ---

func _populate_add_menu(popup: PopupMenu, target: Node) -> void:
	popup.clear()
	if popup.id_pressed.is_connected(_on_add_menu_id_pressed):
		popup.id_pressed.disconnect(_on_add_menu_id_pressed)

	var candidates := _collect_node_capability_candidates()
	if candidates.is_empty():
		popup.add_item("未找到 GFNodeCapability")
		popup.set_item_disabled(0, true)
		return

	for i: int in range(candidates.size()):
		var candidate := candidates[i] as Dictionary
		popup.add_item(String(candidate["label"]), i)
		popup.set_item_metadata(i, candidate)

	popup.id_pressed.connect(_on_add_menu_id_pressed.bind(popup, target), CONNECT_DEFERRED)


func _populate_recipe_menu(popup: PopupMenu, target: Node) -> void:
	popup.clear()
	if popup.id_pressed.is_connected(_on_recipe_menu_id_pressed):
		popup.id_pressed.disconnect(_on_recipe_menu_id_pressed)

	var candidates := _collect_recipe_candidates()
	if candidates.is_empty():
		popup.add_item("未找到 GFCapabilityRecipe")
		popup.set_item_disabled(0, true)
		return

	for i: int in range(candidates.size()):
		var candidate := candidates[i] as Dictionary
		popup.add_item(String(candidate["label"]), i)
		popup.set_item_metadata(i, candidate)

	popup.id_pressed.connect(_on_recipe_menu_id_pressed.bind(popup, target), CONNECT_DEFERRED)


func _collect_node_capability_candidates() -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	if not _is_capability_extension_enabled():
		return candidates

	var used_paths: Dictionary = {}
	var type_index: Variant = GF_EDITOR_TYPE_INDEX_BASE.new()
	var base_scripts := _get_node_capability_base_scripts()
	var excluded_scripts := base_scripts.duplicate()

	for base_script: Script in base_scripts:
		for record: Dictionary in type_index.collect_scripts_extending(base_script, excluded_scripts):
			var class_name_value := String(record["class_name"])
			var path := String(record["path"])
			if used_paths.has(path):
				continue

			used_paths[path] = true
			candidates.append({
				"kind": "script",
				"label": class_name_value,
				"path": path,
				"default_name": class_name_value,
			})

	for base_script: Script in base_scripts:
		for scene_record: Dictionary in type_index.collect_scene_roots_extending(base_script, used_paths):
			var display_name := String(scene_record["display_name"])
			candidates.append({
				"kind": "scene",
				"label": "%s 场景" % display_name,
				"path": String(scene_record["path"]),
				"default_name": display_name,
			})

	candidates.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return String(left["label"]) < String(right["label"])
	)
	return candidates


func _collect_recipe_candidates() -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	if not Engine.is_editor_hint() or not _is_capability_extension_enabled():
		return candidates

	var filesystem := EditorInterface.get_resource_filesystem()
	if filesystem == null:
		return candidates

	var root_dir := filesystem.get_filesystem()
	if root_dir == null:
		return candidates

	var used_paths: Dictionary = {}
	_collect_recipe_candidates_recursive(root_dir, candidates, used_paths)
	candidates.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return String(left["label"]) < String(right["label"])
	)
	return candidates


func _collect_recipe_candidates_recursive(
	directory: EditorFileSystemDirectory,
	candidates: Array[Dictionary],
	used_paths: Dictionary
) -> void:
	for i: int in range(directory.get_subdir_count()):
		_collect_recipe_candidates_recursive(directory.get_subdir(i), candidates, used_paths)

	for i: int in range(directory.get_file_count()):
		var file_name := directory.get_file(i)
		if not _is_recipe_resource_file(file_name):
			continue

		var path := _join_resource_path(directory.get_path(), file_name)
		if used_paths.has(path):
			continue
		var recipe_base_script := _get_capability_recipe_script()
		if recipe_base_script == null:
			return

		var recipe := load(path) as Resource
		if recipe == null or not _resource_extends_script(recipe, recipe_base_script):
			continue

		used_paths[path] = true
		candidates.append({
			"label": _get_recipe_display_label(recipe, path),
			"path": path,
			"recipe": recipe,
		})


func _get_node_capability_base_scripts() -> Array[Script]:
	var result: Array[Script] = []
	for path: String in [
		GF_NODE_CAPABILITY_SCRIPT_PATH,
		GF_NODE_2D_CAPABILITY_SCRIPT_PATH,
		GF_NODE_3D_CAPABILITY_SCRIPT_PATH,
		GF_CONTROL_CAPABILITY_SCRIPT_PATH,
	]:
		var script := _load_script_or_null(path)
		if script != null:
			result.append(script)
	return result


func _get_capability_container_script() -> Script:
	return _load_script_or_null(GF_CAPABILITY_CONTAINER_SCRIPT_PATH)


func _get_capability_recipe_script() -> Script:
	return _load_script_or_null(GF_CAPABILITY_RECIPE_SCRIPT_PATH)


func _load_script_or_null(path: String) -> Script:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Script


func _is_capability_extension_enabled() -> bool:
	return GF_EXTENSION_SETTINGS_BASE.is_extension_enabled(CAPABILITY_EXTENSION_ID)


func _resource_extends_script(resource: Resource, base_script: Script) -> bool:
	if resource == null or base_script == null:
		return false
	var script := resource.get_script() as Script
	return script != null and _SCRIPT_TYPE_INSPECTOR.script_extends_or_equals(script, base_script)


func _is_recipe_resource_file(file_name: String) -> bool:
	var extension := file_name.get_extension().to_lower()
	return extension == "tres" or extension == "res"


func _join_resource_path(dir_path: String, file_name: String) -> String:
	if dir_path.ends_with("/"):
		return dir_path + file_name
	return "%s/%s" % [dir_path, file_name]


func _get_recipe_display_label(recipe: Resource, path: String) -> String:
	var display_name := ""
	if recipe != null and recipe.has_method("get_display_name"):
		display_name = String(recipe.call("get_display_name"))
	if display_name.is_empty():
		display_name = path.get_file().get_basename().to_pascal_case()
	return "%s (%s)" % [display_name, path]


func _script_is_node_capability(script: Script) -> bool:
	if script == null:
		return false
	for base_script: Script in _get_node_capability_base_scripts():
		if _SCRIPT_TYPE_INSPECTOR.script_extends_or_equals(script, base_script):
			return true
	return false


func _get_packed_scene_root_script(scene: PackedScene) -> Script:
	if scene == null:
		return null

	var state := scene.get_state()
	if state == null:
		return null

	for node_index: int in range(state.get_node_count()):
		if not state.get_node_path(node_index, true).is_empty():
			continue

		for property_index: int in range(state.get_node_property_count(node_index)):
			if state.get_node_property_name(node_index, property_index) == &"script":
				return state.get_node_property_value(node_index, property_index) as Script
	return null


func _create_capability_row(target: Node, capability: Node) -> Control:
	var wrapper := VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_child(row)

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

	var properties := _create_capability_properties(capability)
	if properties.get_child_count() > 0:
		wrapper.add_child(properties)

	return wrapper


func _create_capability_properties(capability: Node) -> Control:
	var properties := VBoxContainer.new()
	properties.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	for property_info: Dictionary in capability.get_property_list():
		if not _is_editable_capability_property(property_info):
			continue

		var property_name := String(property_info["name"])
		var editor_property := EditorInspector.instantiate_property_editor(
			capability,
			int(property_info.get("type", TYPE_NIL)),
			property_name,
			int(property_info.get("hint", PROPERTY_HINT_NONE)),
			String(property_info.get("hint_string", "")),
			int(property_info.get("usage", PROPERTY_USAGE_DEFAULT)),
			false
		)
		if editor_property != null:
			var row := HBoxContainer.new()
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			var label := Label.new()
			label.text = _get_property_display_name(property_name)
			label.tooltip_text = property_name
			label.custom_minimum_size = Vector2(128, 0)
			row.add_child(label)

			editor_property.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(editor_property)
			properties.add_child(row)

	return properties


func _is_editable_capability_property(property_info: Dictionary) -> bool:
	var usage := int(property_info.get("usage", 0))
	if (usage & PROPERTY_USAGE_EDITOR) == 0:
		return false
	if (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
		return false

	var property_name := String(property_info.get("name", ""))
	return (
		not property_name.is_empty()
		and property_name != "script"
		and property_name != "active"
	)


func _get_property_display_name(property_name: String) -> String:
	if property_name.is_empty():
		return ""
	return property_name.capitalize()


func _get_capability_display_name(capability: Node) -> String:
	var script := capability.get_script() as Script
	if script != null:
		var global_name := script.get_global_name()
		if global_name != &"":
			return String(global_name)
	return capability.name


func _get_capability_containers(target: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child in target.get_children(true):
		if _is_capability_container(child):
			result.append(child as Node)
	return result


func _get_or_create_capability_container(target: Node, capability: Node) -> Node:
	for existing: Node in _get_capability_containers(target):
		if _container_matches_capability(existing, capability):
			return existing

	var container := _create_capability_container_node(target, capability)
	container.set_meta(META_CAPABILITY_CONTAINER, true)
	_try_attach_capability_container_script(container)
	target.add_child(container, true)
	_set_owner_recursive(container, EditorInterface.get_edited_scene_root())
	return container


func _create_capability_container_node(target: Node, capability: Node) -> Node:
	var container: Node
	if target is Node3D and capability is Node3D:
		container = Node3D.new()
		container.name = "GFCapabilityContainer3D"
	elif target is Node2D and capability is Node2D:
		container = Node2D.new()
		container.name = "GFCapabilityContainer2D"
	elif target is Control and capability is Control:
		container = Control.new()
		container.name = "GFCapabilityContainerControl"
		_configure_control_container(container as Control)
	else:
		container = Node.new()
		container.name = "GFCapabilityContainer"
	return container


func _try_attach_capability_container_script(container: Node) -> void:
	var container_script := _get_capability_container_script()
	if container_script == null or not container_script.can_instantiate():
		push_warning("[GF Framework] 能力容器脚本不可用，已改用元数据标记容器。")
		return

	var base_type := String(container_script.get_instance_base_type())
	if not base_type.is_empty() and not container.is_class(base_type):
		push_warning("[GF Framework] 能力容器节点类型与脚本基类不匹配，已改用元数据标记容器。")
		return

	container.set_script(container_script)


func _configure_control_container(container: Control) -> void:
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	container.offset_left = 0.0
	container.offset_top = 0.0
	container.offset_right = 0.0
	container.offset_bottom = 0.0


func _container_matches_capability(container: Node, capability: Node) -> bool:
	if capability is Node3D:
		return container is Node3D
	if capability is Node2D:
		return container is Node2D
	if capability is Control:
		return container is Control
	return not (container is Node2D) and not (container is Node3D) and not (container is Control)


func _is_capability_container(node: Node) -> bool:
	if bool(node.get_meta(META_CAPABILITY_CONTAINER, false)):
		return true

	var container_script := _get_capability_container_script()
	var node_script := node.get_script() as Script
	return (
		container_script != null
		and node_script != null
		and _SCRIPT_TYPE_INSPECTOR.script_extends_or_equals(node_script, container_script)
	)


func _get_capability_nodes(target: Node) -> Array[Node]:
	var result: Array[Node] = []
	for container: Node in _get_capability_containers(target):
		for child in container.get_children(true):
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

	var container := _get_or_create_capability_container(target, node)
	node.name = _make_unique_child_name(container, String(candidate["default_name"]))
	container.add_child(node, true)
	_set_owner_recursive(node, EditorInterface.get_edited_scene_root())
	_select_editor_node(node)
	EditorInterface.inspect_object(node)


func _apply_recipe_to_target(target: Node, recipe: Resource) -> Dictionary:
	var report := _GF_VALIDATION_REPORT_SCRIPT.new("Capability recipe editor apply")
	var added: Array[Dictionary] = []
	var skipped: Array[Dictionary] = []
	if not is_instance_valid(target):
		report.add_error(&"invalid_target", "Target node is invalid.")
		return _recipe_apply_report_to_dict(report, recipe, added, skipped)
	if recipe == null:
		report.add_error(&"invalid_recipe", "Capability recipe is null.")
		return _recipe_apply_report_to_dict(report, recipe, added, skipped)

	var entries := recipe.get("entries") as Array
	if entries == null:
		entries = []

	for index: int in range(entries.size()):
		var entry := entries[index] as Resource
		if entry == null:
			report.add_warning(&"null_entry", "Recipe contains a null entry.", str(index))
			continue
		if not entry.has_method("is_valid_entry") or not bool(entry.call("is_valid_entry")):
			report.add_error(&"invalid_entry", "Recipe entry requires capability_type or scene.", str(index))
			continue

		var node := _create_capability_node_from_recipe_entry(entry, report, index)
		if node == null:
			skipped.append({
				"index": index,
				"kind": "not_node_capability",
			})
			continue

		var capability_script := entry.get("capability_type") as Script
		if capability_script == null:
			capability_script = node.get_script() as Script
		if capability_script != null and _target_has_capability_script(target, capability_script):
			node.queue_free()
			skipped.append({
				"index": index,
				"kind": "already_exists",
				"type": _get_script_key(capability_script),
			})
			continue

		var container := _get_or_create_capability_container(target, node)
		node.name = _make_unique_child_name(container, _get_recipe_entry_node_name(entry, node, index))
		container.add_child(node, true)
		_set_owner_recursive(node, EditorInterface.get_edited_scene_root())
		_set_editor_capability_active(node, bool(entry.get("active")))
		added.append({
			"index": index,
			"type": _get_script_key(capability_script),
			"name": node.name,
			"active": bool(entry.get("active")),
		})

	var result := _recipe_apply_report_to_dict(report, recipe, added, skipped)
	result["dependency_report"] = _build_editor_capability_report(target)
	_select_editor_node(target)
	EditorInterface.inspect_object(target)
	return result


func _create_capability_node_from_recipe_entry(
	entry: Resource,
	report: Variant,
	index: int
) -> Node:
	if entry == null:
		return null
	var entry_scene := entry.get("scene") as PackedScene
	if entry_scene != null:
		var scene_node := entry_scene.instantiate() as Node
		if scene_node == null:
			report.add_error(&"scene_root_not_node", "Recipe scene root must be a Node.", str(index))
			return null
		var scene_script := entry.get("capability_type") as Script
		if scene_script == null:
			scene_script = scene_node.get_script() as Script
		if not _script_is_node_capability(scene_script):
			report.add_warning(&"not_node_capability", "Recipe scene root is not a GF node capability.", str(index))
			scene_node.queue_free()
			return null
		return scene_node

	var script := entry.get("capability_type") as Script
	if not _script_is_node_capability(script):
		report.add_warning(&"not_node_capability", "Recipe entry is not a GF node capability.", str(index))
		return null
	if not script.can_instantiate():
		report.add_error(&"script_not_instantiable", "Recipe capability script cannot be instantiated.", str(index))
		return null

	var node := script.new() as Node
	if node == null:
		report.add_error(&"script_not_node", "Recipe capability script must instantiate a Node.", str(index))
	return node


func _recipe_apply_report_to_dict(
	report: Variant,
	recipe: Resource,
	added: Array[Dictionary],
	skipped: Array[Dictionary]
) -> Dictionary:
	return report.to_dict(
		{
			"recipe_id": recipe.get("recipe_id") if recipe != null else &"",
			"added": added,
			"skipped": skipped,
			"added_count": added.size(),
			"skipped_count": skipped.size(),
		},
		{
			"include_subject": false,
			"include_metadata": false,
			"include_info_count": false,
			"include_issue_count": false,
			"next_actions": _get_editor_capability_next_actions(),
			"no_action": "No action required.",
			"fallback_action": "Review the first reported capability editor issue.",
		}
	)


func _get_recipe_entry_node_name(entry: Resource, node: Node, index: int) -> String:
	var capability_type: Script = null
	if entry != null:
		capability_type = entry.get("capability_type") as Script
	if capability_type != null:
		var global_name := capability_type.get_global_name()
		if global_name != &"":
			return String(global_name)
	if node != null and not String(node.name).is_empty():
		return String(node.name)
	return "Capability%d" % (index + 1)


func _build_editor_capability_report(target: Node) -> Dictionary:
	var report := _GF_VALIDATION_REPORT_SCRIPT.new("Capability inspector")
	if not is_instance_valid(target):
		report.add_error(&"invalid_target", "Target node is invalid.")
		return report.to_dict({}, { "include_subject": false })

	var capabilities := _get_capability_nodes(target)
	var capability_records: Array[Dictionary] = []
	var seen_scripts: Dictionary = {}
	for capability: Node in capabilities:
		var script := capability.get_script() as Script
		var script_key := _get_script_key(script)
		if script == null:
			report.add_warning(&"missing_capability_script", "Capability node has no script.", capability.get_path())
			continue
		if seen_scripts.has(script):
			report.add_warning(&"duplicate_capability", "Target contains duplicate capability scripts.", script_key)
		seen_scripts[script] = true

		var required_types := _get_required_capability_types(capability, report, script_key)
		var missing_dependencies: Array[Dictionary] = []
		for required_type: Script in required_types:
			if _capability_list_has_script(capabilities, required_type):
				continue
			var missing_entry := {
				"capability": script_key,
				"required": _get_script_key(required_type),
			}
			missing_dependencies.append(missing_entry)
			report.add_error(
				&"missing_required_capability",
				"Capability is missing a required capability.",
				script_key,
				_get_script_key(required_type)
			)

		capability_records.append({
			"type": script_key,
			"name": capability.name,
			"active": _read_editor_capability_active(capability),
			"required": _script_array_to_keys(required_types),
			"missing_dependencies": missing_dependencies,
		})

	return report.to_dict(
		{
			"target": target.get_path(),
			"capability_count": capability_records.size(),
			"capabilities": capability_records,
		},
		{
			"include_subject": false,
			"include_metadata": false,
			"include_info_count": false,
			"include_issue_count": false,
			"next_actions": _get_editor_capability_next_actions(),
			"no_action": "No action required.",
			"fallback_action": "Review the first reported capability editor issue.",
		}
	)


func _get_required_capability_types(
	capability: Node,
	report: Variant,
	script_key: String
) -> Array[Script]:
	if capability == null or not capability.has_method("get_required_capabilities"):
		return [] as Array[Script]

	var raw_value: Variant = capability.call("get_required_capabilities")
	if raw_value == null:
		return [] as Array[Script]
	if not raw_value is Array:
		report.add_warning(
			&"invalid_required_capabilities",
			"get_required_capabilities() must return an Array of Script values.",
			script_key
		)
		return [] as Array[Script]

	var result: Array[Script] = []
	for item: Variant in raw_value:
		if item is Script and not result.has(item):
			result.append(item as Script)
		elif item != null:
			report.add_warning(
				&"invalid_required_capability_type",
				"get_required_capabilities() contains a non-Script value.",
				script_key
			)
	return result


func _target_has_capability_script(target: Node, expected_script: Script) -> bool:
	return _capability_list_has_script(_get_capability_nodes(target), expected_script)


func _capability_list_has_script(capabilities: Array[Node], expected_script: Script) -> bool:
	if expected_script == null:
		return false

	for capability: Node in capabilities:
		var script := capability.get_script() as Script
		if script == null:
			continue
		if script == expected_script:
			return true
		if _SCRIPT_TYPE_INSPECTOR.script_extends_or_equals(script, expected_script):
			return true
	return false


func _script_array_to_keys(scripts: Array[Script]) -> PackedStringArray:
	var result := PackedStringArray()
	for script: Script in scripts:
		result.append(_get_script_key(script))
	result.sort()
	return result


func _get_script_key(script: Script) -> String:
	if script == null:
		return "<null>"

	var global_name := script.get_global_name()
	if global_name != &"":
		return String(global_name)
	if not script.resource_path.is_empty():
		return script.resource_path
	return str(script.get_instance_id())


func _show_editor_report(title: String, report: Dictionary) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.exclusive = false

	var text_edit := TextEdit.new()
	text_edit.editable = false
	text_edit.custom_minimum_size = Vector2(720, 420)
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_edit.text = _format_editor_report(report)
	dialog.add_child(text_edit)
	dialog.confirmed.connect(dialog.queue_free, CONNECT_DEFERRED)
	dialog.close_requested.connect(dialog.queue_free, CONNECT_DEFERRED)

	var base_control := EditorInterface.get_base_control()
	if base_control != null:
		base_control.add_child(dialog)
		dialog.popup_centered(Vector2i(760, 460))


func _format_editor_report(report: Dictionary) -> String:
	var lines := PackedStringArray()
	lines.append(String(report.get("summary", "Capability report")))
	lines.append("ok: %s" % str(report.get("ok", false)))
	lines.append("errors: %d, warnings: %d" % [
		int(report.get("error_count", 0)),
		int(report.get("warning_count", 0)),
	])
	if report.has("added_count"):
		lines.append("added: %d, skipped: %d" % [
			int(report.get("added_count", 0)),
			int(report.get("skipped_count", 0)),
		])
	if report.has("capability_count"):
		lines.append("capabilities: %d" % int(report.get("capability_count", 0)))

	var issues := report.get("issues", []) as Array
	if issues != null and not issues.is_empty():
		lines.append("")
		lines.append("Issues:")
		for issue: Dictionary in issues:
			var kind := String(issue.get("kind", "unknown"))
			var severity := String(issue.get("severity", "error"))
			var message := String(issue.get("message", ""))
			var key := str(issue.get("key", ""))
			var path := String(issue.get("path", ""))
			lines.append("- [%s] %s: %s" % [severity, kind, message])
			if not key.is_empty() or not path.is_empty():
				lines.append("  key=%s path=%s" % [key, path])

	lines.append("")
	lines.append("Next action: %s" % String(report.get("next_action", "No action required.")))
	return "\n".join(lines)


func _get_editor_capability_next_actions() -> Dictionary:
	return {
		"invalid_target": "Select a valid Node before using the capability inspector.",
		"invalid_recipe": "Assign a valid GFCapabilityRecipe resource.",
		"invalid_entry": "Set capability_type or scene on every Recipe entry.",
		"null_entry": "Remove the null Recipe entry or replace it with a valid entry.",
		"not_node_capability": "Use a GFNodeCapability, GFNode2DCapability, GFNode3DCapability, or GFControlCapability entry.",
		"script_not_instantiable": "Use an instantiable capability script or a PackedScene entry.",
		"script_not_node": "Use node-based capabilities in the editor inspector.",
		"scene_root_not_node": "Use a scene whose root is a Node.",
		"missing_capability_script": "Attach a script to the capability node or remove it.",
		"duplicate_capability": "Remove duplicate capability nodes unless they intentionally use different registered types.",
		"missing_required_capability": "Add the required capability or adjust get_required_capabilities().",
		"invalid_required_capabilities": "Return Array[Script] from get_required_capabilities().",
		"invalid_required_capability_type": "Only Script values should be returned from get_required_capabilities().",
	}


func _remove_capability_node(target: Node, capability: Node) -> void:
	if not is_instance_valid(capability):
		return

	var container := capability.get_parent()
	capability.queue_free()
	if is_instance_valid(target):
		_select_editor_node(target)
		EditorInterface.inspect_object(target)
	if is_instance_valid(container) and container.get_child_count(true) <= 1:
		container.queue_free()


func _make_unique_child_name(parent: Node, base_name: String) -> String:
	var clean_name := base_name if not base_name.is_empty() else "Capability"
	if not parent.has_node(NodePath(clean_name)):
		return clean_name

	var index: int = 2
	while parent.has_node(NodePath("%s%d" % [clean_name, index])):
		index += 1
	return "%s%d" % [clean_name, index]


func _select_editor_node(node: Node) -> void:
	if not is_instance_valid(node):
		return

	var selection := EditorInterface.get_selection()
	if selection == null:
		return

	selection.clear()
	selection.add_node(node)


func _set_owner_recursive(node: Node, owner: Node) -> void:
	if owner == null:
		return

	node.owner = owner
	for child: Node in node.get_children(true):
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


# --- 信号处理函数 ---

func _on_add_menu_id_pressed(id: int, popup: PopupMenu, target: Node) -> void:
	var index := popup.get_item_index(id)
	if index < 0:
		return

	var candidate := popup.get_item_metadata(index) as Dictionary
	if candidate.is_empty():
		return
	_add_capability_node(target, candidate)


func _on_recipe_menu_id_pressed(id: int, popup: PopupMenu, target: Node) -> void:
	var index := popup.get_item_index(id)
	if index < 0:
		return

	var candidate := popup.get_item_metadata(index) as Dictionary
	if candidate.is_empty():
		return

	var recipe := candidate.get("recipe", null) as Resource
	var report := _apply_recipe_to_target(target, recipe)
	_show_editor_report("GF Capability Recipe", report)


func _on_validate_capabilities_pressed(target: Node) -> void:
	_show_editor_report("GF Capability Validation", _build_editor_capability_report(target))


func _on_capability_active_toggled(active: bool, capability: Node) -> void:
	if is_instance_valid(capability):
		_set_editor_capability_active(capability, active)


func _on_capability_edit_pressed(capability: Node) -> void:
	if is_instance_valid(capability):
		EditorInterface.inspect_object(capability)


func _on_capability_remove_pressed(target: Node, capability: Node) -> void:
	_remove_capability_node(target, capability)
