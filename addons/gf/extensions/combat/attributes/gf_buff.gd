## GFBuff: 状态效果基类。
##
## 管理 Buff 的生命周期、层数以及对属性/标签的影响。
## 在 GFCombatSystem 的 tick 中驱动 update。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.17.0
class_name GFBuff
extends RefCounted


# --- 枚举 ---

## 重复添加同 ID Buff 时的层数策略。
## [br]
## @api public
enum StackMode {
	## 只刷新持续时间，不改变层数。
	REFRESH_ONLY,
	## 刷新持续时间，并在 max_stacks 允许时增加层数。
	ADD_STACK,
	## 忽略重复添加，不刷新持续时间或层数。
	IGNORE,
}

## 重复添加同 ID Buff 时的持续时间刷新策略。
## [br]
## @api public
enum DurationRefreshPolicy {
	## 保持当前剩余时间。
	KEEP_CURRENT,
	## 使用新的持续时间重置剩余时间。
	RESET_TO_NEW_DURATION,
	## 将新的持续时间追加到当前剩余时间。
	EXTEND_BY_NEW_DURATION,
	## 保留当前剩余时间与新持续时间中较长者。
	KEEP_LONGER_REMAINING,
}


# --- 公共变量 ---

## Buff 的唯一标识名（通常用于排斥逻辑）。
## [br]
## @api public
var id: StringName = &""

## Buff 的总持续时间（秒）。如果为 -1 则视为永久 Buff。
## [br]
## @api public
var duration: float = 0.0

## 当前剩余剩余时间。
## [br]
## @api public
var time_left: float = 0.0

## 当前层数。
## [br]
## @api public
var stacks: int = 1

## 最大层数。
## [br]
## @api public
var max_stacks: int = 1

## 重复添加同 ID Buff 时的层数策略。
## [br]
## @api public
var stack_mode: StackMode = StackMode.ADD_STACK

## 重复添加同 ID Buff 时的持续时间刷新策略。
## [br]
## @api public
var duration_refresh_policy: DurationRefreshPolicy = DurationRefreshPolicy.RESET_TO_NEW_DURATION

## 周期 Tick 间隔。小于等于 0 时保持每帧调用 on_tick() 的旧行为。
## [br]
## @api public
var tick_interval_seconds: float = 0.0

## 单次 update 允许补偿触发的最大周期 Tick 次数。小于等于 0 时不限制。
## [br]
## @api public
var max_periodic_ticks_per_update: int = 8

## 持续时间耗尽时是否由 CombatSystem 移除。
## [br]
## @api public
var remove_on_expire: bool = true

## Buff 携带的属性修饰器列表。应用时会自动挂载到宿主的 Attribute 上。
## [br]
## @api public
var modifiers: Array[GFModifier] = []

## Buff 携带的标签列表。应用时会自动挂载到宿主的 TagComponent 上。
## [br]
## @api public
var tags: Array[StringName] = []

## Buff 的拥有者（通常是一个持有 Combat 数据的 Object）。
## [br]
## @api public
var owner: Object = null


# --- 私有变量 ---

var _tick_accumulator: float = 0.0


# --- 公共方法 ---

## 初始化 Buff，由系统或工厂调用。
## [br]
## @api public
## [br]
## @param p_id: Buff 标识。
## [br]
## @param p_duration: Buff 持续时间（秒）。
## [br]
## @param p_owner: Buff 所属对象。
func setup(p_id: StringName, p_duration: float, p_owner: Object) -> void:
	id = p_id
	duration = p_duration
	time_left = duration
	owner = p_owner
	_tick_accumulator = 0.0


## 当 Buff 首次应用时触发。
## [br]
## @api public
func on_apply() -> void:
	_apply_effects()


## 当 Buff 被移除时触发。
## [br]
## @api public
func on_remove() -> void:
	_remove_effects()


## 当 Buff 层数增加时触发（通常用于刷新持续时间）。
## [br]
## @api public
## [br]
## @param p_new_duration: 刷新后的持续时间（秒）。
func on_refresh(p_new_duration: float) -> void:
	if stack_mode == StackMode.IGNORE:
		return

	_apply_refresh_duration(p_new_duration)
	if stack_mode == StackMode.ADD_STACK and max_stacks > 1:
		stacks = mini(stacks + 1, max_stacks)


## 使用同 ID 的新 Buff 刷新当前运行中实例。
## [br]
## @api public
## [br]
## @param source_buff: 本次尝试添加的新 Buff。
func refresh_from(source_buff: GFBuff) -> void:
	if source_buff == null:
		return
	on_refresh(source_buff.duration)


