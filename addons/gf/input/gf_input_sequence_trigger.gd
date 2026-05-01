## GFInputSequenceTrigger: 动作序列触发器。
##
## 按顺序观察一组前置动作的 just-started 状态，全部完成后当前输入活跃时触发。
class_name GFInputSequenceTrigger
extends GFInputTrigger


# --- 导出变量 ---

## 当前动作触发前必须依次开始的动作列表。
@export var required_action_ids: Array[StringName] = []

## 相邻步骤允许的最大间隔。小于等于 0 表示不限制。
@export var max_gap_seconds: float = 0.4:
	set(value):
		max_gap_seconds = maxf(value, 0.0)

## 玩家级动作是否只检查同一玩家。
@export var player_scoped: bool = true


# --- 公共方法 ---

func reset_trigger_state(state: Dictionary) -> void:
	state.clear()
	state["sequence_index"] = 0
	state["gap_elapsed"] = 0.0
	state["completed"] = false


func prepare_runtime(
	_action_id: StringName,
	input_utility: Object,
	player_index: int,
	state: Dictionary
) -> void:
	state["input_utility"] = input_utility
	state["player_index"] = player_index


func update(raw_active: bool, _value: Variant, delta: float, state: Dictionary) -> TriggerState:
	if required_action_ids.is_empty():
		return TriggerState.TRIGGERED if raw_active else TriggerState.INACTIVE

	_advance_sequence(state, delta)
	if bool(state.get("completed", false)) and raw_active:
		_reset_sequence_progress(state)
		return TriggerState.TRIGGERED

	return TriggerState.ONGOING if raw_active else TriggerState.INACTIVE


# --- 私有/辅助方法 ---

func _advance_sequence(state: Dictionary, delta: float) -> void:
	var input_utility := state.get("input_utility") as Object
	if input_utility == null:
		return

	var sequence_index := int(state.get("sequence_index", 0))
	if sequence_index >= required_action_ids.size():
		state["completed"] = true
		return

	if sequence_index > 0 and max_gap_seconds > 0.0:
		var gap_elapsed := float(state.get("gap_elapsed", 0.0)) + maxf(delta, 0.0)
		state["gap_elapsed"] = gap_elapsed
		if gap_elapsed > max_gap_seconds:
			_reset_sequence_progress(state)
			sequence_index = 0

	var required_action_id := required_action_ids[sequence_index]
	if not _was_action_just_started(input_utility, required_action_id, int(state.get("player_index", -1))):
		return

	sequence_index += 1
	state["sequence_index"] = sequence_index
	state["gap_elapsed"] = 0.0
	if sequence_index >= required_action_ids.size():
		state["completed"] = true


func _was_action_just_started(input_utility: Object, action_id: StringName, player_index: int) -> bool:
	if player_scoped and player_index >= 0 and input_utility.has_method("was_action_just_started_for_player"):
		return bool(input_utility.call("was_action_just_started_for_player", player_index, action_id))
	if input_utility.has_method("was_action_just_started"):
		return bool(input_utility.call("was_action_just_started", action_id))
	return false


func _reset_sequence_progress(state: Dictionary) -> void:
	state["sequence_index"] = 0
	state["gap_elapsed"] = 0.0
	state["completed"] = false
