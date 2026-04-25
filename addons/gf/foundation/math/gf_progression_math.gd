## GFProgressionMath: 挂机与模拟经营项目的纯进度曲线数学工具。
##
## 负责价格曲线、收益曲线、里程碑倍率、软上限与分段式离线收益结算。
## 它不依赖 GFArchitecture，可直接与 JSON/CSV/Luban 等导出的配置字典配合使用。
class_name GFProgressionMath
extends RefCounted


# --- 枚举 ---

## 支持的基础曲线类型。
enum CurveMode {
	## 常量曲线。
	CONSTANT,
	## 线性曲线。
	LINEAR,
	## 指数曲线。
	EXPONENTIAL,
}


# --- 常量 ---

const _BIG_NUMBER_SCRIPT: Script = preload("res://addons/gf/foundation/numeric/gf_big_number.gd")

## 默认的软上限幂指数。
const _DEFAULT_SOFT_CAP_POWER: float = 0.5


# --- 公共方法 ---

## 根据配置计算某一级的曲线值。
## @param level: 目标等级。
## @param curve_config: 支持 `base_value/start_level/mode/per_level/multiplier/phases/overrides`。
## @return 对应等级的曲线值。
static func evaluate_curve(level: int, curve_config: Dictionary) -> Object:
	var target_level: int = maxi(level, 0)
	var override_value: Variant = _find_override_value(target_level, curve_config.get("overrides", {}))
	if override_value != null:
		return _to_big_number(override_value)

	var phases: Array = curve_config.get("phases", [])
	if not phases.is_empty():
		return _evaluate_piecewise_curve(target_level, phases, curve_config)

	return _evaluate_single_curve(target_level, curve_config)


## 为基础值叠加里程碑倍率。
## @param value: 基础数值。
## @param level: 当前等级。
## @param milestones: 里程碑数组；每项支持 `level/multiplier`。
## @return 叠加后的数值。
static func apply_milestone_multipliers(value: Variant, level: int, milestones: Array) -> Object:
	var result: Object = _to_big_number(value)
	var target_level: int = maxi(level, 0)

	for milestone_variant in milestones:
		if typeof(milestone_variant) != TYPE_DICTIONARY:
			continue

		var milestone: Dictionary = milestone_variant
		var required_level: int = int(milestone.get("level", 0))
		if target_level < required_level:
			continue

		var multiplier: float = _to_float(milestone.get("multiplier", 1.0))
		result = result.multiply(_to_big_number(multiplier))

	return result


## 对一个值应用幂函数型软上限。
## @param value: 原始值。
## @param soft_cap: 软上限起点。
## @param power: 超出部分的幂指数；0.5 表示平方根衰减。
## @return 软上限处理后的数值。
static func apply_soft_cap(
	value: Variant,
	soft_cap: Variant,
	power: float = _DEFAULT_SOFT_CAP_POWER
) -> Object:
	var big_value: Object = _to_big_number(value)
	var cap_value: Object = _to_big_number(soft_cap)

	if power <= 0.0:
		push_error("[GFProgressionMath] soft cap power 必须大于 0。")
		return cap_value

	if big_value.compare_to(cap_value) <= 0 or is_equal_approx(power, 1.0):
		return big_value

	var overflow: Object = big_value.subtract(cap_value)
	var softened_overflow: Object = overflow.powf(power)
	return cap_value.add(softened_overflow)


