@tool

## GF 插件 Inspector 与导出插件管理辅助。
extends RefCounted


# --- 常量 ---

const EXTENSION_EXPORT_PLUGIN_SCRIPT_PATH: String = "res://addons/gf/kernel/editor/extension/gf_extension_export_plugin.gd"
const GFExtensionSettingsBase = preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")


# --- 私有变量 ---

var _inspector_plugins: Array[EditorInspectorPlugin] = []
var _standard_export_plugins: Array[EditorExportPlugin] = []
var _extension_export_plugin: EditorExportPlugin
var _extension_export_plugins: Array[EditorExportPlugin] = []
var _standard_inspector_records: Array[Dictionary] = []
var _standard_export_records: Array[Dictionary] = []


# --- 公共方法 ---

## 安装 GF Inspector 与导出插件。
## @param plugin: 当前 EditorPlugin 实例。
## @param standard_records: 组合入口传入的标准库 Inspector 与导出插件记录。
func setup(plugin: EditorPlugin, standard_records: Dictionary = {}) -> void:
	if plugin == null:
		return
	_standard_inspector_records = _to_record_array(standard_records.get("inspector_plugin_records", []))
	_standard_export_records = _to_record_array(standard_records.get("export_plugin_records", []))
	_setup_inspector_tools(plugin)
	_setup_standard_export_plugins(plugin)
	_setup_extension_export_plugin(plugin)
	_setup_enabled_extension_export_plugins(plugin)


## 移除 GF Inspector 与导出插件。
## @param plugin: 当前 EditorPlugin 实例。
func cleanup(plugin: EditorPlugin) -> void:
	if plugin == null:
		return
	_cleanup_enabled_extension_export_plugins(plugin)
	_cleanup_extension_export_plugin(plugin)
	_cleanup_standard_export_plugins(plugin)
	_cleanup_inspector_tools(plugin)


# --- 私有/辅助方法 ---

func _setup_inspector_tools(plugin: EditorPlugin) -> void:
	for record: Dictionary in _standard_inspector_records:
		_add_inspector_plugin(plugin, String(record["path"]), String(record["label"]))
	for record: Dictionary in _collect_enabled_extension_inspector_records():
		_add_inspector_plugin(plugin, String(record["path"]), String(record["label"]))


func _setup_standard_export_plugins(plugin: EditorPlugin) -> void:
	for record: Dictionary in _standard_export_records:
		var export_plugin := _load_export_plugin(String(record["path"]), String(record["label"]))
		if export_plugin == null:
			continue
		plugin.add_export_plugin(export_plugin)
		_standard_export_plugins.append(export_plugin)


func _setup_extension_export_plugin(plugin: EditorPlugin) -> void:
	var export_script := load(EXTENSION_EXPORT_PLUGIN_SCRIPT_PATH) as Script
	if export_script == null or not export_script.can_instantiate():
		push_error("[GF Framework] 扩展导出过滤插件脚本加载失败。")
		return

	_extension_export_plugin = export_script.new() as EditorExportPlugin
	if _extension_export_plugin == null:
		push_error("[GF Framework] 扩展导出过滤插件实例化失败。")
		return

	plugin.add_export_plugin(_extension_export_plugin)


func _setup_enabled_extension_export_plugins(plugin: EditorPlugin) -> void:
	for export_plugin_path: String in GFExtensionSettingsBase.get_enabled_export_plugin_paths():
		var export_plugin := _load_export_plugin(export_plugin_path, export_plugin_path)
		if export_plugin == null:
			continue
		plugin.add_export_plugin(export_plugin)
		_extension_export_plugins.append(export_plugin)


func _load_inspector_plugin(script_path: String, label: String) -> EditorInspectorPlugin:
	var inspector_script := load(script_path) as Script
	if inspector_script == null or not inspector_script.can_instantiate():
		push_error("[GF Framework] %s 插件脚本加载失败。" % label)
		return null

	var inspector_plugin := inspector_script.new() as EditorInspectorPlugin
	if inspector_plugin == null:
		push_error("[GF Framework] %s 插件实例化失败。" % label)
		return null

	return inspector_plugin


func _load_export_plugin(script_path: String, label: String) -> EditorExportPlugin:
	var export_script := load(script_path) as Script
	if export_script == null or not export_script.can_instantiate():
		push_error("[GF Framework] %s 导出插件脚本加载失败。" % label)
		return null

	var export_plugin := export_script.new() as EditorExportPlugin
	if export_plugin == null:
		push_error("[GF Framework] %s 导出插件实例化失败。" % label)
		return null

	return export_plugin


func _add_inspector_plugin(plugin: EditorPlugin, script_path: String, label: String) -> void:
	var inspector_plugin := _load_inspector_plugin(script_path, label)
	if inspector_plugin == null:
		return

	plugin.add_inspector_plugin(inspector_plugin)
	_inspector_plugins.append(inspector_plugin)


func _collect_enabled_extension_inspector_records() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var used_paths: Dictionary = {}
	for manifest: GFExtensionManifest in GFExtensionSettingsBase.get_enabled_manifests():
		for inspector_path: String in manifest.editor_inspector_paths:
			var normalized_path := inspector_path.strip_edges()
			if normalized_path.is_empty() or used_paths.has(normalized_path):
				continue

			used_paths[normalized_path] = true
			records.append({
				"path": normalized_path,
				"label": _get_extension_inspector_label(manifest, normalized_path),
			})
	return records


func _get_extension_inspector_label(manifest: GFExtensionManifest, inspector_path: String) -> String:
	var extension_name := manifest.display_name
	if extension_name.is_empty():
		extension_name = manifest.id
	var script_name := inspector_path.get_file().get_basename().to_pascal_case()
	return "%s %s" % [extension_name, script_name]


func _to_record_array(value: Variant) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	if not value is Array:
		return records
	for record_variant: Variant in value:
		if record_variant is Dictionary:
			records.append((record_variant as Dictionary).duplicate(true))
	return records


func _cleanup_inspector_tools(plugin: EditorPlugin) -> void:
	for inspector_plugin: EditorInspectorPlugin in _inspector_plugins:
		if inspector_plugin != null:
			plugin.remove_inspector_plugin(inspector_plugin)
	_inspector_plugins.clear()


func _cleanup_standard_export_plugins(plugin: EditorPlugin) -> void:
	for export_plugin: EditorExportPlugin in _standard_export_plugins:
		if export_plugin != null:
			plugin.remove_export_plugin(export_plugin)
	_standard_export_plugins.clear()


func _cleanup_extension_export_plugin(plugin: EditorPlugin) -> void:
	if _extension_export_plugin != null:
		plugin.remove_export_plugin(_extension_export_plugin)
		_extension_export_plugin = null


func _cleanup_enabled_extension_export_plugins(plugin: EditorPlugin) -> void:
	for export_plugin: EditorExportPlugin in _extension_export_plugins:
		if export_plugin != null:
			plugin.remove_export_plugin(export_plugin)
	_extension_export_plugins.clear()
