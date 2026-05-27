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

## 当技能激活失败时发出。
## [br]
## @api public
## [br]
## @param skill: 激活失败的技能实例。
## [br]
## @param context: 技能激活上下文。
signal activation_failed(skill: GFSkill, context)

## 当技能完成激活提交并进入冷却时发出。
## [br]
## @api public
## [br]
## @param skill: 已提交的技能实例。
## [br]
## @param context: 技能激活上下文。
signal activation_committed(skill: GFSkill, context)


# --- 常量 ---

const _GF_SKILL_ACTIVATION_CONTEXT: Script = preload("res://addons/gf/extensions/combat/skills/gf_skill_activation_context.gd")


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

## 可选标签查询。为空时使用 require_tags / ignore_tags。
## [br]
## @api public
var activation_query: GFTagQuery = null

## 激活检查回调。每个回调接收 GFSkillActivationContext，可返回 bool 或 { ok, reason, metadata }。
## [br]
## @api public
## [br]
## @schema activation_checks: Array[Callable]，用于项目自定义成本、状态或上下文检查。
var activation_checks: Array[Callable] = []

## 激活提交回调。检查和目标解析通过后、执行技能逻辑前调用。
## [br]
## @api public
## [br]
## @schema activation_commit_callbacks: Array[Callable]，用于项目自定义成本提交、资源预留或日志写入。
var activation_commit_callbacks: Array[Callable] = []


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
	return bool(get_activation_report().get("ok", false))


## 创建技能激活上下文。
## [br]
## @api public
## [br]
## @param manual_target: 可选的手动目标。
## [br]
## @param cast_center: 可选施法中心；传入 `null` 时回退到施法者位置。
## [br]
## @param activation_metadata: 项目自定义激活元数据。
## [br]
## @return 技能激活上下文。
## [br]
## @schema cast_center: Variant，可为 null 或 Vector2；为 null 时从 owner.global_position 推导。
## [br]
## @schema activation_metadata: Dictionary，复制到上下文中供项目检查、提交或诊断使用。
func build_activation_context(
	manual_target: Object = null,
	cast_center: Variant = null,
	activation_metadata: Dictionary = {}
) -> RefCounted:
	var context := _GF_SKILL_ACTIVATION_CONTEXT.new() as RefCounted
	context.call(
		"configure",
		self,
		_get_valid_owner(),
		manual_target,
		cast_center,
		_resolve_cast_center(cast_center),
		activation_metadata
	)
	return context


## 获取技能激活报告。
## [br]
## @api public
## [br]
## @param context: 可选激活上下文；为空时创建默认上下文。
## [br]
## @return 激活报告。
## [br]
## @schema return: Dictionary，包含 ok、reason、skill_id、target_count 和 metadata。
func get_activation_report(context: RefCounted = null) -> Dictionary:
	var activation_context := context if context != null else build_activation_context()
	return _validate_activation_context(activation_context, true)


## 执行技能。
## [br]
## @api public
## [br]
## @param manual_target: 可选的手动目标。
## [br]
## @param cast_center: 可选施法中心；传入 `null` 时回退到施法者位置。
## [br]
## @param activation_metadata: 项目自定义激活元数据。
## [br]
## @return 技能实际执行并进入冷却时返回 `true`。
## [br]
## @schema cast_center: Variant，可为 null 或 Vector2；为 null 时从 owner.global_position 推导。
## [br]
## @schema activation_metadata: Dictionary，复制到上下文中供项目检查、提交或诊断使用。
func execute(
	manual_target: Object = null,
	cast_center: Variant = null,
	activation_metadata: Dictionary = {}
) -> bool:
	var context := build_activation_context(manual_target, cast_center, activation_metadata)
	var report := _validate_activation_context(context, false)
	if not bool(report.get("ok", false)):
		activation_failed.emit(self, context)
		return false

	if not _resolve_activation_targets(context):
		activation_failed.emit(self, context)
		return false

	report = _run_activation_callbacks(context, activation_checks, &"activation_check_failed")
	if not bool(report.get("ok", false)):
		activation_failed.emit(self, context)
		return false

	report = _run_activation_callbacks(context, activation_commit_callbacks, &"activation_commit_failed")
	if not bool(report.get("ok", false)):
		activation_failed.emit(self, context)
		return false

	if not _try_activate(context):
		_fail_activation_context(context, &"execute_failed")
		activation_failed.emit(self, context)
		return false
	cooldown_left = cooldown_max
	cooldown_started.emit(self)
	activation_committed.emit(self, context)
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


## 基于激活上下文执行技能。默认桥接到旧的 `_try_execute()`。
## [br]
## @api protected
## [br]
## @param context: 技能激活上下文。
## [br]
## @return 技能真正生效时返回 `true`。
func _try_activate(context: RefCounted) -> bool:
	var targets := context.get("targets") as Array
	var typed_targets: Array[Object] = []
	if targets != null:
		for target: Variant in targets:
			if target is Object:
				typed_targets.append(target as Object)
	return _try_execute(typed_targets)


# --- 私有/辅助方法 ---

