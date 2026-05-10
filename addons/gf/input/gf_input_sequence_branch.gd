## GFInputSequenceBranch: 输入序列触发器的一条可选分支。
##
## 多分支允许同一动作由不同抽象动作序列触发，适合格斗、快捷指令或可替代输入路径。
class_name GFInputSequenceBranch
extends Resource


# --- 常量 ---

const GFInputSequenceStepBase = preload("res://addons/gf/input/gf_input_sequence_step.gd")


# --- 导出变量 ---

## 本分支的步骤列表。
@export var steps: Array[GFInputSequenceStepBase] = []

## 本分支默认最大步骤间隔。小于 0 表示使用触发器默认值，0 表示不限制。
@export var max_gap_seconds: float = -1.0:
	set(value):
		max_gap_seconds = maxf(value, -1.0)


# --- 公共方法 ---

## 检查分支是否至少包含一个有效动作步骤。
## @return 有效返回 true。
func is_valid_branch() -> bool:
	for step: GFInputSequenceStepBase in steps:
		if step != null and step.action_id != &"":
			return true
	return false


## 创建当前分支的深拷贝。
## @return 分支副本。
func duplicate_branch() -> Resource:
	return duplicate(true) as Resource


## 从动作 ID 数组创建分支。
## @param action_ids: 动作 ID 数组。
## @param p_max_gap_seconds: 默认最大步骤间隔。
## @return 新分支。
static func from_action_ids(
	action_ids: Array[StringName],
	p_max_gap_seconds: float = -1.0
) -> Resource:
	var script: Script = load("res://addons/gf/input/gf_input_sequence_branch.gd") as Script
	var branch: Resource = script.new() as Resource
	branch.set("max_gap_seconds", p_max_gap_seconds)
	for action_id: StringName in action_ids:
		var steps := branch.get("steps") as Array
		steps.append(GFInputSequenceStepBase.from_action_id(action_id))
		branch.set("steps", steps)
	return branch
