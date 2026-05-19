@tool

## GF 插件导入插件管理辅助。
extends RefCounted


# --- 常量 ---

const GFExtensionSettingsBase = preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")


# --- 私有变量 ---

var _import_plugins: Array[EditorImportPlugin] = []


# --- 公共方法 ---

## 注册当前启用扩展声明的 EditorImportPlugin。
## @param plugin: 当前 EditorPlugin 实例。
func setup(plugin: EditorPlugin) -> void:
	if plugin == null:
		return

	for import_plugin_path: String in GFExtensionSettingsBase.get_enabled_import_plugin_paths():
		_add_import_plugin(plugin, import_plugin_path)


## 注销已注册的 EditorImportPlugin。
## @param plugin: 当前 EditorPlugin 实例。
func cleanup(plugin: EditorPlugin) -> void:
	if plugin == null:
		return

	for import_plugin: EditorImportPlugin in _import_plugins:
		if import_plugin != null:
			plugin.remove_import_plugin(import_plugin)
	_import_plugins.clear()


# --- 私有/辅助方法 ---

func _add_import_plugin(plugin: EditorPlugin, script_path: String) -> void:
	var import_plugin := _load_import_plugin(script_path)
	if import_plugin == null:
		return

	plugin.add_import_plugin(import_plugin)
	_import_plugins.append(import_plugin)


func _load_import_plugin(script_path: String) -> EditorImportPlugin:
	var import_script := load(script_path) as Script
	if import_script == null or not import_script.can_instantiate():
		push_error("[GF Framework] 导入插件脚本加载失败：%s" % script_path)
		return null

	var import_plugin := import_script.new() as EditorImportPlugin
	if import_plugin == null:
		push_error("[GF Framework] 导入插件实例化失败：%s" % script_path)
		return null

	return import_plugin
