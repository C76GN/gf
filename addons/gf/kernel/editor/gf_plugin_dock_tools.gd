@tool

## GF 插件底部面板管理辅助。
extends RefCounted


# --- 常量 ---

const EXTENSION_MANAGER_DOCK_SCRIPT_PATH: String = "res://addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd"
const GFEditorWorkspaceDockBase = preload("res://addons/gf/kernel/editor/gf_editor_workspace_dock.gd")
const GFExtensionSettingsBase = preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")


# --- 私有变量 ---

var _dock_records: Array[Dictionary] = []
var _standard_dock_records: Array[Dictionary] = []


# --- 公共方法 ---

## 安装 GF 底部面板。
## @param plugin: 当前 EditorPlugin 实例。
## @param standard_dock_records: 组合入口传入的标准库 Dock 记录。
func setup(plugin: EditorPlugin, standard_dock_records: Array[Dictionary] = []) -> void:
	if plugin == null:
		return

	set_standard_dock_records(standard_dock_records)
	var records := _collect_core_dock_records()
	records.append_array(_collect_enabled_extension_dock_records())
	_add_workspace_dock(plugin, records)


## 移除 GF 底部面板。
## @param plugin: 当前 EditorPlugin 实例。
func cleanup(plugin: EditorPlugin) -> void:
	if plugin == null:
		return

	for record: Dictionary in _dock_records:
		var dock := record.get("dock") as Control
		if is_instance_valid(dock):
			plugin.remove_control_from_bottom_panel(dock)
			dock.queue_free()
	_dock_records.clear()


## 设置由组合入口收集到的标准库 Dock 记录。
## @param standard_dock_records: 标准库 Dock 记录。
func set_standard_dock_records(standard_dock_records: Array[Dictionary]) -> void:
	_standard_dock_records = _copy_records(standard_dock_records)


# --- 私有/辅助方法 ---

func _collect_core_dock_records() -> Array[Dictionary]:
	var records := _copy_records(_standard_dock_records)
	records.append(
		{
			"path": EXTENSION_MANAGER_DOCK_SCRIPT_PATH,
			"label": "GF Extensions",
		}
	)
	return records


func _copy_records(source: Array[Dictionary]) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for record: Dictionary in source:
		records.append(record.duplicate(true))
	return records


func _collect_enabled_extension_dock_records() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var used_paths: Dictionary = {}
	for manifest: GFExtensionManifest in GFExtensionSettingsBase.get_enabled_manifests(true):
		for dock_path: String in manifest.editor_dock_paths:
			var normalized_path := dock_path.strip_edges()
			if normalized_path.is_empty() or used_paths.has(normalized_path):
				continue

			used_paths[normalized_path] = true
			records.append({
				"path": normalized_path,
				"label": _get_extension_dock_label(manifest, normalized_path),
			})
	return records


func _add_bottom_dock(plugin: EditorPlugin, script_path: String, fallback_label: String) -> void:
	var dock_script := load(script_path) as Script
	if dock_script == null or not dock_script.can_instantiate():
		push_error("[GF Framework] 底部面板脚本加载失败：%s" % script_path)
		return

	var dock := dock_script.new() as Control
	if dock == null:
		push_error("[GF Framework] 底部面板实例化失败：%s" % script_path)
		return

	var label := fallback_label
	if not dock.name.is_empty():
		label = dock.name
	var button := plugin.add_control_to_bottom_panel(dock, label)
	_dock_records.append({
		"dock": dock,
		"button": button,
		"path": script_path,
	})


func _add_workspace_dock(plugin: EditorPlugin, records: Array[Dictionary]) -> void:
	var dock := GFEditorWorkspaceDockBase.new()
	dock.setup(records)
	var button := plugin.add_control_to_bottom_panel(dock, dock.name)
	_dock_records.append({
		"dock": dock,
		"button": button,
		"path": "res://addons/gf/kernel/editor/gf_editor_workspace_dock.gd",
	})


func _get_extension_dock_label(manifest: GFExtensionManifest, dock_path: String) -> String:
	var extension_name := manifest.display_name
	if extension_name.is_empty():
		extension_name = manifest.id
	var script_name := dock_path.get_file().get_basename().to_pascal_case()
	return "%s %s" % [extension_name, script_name]