func _validate_activation_context(context: RefCounted, include_callbacks: bool) -> Dictionary:
	if context == null:
		return {
			"ok": false,
			"reason": &"invalid_context",
			"metadata": {},
		}
	if cooldown_left > 0.0:
		return _fail_activation_context(context, &"cooldown")

	var valid_owner := context.get("owner") as Object
	if valid_owner == null or not is_instance_valid(valid_owner):
		return _fail_activation_context(context, &"invalid_owner")

	var tag_source: Variant = _get_owner_tag_source(valid_owner)
	if not _validate_required_tags(context, tag_source):
		return context.call("to_report") as Dictionary
	if not _validate_blocked_tags(context, tag_source):
		return context.call("to_report") as Dictionary
	if activation_query != null and not activation_query.matches(tag_source):
		var query_report := activation_query.get_match_report(tag_source)
		return _fail_activation_context(context, &"activation_query_failed", {
			"query_report": query_report,
		})
	if not _custom_can_execute():
		return _fail_activation_context(context, &"custom_check_failed")
	if include_callbacks:
		return _run_activation_callbacks(context, activation_checks, &"activation_check_failed")
	return context.call("to_report") as Dictionary


func _validate_required_tags(context: RefCounted, tag_source: Variant) -> bool:
	for tag: StringName in require_tags:
		if not GFTagSourceAdapter.source_has_tag(tag_source, tag):
			_fail_activation_context(context, &"missing_required_tag", {
				"tag": tag,
			})
			return false
	return true


func _validate_blocked_tags(context: RefCounted, tag_source: Variant) -> bool:
	for tag: StringName in ignore_tags:
		if GFTagSourceAdapter.source_has_tag(tag_source, tag):
			_fail_activation_context(context, &"blocked_tag", {
				"tag": tag,
			})
			return false
	return true


func _resolve_activation_targets(context: RefCounted) -> bool:
	var final_targets: Array[Object] = []
	var manual_target := context.get("manual_target") as Object
	var resolved_center := context.get("resolved_center") as Vector2

	if manual_target != null:
		if targeting_rule != null:
			var utility := _get_targeting_utility()
			if utility == null:
				push_error("[GFCombat] GFSkillTargetingUtility 尚未在架构中注册。")
				_fail_activation_context(context, &"targeting_utility_missing")
				return false

			var valid_targets := utility.find_targets(resolved_center, targeting_rule, [manual_target])
			if not valid_targets.is_empty():
				final_targets.append(manual_target)
			else:
				_fail_activation_context(context, &"invalid_manual_target")
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
			_fail_activation_context(context, &"targeting_utility_missing")
			return false

		final_targets = utility.find_targets(resolved_center, targeting_rule, candidates)

	if targeting_rule != null and targeting_rule.max_count > 0 and final_targets.is_empty():
		_fail_activation_context(context, &"no_targets")
		return false

	context.set("targets", final_targets)
	return true


func _run_activation_callbacks(
	context: RefCounted,
	callbacks: Array[Callable],
	default_reason: StringName
) -> Dictionary:
	for callback: Callable in callbacks:
		if not callback.is_valid():
			continue
		var result: Variant = callback.call(context)
		var report := _apply_activation_callback_result(context, result, default_reason)
		if not bool(report.get("ok", false)):
			return report
	return context.call("to_report") as Dictionary


func _apply_activation_callback_result(
	context: RefCounted,
	result: Variant,
	default_reason: StringName
) -> Dictionary:
	if result is Dictionary:
		var result_data := result as Dictionary
		var metadata_value: Variant = result_data.get("metadata", {})
		var metadata := metadata_value as Dictionary if metadata_value is Dictionary else {}
		if bool(result_data.get("ok", true)):
			_merge_activation_metadata(context, metadata)
			return context.call("to_report") as Dictionary
		var reason := StringName(String(result_data.get("reason", default_reason)))
		return _fail_activation_context(context, reason, metadata)
	if result is bool and not bool(result):
		return _fail_activation_context(context, default_reason)
	return context.call("to_report") as Dictionary


func _merge_activation_metadata(context: RefCounted, extra_metadata: Dictionary) -> void:
	var metadata := context.get("metadata") as Dictionary
	if metadata == null:
		metadata = {}
	for key: Variant in extra_metadata.keys():
		metadata[key] = GFVariantData.duplicate_variant(extra_metadata[key])
	context.set("metadata", metadata)


func _fail_activation_context(
	context: RefCounted,
	reason: StringName,
	extra_metadata: Dictionary = {}
) -> Dictionary:
	if context != null and context.has_method("fail"):
		context.call("fail", reason, extra_metadata)
	if context != null and context.has_method("to_report"):
		return context.call("to_report") as Dictionary
	return {
		"ok": false,
		"reason": reason,
		"metadata": extra_metadata.duplicate(true),
	}


func _get_owner_tag_source(valid_owner: Object) -> Variant:
	if valid_owner.has_method("get_tag_component"):
		return valid_owner.call("get_tag_component")
	if valid_owner.has_method("get_tags") or valid_owner.has_method("has_tag") or valid_owner.has_method("get_tag_count"):
		return valid_owner
	return null

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
