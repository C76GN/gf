## GFSaveSlotCard: 通用存档槽展示卡片数据。
##
## 作为 UI 和存档系统之间的轻量 DTO，不规定具体界面布局或业务字段。
class_name GFSaveSlotCard
extends Resource


# --- 导出变量 ---

## 整数槽位索引。文件名/云端 key 场景可保持为 -1。
@export var slot_index: int = -1

## 逻辑槽位标识。
@export var slot_id: StringName = &""

## 展示名称。
@export var display_name: String = ""

## 展示描述。
@export_multiline var description: String = ""

## 是否为空槽位。
@export var is_empty: bool = true

## 是否为当前选中槽位。
@export var is_active: bool = false

## 是否兼容当前项目版本或数据结构。
@export var is_compatible: bool = true

## 最近修改时间戳。
@export var modified_time: int = 0

## 原始元数据副本。
@export var metadata: Dictionary = {}

## 兼容性问题列表。
@export var compatibility_errors: PackedStringArray = PackedStringArray()


# --- 公共方法 ---

## 从 GFStorageUtility.list_slots() 风格的摘要配置卡片。
## @param summary: 槽位摘要。
## @param fallback_slot_id: 摘要缺少 slot_id 时的兜底标识。
## @param active_slot_index: 当前选中槽位索引。
## @return 当前卡片。
func configure_from_slot_summary(
	summary: Dictionary,
	fallback_slot_id: StringName = &"",
	active_slot_index: int = -1
) -> GFSaveSlotCard:
	var summary_metadata := summary.get("metadata", {}) as Dictionary
	metadata = summary_metadata.duplicate(true) if summary_metadata != null else {}
	slot_index = int(summary.get("slot_id", summary.get("slot_index", slot_index)))
	slot_id = StringName(metadata.get("slot_id", fallback_slot_id if fallback_slot_id != &"" else str(slot_index)))
	display_name = String(metadata.get("display_name", ""))
	description = String(metadata.get("description", ""))
	modified_time = int(summary.get("modified_time", metadata.get("updated_at_unix", 0)))
	is_empty = false
	is_active = active_slot_index >= 0 and slot_index == active_slot_index
	is_compatible = bool(summary.get("is_compatible", metadata.get("is_compatible", true)))
	compatibility_errors = _to_string_array(summary.get("compatibility_errors", metadata.get("compatibility_errors", [])))
	return self


## 转换为 Dictionary。
## @return 卡片字典。
func to_dict() -> Dictionary:
	return {
		"slot_index": slot_index,
		"slot_id": slot_id,
		"display_name": display_name,
		"description": description,
		"is_empty": is_empty,
		"is_active": is_active,
		"is_compatible": is_compatible,
		"modified_time": modified_time,
		"metadata": metadata.duplicate(true),
		"compatibility_errors": compatibility_errors,
	}


## 获取通用状态文本。
## @return 状态文本。
func get_status_text() -> String:
	if is_empty:
		return "Empty"
	if not is_compatible:
		return "Incompatible"
	if is_active:
		return "Active"
	return "Ready"


## 从摘要创建卡片。
## @param summary: 槽位摘要。
## @param fallback_slot_id: 兜底标识。
## @param active_slot_index: 当前选中槽位索引。
## @return 新卡片。
static func from_slot_summary(
	summary: Dictionary,
	fallback_slot_id: StringName = &"",
	active_slot_index: int = -1
) -> GFSaveSlotCard:
	return GFSaveSlotCard.new().configure_from_slot_summary(summary, fallback_slot_id, active_slot_index)


# --- 私有/辅助方法 ---

func _to_string_array(value: Variant) -> PackedStringArray:
	if value is PackedStringArray:
		return value

	var result := PackedStringArray()
	if value is Array:
		for item: Variant in value:
			result.append(String(item))
	return result
