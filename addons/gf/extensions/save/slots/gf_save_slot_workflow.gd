## GFSaveSlotWorkflow: 通用存档槽工作流配置。
##
## 负责把槽位索引、逻辑标识、元数据和槽位摘要 DTO 串起来。
## 不执行具体存取逻辑，也不写死任何游戏业务字段。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFSaveSlotWorkflow
extends Resource


# --- 常量 ---

const _GF_SAVE_SLOT_CARD_SCRIPT: Script = preload("res://addons/gf/extensions/save/slots/gf_save_slot_card.gd")
const _GF_SAVE_SLOT_METADATA_SCRIPT: Script = preload("res://addons/gf/extensions/save/slots/gf_save_slot_metadata.gd")


# --- 导出变量 ---

## 当前选中槽位索引。仅用于构建摘要时标记 active。
## [br]
## @api public
@export var active_slot_index: int = 0

## 槽位标识模板，支持 {index} 占位符。
## [br]
## @api public
@export var slot_id_template: String = "slot_{index}"

## 空槽位展示名模板，支持 {index} 占位符。默认为空，由项目按 UI 与本地化需要显式设置。
## [br]
## @api public
@export var empty_display_name_template: String = ""

## 可替换的元数据资源脚本，项目层可继承 GFSaveSlotMetadata 扩展。
## [br]
## @api public
@export var metadata_script: Script = _GF_SAVE_SLOT_METADATA_SCRIPT

## 可替换的卡片资源脚本，项目层可继承 GFSaveSlotCard 扩展。
## [br]
## @api public
@export var card_script: Script = _GF_SAVE_SLOT_CARD_SCRIPT

## 槽位角色。用于区分 autosave/manual/cloud 等抽象类别。
## [br]
## @api public
@export var slot_role: StringName = &""


# --- 私有变量 ---

var _slot_id_overrides: Dictionary = {}


# --- 公共方法 ---

## 选择当前槽位。
## [br]
## @api public
## [br]
## @param index: 槽位索引。
## [br]
## @return 当前槽位逻辑标识。
func select_slot_index(index: int) -> StringName:
	active_slot_index = maxi(index, 0)
	return get_active_slot_id()


## 设置指定索引的逻辑标识覆盖。
## [br]
## @api public
## [br]
## @param index: 槽位索引。
## [br]
## @param slot_id: 逻辑标识。
func set_slot_id_override(index: int, slot_id: StringName) -> void:
	if slot_id == &"":
		_slot_id_overrides.erase(index)
		return
	_slot_id_overrides[index] = slot_id


## 清空逻辑标识覆盖。
## [br]
## @api public
func clear_slot_id_overrides() -> void:
	_slot_id_overrides.clear()


## 获取当前槽位逻辑标识。
## [br]
## @api public
## [br]
## @return 槽位标识。
func get_active_slot_id() -> StringName:
	return get_slot_id_for_index(active_slot_index)


## 获取当前 GFStorageUtility 整数槽位。
## [br]
## @api public
## [br]
## @return 整数槽位。
func get_active_storage_slot_id() -> int:
	return active_slot_index


## 获取指定索引的逻辑标识。
## [br]
## @api public
## [br]
## @param index: 槽位索引。
## [br]
## @return 槽位标识。
func get_slot_id_for_index(index: int) -> StringName:
	if _slot_id_overrides.has(index):
		return _slot_id_overrides[index]
	return StringName(slot_id_template.replace("{index}", str(index)))


## 获取空槽位展示名。
## [br]
## @api public
## [br]
## @param index: 槽位索引。
## [br]
## @return 展示名。
func get_empty_display_name_for_index(index: int) -> String:
	return empty_display_name_template.replace("{index}", str(index))


## 构建当前槽位元数据。
## [br]
## @api public
## [br]
## @param display_name: 可选展示名。
## [br]
## @param custom_metadata: 自定义元数据。
## [br]
## @return 元数据资源。
## [br]
## @schema custom_metadata: Dictionary，会写入 GFSaveSlotMetadata.custom_metadata；slot_role 非空时会额外写入 slot_role。
func build_active_metadata(
	display_name: String = "",
	custom_metadata: Dictionary = {}
) -> GFSaveSlotMetadata:
	return build_slot_metadata(active_slot_index, display_name, custom_metadata)


## 构建指定槽位元数据。
## [br]
## @api public
## [br]
## @param index: 槽位索引。
## [br]
## @param display_name: 可选展示名。
## [br]
## @param custom_metadata: 自定义元数据。
## [br]
## @return 元数据资源。
## [br]
## @schema custom_metadata: Dictionary，会写入 GFSaveSlotMetadata.custom_metadata；slot_role 非空时会额外写入 slot_role。
func build_slot_metadata(
	index: int,
	display_name: String = "",
	custom_metadata: Dictionary = {}
) -> GFSaveSlotMetadata:
	var metadata := _new_metadata()
	metadata.slot_id = get_slot_id_for_index(index)
	var resolved_display_name := display_name
	if resolved_display_name.is_empty():
		resolved_display_name = get_empty_display_name_for_index(index)
	metadata.display_name = resolved_display_name
	metadata.custom_metadata = custom_metadata.duplicate(true)
	if slot_role != &"":
		metadata.custom_metadata["slot_role"] = slot_role
	var now := int(Time.get_unix_time_from_system())
	metadata.created_at_unix = now
	metadata.updated_at_unix = now
	return metadata


