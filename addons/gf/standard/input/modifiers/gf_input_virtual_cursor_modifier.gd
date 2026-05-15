## GFInputVirtualCursorModifier: 虚拟光标输入修饰器。
##
## 将二维输入视为速度并积分为一个位置值。它只维护抽象坐标，不访问 Viewport、
## Control 或具体 UI 节点。
class_name GFInputVirtualCursorModifier
extends GFInputModifier


# --- 导出变量 ---

## 初始位置。
@export var initial_position: Vector2 = Vector2(0.5, 0.5)

## 每秒移动速度倍率。
@export var speed: Vector2 = Vector2.ONE

## 是否按真实经过时间缩放输入。
@export var apply_delta_time: bool = true

## 是否将位置限制在 clamp_rect 内。
@export var clamp_to_rect: bool = true

## 可用位置范围。
@export var clamp_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ONE)

## 输入低于该长度时视为空闲。
@export_range(0.0, 1.0, 0.001) var idle_threshold: float = 0.0

## 空闲时是否回到 initial_position。
@export var reset_when_idle: bool = false


# --- 公共变量 ---

## 当前虚拟光标位置。
var position: Vector2 = Vector2(0.5, 0.5)


# --- 私有变量 ---

var _initialized: bool = false
var _last_ticks_msec: int = 0


# --- 公共方法 ---

## 修改二维输入值。
## @param value: 要写入或修改的值。
## @param _event: 原始输入事件，默认实现不直接使用。
## @param _action: 当前输入动作配置，默认实现不直接使用。
func modify(value: Vector2, _event: InputEvent = null, _action: GFInputAction = null) -> Vector2:
	_ensure_initialized()
	var input_value := value
	if input_value.length() <= idle_threshold:
		if reset_when_idle:
			reset_position()
		_update_ticks()
		return position

	position += input_value * speed * _get_step_delta()
	if clamp_to_rect:
		position = _clamp_position(position)
	return position


## 修改三维输入值。
## @param value: 要写入或修改的值。
## @param event: 原始输入事件，默认实现不直接使用。
## @param action: 当前输入动作配置，默认实现不直接使用。
func modify_3d(value: Vector3, event: InputEvent = null, action: GFInputAction = null) -> Vector3:
	var cursor_position := modify(Vector2(value.x, value.y), event, action)
	return Vector3(cursor_position.x, cursor_position.y, value.z)


## 重置虚拟光标位置。
## @return 当前修饰器。
func reset_position() -> GFInputVirtualCursorModifier:
	position = initial_position
	_initialized = true
	_update_ticks()
	return self


## 创建运行时副本。
## @return 修饰器副本。
func duplicate_modifier() -> GFInputModifier:
	var modifier := duplicate(true) as GFInputVirtualCursorModifier
	modifier.position = modifier.initial_position
	modifier._initialized = false
	modifier._last_ticks_msec = 0
	return modifier


# --- 私有/辅助方法 ---

func _ensure_initialized() -> void:
	if _initialized:
		return
	position = initial_position
	_initialized = true
	_update_ticks()


func _get_step_delta() -> float:
	if not apply_delta_time:
		_update_ticks()
		return 1.0

	var now := Time.get_ticks_msec()
	var delta := 0.0
	if _last_ticks_msec > 0:
		delta = float(now - _last_ticks_msec) / 1000.0
	_last_ticks_msec = now
	return maxf(delta, 0.0)


func _update_ticks() -> void:
	_last_ticks_msec = Time.get_ticks_msec()


func _clamp_position(value: Vector2) -> Vector2:
	var rect := clamp_rect.abs()
	return Vector2(
		clampf(value.x, rect.position.x, rect.end.x),
		clampf(value.y, rect.position.y, rect.end.y)
	)
