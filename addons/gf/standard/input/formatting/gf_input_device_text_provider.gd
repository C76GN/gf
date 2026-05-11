## GFInputDeviceTextProvider: 通用手柄输入文本 provider。
##
## 以抽象方位和轴名称描述 Joypad 输入，项目可通过字典覆盖为任意设备、平台或本地化文本。
class_name GFInputDeviceTextProvider
extends GFInputTextProvider


# --- 常量 ---

const DEFAULT_BUTTON_LABELS: Dictionary = {
	JOY_BUTTON_A: "Button South",
	JOY_BUTTON_B: "Button East",
	JOY_BUTTON_X: "Button West",
	JOY_BUTTON_Y: "Button North",
	JOY_BUTTON_BACK: "Back",
	JOY_BUTTON_GUIDE: "Guide",
	JOY_BUTTON_START: "Start",
	JOY_BUTTON_LEFT_STICK: "Left Stick",
	JOY_BUTTON_RIGHT_STICK: "Right Stick",
	JOY_BUTTON_LEFT_SHOULDER: "Left Shoulder",
	JOY_BUTTON_RIGHT_SHOULDER: "Right Shoulder",
	JOY_BUTTON_DPAD_UP: "D-Pad Up",
	JOY_BUTTON_DPAD_DOWN: "D-Pad Down",
	JOY_BUTTON_DPAD_LEFT: "D-Pad Left",
	JOY_BUTTON_DPAD_RIGHT: "D-Pad Right",
	JOY_BUTTON_MISC1: "Misc",
	JOY_BUTTON_PADDLE1: "Paddle 1",
	JOY_BUTTON_PADDLE2: "Paddle 2",
	JOY_BUTTON_PADDLE3: "Paddle 3",
	JOY_BUTTON_PADDLE4: "Paddle 4",
	JOY_BUTTON_TOUCHPAD: "Touchpad",
}

const DEFAULT_AXIS_LABELS: Dictionary = {
	JOY_AXIS_LEFT_X: "Left Stick X",
	JOY_AXIS_LEFT_Y: "Left Stick Y",
	JOY_AXIS_RIGHT_X: "Right Stick X",
	JOY_AXIS_RIGHT_Y: "Right Stick Y",
	JOY_AXIS_TRIGGER_LEFT: "Left Trigger",
	JOY_AXIS_TRIGGER_RIGHT: "Right Trigger",
}


# --- 导出变量 ---

## Joypad 按钮标签表，Key 为 JoyButton int。
@export var button_labels: Dictionary = DEFAULT_BUTTON_LABELS

## Joypad 轴标签表，Key 为 JoyAxis int。
@export var axis_labels: Dictionary = DEFAULT_AXIS_LABELS

## 正向轴后缀。
@export var axis_positive_suffix: String = "+"

## 负向轴后缀。
@export var axis_negative_suffix: String = "-"

## 轴方向判断死区。
@export_range(0.0, 1.0, 0.001) var axis_direction_deadzone: float = 0.1


# --- 公共方法 ---

## 创建标准手柄文本 provider。
## @param provider_priority: provider 优先级。
## @return 文本 provider。
static func create_standard(provider_priority: int = 0) -> GFInputDeviceTextProvider:
	var provider := GFInputDeviceTextProvider.new()
	provider.priority = provider_priority
	return provider


## 使用标准标签格式化 Joypad 输入事件。
## @param input_event: 输入事件。
## @param options: 可选格式化参数。
## @return 文本；非 Joypad 事件返回空字符串。
static func format_joypad_event(input_event: InputEvent, options: Dictionary = {}) -> String:
	var provider := create_standard()
	return provider.get_event_text(input_event, options)


## 判断是否支持指定输入事件。
## @param input_event: 输入事件。
## @param _options: 调用选项。
## @return 支持返回 true。
func supports_event(input_event: InputEvent, _options: Dictionary = {}) -> bool:
	return input_event is InputEventJoypadButton or input_event is InputEventJoypadMotion


## 获取输入事件文本。
## @param input_event: 输入事件。
## @param options: 调用选项。
## @return 文本；不支持时返回空字符串。
func get_event_text(input_event: InputEvent, options: Dictionary = {}) -> String:
	if input_event is InputEventJoypadButton:
		return _button_as_text((input_event as InputEventJoypadButton).button_index, options)
	if input_event is InputEventJoypadMotion:
		var motion := input_event as InputEventJoypadMotion
		return _axis_as_text(motion.axis, motion.axis_value, options)
	return ""


# --- 私有/辅助方法 ---

func _button_as_text(button: JoyButton, options: Dictionary) -> String:
	var labels := options.get("joypad_button_labels", button_labels) as Dictionary
	if labels != null and labels.has(int(button)):
		return String(labels[int(button)])
	return "Joy Button %d" % int(button)


func _axis_as_text(axis: JoyAxis, axis_value: float, options: Dictionary) -> String:
	var labels := options.get("joypad_axis_labels", axis_labels) as Dictionary
	var base_text := ""
	if labels != null and labels.has(int(axis)):
		base_text = String(labels[int(axis)])
	else:
		base_text = "Joy Axis %d" % int(axis)

	var deadzone := float(options.get("joypad_axis_deadzone", axis_direction_deadzone))
	if absf(axis_value) <= deadzone:
		return base_text
	if axis_value > 0.0:
		return "%s %s" % [base_text, String(options.get("joypad_axis_positive_suffix", axis_positive_suffix))]
	return "%s %s" % [base_text, String(options.get("joypad_axis_negative_suffix", axis_negative_suffix))]
