## GFInputIconProvider: 输入图标格式化扩展点。
##
## 项目可继承此资源，把输入事件映射为 Texture2D 或 RichTextLabel BBCode。
class_name GFInputIconProvider
extends Resource


# --- 导出变量 ---

## 优先级。数值越大越先尝试。
@export var priority: int = 0

## BBCode 图标默认尺寸。小于等于 0 时不写尺寸。
@export var icon_size: int = 24


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


## 获取输入事件图标。
## @param _input_event: 输入事件。
## @param _options: 调用选项。
## @return 图标资源；返回 null 会回退到后续 provider。
func get_event_icon(_input_event: InputEvent, _options: Dictionary = {}) -> Texture2D:
	return null


## 获取输入事件 RichTextLabel BBCode。
## @param input_event: 输入事件。
## @param options: 调用选项。
## @return BBCode；返回空字符串会回退到文本格式化。
func get_event_rich_text(input_event: InputEvent, options: Dictionary = {}) -> String:
	var icon := get_event_icon(input_event, options)
	if icon == null or icon.resource_path.is_empty():
		return ""

	var size := int(options.get("icon_size", icon_size))
	if size > 0:
		return "[img=%d]%s[/img]" % [size, icon.resource_path]
	return "[img]%s[/img]" % icon.resource_path
