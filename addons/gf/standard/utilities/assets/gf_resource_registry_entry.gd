## GFResourceRegistryEntry: 通用资源注册表条目。
##
## 用稳定 ID 描述一个可通过 ResourceLoader 读取的资源路径、可选类型提示和可索引字段。
## 条目不解释字段业务含义，只为 GFResourceRegistry 提供数据。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.21.0
class_name GFResourceRegistryEntry
extends Resource


# --- 导出变量 ---

## 条目稳定 ID。推荐使用 StringName，不应把资源路径当作项目逻辑 ID。
## [br]
## @api public
@export var id: StringName = &""

## 资源路径。支持普通 `res://` 路径，也支持 Godot 的 `uid://` 路径。
## [br]
## @api public
@export var path: String = ""

## 可选资源类型提示，会传给 ResourceLoader 或 GFAssetUtility。
## [br]
## @api public
@export var type_hint: String = ""

## 可索引字段。字段值可为单值、Array 或 PackedStringArray。
## [br]
## @api public
## [br]
## @schema fields: Dictionary from field id to scalar, Array, or PackedStringArray values.
@export var fields: Dictionary = {}


# --- 公共方法 ---

## 配置条目并返回自身。
## [br]
## @api public
## [br]
## @param entry_id: 条目稳定 ID。
## [br]
## @param path: 资源路径，支持 `res://` 或 `uid://`。
## [br]
## @param hint: 可选资源类型提示。
## [br]
## @param indexed_fields: 可索引字段。
## [br]
## @schema indexed_fields: Dictionary from field id to scalar, Array, or PackedStringArray values.
## [br]
## @return 当前条目。
func configure(
	entry_id: StringName,
	path: String,
	hint: String = "",
	indexed_fields: Dictionary = {}
) -> Resource:
	id = entry_id
	self.path = path
	type_hint = hint
	fields = indexed_fields.duplicate(true)
	return self


## 检查条目是否包含可用 ID 和资源路径。
## [br]
## @api public
## [br]
## @return 条目可被注册表使用时返回 true。
func is_valid_entry() -> bool:
	return id != &"" and not path.is_empty()


## 创建条目副本。
## [br]
## @api public
## [br]
## @return 条目副本。
func duplicate_entry() -> Resource:
	var entry := get_script().new() as Resource
	entry.set("id", id)
	entry.set("path", path)
	entry.set("type_hint", type_hint)
	entry.set("fields", fields.duplicate(true))
	return entry


## 转换为可序列化字典。
## [br]
## @api public
## [br]
## @return 条目字典。
## [br]
## @schema return: Dictionary with id, resource_path, type_hint, and fields.
func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"path": path,
		"type_hint": type_hint,
		"fields": fields.duplicate(true),
	}


## 从字典创建条目。
## [br]
## @api public
## [br]
## @param data: 条目字典。
## [br]
## @schema data: Dictionary with optional id, resource_path, type_hint, and fields.
## [br]
## @return 新条目。
static func from_dict(data: Dictionary) -> Resource:
	var script := load("res://addons/gf/standard/utilities/assets/gf_resource_registry_entry.gd") as Script
	var entry := script.new() as Resource
	var raw_fields: Variant = data.get("fields", {})
	entry.call(
		"configure",
		StringName(String(data.get("id", ""))),
		String(data.get("resource_path", data.get("path", ""))),
		String(data.get("type_hint", "")),
		raw_fields if raw_fields is Dictionary else {}
	)
	return entry
