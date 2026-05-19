@tool
extends EditorPlugin


## GF Framework 编辑器插件。
## 在启用/禁用插件时自动注册/注销 Gf AutoLoad 单例，并装配 GF 编辑器工具。

# --- 常量 ---

const GFPluginAutoload = preload("res://addons/gf/kernel/editor/gf_plugin_autoload.gd")
const GFPluginProjectSettings = preload("res://addons/gf/kernel/editor/gf_plugin_project_settings.gd")
const GFPluginInspectorTools = preload("res://addons/gf/kernel/editor/gf_plugin_inspector_tools.gd")
const GFPluginActions = preload("res://addons/gf/kernel/editor/gf_plugin_actions.gd")
const GFPluginMenu = preload("res://addons/gf/kernel/editor/gf_plugin_menu.gd")
const GFPluginDockTools = preload("res://addons/gf/kernel/editor/gf_plugin_dock_tools.gd")
const GFPluginImportTools = preload("res://addons/gf/kernel/editor/gf_plugin_import_tools.gd")
const GFPluginGltfDocumentTools = preload("res://addons/gf/kernel/editor/gf_plugin_gltf_document_tools.gd")
const GFStandardEditorExtensions = preload("res://addons/gf/standard/editor/gf_standard_editor_extensions.gd")


# --- 私有变量 ---

var _inspector_tools: RefCounted
var _actions: RefCounted
var _menu: RefCounted
var _dock_tools: RefCounted
var _import_tools: RefCounted
var _gltf_document_tools: RefCounted
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
	_actions.setup(_standard_editor_extension_records.get("template_records", []))
	_actions.workspace_requested.connect(_on_workspace_requested)

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

	_dock_tools.setup(self, _standard_editor_extension_records.get("dock_records", []) as Array[Dictionary])
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
