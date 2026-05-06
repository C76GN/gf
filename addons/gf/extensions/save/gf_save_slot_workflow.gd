## GFSaveSlotWorkflow: 通用存档槽工作流配置。
##
## 负责把槽位索引、逻辑标识、元数据和 UI 卡片摘要串起来。
## 不执行具体存取逻辑，也不写死任何游戏业务字段。
class_name GFSaveSlotWorkflow
extends Resource


# --- 常量 ---

const GFSaveSlotCardBase = preload("res://addons/gf/extensions/save/gf_save_slot_card.gd")
const GFSaveSlotMetadataBase = preload("res://addons/gf/extensions/save/gf_save_slot_metadata.gd")


# --- 导出变量 ---

## 当前选中槽位索引。默认从 1 开始，贴近常见存档 UI。
@export var active_slot_index: int = 1

## 槽位标识模板，支持 {index} 占位符。
@export var slot_id_template: String = "slot_{index}"

## 空槽位展示名模板，支持 {index} 占位符。
@export var empty_display_name_template: String = "Slot {index}"

## 可替换的元数据资源脚本，项目层可继承 GFSaveSlotMetadata 扩展。
@export var metadata_script: Script = GFSaveSlotMetadataBase

## 可替换的卡片资源脚本，项目层可继承 GFSaveSlotCard 扩展。
@export var card_script: Script = GFSaveSlotCardBase

## 槽位角色。用于区分 autosave/manual/cloud 等抽象类别。
@export var slot_role: StringName = &""


# --- 私有变量 ---

var _slot_id_overrides: Dictionary = {}


# --- 公共方法 ---

## 选择当前槽位。
## @param index: 槽位索引。
## @return 当前槽位逻辑标识。
func select_slot_index(index: int) -> StringName:
	active_slot_index = maxi(index, 0)
	return get_active_slot_id()


## 设置指定索引的逻辑标识覆盖。
## @param index: 槽位索引。
## @param slot_id: 逻辑标识。
func set_slot_id_override(index: int, slot_id: StringName) -> void:
	if slot_id == &"":
		_slot_id_overrides.erase(index)
		return
	_slot_id_overrides[index] = slot_id


## 清空逻辑标识覆盖。
func clear_slot_id_overrides() -> void:
	_slot_id_overrides.clear()


## 获取当前槽位逻辑标识。
## @return 槽位标识。
func get_active_slot_id() -> StringName:
	return get_slot_id_for_index(active_slot_index)


## 获取当前 GFStorageUtility 整数槽位。
## @return 整数槽位。
func get_active_storage_slot_id() -> int:
	return active_slot_index


## 获取指定索引的逻辑标识。
## @param index: 槽位索引。
## @return 槽位标识。
func get_slot_id_for_index(index: int) -> StringName:
	if _slot_id_overrides.has(index):
		return _slot_id_overrides[index]
	return StringName(slot_id_template.replace("{index}", str(index)))


## 获取空槽位展示名。
## @param index: 槽位索引。
## @return 展示名。
func get_empty_display_name_for_index(index: int) -> String:
	return empty_display_name_template.replace("{index}", str(index))


## 构建当前槽位元数据。
## @param display_name: 可选展示名。
## @param custom_metadata: 自定义元数据。
## @return 元数据资源。
func build_active_metadata(
	display_name: String = "",
	custom_metadata: Dictionary = {}
) -> GFSaveSlotMetadataBase:
	return build_slot_metadata(active_slot_index, display_name, custom_metadata)


## 构建指定槽位元数据。
## @param index: 槽位索引。
## @param display_name: 可选展示名。
## @param custom_metadata: 自定义元数据。
## @return 元数据资源。
func build_slot_metadata(
	index: int,
	display_name: String = "",
	custom_metadata: Dictionary = {}
) -> GFSaveSlotMetadataBase:
	var metadata := _new_metadata()
	metadata.slot_id = get_slot_id_for_index(index)
	metadata.display_name = display_name if not display_name.is_empty() else get_empty_display_name_for_index(index)
	metadata.custom_metadata = custom_metadata.duplicate(true)
	if slot_role != &"":
		metadata.custom_metadata["slot_role"] = slot_role
	var now := int(Time.get_unix_time_from_system())
	metadata.created_at_unix = now
	metadata.updated_at_unix = now
	return metadata


