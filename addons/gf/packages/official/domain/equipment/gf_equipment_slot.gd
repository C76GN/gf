## GFEquipmentSlot: 通用装备/挂载槽位。
##
## 槽位只记录可接受标签和已挂载 item_id，不规定装备类型。
class_name GFEquipmentSlot
extends Resource


# --- 导出变量 ---

## 槽位 ID。
@export var slot_id: StringName = &""

## 当前挂载的物品 ID。
@export var item_id: StringName = &""

## 接受的物品标签。为空表示不限制。
@export var accepted_tags: Array[StringName] = []

## 是否要求物品同时拥有全部 accepted_tags。false 表示拥有任一标签即可。
@export var require_all_tags: bool = false

## 自定义元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 检查标签是否可被槽位接受。
## @param item_tags: 物品标签。
## @return 可接受时返回 true。
func can_accept(item_tags: Array[StringName]) -> bool:
	if accepted_tags.is_empty():
		return true

	if require_all_tags:
		for tag: StringName in accepted_tags:
			if not item_tags.has(tag):
				return false
		return true

	for tag: StringName in accepted_tags:
		if item_tags.has(tag):
			return true
	return false


## 挂载物品。
## @param p_item_id: 物品 ID。
## @param item_tags: 物品标签。
## @return 成功时返回 true。
func equip(p_item_id: StringName, item_tags: Array[StringName] = []) -> bool:
	if p_item_id == &"" or not can_accept(item_tags):
		return false
	item_id = p_item_id
	return true


## 清空槽位。
func unequip() -> void:
	item_id = &""

