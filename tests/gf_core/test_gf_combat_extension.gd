extends "res://addons/gut/test.gd"


# --- 辅助类 (模拟战斗实体) ---

class MockEntity extends Object:
	var tag_component := GFTagComponent.new()
	var attributes := {}
	var buffs: Array[GFBuff] = []
	
	func get_tag_component() -> GFTagComponent:
		return tag_component
		
	func get_attribute(p_id: StringName) -> GFAttribute:
		return attributes.get(p_id)
		
	func add_attr(p_id: StringName, p_val: float) -> void:
		attributes[p_id] = GFAttribute.new(p_val)


class RejectingSkill extends GFSkill:
	func _custom_can_execute() -> bool:
		return false


# --- 测试方法 ---

## 测试 GFAttribute 的修饰器计算。
func test_attribute_calculation() -> void:
	var attr := GFAttribute.new(100.0) # Base = 100
	
	# 添加基础加值: +20
	attr.add_modifier(GFModifier.create_base_add(20.0))
	assert_eq(attr.current_value.get_value(), 120.0, "Base add should work")
	
	# 添加百分比加值: +50% (0.5)
	# Formula: (100 + 20) * (1.0 + 0.5) = 120 * 1.5 = 180
	attr.add_modifier(GFModifier.create_percent_add(0.5))
	assert_eq(attr.current_value.get_value(), 180.0, "Percent add should apply to base+base_add")
	
	# 添加最终加值: +10
	# Formula: 180 + 10 = 190
	attr.add_modifier(GFModifier.create_final_add(10.0))
	assert_eq(attr.current_value.get_value(), 190.0, "Final add should work")
	
	# 移除百分比加值
	# Formula: (100 + 20) * 1.0 + 10 = 130
	attr.remove_modifiers_by_source(&"")
	# 移除所有后再手动测试移除单个
	attr.set_base_value(100.0)
	var mod := GFModifier.create_percent_add(1.0)
	attr.add_modifier(mod)
	assert_eq(attr.current_value.get_value(), 200.0)
	attr.remove_modifier(mod)
	assert_eq(attr.current_value.get_value(), 100.0)


func test_modifier_separates_attribute_and_source() -> void:
	var attr := GFAttribute.new(10.0)
	var mod := GFModifier.create_base_add(5.0, &"ATK", &"Ring")

	attr.add_modifier(mod)
	attr.remove_modifiers_by_source(&"ATK")
	assert_eq(attr.current_value.get_value(), 15.0, "按属性 ID 移除不应误删来源为 Ring 的修饰器。")

	attr.remove_modifiers_by_source(&"Ring")
	assert_eq(attr.current_value.get_value(), 10.0, "按来源 ID 移除应清理匹配修饰器。")


## 测试 BindableProperty 的响应式。
func test_attribute_reactivity() -> void:
	var attr := GFAttribute.new(10.0)
	var changed_count := [0]
	attr.current_value.value_changed.connect(func(_old, _new): changed_count[0] += 1)
	
	attr.add_modifier(GFModifier.create_base_add(5.0))
	assert_eq(changed_count[0], 1, "Signal should emit on modification")

	attr.set_base_value(20.0)
	assert_eq(changed_count[0], 2, "Signal should emit on base value change")


## 测试 GFAttribute 对外暴露的是只读响应式视图。
func test_attribute_current_value_is_read_only() -> void:
	var attr := GFAttribute.new(10.0)
	watch_signals(attr.current_value)

	attr.current_value.set_value(999.0)

	assert_push_error("[GFReadOnlyBindableProperty] 当前属性为只读视图，请通过宿主对象修改其值。")
	assert_eq(attr.current_value.get_value(), 10.0, "外部不应绕过 GFAttribute 直接改写 current_value。")
	assert_signal_not_emitted(attr.current_value, "value_changed", "只读视图拒绝直接写入时不应发出变化信号。")


