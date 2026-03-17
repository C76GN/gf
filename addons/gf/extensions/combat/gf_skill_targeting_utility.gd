# addons/gf/extensions/combat/gf_skill_targeting_utility.gd
class_name GFSkillTargetingUtility
extends GFUtility


## GFSkillTargetingUtility: 技能索敌处理工具。
##
## 提供管线化的索敌逻辑：空间过滤 -> 标签过滤 -> 规则排序 -> 数量截取。


# --- 公共方法 ---

## 执行索敌 pipeline。
## @param p_center: 索敌中心点。
## @param p_rule: 索敌规则资源。
## @param p_available_entities: 可选的候选实体池，若不提供则需从其他 Utility 获取。
## @return 最终筛选出的目标数组。
func find_targets(p_center: Vector2, p_rule: GFSkillTargetingRule, p_available_entities: Array) -> Array[Object]:
	if p_rule == null:
		return []
		
	var targets: Array[Object] = []
	
	# 1. 空间采集 & 2. 标签过滤 (合并处理提高效率)
	for entity in p_available_entities:
		if not is_instance_valid(entity):
			continue
			
		# 空间检查 (目前仅实现了 CIRCLE 和 SINGLE 的半径检查)
		if p_rule.shape == GFSkillTargetingRule.Shape.CIRCLE or p_rule.shape == GFSkillTargetingRule.Shape.SINGLE:
			var pos := _get_entity_position(entity)
			if p_center.distance_to(pos) > p_rule.radius:
				continue
		# TODO: 其他形状如 RECTANGLE, SECTOR 的具体数学检查可根据项目需求扩展
		
		# 标签过滤
		if not _check_tags(entity, p_rule):
			continue
			
		targets.append(entity)
		
	if targets.is_empty():
		return []
		
	# 3. 排序
	_sort_targets(targets, p_center, p_rule)
	
	# 4. 截取
	if p_rule.max_count > 0 and targets.size() > p_rule.max_count:
		targets = targets.slice(0, p_rule.max_count)
		
	return targets


# --- 私有方法 ---

## 检查实体的标签是否符合规则。
func _check_tags(p_entity: Object, p_rule: GFSkillTargetingRule) -> bool:
	if not p_entity.has_method(&"get_tag_component"):
		return p_rule.require_tags.is_empty()
		
	var tc := p_entity.call(&"get_tag_component") as GFTagComponent
	if tc == null:
		return p_rule.require_tags.is_empty()
		
	# 检查必须拥有的标签
	for tag in p_rule.require_tags:
		if not tc.has_tag(tag):
			return false
			
	# 检查禁止拥有的标签
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


## 获取实体的坐标位置。
func _get_entity_position(p_entity: Object) -> Vector2:
	if "global_position" in p_entity:
		return p_entity.global_position
	return Vector2.ZERO


## 获取实体的动态属性值。
func _get_entity_attribute_value(p_entity: Object, p_attr_name: StringName) -> float:
	if p_entity.has_method(&"get_attribute"):
		var attr := p_entity.call(&"get_attribute", p_attr_name) as GFAttribute
		if attr != null:
			return attr.current_value.get_value()
	
	# 回退方案：通过属性字典或成员变量获取
	if p_attr_name in p_entity:
		var val = p_entity.get(p_attr_name)
		if val is float or val is int:
			return float(val)
			
	return 0.0
