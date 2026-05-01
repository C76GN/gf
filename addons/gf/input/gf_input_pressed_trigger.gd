## GFInputPressedTrigger: 按下瞬间触发器。
##
## 只在输入从非活跃变为活跃的那一次更新中触发，适合确认、跳跃等一次性动作。
class_name GFInputPressedTrigger
extends GFInputTrigger


# --- 公共方法 ---

func reset_trigger_state(state: Dictionary) -> void:
	state.clear()
	state["was_active"] = false


func update(raw_active: bool, _value: Variant, _delta: float, state: Dictionary) -> TriggerState:
	var was_active := bool(state.get("was_active", false))
	state["was_active"] = raw_active
	if raw_active and not was_active:
		return TriggerState.TRIGGERED
	return TriggerState.ONGOING if raw_active else TriggerState.INACTIVE
