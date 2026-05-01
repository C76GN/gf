## GFInputHoldTrigger: 长按触发器。
##
## 输入持续活跃达到 hold_seconds 后，动作才进入活跃状态。释放输入会重置计时。
class_name GFInputHoldTrigger
extends GFInputTrigger


# --- 导出变量 ---

## 需要持续按住的秒数。
@export var hold_seconds: float = 0.25:
	set(value):
		hold_seconds = maxf(value, 0.0)


# --- 公共方法 ---

func reset_trigger_state(state: Dictionary) -> void:
	state.clear()
	state["elapsed"] = 0.0


func update(raw_active: bool, _value: Variant, delta: float, state: Dictionary) -> TriggerState:
	if not raw_active:
		state["elapsed"] = 0.0
		return TriggerState.INACTIVE

	var elapsed := float(state.get("elapsed", 0.0))
	elapsed += maxf(delta, 0.0)
	state["elapsed"] = elapsed
	if elapsed >= hold_seconds:
		return TriggerState.TRIGGERED
	return TriggerState.ONGOING
