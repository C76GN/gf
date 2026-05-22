## GFSkill: 技能基类。
##
## 负责冷却、施放校验与目标解析入口，
## 具体技能逻辑通过子类重写 `_on_execute()` 实现。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.17.0
class_name GFSkill
extends RefCounted


# --- 信号 ---

## 当技能开始进入冷却时发出。
## [br]
## @api public
## [br]
## @param skill: 进入冷却的技能实例。
signal cooldown_started(skill: GFSkill)


# --- 公共变量 ---

## 技能 ID。
## [br]
## @api public
var id: StringName = &""

## 最大冷却时间。
## [br]
## @api public
var cooldown_max: float = 0.0

## 当前剩余冷却时间。
## [br]
## @api public
var cooldown_left: float = 0.0

## 释放技能所需标签。
## [br]
## @api public
var require_tags: Array[StringName] = []

## 释放技能时禁止存在的标签。
## [br]
## @api public
var ignore_tags: Array[StringName] = []

## 技能拥有者。
## [br]
## @api public
var owner: Object = null

## 技能索敌规则。
## [br]
## @api public
var targeting_rule: GFSkillTargetingRule = null


# --- 私有变量 ---

var _architecture_ref: WeakRef = null


# --- Godot 生命周期方法 ---

func _init(p_owner: Object = null) -> void:
	owner = p_owner


# --- 公共方法 ---

## 更新冷却时间。
## [br]
## @api public
## [br]
## @param p_delta: 本次更新经过的时间。
func update(p_delta: float) -> void:
	if cooldown_left > 0.0:
		cooldown_left = max(0.0, cooldown_left - p_delta)


## 注入当前技能执行所在的架构实例。
## [br]
## @api framework_internal
## [br]
## @param architecture: 当前架构。
func inject_dependencies(architecture: GFArchitecture) -> void:
	_architecture_ref = weakref(architecture) if architecture != null else null


## 检查技能当前是否允许施放。
## [br]
## @api public
## [br]
## @return 可施放时返回 `true`。
func can_execute() -> bool:
	if cooldown_left > 0.0:
		return false

	var valid_owner := _get_valid_owner()
	if valid_owner == null:
		return false

	if not valid_owner.has_method("get_tag_component"):
		return require_tags.is_empty() and _custom_can_execute()

	var tc := valid_owner.get_tag_component() as GFTagComponent
	if tc == null:
		return require_tags.is_empty() and _custom_can_execute()

	for tag in require_tags:
		if not tc.has_tag(tag):
			return false

	for tag in ignore_tags:
		if tc.has_tag(tag):
			return false

	return _custom_can_execute()


## 执行技能。
## [br]
## @api public
## [br]
## @param manual_target: 可选的手动目标。
## [br]
## @param cast_center: 可选施法中心；传入 `null` 时回退到施法者位置。
## [br]
## @return 技能实际执行并进入冷却时返回 `true`。
## [br]
## @schema cast_center: Variant，可为 null 或 Vector2；为 null 时从 owner.global_position 推导。
func execute(manual_target: Object = null, cast_center: Variant = null) -> bool:
	if not can_execute():
		return false

	var final_targets: Array[Object] = []
	var resolved_center := _resolve_cast_center(cast_center)

	if manual_target != null:
		if targeting_rule != null:
			var utility := _get_targeting_utility()
			if utility == null:
				push_error("[GFCombat] GFSkillTargetingUtility 尚未在架构中注册。")
				return false

			var valid_targets := utility.find_targets(resolved_center, targeting_rule, [manual_target])
			if not valid_targets.is_empty():
				final_targets.append(manual_target)
			else:
				return false
		else:
			final_targets.append(manual_target)
	elif targeting_rule != null:
		var candidates: Array = []
		var valid_owner := _get_valid_owner()
		if valid_owner != null and valid_owner.has_method(&"get_targeting_candidates"):
			candidates = valid_owner.call(&"get_targeting_candidates")
		elif has_method(&"get_targeting_candidates"):
			candidates = call(&"get_targeting_candidates")

		var utility := _get_targeting_utility()
		if utility == null:
			push_error("[GFCombat] GFSkillTargetingUtility 尚未在架构中注册。")
			return false

		final_targets = utility.find_targets(resolved_center, targeting_rule, candidates)

	if targeting_rule != null and targeting_rule.max_count > 0 and final_targets.is_empty():
		return false

	if not _try_execute(final_targets):
		return false
	cooldown_left = cooldown_max
	cooldown_started.emit(self)
	return true


# --- 可重写钩子 / 虚方法 ---

## 自定义施放检查。
## [br]
## @api protected
## [br]
## @return 允许施放时返回 `true`。
func _custom_can_execute() -> bool:
	return true


## 具体技能逻辑入口。
## [br]
## @api protected
## [br]
## @param targets: 经过筛选后的最终目标数组。
## [br]
## @schema targets: Array[Object]，经过 targeting_rule 或手动目标校验后的最终目标列表。
func _on_execute(targets: Array[Object]) -> void:
	pass


## 可报告成功/失败的技能执行入口。默认调用旧的 `_on_execute()` 钩子并视为成功。
## [br]
## @api protected
## [br]
## @param targets: 经过筛选后的最终目标数组。
## [br]
## @return 技能真正生效时返回 `true`。
## [br]
## @schema targets: Array[Object]，经过 targeting_rule 或手动目标校验后的最终目标列表。
func _try_execute(targets: Array[Object]) -> bool:
	_on_execute(targets)
	return true


# --- 私有/辅助方法 ---

func _resolve_cast_center(cast_center: Variant) -> Vector2:
	if cast_center is Vector2:
		return cast_center

	var valid_owner := _get_valid_owner()
	if valid_owner != null and "global_position" in valid_owner:
		return valid_owner.global_position

	return Vector2.ZERO


func _get_valid_owner() -> Object:
	if owner == null or not is_instance_valid(owner):
		return null
	return owner


func _get_targeting_utility() -> GFSkillTargetingUtility:
	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null

	return architecture.get_utility(GFSkillTargetingUtility) as GFSkillTargetingUtility


func _get_architecture_or_null() -> GFArchitecture:
	if _architecture_ref != null:
		var architecture := _architecture_ref.get_ref() as GFArchitecture
		if architecture != null:
			return architecture
	return GFAutoload.get_architecture_or_null()
