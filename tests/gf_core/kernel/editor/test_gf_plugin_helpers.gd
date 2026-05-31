extends GutTest


# --- 常量 ---

const GF_PLUGIN_SCRIPT = preload("res://addons/gf/plugin.gd")
const GF_PLUGIN_ACTIONS = preload("res://addons/gf/kernel/editor/gf_plugin_actions.gd")
const GF_PLUGIN_AUTOLOAD = preload("res://addons/gf/kernel/editor/gf_plugin_autoload.gd")
const GF_PLUGIN_DOCK_TOOLS = preload("res://addons/gf/kernel/editor/gf_plugin_dock_tools.gd")
const GF_PLUGIN_INSPECTOR_TOOLS = preload("res://addons/gf/kernel/editor/gf_plugin_inspector_tools.gd")
const GF_PLUGIN_IMPORT_TOOLS = preload("res://addons/gf/kernel/editor/gf_plugin_import_tools.gd")
const GF_PLUGIN_MENU = preload("res://addons/gf/kernel/editor/gf_plugin_menu.gd")
const GF_PLUGIN_PROJECT_SETTINGS = preload("res://addons/gf/kernel/editor/gf_plugin_project_settings.gd")
const GF_EDITOR_WORKSPACE_DOCK = preload("res://addons/gf/kernel/editor/gf_editor_workspace_dock.gd")
const GF_EDITOR_WORKSPACE_UI = preload("res://addons/gf/kernel/editor/gf_editor_workspace_ui.gd")
const GF_EDITOR_WORKSPACE_WINDOW = preload("res://addons/gf/kernel/editor/gf_editor_workspace_window.gd")
const GF_EXTENSION_MANAGER_DOCK = preload("res://addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd")
const GF_EXTENSION_SETTINGS_BASE = preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")
const GF_STANDARD_EDITOR_EXTENSIONS = preload("res://addons/gf/standard/editor/gf_standard_editor_extensions.gd")
const GF_VARIANT_ACCESS = preload("res://addons/gf/kernel/core/gf_variant_access.gd")


# --- 测试用例 ---