## 测试 GFTagComponent。
func test_tag_component() -> void:
	var tc := GFTagComponent.new()
	assert_false(tc.has_tag(&"Stun"), "Should not have tag initially")
	
	tc.add_tag(&"Stun", 2)
	assert_true(tc.has_tag(&"Stun"), "Should have tag after adding")
	assert_eq(tc.get_tag_count(&"Stun"), 2, "Stack count should be correct")
	
	tc.remove_tag(&"Stun", 1)
	assert_eq(tc.get_tag_count(&"Stun"), 1)
	
	tc.remove_tag(&"Stun", 1)
	assert_false(tc.has_tag(&"Stun"), "Tag should be removed when stack reaches 0")


func test_tag_component_rejects_invalid_remove_count() -> void:
	var tc := GFTagComponent.new()
	tc.add_tag(&"Stun", 2)

	tc.remove_tag(&"Stun", -2)

	assert_push_warning("[GFTagComponent] remove_tag 收到无效层数，请传入正数或 -1。")
	assert_eq(tc.get_tag_count(&"Stun"), 2, "无效移除层数不应反向增加标签层数。")


func test_skill_requires_tags_when_owner_has_no_tag_component() -> void:
	var plain_owner := Object.new()
	var skill := GFSkill.new(plain_owner)
	skill.require_tags.append(&"Armed")

	assert_false(skill.can_execute(), "存在必需标签但 owner 无标签组件时，技能不应允许施放。")


func test_skill_custom_can_execute_runs_without_tag_component() -> void:
	var plain_owner := Object.new()
	var skill := RejectingSkill.new()
	skill.owner = plain_owner

	assert_false(skill.can_execute(), "owner 无标签组件且无必需标签时，仍应执行自定义施放检查。")


func test_attribute_ignores_null_modifier() -> void:
	var attr := GFAttribute.new(10.0)

	attr.add_modifier(null)

	assert_eq(attr.current_value.get_value(), 10.0, "空修饰器不应影响属性计算。")


func test_buff_modifier_supports_legacy_source_tag_attribute_fallback() -> void:
	var system := GFCombatSystem.new()
	var entity := MockEntity.new()
	entity.add_attr(&"ATK", 10.0)
	system.register_entity(entity)

	var buff := GFBuff.new()
	var mod := GFModifier.new()
	mod.value = 5.0
	mod.source_tag = &"ATK"
	buff.modifiers.append(mod)
	buff.setup(&"LegacyPowerUp", 1.0, entity)

	system.add_buff(entity, buff)

	assert_eq(entity.get_attribute(&"ATK").current_value.get_value(), 15.0, "旧 source_tag 写法仍应作为目标属性回退。")


## 测试 GFCombatSystem 的 Buff 驱动。
func test_combat_system_buff_lifecycle() -> void:
	var system := GFCombatSystem.new()
	var entity := MockEntity.new()
	entity.add_attr(&"ATK", 10.0)
	
	system.register_entity(entity)
	
	var buff := GFBuff.new()
	var atk_mod := GFModifier.create_base_add(5.0, &"ATK")
	buff.modifiers.append(atk_mod)
	buff.tags.append(&"Buffed")
	buff.setup(&"PowerUp", 2.0, entity) # 持续 2 秒
	
	system.add_buff(entity, buff)
	
	assert_true(entity.tag_component.has_tag(&"Buffed"), "Buff tags should be applied")
	assert_eq(entity.get_attribute(&"ATK").current_value.get_value(), 15.0, "Buff modifiers should be applied")
	
	# Tick 1 秒
	system.tick(1.0)
	assert_eq(entity.get_attribute(&"ATK").current_value.get_value(), 15.0, "Buff should still be active")
	
	# Tick 1.5 秒 (总共 2.5，超过 2)
	system.tick(1.5)
	assert_false(entity.tag_component.has_tag(&"Buffed"), "Buff tags should be removed after expiration")
	assert_eq(entity.get_attribute(&"ATK").current_value.get_value(), 10.0, "Buff modifiers should be removed after expiration")