## 构建空槽位卡片。
## [br]
## @api public
## [br]
## @param index: 槽位索引。
## [br]
## @return 卡片资源。
func build_empty_card(index: int) -> GFSaveSlotCard:
	var card := _new_card()
	card.slot_index = index
	card.slot_id = get_slot_id_for_index(index)
	card.display_name = get_empty_display_name_for_index(index)
	card.is_empty = true
	card.is_active = index == active_slot_index
	return card


## 根据摘要构建槽位卡片。摘要为空时返回空卡片。
## [br]
## @api public
## [br]
## @param index: 槽位索引。
## [br]
## @param summary: 槽位摘要。
## [br]
## @param p_active_slot_index: 当前选中索引；小于 0 时使用 active_slot_index。
## [br]
## @return 卡片资源。
## [br]
## @schema summary: Dictionary，可包含 slot_index、slot_id、modified_time、is_compatible、compatibility_errors 与 metadata。
func build_card_for_index(
	index: int,
	summary: Dictionary = {},
	p_active_slot_index: int = -1
) -> GFSaveSlotCard:
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
## [br]
## @api public
## [br]
## @param indices: 槽位索引列表。
## [br]
## @param summaries: 槽位摘要列表。
## [br]
## @return 卡片列表。
## [br]
## @schema indices: Array，元素为可转换为 int 的槽位索引。
## [br]
## @schema summaries: Array，每项为 GFStorageUtility.list_slots() 风格的 Dictionary 摘要。
func build_cards_for_indices(indices: Array, summaries: Array = []) -> Array[GFSaveSlotCard]:
	var summary_index := _index_summaries(summaries)
	var result: Array[GFSaveSlotCard] = []
	for index_variant: Variant in indices:
		var index := int(index_variant)
		var summary := summary_index.get(index, {}) as Dictionary
		result.append(build_card_for_index(index, summary if summary != null else {}))
	return result


## 从 GFStorageUtility 读取摘要并构建卡片。
## [br]
## @api public
## [br]
## @param storage: 存储工具。
## [br]
## @param indices: 需要展示的槽位索引；为空时使用已有槽位。
## [br]
## @return 卡片列表。
## [br]
## @schema indices: Array，元素为可转换为 int 的槽位索引。
func build_cards_from_storage(storage: GFStorageUtility, indices: Array = []) -> Array[GFSaveSlotCard]:
	if storage == null:
		return []

	var summaries := storage.list_slots()
	var target_indices := indices.duplicate()
	if target_indices.is_empty():
		for summary: Dictionary in summaries:
			var summary_index := _get_summary_slot_index(summary)
			if summary_index >= 0:
				target_indices.append(summary_index)
	return build_cards_for_indices(target_indices, summaries)


# --- 私有/辅助方法 ---

func _new_metadata() -> GFSaveSlotMetadata:
	var metadata: Variant = metadata_script.new() if metadata_script != null else GFSaveSlotMetadata.new()
	if metadata is GFSaveSlotMetadata:
		return metadata as GFSaveSlotMetadata
	return GFSaveSlotMetadata.new()


func _new_card() -> GFSaveSlotCard:
	var card: Variant = card_script.new() if card_script != null else GFSaveSlotCard.new()
	if card is GFSaveSlotCard:
		return card as GFSaveSlotCard
	return GFSaveSlotCard.new()


func _index_summaries(summaries: Array) -> Dictionary:
	var result: Dictionary = {}
	for summary_variant: Variant in summaries:
		var summary := summary_variant as Dictionary
		if summary == null:
			continue
		var index := _get_summary_slot_index(summary)
		if index >= 0:
			result[index] = summary
	return result


func _get_summary_slot_index(summary: Dictionary) -> int:
	if summary.has("slot_index"):
		return int(summary.get("slot_index", -1))

	var slot_id: Variant = summary.get("slot_id", null)
	if slot_id == null:
		return -1
	if slot_id is int or slot_id is float:
		return int(slot_id)

	var slot_id_text := String(slot_id)
	if slot_id_text.is_valid_int():
		return slot_id_text.to_int()
	return _parse_slot_index_from_id(slot_id_text)


func _parse_slot_index_from_id(slot_id: String) -> int:
	var marker := "{index}"
	var marker_index := slot_id_template.find(marker)
	if marker_index >= 0:
		var prefix := slot_id_template.substr(0, marker_index)
		var suffix := slot_id_template.substr(marker_index + marker.length())
		if slot_id.begins_with(prefix) and slot_id.ends_with(suffix):
			var index_text := slot_id.trim_prefix(prefix).trim_suffix(suffix)
			if index_text.is_valid_int():
				return index_text.to_int()

	var digits := ""
	for i in range(slot_id.length() - 1, -1, -1):
		var character := slot_id.substr(i, 1)
		if not character.is_valid_int():
			break
		digits = character + digits
	if digits.is_valid_int():
		return digits.to_int()
	return -1
