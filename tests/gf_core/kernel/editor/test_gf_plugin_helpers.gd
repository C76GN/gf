extends GutTest


# --- 常量 ---

const GF_PLUGIN_SCRIPT := preload("res://addons/gf/plugin.gd")
const GF_PLUGIN_ACTIONS := preload("res://addons/gf/kernel/editor/gf_plugin_actions.gd")
const GF_PLUGIN_AUTOLOAD := preload("res://addons/gf/kernel/editor/gf_plugin_autoload.gd")
const GF_PLUGIN_DOCK_TOOLS := preload("res://addons/gf/kernel/editor/gf_plugin_dock_tools.gd")
const GF_PLUGIN_INSPECTOR_TOOLS := preload("res://addons/gf/kernel/editor/gf_plugin_inspector_tools.gd")
const GF_PLUGIN_MENU := preload("res://addons/gf/kernel/editor/gf_plugin_menu.gd")
const GF_PLUGIN_PROJECT_SETTINGS := preload("res://addons/gf/kernel/editor/gf_plugin_project_settings.gd")
const GF_EDITOR_WORKSPACE_DOCK := preload("res://addons/gf/kernel/editor/gf_editor_workspace_dock.gd")
const GF_EXTENSION_MANAGER_DOCK := preload("res://addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd")
const GF_EXTENSION_SETTINGS_BASE := preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")
const GF_STANDARD_EDITOR_EXTENSIONS := preload("res://addons/gf/standard/editor/gf_standard_editor_extensions.gd")


# --- 测试用例 ---

