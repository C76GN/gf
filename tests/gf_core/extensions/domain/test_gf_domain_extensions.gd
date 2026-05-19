## 测试通用领域扩展中的特征、库存与槽位集合。
extends GutTest


# --- 常量 ---

const GFDerivedAttributeRuleBase = preload("res://addons/gf/extensions/domain/attributes/gf_derived_attribute_rule.gd")


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


## 验证槽位库存遵守堆叠容量、堆叠数量上限与序列化。
func test_slot_inventory_respects_stack_rules_and_serializes() -> void:
	var definition := GFInventoryItemDefinition.new()
	definition.item_id = &"item_a"
	definition.max_stack_amount = 5
	definition.max_stack_count = 2
	definition.stack_key_fields = PackedStringArray(["grade"])

	var registry := GFInventoryItemRegistry.new()
	registry.set_definition(definition)

	var inventory := GFSlotInventoryModel.new()
	inventory.registry = registry
	inventory.set_slot_count(3)

	var result := inventory.add_item(&"item_a", 12, { "grade": "basic" })

	assert_false(result.ok, "容量不足时应返回部分成功。")
	assert_eq(result.accepted_amount, 10, "两个堆叠最多应接受 10 个。")
	assert_eq(result.remaining_amount, 2, "剩余数量应写入操作结果。")
	assert_eq(inventory.get_item_total(&"item_a"), 10, "库存总数应统计全部兼容堆叠。")
	assert_eq(inventory.get_occupied_slot_indices().size(), 2, "应占用两个槽位。")

	var restored := GFSlotInventoryModel.new()
	restored.registry = registry
	restored.from_dict(inventory.to_dict())

	assert_eq(restored.get_slot_count(), 3, "恢复后槽位数量应一致。")
	assert_eq(restored.get_item_total(&"item_a"), 10, "恢复后物品总数应一致。")


func test_inventory_partial_result_normalizes_ok_reason() -> void:
	var partial := GFInventoryOperationResult.partial(&"item_a", 5, 2, &"ok")
	var failed := GFInventoryOperationResult.partial(&"item_a", 5, 0, &"ok")
	var invalid := GFInventoryOperationResult.partial(&"item_a", 0, 0, &"invalid_request")

	assert_false(partial.ok, "未处理完整请求时 ok 应为 false。")
	assert_eq(partial.reason, &"partial", "部分成功不应继续报告 ok 原因。")
	assert_eq(partial.remaining_amount, 3, "部分成功应保留剩余数量。")
	assert_eq(failed.reason, &"failed", "完全未处理且未提供失败原因时应归一化为 failed。")
	assert_false(invalid.ok, "请求数量为 0 的结果不应被误判为成功。")
	assert_eq(invalid.reason, &"invalid_request", "显式失败原因应保留。")


## 验证槽位拆分不会绕过最大堆叠数量上限。
func test_slot_inventory_split_respects_stack_count_limit() -> void:
	var definition := GFInventoryItemDefinition.new()
	definition.item_id = &"item_a"
	definition.max_stack_amount = 10
	definition.max_stack_count = 1

	var registry := GFInventoryItemRegistry.new()
	registry.set_definition(definition)

	var inventory := GFSlotInventoryModel.new()
	inventory.registry = registry
	inventory.set_slot_count(2)
	inventory.add_item_to_slot(0, &"item_a", 5)

	var result := inventory.move_between_slots(0, 1, 2)

	assert_false(result.ok, "拆分会增加堆叠数量时应失败。")
	assert_eq(result.reason, &"stack_count_limit", "失败原因应说明堆叠数量上限。")
	assert_true(inventory.is_slot_empty(1), "失败后目标槽位应保持为空。")


## 验证槽位库存索引与约束报告。
func test_slot_inventory_index_and_constraint_report() -> void:
	var definition := GFInventoryItemDefinition.new()
	definition.item_id = &"item_a"
	definition.max_stack_amount = 5
	definition.max_stack_count = 1
	definition.compatibility_checker = func(left: Dictionary, right: Dictionary, _definition: GFInventoryItemDefinition) -> bool:
		return left.get("variant", "base") == right.get("variant", "base")

	var registry := GFInventoryItemRegistry.new()
	registry.set_definition(definition)

	var inventory := GFSlotInventoryModel.new()
	inventory.registry = registry
	inventory.set_slot_count(3)
	inventory.set_stack(0, GFInventoryStack.new(&"item_a", 5, { "variant": "base" }))
	inventory.set_stack(1, GFInventoryStack.new(&"item_a", 2, { "variant": "rare" }))
	inventory.set_stack(2, GFInventoryStack.new(&"item_a", 8, { "variant": "base" }))

	var base_slots := inventory.get_slots_for_item(&"item_a", { "variant": "base" })
	var report := inventory.validate_inventory()

	assert_eq(base_slots, PackedInt32Array([0, 2]), "索引查询应支持实例数据兼容筛选。")
	assert_false(bool(report["ok"]), "违反注册表约束时应返回失败报告。")
	assert_true(_has_domain_issue_kind(report["issues"] as Array, "stack_amount_exceeds_limit"), "报告应包含单堆叠超限。")
	assert_true(_has_domain_issue_kind(report["issues"] as Array, "stack_count_exceeds_limit"), "报告应包含堆叠数量超限。")


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