func test_plugin_split_helpers_load() -> void:
	assert_not_null(GF_PLUGIN_SCRIPT, "主插件脚本应可加载。")
	assert_not_null(GF_PLUGIN_ACTIONS, "菜单动作辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_AUTOLOAD, "Autoload 辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_DOCK_TOOLS, "Dock 辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_INSPECTOR_TOOLS, "Inspector 辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_IMPORT_TOOLS, "导入插件辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_MENU, "菜单辅助脚本应可加载。")
	assert_not_null(GF_PLUGIN_PROJECT_SETTINGS, "ProjectSettings 辅助脚本应可加载。")
	assert_not_null(GF_EDITOR_WORKSPACE_UI, "工作区页面 UI 辅助脚本应可加载。")
	assert_not_null(GF_EDITOR_WORKSPACE_WINDOW, "独立工作区窗口脚本应可加载。")


func test_editor_workspace_ui_builds_common_page_chrome() -> void:
	var page: VBoxContainer = VBoxContainer.new()
	GF_EDITOR_WORKSPACE_UI.apply_page_root(page)

	var toolbar: HBoxContainer = GF_EDITOR_WORKSPACE_UI.make_toolbar()
	var state: WorkspaceButtonState = WorkspaceButtonState.new()
	var button: Button = GF_EDITOR_WORKSPACE_UI.make_button("刷新", "重新加载。", _mark_workspace_ui_button_pressed.bind(state))
	var summary: Label = GF_EDITOR_WORKSPACE_UI.make_summary_label("准备就绪")
	var empty: Label = GF_EDITOR_WORKSPACE_UI.make_empty_label("暂无内容")
	var details: TextEdit = GF_EDITOR_WORKSPACE_UI.make_details_output(96.0)

	button.pressed.emit()
	GF_EDITOR_WORKSPACE_UI.set_status(summary, "完成", GF_EDITOR_WORKSPACE_UI.OK_TEXT_COLOR)

	assert_true(page.clip_contents, "工作区页面根控件应裁剪自身内容。")
	assert_eq(page.size_flags_horizontal, Control.SIZE_EXPAND_FILL, "工作区页面根控件应横向填充。")
	assert_eq(page.size_flags_vertical, Control.SIZE_EXPAND_FILL, "工作区页面根控件应纵向填充。")
	assert_eq(toolbar.size_flags_horizontal, Control.SIZE_EXPAND_FILL, "通用工具栏应横向填充。")
	assert_eq(toolbar.get_theme_constant("separation"), GF_EDITOR_WORKSPACE_UI.TOOLBAR_SEPARATION, "通用工具栏应使用统一间距。")
	assert_eq(state.count, 1, "通用按钮应连接按下回调。")
	assert_eq(summary.text, "完成", "通用状态写入应更新文本。")
	assert_eq(summary.modulate, GF_EDITOR_WORKSPACE_UI.OK_TEXT_COLOR, "通用状态写入应更新颜色。")
	assert_eq(empty.modulate, GF_EDITOR_WORKSPACE_UI.EMPTY_TEXT_COLOR, "空状态应使用统一弱提示颜色。")
	assert_false(details.editable, "详情输出框应只读。")
	assert_eq(details.custom_minimum_size.y, 96.0, "详情输出框应接受页面自定义高度。")
	assert_eq(GF_EDITOR_WORKSPACE_UI.get_report_color({"error_count": 1}), GF_EDITOR_WORKSPACE_UI.ERROR_TEXT_COLOR, "错误报告应映射错误色。")
	assert_eq(GF_EDITOR_WORKSPACE_UI.get_report_color({"warning_count": 1}), GF_EDITOR_WORKSPACE_UI.WARNING_TEXT_COLOR, "警告报告应映射警告色。")
	assert_eq(GF_EDITOR_WORKSPACE_UI.get_report_color({}), GF_EDITOR_WORKSPACE_UI.OK_TEXT_COLOR, "无问题报告应映射成功色。")

	page.free()
	toolbar.free()
	button.free()
	summary.free()
	empty.free()
	details.free()


func test_plugin_action_menu_ids_are_unique() -> void:
	var actions: Object = _new_object(GF_PLUGIN_ACTIONS)
	_call_void(actions, &"_setup_menu_actions", [GF_STANDARD_EDITOR_EXTENSIONS.get_template_records()])
	var entries: Array = _call_array(actions, &"get_menu_entries")
	_call_void(actions, &"_cleanup_extension_editor_actions")
	var ids: Array[int] = []
	for entry: Dictionary in entries:
		ids.append(GF_VARIANT_ACCESS.get_option_int(entry, "id", -1))

	var unique_ids: Dictionary = {}
	var highest_id: int = -1
	for id: int in ids:
		unique_ids[id] = true
		highest_id = maxi(highest_id, id)

	assert_eq(unique_ids.size(), ids.size(), "GF 菜单动作 ID 应保持唯一。")
	assert_gt(GF_PLUGIN_ACTIONS.EXTENSION_MENU_ID_START, GF_PLUGIN_ACTIONS.TEMPLATE_MENU_ID_START, "扩展菜单动作 ID 应避开模板菜单动作 ID。")
	assert_gt(highest_id, GF_PLUGIN_ACTIONS.MENU_GENERATE_PROJECT_ACCESSORS, "动态模板或包动作应可注册到菜单。")


func test_plugin_actions_setup_replaces_previous_file_dialog_immediately() -> void:
	var actions: Object = _new_object(GF_PLUGIN_ACTIONS)
	var old_dialog: FileDialog = FileDialog.new()
	add_child(old_dialog)
	actions.set(&"_file_dialog", old_dialog)

	_call_void(actions, &"setup", [[]])
	var current_dialog: FileDialog = _as_file_dialog(actions.get(&"_file_dialog"))

	assert_not_null(current_dialog, "setup 应创建新的文件对话框。")
	assert_ne(current_dialog, old_dialog, "重复 setup 应替换旧文件对话框。")
	assert_null(old_dialog.get_parent(), "重复 setup 应立即让旧文件对话框脱离父节点。")

	_call_void(actions, &"cleanup")
	assert_null(current_dialog.get_parent(), "cleanup 应立即让当前文件对话框脱离父节点。")

	await get_tree().process_frame
	assert_false(is_instance_valid(old_dialog), "旧文件对话框应在下一帧释放。")
	assert_false(is_instance_valid(current_dialog), "当前文件对话框应在下一帧释放。")


func test_plugin_action_system_template_uses_gf_lifecycle_section() -> void:
	var actions: Object = _new_object(GF_PLUGIN_ACTIONS)
	_call_void(actions, &"_setup_menu_actions", [[]])
	var source: String = _call_text(actions, &"_get_template", ["System"])
	_call_void(actions, &"_cleanup_extension_editor_actions")

	assert_true(source.contains("# --- GF 生命周期方法 ---"), "System 模板应使用 GF 生命周期 section。")
	assert_false(source.contains("# --- Godot 生命周期方法 ---"), "System 模板不应误用 Godot 生命周期 section。")


func test_plugin_action_open_workspace_emits_signal() -> void:
	var actions: Object = _new_object(GF_PLUGIN_ACTIONS)
	_call_void(actions, &"_setup_menu_actions", [[]])
	watch_signals(actions)

	_call_void(actions, &"handle_menu_id", [GF_PLUGIN_ACTIONS.MENU_OPEN_WORKSPACE])

	assert_signal_emitted(actions, "workspace_requested", "GF 工具菜单应能请求打开独立工作区。")
	_call_void(actions, &"_cleanup_extension_editor_actions")


func test_standard_template_records_are_injected_without_kernel_hardcoding() -> void:
	var actions: Object = _new_object(GF_PLUGIN_ACTIONS)
	_call_void(actions, &"_setup_menu_actions", [GF_STANDARD_EDITOR_EXTENSIONS.get_template_records()])
	var source: String = _call_text(actions, &"_get_template", ["NodeState"])
	_call_void(actions, &"_cleanup_extension_editor_actions")

	assert_true(source.contains("func _enter("), "NodeState 模板应由 standard 扩展记录注入。")
	assert_eq(_call_text(actions, &"_get_base_class", ["NodeState"]), "GFNodeState", "NodeState 基类应来自模板记录。")


func test_plugin_inspector_tools_discovers_enabled_extension_inspectors() -> void:
	var restore: Dictionary = _set_enabled_extensions(["gf.capability", "gf.flow"])
	var tools: Object = _new_object(GF_PLUGIN_INSPECTOR_TOOLS)
	var records: Array = _call_array(tools, &"_collect_enabled_extension_inspector_records")
	var paths: Array[String] = []
	for record: Dictionary in records:
		paths.append(GF_VARIANT_ACCESS.get_option_string(record, "path"))

	_restore_enabled_extensions(restore)

	assert_true(
		paths.has("res://addons/gf/extensions/capability/editor/gf_capability_inspector_plugin.gd"),
		"Capability Inspector 应由扩展 manifest 声明。"
	)
	assert_true(
		paths.has("res://addons/gf/extensions/flow/editor/gf_flow_graph_inspector_plugin.gd"),
		"Flow Graph Inspector 应由扩展 manifest 声明。"
	)


func test_plugin_import_tools_ignores_null_plugin() -> void:
	var tools: Object = _new_object(GF_PLUGIN_IMPORT_TOOLS)

	_call_void(tools, &"setup", [null])
	_call_void(tools, &"cleanup", [null])

	var import_plugins: Array = GF_VARIANT_ACCESS.as_array(tools.get(&"_import_plugins"))
	assert_true(import_plugins.is_empty(), "无 EditorPlugin 实例时导入插件辅助脚本不应注册任何对象。")


func test_plugin_actions_discovers_enabled_extension_menu_entries() -> void:
	var restore: Dictionary = _set_enabled_extensions(["gf.save", "gf.network"])
	var actions: Object = _new_object(GF_PLUGIN_ACTIONS)
	_call_void(actions, &"_setup_menu_actions", [[]])
	var entries: Array = _call_array(actions, &"get_menu_entries")
	_call_void(actions, &"_cleanup_extension_editor_actions")
	_restore_enabled_extensions(restore)

	var labels: Array[String] = []
	for entry: Dictionary in entries:
		labels.append(GF_VARIANT_ACCESS.get_option_string(entry, "label"))

	assert_true(labels.has("校验当前场景 SaveGraph"), "SaveGraph 诊断应由 Save 扩展 manifest 注册。")
	assert_true(labels.has("生成 Network Contract 访问器"), "Network Contract 生成器应由 Network 扩展 manifest 注册。")


func test_plugin_actions_discovers_enabled_extension_templates() -> void:
	var restore: Dictionary = _set_enabled_extensions(["gf.capability"])
	var actions: Object = _new_object(GF_PLUGIN_ACTIONS)
	_call_void(actions, &"_setup_menu_actions", [[]])
	var entries: Array = _call_array(actions, &"get_menu_entries")
	var source: String = _call_text(actions, &"_get_template", ["NodeCapability"])
	_call_void(actions, &"_cleanup_extension_editor_actions")
	_restore_enabled_extensions(restore)

	var labels: Array[String] = []
	for entry: Dictionary in entries:
		labels.append(GF_VARIANT_ACCESS.get_option_string(entry, "label"))

	assert_true(labels.has("生成 NodeCapability"), "Capability 模板应由 Capability 扩展 manifest 注册。")
	assert_true(source.contains("func get_dependency_removal_policy()"), "Capability 模板源码应由包动作贡献。")


func test_plugin_dock_tools_keeps_core_docks_available_without_extensions() -> void:
	var restore: Dictionary = _set_enabled_extensions([])
	var tools: Object = _new_object(GF_PLUGIN_DOCK_TOOLS)
	_call_void(tools, &"set_standard_dock_records", [GF_STANDARD_EDITOR_EXTENSIONS.get_dock_records()])
	var core_records: Array = _call_array(tools, &"_collect_core_dock_records")
	var extension_records: Array = _call_array(tools, &"_collect_enabled_extension_dock_records")
	_restore_enabled_extensions(restore)

	var core_paths: Array[String] = []
	for record: Dictionary in core_records:
		core_paths.append(GF_VARIANT_ACCESS.get_option_string(record, "path"))

	assert_true(
		core_paths.has("res://addons/gf/standard/utilities/storage/editor/gf_storage_viewer_dock.gd"),
		"Storage Viewer 应作为 standard Dock 保持可用。"
	)
	assert_true(
		core_paths.has("res://addons/gf/standard/input/editor/gf_input_mapping_dock.gd"),
		"输入映射工作区页面应作为 standard Dock 保持可用。"
	)
	assert_true(
		core_paths.has("res://addons/gf/standard/state_machine/node/editor/gf_node_state_machine_dock.gd"),
		"节点状态机工具应作为 standard Dock 保持可用。"
	)
	assert_true(
		core_paths.has("res://addons/gf/standard/utilities/debug/editor/gf_diagnostics_dock.gd"),
		"诊断工作区页面应作为 standard Dock 保持可用。"
	)
	assert_true(
		core_paths.has("res://addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd"),
		"扩展管理器应作为 kernel Dock 保持可用。"
	)
	assert_true(extension_records.is_empty(), "全禁用时不应注册任何扩展级 Dock。")


func test_plugin_dock_tools_discovers_enabled_extension_docks() -> void:
	var restore: Dictionary = _set_enabled_extensions(["gf.flow"])
	var tools: Object = _new_object(GF_PLUGIN_DOCK_TOOLS)
	var extension_records: Array = _call_array(tools, &"_collect_enabled_extension_dock_records")
	_restore_enabled_extensions(restore)

	var paths: Array[String] = []
	for record: Dictionary in extension_records:
		paths.append(GF_VARIANT_ACCESS.get_option_string(record, "path"))

	assert_true(
		paths.has("res://addons/gf/extensions/flow/editor/gf_flow_graph_dock.gd"),
		"Flow 工具面板应由 Flow 扩展 manifest 注册。"
	)
	var flow_record: Dictionary = _dictionary_at(extension_records, 0)
	assert_eq(GF_VARIANT_ACCESS.get_option_string(flow_record, "label"), "GF Flow", "扩展页面记录应使用简洁扩展名作为 fallback。")
	assert_eq(GF_VARIANT_ACCESS.get_option_string(flow_record, "short_label"), "流程", "扩展页面应提供短标签。")
	assert_eq(GF_VARIANT_ACCESS.get_option_int(flow_record, "order"), 40, "扩展页面应读取 manifest 中的工作区排序。")


func test_plugin_dock_tools_discovers_save_extension_workspace_page() -> void:
	var restore: Dictionary = _set_enabled_extensions(["gf.save"])
	var tools: Object = _new_object(GF_PLUGIN_DOCK_TOOLS)
	var extension_records: Array = _call_array(tools, &"_collect_enabled_extension_dock_records")
	_restore_enabled_extensions(restore)

	var paths: Array[String] = []
	for record: Dictionary in extension_records:
		paths.append(GF_VARIANT_ACCESS.get_option_string(record, "path"))

	assert_true(
		paths.has("res://addons/gf/extensions/save/editor/gf_save_graph_dock.gd"),
		"SaveGraph 工作区页面应由 Save 扩展 manifest 注册。"
	)
	var save_record: Dictionary = _dictionary_at(extension_records, 0)
	assert_eq(GF_VARIANT_ACCESS.get_option_string(save_record, "label"), "GF Save", "Save 扩展页面应使用扩展名作为页面标题。")
	assert_eq(GF_VARIANT_ACCESS.get_option_string(save_record, "short_label"), "保存", "Save 扩展页面应提供短标签。")
	assert_eq(GF_VARIANT_ACCESS.get_option_int(save_record, "order"), 30, "Save 扩展页面应读取 manifest 中的工作区排序。")


func test_plugin_dock_tools_sorts_workspace_records_by_order() -> void:
	var tools: Object = _new_object(GF_PLUGIN_DOCK_TOOLS)
	var records: Array[Dictionary] = [
		{"path": "res://z.gd", "label": "Z", "order": 30},
		{"path": "res://b.gd", "label": "B", "order": 10},
		{"path": "res://a.gd", "label": "A", "order": 10},
	]

	records.sort_custom(Callable(tools, "_sort_dock_records"))

	var labels: Array[String] = []
	for record: Dictionary in records:
		labels.append(GF_VARIANT_ACCESS.get_option_string(record, "label"))
	assert_eq(labels, ["A", "B", "Z"], "工作区页面应先按 order，再按标题稳定排序。")


func test_editor_workspace_dock_groups_gf_panels() -> void:
	var dock: Control = _new_control(GF_EDITOR_WORKSPACE_DOCK)
	var records: Array[Dictionary] = [
		{
			"path": "res://addons/gf/standard/utilities/storage/editor/gf_storage_viewer_dock.gd",
			"label": "GF Storage Viewer",
		},
		{
			"path": "res://addons/gf/standard/input/editor/gf_input_mapping_dock.gd",
			"label": "GF Input Mapping",
		},
		{
			"path": "res://addons/gf/standard/utilities/debug/editor/gf_signal_graph_dock.gd",
			"label": "GF Signal Diagnostics",
		},
		{
			"path": "res://addons/gf/standard/utilities/debug/editor/gf_diagnostics_dock.gd",
			"label": "GF Diagnostics",
		},
		{
			"path": "res://addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd",
			"label": "GF Extensions",
		},
	]
	_call_void(dock, &"setup", [records])

	assert_eq(dock.name, "GF", "统一工作区根节点应保留 GF 名称。")
	assert_true(dock.clip_contents, "统一工作区应裁剪超出内容，避免覆盖 Godot 底部栏。")
	assert_eq(dock.custom_minimum_size, Vector2(0.0, 72.0), "统一工作区最小高度只应保留顶部入口区。")
	assert_eq(_call_int(dock, &"get_page_count"), 5, "工作区应把多个 GF 面板收束为内部页面。")
	assert_eq(
		_call_packed_string_array(dock, &"get_page_titles"),
		PackedStringArray(["GF Storage Viewer", "GF Input Mapping", "GF Signal Diagnostics", "GF Diagnostics", "GF Extensions"]),
		"页面标题应保留原面板语义。"
	)
	assert_eq(
		_call_packed_string_array(dock, &"get_page_button_titles"),
		PackedStringArray(["存储", "输入", "信号诊断", "诊断", "扩展"]),
		"响应式页面入口应使用短标签。"
	)
	var about_summary: String = _call_text(dock, &"get_about_text")
	assert_true(about_summary.contains("版本：%s" % _call_text(dock, &"_get_framework_version")), "关于弹窗应展示当前框架版本。")
	assert_true(about_summary.contains("https://github.com/C76GN/gf-framework"), "关于弹窗应提供项目地址。")
	assert_true(about_summary.contains("https://gf-framework.readthedocs.io/"), "关于弹窗应提供正式文档地址。")
	assert_true(about_summary.contains("https://github.com/C76GN/gf-framework/issues"), "关于弹窗应提供问题反馈地址。")
	assert_true(about_summary.contains("https://github.com/C76GN/gf-framework/releases"), "关于弹窗应提供发布记录地址。")
	assert_true(about_summary.contains("cl7o6dgyn@gmail.com"), "关于弹窗应提供联系邮箱。")
	var tabs: TabContainer = _get_tab_container(dock, &"_tabs")
	var page_count: int = _call_int(dock, &"get_page_count")
	for index: int in range(page_count):
		var page: Control = _as_control(tabs.get_child(index))
		var content: Control = _as_control(page.get_child(0))
		assert_true(page.clip_contents, "每个页面容器都应裁剪内容，避免覆盖底部栏。")
		assert_eq(page.custom_minimum_size, Vector2.ZERO, "页面容器不应继承内部工具最小高度。")
		assert_true(content.clip_contents, "被装入工作区的工具页面应裁剪自身溢出内容。")
		assert_eq(content.anchor_right, 1.0, "工具页面应横向铺满页面容器。")
		assert_eq(content.anchor_bottom, 1.0, "工具页面应纵向跟随页面容器。")

	_call_void(dock, &"_ensure_about_dialog")
	var about_dialog: AcceptDialog = _get_accept_dialog(dock, &"_about_dialog")
	var about_scroll: ScrollContainer = _as_scroll_container(about_dialog.get_node("AboutContent/AboutLayout/AboutScroll"))
	var about_text: RichTextLabel = _as_rich_text_label(about_dialog.get_node("AboutContent/AboutLayout/AboutScroll/AboutText"))
	var about_actions: HBoxContainer = _as_hbox_container(about_dialog.get_node("AboutContent/AboutLayout/AboutActionRow"))
	var about_issues: Button = _as_button(about_dialog.get_node("AboutContent/AboutLayout/AboutActionRow/AboutIssuesButton"))
	var about_releases: Button = _as_button(about_dialog.get_node("AboutContent/AboutLayout/AboutActionRow/AboutReleasesButton"))
	var about_version_check: Button = _as_button(about_dialog.get_node("AboutContent/AboutLayout/AboutActionRow/AboutVersionCheckButton"))
	var about_version_status: Label = _as_label(about_dialog.get_node("AboutContent/AboutLayout/AboutVersionStatus"))
	var about_confirm: Button = _as_button(about_dialog.get_node("AboutContent/AboutLayout/AboutConfirmCenter/AboutConfirmButton"))
	assert_eq(about_dialog.min_size, Vector2i(560, 320), "关于弹窗应保持固定可控尺寸。")
	assert_eq(about_dialog.max_size, Vector2i(560, 320), "关于弹窗应限制最大尺寸，避免被编辑器窗口撑高。")
	assert_true(about_dialog.unresizable, "关于弹窗应避免被内容撑成过大的可调整窗口。")
	assert_false(about_dialog.wrap_controls, "关于弹窗不应按内容自动包裹成异常尺寸。")
	assert_eq(about_scroll.custom_minimum_size.y, 150.0, "关于正文区域应限制高度，避免长链接撑高弹窗。")
	assert_not_null(about_text, "关于弹窗应使用可点击链接文本。")
	assert_false(about_text.fit_content, "关于正文不应使用 fit_content，避免参与过长最小高度计算。")
	assert_true(about_text.text.contains("[url=https://github.com/C76GN/gf-framework]GitHub[/url]"), "项目地址应作为短正文链接呈现。")
	assert_true(about_text.text.contains("[url=https://gf-framework.readthedocs.io/]文档[/url]"), "文档地址应作为短正文链接呈现。")
	assert_true(about_text.text.contains("[url=https://github.com/C76GN/gf-framework/issues]Issues[/url]"), "Issues 地址应作为短正文链接呈现。")
	assert_true(about_text.text.contains("[url=https://github.com/C76GN/gf-framework/releases]Releases[/url]"), "Releases 地址应作为短正文链接呈现。")
	assert_true(about_text.text.contains("WeChat：C76_GN"), "关于弹窗应展示微信联系方式。")
	assert_true(about_text.text.contains("QQ：403150493"), "关于弹窗应展示 QQ 联系方式。")
	assert_not_null(about_actions, "关于弹窗应提供项目链接快捷按钮行。")
	assert_eq(about_issues.text, "Issues", "关于弹窗应提供 Issues 快捷按钮。")
	assert_eq(about_releases.text, "Releases", "关于弹窗应提供 Releases 快捷按钮。")
	assert_eq(about_version_check.text, "检测最新版本", "关于弹窗应提供手动版本检测按钮。")
	assert_true(about_version_status.text.contains("当前版本："), "版本检测状态应先展示当前版本。")
	assert_true(about_version_status.text.contains("手动检测"), "版本检测状态应提示可手动检查最新发布版本。")
	assert_eq(_call_text(dock, &"_normalize_version_tag", ["refs/tags/v3.5.0-beta+1"]), "3.5.0", "版本号归一化应忽略 tag 前缀、预发布和构建元数据。")
	assert_eq(_call_int(dock, &"_compare_version_strings", ["v3.5.1", "3.5.0"]), 1, "更新版本应被识别为更高版本。")
	assert_eq(_call_int(dock, &"_compare_version_strings", ["3.5.0", "v3.5.0"]), 0, "相同版本应被识别为一致。")
	assert_eq(_call_int(dock, &"_compare_version_strings", ["3.4.9", "3.5.0"]), -1, "旧版本应被识别为更低版本。")
	assert_true(
		GF_VARIANT_ACCESS.get_option_string(_call_dictionary(dock, &"_make_latest_version_status", ["v3.5.1", "3.5.0"]), "message").contains("发现新版本"),
		"最新版本高于当前版本时应提示更新。"
	)
	assert_true(
		GF_VARIANT_ACCESS.get_option_string(_call_dictionary(dock, &"_make_latest_version_status", ["v3.5.0", "3.5.0"]), "message").contains("当前已是最新版本"),
		"最新版本等于当前版本时应提示已是最新。"
	)
	add_child(dock)
	_call_void(dock, &"show_about_dialog")
	assert_eq(about_dialog.size, Vector2i(560, 320), "关于弹窗弹出后仍应保持紧凑尺寸。")
	assert_eq(about_dialog.mode, Window.MODE_WINDOWED, "关于弹窗弹出时应重置为普通窗口，避免沿用最大化状态。")
	about_dialog.hide()
	assert_false(about_dialog.get_ok_button().visible, "默认底部确认按钮应隐藏，避免按钮停在右下角。")
	assert_eq(about_confirm.text, "确定", "自定义确认按钮应使用中文确定。")
	assert_true(about_confirm.get_parent() is CenterContainer, "自定义确认按钮应放在居中容器中。")

	dock.free()


func test_editor_workspace_prefers_record_label_over_page_script_name() -> void:
	var dock: Control = _new_control(GF_EDITOR_WORKSPACE_DOCK)
	var records: Array[Dictionary] = [
		{
			"path": "res://addons/gf/standard/utilities/storage/editor/gf_storage_viewer_dock.gd",
			"label": "GF Save",
		},
	]
	_call_void(dock, &"setup", [records])

	assert_eq(_call_packed_string_array(dock, &"get_page_titles"), PackedStringArray(["GF Save"]), "工作区页面标题应优先使用产品化记录标题。")
	assert_eq(_call_packed_string_array(dock, &"get_page_button_titles"), PackedStringArray(["保存"]), "短标签应从产品化标题派生。")

	dock.free()


func test_editor_workspace_window_hosts_workspace_pages() -> void:
	var window: Window = _new_window(GF_EDITOR_WORKSPACE_WINDOW)
	var records: Array[Dictionary] = [
		{
			"path": "res://addons/gf/standard/utilities/storage/editor/gf_storage_viewer_dock.gd",
			"label": "GF Storage Viewer",
		},
		{
			"path": "res://addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd",
			"label": "GF Extensions",
		},
	]

	_call_void(window, &"setup", [records])

	assert_eq(window.title, "GF Workspace", "独立窗口应使用统一 GF 工作区标题。")
	assert_eq(window.min_size, Vector2i(900, 560), "独立窗口应提供足够的编辑器工作面积。")
	assert_eq(_call_int(window, &"get_page_count"), 2, "独立窗口应承载注入的工作区页面。")
	assert_eq(_call_packed_string_array(window, &"get_page_titles"), PackedStringArray(["GF Storage Viewer", "GF Extensions"]), "独立窗口应保留页面标题。")
	var workspace: Control = _call_control(window, &"get_workspace")
	assert_not_null(workspace, "独立窗口应持有内部工作区控件。")
	window.transient = true
	window.exclusive = true
	_call_void(window, &"set_always_on_top_enabled", [true])
	assert_true(_call_bool(window, &"is_always_on_top_enabled"), "独立工作区窗口应支持置顶。")
	assert_false(window.transient, "启用置顶前应解除 transient，避免 Godot 报错。")
	assert_false(window.exclusive, "启用置顶前应解除 exclusive，避免沿用临时弹窗语义。")
	var always_on_top_button: Button = _get_button(workspace, &"_always_on_top_button")
	assert_true(always_on_top_button.button_pressed, "工作区置顶按钮应同步窗口状态。")
	_call_void(workspace, &"_on_always_on_top_toggled", [false])
	assert_false(_call_bool(window, &"is_always_on_top_enabled"), "置顶按钮应能关闭独立窗口置顶。")

	window.free()


func test_extension_manager_dock_exposes_strict_reference_export_policy() -> void:
	var restore: Dictionary = _set_project_setting(
		GF_EXTENSION_SETTINGS_BASE.EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING,
		true
	)
	var dock: VBoxContainer = _new_vbox_container(GF_EXTENSION_MANAGER_DOCK)
	_call_void(dock, &"_refresh_extensions")

	var export_fail_check: CheckBox = _get_check_box(dock, &"_export_fail_check")
	assert_not_null(export_fail_check, "扩展管理面板应暴露禁用扩展引用的严格导出策略。")
	assert_eq(export_fail_check.text, "引用禁用扩展时阻止导出", "严格导出策略应有清晰的 UI 文案。")
	assert_true(export_fail_check.button_pressed, "扩展管理面板应读取当前严格导出策略。")

	dock.free()
	_restore_project_setting(
		GF_EXTENSION_SETTINGS_BASE.EXPORT_FAIL_ON_DISABLED_REFERENCES_SETTING,
		restore
	)


func test_extension_manager_dock_clears_rows_immediately() -> void:
	var dock: VBoxContainer = _new_vbox_container(GF_EXTENSION_MANAGER_DOCK)
	var first: Label = Label.new()
	var second: Label = Label.new()
	var extension_rows: VBoxContainer = _get_vbox_container(dock, &"_extension_rows")
	extension_rows.add_child(first)
	extension_rows.add_child(second)

	_call_void(dock, &"_clear_extension_rows")

	assert_eq(extension_rows.get_child_count(), 0, "刷新扩展列表时旧行应立即从容器移除。")
	assert_null(first.get_parent(), "第一行应立即脱离扩展列表容器。")
	assert_null(second.get_parent(), "第二行应立即脱离扩展列表容器。")

	await get_tree().process_frame
	assert_false(is_instance_valid(first), "下一帧第一行应完成释放。")
	assert_false(is_instance_valid(second), "下一帧第二行应完成释放。")
	dock.free()


# --- 私有/辅助方法 ---

func _set_enabled_extensions(extension_ids: Array[String]) -> Dictionary:
	var setting_name: String = GF_EXTENSION_SETTINGS_BASE.ENABLED_EXTENSIONS_SETTING
	var restore: Dictionary = {
		"had_setting": ProjectSettings.has_setting(setting_name),
		"value": ProjectSettings.get_setting(setting_name, []),
	}
	ProjectSettings.set_setting(setting_name, extension_ids)
	return restore


func _restore_enabled_extensions(restore: Dictionary) -> void:
	var setting_name: String = GF_EXTENSION_SETTINGS_BASE.ENABLED_EXTENSIONS_SETTING
	if GF_VARIANT_ACCESS.get_option_bool(restore, "had_setting"):
		ProjectSettings.set_setting(setting_name, GF_VARIANT_ACCESS.get_option_value(restore, "value", []))
	else:
		ProjectSettings.clear(setting_name)


func _mark_workspace_ui_button_pressed(state: WorkspaceButtonState) -> void:
	state.count += 1


func _set_project_setting(setting_name: String, value: Variant) -> Dictionary:
	var restore: Dictionary = {
		"had_setting": ProjectSettings.has_setting(setting_name),
		"value": ProjectSettings.get_setting(setting_name, null),
	}
	ProjectSettings.set_setting(setting_name, value)
	return restore


func _restore_project_setting(setting_name: String, restore: Dictionary) -> void:
	if GF_VARIANT_ACCESS.get_option_bool(restore, "had_setting"):
		ProjectSettings.set_setting(setting_name, GF_VARIANT_ACCESS.get_option_value(restore, "value", null))
	else:
		ProjectSettings.clear(setting_name)


func _new_object(script: Variant) -> Object:
	assert_true(script is Script, "测试 helper 脚本应是可实例化 Script。")
	if script is Script:
		var helper_script: Script = script
		var instance: Variant = helper_script.call(&"new")
		assert_true(instance is Object, "测试 helper 脚本应实例化为 Object。")
		if instance is Object:
			var object_instance: Object = instance
			return object_instance
	return null


func _new_control(script: Variant) -> Control:
	var object_instance: Object = _new_object(script)
	assert_true(object_instance is Control, "测试 helper 脚本应实例化为 Control。")
	if object_instance is Control:
		var control: Control = object_instance
		return control
	return null


func _new_vbox_container(script: Variant) -> VBoxContainer:
	var object_instance: Object = _new_object(script)
	assert_true(object_instance is VBoxContainer, "测试 helper 脚本应实例化为 VBoxContainer。")
	if object_instance is VBoxContainer:
		var container: VBoxContainer = object_instance
		return container
	return null


func _new_window(script: Variant) -> Window:
	var object_instance: Object = _new_object(script)
	assert_true(object_instance is Window, "测试 helper 脚本应实例化为 Window。")
	if object_instance is Window:
		var window: Window = object_instance
		return window
	return null


func _call_value(target: Object, method_name: StringName, args: Array = []) -> Variant:
	return target.callv(method_name, args)


func _call_void(target: Object, method_name: StringName, args: Array = []) -> void:
	var _call_result: Variant = _call_value(target, method_name, args)


func _call_array(target: Object, method_name: StringName, args: Array = []) -> Array:
	return GF_VARIANT_ACCESS.as_array(_call_value(target, method_name, args))


func _call_dictionary(target: Object, method_name: StringName, args: Array = []) -> Dictionary:
	return GF_VARIANT_ACCESS.as_dictionary(_call_value(target, method_name, args))


func _call_int(target: Object, method_name: StringName, args: Array = []) -> int:
	return GF_VARIANT_ACCESS.to_int(_call_value(target, method_name, args))


func _call_bool(target: Object, method_name: StringName, args: Array = []) -> bool:
	return GF_VARIANT_ACCESS.to_bool(_call_value(target, method_name, args))


func _call_text(target: Object, method_name: StringName, args: Array = []) -> String:
	return GF_VARIANT_ACCESS.to_text(_call_value(target, method_name, args))


func _call_packed_string_array(target: Object, method_name: StringName, args: Array = []) -> PackedStringArray:
	var value: Variant = _call_value(target, method_name, args)
	if value is PackedStringArray:
		var strings: PackedStringArray = value
		return strings
	if value is Array:
		var values: Array = value
		var result: PackedStringArray = PackedStringArray()
		for item: Variant in values:
			var _append_result: bool = result.append(GF_VARIANT_ACCESS.to_text(item))
		return result
	return PackedStringArray()


func _call_control(target: Object, method_name: StringName, args: Array = []) -> Control:
	var value: Variant = _call_value(target, method_name, args)
	assert_true(value is Control, "测试观察值应为 Control。")
	if value is Control:
		var control: Control = value
		return control
	return null


func _dictionary_at(values: Array, index: int) -> Dictionary:
	assert_true(index >= 0 and index < values.size(), "测试记录索引应在数组范围内。")
	var value: Variant = values[index] if index >= 0 and index < values.size() else {}
	assert_true(value is Dictionary, "测试记录应为 Dictionary。")
	return GF_VARIANT_ACCESS.as_dictionary(value)


func _get_tab_container(target: Object, property_name: StringName) -> TabContainer:
	return _as_tab_container(target.get(property_name))


func _get_accept_dialog(target: Object, property_name: StringName) -> AcceptDialog:
	return _as_accept_dialog(target.get(property_name))


func _get_button(target: Object, property_name: StringName) -> Button:
	return _as_button(target.get(property_name))


func _get_check_box(target: Object, property_name: StringName) -> CheckBox:
	return _as_check_box(target.get(property_name))


func _get_vbox_container(target: Object, property_name: StringName) -> VBoxContainer:
	return _as_vbox_container(target.get(property_name))


func _as_file_dialog(value: Variant) -> FileDialog:
	assert_true(value is FileDialog, "测试观察值应为 FileDialog。")
	if value is FileDialog:
		var dialog: FileDialog = value
		return dialog
	return null


func _as_control(value: Variant) -> Control:
	assert_true(value is Control, "测试观察值应为 Control。")
	if value is Control:
		var control: Control = value
		return control
	return null


func _as_scroll_container(value: Variant) -> ScrollContainer:
	assert_true(value is ScrollContainer, "测试观察值应为 ScrollContainer。")
	if value is ScrollContainer:
		var control: ScrollContainer = value
		return control
	return null


func _as_rich_text_label(value: Variant) -> RichTextLabel:
	assert_true(value is RichTextLabel, "测试观察值应为 RichTextLabel。")
	if value is RichTextLabel:
		var label: RichTextLabel = value
		return label
	return null


func _as_hbox_container(value: Variant) -> HBoxContainer:
	assert_true(value is HBoxContainer, "测试观察值应为 HBoxContainer。")
	if value is HBoxContainer:
		var container: HBoxContainer = value
		return container
	return null


func _as_vbox_container(value: Variant) -> VBoxContainer:
	assert_true(value is VBoxContainer, "测试观察值应为 VBoxContainer。")
	if value is VBoxContainer:
		var container: VBoxContainer = value
		return container
	return null


func _as_tab_container(value: Variant) -> TabContainer:
	assert_true(value is TabContainer, "测试观察值应为 TabContainer。")
	if value is TabContainer:
		var container: TabContainer = value
		return container
	return null


func _as_accept_dialog(value: Variant) -> AcceptDialog:
	assert_true(value is AcceptDialog, "测试观察值应为 AcceptDialog。")
	if value is AcceptDialog:
		var dialog: AcceptDialog = value
		return dialog
	return null


func _as_button(value: Variant) -> Button:
	assert_true(value is Button, "测试观察值应为 Button。")
	if value is Button:
		var button: Button = value
		return button
	return null


func _as_check_box(value: Variant) -> CheckBox:
	assert_true(value is CheckBox, "测试观察值应为 CheckBox。")
	if value is CheckBox:
		var check_box: CheckBox = value
		return check_box
	return null


func _as_label(value: Variant) -> Label:
	assert_true(value is Label, "测试观察值应为 Label。")
	if value is Label:
		var label: Label = value
		return label
	return null


# --- 辅助类型 ---

class WorkspaceButtonState:
	extends RefCounted

	var count: int = 0
