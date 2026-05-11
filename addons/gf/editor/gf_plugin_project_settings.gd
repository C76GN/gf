@tool

## GF 插件 ProjectSettings 注册辅助。
extends RefCounted


# --- 常量 ---

const INSTALLERS_SETTING: String = "gf/project/installers"
const INSTALLERS_DEFAULT := []
const FAIL_ON_INSTALLER_ERROR_SETTING: String = "gf/project/fail_on_installer_error"
const FAIL_ON_INSTALLER_ERROR_DEFAULT: bool = true
const INSTALLER_TIMEOUT_SETTING: String = "gf/project/installer_timeout_seconds"
const INSTALLER_TIMEOUT_DEFAULT: float = 0.0
const ACCESS_OUTPUT_SETTING: String = "gf/codegen/access_output_path"
const ACCESS_OUTPUT_DEFAULT: String = "res://gf/generated/gf_access.gd"
const PROJECT_ACCESS_OUTPUT_SETTING: String = "gf/codegen/project_access_output_path"
const PROJECT_ACCESS_OUTPUT_DEFAULT: String = "res://gf/generated/gf_project_access.gd"
const BUILD_INFO_EXPORT_ENABLED_SETTING: String = "gf/build/export/write_git_metadata"
const BUILD_INFO_EXPORT_RESTORE_SETTING: String = "gf/build/export/restore_previous_settings"
const BUILD_INFO_EXPORT_SAVE_SETTING: String = "gf/build/export/save_project_settings"
const BUILD_INFO_EXPORT_METADATA_SETTING: String = "gf/build/export/metadata"


# --- 公共方法 ---

static func ensure_all() -> void:
	var should_save := false
	if _ensure_default(INSTALLERS_SETTING, INSTALLERS_DEFAULT):
		should_save = true
	if _ensure_default(FAIL_ON_INSTALLER_ERROR_SETTING, FAIL_ON_INSTALLER_ERROR_DEFAULT):
		should_save = true
	if _ensure_default(INSTALLER_TIMEOUT_SETTING, INSTALLER_TIMEOUT_DEFAULT):
		should_save = true
	if _ensure_default(ACCESS_OUTPUT_SETTING, ACCESS_OUTPUT_DEFAULT):
		should_save = true
	if _ensure_default(PROJECT_ACCESS_OUTPUT_SETTING, PROJECT_ACCESS_OUTPUT_DEFAULT):
		should_save = true
	if _ensure_default(BUILD_INFO_EXPORT_ENABLED_SETTING, false):
		should_save = true
	if _ensure_default(BUILD_INFO_EXPORT_RESTORE_SETTING, true):
		should_save = true
	if _ensure_default(BUILD_INFO_EXPORT_SAVE_SETTING, false):
		should_save = true
	if _ensure_default(BUILD_INFO_EXPORT_METADATA_SETTING, {}):
		should_save = true

	_register_property_info()
	if should_save:
		ProjectSettings.save()


static func get_access_output_path() -> String:
	return String(ProjectSettings.get_setting(ACCESS_OUTPUT_SETTING, ACCESS_OUTPUT_DEFAULT))


static func get_project_access_output_path() -> String:
	return String(ProjectSettings.get_setting(PROJECT_ACCESS_OUTPUT_SETTING, PROJECT_ACCESS_OUTPUT_DEFAULT))


# --- 私有/辅助方法 ---

static func _ensure_default(setting_name: String, default_value: Variant) -> bool:
	if ProjectSettings.has_setting(setting_name):
		return false
	ProjectSettings.set_setting(setting_name, default_value)
	ProjectSettings.set_initial_value(setting_name, default_value)
	return true


static func _register_property_info() -> void:
	ProjectSettings.add_property_info({
		"name": INSTALLERS_SETTING,
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "%d/%d:*.gd" % [TYPE_STRING, PROPERTY_HINT_FILE],
	})
	ProjectSettings.set_as_basic(INSTALLERS_SETTING, true)
	ProjectSettings.add_property_info({
		"name": FAIL_ON_INSTALLER_ERROR_SETTING,
		"type": TYPE_BOOL,
	})
	ProjectSettings.set_as_basic(FAIL_ON_INSTALLER_ERROR_SETTING, true)
	ProjectSettings.add_property_info({
		"name": INSTALLER_TIMEOUT_SETTING,
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,600,0.1,or_greater",
	})
	ProjectSettings.set_as_basic(INSTALLER_TIMEOUT_SETTING, true)
	ProjectSettings.add_property_info({
		"name": ACCESS_OUTPUT_SETTING,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.gd",
	})
	ProjectSettings.set_as_basic(ACCESS_OUTPUT_SETTING, true)
	ProjectSettings.add_property_info({
		"name": PROJECT_ACCESS_OUTPUT_SETTING,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.gd",
	})
	ProjectSettings.set_as_basic(PROJECT_ACCESS_OUTPUT_SETTING, true)
	ProjectSettings.add_property_info({
		"name": BUILD_INFO_EXPORT_ENABLED_SETTING,
		"type": TYPE_BOOL,
	})
	ProjectSettings.set_as_basic(BUILD_INFO_EXPORT_ENABLED_SETTING, true)
	ProjectSettings.add_property_info({
		"name": BUILD_INFO_EXPORT_RESTORE_SETTING,
		"type": TYPE_BOOL,
	})
	ProjectSettings.set_as_basic(BUILD_INFO_EXPORT_RESTORE_SETTING, true)
	ProjectSettings.add_property_info({
		"name": BUILD_INFO_EXPORT_SAVE_SETTING,
		"type": TYPE_BOOL,
	})
	ProjectSettings.set_as_basic(BUILD_INFO_EXPORT_SAVE_SETTING, true)
	ProjectSettings.add_property_info({
		"name": BUILD_INFO_EXPORT_METADATA_SETTING,
		"type": TYPE_DICTIONARY,
	})
