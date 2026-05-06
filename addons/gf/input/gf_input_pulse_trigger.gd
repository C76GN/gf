## GFInputPulseTrigger: 周期脉冲触发器。
##
## 输入持续活跃时按固定间隔触发一次，可用于连发、菜单重复导航等通用场景。
class_name GFInputPulseTrigger
extends GFInputTrigger


# --- 导出变量 ---

## 脉冲间隔秒数。
@export var interval_seconds: float = 0.1:
	set(value):
		interval_seconds = maxf(value, 0.001)

## 输入首次变为活跃时是否立即触发。
@export var trigger_immediately: bool = true


# --- 公共方法 ---

## 重置输入触发器运行时状态。
## @param state: 触发器运行时状态字典。
func reset_trigger_state(state: Dictionary) -> void:
	state.clear()
	state["was_active"] = false
	state["elapsed"] = 0.0


## 更新运行时状态。
## @param raw_active: 原始输入是否处于激活状态。
## @param _value: 输入值，默认实现不直接使用。
## @param delta: 本帧时间增量（秒）。
## @param state: 触发器运行时状态字典。
func update(raw_active: bool, _value: Variant, delta: float, state: Dictionary) -> TriggerState:
	var was_active := bool(state.get("was_active", false))
	if not raw_active:
		state["was_active"] = false
		state["elapsed"] = 0.0
		return TriggerState.INACTIVE

	if trigger_immediately and not was_active:
		state["was_active"] = true
		state["elapsed"] = 0.0
		return TriggerState.TRIGGERED

	var elapsed := float(state.get("elapsed", 0.0)) + maxf(delta, 0.0)
	if elapsed >= interval_seconds:
		state["elapsed"] = fmod(elapsed, interval_seconds)
		state["was_active"] = true
		return TriggerState.TRIGGERED

	state["elapsed"] = elapsed
	state["was_active"] = true
	return TriggerState.ONGOING
