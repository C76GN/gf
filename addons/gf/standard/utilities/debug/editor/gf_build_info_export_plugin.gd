@tool

## GFBuildInfoExportPlugin: 导出时写入构建元数据的可选编辑器插件。
##
## 只负责把通用 Git 构建字段写入 ProjectSettings，项目仍可决定是否保存、
## 是否恢复旧值以及如何展示这些字段。
## [br]
## @api public
## [br]
## @category editor_api
## [br]
## @since 3.17.0
class_name GFBuildInfoExportPlugin
extends EditorExportPlugin


# --- 常量 ---

## 是否在导出开始时写入 Git 构建元数据的 ProjectSettings 键。
## [br]
## @api public
const ENABLED_SETTING: String = "gf/build/export/write_git_metadata"

## 导出结束后是否恢复旧构建元数据的 ProjectSettings 键。
## [br]
## @api public
const RESTORE_PREVIOUS_SETTING: String = "gf/build/export/restore_previous_settings"

## 写入或恢复后是否立即保存 ProjectSettings 的设置键。
## [br]
## @api public
const SAVE_PROJECT_SETTINGS_SETTING: String = "gf/build/export/save_project_settings"

## 导出时附加到构建信息中的自定义元数据 ProjectSettings 键。
## [br]
## @api public
const EXTRA_METADATA_SETTING: String = "gf/build/export/metadata"

const _BUILD_SETTING_PATHS: Array[String] = [
	"gf/build/commit_hash",
	"gf/build/branch",
	"gf/build/tag",
	"gf/build/commit_count",
	"gf/build/is_dirty",
	"gf/build/time_utc",
	"gf/build/metadata",
]


# --- 私有变量 ---

var _previous_settings: Dictionary = {}
var _had_previous_setting: Dictionary = {}
var _export_wrote_metadata: bool = false


# --- Godot 生命周期方法 ---

func _get_name() -> String:
	return "GFBuildInfoExportPlugin"


func _export_begin(
	_features: PackedStringArray,
	_is_debug: bool,
	_path: String,
	_flags: int
) -> void:
	if not bool(ProjectSettings.get_setting(ENABLED_SETTING, false)):
		return

	_capture_previous_settings()
	var extra_metadata := ProjectSettings.get_setting(EXTRA_METADATA_SETTING, {}) as Dictionary
	GFBuildInfo.write_git_metadata_to_project_settings(
		"res://",
		extra_metadata.duplicate(true) if extra_metadata != null else {},
		bool(ProjectSettings.get_setting(SAVE_PROJECT_SETTINGS_SETTING, false))
	)
	_export_wrote_metadata = true


func _export_end() -> void:
	if not _export_wrote_metadata:
		return

	if bool(ProjectSettings.get_setting(RESTORE_PREVIOUS_SETTING, true)):
		_restore_previous_settings()
		if bool(ProjectSettings.get_setting(SAVE_PROJECT_SETTINGS_SETTING, false)):
			ProjectSettings.save()

	_previous_settings.clear()
	_had_previous_setting.clear()
	_export_wrote_metadata = false


# --- 私有/辅助方法 ---

func _capture_previous_settings() -> void:
	_previous_settings.clear()
	_had_previous_setting.clear()
	for setting_path: String in _BUILD_SETTING_PATHS:
		_had_previous_setting[setting_path] = ProjectSettings.has_setting(setting_path)
		if ProjectSettings.has_setting(setting_path):
			_previous_settings[setting_path] = ProjectSettings.get_setting(setting_path)


func _restore_previous_settings() -> void:
	for setting_path: String in _BUILD_SETTING_PATHS:
		if bool(_had_previous_setting.get(setting_path, false)):
			ProjectSettings.set_setting(setting_path, _previous_settings.get(setting_path))
		else:
			ProjectSettings.clear(setting_path)
