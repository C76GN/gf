## GFInputSequenceStep: 输入序列中的单个抽象动作步骤。
##
## 步骤只描述动作 ID、间隔和按住/释放条件，不绑定具体按键或业务语义。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFInputSequenceStep
extends Resource


# --- 导出变量 ---

## 需要匹配的抽象动作 ID。
## [br]
## @api public
@export var action_id: StringName = &""

## 从上一完成步骤到本步骤开始允许的最大间隔。小于 0 表示使用分支或触发器默认值，0 表示不限制。
## [br]
## @api public
@export var max_gap_seconds: float = -1.0:
	set(value):
		max_gap_seconds = maxf(value, -1.0)

## 动作需要保持活跃的最短时间。
## [br]
## @api public
@export var min_hold_seconds: float = 0.0:
	set(value):
		min_hold_seconds = maxf(value, 0.0)

## 是否在动作释放时完成本步骤。
## [br]
## @api public
@export var trigger_on_release: bool = false


# --- 公共方法 ---

## 创建当前步骤的深拷贝。
## [br]
## @api public
## [br]
## @return 步骤副本。
func duplicate_step() -> GFInputSequenceStep:
	return duplicate(true) as GFInputSequenceStep


## 创建只包含动作 ID 的步骤。
## [br]
## @api public
## [br]
## @param p_action_id: 动作 ID。
## [br]
## @return 新步骤。
static func from_action_id(p_action_id: StringName) -> GFInputSequenceStep:
	var step := GFInputSequenceStep.new()
	step.action_id = p_action_id
	return step
