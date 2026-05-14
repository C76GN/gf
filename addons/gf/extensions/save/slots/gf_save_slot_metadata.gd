## GFSaveSlotMetadata: 通用存档槽元数据。
##
## 只描述槽位、版本、时间、标签和项目自定义字典，不绑定任何具体游戏业务字段。
class_name GFSaveSlotMetadata
extends Resource


# --- 导出变量 ---

## 槽位逻辑标识。可由项目映射到整数槽、文件名或云端 key。
@export var slot_id: StringName = &""

## 展示名称。
@export var display_name: String = ""

## 展示描述。
@export_multiline var description: String = ""

## 存档数据结构标识。
@export var schema_id: StringName = &""

## 存档数据结构版本。
@export_range(1, 999999, 1) var schema_version: int = 1

## 项目版本号。
@export var app_version: String = ""

## 创建时间戳。
@export var created_at_unix: int = 0

## 更新时间戳。
@export var updated_at_unix: int = 0

## 通用游玩时长或业务耗时。
@export var elapsed_seconds: float = 0.0

## 通用标签。
@export var tags: PackedStringArray = PackedStringArray()

## 项目自定义元数据。
@export var custom_metadata: Dictionary = {}


# --- 公共方法 ---

## 转换为 Dictionary。
## @param include_empty: 是否包含空值。
## @return 元数据字典。
func to_dict(include_empty: bool = true) -> Dictionary:
	var result := {
		"slot_id": slot_id,
		"display_name": display_name,
		"description": description,
		"schema_id": schema_id,
		"schema_version": schema_version,
		"app_version": app_version,
		"created_at_unix": created_at_unix,
		"updated_at_unix": updated_at_unix,
		"elapsed_seconds": elapsed_seconds,
		"tags": tags,
		"custom_metadata": custom_metadata.duplicate(true),
	}
	if include_empty:
		return result

	for key: Variant in result.keys():
		if _is_empty_metadata_value(result[key]):
			result.erase(key)
	return result


## 转换为只包含非空值的补丁字典。
## @return 补丁字典。
func to_patch_dict() -> Dictionary:
	return to_dict(false)


## 应用字典数据。
## @param data: 元数据字典。
func apply_dict(data: Dictionary) -> void:
	if data.has("slot_id"):
		slot_id = StringName(data["slot_id"])
	if data.has("display_name"):
		display_name = String(data["display_name"])
	if data.has("description"):
		description = String(data["description"])
	if data.has("schema_id"):
		schema_id = StringName(data["schema_id"])
	if data.has("schema_version"):
		schema_version = maxi(int(data["schema_version"]), 1)
	if data.has("app_version"):
		app_version = String(data["app_version"])
	if data.has("created_at_unix"):
		created_at_unix = int(data["created_at_unix"])
	if data.has("updated_at_unix"):
		updated_at_unix = int(data["updated_at_unix"])
	if data.has("elapsed_seconds"):
		elapsed_seconds = maxf(float(data["elapsed_seconds"]), 0.0)
	if data.has("tags"):
		tags = _to_string_array(data["tags"])
	if data.has("custom_metadata"):
		var custom := data["custom_metadata"] as Dictionary
		custom_metadata = custom.duplicate(true) if custom != null else {}


## 创建深拷贝。
## @return 新元数据。
func duplicate_metadata() -> GFSaveSlotMetadata:
	return GFSaveSlotMetadata.from_dict(to_dict(true))


## 获取展示名称，允许调用方提供兜底文本。
## @param fallback: 兜底文本。
## @return 展示名称。
func get_display_name(fallback: String = "") -> String:
	if not display_name.is_empty():
		return display_name
	return fallback


## 校验元数据的通用结构。
## @return 诊断报告。
func validate_metadata() -> Dictionary:
	var issues: Array[Dictionary] = []
	if slot_id == &"":
		issues.append({ "severity": "warning", "kind": "empty_slot_id", "message": "Slot id is empty." })
	if schema_version <= 0:
		issues.append({ "severity": "error", "kind": "invalid_schema_version", "message": "Schema version must be positive." })
	if elapsed_seconds < 0.0:
		issues.append({ "severity": "error", "kind": "invalid_elapsed_seconds", "message": "Elapsed seconds cannot be negative." })
	return {
		"ok": _has_no_error_issues(issues),
		"issues": issues,
	}


## 从 Dictionary 创建元数据。
## @param data: 元数据字典。
## @return 新元数据。
static func from_dict(data: Dictionary) -> GFSaveSlotMetadata:
	var metadata := GFSaveSlotMetadata.new()
	metadata.apply_dict(data)
	return metadata


## 使用常用字段创建元数据。
## @param p_slot_id: 槽位标识。
## @param p_display_name: 展示名称。
## @param p_custom_metadata: 自定义元数据。
## @return 新元数据。
static func from_values(
	p_slot_id: StringName,
	p_display_name: String = "",
	p_custom_metadata: Dictionary = {}
) -> GFSaveSlotMetadata:
	var metadata := GFSaveSlotMetadata.new()
	metadata.slot_id = p_slot_id
	metadata.display_name = p_display_name
	metadata.custom_metadata = p_custom_metadata.duplicate(true)
	var now := int(Time.get_unix_time_from_system())
	metadata.created_at_unix = now
	metadata.updated_at_unix = now
	return metadata


# --- 私有/辅助方法 ---

func _is_empty_metadata_value(value: Variant) -> bool:
	if value == null:
		return true
	if value is String or value is StringName:
		return String(value).is_empty()
	if value is Array or value is PackedStringArray:
		return value.is_empty()
	if value is Dictionary:
		return (value as Dictionary).is_empty()
	if value is int or value is float:
		return float(value) == 0.0
	return false


func _to_string_array(value: Variant) -> PackedStringArray:
	if value is PackedStringArray:
		return value

	var result := PackedStringArray()
	if value is Array:
		for item: Variant in value:
			result.append(String(item))
	return result


func _has_no_error_issues(issues: Array[Dictionary]) -> bool:
	for issue: Dictionary in issues:
		if String(issue.get("severity", "")) == "error":
			return false
	return true
