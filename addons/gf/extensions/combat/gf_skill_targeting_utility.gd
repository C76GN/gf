## GFSkillTargetingUtility: 技能索敌处理工具。
##
## 提供统一的目标筛选流程：先做空间过滤，
## 再执行标签过滤、排序与数量截断。
class_name GFSkillTargetingUtility
extends GFUtility


# --- 公共方法 ---

## 执行索敌 pipeline。
## @param p_center: 索敌中心点。
## @param p_rule: 索敌规则资源。
## @param p_available_entities: 候选实体池。
## @return 最终筛选出的目标数组。
func find_targets(p_center: Vector2, p_rule: GFSkillTargetingRule, p_available_entities: Array) -> Array[Object]:
	if p_rule == null:
		return []

	var targets: Array[Object] = []

	for entity in p_available_entities:
		if not is_instance_valid(entity):
			continue

		if not _is_entity_in_shape(entity, p_center, p_rule):
			continue

		if not _check_tags(entity, p_rule):
			continue

		targets.append(entity)

	if targets.is_empty():
		return []

	_sort_targets(targets, p_center, p_rule)

	if p_rule.max_count > 0 and targets.size() > p_rule.max_count:
		targets = targets.slice(0, p_rule.max_count)

	return targets


# --- 私有/辅助方法 ---

func _is_entity_in_shape(p_entity: Object, p_center: Vector2, p_rule: GFSkillTargetingRule) -> bool:
	var pos := _get_entity_position(p_entity)
	var offset := pos - p_center

	match p_rule.shape:
		GFSkillTargetingRule.Shape.RECTANGLE:
			var half_size := p_rule.rectangle_size * 0.5
			return absf(offset.x) <= half_size.x and absf(offset.y) <= half_size.y

		GFSkillTargetingRule.Shape.CIRCLE, GFSkillTargetingRule.Shape.SINGLE:
			return offset.length_squared() <= p_rule.radius * p_rule.radius

		GFSkillTargetingRule.Shape.SECTOR:
			if offset.length_squared() > p_rule.radius * p_rule.radius:
				return false

			if offset == Vector2.ZERO:
				return true

			var forward := p_rule.forward_direction
			if forward == Vector2.ZERO:
				forward = Vector2.RIGHT

			var half_angle_radians := deg_to_rad(clampf(p_rule.sector_angle_degrees, 0.0, 360.0) * 0.5)
			if half_angle_radians >= PI:
				return true

			return absf(forward.normalized().angle_to(offset.normalized())) <= half_angle_radians

	return false


## 检查实体标签是否符合规则。
func _check_tags(p_entity: Object, p_rule: GFSkillTargetingRule) -> bool:
	if not p_entity.has_method(&"get_tag_component"):
		return p_rule.require_tags.is_empty()

	var tc := p_entity.call(&"get_tag_component") as GFTagComponent
	if tc == null:
		return p_rule.require_tags.is_empty()

	for tag in p_rule.require_tags:
		if not tc.has_tag(tag):
			return false

	for tag in p_rule.ignore_tags:
		if tc.has_tag(tag):
			return false

	return true


## 对目标列表进行排序。
func _sort_targets(p_targets: Array[Object], p_center: Vector2, p_rule: GFSkillTargetingRule) -> void:
	match p_rule.sort_rule:
		GFSkillTargetingRule.SortRule.DISTANCE_CLOSEST:
			p_targets.sort_custom(func(a, b):
				return p_center.distance_squared_to(_get_entity_position(a)) < p_center.distance_squared_to(_get_entity_position(b))
			)
		GFSkillTargetingRule.SortRule.DISTANCE_FURTHEST:
			p_targets.sort_custom(func(a, b):
				return p_center.distance_squared_to(_get_entity_position(a)) > p_center.distance_squared_to(_get_entity_position(b))
			)
		GFSkillTargetingRule.SortRule.ATTRIBUTE_LOWEST:
			p_targets.sort_custom(func(a, b):
				return _get_entity_attribute_value(a, p_rule.sort_attribute_name) < _get_entity_attribute_value(b, p_rule.sort_attribute_name)
			)
		GFSkillTargetingRule.SortRule.ATTRIBUTE_HIGHEST:
			p_targets.sort_custom(func(a, b):
				return _get_entity_attribute_value(a, p_rule.sort_attribute_name) > _get_entity_attribute_value(b, p_rule.sort_attribute_name)
			)
		GFSkillTargetingRule.SortRule.RANDOM:
			p_targets.shuffle()


## 获取实体坐标位置。
func _get_entity_position(p_entity: Object) -> Vector2:
	if "global_position" in p_entity:
		return p_entity.global_position

	return Vector2.ZERO


## 获取实体属性值。
func _get_entity_attribute_value(p_entity: Object, p_attr_name: StringName) -> float:
	if p_entity.has_method(&"get_attribute"):
		var attr := p_entity.call(&"get_attribute", p_attr_name) as GFAttribute
		if attr != null:
			return attr.current_value.get_value()

	if p_attr_name in p_entity:
		var val = p_entity.get(p_attr_name)
		if val is float or val is int:
			return float(val)

	return 0.0