func test_plugin_split_helpers_load() -> void:
	assert_not_null(GF_PLUGIN_SCRIPT, "主插件脚本应可加载。")
	assert_not_null(GF_PLUGIN_ACTIONS, "菜单动作辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_AUTOLOAD, "Autoload 辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_DOCK_TOOLS, "Dock 辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_INSPECTOR_TOOLS, "Inspector 辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_MENU, "菜单辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_PROJECT_SETTINGS, "ProjectSettings 辅助脚本应可加载。")


func test_plugin_action_menu_ids_are_unique() -> void:
	var actions: Variant = GF_PLUGIN_ACTIONS.new()
	actions._setup_menu_actions(GF_STANDARD_EDITOR_EXTENSIONS.get_template_records())
	var entries: Array = actions.get_menu_entries()
	actions._cleanup_extension_editor_actions()
	var ids: Array[int] = []
	for entry: Dictionary in entries:
		ids.append(int(entry.get("id", -1)))

	var unique_ids: Dictionary = {}
	var highest_id := -1
	for id: int in ids:
		unique_ids[id] = true
		highest_id = maxi(highest_id, id)

	assert_eq(unique_ids.size(), ids.size(), "GF 菜单动作 ID 应保持唯一。")
	assert_gt(GF_PLUGIN_ACTIONS.EXTENSION_MENU_ID_START, GF_PLUGIN_ACTIONS.TEMPLATE_MENU_ID_START, "扩展菜单动作 ID 应避开模板菜单动作 ID。")
	assert_gt(highest_id, GF_PLUGIN_ACTIONS.MENU_GENERATE_PROJECT_ACCESSORS, "动态模板或包动作应可注册到菜单。")


func test_plugin_action_system_template_uses_gf_lifecycle_section() -> void:
	var actions: Variant = GF_PLUGIN_ACTIONS.new()
	actions._setup_menu_actions([])
	var source: String = actions._get_template("System")
	actions._cleanup_extension_editor_actions()

	assert_true(source.contains("# --- GF 生命周期方法 ---"), "System 模板应使用 GF 生命周期 section。")
	assert_false(source.contains("# --- Godot 生命周期方法 ---"), "System 模板不应误用 Godot 生命周期 section。")


func test_standard_template_records_are_injected_without_kernel_hardcoding() -> void:
	var actions: Variant = GF_PLUGIN_ACTIONS.new()
	actions._setup_menu_actions(GF_STANDARD_EDITOR_EXTENSIONS.get_template_records())
	var source: String = actions._get_template("NodeState")
	actions._cleanup_extension_editor_actions()

	assert_true(source.contains("func _enter("), "NodeState 模板应由 standard 扩展记录注入。")
	assert_eq(actions._get_base_class("NodeState"), "GFNodeState", "NodeState 基类应来自模板记录。")


func test_plugin_inspector_tools_discovers_enabled_extension_inspectors() -> void:
	var restore := _set_enabled_extensions(["gf.official.capability", "gf.official.flow"])
	var tools: Variant = GF_PLUGIN_INSPECTOR_TOOLS.new()
	var records: Array = tools._collect_enabled_extension_inspector_records()
	var paths: Array[String] = []
	for record: Dictionary in records:
		paths.append(String(record.get("path", "")))

	_restore_enabled_extensions(restore)

	assert_true(
		paths.has("res://addons/gf/extensions/official/capability/editor/gf_capability_inspector_plugin.gd"),
		"Capability Inspector 应由扩展 manifest 声明。"
	)
	assert_true(
		paths.has("res://addons/gf/extensions/official/flow/editor/gf_flow_graph_inspector_plugin.gd"),
		"Flow Graph Inspector 应由扩展 manifest 声明。"
	)


func test_plugin_actions_discovers_enabled_extension_menu_entries() -> void:
	var restore := _set_enabled_extensions(["gf.official.save", "gf.official.network"])
	var actions: Variant = GF_PLUGIN_ACTIONS.new()
	actions._setup_menu_actions([])
	var entries: Array = actions.get_menu_entries()
	actions._cleanup_extension_editor_actions()
	_restore_enabled_extensions(restore)

	var labels: Array[String] = []
	for entry: Dictionary in entries:
		labels.append(String(entry.get("label", "")))

	assert_true(labels.has("校验当前场景 SaveGraph"), "SaveGraph 诊断应由 Save 扩展 manifest 注册。")
	assert_true(labels.has("生成 Network Contract 访问器"), "Network Contract 生成器应由 Network 扩展 manifest 注册。")


func test_plugin_actions_discovers_enabled_extension_templates() -> void:
	var restore := _set_enabled_extensions(["gf.official.capability"])
	var actions: Variant = GF_PLUGIN_ACTIONS.new()
	actions._setup_menu_actions([])
	var entries: Array = actions.get_menu_entries()
	var source: String = actions._get_template("NodeCapability")
	actions._cleanup_extension_editor_actions()
	_restore_enabled_extensions(restore)

	var labels: Array[String] = []
	for entry: Dictionary in entries:
		labels.append(String(entry.get("label", "")))

	assert_true(labels.has("生成 NodeCapability"), "Capability 模板应由 Capability 扩展 manifest 注册。")
	assert_true(source.contains("func get_required_capabilities()"), "Capability 模板源码应由包动作贡献。")


func test_plugin_dock_tools_keeps_core_docks_available_without_extensions() -> void:
	var restore := _set_enabled_extensions([])
	var tools: Variant = GF_PLUGIN_DOCK_TOOLS.new()
	tools.set_standard_dock_records(GF_STANDARD_EDITOR_EXTENSIONS.get_dock_records())
	var core_records: Array = tools._collect_core_dock_records()
	var extension_records: Array = tools._collect_enabled_extension_dock_records()
	_restore_enabled_extensions(restore)

	var core_paths: Array[String] = []
	for record: Dictionary in core_records:
		core_paths.append(String(record.get("path", "")))

	assert_true(
		core_paths.has("res://addons/gf/standard/utilities/storage/editor/gf_storage_viewer_dock.gd"),
		"Save Viewer 应作为 standard Dock 保持可用。"
	)
	assert_true(
		core_paths.has("res://addons/gf/standard/state_machine/node/editor/gf_node_state_machine_dock.gd"),
		"节点状态机工具应作为 standard Dock 保持可用。"
	)
	assert_true(
		core_paths.has("res://addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd"),
		"扩展管理器应作为 kernel Dock 保持可用。"
	)
	assert_true(extension_records.is_empty(), "全禁用时不应注册任何扩展级 Dock。")


func test_plugin_dock_tools_discovers_enabled_extension_docks() -> void:
	var restore := _set_enabled_extensions(["gf.official.flow"])
	var tools: Variant = GF_PLUGIN_DOCK_TOOLS.new()
	var extension_records: Array = tools._collect_enabled_extension_dock_records()
	_restore_enabled_extensions(restore)

	var paths: Array[String] = []
	for record: Dictionary in extension_records:
		paths.append(String(record.get("path", "")))

	assert_true(
		paths.has("res://addons/gf/extensions/official/flow/editor/gf_flow_graph_dock.gd"),
		"Flow 工具面板应由 Flow 扩展 manifest 注册。"
	)


func test_editor_workspace_dock_groups_gf_panels() -> void:
	var dock: Variant = GF_EDITOR_WORKSPACE_DOCK.new()
	var records: Array[Dictionary] = [
		{
			"path": "res://addons/gf/standard/utilities/storage/editor/gf_storage_viewer_dock.gd",
			"label": "GF Save Viewer",
		},
		{
			"path": "res://addons/gf/standard/utilities/debug/editor/gf_signal_graph_dock.gd",
			"label": "GF Signal Graph",
		},
		{
			"path": "res://addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd",
			"label": "GF Extensions",
		},
	]
	dock.setup(records)

	assert_eq(dock.name, "GF", "统一工作区应只占用一个 GF 底部入口。")
	assert_true(dock.clip_contents, "统一工作区应裁剪超出内容，避免覆盖 Godot 底部栏。")
	assert_eq(dock.custom_minimum_size, Vector2(0.0, 112.0), "统一工作区最小高度只应保留顶部入口区。")
	assert_eq(dock.get_page_count(), 3, "工作区应把多个 GF 面板收束为内部页面。")
	assert_eq(dock.get_page_titles(), PackedStringArray(["GF Save Viewer", "GF Signal Graph", "GF Extensions"]), "页面标题应保留原面板语义。")
	assert_eq(dock.get_page_button_titles(), PackedStringArray(["GF Save Viewer", "GF Signal Graph", "GF Extensions"]), "响应式页面入口应随页面记录自动生成。")
	assert_true(dock.get_about_text().contains("https://github.com/C76GN/gf-framework"), "关于弹窗应提供项目地址。")
	assert_true(dock.get_about_text().contains("https://gf-framework.readthedocs.io/"), "关于弹窗应提供正式文档地址。")
	assert_true(dock.get_about_text().contains("cl7o6dgyn@gmail.com"), "关于弹窗应提供联系邮箱。")
	for index: int in range(dock.get_page_count()):
		var page := dock._tabs.get_child(index) as Control
		var content := page.get_child(0) as Control
		assert_true(page.clip_contents, "每个页面容器都应裁剪内容，避免覆盖底部栏。")
		assert_eq(page.custom_minimum_size, Vector2.ZERO, "页面容器不应把内部工具最小高度传给底部面板。")
		assert_true(content.clip_contents, "被装入工作区的工具页面应裁剪自身溢出内容。")
		assert_eq(content.anchor_right, 1.0, "工具页面应横向铺满页面容器。")
		assert_eq(content.anchor_bottom, 1.0, "工具页面应纵向跟随页面容器。")

	dock._ensure_about_dialog()
	var about_scroll := dock._about_dialog.get_node("AboutContent/AboutLayout/AboutScroll") as ScrollContainer
	var about_text := dock._about_dialog.get_node("AboutContent/AboutLayout/AboutScroll/AboutText") as RichTextLabel
	var about_confirm := dock._about_dialog.get_node("AboutContent/AboutLayout/AboutConfirmCenter/AboutConfirmButton") as Button
	assert_eq(dock._about_dialog.min_size, Vector2i(620, 360), "关于弹窗应保持固定可控尺寸。")
	assert_eq(about_scroll.custom_minimum_size.y, 236.0, "关于正文区域应限制高度，避免长链接撑高弹窗。")
	assert_not_null(about_text, "关于弹窗应使用可点击链接文本。")
	assert_false(about_text.fit_content, "关于正文不应使用 fit_content，避免参与过长最小高度计算。")
	assert_true(about_text.text.contains("[url=https://github.com/C76GN/gf-framework]"), "项目地址应作为正文链接呈现。")
	assert_true(about_text.text.contains("[url=https://gf-framework.readthedocs.io/]"), "文档地址应作为正文链接呈现。")
	assert_true(about_text.text.contains("WeChat：C76_GN"), "关于弹窗应展示微信联系方式。")
	assert_true(about_text.text.contains("QQ：403150493"), "关于弹窗应展示 QQ 联系方式。")
	assert_false(dock._about_dialog.get_ok_button().visible, "默认底部确认按钮应隐藏，避免按钮停在右下角。")
	assert_eq(about_confirm.text, "确定", "自定义确认按钮应使用中文确定。")
	assert_true(about_confirm.get_parent() is CenterContainer, "自定义确认按钮应放在居中容器中。")

	dock.free()


func test_extension_manager_dock_exposes_strict_reference_export_policy() -> void:
	var restore := _set_project_setting(
		GF_EXTENSION_SETTINGS_BASE.EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING,
		true
	)
	var dock: Variant = GF_EXTENSION_MANAGER_DOCK.new()
	dock._refresh_extensions()

	assert_not_null(dock._export_fail_check, "扩展管理面板应暴露禁用扩展引用的严格导出策略。")
	assert_eq(dock._export_fail_check.text, "引用禁用扩展时阻止导出", "严格导出策略应有清晰的 UI 文案。")
	assert_true(dock._export_fail_check.button_pressed, "扩展管理面板应读取当前严格导出策略。")

	dock.free()
	_restore_project_setting(
		GF_EXTENSION_SETTINGS_BASE.EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING,
		restore
	)


# --- 私有/辅助方法 ---

func _set_enabled_extensions(extension_ids: Array[String]) -> Dictionary:
	var setting_name: String = GF_EXTENSION_SETTINGS_BASE.ENABLED_EXTENSIONS_SETTING
	var restore := {
		"had_setting": ProjectSettings.has_setting(setting_name),
		"value": ProjectSettings.get_setting(setting_name, []),
	}
	ProjectSettings.set_setting(setting_name, extension_ids)
	return restore


func _restore_enabled_extensions(restore: Dictionary) -> void:
	var setting_name: String = GF_EXTENSION_SETTINGS_BASE.ENABLED_EXTENSIONS_SETTING
	if bool(restore.get("had_setting", false)):
		ProjectSettings.set_setting(setting_name, restore.get("value", []))
	else:
		ProjectSettings.clear(setting_name)


func _set_project_setting(setting_name: String, value: Variant) -> Dictionary:
	var restore := {
		"had_setting": ProjectSettings.has_setting(setting_name),
		"value": ProjectSettings.get_setting(setting_name, null),
	}
	ProjectSettings.set_setting(setting_name, value)
	return restore


func _restore_project_setting(setting_name: String, restore: Dictionary) -> void:
	if bool(restore.get("had_setting", false)):
		ProjectSettings.set_setting(setting_name, restore.get("value", null))
	else:
		ProjectSettings.clear(setting_name)
