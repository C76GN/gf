## GFInventoryModel: 通用可序列化库存模型。
##
## 只管理 item_id、数量和元数据，不假设道具类型、品质、装备等业务概念。
class_name GFInventoryModel
extends GFModel


# --- 私有变量 ---

var _stacks: Dictionary = {}


# --- 公共方法 ---

## 添加物品数量。
## @param item_id: 物品 ID。
## @param amount: 增加数量。
## @param metadata: 可选元数据；首次加入时保存。
func add_item(item_id: StringName, amount: int = 1, metadata: Dictionary = {}) -> void:
	if item_id == &"" or amount <= 0:
		return

	var stack := _stacks.get(item_id, {}) as Dictionary
	stack["amount"] = int(stack.get("amount", 0)) + amount
	if not stack.has("metadata"):
		stack["metadata"] = metadata.duplicate(true)
	_stacks[item_id] = stack


## 移除物品数量。
## @param item_id: 物品 ID。
## @param amount: 移除数量。
## @return 成功移除完整数量时返回 true。
func remove_item(item_id: StringName, amount: int = 1) -> bool:
	if item_id == &"" or amount <= 0 or not _stacks.has(item_id):
		return false

	var stack := _stacks[item_id] as Dictionary
	var current_amount := int(stack.get("amount", 0))
	if current_amount < amount:
		return false

	current_amount -= amount
	if current_amount <= 0:
		_stacks.erase(item_id)
	else:
		stack["amount"] = current_amount
		_stacks[item_id] = stack
	return true


## 设置物品数量。
## @param item_id: 物品 ID。
## @param amount: 新数量；小于等于 0 时移除。
func set_item_amount(item_id: StringName, amount: int) -> void:
	if item_id == &"":
		return
	if amount <= 0:
		_stacks.erase(item_id)
		return

	var stack := _stacks.get(item_id, {}) as Dictionary
	stack["amount"] = amount
	if not stack.has("metadata"):
		stack["metadata"] = {}
	_stacks[item_id] = stack


## 获取物品数量。
## @param item_id: 物品 ID。
## @return 数量。
func get_item_amount(item_id: StringName) -> int:
	if not _stacks.has(item_id):
		return 0
	return int((_stacks[item_id] as Dictionary).get("amount", 0))


## 检查是否拥有足够数量。
## @param item_id: 物品 ID。
## @param amount: 需要数量。
## @return 足够时返回 true。
func has_item(item_id: StringName, amount: int = 1) -> bool:
	return get_item_amount(item_id) >= amount


## 获取物品元数据。
## @param item_id: 物品 ID。
## @return 元数据副本。
func get_item_metadata(item_id: StringName) -> Dictionary:
	if not _stacks.has(item_id):
		return {}
	return ((_stacks[item_id] as Dictionary).get("metadata", {}) as Dictionary).duplicate(true)


## 获取库存快照。
## @return 库存字典副本。
func get_items() -> Dictionary:
	return _stacks.duplicate(true)


## 清空库存。
func clear() -> void:
	_stacks.clear()


## 序列化库存状态。
## @return 可写入存档的字典。
func to_dict() -> Dictionary:
	var serialized: Dictionary = {}
	for item_id: StringName in _stacks:
		serialized[String(item_id)] = (_stacks[item_id] as Dictionary).duplicate(true)
	return { "items": serialized }


## 从字典恢复库存状态。
## @param data: 序列化数据。
func from_dict(data: Dictionary) -> void:
	_stacks.clear()
	var raw_items := data.get("items", {}) as Dictionary
	for key: Variant in raw_items:
		var item_id := StringName(String(key))
		var stack := raw_items[key] as Dictionary
		_stacks[item_id] = stack.duplicate(true)