## 测试注销实体时会同步移除活跃实体索引。
func test_unregister_entity_removes_active_status() -> void:
	var system := GFCombatSystem.new()
	var entity := MockEntity.new()
	entity.add_attr(&"ATK", 10.0)
	
	system.register_entity(entity)
	
	var buff := GFBuff.new()
	buff.setup(&"PowerUp", 2.0, entity)
	system.add_buff(entity, buff)
	
	assert_true(system._active_entities.has(entity.get_instance_id()), "添加 Buff 后实体应进入活跃集合。")
	
	system.unregister_entity(entity)
	
	assert_false(system._active_entities.has(entity.get_instance_id()), "注销实体后活跃索引应被清理。")
	system.tick(1.0)


func test_dispose_removes_buff_effects_and_clears_indices() -> void:
	var system := GFCombatSystem.new()
	var entity := MockEntity.new()
	entity.add_attr(&"ATK", 10.0)
	system.register_entity(entity)

	var buff := GFBuff.new()
	buff.modifiers.append(GFModifier.create_base_add(5.0, &"ATK"))
	buff.tags.append(&"Buffed")
	buff.setup(&"PowerUp", 2.0, entity)
	system.add_buff(entity, buff)

	assert_eq(entity.get_attribute(&"ATK").current_value.get_value(), 15.0, "dispose 前 Buff 修饰器应已生效。")
	assert_true(entity.tag_component.has_tag(&"Buffed"), "dispose 前 Buff 标签应已生效。")

	system.dispose()

	assert_eq(entity.get_attribute(&"ATK").current_value.get_value(), 10.0, "dispose 应移除仍存活实体上的 Buff 修饰器。")
	assert_false(entity.tag_component.has_tag(&"Buffed"), "dispose 应移除仍存活实体上的 Buff 标签。")
	assert_eq(system._entities.size(), 0, "dispose 后主索引应清空。")
	assert_eq(system._active_entities.size(), 0, "dispose 后活跃索引应清空。")


## 测试技能 CD 更新。
func test_skill_cooldown() -> void:
	var system := GFCombatSystem.new()
	var entity := MockEntity.new()
	system.register_entity(entity)
	
	var skill := GFSkill.new(entity)
	skill.cooldown_max = 5.0
	system.add_skill(entity, skill)
	
	skill.execute() # 消耗 CD
	assert_eq(skill.cooldown_left, 5.0)
	
	system.tick(2.0)
	assert_eq(skill.cooldown_left, 3.0, "Skill CD should be updated by system tick")


func test_add_skill_assigns_owner_when_missing() -> void:
	var system := GFCombatSystem.new()
	var entity := MockEntity.new()
	system.register_entity(entity)

	var skill := GFSkill.new()
	skill.cooldown_max = 1.0
	system.add_skill(entity, skill)
	skill.execute()

	assert_eq(skill.owner, entity, "未设置 owner 的技能在加入实体时应自动回填所属者。")
	assert_eq(skill.cooldown_left, 1.0, "自动回填 owner 后，技能应可正常进入冷却。")


func test_add_buff_assigns_owner_when_missing() -> void:
	var system := GFCombatSystem.new()
	var entity := MockEntity.new()
	entity.add_attr(&"ATK", 10.0)
	system.register_entity(entity)

	var buff := GFBuff.new()
	buff.modifiers.append(GFModifier.create_base_add(5.0, &"ATK"))
	buff.setup(&"PowerUp", 1.0, null)
	system.add_buff(entity, buff)

	assert_eq(buff.owner, entity, "未设置 owner 的 Buff 在加入实体时应自动回填所属者。")
	assert_eq(entity.get_attribute(&"ATK").current_value.get_value(), 15.0, "自动回填 owner 后，Buff 效果应能正常生效。")


func test_duplicate_buff_refresh_updates_duration_and_stacks() -> void:
	var system := GFCombatSystem.new()
	var entity := MockEntity.new()
	system.register_entity(entity)

	var buff := GFBuff.new()
	buff.max_stacks = 3
	buff.setup(&"StackingBuff", 1.0, entity)
	system.add_buff(entity, buff)

	var refreshed_buff := GFBuff.new()
	refreshed_buff.setup(&"StackingBuff", -1.0, entity)
	system.add_buff(entity, refreshed_buff)

	assert_eq(buff.stacks, 2, "重复 Buff 应在 max_stacks 允许时增加层数。")
	assert_eq(buff.duration, -1.0, "重复 Buff 刷新应同步新的 duration。")
	assert_eq(buff.time_left, -1.0, "重复 Buff 刷新应同步新的剩余时间。")


