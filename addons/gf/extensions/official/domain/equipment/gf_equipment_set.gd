## GFEquipmentSet: 通用槽位集合。
##
## 用于管理一组 `GFEquipmentSlot`，不约束槽位名称或装备类型。
class_name GFEquipmentSet
extends Resource


# --- 导出变量 ---

## 槽位表。Key 推荐为 StringName，Value 应为 GFEquipmentSlot。
@export var slots: Dictionary = {}


# --- 公共方法 ---

## 添加或替换槽位。
## @param slot: 槽位资源。
func set_slot(slot: GFEquipmentSlot) -> void:
	if slot == null or slot.slot_id == &"":
		return
	slots[slot.slot_id] = slot


## 获取槽位。
## @param slot_id: 槽位 ID。
## @return 槽位资源；不存在时返回 null。
func get_slot(slot_id: StringName) -> GFEquipmentSlot:
	return slots.get(slot_id) as GFEquipmentSlot


## 挂载物品到槽位。
## @param slot_id: 槽位 ID。
## @param item_id: 物品 ID。
## @param item_tags: 物品标签。
## @return 成功时返回 true。
func equip(slot_id: StringName, item_id: StringName, item_tags: Array[StringName] = []) -> bool:
	var slot := get_slot(slot_id)
	if slot == null:
		return false
	return slot.equip(item_id, item_tags)


## 清空槽位。
## @param slot_id: 槽位 ID。
func unequip(slot_id: StringName) -> void:
	var slot := get_slot(slot_id)
	if slot != null:
		slot.unequip()


## 获取槽位当前物品。
## @param slot_id: 槽位 ID。
## @return 物品 ID。
func get_equipped_item(slot_id: StringName) -> StringName:
	var slot := get_slot(slot_id)
	if slot == null:
		return &""
	return slot.item_id

