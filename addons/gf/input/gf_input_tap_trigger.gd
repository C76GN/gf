## GFInputTapTrigger: 短按触发器。
##
## 输入按下后在指定时间窗口内释放时触发一次。
class_name GFInputTapTrigger
extends GFInputTrigger


# --- 导出变量 ---

## 最短按住时间。
@export var min_tap_seconds: float = 0.0:
	set(value):
		min_tap_seconds = maxf(value, 0.0)

## 最长按住时间。
@export var max_tap_seconds: float = 0.25:
	set(value):
		max_tap_seconds = maxf(value, min_tap_seconds)


# --- 公共方法 ---

func reset_trigger_state(state: Dictionary) -> void:
	state.clear()
	state["was_active"] = false
	state["elapsed"] = 0.0


func update(raw_active: bool, _value: Variant, delta: float, state: Dictionary) -> TriggerState:
	var was_active := bool(state.get("was_active", false))
	var elapsed := float(state.get("elapsed", 0.0))

	if raw_active:
		elapsed = 0.0 if not was_active else elapsed + maxf(delta, 0.0)
		state["elapsed"] = elapsed
		state["was_active"] = true
		return TriggerState.ONGOING

	state["was_active"] = false
	state["elapsed"] = 0.0
	if was_active and elapsed >= min_tap_seconds and elapsed <= max_tap_seconds:
		return TriggerState.TRIGGERED
	return TriggerState.INACTIVE
