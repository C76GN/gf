## GFTurnContext: 通用回合流程上下文。
##
## 只记录参与者、行动、轮次和元数据，不假设生命值、阵营、技能等业务概念。
class_name GFTurnContext
extends RefCounted


# --- 公共变量 ---

## 当前流程参与者。
var actors: Array[Object] = []

## 当前待处理行动。
var actions: Array[GFTurnAction] = []

## 当前行动主体。
var current_actor: Object = null

## 当前回合索引。
var turn_index: int = 0

## 当前轮次索引。
var round_index: int = 0

## 自定义元数据。
var metadata: Dictionary = {}


# --- 公共方法 ---

## 添加参与者。
## @param actor: 参与者对象。
func add_actor(actor: Object) -> void:
	if actor == null or actors.has(actor):
		return
	actors.append(actor)


## 移除参与者。
## @param actor: 参与者对象。
func remove_actor(actor: Object) -> void:
	actors.erase(actor)
	if current_actor == actor:
		current_actor = null


## 清空运行时行动。
func clear_actions() -> void:
	actions.clear()


## 从参与者读取排序或判定值。
##
## 优先调用 `get_turn_value(key, fallback)`，其次读取对象属性。
## @param actor: 参与者对象。
## @param key: 值键。
## @param fallback: 读取失败时的兜底值。
## @return 读取到的值。
func get_actor_value(actor: Object, key: StringName, fallback: Variant = null) -> Variant:
	if actor == null:
		return fallback
	if actor.has_method("get_turn_value"):
		return actor.call("get_turn_value", key, fallback)

	var property_name := String(key)
	if property_name in actor:
		return actor.get(property_name)
	return fallback

