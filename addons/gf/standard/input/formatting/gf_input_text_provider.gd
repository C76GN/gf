## GFInputTextProvider: 输入文本格式化扩展点。
##
## 项目可继承此资源，为特定设备、平台、本地化或图标字体提供自定义文本。
class_name GFInputTextProvider
extends Resource


# --- 导出变量 ---

## 优先级。数值越大越先尝试。
@export var priority: int = 0


# --- 公共方法 ---

## 获取优先级。
## @return 优先级。
func get_priority() -> int:
	return priority


## 判断是否支持指定输入事件。
## @param _input_event: 输入事件。
## @param _options: 调用选项。
## @return 支持返回 true。
func supports_event(_input_event: InputEvent, _options: Dictionary = {}) -> bool:
	return false


## 获取输入事件文本。
## @param _input_event: 输入事件。
## @param _options: 调用选项。
## @return 文本；返回空字符串会回退到后续 provider 或默认格式化。
func get_event_text(_input_event: InputEvent, _options: Dictionary = {}) -> String:
	return ""
