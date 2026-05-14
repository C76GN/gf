@tool

## GF 编辑器工作区通用 UI 辅助。
##
## 提供页面根节点、工具栏、状态文本、空状态和详情区的统一构建函数。
extends RefCounted


# --- 常量 ---

const DEFAULT_DETAILS_MIN_HEIGHT: float = 112.0
const TOOLBAR_SEPARATION: int = 6
const EMPTY_TEXT_COLOR := Color(0.72, 0.72, 0.72)
const INFO_TEXT_COLOR := Color(0.72, 0.72, 0.72)
const OK_TEXT_COLOR := Color(0.45, 0.9, 0.55)
const WARNING_TEXT_COLOR := Color(1.0, 0.78, 0.35)
const ERROR_TEXT_COLOR := Color(1.0, 0.45, 0.35)


# --- 公共方法 ---

## 应用工作区页面根控件的通用尺寸设置。
## @param control: 页面根控件。
static func apply_page_root(control: Control) -> void:
	if control == null:
		return
	control.clip_contents = true
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control.size_flags_vertical = Control.SIZE_EXPAND_FILL
	control.custom_minimum_size = Vector2.ZERO


## 创建通用工具栏容器。
## @return 工具栏容器。
static func make_toolbar() -> HBoxContainer:
	var toolbar := HBoxContainer.new()
	toolbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_theme_constant_override("separation", TOOLBAR_SEPARATION)
	return toolbar


## 创建通用按钮。
## @param text: 按钮文本。
## @param tooltip: 提示文本。
## @param pressed: 按下回调。
## @return 按钮。
static func make_button(text: String, tooltip: String = "", pressed: Callable = Callable()) -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = tooltip
	if pressed.is_valid():
		button.pressed.connect(pressed)
	return button


## 创建通用摘要 Label。
## @param text: 初始文本。
## @return 摘要 Label。
static func make_summary_label(text: String = "") -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.modulate = INFO_TEXT_COLOR
	return label


## 创建通用空状态 Label。
## @param text: 初始文本。
## @return 空状态 Label。
static func make_empty_label(text: String = "") -> Label:
	var label := make_summary_label(text)
	label.modulate = EMPTY_TEXT_COLOR
	label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	return label


## 创建通用详情输出框。
## @param min_height: 最小高度。
## @return 详情输出框。
static func make_details_output(min_height: float = DEFAULT_DETAILS_MIN_HEIGHT) -> TextEdit:
	var details := TextEdit.new()
	details.editable = false
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	details.custom_minimum_size = Vector2(0.0, min_height)
	return details


## 获取校验报告对应的状态颜色。
## @param report: GF 字典式报告。
## @return 状态颜色。
static func get_report_color(report: Dictionary) -> Color:
	if int(report.get("error_count", 0)) > 0:
		return ERROR_TEXT_COLOR
	if int(report.get("warning_count", 0)) > 0:
		return WARNING_TEXT_COLOR
	return OK_TEXT_COLOR


## 把状态文本写入 Label。
## @param label: 目标 Label。
## @param text: 状态文本。
## @param color: 文本颜色。
static func set_status(label: Label, text: String, color: Color = INFO_TEXT_COLOR) -> void:
	if label == null:
		return
	label.text = text
	label.modulate = color
