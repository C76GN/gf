## GFInputBinding: 把一个 Godot 输入事件映射到动作值贡献。
##
## 该资源只描述输入来源和数值方向，实际动作归属由 GFInputMapping 决定。
class_name GFInputBinding
extends Resource


# --- 枚举 ---

## 输入值贡献目标。
enum ValueTarget {
	## 根据动作值类型自动映射。
	AUTO,
	## 只作为开关输入。
	BOOL,
	## 一维轴正向。
	AXIS_1D_POSITIVE,
	## 一维轴负向。
	AXIS_1D_NEGATIVE,
	## 二维轴 X 正向。
	AXIS_2D_X_POSITIVE,
	## 二维轴 X 负向。
	AXIS_2D_X_NEGATIVE,
	## 二维轴 Y 正向。
	AXIS_2D_Y_POSITIVE,
	## 二维轴 Y 负向。
	AXIS_2D_Y_NEGATIVE,
}


# --- 常量 ---

const GFInputActionBase = preload("res://addons/gf/input/gf_input_action.gd")


# --- 导出变量 ---

## Godot 原生输入事件模板。
@export var input_event: InputEvent

## 当前绑定贡献到动作值的方向。
@export var value_target: ValueTarget = ValueTarget.AUTO

## 轴输入死区。对按键和按钮输入无影响。
@export_range(0.0, 1.0, 0.01) var deadzone: float = 0.2

## 输入贡献缩放。
@export var scale: float = 1.0

## 是否按设备 ID 精确匹配。关闭时同类按键、鼠标按钮或手柄按钮可跨设备匹配。
@export var match_device: bool = false

## 覆盖显示名称。
@export var display_name: String = ""

## 该绑定是否可被玩家重绑。
@export var remappable: bool = true


# --- 公共方法 ---

## 创建深拷贝，避免运行时重映射污染原始资源。
## @return 新绑定。
func duplicate_binding() -> Resource:
	var binding: Variant = (get_script() as Script).new()
	binding.input_event = input_event.duplicate(true) as InputEvent if input_event != null else null
	binding.value_target = value_target
	binding.deadzone = deadzone
	binding.scale = scale
	binding.match_device = match_device
	binding.display_name = display_name
	binding.remappable = remappable
	return binding as Resource


## 判断当前绑定是否匹配输入事件。
## @param event: 运行时输入事件。
## @return 是否匹配。
func matches_event(event: InputEvent) -> bool:
	if input_event == null or event == null:
		return false
	if match_device and event.device != input_event.device:
		return false

	if input_event is InputEventAction and event is InputEventAction:
		return (input_event as InputEventAction).action == (event as InputEventAction).action

	if input_event is InputEventKey and event is InputEventKey:
		return _matches_key(event as InputEventKey, input_event as InputEventKey)

	if input_event is InputEventMouseButton and event is InputEventMouseButton:
		return (input_event as InputEventMouseButton).button_index == (event as InputEventMouseButton).button_index

	if input_event is InputEventJoypadButton and event is InputEventJoypadButton:
		return (input_event as InputEventJoypadButton).button_index == (event as InputEventJoypadButton).button_index

	if input_event is InputEventJoypadMotion and event is InputEventJoypadMotion:
		return (input_event as InputEventJoypadMotion).axis == (event as InputEventJoypadMotion).axis

	if input_event is InputEventScreenTouch and event is InputEventScreenTouch:
		return true

	return input_event.is_match(event, true)


## 计算该输入事件对动作值的贡献。
## @param event: 运行时输入事件。
## @param action_value_type: 动作值类型。
## @return 二维向量贡献；布尔与一维轴使用 x 分量。
func get_contribution(event: InputEvent, action_value_type: GFInputActionBase.ValueType) -> Vector2:
	var raw_value := _read_event_value(event)
	if value_target == ValueTarget.AUTO:
		return _get_auto_contribution(raw_value, action_value_type)

	var strength := _get_target_strength(event, raw_value, value_target)
	if strength < deadzone:
		strength = 0.0

	match value_target:
		ValueTarget.BOOL:
			return Vector2(strength * scale, 0.0)
		ValueTarget.AXIS_1D_POSITIVE:
			return Vector2(strength * scale, 0.0)
		ValueTarget.AXIS_1D_NEGATIVE:
			return Vector2(-strength * scale, 0.0)
		ValueTarget.AXIS_2D_X_POSITIVE:
			return Vector2(strength * scale, 0.0)
		ValueTarget.AXIS_2D_X_NEGATIVE:
			return Vector2(-strength * scale, 0.0)
		ValueTarget.AXIS_2D_Y_POSITIVE:
			return Vector2(0.0, strength * scale)
		ValueTarget.AXIS_2D_Y_NEGATIVE:
			return Vector2(0.0, -strength * scale)
		_:
			return Vector2.ZERO


## 获取显示名称。
## @return 显示名称；为空时由输入事件格式化。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if input_event == null:
		return "Unbound"
	return input_event.as_text()


# --- 私有/辅助方法 ---

func _matches_key(event: InputEventKey, template: InputEventKey) -> bool:
	var template_key := template.physical_keycode
	if template_key == KEY_NONE:
		template_key = template.keycode

	var event_key := event.physical_keycode
	if event_key == KEY_NONE:
		event_key = event.keycode

	return (
		template_key == event_key
		and template.ctrl_pressed == event.ctrl_pressed
		and template.alt_pressed == event.alt_pressed
		and template.shift_pressed == event.shift_pressed
		and template.meta_pressed == event.meta_pressed
	)


func _read_event_value(event: InputEvent) -> float:
	if event is InputEventAction:
		var action_event := event as InputEventAction
		return action_event.strength if action_event.pressed else 0.0

	if event is InputEventKey:
		var key_event := event as InputEventKey
		return 1.0 if key_event.pressed else 0.0

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		return mouse_event.factor if mouse_event.pressed else 0.0

	if event is InputEventJoypadButton:
		var joy_button := event as InputEventJoypadButton
		return joy_button.pressure if joy_button.pressed else 0.0

	if event is InputEventJoypadMotion:
		var axis_event := event as InputEventJoypadMotion
		return axis_event.axis_value if absf(axis_event.axis_value) >= deadzone else 0.0

	if event is InputEventScreenTouch:
		return 1.0 if (event as InputEventScreenTouch).pressed else 0.0

	return 0.0


func _get_target_strength(event: InputEvent, raw_value: float, target: ValueTarget) -> float:
	if event is InputEventJoypadMotion:
		match target:
			ValueTarget.AXIS_1D_POSITIVE, ValueTarget.AXIS_2D_X_POSITIVE, ValueTarget.AXIS_2D_Y_POSITIVE:
				return maxf(raw_value, 0.0)
			ValueTarget.AXIS_1D_NEGATIVE, ValueTarget.AXIS_2D_X_NEGATIVE, ValueTarget.AXIS_2D_Y_NEGATIVE:
				return maxf(-raw_value, 0.0)
			_:
				return absf(raw_value)
	return absf(raw_value)


func _get_auto_contribution(raw_value: float, action_value_type: GFInputActionBase.ValueType) -> Vector2:
	match action_value_type:
		GFInputActionBase.ValueType.BOOL:
			return Vector2(absf(raw_value) * scale, 0.0)
		GFInputActionBase.ValueType.AXIS_1D:
			return Vector2(raw_value * scale, 0.0)
		GFInputActionBase.ValueType.AXIS_2D:
			return Vector2(raw_value * scale, 0.0)
		_:
			return Vector2.ZERO
