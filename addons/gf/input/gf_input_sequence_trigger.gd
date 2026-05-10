## GFInputSequenceTrigger: 动作序列触发器。
##
## 按顺序观察一组前置动作的 just-started 状态，全部完成后当前输入活跃时触发。
class_name GFInputSequenceTrigger
extends GFInputTrigger


# --- 常量 ---

const GFInputSequenceBranchBase = preload("res://addons/gf/input/gf_input_sequence_branch.gd")
const GFInputSequenceStepBase = preload("res://addons/gf/input/gf_input_sequence_step.gd")


# --- 导出变量 ---

## 当前动作触发前必须依次开始的动作列表。
@export var required_action_ids: Array[StringName] = []

## 可选输入序列分支。非空时优先使用分支配置，required_action_ids 保持兼容旧资源。
@export var branches: Array[GFInputSequenceBranchBase] = []

## 相邻步骤允许的最大间隔。小于等于 0 表示不限制。
@export var max_gap_seconds: float = 0.4:
	set(value):
		max_gap_seconds = maxf(value, 0.0)

## 玩家级动作是否只检查同一玩家。
@export var player_scoped: bool = true


# --- 公共方法 ---

## 重置输入触发器运行时状态。
## @param state: 触发器运行时状态字典。
func reset_trigger_state(state: Dictionary) -> void:
	state.clear()
	state["sequence_index"] = 0
	state["gap_elapsed"] = 0.0
	state["completed"] = false
	state["branch_states"] = []


## 准备输入动作运行时状态。
## @param _action_id: 当前输入动作标识，默认实现不直接使用。
## @param input_utility: 输入运行时依赖的 GFInputUtility 实例。
## @param player_index: 玩家索引。
## @param state: 触发器运行时状态字典。
func prepare_runtime(
	_action_id: StringName,
	input_utility: Object,
	player_index: int,
	state: Dictionary
) -> void:
	state["input_utility"] = input_utility
	state["player_index"] = player_index


## 更新运行时状态。
## @param raw_active: 原始输入是否处于激活状态。
## @param _value: 输入值，默认实现不直接使用。
## @param delta: 本帧时间增量（秒）。
## @param state: 触发器运行时状态字典。
func update(raw_active: bool, _value: Variant, delta: float, state: Dictionary) -> TriggerState:
	var effective_branches := _get_effective_branches()
	if effective_branches.is_empty():
		return TriggerState.TRIGGERED if raw_active else TriggerState.INACTIVE

	_advance_branches(state, delta, effective_branches)
	if _has_completed_branch(state) and raw_active:
		_reset_all_branch_progress(state)
		return TriggerState.TRIGGERED

	return TriggerState.ONGOING if raw_active else TriggerState.INACTIVE


# --- 私有/辅助方法 ---

func _get_effective_branches() -> Array[GFInputSequenceBranchBase]:
	var result: Array[GFInputSequenceBranchBase] = []
	for branch: GFInputSequenceBranchBase in branches:
		if branch != null and branch.is_valid_branch():
			result.append(branch)
	if not result.is_empty():
		return result
	if required_action_ids.is_empty():
		return result
	result.append(GFInputSequenceBranchBase.from_action_ids(required_action_ids, max_gap_seconds) as GFInputSequenceBranchBase)
	return result


func _advance_branches(
	state: Dictionary,
	delta: float,
	effective_branches: Array[GFInputSequenceBranchBase]
) -> void:
	var input_utility := state.get("input_utility") as Object
	if input_utility == null:
		return

	var branch_states := _get_branch_states(state, effective_branches.size())
	for branch_index: int in range(effective_branches.size()):
		var branch := effective_branches[branch_index]
		if branch == null:
			continue
		_advance_branch(branch_states[branch_index], branch, input_utility, delta, int(state.get("player_index", -1)))


func _advance_branch(
	branch_state: Dictionary,
	branch: GFInputSequenceBranchBase,
	input_utility: Object,
	delta: float,
	player_index: int
) -> void:
	if bool(branch_state.get("completed", false)):
		return

	var sequence_index := int(branch_state.get("sequence_index", 0))
	var steps := _get_valid_steps(branch)
	if sequence_index >= steps.size():
		branch_state["completed"] = true
		return

	var current_step := steps[sequence_index]
	if _should_reset_for_gap(branch_state, current_step, branch, delta):
		_reset_branch_progress(branch_state)
		sequence_index = 0
		current_step = steps[sequence_index]

	if _advance_step(branch_state, current_step, input_utility, delta, player_index):
		sequence_index += 1
		branch_state["sequence_index"] = sequence_index
		branch_state["gap_elapsed"] = 0.0
		branch_state["step_elapsed"] = 0.0
		branch_state["step_started"] = false
		branch_state["step_was_active"] = false
		if sequence_index >= steps.size():
			branch_state["completed"] = true


