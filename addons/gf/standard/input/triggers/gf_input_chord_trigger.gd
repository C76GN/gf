## GFInputChordTrigger: 组合动作触发器。
##
## 当前输入活跃且另一个动作也处于活跃状态时触发，不绑定具体按键。
class_name GFInputChordTrigger
extends GFInputTrigger


# --- 常量 ---

const _INSTANCE_GUARD: Script = preload("res://addons/gf/kernel/core/gf_instance_guard.gd")


# --- 导出变量 ---

## 需要同时保持活跃的动作标识。
@export var required_action_id: StringName = &""

## 玩家级动作是否只检查同一玩家。
@export var player_scoped: bool = true


# --- 公共方法 ---

## 准备输入动作运行时状态。
## @param _action_id: 当前输入动作标识，默认实现不直接使用。
## @param input_runtime: 输入映射运行时。
## @param player_index: 玩家索引。
## @param state: 触发器运行时状态字典。
func prepare_runtime(
	_action_id: StringName,
	input_runtime: Object,
	player_index: int,
	state: Dictionary
) -> void:
	state["input_runtime"] = input_runtime
	state["player_index"] = player_index


## 更新运行时状态。
## @param raw_active: 原始输入是否处于激活状态。
## @param _value: 输入值，默认实现不直接使用。
## @param _delta: 本帧时间增量（秒），默认实现不直接使用。
## @param state: 触发器运行时状态字典。
func update(raw_active: bool, _value: Variant, _delta: float, state: Dictionary) -> TriggerState:
	if not raw_active:
		return TriggerState.INACTIVE
	if required_action_id == &"":
		return TriggerState.TRIGGERED

	var input_runtime := _get_input_runtime(state)
	if input_runtime == null:
		return TriggerState.INACTIVE

	var player_index := int(state.get("player_index", -1))
	if player_scoped and player_index >= 0 and input_runtime.has_method("is_action_active_for_player"):
		return (
			TriggerState.TRIGGERED
			if bool(input_runtime.call("is_action_active_for_player", player_index, required_action_id))
			else TriggerState.INACTIVE
		)

	if input_runtime.has_method("is_action_active") and bool(input_runtime.call("is_action_active", required_action_id)):
		return TriggerState.TRIGGERED
	return TriggerState.INACTIVE


# --- 私有/辅助方法 ---

func _get_input_runtime(state: Dictionary) -> Object:
	return _INSTANCE_GUARD._get_live_object(state.get("input_runtime"))