## 周期性触发逻辑。
## [br]
## @api public
## [br]
## @param _p_delta: 帧间隔。
func on_tick(_p_delta: float) -> void:
	pass


## 内部状态更新流程。
## [br]
## @api public
## [br]
## @param p_delta: 帧间隔。
## [br]
## @return 如果 Buff 已耗尽生命周期需要被移除，则返回 true。
func update(p_delta: float) -> bool:
	var step_delta: float = maxf(0.0, p_delta)
	if duration != -1.0:
		time_left -= step_delta
		if time_left <= 0.0:
			if remove_on_expire:
				return true
			time_left = 0.0

	_update_periodic_tick(step_delta)
	return false


# --- 私有/辅助方法 ---

func _apply_refresh_duration(p_new_duration: float) -> void:
	match duration_refresh_policy:
		DurationRefreshPolicy.KEEP_CURRENT:
			return
		DurationRefreshPolicy.EXTEND_BY_NEW_DURATION:
			_extend_duration(p_new_duration)
		DurationRefreshPolicy.KEEP_LONGER_REMAINING:
			_keep_longer_duration(p_new_duration)
		_:
			duration = p_new_duration
			time_left = p_new_duration


func _extend_duration(p_new_duration: float) -> void:
	duration = p_new_duration
	if time_left == -1.0 or p_new_duration == -1.0:
		duration = -1.0
		time_left = -1.0
		return

	time_left += maxf(0.0, p_new_duration)


func _keep_longer_duration(p_new_duration: float) -> void:
	if time_left == -1.0 or p_new_duration == -1.0:
		duration = -1.0
		time_left = -1.0
		return

	duration = maxf(duration, p_new_duration)
	time_left = maxf(time_left, p_new_duration)


func _update_periodic_tick(p_delta: float) -> void:
	if tick_interval_seconds <= 0.0:
		on_tick(p_delta)
		return

	_tick_accumulator += p_delta
	var tick_budget: int = max_periodic_ticks_per_update
	var tick_count: int = 0
	while _tick_accumulator >= tick_interval_seconds and (tick_budget <= 0 or tick_count < tick_budget):
		_tick_accumulator -= tick_interval_seconds
		on_tick(tick_interval_seconds)
		tick_count += 1
	if tick_budget > 0 and tick_count >= tick_budget and _tick_accumulator >= tick_interval_seconds:
		_tick_accumulator = minf(_tick_accumulator, tick_interval_seconds)


# 应用 Buff 携带的所有效果。
func _apply_effects() -> void:
	var valid_owner: Object = _get_valid_owner()
	if valid_owner == null:
		return

	if valid_owner.has_method("get_tag_component"):
		var tag_component: GFTagComponent = _get_tag_component_value(valid_owner.call("get_tag_component"))
		if tag_component != null:
			for tag: StringName in tags:
				tag_component.add_tag(tag)

	if valid_owner.has_method("get_attribute"):
		for mod: GFModifier in modifiers:
			if mod == null or mod.attribute_id == &"":
				continue

			var attribute: GFModifiedAttribute = _get_modified_attribute_value(valid_owner.call("get_attribute", mod.attribute_id))
			if attribute != null:
				attribute.add_modifier(mod)


# 移除 Buff 携带的所有效果。
func _remove_effects() -> void:
	var valid_owner: Object = _get_valid_owner()
	if valid_owner == null:
		return

	if valid_owner.has_method("get_tag_component"):
		var tag_component: GFTagComponent = _get_tag_component_value(valid_owner.call("get_tag_component"))
		if tag_component != null:
			for tag: StringName in tags:
				tag_component.remove_tag(tag)

	if valid_owner.has_method("get_attribute"):
		for mod: GFModifier in modifiers:
			if mod == null or mod.attribute_id == &"":
				continue

			var attribute: GFModifiedAttribute = _get_modified_attribute_value(valid_owner.call("get_attribute", mod.attribute_id))
			if attribute != null:
				attribute.remove_modifier(mod)


func _get_valid_owner() -> Object:
	if owner == null or not is_instance_valid(owner):
		return null
	return owner


func _get_tag_component_value(value: Variant) -> GFTagComponent:
	if value is GFTagComponent:
		var tag_component: GFTagComponent = value
		return tag_component
	return null


func _get_modified_attribute_value(value: Variant) -> GFModifiedAttribute:
	if value is GFModifiedAttribute:
		var attribute: GFModifiedAttribute = value
		return attribute
	return null