func _advance_step(
	branch_state: Dictionary,
	step: GFInputSequenceStepBase,
	input_utility: Object,
	delta: float,
	player_index: int
) -> bool:
	if step == null or step.action_id == &"":
		return true

	var is_active := _is_action_active(input_utility, step.action_id, player_index)
	var was_active := bool(branch_state.get("step_was_active", false))
	var started := bool(branch_state.get("step_started", false))
	var elapsed := float(branch_state.get("step_elapsed", 0.0))
	var just_started := _was_action_just_started(input_utility, step.action_id, player_index)

	if step.trigger_on_release and _was_action_just_completed(input_utility, step.action_id, player_index):
		elapsed = maxf(elapsed, _get_last_completed_duration(input_utility, step.action_id, player_index))
		branch_state["step_elapsed"] = elapsed
		branch_state["step_started"] = false
		branch_state["step_was_active"] = false
		if elapsed >= step.min_hold_seconds:
			return true
		_reset_branch_progress(branch_state)
		return false

	if just_started or (not started and is_active and (step.trigger_on_release or step.min_hold_seconds > 0.0)):
		started = true
		elapsed = maxf(delta, 0.0) if is_active else 0.0
	elif started and is_active:
		elapsed += maxf(delta, 0.0)

	branch_state["step_started"] = started
	branch_state["step_elapsed"] = elapsed
	branch_state["step_was_active"] = is_active

	if step.trigger_on_release:
		if started and was_active and not is_active:
			if elapsed >= step.min_hold_seconds:
				return true
			_reset_branch_progress(branch_state)
		return false

	if not started:
		return false
	if step.min_hold_seconds <= 0.0:
		return true
	if is_active and elapsed >= step.min_hold_seconds:
		return true
	if not is_active and was_active:
		_reset_branch_progress(branch_state)
	return false


func _should_reset_for_gap(
	branch_state: Dictionary,
	step: GFInputSequenceStepBase,
	branch: GFInputSequenceBranchBase,
	delta: float
) -> bool:
	if int(branch_state.get("sequence_index", 0)) <= 0:
		return false
	if bool(branch_state.get("step_started", false)):
		return false

	var gap_seconds := _resolve_gap_seconds(step, branch)
	if gap_seconds <= 0.0:
		return false

	var gap_elapsed := float(branch_state.get("gap_elapsed", 0.0)) + maxf(delta, 0.0)
	branch_state["gap_elapsed"] = gap_elapsed
	return gap_elapsed > gap_seconds


func _resolve_gap_seconds(step: GFInputSequenceStepBase, branch: GFInputSequenceBranchBase) -> float:
	if step != null and step.max_gap_seconds >= 0.0:
		return step.max_gap_seconds
	if branch != null and branch.max_gap_seconds >= 0.0:
		return branch.max_gap_seconds
	return max_gap_seconds


func _get_valid_steps(branch: GFInputSequenceBranchBase) -> Array[GFInputSequenceStepBase]:
	var result: Array[GFInputSequenceStepBase] = []
	if branch == null:
		return result
	for step: GFInputSequenceStepBase in branch.steps:
		if step != null and step.action_id != &"":
			result.append(step)
	return result


func _get_branch_states(state: Dictionary, branch_count: int) -> Array[Dictionary]:
	var branch_states := state.get("branch_states", []) as Array
	if branch_states == null:
		branch_states = []
	while branch_states.size() < branch_count:
		branch_states.append(_make_branch_state())
	while branch_states.size() > branch_count:
		branch_states.pop_back()
	state["branch_states"] = branch_states
	var typed_states: Array[Dictionary] = []
	typed_states.assign(branch_states)
	return typed_states


func _make_branch_state() -> Dictionary:
	return {
		"sequence_index": 0,
		"gap_elapsed": 0.0,
		"completed": false,
		"step_elapsed": 0.0,
		"step_started": false,
		"step_was_active": false,
	}


func _has_completed_branch(state: Dictionary) -> bool:
	var branch_states := state.get("branch_states", []) as Array
	if branch_states == null:
		return false
	for branch_state: Dictionary in branch_states:
		if bool(branch_state.get("completed", false)):
			return true
	return false


func _is_action_active(input_utility: Object, action_id: StringName, player_index: int) -> bool:
	if player_scoped and player_index >= 0 and input_utility.has_method("is_action_active_for_player"):
		return bool(input_utility.call("is_action_active_for_player", player_index, action_id))
	if input_utility.has_method("is_action_active"):
		return bool(input_utility.call("is_action_active", action_id))
	return false


func _was_action_just_started(input_utility: Object, action_id: StringName, player_index: int) -> bool:
	if player_scoped and player_index >= 0 and input_utility.has_method("was_action_just_started_for_player"):
		return bool(input_utility.call("was_action_just_started_for_player", player_index, action_id))
	if input_utility.has_method("was_action_just_started"):
		return bool(input_utility.call("was_action_just_started", action_id))
	return false


func _was_action_just_completed(input_utility: Object, action_id: StringName, player_index: int) -> bool:
	if player_scoped and player_index >= 0 and input_utility.has_method("was_action_just_completed_for_player"):
		return bool(input_utility.call("was_action_just_completed_for_player", player_index, action_id))
	if input_utility.has_method("was_action_just_completed"):
		return bool(input_utility.call("was_action_just_completed", action_id))
	return false


func _get_last_completed_duration(input_utility: Object, action_id: StringName, player_index: int) -> float:
	if player_scoped and player_index >= 0 and input_utility.has_method("get_last_completed_duration_for_player"):
		return float(input_utility.call("get_last_completed_duration_for_player", player_index, action_id))
	if input_utility.has_method("get_last_completed_duration"):
		return float(input_utility.call("get_last_completed_duration", action_id))
	return 0.0


func _reset_all_branch_progress(state: Dictionary) -> void:
	state["sequence_index"] = 0
	state["gap_elapsed"] = 0.0
	state["completed"] = false
	var branch_states := state.get("branch_states", []) as Array
	if branch_states == null:
		return
	for branch_state: Dictionary in branch_states:
		_reset_branch_progress(branch_state)


func _reset_branch_progress(branch_state: Dictionary) -> void:
	branch_state["sequence_index"] = 0
	branch_state["gap_elapsed"] = 0.0
	branch_state["completed"] = false
	branch_state["step_elapsed"] = 0.0
	branch_state["step_started"] = false
	branch_state["step_was_active"] = false
