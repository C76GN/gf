@tool

## GF 插件工具菜单管理辅助。
extends RefCounted


# --- 常量 ---

const GFPluginActions = preload("res://addons/gf/editor/gf_plugin_actions.gd")


# --- 私有变量 ---

var _menu: PopupMenu


# --- 公共方法 ---

## 创建并注册 GF 工具菜单。
## @param plugin: 当前 EditorPlugin 实例。
## @param handler: 处理菜单 ID 的回调。
func setup(plugin: EditorPlugin, handler: Callable) -> void:
	if plugin == null:
		return
	_menu = PopupMenu.new()
	_menu.id_pressed.connect(handler)
	_populate_menu()
	plugin.add_tool_submenu_item("GF", _menu)


## 移除并释放 GF 工具菜单。
## @param plugin: 当前 EditorPlugin 实例。
func cleanup(plugin: EditorPlugin) -> void:
	if plugin != null:
		plugin.remove_tool_menu_item("GF")
	if is_instance_valid(_menu):
		_menu.queue_free()
	_menu = null


# --- 私有/辅助方法 ---

func _populate_menu() -> void:
	_menu.add_separator("核心模块")
	_menu.add_item("生成 System", GFPluginActions.MENU_GENERATE_SYSTEM)
	_menu.add_item("生成 Model", GFPluginActions.MENU_GENERATE_MODEL)
	_menu.add_item("生成 Utility", GFPluginActions.MENU_GENERATE_UTILITY)
	_menu.add_item("生成 Command", GFPluginActions.MENU_GENERATE_COMMAND)

	_menu.add_separator("扩展模板")
	_menu.add_item("生成 Capability", GFPluginActions.MENU_GENERATE_CAPABILITY)
	_menu.add_item("生成 NodeCapability", GFPluginActions.MENU_GENERATE_NODE_CAPABILITY)
	_menu.add_item("生成 Node2DCapability", GFPluginActions.MENU_GENERATE_NODE_2D_CAPABILITY)
	_menu.add_item("生成 Node3DCapability", GFPluginActions.MENU_GENERATE_NODE_3D_CAPABILITY)
	_menu.add_item("生成 ControlCapability", GFPluginActions.MENU_GENERATE_CONTROL_CAPABILITY)
	_menu.add_item("生成 NodeState", GFPluginActions.MENU_GENERATE_NODE_STATE)
	_menu.add_item("生成 NodeStateMachine", GFPluginActions.MENU_GENERATE_NODE_STATE_MACHINE)

	_menu.add_separator("代码生成")
	_menu.add_item("生成强类型访问器", GFPluginActions.MENU_GENERATE_ACCESSORS)
	_menu.add_item("生成项目常量访问器", GFPluginActions.MENU_GENERATE_PROJECT_ACCESSORS)

	_menu.add_separator("诊断")
	_menu.add_item("校验当前场景 SaveGraph", GFPluginActions.MENU_VALIDATE_SAVE_GRAPH)
