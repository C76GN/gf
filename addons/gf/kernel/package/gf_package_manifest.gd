## GFPackageManifest: GF 包元数据描述。
##
## 用于描述官方包或社区包的稳定 ID、版本、依赖和可选安装入口。
class_name GFPackageManifest
extends RefCounted


# --- 常量 ---

## GF 包 manifest 文件名。
const FILE_NAME: String = "gf_package.json"

## 包类型：GF 标准库内置能力。
const KIND_STANDARD: String = "standard"

## 包类型：随 GF 发布的官方包。
const KIND_OFFICIAL: String = "official"

## 包类型：社区包或项目本地包。
const KIND_COMMUNITY: String = "community"


# --- 公共变量 ---

## 稳定包 ID，推荐格式为 `gf.official.combat` 或 `author.package_name`。
var id: String = ""

## 面向用户显示的包名。
var display_name: String = ""

## 包版本号。
var version: String = ""

## 包类型，应为 `standard`、`official` 或 `community`。
var kind: String = KIND_COMMUNITY

## 包根目录。
var root_path: String = ""

## 简短说明。
var description: String = ""

## 依赖的包 ID 列表。
var dependencies: Array[String] = []

## 可选 GFInstaller 路径列表。需要自动装配运行时模块时使用。
var installer_paths: Array[String] = []

## 便于工具筛选的标签。
var tags: Array[String] = []

## 是否在项目首次启用 GF 时默认启用该包。
var enabled_by_default: bool = false

## manifest 文件路径。
var source_path: String = ""


# --- 公共方法 ---

## 从字典创建包 manifest。
## @param data: manifest 字典。
## @param package_root_path: 包根目录。
## @param manifest_source_path: manifest 文件路径。
## @return 包 manifest 实例。
static func from_dictionary(
	data: Dictionary,
	package_root_path: String = "",
	manifest_source_path: String = ""
) -> GFPackageManifest:
	var manifest := GFPackageManifest.new()
	manifest.id = String(data.get("id", ""))
	manifest.display_name = String(data.get("display_name", data.get("name", "")))
	manifest.version = String(data.get("version", ""))
	manifest.kind = String(data.get("kind", KIND_COMMUNITY))
	manifest.root_path = package_root_path
	manifest.description = String(data.get("description", data.get("summary", "")))
	manifest.dependencies = _to_string_array(data.get("dependencies", []))
	manifest.installer_paths = _to_string_array(data.get("installer_paths", []))
	manifest.tags = _to_string_array(data.get("tags", []))
	manifest.enabled_by_default = bool(data.get(
		"enabled_by_default",
		manifest.kind == KIND_STANDARD or manifest.kind == KIND_OFFICIAL
	))
	manifest.source_path = manifest_source_path
	return manifest


## 从 JSON 文件读取包 manifest。
## @param path: `gf_package.json` 文件路径。
## @return 读取成功时返回 manifest；失败时返回 null。
static func from_json_file(path: String) -> GFPackageManifest:
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
		"kind": kind,
		"root_path": root_path,
		"description": description,
		"dependencies": dependencies.duplicate(),
		"installer_paths": installer_paths.duplicate(),
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
	if not [KIND_STANDARD, KIND_OFFICIAL, KIND_COMMUNITY].has(kind):
		errors.append("kind must be standard, official, or community")
	if root_path.strip_edges().is_empty():
		errors.append("root_path is required")
	return errors


# --- 私有/辅助方法 ---

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