## 测试 GFAttribute 的强制重算。
func test_attribute_force_recalculate() -> void:
	var attr := GFAttribute.new(100.0)
	var mod := GFModifier.create_base_add(10.0)
	attr.add_modifier(mod)
	assert_eq(attr.current_value.get_value(), 110.0)
	
	# 直接修改修饰器数值而不通过 add/remove
	mod.value = 50.0
	assert_eq(attr.current_value.get_value(), 110.0, "Value should not change automatically")
	
	attr.force_recalculate()
	assert_eq(attr.current_value.get_value(), 150.0, "Force recalculate should update final value")


## 测试战斗事件派发。
func test_update_active_status_cleans_orphaned_active_entry() -> void:
	var system := GFCombatSystem.new()
	var entity := MockEntity.new()

	system._active_entities[entity.get_instance_id()] = entity
	system._update_active_status(entity)

	assert_false(system._active_entities.has(entity.get_instance_id()), "未注册实体的活跃索引应被移除。")


func test_tick_cleans_freed_entities_from_internal_indices() -> void:
	var system := GFCombatSystem.new()
	var entity := MockEntity.new()

	system._entities[entity] = {
		"buffs": [],
		"skills": [],
	}
	system._active_entities[entity.get_instance_id()] = entity

	entity.free()
	system.tick(0.0)

	assert_eq(system._entities.size(), 0, "已释放实体应从主索引中清理。")
	assert_eq(system._active_entities.size(), 0, "已释放实体应从活跃索引中清理。")


func test_combat_event_dispatching() -> void:
	# 初始化架构以支持事件总线
	var arch := GFArchitecture.new()
	Gf.set_architecture(arch)
	
	var system := GFCombatSystem.new()
	var entity := MockEntity.new()
	system.register_entity(entity)
	
	var events := {
		"applied": 0,
		"refreshed": 0,
		"removed": 0,
	}
	
	# 注册监听器
	Gf.listen(GFCombatPayloads.GFBuffAppliedPayload, func(_p): events["applied"] += 1)
	Gf.listen(GFCombatPayloads.GFBuffRefreshedPayload, func(_p): events["refreshed"] += 1)
	Gf.listen(GFCombatPayloads.GFBuffRemovedPayload, func(_p): events["removed"] += 1)
	
	var buff := GFBuff.new()
	buff.setup(&"TestBuff", 1.0, entity)
	
	# 测试 Apply
	system.add_buff(entity, buff)
	assert_eq(events["applied"], 1)
	
	# 测试 Refresh
	system.add_buff(entity, buff)
	assert_eq(events["refreshed"], 1)
	
	# 测试 Remove
	system.tick(2.0)
	assert_eq(events["removed"], 1)
	
	# 清理架构
	arch.dispose()


func test_combat_events_use_injected_scoped_architecture() -> void:
	var parent_arch := GFArchitecture.new()
	await Gf.set_architecture(parent_arch)

	var child_arch := GFArchitecture.new(parent_arch)
	var system := GFCombatSystem.new()
	await child_arch.register_system_instance(system)

	var parent_events := { "applied": 0 }
	var child_events := { "applied": 0 }
	parent_arch.register_event(GFCombatPayloads.GFBuffAppliedPayload, func(_p) -> void:
		parent_events["applied"] += 1
	)
	child_arch.register_event(GFCombatPayloads.GFBuffAppliedPayload, func(_p) -> void:
		child_events["applied"] += 1
	)

	var entity := MockEntity.new()
	var buff := GFBuff.new()
	buff.setup(&"ScopedBuff", 1.0, entity)

	system.register_entity(entity)
	system.add_buff(entity, buff)

	assert_eq(child_events["applied"], 1, "Scoped CombatSystem 应向自身架构派发事件。")
	assert_eq(parent_events["applied"], 0, "Scoped CombatSystem 不应绕到全局父架构派发事件。")

	child_arch.dispose()
	parent_arch.dispose()
	Gf._architecture = null