## 构建空槽位卡片。
## @param index: 槽位索引。
## @return 卡片资源。
func build_empty_card(index: int) -> GFSaveSlotCardBase:
	var card := _new_card()
	card.slot_index = index
	card.slot_id = get_slot_id_for_index(index)
	card.display_name = get_empty_display_name_for_index(index)
	card.is_empty = true
	card.is_active = index == active_slot_index
	return card


## 根据摘要构建槽位卡片。摘要为空时返回空卡片。
## @param index: 槽位索引。
## @param summary: 槽位摘要。
## @param p_active_slot_index: 当前选中索引；小于 0 时使用 active_slot_index。
## @return 卡片资源。
func build_card_for_index(
	index: int,
	summary: Dictionary = {},
	p_active_slot_index: int = -1
) -> GFSaveSlotCardBase:
	if summary.is_empty():
		return build_empty_card(index)

	var card := _new_card()
	var selected_index := active_slot_index if p_active_slot_index < 0 else p_active_slot_index
	card.configure_from_slot_summary(summary, get_slot_id_for_index(index), selected_index)
	if card.slot_index < 0:
		card.slot_index = index
	if card.slot_id == &"":
		card.slot_id = get_slot_id_for_index(index)
	if card.display_name.is_empty():
		card.display_name = get_empty_display_name_for_index(index)
	return card


## 根据索引和摘要列表构建卡片列表。
## @param indices: 槽位索引列表。
## @param summaries: 槽位摘要列表。
## @return 卡片列表。
func build_cards_for_indices(indices: Array, summaries: Array = []) -> Array[GFSaveSlotCardBase]:
	var summary_index := _index_summaries(summaries)
	var result: Array[GFSaveSlotCardBase] = []
	for index_variant: Variant in indices:
		var index := int(index_variant)
		var summary := summary_index.get(index, {}) as Dictionary
		result.append(build_card_for_index(index, summary if summary != null else {}))
	return result


## 从 GFStorageUtility 读取摘要并构建卡片。
## @param storage: 存储工具。
## @param indices: 需要展示的槽位索引；为空时使用已有槽位。
## @return 卡片列表。
func build_cards_from_storage(storage: GFStorageUtility, indices: Array = []) -> Array[GFSaveSlotCardBase]:
	if storage == null:
		return []

	var summaries := storage.list_slots()
	var target_indices := indices.duplicate()
	if target_indices.is_empty():
		for summary: Dictionary in summaries:
			target_indices.append(int(summary.get("slot_id", summary.get("slot_index", 0))))
	return build_cards_for_indices(target_indices, summaries)


# --- 私有/辅助方法 ---

func _new_metadata() -> GFSaveSlotMetadataBase:
	var metadata: Variant = metadata_script.new() if metadata_script != null else GFSaveSlotMetadataBase.new()
	if metadata is GFSaveSlotMetadataBase:
		return metadata as GFSaveSlotMetadataBase
	return GFSaveSlotMetadataBase.new()


func _new_card() -> GFSaveSlotCardBase:
	var card: Variant = card_script.new() if card_script != null else GFSaveSlotCardBase.new()
	if card is GFSaveSlotCardBase:
		return card as GFSaveSlotCardBase
	return GFSaveSlotCardBase.new()


func _index_summaries(summaries: Array) -> Dictionary:
	var result: Dictionary = {}
	for summary_variant: Variant in summaries:
		var summary := summary_variant as Dictionary
		if summary == null:
			continue
		var index := int(summary.get("slot_id", summary.get("slot_index", -1)))
		if index >= 0:
			result[index] = summary
	return result
