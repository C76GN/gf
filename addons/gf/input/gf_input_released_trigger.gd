## GFInputReleasedTrigger: 释放瞬间触发器。
##
## 输入从活跃变为非活跃时触发一次，适合蓄力释放、松手确认等通用交互。
class_name GFInputReleasedTrigger
extends GFInputTrigger


# --- 公共方法 ---

func reset_trigger_state(state: Dictionary) -> void:
	state.clear()
	state["was_active"] = false


func update(raw_active: bool, _value: Variant, _delta: float, state: Dictionary) -> TriggerState:
	var was_active := bool(state.get("was_active", false))
	state["was_active"] = raw_active
	if was_active and not raw_active:
		return TriggerState.TRIGGERED
	return TriggerState.ONGOING if raw_active else TriggerState.INACTIVE
