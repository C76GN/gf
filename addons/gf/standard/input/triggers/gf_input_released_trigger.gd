## GFInputReleasedTrigger: 释放瞬间触发器。
##
## 输入从活跃变为非活跃时触发一次，适合蓄力释放、松手确认等通用交互。
class_name GFInputReleasedTrigger
extends GFInputTrigger


# --- 公共方法 ---

## 重置输入触发器运行时状态。
## @param state: 触发器运行时状态字典。
func reset_trigger_state(state: Dictionary) -> void:
	state.clear()
	state["was_active"] = false


## 更新运行时状态。
## @param raw_active: 原始输入是否处于激活状态。
## @param _value: 输入值，默认实现不直接使用。
## @param _delta: 本帧时间增量（秒），默认实现不直接使用。
## @param state: 触发器运行时状态字典。
func update(raw_active: bool, _value: Variant, _delta: float, state: Dictionary) -> TriggerState:
	var was_active := bool(state.get("was_active", false))
	state["was_active"] = raw_active
	if was_active and not raw_active:
		return TriggerState.TRIGGERED
	return TriggerState.ONGOING if raw_active else TriggerState.INACTIVE
