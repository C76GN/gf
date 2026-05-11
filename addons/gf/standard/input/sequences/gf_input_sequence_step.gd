## GFInputSequenceStep: 输入序列中的单个抽象动作步骤。
##
## 步骤只描述动作 ID、间隔和按住/释放条件，不绑定具体按键或业务语义。
class_name GFInputSequenceStep
extends Resource


# --- 导出变量 ---

## 需要匹配的抽象动作 ID。
@export var action_id: StringName = &""

## 从上一完成步骤到本步骤开始允许的最大间隔。小于 0 表示使用分支或触发器默认值，0 表示不限制。
@export var max_gap_seconds: float = -1.0:
	set(value):
		max_gap_seconds = maxf(value, -1.0)

## 动作需要保持活跃的最短时间。
@export var min_hold_seconds: float = 0.0:
	set(value):
		min_hold_seconds = maxf(value, 0.0)

## 是否在动作释放时完成本步骤。
@export var trigger_on_release: bool = false


# --- 公共方法 ---

## 创建当前步骤的深拷贝。
## @return 步骤副本。
func duplicate_step() -> Resource:
	return duplicate(true) as Resource


## 创建只包含动作 ID 的步骤。
## @param p_action_id: 动作 ID。
## @return 新步骤。
static func from_action_id(p_action_id: StringName) -> Resource:
	var script: Script = load("res://addons/gf/standard/input/sequences/gf_input_sequence_step.gd") as Script
	var step: Resource = script.new() as Resource
	step.set("action_id", p_action_id)
	return step
