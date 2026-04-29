## GFTurnAction: 通用回合行动基类。
##
## 行动只描述“谁执行、对谁执行、排序值与载荷”，具体效果由子类重写 `resolve()`。
class_name GFTurnAction
extends RefCounted


# --- 公共变量 ---

## 行动标识。
var action_id: StringName = &""

## 行动发起者。
var actor: Object = null

## 行动目标列表。
var targets: Array[Object] = []

## 行动载荷。
var payload: Variant = null

## 主排序优先级，值越大越先处理。
var priority: int = 0

## 次排序值，值越大越先处理。
var sort_value: float = 0.0

## 是否已取消。
var is_cancelled: bool = false


# --- Godot 生命周期方法 ---

func _init(
	p_actor: Object = null,
	p_targets: Array[Object] = [],
	p_payload: Variant = null,
	p_priority: int = 0,
	p_sort_value: float = 0.0
) -> void:
	actor = p_actor
	targets = p_targets.duplicate()
	payload = p_payload
	priority = p_priority
	sort_value = p_sort_value


# --- 公共方法 ---

## 解析行动。子类应重写该方法。
## @param _context: 回合上下文。
## @return 可返回 null 或 Signal。
func resolve(_context: GFTurnContext) -> Variant:
	return null


## 取消行动。
func cancel() -> void:
	is_cancelled = true

