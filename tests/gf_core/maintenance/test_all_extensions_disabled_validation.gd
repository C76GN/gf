## 验证所有 GF 内置扩展禁用时 kernel/standard 仍可独立加载。
extends GutTest


# --- 常量 ---

const SOURCE_ROOTS: Array[String] = [
	"res://addons/gf/kernel",
	"res://addons/gf/standard",
]
const GF_EXTENSION_SETTINGS_BASE := preload("res://addons/gf/kernel/extension/gf_extension_settings.gd")
const GF_PLUGIN_ACTIONS := preload("res://addons/gf/kernel/editor/gf_plugin_actions.gd")
const GF_PLUGIN_DOCK_TOOLS := preload("res://addons/gf/kernel/editor/gf_plugin_dock_tools.gd")
const GF_PLUGIN_INSPECTOR_TOOLS := preload("res://addons/gf/kernel/editor/gf_plugin_inspector_tools.gd")


# --- 测试用例 ---

func test_all_extensions_disabled_keeps_extension_queries_empty() -> void:
	var restore := _set_enabled_extensions([])
	var enabled_manifests := GF_EXTENSION_SETTINGS_BASE.get_enabled_manifests()
	var editor_action_paths := GF_EXTENSION_SETTINGS_BASE.get_enabled_editor_action_paths()
	var editor_dock_paths := GF_EXTENSION_SETTINGS_BASE.get_enabled_editor_dock_paths()
	var editor_inspector_paths := GF_EXTENSION_SETTINGS_BASE.get_enabled_editor_inspector_paths()
	var export_plugin_paths := GF_EXTENSION_SETTINGS_BASE.get_enabled_export_plugin_paths()
	var access_extension_paths := GF_EXTENSION_SETTINGS_BASE.get_enabled_access_generator_extension_paths()
	_restore_enabled_extensions(restore)

	assert_true(enabled_manifests.is_empty(), "全禁用时不应解析出启用扩展 manifest。")
	assert_true(editor_action_paths.is_empty(), "全禁用时不应暴露扩展菜单动作。")
	assert_true(editor_dock_paths.is_empty(), "全禁用时不应暴露扩展 Dock。")
	assert_true(editor_inspector_paths.is_empty(), "全禁用时不应暴露扩展 Inspector。")
	assert_true(export_plugin_paths.is_empty(), "全禁用时不应暴露扩展导出插件。")
	assert_true(access_extension_paths.is_empty(), "全禁用时不应暴露扩展访问器扩展。")


func test_all_extensions_disabled_plugin_helpers_discover_no_extension_extensions() -> void:
	var restore := _set_enabled_extensions([])
	var actions: Variant = GF_PLUGIN_ACTIONS.new()
	actions._load_extension_editor_actions()
	actions._register_loaded_extension_action_entries()
	var action_entries := _filter_extension_menu_entries(
		actions.get_menu_entries(),
		int(actions.EXTENSION_MENU_ID_START)
	)
	actions._cleanup_extension_editor_actions()

	var dock_tools: Variant = GF_PLUGIN_DOCK_TOOLS.new()
	var dock_records: Array = dock_tools._collect_enabled_extension_dock_records()

	var inspector_tools: Variant = GF_PLUGIN_INSPECTOR_TOOLS.new()
	var inspector_records: Array = inspector_tools._collect_enabled_extension_inspector_records()
	_restore_enabled_extensions(restore)

	assert_true(action_entries.is_empty(), "全禁用时 GF 菜单不应注册扩展级动作。")
	assert_true(dock_records.is_empty(), "全禁用时不应注册扩展级 Dock。")
	assert_true(inspector_records.is_empty(), "全禁用时不应注册扩展级 Inspector。")


func test_kernel_and_standard_scripts_load_with_all_extensions_disabled() -> void:
	var restore := _set_enabled_extensions([])
	var paths: Array[String] = []
	for root: String in SOURCE_ROOTS:
		_collect_gd_files(root, paths)

	var issues: Array[String] = []
	for path: String in paths:
		if load(path) == null:
			issues.append(path)
	_restore_enabled_extensions(restore)

	assert_eq(issues, [], "全禁用时 kernel/standard 脚本仍应可加载：\n%s" % _join_lines(issues))


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


func _filter_extension_menu_entries(entries: Array, extension_menu_id_start: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry_variant: Variant in entries:
		var entry := entry_variant as Dictionary
		if entry == null:
			continue
		if int(entry.get("id", -1)) >= extension_menu_id_start:
			result.append(entry.duplicate(true))
	return result


func _join_lines(lines: Array[String]) -> String:
	var packed := PackedStringArray()
	for line: String in lines:
		packed.append(line)
	return "\n".join(packed)
