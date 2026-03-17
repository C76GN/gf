# tests/gf_core/test_gf_combat_targeting.gd
extends GutTest


# --- 外部依赖 ---

const GFSkill_ := preload("res://addons/gf/extensions/combat/gf_skill.gd")
const GFTagComponent_ := preload("res://addons/gf/extensions/combat/gf_tag_component.gd")
const GFAttribute_ := preload("res://addons/gf/extensions/combat/gf_attribute.gd")
const GFSkillTargetingRule_ := preload("res://addons/gf/extensions/combat/gf_skill_targeting_rule.gd")
const GFSkillTargetingUtility_ := preload("res://addons/gf/extensions/combat/gf_skill_targeting_utility.gd")


# --- 内部辅助类 ---

class DummyEntity:
	var global_position: Vector2 = Vector2.ZERO
	var _tags := GFTagComponent.new()
	var _attributes: Dictionary = {} # StringName -> GFAttribute
	
	func get_tag_component() -> GFTagComponent:
		return _tags
		
	func get_attribute(p_name: StringName) -> GFAttribute:
		return _attributes.get(p_name)
		
	func add_attr(p_name: StringName, p_val: float) -> void:
		_attributes[p_name] = GFAttribute.new(p_val)


# --- Godot 生命周期方法 ---

func before_each() -> void:
	var arch := GFArchitecture.new()
	arch.register_utility_instance(GFSkillTargetingUtility.new())
	await Gf.set_architecture(arch)


func after_each() -> void:
	var arch := Gf.get_architecture()
	if arch != null:
		arch.dispose()
	Gf._architecture = null


# --- 测试用例 ---

func test_targeting_distance_sorting() -> void:
	var utility := Gf.get_utility(GFSkillTargetingUtility) as GFSkillTargetingUtility
	var rule := GFSkillTargetingRule.new()
	rule.shape = GFSkillTargetingRule.Shape.CIRCLE
	rule.radius = 200.0
	rule.max_count = 10
	
	var e1 := DummyEntity.new()
	e1.global_position = Vector2(100, 0) # 距离 100
	
	var e2 := DummyEntity.new()
	e2.global_position = Vector2(50, 0)  # 距离 50
	
	var e3 := DummyEntity.new()
	e3.global_position = Vector2(150, 0) # 距离 150
	
	var candidates: Array[Object] = [e1, e2, e3]
	
	# 测试最近排序
	rule.sort_rule = GFSkillTargetingRule.SortRule.DISTANCE_CLOSEST
	var targets := utility.find_targets(Vector2.ZERO, rule, candidates)
	assert_eq(targets.size(), 3)
	assert_eq(targets[0], e2)
	assert_eq(targets[1], e1)
	assert_eq(targets[2], e3)
	
	# 测试最远排序
	rule.sort_rule = GFSkillTargetingRule.SortRule.DISTANCE_FURTHEST
	targets = utility.find_targets(Vector2.ZERO, rule, candidates)
	assert_eq(targets[0], e3)
	assert_eq(targets[2], e2)


func test_targeting_attribute_sorting() -> void:
	var utility := Gf.get_utility(GFSkillTargetingUtility) as GFSkillTargetingUtility
	var rule := GFSkillTargetingRule.new()
	rule.shape = GFSkillTargetingRule.Shape.CIRCLE
	rule.radius = 1000.0
	rule.max_count = 3
	rule.sort_attribute_name = &"CustomVal"
	
	var e1 := DummyEntity.new()
	e1.add_attr(&"CustomVal", 10.0)
	
	var e2 := DummyEntity.new()
	e2.add_attr(&"CustomVal", 50.0)
	
	var e3 := DummyEntity.new()
	e3.add_attr(&"CustomVal", 5.0)
	
	var candidates: Array[Object] = [e1, e2, e3]
	
	# 测试最高排序
	rule.sort_rule = GFSkillTargetingRule.SortRule.ATTRIBUTE_HIGHEST
	var targets := utility.find_targets(Vector2.ZERO, rule, candidates)
	assert_eq(targets[0], e2)
	assert_eq(targets[2], e3)
	
	# 测试最低排序
	rule.sort_rule = GFSkillTargetingRule.SortRule.ATTRIBUTE_LOWEST
	targets = utility.find_targets(Vector2.ZERO, rule, candidates)
	assert_eq(targets[0], e3)
	assert_eq(targets[2], e2)


func test_targeting_tag_filtering() -> void:
	var utility := Gf.get_utility(GFSkillTargetingUtility) as GFSkillTargetingUtility
	var rule := GFSkillTargetingRule.new()
	rule.radius = 1000.0
	rule.require_tags = [&"Ally"]
	rule.ignore_tags = [&"Dead"]
	
	var e1 := DummyEntity.new()
	e1.get_tag_component().add_tag(&"Ally")
	
	var e2 := DummyEntity.new()
	e2.get_tag_component().add_tag(&"Enemy")
	
	var e3 := DummyEntity.new()
	e3.get_tag_component().add_tag(&"Ally")
	e3.get_tag_component().add_tag(&"Dead")
	
	var candidates: Array[Object] = [e1, e2, e3]
	
	var targets := utility.find_targets(Vector2.ZERO, rule, candidates)
	assert_eq(targets.size(), 1)
	assert_eq(targets[0], e1)


func test_targeting_max_count() -> void:
	var utility := Gf.get_utility(GFSkillTargetingUtility) as GFSkillTargetingUtility
	var rule := GFSkillTargetingRule.new()
	rule.radius = 1000.0
	rule.max_count = 2
	
	var e1 := DummyEntity.new()
	var e2 := DummyEntity.new()
	var e3 := DummyEntity.new()
	
	var candidates: Array[Object] = [e1, e2, e3]
	var targets := utility.find_targets(Vector2.ZERO, rule, candidates)
	assert_eq(targets.size(), 2)


func test_skill_auto_targeting() -> void:
	var rule := GFSkillTargetingRule.new()
	rule.radius = 100.0
	rule.max_count = 1
	
	var e1 := DummyEntity.new()
	e1.global_position = Vector2(50, 0)
	
	# 模拟拥有者
	var owner_entity := DummyEntity.new()
	owner_entity.global_position = Vector2.ZERO
	
	# 由于通过 TestSkill 子类重写了 get_targeting_candidates，
	# 且现在 GFSkill 会回退检查自身的方法，测试应能成功
	var test_skill := TestSkill.new(owner_entity)
	test_skill.targeting_rule = rule
	test_skill.candidates = [e1]
	
	test_skill.execute()
	assert_eq(test_skill.last_targets.size(), 1)
	assert_eq(test_skill.last_targets[0], e1)


# --- 测试辅助子类 ---

class TestSkill extends GFSkill:
	var last_targets: Array[Object] = []
	var candidates: Array = []
	
	func get_targeting_candidates() -> Array:
		return candidates
		
	func _on_execute(p_targets: Array[Object]) -> void:
		last_targets = p_targets
