@tool

# GF 插件编辑器工作区窗口管理辅助。
extends RefCounted


# --- 常量 ---

## 扩展管理页面脚本路径。
## [br]
## @api framework_internal
## [br]
## @layer kernel/editor
const EXTENSION_MANAGER_DOCK_SCRIPT_PATH: String = "res://addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd"

## 工作区窗口脚本。
## [br]
## @api framework_internal
## [br]
## @layer kernel/editor
const GFEditorWorkspaceWindowBase = preload("res://addons/gf/kernel/editor/gf_editor_workspace_window.gd")

## 扩展启用设置脚本。
## [br]
## @api framework_internal
## [br]
## @layer kernel/editor
const GFExtensionSettingsBase = preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")


# --- 私有变量 ---

var _standard_dock_records: Array[Dictionary] = []
var _workspace_window: Window = null


# --- 公共方法 ---

## 安装 GF 编辑器工作区窗口入口。
## [br]
## @api framework_internal
## [br]
## @layer kernel/editor
## [br]
## @param plugin: 当前 EditorPlugin 实例。
## [br]
## @param standard_dock_records: 组合入口传入的标准库页面记录。
## [br]
## @schema standard_dock_records: Array of Dictionary dock page records.
func setup(plugin: EditorPlugin, standard_dock_records: Array[Dictionary] = []) -> void:
	if plugin == null:
		return

	set_standard_dock_records(standard_dock_records)
	var records := _collect_core_dock_records()
	records.append_array(_collect_enabled_extension_dock_records())
	records.sort_custom(_sort_dock_records)
	_add_workspace_window(records)


## 移除 GF 编辑器工作区窗口入口。
## [br]
## @api framework_internal
## [br]
## @layer kernel/editor
## [br]
## @param _plugin: 当前 EditorPlugin 实例。
func cleanup(_plugin: EditorPlugin) -> void:
	if is_instance_valid(_workspace_window):
		_workspace_window.queue_free()
	_workspace_window = null


## 设置由组合入口收集到的标准库页面记录。
## [br]
## @api framework_internal
## [br]
## @layer kernel/editor
## [br]
## @param standard_dock_records: 标准库页面记录。
## [br]
## @schema standard_dock_records: Array of Dictionary dock page records.
func set_standard_dock_records(standard_dock_records: Array[Dictionary]) -> void:
	_standard_dock_records = _copy_records(standard_dock_records)


## 显示 GF 编辑器工作区。
## [br]
## @api framework_internal
## [br]
## @layer kernel/editor
func show_workspace() -> void:
	if is_instance_valid(_workspace_window) and _workspace_window.has_method("popup_workspace"):
		_workspace_window.call("popup_workspace")


## 获取当前工作区窗口。
## [br]
## @api framework_internal
## [br]
## @layer kernel/editor
## [br]
## @return 工作区窗口；未安装时返回 null。
func get_workspace_window() -> Window:
	return _workspace_window


# --- 私有/辅助方法 ---

func _collect_core_dock_records() -> Array[Dictionary]:
	var records := _copy_records(_standard_dock_records)
	records.append(
		{
			"path": EXTENSION_MANAGER_DOCK_SCRIPT_PATH,
			"label": "GF Extensions",
			"short_label": "扩展",
			"order": 80,
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
	for manifest: GFExtensionManifest in GFExtensionSettingsBase.get_enabled_manifests():
		for dock_path: String in manifest.editor_dock_paths:
			var normalized_path := dock_path.strip_edges()
			if normalized_path.is_empty() or used_paths.has(normalized_path):
				continue

			used_paths[normalized_path] = true
			records.append({
				"path": normalized_path,
				"label": _get_extension_dock_label(manifest, normalized_path),
				"short_label": _get_extension_short_label(manifest),
				"order": manifest.editor_dock_order,
			})
	return records


func _add_workspace_window(records: Array[Dictionary]) -> void:
	_workspace_window = GFEditorWorkspaceWindowBase.new()
	_workspace_window.setup(records)
	EditorInterface.get_base_control().add_child(_workspace_window)


func _get_extension_dock_label(manifest: GFExtensionManifest, dock_path: String) -> String:
	var extension_name := manifest.display_name
	if extension_name.is_empty():
		extension_name = manifest.id
	if manifest.editor_dock_paths.size() <= 1:
		return extension_name

	var script_label := dock_path.get_file().get_basename()
	if script_label.begins_with("gf_"):
		script_label = script_label.substr(3)
	if script_label.ends_with("_dock"):
		script_label = script_label.substr(0, script_label.length() - 5)
	if script_label.is_empty():
		return extension_name
	script_label = script_label.to_pascal_case()
	if extension_name.ends_with(script_label):
		return extension_name
	return "%s %s" % [extension_name, script_label]


func _get_extension_short_label(manifest: GFExtensionManifest) -> String:
	if not manifest.editor_dock_short_label.is_empty():
		return manifest.editor_dock_short_label

	var extension_name := manifest.display_name
	if extension_name.is_empty():
		extension_name = manifest.id
	if extension_name.begins_with("GF "):
		extension_name = extension_name.substr(3)
	return extension_name


func _sort_dock_records(left: Dictionary, right: Dictionary) -> bool:
	var left_order := int(left.get("order", 1000))
	var right_order := int(right.get("order", 1000))
	if left_order != right_order:
		return left_order < right_order

	var left_label := String(left.get("label", ""))
	var right_label := String(right.get("label", ""))
	if left_label != right_label:
		return left_label < right_label
	return String(left.get("path", "")) < String(right.get("path", ""))
