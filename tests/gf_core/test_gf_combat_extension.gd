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
	attr.remove_modifiers_by_source(&"") # 因为没传 source，默认是空
	# 移除所有后再手动测试移除单个
	attr.set_base_value(100.0)
	var mod := GFModifier.create_percent_add(1.0)
	attr.add_modifier(mod)
	assert_eq(attr.current_value.get_value(), 200.0)
	attr.remove_modifier(mod)
	assert_eq(attr.current_value.get_value(), 100.0)


## 测试 BindableProperty 的响应式。
func test_attribute_reactivity() -> void:
	var attr := GFAttribute.new(10.0)
	var changed_count := [0]
	attr.current_value.value_changed.connect(func(_old, _new): changed_count[0] += 1)
	
	attr.add_modifier(GFModifier.create_base_add(5.0))
	assert_eq(changed_count[0], 1, "Signal should emit on modification")
	
	attr.set_base_value(20.0)
	assert_eq(changed_count[0], 2, "Signal should emit on base value change")


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
