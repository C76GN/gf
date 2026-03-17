# addons/gf/extensions/combat/gf_skill.gd
class_name GFSkill
extends RefCounted


## GFSkill: 技能基类。
## 
## 管理 CD、消耗检查及标签限制。
## 具体的技能逻辑通过子类重写 _on_execute 来实现。

signal cooldown_started(skill: GFSkill)


# --- 公共变量 ---

## 技能 ID。
var id: StringName = &""

## 最大冷却时间。
var cooldown_max: float = 0.0

## 当前剩余冷却时间。
var cooldown_left: float = 0.0

## 释放技能所需的标签。
var require_tags: Array[StringName] = []

## 释放技能禁止存在的标签。
var ignore_tags: Array[StringName] = []

## 技能所有者。
var owner: Object = null

## 技能索敌规则。若配置此项且 execute 未传入手动目标，则会自动索敌。
var targeting_rule: GFSkillTargetingRule = null


# --- Godot 生命周期方法 ---

func _init(p_owner: Object = null) -> void:
	owner = p_owner


# --- 公共方法 ---

## 更新 CD。
func update(p_delta: float) -> void:
	if cooldown_left > 0:
		cooldown_left = max(0.0, cooldown_left - p_delta)


## 检查技能是否可以被释放。
## @return 可以释放返回 true。
func can_execute() -> bool:
	if cooldown_left > 0:
		return false
		
	if owner == null:
		return false
		
	# 检查标签
	if owner.has_method("get_tag_component"):
		var tc := owner.get_tag_component() as GFTagComponent
		if tc != null:
			# 必须包含
			for tag in require_tags:
				if not tc.has_tag(tag):
					return false
			# 不能包含
			for tag in ignore_tags:
				if tc.has_tag(tag):
					return false
					
	return _custom_can_execute()


## 执行技能。
## @param manual_target: 可选的手动指定目标。
## @param cast_center: 技能施放中心坐标，默认为施法者位置。
func execute(manual_target: Object = null, cast_center: Vector2 = Vector2.ZERO) -> void:
	if not can_execute():
		return
		
	var final_targets: Array[Object] = []
	
	if manual_target != null:
		# 手动指定目标：若有规则，则需进行规则校验
		if targeting_rule != null:
			var utility := Gf.get_utility(GFSkillTargetingUtility) as GFSkillTargetingUtility
			if utility == null:
				push_error("[GFCombat] GFSkillTargetingUtility 尚未在架构中注册。")
				return
				
			var valid_targets := utility.find_targets(cast_center, targeting_rule, [manual_target])
			if not valid_targets.is_empty():
				final_targets.append(manual_target)
		else:
			final_targets.append(manual_target)
	elif targeting_rule != null:
		# 自动索敌：需从外界或全局实体池获取候选者。此处暂定由 owner 提供或需要子类传递候选池。
		# 在通用框架层级，我们可以尝试从 owner 的上下文获取候选实体，或由技能自身提供。
		var candidates: Array = []
		if owner != null and owner.has_method(&"get_targeting_candidates"):
			candidates = owner.call(&"get_targeting_candidates")
		elif has_method(&"get_targeting_candidates"):
			candidates = call(&"get_targeting_candidates")
			
		var utility := Gf.get_utility(GFSkillTargetingUtility) as GFSkillTargetingUtility
		if utility == null:
			push_error("[GFCombat] GFSkillTargetingUtility 尚未在架构中注册。")
			return
			
		var center := cast_center
		if center == Vector2.ZERO and "global_position" in owner:
			center = owner.global_position
			
		final_targets = utility.find_targets(center, targeting_rule, candidates)
		
	# 若索敌后仍为空且规则规定必选目标，则不触发执行
	if targeting_rule != null and targeting_rule.max_count > 0 and final_targets.is_empty():
		return
		
	_on_execute(final_targets)
	cooldown_left = cooldown_max
	cooldown_started.emit(self)


# --- 虚方法 (由子类重写) ---

## 自定义释放检查。
func _custom_can_execute() -> bool:
	return true


## 具体的技能逻辑入口。
## @param targets: 经过筛选后的最终目标数组。
func _on_execute(targets: Array[Object]) -> void:
	pass