## 计算一段离线时间内的收益。
## @param rate_per_second: 基础每秒产出。
## @param offline_seconds: 离线时长（秒）。
## @param options: 支持 `max_seconds/storage_remaining/segments`。
## @return 包含产出与时间统计的字典。
static func settle_offline_progress(
	rate_per_second: Variant,
	offline_seconds: float,
	options: Dictionary = {}
) -> Dictionary:
	var base_rate: Object = _to_big_number(rate_per_second)
	var zero_value: Object = _to_big_number(0)
	var requested_seconds: float = maxf(offline_seconds, 0.0)
	var settled_seconds: float = requested_seconds
	if options.has("max_seconds"):
		settled_seconds = minf(settled_seconds, maxf(_to_float(options.get("max_seconds", 0.0)), 0.0))

	var total_produced: Object = _to_big_number(0)
	var consumed_seconds: float = 0.0
	var storage_capped: bool = false
	var segments: Array = options.get("segments", [])
	var remaining_seconds: float = settled_seconds
	var has_storage_limit: bool = options.has("storage_remaining")
	var storage_remaining: Object = null

	if has_storage_limit:
		storage_remaining = _to_big_number(options.get("storage_remaining", 0))
		if storage_remaining.compare_to(zero_value) <= 0:
			storage_remaining = zero_value

	for segment_variant in segments:
		if remaining_seconds <= 0.0 or storage_capped:
			break

		if typeof(segment_variant) != TYPE_DICTIONARY:
			continue

		var segment: Dictionary = segment_variant
		var configured_duration: float = maxf(_to_float(segment.get("duration_seconds", 0.0)), 0.0)
		if configured_duration <= 0.0:
			continue

		var run_seconds: float = minf(configured_duration, remaining_seconds)
		var segment_result: Dictionary = _settle_segment(
			base_rate,
			run_seconds,
			segment,
			storage_remaining
		)
		total_produced = total_produced.add(segment_result["produced"])
		consumed_seconds += float(segment_result["consumed_seconds"])
		remaining_seconds -= run_seconds

		if has_storage_limit:
			storage_remaining = storage_remaining.subtract(segment_result["produced"])
			if storage_remaining.compare_to(zero_value) <= 0:
				storage_remaining = zero_value

		if bool(segment_result["storage_capped"]):
			storage_capped = true

	if remaining_seconds > 0.0 and not storage_capped:
		var default_result: Dictionary = _settle_segment(
			base_rate,
			remaining_seconds,
			{},
			storage_remaining
		)
		total_produced = total_produced.add(default_result["produced"])
		consumed_seconds += float(default_result["consumed_seconds"])

		if bool(default_result["storage_capped"]):
			storage_capped = true

	var expired_seconds: float = requested_seconds - settled_seconds
	var wasted_seconds: float = settled_seconds - consumed_seconds
	if expired_seconds < 0.0:
		expired_seconds = 0.0
	if wasted_seconds < 0.0:
		wasted_seconds = 0.0

	return {
		"produced": total_produced,
		"requested_seconds": requested_seconds,
		"settled_seconds": settled_seconds,
		"consumed_seconds": consumed_seconds,
		"expired_seconds": expired_seconds,
		"wasted_seconds": wasted_seconds,
		"storage_capped": storage_capped,
	}


# --- 私有/辅助方法 ---

static func _evaluate_single_curve(level: int, curve_config: Dictionary) -> Object:
	var start_level: int = int(curve_config.get("start_level", 0))
	var anchor_value: Object = _resolve_anchor_value(curve_config, curve_config, null)
	return _evaluate_phase(level, curve_config, anchor_value, start_level)


static func _evaluate_piecewise_curve(level: int, phases: Array, curve_config: Dictionary) -> Object:
	var sorted_phases: Array[Dictionary] = _sort_phase_configs(phases)
	if sorted_phases.is_empty():
		return _evaluate_single_curve(level, curve_config)

	var current_index: int = 0
	for i in range(sorted_phases.size()):
		var phase_start: int = int(sorted_phases[i].get("start_level", 0))
		if phase_start <= level:
			current_index = i
		else:
			break

	var anchor_level: int = int(sorted_phases[0].get("start_level", 0))
	var anchor_value: Object = _resolve_anchor_value(sorted_phases[0], curve_config, null)
	var current_phase: Dictionary = sorted_phases[0]

	for i in range(1, current_index + 1):
		var next_phase: Dictionary = sorted_phases[i]
		var next_start: int = int(next_phase.get("start_level", 0))
		var inherited_value: Object = _evaluate_phase(next_start, current_phase, anchor_value, anchor_level)
		anchor_value = _resolve_anchor_value(next_phase, curve_config, inherited_value)
		anchor_level = next_start
		current_phase = next_phase

	return _evaluate_phase(level, current_phase, anchor_value, anchor_level)


static func _evaluate_phase(
	level: int,
	phase_config: Dictionary,
	anchor_value: Object,
	anchor_level: int
) -> Object:
	var delta_levels: int = maxi(level - anchor_level, 0)
	var curve_mode: CurveMode = _parse_curve_mode(phase_config.get("mode", CurveMode.CONSTANT))

	match curve_mode:
		CurveMode.CONSTANT:
			return anchor_value.clone()

		CurveMode.LINEAR:
			var per_level: Object = _to_big_number(phase_config.get("per_level", 0))
			return anchor_value.add(per_level.multiply(_to_big_number(delta_levels)))

		CurveMode.EXPONENTIAL:
			var multiplier: float = _to_float(phase_config.get("multiplier", 1.0))
			if multiplier <= 0.0:
				push_error("[GFProgressionMath] 指数曲线 multiplier 必须大于 0。")
				return anchor_value.clone()

			if delta_levels == 0:
				return anchor_value.clone()

			return anchor_value.multiply(_to_big_number(multiplier).powi(delta_levels))

	return anchor_value.clone()


