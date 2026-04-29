## 测试通用领域扩展中的特征、库存与槽位集合。
extends GutTest


# --- 测试方法 ---

## 验证特征集合按优先级合并数值。
func test_trait_set_calculates_number() -> void:
	var trait_set := GFTraitSet.new()

	var add_trait := GFTrait.new()
	add_trait.target_id = &"power"
	add_trait.value = 5.0
	add_trait.combine_mode = GFTrait.CombineMode.ADD
	add_trait.priority = 0

	var multiply_trait := GFTrait.new()
	multiply_trait.target_id = &"power"
	multiply_trait.value = 2.0
	multiply_trait.combine_mode = GFTrait.CombineMode.MULTIPLY
	multiply_trait.priority = 1

	trait_set.add_trait(multiply_trait)
	trait_set.add_trait(add_trait)

	assert_eq(trait_set.calculate_number(&"power", 10.0), 30.0, "应先加值再乘值。")


## 验证库存模型可增减、序列化和恢复。
func test_inventory_model_serializes_items() -> void:
	var inventory := GFInventoryModel.new()
	inventory.add_item(&"item_a", 2, { "tag": "test" })
	inventory.add_item(&"item_a", 3)

	assert_eq(inventory.get_item_amount(&"item_a"), 5, "同一 item_id 应堆叠数量。")
	assert_true(inventory.remove_item(&"item_a", 4), "数量足够时应允许移除。")
	assert_eq(inventory.get_item_amount(&"item_a"), 1, "移除后数量应更新。")

	var restored := GFInventoryModel.new()
	restored.from_dict(inventory.to_dict())

	assert_eq(restored.get_item_amount(&"item_a"), 1, "恢复后数量应一致。")
	assert_eq(restored.get_item_metadata(&"item_a").get("tag"), "test", "恢复后元数据应一致。")


## 验证槽位集合按标签规则挂载物品。
func test_equipment_set_checks_slot_tags() -> void:
	var slot := GFEquipmentSlot.new()
	slot.slot_id = &"slot_a"
	slot.accepted_tags = [&"usable", &"rare"]
	slot.require_all_tags = true

	var equipment := GFEquipmentSet.new()
	equipment.set_slot(slot)

	var incomplete_tags: Array[StringName] = [&"usable"]
	var complete_tags: Array[StringName] = [&"usable", &"rare"]

	assert_false(equipment.equip(&"slot_a", &"item_a", incomplete_tags), "缺少任一必需标签时不应挂载。")
	assert_true(equipment.equip(&"slot_a", &"item_a", complete_tags), "满足全部标签时应挂载。")
	assert_eq(equipment.get_equipped_item(&"slot_a"), &"item_a", "挂载后应能读取 item_id。")

	equipment.unequip(&"slot_a")

	assert_eq(equipment.get_equipped_item(&"slot_a"), &"", "卸载后槽位应为空。")
