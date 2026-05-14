## GFExtensionManifest: GF 扩展元数据描述。
##
## 用于描述 GF 扩展的稳定 ID、版本、依赖、安装入口和编辑器扩展。
class_name GFExtensionManifest
extends RefCounted


# --- 常量 ---

## GF 扩展 manifest 文件名。
const FILE_NAME: String = "gf_extension.json"

## 扩展类型：GF 标准库内置能力。
const KIND_STANDARD: String = "standard"

## 扩展类型：GF 可选扩展。
const KIND_EXTENSION: String = "extension"


# --- 公共变量 ---

## 稳定扩展 ID，推荐格式为反向域名或作者命名空间，例如 `author.extension_name`。
var id: String = ""

## 面向用户显示的扩展名。
var display_name: String = ""

## 扩展发行版本号。GF 内置扩展必须与当前 GF 发行版本一致。
var version: String = ""

## 扩展自身版本号。GF 内置扩展按扩展内公开行为变化独立递增；未声明时回退到 version。
var extension_version: String = "":
	set(value):
		extension_version = value
		_has_extension_version = true

## 扩展类型，应为 `standard` 或 `extension`。
var kind: String = KIND_EXTENSION

## 扩展根目录。
var root_path: String = ""

## 简短说明。
var description: String = ""

## 依赖的扩展 ID 列表。
var dependencies: Array[String] = []

## 可选 GFInstaller 路径列表。需要自动装配运行时模块时使用。
var installer_paths: Array[String] = []

## 可选编辑器菜单动作脚本路径列表。
var editor_action_paths: Array[String] = []

## 可选编辑器工作区页面脚本路径列表。
var editor_dock_paths: Array[String] = []

## 可选 EditorInspectorPlugin 路径列表。需要为扩展内类型提供 Inspector 增强时使用。
var editor_inspector_paths: Array[String] = []

## 可选 EditorExportPlugin 路径列表。
var export_plugin_paths: Array[String] = []

## 可选 GFAccessGenerator 扩展脚本路径列表。
var access_generator_extension_paths: Array[String] = []

## 便于工具筛选的标签。
var tags: Array[String] = []

## 是否在项目首次启用 GF 时默认启用该扩展。
var enabled_by_default: bool = false

## manifest 文件路径。
var source_path: String = ""


# --- 私有变量 ---

var _has_extension_version: bool = false


# --- 公共方法 ---

## 从字典创建扩展 manifest。
## @param data: manifest 字典。
## @param extension_root_path: 扩展根目录。
## @param manifest_source_path: manifest 文件路径。
## @return 扩展 manifest 实例。
static func from_dictionary(
	data: Dictionary,
	extension_root_path: String = "",
	manifest_source_path: String = ""
) -> GFExtensionManifest:
	var manifest := GFExtensionManifest.new()
	manifest.id = String(data.get("id", ""))
	manifest.display_name = String(data.get("display_name", data.get("name", "")))
	manifest.version = String(data.get("version", ""))
	manifest.extension_version = String(data.get("extension_version", manifest.version))
	manifest._has_extension_version = data.has("extension_version")
	manifest.kind = String(data.get("kind", KIND_EXTENSION)).strip_edges()
	if manifest.kind.is_empty():
		manifest.kind = KIND_EXTENSION
	manifest.root_path = extension_root_path
	manifest.description = String(data.get("description", data.get("summary", "")))
	manifest.dependencies = _to_string_array(data.get("dependencies", []))
	manifest.installer_paths = _to_string_array(data.get("installer_paths", []))
	manifest.editor_action_paths = _to_string_array(data.get("editor_action_paths", []))
	manifest.editor_dock_paths = _to_string_array(data.get("editor_dock_paths", []))
	manifest.editor_inspector_paths = _to_string_array(data.get("editor_inspector_paths", []))
	manifest.export_plugin_paths = _to_string_array(data.get("export_plugin_paths", []))
	manifest.access_generator_extension_paths = _to_string_array(data.get("access_generator_extension_paths", []))
	manifest.tags = _to_string_array(data.get("tags", []))
	manifest.enabled_by_default = bool(data.get(
		"enabled_by_default",
		manifest.kind == KIND_STANDARD or manifest.kind == KIND_EXTENSION
	))
	manifest.source_path = manifest_source_path
	return manifest


## 从 JSON 文件读取扩展 manifest。
## @param path: `gf_extension.json` 文件路径。
## @return 读取成功时返回 manifest；失败时返回 null。
static func from_json_file(path: String) -> GFExtensionManifest:
	if path.is_empty():
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null

	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return null

	return from_dictionary(parsed as Dictionary, path.get_base_dir(), path)


## 转换为字典。
## @return manifest 字典副本。
func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"version": version,
		"extension_version": extension_version,
		"kind": kind,
		"root_path": root_path,
		"description": description,
		"dependencies": dependencies.duplicate(),
		"installer_paths": installer_paths.duplicate(),
		"editor_action_paths": editor_action_paths.duplicate(),
		"editor_dock_paths": editor_dock_paths.duplicate(),
		"editor_inspector_paths": editor_inspector_paths.duplicate(),
		"export_plugin_paths": export_plugin_paths.duplicate(),
		"access_generator_extension_paths": access_generator_extension_paths.duplicate(),
		"tags": tags.duplicate(),
		"enabled_by_default": enabled_by_default,
		"source_path": source_path,
	}


## 检查 manifest 是否满足基本规范。
## @return 满足规范时返回 true。
func is_valid() -> bool:
	return get_validation_errors().is_empty()


## 获取 manifest 规范错误。
## @return 错误消息列表。
func get_validation_errors() -> Array[String]:
	var errors: Array[String] = []
	if id.strip_edges().is_empty():
		errors.append("id is required")
	if display_name.strip_edges().is_empty():
		errors.append("display_name is required")
	if version.strip_edges().is_empty():
		errors.append("version is required")
	if not [KIND_STANDARD, KIND_EXTENSION].has(kind):
		errors.append("kind must be standard or extension")
	if root_path.strip_edges().is_empty():
		errors.append("root_path is required")
	_append_resource_path_errors(errors, "installer_paths", installer_paths)
	_append_resource_path_errors(errors, "editor_action_paths", editor_action_paths)
	_append_resource_path_errors(errors, "editor_dock_paths", editor_dock_paths)
	_append_resource_path_errors(errors, "editor_inspector_paths", editor_inspector_paths)
	_append_resource_path_errors(errors, "export_plugin_paths", export_plugin_paths)
	_append_resource_path_errors(errors, "access_generator_extension_paths", access_generator_extension_paths)
	return errors


# --- 私有/辅助方法 ---

func _append_resource_path_errors(
	errors: Array[String],
	property_name: String,
	paths: Array[String]
) -> void:
	for path: String in paths:
		var normalized_path := path.strip_edges()
		if normalized_path.is_empty():
			errors.append("%s contains empty path" % property_name)
			continue
		if not normalized_path.begins_with("res://"):
			errors.append("%s path must be res://: %s" % [property_name, normalized_path])
			continue
		if not _path_is_under_root(normalized_path):
			errors.append("%s path must stay under root_path: %s" % [property_name, normalized_path])


func _path_is_under_root(path: String) -> bool:
	var normalized_root := root_path.strip_edges().trim_suffix("/")
	if normalized_root.is_empty():
		return true
	return path == normalized_root or path.begins_with(normalized_root + "/")


static func _to_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is PackedStringArray:
		for item: String in value:
			result.append(item)
		return result
	if value is Array:
		for item: Variant in value:
			if typeof(item) == TYPE_STRING or item is StringName:
				result.append(String(item))
	return result
