## GFInputDirectionHistory: 最后按下方向优先的输入历史。
##
## 维护动作 ID 到方向向量的按下顺序，适合网格移动、菜单导航或四方向角色控制。
## 它不读取 InputMap，也不规定动作命名。
class_name GFInputDirectionHistory
extends RefCounted


# --- 私有变量 ---

var _pressed_actions: Dictionary = {}
var _history: Array[StringName] = []


# --- 公共方法 ---

## 标记一个方向动作被按下。
## @param action_id: 动作标识。
## @param direction: 方向。
func press_action(action_id: StringName, direction: Vector2i) -> void:
	if action_id == &"" or direction == Vector2i.ZERO:
		return
	_pressed_actions[action_id] = direction
	_history.erase(action_id)
	_history.append(action_id)


## 标记一个方向动作被释放。
## @param action_id: 动作标识。
func release_action(action_id: StringName) -> void:
	_pressed_actions.erase(action_id)
	_history.erase(action_id)


## 按方向值生成内部动作标识并标记按下。
## @param direction: 方向。
func press_direction(direction: Vector2i) -> void:
	press_action(_direction_to_id(direction), direction)


## 按方向值生成内部动作标识并标记释放。
## @param direction: 方向。
func release_direction(direction: Vector2i) -> void:
	release_action(_direction_to_id(direction))


## 根据 pressed 状态更新动作。
## @param action_id: 动作标识。
## @param direction: 方向。
## @param pressed: 是否按下。
func update_action(action_id: StringName, direction: Vector2i, pressed: bool) -> void:
	if pressed:
		press_action(action_id, direction)
	else:
		release_action(action_id)


## 获取当前优先方向。
## @return 最近按下且尚未释放的方向；没有时返回 Vector2i.ZERO。
func get_current_direction() -> Vector2i:
	if _history.is_empty():
		return Vector2i.ZERO
	var action_id := _history[_history.size() - 1]
	var direction: Variant = _pressed_actions.get(action_id, Vector2i.ZERO)
	return direction if direction is Vector2i else Vector2i.ZERO


## 获取当前优先动作。
## @return 最近按下且尚未释放的动作；没有时返回空 StringName。
func get_current_action() -> StringName:
	if _history.is_empty():
		return &""
	return _history[_history.size() - 1]


## 获取按下历史副本。
## @return 动作 ID 列表。
func get_history() -> Array[StringName]:
	return _history.duplicate()


## 清空历史。
func clear() -> void:
	_pressed_actions.clear()
	_history.clear()


# --- 私有/辅助方法 ---

func _direction_to_id(direction: Vector2i) -> StringName:
	return StringName("%d,%d" % [direction.x, direction.y])
