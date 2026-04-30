## 测试战斗索敌规则、排序与施法中心解析行为。
extends GutTest


const GFSkill_ := preload("res://addons/gf/extensions/combat/gf_skill.gd")
const GFTagComponent_ := preload("res://addons/gf/extensions/combat/gf_tag_component.gd")
const GFAttribute_ := preload("res://addons/gf/extensions/combat/gf_attribute.gd")
const GFSkillTargetingRule_ := preload("res://addons/gf/extensions/combat/gf_skill_targeting_rule.gd")
const GFSkillTargetingUtility_ := preload("res://addons/gf/extensions/combat/gf_skill_targeting_utility.gd")


class DummyEntity:
	var global_position: Vector2 = Vector2.ZERO
	var _tags := GFTagComponent.new()
	var _attributes: Dictionary = {}

	func get_tag_component() -> GFTagComponent:
		return _tags

	func get_attribute(p_name: StringName) -> GFAttribute:
		return _attributes.get(p_name)

	func add_attr(p_name: StringName, p_val: float) -> void:
		_attributes[p_name] = GFAttribute.new(p_val)


class TestSkill extends GFSkill:
	var last_targets: Array[Object] = []
	var candidates: Array = []

	func get_targeting_candidates() -> Array:
		return candidates

	func _on_execute(p_targets: Array[Object]) -> void:
		last_targets = p_targets


func before_each() -> void:
	var arch := GFArchitecture.new()
	arch.register_utility_instance(GFSkillTargetingUtility.new())
	await Gf.set_architecture(arch)


func after_each() -> void:
	var arch: GFArchitecture = Gf.get_architecture()
	if arch != null:
		arch.dispose()
	Gf._architecture = null


func test_targeting_distance_sorting() -> void:
	var utility := Gf.get_utility(GFSkillTargetingUtility) as GFSkillTargetingUtility
	var rule := GFSkillTargetingRule.new()
	rule.shape = GFSkillTargetingRule.Shape.CIRCLE
	rule.radius = 200.0
	rule.max_count = 10

	var e1 := DummyEntity.new()
	e1.global_position = Vector2(100, 0)

	var e2 := DummyEntity.new()
	e2.global_position = Vector2(50, 0)

	var e3 := DummyEntity.new()
	e3.global_position = Vector2(150, 0)

	var candidates: Array[Object] = [e1, e2, e3]

	rule.sort_rule = GFSkillTargetingRule.SortRule.DISTANCE_CLOSEST
	var targets := utility.find_targets(Vector2.ZERO, rule, candidates)
	assert_eq(targets.size(), 3)
	assert_eq(targets[0], e2)
	assert_eq(targets[1], e1)
	assert_eq(targets[2], e3)

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

	rule.sort_rule = GFSkillTargetingRule.SortRule.ATTRIBUTE_HIGHEST
	var targets := utility.find_targets(Vector2.ZERO, rule, candidates)
	assert_eq(targets[0], e2)
	assert_eq(targets[2], e3)

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


func test_rectangle_shape_filters_axis_aligned_bounds() -> void:
	var utility := Gf.get_utility(GFSkillTargetingUtility) as GFSkillTargetingUtility
	var rule := GFSkillTargetingRule.new()
	rule.shape = GFSkillTargetingRule.Shape.RECTANGLE
	rule.rectangle_size = Vector2(100.0, 80.0)
	rule.max_count = 10

	var inside := DummyEntity.new()
	inside.global_position = Vector2(40, 20)

	var outside_x := DummyEntity.new()
	outside_x.global_position = Vector2(60, 0)

	var outside_y := DummyEntity.new()
	outside_y.global_position = Vector2(0, 50)

	var targets := utility.find_targets(Vector2.ZERO, rule, [inside, outside_x, outside_y])
	assert_eq(targets.size(), 1)
	assert_eq(targets[0], inside)


func test_sector_shape_filters_by_direction() -> void:
	var utility := Gf.get_utility(GFSkillTargetingUtility) as GFSkillTargetingUtility
	var rule := GFSkillTargetingRule.new()
	rule.shape = GFSkillTargetingRule.Shape.SECTOR
	rule.radius = 100.0
	rule.forward_direction = Vector2.RIGHT
	rule.sector_angle_degrees = 90.0
	rule.max_count = 10

	var forward_target := DummyEntity.new()
	forward_target.global_position = Vector2(50, 0)

	var side_target := DummyEntity.new()
	side_target.global_position = Vector2(0, 50)

	var back_target := DummyEntity.new()
	back_target.global_position = Vector2(-50, 0)

	var targets := utility.find_targets(Vector2.ZERO, rule, [forward_target, side_target, back_target])
	assert_eq(targets.size(), 1)
	assert_eq(targets[0], forward_target)


func test_skill_auto_targeting() -> void:
	var rule := GFSkillTargetingRule.new()
	rule.radius = 100.0
	rule.max_count = 1

	var target := DummyEntity.new()
	target.global_position = Vector2(50, 0)

	var owner_entity := DummyEntity.new()
	owner_entity.global_position = Vector2.ZERO

	var test_skill := TestSkill.new(owner_entity)
	test_skill.targeting_rule = rule
	test_skill.candidates = [target]

	test_skill.execute()
	assert_eq(test_skill.last_targets.size(), 1)
	assert_eq(test_skill.last_targets[0], target)


func test_skill_manual_target_defaults_center_to_owner_position() -> void:
	var rule := GFSkillTargetingRule.new()
	rule.radius = 30.0
	rule.max_count = 1

	var owner_entity := DummyEntity.new()
	owner_entity.global_position = Vector2(100, 100)

	var target := DummyEntity.new()
	target.global_position = Vector2(120, 100)

	var test_skill := TestSkill.new(owner_entity)
	test_skill.targeting_rule = rule

	test_skill.execute(target)
	assert_eq(test_skill.last_targets.size(), 1)
	assert_eq(test_skill.last_targets[0], target)


func test_skill_explicit_origin_cast_center_is_respected() -> void:
	var rule := GFSkillTargetingRule.new()
	rule.radius = 30.0
	rule.max_count = 1

	var owner_entity := DummyEntity.new()
	owner_entity.global_position = Vector2(300, 300)

	var origin_target := DummyEntity.new()
	origin_target.global_position = Vector2(10, 0)

	var test_skill := TestSkill.new(owner_entity)
	test_skill.targeting_rule = rule
	test_skill.candidates = [origin_target]

	test_skill.execute(null, Vector2.ZERO)
	assert_eq(test_skill.last_targets.size(), 1)
	assert_eq(test_skill.last_targets[0], origin_target)
