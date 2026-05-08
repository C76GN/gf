## GFBuildInfo: 运行时构建信息快照。
##
## 用统一 Resource 承载项目版本、GF 版本、构建号、提交号和运行平台信息，
## 便于诊断、日志、存档元数据或项目自己的版本界面复用。
class_name GFBuildInfo
extends Resource


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
	info.project_name = _get_project_setting_text("application/config/name")
	info.project_version = _get_project_setting_text("application/config/version")
	info.framework_version = _read_framework_version()
	info.build_id = _get_project_setting_text("gf/build/id")
	info.commit_hash = _get_project_setting_text("gf/build/commit_hash")
	info.branch = _get_project_setting_text("gf/build/branch")
	info.build_time_utc = _get_project_setting_text("gf/build/time_utc")
	info.engine_version = _format_engine_version(Engine.get_version_info())
	info.platform_name = OS.get_name()
	info.is_debug_build = OS.is_debug_build()
	var metadata_value: Variant = ProjectSettings.get_setting("gf/build/metadata", {})
	info.metadata = (metadata_value as Dictionary).duplicate(true) if metadata_value is Dictionary else {}
	return info


## 从 Dictionary 创建构建信息。
## @param data: 构建信息字典。
## @return 新构建信息。
static func from_dict(data: Dictionary) -> GFBuildInfo:
	var info := GFBuildInfo.new()
	info.apply_dict(data)
	return info


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
	var error := config.load("res://addons/gf/plugin.cfg")
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
