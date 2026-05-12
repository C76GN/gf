## GFNodeStateCondition: 节点状态的可复用进入/退出条件资源。
##
## 条件只负责判断状态切换是否允许，不直接执行切换或修改状态机结构。
class_name GFNodeStateCondition
extends Resource


# --- 导出变量 ---

## 条件标识，便于调试或项目工具识别。
@export var condition_id: StringName = &""

## 是否反转 evaluate() 的结果。
@export var invert: bool = false

## 项目自定义元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 评估条件。
## @param state: 当前条件所属状态。
## @param phase: 条件阶段，通常为 enter 或 exit。
## @param peer_state: 进入时为来源状态名，退出时为目标状态名。
## @param args: 状态切换参数。
## @return 条件通过时返回 true。
func evaluate(
	state: GFNodeState,
	phase: StringName,
	peer_state: StringName = &"",
	args: Dictionary = {}
) -> bool:
	var accepted := _evaluate(state, phase, peer_state, args)
	return not accepted if invert else accepted


# --- 虚方法（由子类重写） ---

## 条件评估扩展点。
func _evaluate(
	_state: GFNodeState,
	_phase: StringName,
	_peer_state: StringName = &"",
	_args: Dictionary = {}
) -> bool:
	return true
