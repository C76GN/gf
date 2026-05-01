## GFInputMapping: 单个动作的输入绑定集合。
class_name GFInputMapping
extends Resource


# --- 常量 ---

const GFInputActionBase = preload("res://addons/gf/input/gf_input_action.gd")
const GFInputBindingBase = preload("res://addons/gf/input/gf_input_binding.gd")
const GFInputModifierBase = preload("res://addons/gf/input/gf_input_modifier.gd")
const GFInputTriggerBase = preload("res://addons/gf/input/gf_input_trigger.gd")


# --- 导出变量 ---

## 抽象输入动作。
@export var action: GFInputActionBase

## 动作绑定列表。多个绑定会合并为同一个动作值。
@export var bindings: Array[GFInputBindingBase] = []

## 映射级输入修饰器，按顺序作用于该动作聚合后的值。
@export var modifiers: Array[GFInputModifierBase] = []

## 可选触发器，全部满足后动作才会被视为活跃。
@export var triggers: Array[GFInputTriggerBase] = []

## 可选显示名称覆盖。
@export var display_name: String = ""

## 可选显示分类覆盖。
@export var display_category: String = ""


# --- 公共方法 ---

## 获取动作标识。
## @return 稳定动作标识。
func get_action_id() -> StringName:
	if action == null:
		return &""
	return action.get_action_id()


## 获取显示名称。
## @return 显示名称。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if action != null:
		return action.get_display_name()
	return "Input Mapping"


## 获取显示分类。
## @return 显示分类。
func get_display_category() -> String:
	if not display_category.is_empty():
		return display_category
	if action != null:
		return action.display_category
	return ""