## 验证通用属性集合可限制范围、序列化并接入 Trait 计算。
func test_attribute_set_clamps_serializes_and_applies_traits() -> void:
	var attributes := GFAttributeSet.new()
	attributes.define_attribute(&"stamina", 10.0, 8.0, 0.0, 12.0, { "group": "core" })
	attributes.adjust_value(&"stamina", 10.0)

	assert_eq(attributes.get_value(&"stamina"), 12.0, "属性当前值应被范围限制。")

	var stamina_trait := GFTrait.new()
	stamina_trait.target_id = &"stamina"
	stamina_trait.value = 3.0
	stamina_trait.combine_mode = GFTrait.CombineMode.ADD
	var traits := GFTraitSet.new()
	traits.add_trait(stamina_trait)

	assert_eq(attributes.get_value_with_traits(&"stamina", traits), 15.0, "Trait 应能在属性当前值上计算。")

	var restored := GFAttributeSet.new()
	restored.from_dict(attributes.to_dict())

	assert_eq(restored.get_value(&"stamina"), 12.0, "恢复后当前值应一致。")
	assert_eq(restored.get_metadata(&"stamina").get("group"), "core", "恢复后元数据应一致。")


## 验证属性集合可通过通用规则计算派生属性。
func test_attribute_set_updates_derived_attribute_rules() -> void:
	var attributes := GFAttributeSet.new()
	attributes.define_attribute(&"strength", 5.0)
	attributes.define_attribute(&"power", 0.0)
	var rule := GFDerivedAttributeRuleBase.new()
	rule.attribute_id = &"power"
	rule.source_attribute_ids = [&"strength"]
	rule.source_weights = {
		&"strength": 2.0,
	}
	rule.flat_bonus = 1.0

	assert_true(attributes.add_derived_rule(rule), "有效派生规则应可注册。")
	assert_eq(attributes.get_value(&"power"), 11.0, "注册后应立即计算目标属性。")

	attributes.set_value(&"strength", 7.0)

	assert_eq(attributes.get_value(&"power"), 15.0, "来源属性变化后应自动重算派生属性。")


## 验证派生属性规则可使用自定义回调。
func test_derived_attribute_rule_can_use_callback() -> void:
	var attributes := GFAttributeSet.new()
	attributes.define_attribute(&"base", 3.0)
	var rule := GFDerivedAttributeRuleBase.new()
	rule.attribute_id = &"score"
	rule.compute_callback = func(attribute_set: GFAttributeSet, _rule: GFDerivedAttributeRuleBase) -> float:
		return attribute_set.get_value(&"base") * 4.0

	attributes.add_derived_rule(rule)

	assert_true(attributes.has_attribute(&"score"), "派生规则应能创建缺失的目标属性。")
	assert_eq(attributes.get_value(&"score"), 12.0, "自定义回调结果应写入目标属性。")


func test_attribute_set_recalculates_derived_rules_when_base_changes_with_synced_current() -> void:
	var attributes := GFAttributeSet.new()
	attributes.define_attribute(&"strength", 5.0, 10.0)
	var rule := GFDerivedAttributeRuleBase.new()
	rule.attribute_id = &"score"
	rule.source_attribute_ids = [&"strength"]
	rule.compute_callback = func(attribute_set: GFAttributeSet, _rule: GFDerivedAttributeRuleBase) -> float:
		return attribute_set.get_base_value(&"strength")
	attributes.add_derived_rule(rule)

	attributes.set_base_value(&"strength", 10.0, true)

	assert_eq(attributes.get_value(&"score"), 10.0, "base 改变但 current 未变化时也应重算派生属性。")


func test_attribute_set_recalculates_derived_rules_when_limits_clamp_base() -> void:
	var attributes := GFAttributeSet.new()
	attributes.define_attribute(&"strength", 20.0, 5.0, 0.0, 30.0)
	var rule := GFDerivedAttributeRuleBase.new()
	rule.attribute_id = &"score"
	rule.source_attribute_ids = [&"strength"]
	rule.compute_callback = func(attribute_set: GFAttributeSet, _rule: GFDerivedAttributeRuleBase) -> float:
		return attribute_set.get_base_value(&"strength")
	attributes.add_derived_rule(rule)

	attributes.set_limits(&"strength", 0.0, 10.0)

	assert_eq(attributes.get_value(&"score"), 10.0, "limits 改变并夹取 base 时应重算派生属性。")


# --- 私有/辅助方法 ---

func _has_domain_issue_kind(issues: Array, kind: String) -> bool:
	for issue: Dictionary in issues:
		if str(issue.get("kind", "")) == kind:
			return true
	return false
