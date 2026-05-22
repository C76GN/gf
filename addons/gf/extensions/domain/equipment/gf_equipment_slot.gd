## GFEquipmentSlot: 通用装备/挂载槽位。
##
## 槽位只记录可接受标签和已挂载 item_id，不规定装备类型。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFEquipmentSlot
extends Resource


# --- 导出变量 ---

## 槽位 ID。
## [br]
## @api public
@export var slot_id: StringName = &""

## 当前挂载的物品 ID。
## [br]
## @api public
@export var item_id: StringName = &""

## 接受的物品标签。为空表示不限制。
## [br]
## @api public
## [br]
## @schema accepted_tags: Array[StringName]，槽位接受的物品标签；为空时不限制。
@export var accepted_tags: Array[StringName] = []

## 是否要求物品同时拥有全部 accepted_tags。false 表示拥有任一标签即可。
## [br]
## @api public
@export var require_all_tags: bool = false

## 自定义元数据。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary，项目自定义槽位元数据；GF 不读取或改写其中字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 检查标签是否可被槽位接受。
## [br]
## @api public
## [br]
## @param item_tags: 物品标签。
## [br]
## @return 可接受时返回 true。
## [br]
## @schema item_tags: Array[StringName]，当前物品拥有的标签列表。
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
## [br]
## @api public
## [br]
## @param p_item_id: 物品 ID。
## [br]
## @param item_tags: 物品标签。
## [br]
## @return 成功时返回 true。
## [br]
## @schema item_tags: Array[StringName]，当前物品拥有的标签列表。
func equip(p_item_id: StringName, item_tags: Array[StringName] = []) -> bool:
	if p_item_id == &"" or not can_accept(item_tags):
		return false
	item_id = p_item_id
	return true


## 清空槽位。
## [br]
## @api public
func unequip() -> void:
	item_id = &""
