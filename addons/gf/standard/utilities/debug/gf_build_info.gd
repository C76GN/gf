## GFBuildInfo: 运行时构建信息快照。
##
## 用统一 Resource 承载项目版本、GF 版本、构建号、提交号和运行平台信息，
## 便于诊断、日志、存档元数据或项目自己的版本界面复用。
class_name GFBuildInfo
extends Resource


# --- 常量 ---

const BUILD_ID_SETTING: String = "gf/build/id"
const COMMIT_HASH_SETTING: String = "gf/build/commit_hash"
const BRANCH_SETTING: String = "gf/build/branch"
const TAG_SETTING: String = "gf/build/tag"
const COMMIT_COUNT_SETTING: String = "gf/build/commit_count"
const IS_DIRTY_SETTING: String = "gf/build/is_dirty"
const TIME_UTC_SETTING: String = "gf/build/time_utc"
const METADATA_SETTING: String = "gf/build/metadata"
const PROJECT_NAME_SETTING: String = "application/config/name"
const PROJECT_VERSION_SETTING: String = "application/config/version"
const FRAMEWORK_PLUGIN_CONFIG_PATH: String = "res://addons/gf/plugin.cfg"


# --- 导出变量 ---

## 项目名称。
@export var project_name: String = ""

## 项目版本。
@export var project_version: String = ""

## GF Framework 版本。
@export var framework_version: String = ""

## 构建流水线或发行流程写入的构建标识。
@export var build_id: String = ""

## 构建对应的提交哈希。
@export var commit_hash: String = ""

## 构建对应的分支名。
@export var branch: String = ""

## 构建对应的标签名。
@export var tag: String = ""

## 构建对应的提交数量或流水线序号。
@export var commit_count: int = 0

## 构建来源工作区是否存在未提交改动。
@export var is_dirty: bool = false

## 构建时间，建议使用 UTC ISO 文本。
@export var build_time_utc: String = ""

## 当前运行的 Godot 引擎版本文本。
@export var engine_version: String = ""

## 当前运行平台名称。
@export var platform_name: String = ""

## 当前运行包是否为 debug build。
@export var is_debug_build: bool = false

## 项目自定义构建元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 转换为 Dictionary。
## @return 构建信息字典。
func to_dict() -> Dictionary:
	return {
		"project_name": project_name,
		"project_version": project_version,
		"framework_version": framework_version,
		"build_id": build_id,
		"commit_hash": commit_hash,
		"branch": branch,
		"tag": tag,
		"commit_count": commit_count,
		"is_dirty": is_dirty,
		"build_time_utc": build_time_utc,
		"engine_version": engine_version,
		"platform_name": platform_name,
		"is_debug_build": is_debug_build,
		"metadata": metadata.duplicate(true),
	}


## 应用字典数据。
## @param data: 构建信息字典。
func apply_dict(data: Dictionary) -> void:
	project_name = String(data.get("project_name", project_name))
	project_version = String(data.get("project_version", project_version))
	framework_version = String(data.get("framework_version", framework_version))
	build_id = String(data.get("build_id", build_id))
	commit_hash = String(data.get("commit_hash", commit_hash))
	branch = String(data.get("branch", branch))
	tag = String(data.get("tag", tag))
	commit_count = int(data.get("commit_count", commit_count))
	is_dirty = bool(data.get("is_dirty", is_dirty))
	build_time_utc = String(data.get("build_time_utc", build_time_utc))
	engine_version = String(data.get("engine_version", engine_version))
	platform_name = String(data.get("platform_name", platform_name))
	is_debug_build = bool(data.get("is_debug_build", is_debug_build))
	var metadata_data := data.get("metadata", {}) as Dictionary
	metadata = metadata_data.duplicate(true) if metadata_data != null else {}


## 创建当前运行环境的构建信息。
## @return 构建信息快照。
static func collect() -> GFBuildInfo:
	var info := GFBuildInfo.new()
	info.project_name = _get_project_setting_text(PROJECT_NAME_SETTING)
	info.project_version = _get_project_setting_text(PROJECT_VERSION_SETTING)
	info.framework_version = _read_framework_version()
	info.build_id = _get_project_setting_text(BUILD_ID_SETTING)
	info.commit_hash = _get_project_setting_text(COMMIT_HASH_SETTING)
	info.branch = _get_project_setting_text(BRANCH_SETTING)
	info.tag = _get_project_setting_text(TAG_SETTING)
	info.commit_count = int(ProjectSettings.get_setting(COMMIT_COUNT_SETTING, 0))
	info.is_dirty = bool(ProjectSettings.get_setting(IS_DIRTY_SETTING, false))
	info.build_time_utc = _get_project_setting_text(TIME_UTC_SETTING)
	info.engine_version = _format_engine_version(Engine.get_version_info())
	info.platform_name = OS.get_name()
	info.is_debug_build = OS.is_debug_build()
	var metadata_value: Variant = ProjectSettings.get_setting(METADATA_SETTING, {})
	info.metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}
	return info


