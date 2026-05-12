@tool

## GF 插件底部面板管理辅助。
extends RefCounted


# --- 常量 ---

const PACKAGE_MANAGER_DOCK_SCRIPT_PATH: String = "res://addons/gf/kernel/editor/package/gf_package_manager_dock.gd"
const GFStandardEditorExtensionsBase = preload("res://addons/gf/standard/editor/gf_standard_editor_extensions.gd")
const GFPackageSettingsBase = preload("res://addons/gf/kernel/package/gf_package_settings.gd")


# --- 私有变量 ---

var _dock_records: Array[Dictionary] = []


# --- 公共方法 ---

## 安装 GF 底部面板。
## @param plugin: 当前 EditorPlugin 实例。
func setup(plugin: EditorPlugin) -> void:
	if plugin == null:
		return

	for record: Dictionary in _collect_core_dock_records():
		_add_bottom_dock(plugin, String(record["path"]), String(record["label"]))
	for record: Dictionary in _collect_enabled_package_dock_records():
		_add_bottom_dock(plugin, String(record["path"]), String(record["label"]))


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


# --- 私有/辅助方法 ---

func _collect_core_dock_records() -> Array[Dictionary]:
	var records := GFStandardEditorExtensionsBase.get_dock_records()
	records.append(
		{
			"path": PACKAGE_MANAGER_DOCK_SCRIPT_PATH,
			"label": "GF Packages",
		}
	)
	return records


func _collect_enabled_package_dock_records() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var used_paths: Dictionary = {}
	for manifest: GFPackageManifest in GFPackageSettingsBase.get_enabled_manifests(true):
		for dock_path: String in manifest.editor_dock_paths:
			var normalized_path := dock_path.strip_edges()
			if normalized_path.is_empty() or used_paths.has(normalized_path):
				continue

			used_paths[normalized_path] = true
			records.append({
				"path": normalized_path,
				"label": _get_package_dock_label(manifest, normalized_path),
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


func _get_package_dock_label(manifest: GFPackageManifest, dock_path: String) -> String:
	var package_name := manifest.display_name
	if package_name.is_empty():
		package_name = manifest.id
	var script_name := dock_path.get_file().get_basename().to_pascal_case()
	return "%s %s" % [package_name, script_name]
