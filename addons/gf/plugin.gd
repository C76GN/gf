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


# --- 私有变量 ---

var _inspector_tools: RefCounted
var _actions: RefCounted
var _menu: RefCounted
var _dock_tools: RefCounted
var _plugin_active: bool = false


# --- Godot 生命周期方法 ---

func _enter_tree() -> void:
	_plugin_active = true
	GFPluginAutoload.ensure(self)
	GFPluginProjectSettings.ensure_all()

	_inspector_tools = GFPluginInspectorTools.new()
	_inspector_tools.setup(self)

	_actions = GFPluginActions.new()
	_actions.setup()

	_menu = GFPluginMenu.new()
	_menu.setup(self, Callable(_actions, "handle_menu_id"), _actions.get_package_menu_entries())

	_dock_tools = GFPluginDockTools.new()
	call_deferred("_setup_dock_tools")


func _exit_tree() -> void:
	_plugin_active = false
	GFPluginAutoload.remove(self)

	if _dock_tools != null:
		_dock_tools.cleanup(self)
		_dock_tools = null
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

	_dock_tools.setup(self)