## 从 Dictionary 创建构建信息。
## @param data: 构建信息字典。
## @return 新构建信息。
static func from_dict(data: Dictionary) -> GFBuildInfo:
	var info := GFBuildInfo.new()
	info.apply_dict(data)
	return info


## 从当前 Git 工作区收集构建元数据。该方法通常由导出脚本或编辑器工具调用。
## @param work_dir: Git 工作区目录；支持 `res://`、`user://` 或原生路径。
## @return Git 构建元数据。
static func collect_git_metadata(work_dir: String = "res://") -> Dictionary:
	var native_dir := _to_native_path(work_dir)
	var short_hash := _run_git(native_dir, ["rev-parse", "--short=12", "HEAD"])
	var branch_name := _run_git(native_dir, ["rev-parse", "--abbrev-ref", "HEAD"])
	var tag_name := _run_git(native_dir, ["describe", "--tags", "--abbrev=0"])
	var count_text := _run_git(native_dir, ["rev-list", "--count", "HEAD"])
	var dirty_text := _run_git(native_dir, ["status", "--porcelain"])
	return {
		"commit_hash": short_hash,
		"branch": branch_name,
		"tag": tag_name,
		"commit_count": count_text.to_int() if not count_text.is_empty() else 0,
		"is_dirty": not dirty_text.is_empty(),
		"build_time_utc": Time.get_datetime_string_from_system(true, false),
	}


## 把 Git 构建元数据写入 ProjectSettings，供 collect() 在运行时读取。
## @param work_dir: Git 工作区目录；支持 `res://`、`user://` 或原生路径。
## @param extra_metadata: 项目自定义构建元数据。
## @param save_settings: 是否立即保存 ProjectSettings。
## @return 写入的构建元数据。
static func write_git_metadata_to_project_settings(
	work_dir: String = "res://",
	extra_metadata: Dictionary = {},
	save_settings: bool = false
) -> Dictionary:
	var git_data := collect_git_metadata(work_dir)
	ProjectSettings.set_setting(COMMIT_HASH_SETTING, git_data.get("commit_hash", ""))
	ProjectSettings.set_setting(BRANCH_SETTING, git_data.get("branch", ""))
	ProjectSettings.set_setting(TAG_SETTING, git_data.get("tag", ""))
	ProjectSettings.set_setting(COMMIT_COUNT_SETTING, int(git_data.get("commit_count", 0)))
	ProjectSettings.set_setting(IS_DIRTY_SETTING, bool(git_data.get("is_dirty", false)))
	ProjectSettings.set_setting(TIME_UTC_SETTING, git_data.get("build_time_utc", ""))
	if not extra_metadata.is_empty():
		ProjectSettings.set_setting(METADATA_SETTING, extra_metadata.duplicate(true))
	if save_settings:
		ProjectSettings.save()
	return git_data


## 复制构建信息。
## @return 深拷贝后的构建信息。
func duplicate_info() -> GFBuildInfo:
	return GFBuildInfo.from_dict(to_dict())


# --- 私有/辅助方法 ---

static func _get_project_setting_text(path: String) -> String:
	if not ProjectSettings.has_setting(path):
		return ""
	return String(ProjectSettings.get_setting(path, ""))


static func _read_framework_version() -> String:
	var config := ConfigFile.new()
	var error := config.load(FRAMEWORK_PLUGIN_CONFIG_PATH)
	if error != OK:
		return ""
	return String(config.get_value("plugin", "version", ""))


static func _format_engine_version(version_info: Dictionary) -> String:
	var version_text := String(version_info.get("string", ""))
	if not version_text.is_empty():
		return version_text

	var major := String(version_info.get("major", ""))
	var minor := String(version_info.get("minor", ""))
	var patch := String(version_info.get("patch", ""))
	var status := String(version_info.get("status", ""))
	var result := ".".join(PackedStringArray([major, minor, patch]))
	if not status.is_empty():
		result += ".%s" % status
	return result


static func _to_native_path(path: String) -> String:
	if path.begins_with("res://") or path.begins_with("user://"):
		return ProjectSettings.globalize_path(path)
	return path


static func _run_git(native_dir: String, args: Array) -> String:
	var output: Array = []
	var git_args := PackedStringArray(["-C", native_dir])
	for arg: Variant in args:
		git_args.append(String(arg))
	var exit_code := OS.execute("git", git_args, output, true, false)
	if exit_code != OK or output.is_empty():
		return ""
	return String(output[0]).strip_edges()
