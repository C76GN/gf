## GFTextFitUtility: 文本尺寸适配工具。
##
## 为 Label 与 RichTextLabel 提供通用字体大小计算，不接管控件布局、主题或项目文本规则。
class_name GFTextFitUtility
extends RefCounted


# --- 常量 ---

## 默认最小字体尺寸。
const DEFAULT_MIN_FONT_SIZE: int = 8

## 默认最大字体尺寸。
const DEFAULT_MAX_FONT_SIZE: int = 64


# --- 公共方法 ---

## 计算并可选应用 Label 的合适字体尺寸。
## @param label: 目标 Label。
## @param options: 可选设置，支持 min_font_size、max_font_size、available_size、fit_width、fit_height、apply、font_name、font_size_name。
## @return 计算出的字体尺寸；目标无效时返回 0。
static func fit_label(label: Label, options: Dictionary = {}) -> int:
	if label == null:
		return 0

	var resolved_options := _resolve_options(
		label,
		options,
		&"font",
		&"font_size"
	)
	var font_size := _find_largest_fitting_font_size(label, label.text, resolved_options)
	if bool(resolved_options.get("apply", true)):
		label.add_theme_font_size_override(
			resolved_options["font_size_name"] as StringName,
			font_size
		)
	return font_size


## 计算并可选应用 RichTextLabel 的合适字体尺寸。
## @param label: 目标 RichTextLabel。
## @param options: 可选设置，支持 min_font_size、max_font_size、available_size、fit_width、fit_height、apply、font_name、font_size_name。
## @return 计算出的字体尺寸；目标无效时返回 0。
static func fit_rich_text_label(label: RichTextLabel, options: Dictionary = {}) -> int:
	if label == null:
		return 0

	var resolved_options := _resolve_options(
		label,
		options,
		&"normal_font",
		&"normal_font_size"
	)
	var text := label.text
	if label.bbcode_enabled:
		text = _strip_bbcode(text)

	var font_size := _find_largest_fitting_font_size(label, text, resolved_options)
	if bool(resolved_options.get("apply", true)):
		label.add_theme_font_size_override(
			resolved_options["font_size_name"] as StringName,
			font_size
		)
	return font_size


## 测量 Control 在指定字体尺寸下的文本占用。
## @param control: 提供主题字体的控件。
## @param text: 待测量文本。
## @param font_size: 字体尺寸。
## @param options: fit_label() 或 fit_rich_text_label() 使用的设置。
## @return 文本尺寸；字体缺失时返回 Vector2.ZERO。
static func measure_text(control: Control, text: String, font_size: int, options: Dictionary = {}) -> Vector2:
	if control == null:
		return Vector2.ZERO

	var font_name := StringName(options.get("font_name", &"font"))
	var font := options.get("font", null) as Font
	if font == null:
		font = control.get_theme_font(font_name)
	if font == null:
		return Vector2.ZERO

	var available_size := _resolve_available_size(control, options)
	var fit_width := bool(options.get("fit_width", true))
	var wrap_width := available_size.x if fit_width and available_size.x > 0.0 else -1.0
	return _measure_lines(font, text, font_size, wrap_width)


# --- 私有/辅助方法 ---

static func _resolve_options(
	control: Control,
	options: Dictionary,
	default_font_name: StringName,
	default_font_size_name: StringName
) -> Dictionary:
	var resolved := options.duplicate(true)
	resolved["font_name"] = StringName(resolved.get("font_name", default_font_name))
	resolved["font_size_name"] = StringName(resolved.get("font_size_name", default_font_size_name))
	resolved["min_font_size"] = maxi(int(resolved.get("min_font_size", DEFAULT_MIN_FONT_SIZE)), 1)

	var max_font_size := int(resolved.get("max_font_size", 0))
	if max_font_size <= 0:
		max_font_size = control.get_theme_font_size(resolved["font_size_name"] as StringName)
	if max_font_size <= 0:
		max_font_size = DEFAULT_MAX_FONT_SIZE

	resolved["max_font_size"] = maxi(max_font_size, int(resolved["min_font_size"]))
	resolved["fit_width"] = bool(resolved.get("fit_width", true))
	resolved["fit_height"] = bool(resolved.get("fit_height", true))
	resolved["apply"] = bool(resolved.get("apply", true))
	return resolved


static func _find_largest_fitting_font_size(control: Control, text: String, options: Dictionary) -> int:
	var min_font_size := int(options.get("min_font_size", DEFAULT_MIN_FONT_SIZE))
	var max_font_size := int(options.get("max_font_size", DEFAULT_MAX_FONT_SIZE))
	var best_size := min_font_size
	var low := min_font_size
	var high := max_font_size

	while low <= high:
		var candidate := (low + high) / 2
		if _fits(control, text, candidate, options):
			best_size = candidate
			low = candidate + 1
		else:
			high = candidate - 1

	return best_size


static func _fits(control: Control, text: String, font_size: int, options: Dictionary) -> bool:
	var available_size := _resolve_available_size(control, options)
	if available_size.x <= 0.0 and available_size.y <= 0.0:
		return true

	var measured_size := measure_text(control, text, font_size, options)
	var fit_width := bool(options.get("fit_width", true))
	var fit_height := bool(options.get("fit_height", true))
	if fit_width and available_size.x > 0.0 and measured_size.x > available_size.x:
		return false
	if fit_height and available_size.y > 0.0 and measured_size.y > available_size.y:
		return false
	return true


static func _resolve_available_size(control: Control, options: Dictionary) -> Vector2:
	var available_size: Variant = options.get("available_size", control.size)
	if available_size is Vector2i:
		return Vector2(available_size)
	if available_size is Vector2:
		return available_size as Vector2
	return control.size


static func _measure_lines(font: Font, text: String, font_size: int, wrap_width: float) -> Vector2:
	var lines := text.split("\n")
	var max_width := 0.0
	var total_height := 0.0
	for line: String in lines:
		var line_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
		var line_height := maxf(line_size.y, float(font_size))
		if wrap_width > 0.0 and line_size.x > wrap_width:
			var wrapped_lines := ceili(line_size.x / wrap_width)
			max_width = maxf(max_width, wrap_width)
			total_height += line_height * float(wrapped_lines)
		else:
			max_width = maxf(max_width, line_size.x)
			total_height += line_height
	return Vector2(max_width, total_height)


static func _strip_bbcode(text: String) -> String:
	var regex := RegEx.new()
	var error := regex.compile("\\[[^\\]]*\\]")
	if error != OK:
		return text
	return regex.sub(text, "", true)
