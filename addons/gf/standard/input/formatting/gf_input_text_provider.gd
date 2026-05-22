## GFInputTextProvider: 输入文本格式化扩展点。
##
## 项目可继承此资源，为特定设备、平台、本地化或图标字体提供自定义文本。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.17.0
class_name GFInputTextProvider
extends Resource


# --- 导出变量 ---

## 优先级。数值越大越先尝试。
## [br]
## @api public
@export var priority: int = 0


# --- 公共方法 ---

## 获取优先级。
## [br]
## @api public
## [br]
## @return 优先级。
func get_priority() -> int:
	return priority


## 判断是否支持指定输入事件。
## [br]
## @api public
## [br]
## @param _input_event: 输入事件。
## [br]
## @param _options: 调用选项。
## [br]
## @schema _options: Dictionary，由 GFInputFormatter 传入，包含 provider 特定格式化字段。
## [br]
## @return 支持返回 true。
func supports_event(_input_event: InputEvent, _options: Dictionary = {}) -> bool:
	return false


## 获取输入事件文本。
## [br]
## @api public
## [br]
## @param _input_event: 输入事件。
## [br]
## @param _options: 调用选项。
## [br]
## @schema _options: Dictionary，由 GFInputFormatter 传入，包含 provider 特定格式化字段。
## [br]
## @return 文本；返回空字符串会回退到后续 provider 或默认格式化。
func get_event_text(_input_event: InputEvent, _options: Dictionary = {}) -> String:
	return ""
