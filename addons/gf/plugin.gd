@tool
extends EditorPlugin


# GF Framework 编辑器插件。
# 在启用/禁用插件时自动注册/注销 Gf AutoLoad 单例，并装配 GF 编辑器工具。

# --- 常量 ---

## AutoLoad 管理辅助脚本。
## [br]
## @api framework_internal
## [br]
## @layer plugin
const GFPluginAutoload = preload("res://addons/gf/kernel/editor/gf_plugin_autoload.gd")

## ProjectSettings 注册辅助脚本。
## [br]
## @api framework_internal
## [br]
## @layer plugin
const GFPluginProjectSettings = preload("res://addons/gf/kernel/editor/gf_plugin_project_settings.gd")

## Inspector 与导出插件管理辅助脚本。
## [br]
## @api framework_internal
## [br]
## @layer plugin
const GFPluginInspectorTools = preload("res://addons/gf/kernel/editor/gf_plugin_inspector_tools.gd")

## 菜单动作管理辅助脚本。
## [br]
## @api framework_internal
## [br]
## @layer plugin
const GFPluginActions = preload("res://addons/gf/kernel/editor/gf_plugin_actions.gd")

## 工具菜单管理辅助脚本。
## [br]
## @api framework_internal
## [br]
## @layer plugin
const GFPluginMenu = preload("res://addons/gf/kernel/editor/gf_plugin_menu.gd")

## 工作区窗口管理辅助脚本。
## [br]
## @api framework_internal
## [br]
## @layer plugin
const GFPluginDockTools = preload("res://addons/gf/kernel/editor/gf_plugin_dock_tools.gd")

## 导入插件管理辅助脚本。
## [br]
## @api framework_internal
## [br]
## @layer plugin
const GFPluginImportTools = preload("res://addons/gf/kernel/editor/gf_plugin_import_tools.gd")

## glTF 文档扩展管理辅助脚本。
## [br]
## @api framework_internal
## [br]
## @layer plugin
const GFPluginGltfDocumentTools = preload("res://addons/gf/kernel/editor/gf_plugin_gltf_document_tools.gd")

## 标准库编辑器扩展记录脚本。
## [br]
## @api framework_internal
## [br]
## @layer plugin
const GFStandardEditorExtensions = preload("res://addons/gf/standard/editor/gf_standard_editor_extensions.gd")


# --- 私有变量 ---

var _inspector_tools: GFPluginInspectorTools
var _actions: GFPluginActions
var _menu: GFPluginMenu
var _dock_tools: GFPluginDockTools
var _import_tools: GFPluginImportTools
var _gltf_document_tools: GFPluginGltfDocumentTools
var _plugin_active: bool = false
var _standard_editor_extension_records: Dictionary = {}


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	_plugin_active = true
	GFPluginAutoload.ensure(self)
	GFPluginProjectSettings.ensure_all()
	_standard_editor_extension_records = _collect_standard_editor_extension_records()

	_inspector_tools = GFPluginInspectorTools.new()
	_inspector_tools.setup(self, _standard_editor_extension_records)

	_actions = GFPluginActions.new()
	_actions.setup(GFVariantData.get_option_array(_standard_editor_extension_records, "template_records"))
	var _workspace_requested_connected: int = Signal(_actions, &"workspace_requested").connect(_on_workspace_requested)

	_menu = GFPluginMenu.new()
	_menu.setup(self, Callable(_actions, "handle_menu_id"), _actions.get_menu_entries())

	_dock_tools = GFPluginDockTools.new()
	_import_tools = GFPluginImportTools.new()
	_import_tools.setup(self)

	_gltf_document_tools = GFPluginGltfDocumentTools.new()
	_gltf_document_tools.setup()
	call_deferred("_setup_dock_tools")


func _exit_tree() -> void:
	_plugin_active = false
	GFPluginAutoload.remove(self)

	if _dock_tools != null:
		_dock_tools.cleanup(self)
		_dock_tools = null
	if _import_tools != null:
		_import_tools.cleanup(self)
		_import_tools = null
	if _gltf_document_tools != null:
		_gltf_document_tools.cleanup()
		_gltf_document_tools = null
	if _menu != null:
		_menu.cleanup(self)
		_menu = null
	if _actions != null:
		_actions.cleanup()
		_actions = null
	if _inspector_tools != null:
		_inspector_tools.cleanup(self)
		_inspector_tools = null


# --- 私有/辅助方法 ---

func _setup_dock_tools() -> void:
	if not _plugin_active or _dock_tools == null:
		return

	var dock_records: Array[Dictionary] = []
	dock_records.assign(GFVariantData.get_option_array(_standard_editor_extension_records, "dock_records"))
	_dock_tools.setup(self, dock_records)
	call_deferred("_open_workspace_on_startup")


func _collect_standard_editor_extension_records() -> Dictionary:
	return {
		"inspector_plugin_records": GFStandardEditorExtensions.get_inspector_plugin_records(),
		"export_plugin_records": GFStandardEditorExtensions.get_export_plugin_records(),
		"dock_records": GFStandardEditorExtensions.get_dock_records(),
		"template_records": GFStandardEditorExtensions.get_template_records(),
	}


func _open_workspace_on_startup() -> void:
	if _plugin_active and _dock_tools != null:
		_dock_tools.show_workspace()


# --- 信号处理函数 ---

func _on_workspace_requested() -> void:
	if _dock_tools != null:
		_dock_tools.show_workspace()