static func _settle_segment(
	base_rate: Object,
	duration_seconds: float,
	segment: Dictionary,
	storage_remaining: Variant
) -> Dictionary:
	var zero_value: Object = _to_big_number(0)
	if duration_seconds <= 0.0:
		return {
			"produced": zero_value,
			"consumed_seconds": 0.0,
			"storage_capped": false,
		}

	var segment_rate: Object = _resolve_segment_rate(base_rate, segment)
	if segment_rate.compare_to(zero_value) <= 0:
		return {
			"produced": zero_value,
			"consumed_seconds": duration_seconds,
			"storage_capped": false,
		}

	var produced: Object = segment_rate.multiply(_to_big_number(duration_seconds))
	var consumed_seconds: float = duration_seconds
	var storage_capped: bool = false

	if storage_remaining != null and produced.compare_to(storage_remaining) > 0:
		produced = storage_remaining.clone()
		storage_capped = true
		consumed_seconds = storage_remaining.divide(segment_rate).to_float()
		consumed_seconds = clampf(consumed_seconds, 0.0, duration_seconds)

	return {
		"produced": produced,
		"consumed_seconds": consumed_seconds,
		"storage_capped": storage_capped,
	}


static func _resolve_segment_rate(base_rate: Object, segment: Dictionary) -> Object:
	var rate: Object = base_rate.clone()
	if segment.has("rate_per_second"):
		rate = _to_big_number(segment.get("rate_per_second"))

	var multiplier: float = _to_float(segment.get("multiplier", 1.0))
	rate = rate.multiply(_to_big_number(multiplier))

	if segment.has("bonus_per_second"):
		rate = rate.add(_to_big_number(segment.get("bonus_per_second", 0)))

	return rate


static func _resolve_anchor_value(
	phase_config: Dictionary,
	curve_config: Dictionary,
	inherited_value: Variant
) -> Object:
	if phase_config.has("base_value"):
		return _to_big_number(phase_config.get("base_value"))

	if inherited_value != null:
		return inherited_value

	if curve_config.has("base_value"):
		return _to_big_number(curve_config.get("base_value"))

	push_error("[GFProgressionMath] 曲线配置缺少 base_value。")
	return _to_big_number(0)


static func _find_override_value(level: int, overrides: Variant) -> Variant:
	if typeof(overrides) != TYPE_DICTIONARY:
		return null

	var override_dict: Dictionary = overrides
	if override_dict.has(level):
		return override_dict[level]

	var level_key := str(level)
	if override_dict.has(level_key):
		return override_dict[level_key]

	return null


static func _sort_phase_configs(phases: Array) -> Array[Dictionary]:
	var sorted: Array[Dictionary] = []

	for phase_variant in phases:
		if typeof(phase_variant) != TYPE_DICTIONARY:
			continue

		var phase: Dictionary = phase_variant
		var phase_start: int = int(phase.get("start_level", 0))
		var inserted: bool = false

		for i in range(sorted.size()):
			var current_start: int = int(sorted[i].get("start_level", 0))
			if phase_start < current_start:
				sorted.insert(i, phase)
				inserted = true
				break

		if not inserted:
			sorted.append(phase)

	return sorted


static func _parse_curve_mode(mode_value: Variant) -> CurveMode:
	match typeof(mode_value):
		TYPE_INT:
			if mode_value == CurveMode.LINEAR:
				return CurveMode.LINEAR
			if mode_value == CurveMode.EXPONENTIAL:
				return CurveMode.EXPONENTIAL
			return CurveMode.CONSTANT

		TYPE_STRING, TYPE_STRING_NAME:
			var mode_text := str(mode_value).to_lower()
			if mode_text == "linear":
				return CurveMode.LINEAR
			if mode_text == "exponential":
				return CurveMode.EXPONENTIAL
			return CurveMode.CONSTANT

	return CurveMode.CONSTANT


static func _get_big_number_script() -> Script:
	return _BIG_NUMBER_SCRIPT


static func _to_big_number(value: Variant) -> Object:
	return _get_big_number_script().from_variant(value)


static func _to_float(value: Variant) -> float:
	match typeof(value):
		TYPE_INT:
			return float(value)
		TYPE_FLOAT:
			return value
		TYPE_STRING, TYPE_STRING_NAME:
			return str(value).to_float()
		_:
			if is_instance_valid(value) and value.has_method("to_float"):
				return value.to_float()

	return 0.0
