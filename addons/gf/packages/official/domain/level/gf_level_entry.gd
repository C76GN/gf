## GFLevelEntry: 通用关卡目录条目。
##
## 只描述关卡 ID、所属分组、可选场景路径和元数据，不规定关卡玩法规则。
class_name GFLevelEntry
extends Resource


# --- 导出变量 ---

## 关卡稳定 ID。
@export var level_id: StringName = &""

## 可选关卡包或章节 ID。
@export var pack_id: StringName = &""

## 可选关卡场景路径。
@export_file("*.tscn") var scene_path: String = ""

## 目录排序值，数值越小越靠前。
@export var sort_order: int = 0

## 关卡通用元数据。
@export var metadata: Dictionary = {}

## 当前关卡完成后建议解锁的后续关卡 ID。
@export var unlocks_on_complete: Array[StringName] = []


# --- 公共方法 ---

## 获取稳定关卡 ID。
## @return 关卡 ID。
func get_level_id() -> StringName:
	if level_id != &"":
		return level_id
	if not resource_path.is_empty():
		return StringName(resource_path)
	return &""


## 创建条目拷贝。
## @return 新条目。
func duplicate_entry() -> GFLevelEntry:
	var entry := GFLevelEntry.new()
	entry.level_id = level_id
	entry.pack_id = pack_id
	entry.scene_path = scene_path
	entry.sort_order = sort_order
	entry.metadata = metadata.duplicate(true)
	entry.unlocks_on_complete = unlocks_on_complete.duplicate()
	return entry
