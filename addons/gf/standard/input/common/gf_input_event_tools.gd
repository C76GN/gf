# GFInputEventTools: 标准输入模块内部 InputEvent 辅助。
#
# 集中承载 InputEvent 子类收窄和复制逻辑，避免格式化、运行时和触控模块重复实现同一语义。
extends RefCounted

# --- 公共方法 ---

## 复制输入事件，并在复制失败或类型不匹配时返回 null。
## [br]
## @api framework_internal
## [br]
## @layer standard/input
## [br]
## @param event: 输入事件。
## [br]
## @return 输入事件副本。
static func duplicate_input_event(event: InputEvent) -> InputEvent:
	if event == null:
		return null

	var duplicated: Resource = event.duplicate(true)
	return get_input_event(duplicated)


## 将 Variant 收窄为 InputEvent。
## [br]
## @api framework_internal
## [br]
## @layer standard/input
## [br]
## @param value: 待收窄值。
## [br]
## @schema value: InputEvent 或其派生事件对象。
## [br]
## @return 输入事件或 null。
static func get_input_event(value: Variant) -> InputEvent:
	if value is InputEvent:
		var event: InputEvent = value
		return event
	return null


## 将 Variant 收窄为 InputEventAction。
## [br]
## @api framework_internal
## [br]
## @layer standard/input
## [br]
## @param value: 待收窄值。
## [br]
## @schema value: InputEventAction 对象。
## [br]
## @return 输入事件或 null。
static func get_action_event(value: Variant) -> InputEventAction:
	if value is InputEventAction:
		var event: InputEventAction = value
		return event
	return null


## 将 Variant 收窄为 InputEventKey。
## [br]
## @api framework_internal
## [br]
## @layer standard/input
## [br]
## @param value: 待收窄值。
## [br]
## @schema value: InputEventKey 对象。
## [br]
## @return 输入事件或 null。
static func get_key_event(value: Variant) -> InputEventKey:
	if value is InputEventKey:
		var event: InputEventKey = value
		return event
	return null


## 将 Variant 收窄为 InputEventMouseButton。
## [br]
## @api framework_internal
## [br]
## @layer standard/input
## [br]
## @param value: 待收窄值。
## [br]
## @schema value: InputEventMouseButton 对象。
## [br]
## @return 输入事件或 null。
static func get_mouse_button_event(value: Variant) -> InputEventMouseButton:
	if value is InputEventMouseButton:
		var event: InputEventMouseButton = value
		return event
	return null


## 将 Variant 收窄为 InputEventMouseMotion。
## [br]
## @api framework_internal
## [br]
## @layer standard/input
## [br]
## @param value: 待收窄值。
## [br]
## @schema value: InputEventMouseMotion 对象。
## [br]
## @return 输入事件或 null。
static func get_mouse_motion_event(value: Variant) -> InputEventMouseMotion:
	if value is InputEventMouseMotion:
		var event: InputEventMouseMotion = value
		return event
	return null


## 将 Variant 收窄为 InputEventJoypadButton。
## [br]
## @api framework_internal
## [br]
## @layer standard/input
## [br]
## @param value: 待收窄值。
## [br]
## @schema value: InputEventJoypadButton 对象。
## [br]
## @return 输入事件或 null。
static func get_joypad_button_event(value: Variant) -> InputEventJoypadButton:
	if value is InputEventJoypadButton:
		var event: InputEventJoypadButton = value
		return event
	return null


## 将 Variant 收窄为 InputEventJoypadMotion。
## [br]
## @api framework_internal
## [br]
## @layer standard/input
## [br]
## @param value: 待收窄值。
## [br]
## @schema value: InputEventJoypadMotion 对象。
## [br]
## @return 输入事件或 null。
static func get_joypad_motion_event(value: Variant) -> InputEventJoypadMotion:
	if value is InputEventJoypadMotion:
		var event: InputEventJoypadMotion = value
		return event
	return null


## 将 Variant 收窄为 InputEventScreenTouch。
## [br]
## @api framework_internal
## [br]
## @layer standard/input
## [br]
## @param value: 待收窄值。
## [br]
## @schema value: InputEventScreenTouch 对象。
## [br]
## @return 输入事件或 null。
static func get_screen_touch_event(value: Variant) -> InputEventScreenTouch:
	if value is InputEventScreenTouch:
		var event: InputEventScreenTouch = value
		return event
	return null


## 将 Variant 收窄为 InputEventScreenDrag。
## [br]
## @api framework_internal
## [br]
## @layer standard/input
## [br]
## @param value: 待收窄值。
## [br]
## @schema value: InputEventScreenDrag 对象。
## [br]
## @return 输入事件或 null。
static func get_screen_drag_event(value: Variant) -> InputEventScreenDrag:
	if value is InputEventScreenDrag:
		var event: InputEventScreenDrag = value
		return event
	return null
