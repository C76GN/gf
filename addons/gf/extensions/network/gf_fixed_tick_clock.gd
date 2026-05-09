## GFFixedTickClock: 固定步长 tick 时钟。
##
## 用于网络同步、重放、确定性逻辑或任意固定频率调度；它只计算 tick 推进，不执行项目规则。
class_name GFFixedTickClock
extends RefCounted


# --- 信号 ---

## tick 推进后发出。
signal ticks_advanced(previous_tick: int, current_tick: int, step_count: int)


# --- 公共变量 ---

## 每秒 tick 数。
var tick_rate: float = 30.0

## 当前 tick。
var current_tick: int = 0

## 累积但尚未消费的时间。
var accumulator_seconds: float = 0.0

## 单次 advance() 最多推进的 tick 数；小于等于 0 表示不限制。
var max_steps_per_update: int = 8

## 达到单次预算上限时是否丢弃过量累积时间，避免长时间追帧。
var drop_excess_time_on_budget_hit: bool = true


# --- Godot 生命周期方法 ---

func _init(p_tick_rate: float = 30.0, p_start_tick: int = 0) -> void:
	tick_rate = maxf(p_tick_rate, 0.001)
	current_tick = p_start_tick


# --- 公共方法 ---

## 配置时钟。
## @param p_tick_rate: 每秒 tick 数。
## @param p_max_steps_per_update: 单次 advance() 最大步数；小于 0 表示保留原值。
func configure(p_tick_rate: float, p_max_steps_per_update: int = -1) -> void:
	tick_rate = maxf(p_tick_rate, 0.001)
	if p_max_steps_per_update >= 0:
		max_steps_per_update = p_max_steps_per_update


## 重置时钟。
## @param start_tick: 起始 tick。
func reset(start_tick: int = 0) -> void:
	current_tick = start_tick
	accumulator_seconds = 0.0


## 推进时钟并返回应执行的固定步数。
## @param delta_seconds: 本次累积的真实时间。
## @return 应执行的固定 tick 数。
func advance(delta_seconds: float) -> int:
	if delta_seconds <= 0.0:
		return 0

	accumulator_seconds += delta_seconds
	var tick_seconds := get_tick_seconds()
	var available_steps := int(floor(accumulator_seconds / tick_seconds))
	if available_steps <= 0:
		return 0

	var step_count := available_steps
	if max_steps_per_update > 0:
		step_count = mini(step_count, max_steps_per_update)

	var previous_tick := current_tick
	current_tick += step_count
	accumulator_seconds -= tick_seconds * step_count
	if (
		drop_excess_time_on_budget_hit
		and max_steps_per_update > 0
		and available_steps > max_steps_per_update
	):
		accumulator_seconds = minf(accumulator_seconds, tick_seconds)

	ticks_advanced.emit(previous_tick, current_tick, step_count)
	return step_count


## 手动推进一个 tick。
## @return 推进后的当前 tick。
func step_once() -> int:
	var previous_tick := current_tick
	current_tick += 1
	ticks_advanced.emit(previous_tick, current_tick, 1)
	return current_tick


## 获取单个 tick 的秒数。
## @return tick 秒数。
func get_tick_seconds() -> float:
	return 1.0 / maxf(tick_rate, 0.001)


## 获取插值 alpha。
## @return 0 到 1 的累积时间比例。
func get_interpolation_alpha() -> float:
	return clampf(accumulator_seconds / get_tick_seconds(), 0.0, 1.0)


## 转为字典。
## @return 时钟状态字典。
func to_dict() -> Dictionary:
	return {
		"tick_rate": tick_rate,
		"current_tick": current_tick,
		"accumulator_seconds": accumulator_seconds,
		"max_steps_per_update": max_steps_per_update,
		"drop_excess_time_on_budget_hit": drop_excess_time_on_budget_hit,
	}


## 从字典恢复。
## @param data: 时钟状态字典。
func from_dict(data: Dictionary) -> void:
	tick_rate = maxf(float(data.get("tick_rate", tick_rate)), 0.001)
	current_tick = int(data.get("current_tick", current_tick))
	accumulator_seconds = maxf(float(data.get("accumulator_seconds", accumulator_seconds)), 0.0)
	max_steps_per_update = int(data.get("max_steps_per_update", max_steps_per_update))
	drop_excess_time_on_budget_hit = bool(data.get("drop_excess_time_on_budget_hit", drop_excess_time_on_budget_hit))


## 获取调试快照。
## @return 调试信息字典。
func get_debug_snapshot() -> Dictionary:
	var snapshot := to_dict()
	snapshot["tick_seconds"] = get_tick_seconds()
	snapshot["interpolation_alpha"] = get_interpolation_alpha()
	return snapshot
