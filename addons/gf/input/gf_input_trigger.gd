## GFInputTrigger: 输入动作触发器基类。
##
## 触发器只决定“原始输入活跃后何时视为动作活跃”，不修改输入值。运行时状态由
## GFInputMappingUtility 传入的 Dictionary 保存，因此同一资源可被多个上下文复用。
class_name GFInputTrigger
extends Resource


# --- 枚举 ---

## 触发器本次更新后的动作状态。
enum TriggerState {
	## 输入未达到触发条件。
	INACTIVE,
	## 输入正在等待触发条件，例如长按计时中。
	ONGOING,
	## 输入已满足触发条件。
	TRIGGERED,
}


# --- 公共方法 ---

## 重置运行时状态。
## @param state: 由调用方保存的状态字典。
func reset_trigger_state(state: Dictionary) -> void:
	state.clear()


## 更新前注入运行时上下文。
## @param _action_id: 当前动作标识。
## @param _input_utility: 输入映射运行时。
## @param _player_index: 玩家索引；全局动作传 -1。
## @param _state: 该触发器的运行时状态。
func prepare_runtime(
	_action_id: StringName,
	_input_utility: Object,
	_player_index: int,
	_state: Dictionary
) -> void:
	pass


## 更新触发器状态。
## @param raw_active: 原始输入是否活跃。
## @param _value: 当前动作值。
## @param _delta: 本次更新经过的秒数；事件驱动刷新时可能为 0。
## @param _state: 该触发器的运行时状态。
## @return 触发状态。
func update(raw_active: bool, _value: Variant, _delta: float, _state: Dictionary) -> TriggerState:
	return TriggerState.TRIGGERED if raw_active else TriggerState.INACTIVE


## 创建运行时副本。
## @return 触发器副本。
func duplicate_trigger() -> GFInputTrigger:
	return duplicate(true) as GFInputTrigger
