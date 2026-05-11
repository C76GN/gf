extends GutTest


# --- 常量 ---

const GF_PLUGIN_SCRIPT := preload("res://addons/gf/plugin.gd")
const GF_PLUGIN_ACTIONS := preload("res://addons/gf/editor/gf_plugin_actions.gd")
const GF_PLUGIN_AUTOLOAD := preload("res://addons/gf/editor/gf_plugin_autoload.gd")
const GF_PLUGIN_INSPECTOR_TOOLS := preload("res://addons/gf/editor/gf_plugin_inspector_tools.gd")
const GF_PLUGIN_MENU := preload("res://addons/gf/editor/gf_plugin_menu.gd")
const GF_PLUGIN_PROJECT_SETTINGS := preload("res://addons/gf/editor/gf_plugin_project_settings.gd")


# --- 测试用例 ---

func test_plugin_split_helpers_load() -> void:
	assert_not_null(GF_PLUGIN_SCRIPT, "主插件脚本应可加载。")
	assert_not_null(GF_PLUGIN_ACTIONS, "菜单动作辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_AUTOLOAD, "Autoload 辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_INSPECTOR_TOOLS, "Inspector 辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_MENU, "菜单辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_PROJECT_SETTINGS, "ProjectSettings 辅助脚本应可加载。")


func test_plugin_action_menu_ids_are_unique() -> void:
	var ids := [
		GF_PLUGIN_ACTIONS.MENU_GENERATE_SYSTEM,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_MODEL,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_UTILITY,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_COMMAND,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_CAPABILITY,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_NODE_CAPABILITY,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_NODE_2D_CAPABILITY,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_NODE_3D_CAPABILITY,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_CONTROL_CAPABILITY,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_NODE_STATE,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_NODE_STATE_MACHINE,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_ACCESSORS,
		GF_PLUGIN_ACTIONS.MENU_GENERATE_PROJECT_ACCESSORS,
		GF_PLUGIN_ACTIONS.MENU_VALIDATE_SAVE_GRAPH,
	]
	var unique_ids: Dictionary = {}
	for id: int in ids:
		unique_ids[id] = true

	assert_eq(unique_ids.size(), ids.size(), "GF 菜单动作 ID 应保持唯一。")


func test_plugin_action_system_template_uses_gf_lifecycle_section() -> void:
	var actions: Variant = GF_PLUGIN_ACTIONS.new()
	var source: String = actions._get_template("System")

	assert_true(source.contains("# --- GF 生命周期方法 ---"), "System 模板应使用 GF 生命周期 section。")
	assert_false(source.contains("# --- Godot 生命周期方法 ---"), "System 模板不应误用 Godot 生命周期 section。")
