## 验证所有官方包禁用时 kernel/standard 仍可独立加载。
extends GutTest


# --- 常量 ---

const SOURCE_ROOTS: Array[String] = [
	"res://addons/gf/kernel",
	"res://addons/gf/standard",
]
const GF_PACKAGE_SETTINGS_BASE := preload("res://addons/gf/kernel/package/gf_package_settings.gd")
const GF_PLUGIN_ACTIONS := preload("res://addons/gf/kernel/editor/gf_plugin_actions.gd")
const GF_PLUGIN_DOCK_TOOLS := preload("res://addons/gf/kernel/editor/gf_plugin_dock_tools.gd")
const GF_PLUGIN_INSPECTOR_TOOLS := preload("res://addons/gf/kernel/editor/gf_plugin_inspector_tools.gd")


# --- 测试用例 ---

func test_all_packages_disabled_keeps_extension_queries_empty() -> void:
	var restore := _set_enabled_packages([])
	var enabled_manifests := GF_PACKAGE_SETTINGS_BASE.get_enabled_manifests(true)
	var editor_action_paths := GF_PACKAGE_SETTINGS_BASE.get_enabled_editor_action_paths(true)
	var editor_dock_paths := GF_PACKAGE_SETTINGS_BASE.get_enabled_editor_dock_paths(true)
	var editor_inspector_paths := GF_PACKAGE_SETTINGS_BASE.get_enabled_editor_inspector_paths(true)
	var export_plugin_paths := GF_PACKAGE_SETTINGS_BASE.get_enabled_export_plugin_paths(true)
	var access_extension_paths := GF_PACKAGE_SETTINGS_BASE.get_enabled_access_generator_extension_paths(true)
	_restore_enabled_packages(restore)

	assert_true(enabled_manifests.is_empty(), "全禁用时不应解析出启用包 manifest。")
	assert_true(editor_action_paths.is_empty(), "全禁用时不应暴露包菜单动作。")
	assert_true(editor_dock_paths.is_empty(), "全禁用时不应暴露包 Dock。")
	assert_true(editor_inspector_paths.is_empty(), "全禁用时不应暴露包 Inspector。")
	assert_true(export_plugin_paths.is_empty(), "全禁用时不应暴露包导出插件。")
	assert_true(access_extension_paths.is_empty(), "全禁用时不应暴露包访问器扩展。")


func test_all_packages_disabled_plugin_helpers_discover_no_package_extensions() -> void:
	var restore := _set_enabled_packages([])
	var actions: Variant = GF_PLUGIN_ACTIONS.new()
	actions._load_package_editor_actions()
	var action_entries: Array = actions.get_package_menu_entries()
	actions._cleanup_package_editor_actions()

	var dock_tools: Variant = GF_PLUGIN_DOCK_TOOLS.new()
	var dock_records: Array = dock_tools._collect_enabled_package_dock_records()

	var inspector_tools: Variant = GF_PLUGIN_INSPECTOR_TOOLS.new()
	var inspector_records: Array = inspector_tools._collect_enabled_package_inspector_records()
	_restore_enabled_packages(restore)

	assert_true(action_entries.is_empty(), "全禁用时 GF 菜单不应注册包级动作。")
	assert_true(dock_records.is_empty(), "全禁用时不应注册包级 Dock。")
	assert_true(inspector_records.is_empty(), "全禁用时不应注册包级 Inspector。")


func test_kernel_and_standard_scripts_load_with_all_packages_disabled() -> void:
	var restore := _set_enabled_packages([])
	var paths: Array[String] = []
	for root: String in SOURCE_ROOTS:
		_collect_gd_files(root, paths)

	var issues: Array[String] = []
	for path: String in paths:
		if load(path) == null:
			issues.append(path)
	_restore_enabled_packages(restore)

	assert_eq(issues, [], "全禁用时 kernel/standard 脚本仍应可加载：\n%s" % _join_lines(issues))


# --- 私有/辅助方法 ---

func _set_enabled_packages(package_ids: Array[String]) -> Dictionary:
	var setting_name: String = GF_PACKAGE_SETTINGS_BASE.ENABLED_PACKAGES_SETTING
	var restore := {
		"had_setting": ProjectSettings.has_setting(setting_name),
		"value": ProjectSettings.get_setting(setting_name, []),
	}
	ProjectSettings.set_setting(setting_name, package_ids)
	return restore


func _restore_enabled_packages(restore: Dictionary) -> void:
	var setting_name: String = GF_PACKAGE_SETTINGS_BASE.ENABLED_PACKAGES_SETTING
	if bool(restore.get("had_setting", false)):
		ProjectSettings.set_setting(setting_name, restore.get("value", []))
	else:
		ProjectSettings.clear(setting_name)


func _collect_gd_files(root_path: String, result: Array[String]) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while not entry.is_empty():
		var path := root_path.path_join(entry)
		if dir.current_is_dir():
			if not entry.begins_with("."):
				_collect_gd_files(path, result)
		elif entry.ends_with(".gd"):
			result.append(path)
		entry = dir.get_next()
	dir.list_dir_end()


func _join_lines(lines: Array[String]) -> String:
	var packed := PackedStringArray()
	for line: String in lines:
		packed.append(line)
	return "\n".join(packed)
