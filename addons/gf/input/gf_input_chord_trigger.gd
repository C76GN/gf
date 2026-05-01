## GFInputChordTrigger: 组合动作触发器。
##
## 当前输入活跃且另一个动作也处于活跃状态时触发，不绑定具体按键。
class_name GFInputChordTrigger
extends GFInputTrigger


# --- 导出变量 ---

## 需要同时保持活跃的动作标识。
@export var required_action_id: StringName = &""

## 玩家级动作是否只检查同一玩家。
@export var player_scoped: bool = true


# --- 公共方法 ---

func prepare_runtime(
	_action_id: StringName,
	input_utility: Object,
	player_index: int,
	state: Dictionary
) -> void:
	state["input_utility"] = input_utility
	state["player_index"] = player_index


func update(raw_active: bool, _value: Variant, _delta: float, state: Dictionary) -> TriggerState:
	if not raw_active:
		return TriggerState.INACTIVE
	if required_action_id == &"":
		return TriggerState.TRIGGERED

	var input_utility := state.get("input_utility") as Object
	if input_utility == null:
		return TriggerState.INACTIVE

	var player_index := int(state.get("player_index", -1))
	if player_scoped and player_index >= 0 and input_utility.has_method("is_action_active_for_player"):
		return (
			TriggerState.TRIGGERED
			if bool(input_utility.call("is_action_active_for_player", player_index, required_action_id))
			else TriggerState.INACTIVE
		)

	if input_utility.has_method("is_action_active") and bool(input_utility.call("is_action_active", required_action_id)):
		return TriggerState.TRIGGERED
	return TriggerState.INACTIVE
