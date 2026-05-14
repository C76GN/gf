## GFTextFitter: 文本尺寸适配器。
##
## 为常见文本控件提供通用字体大小计算，不接管控件布局、主题或项目文本规则。
class_name GFTextFitter
extends RefCounted


# --- 常量 ---

## 默认最小字体尺寸。
const DEFAULT_MIN_FONT_SIZE: int = 8

## 默认最大字体尺寸。
const DEFAULT_MAX_FONT_SIZE: int = 64


# --- 公共方法 ---

## 计算并可选应用常见 Control 的合适字体尺寸。
## @param control: 目标文本控件，支持 Label、RichTextLabel、Button、LineEdit 与 TextEdit，也可通过 options.text 适配自定义控件。
## @param options: 可选设置，支持 min_font_size、max_font_size、available_size、fit_width、fit_height、apply、font_name、font_size_name、text、content_insets、use_placeholder。
## @return 计算出的字体尺寸；目标无效或无法读取文本时返回 0。
static func fit_control(control: Control, options: Dictionary = {}) -> int:
	if control == null:
		return 0
	if control is RichTextLabel:
		return fit_rich_text_label(control as RichTextLabel, options)
	if control is Label:
		return fit_label(control as Label, options)

	var text_info := _get_control_text_info(control, options)
	if text_info.is_empty():
		return 0

	var resolved_options := _resolve_options(
		control,
		_merge_control_text_options(options, text_info),
		StringName(text_info.get("font_name", &"font")),
		StringName(text_info.get("font_size_name", &"font_size"))
	)
	resolved_options["available_size"] = _resolve_content_available_size(control, resolved_options)
	var font_size := _find_largest_fitting_font_size(control, String(text_info.get("text", "")), resolved_options)
	if bool(resolved_options.get("apply", true)):
		control.add_theme_font_size_override(
			resolved_options["font_size_name"] as StringName,
			font_size
		)
	return font_size


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


## 测量常见 Control 在指定字体尺寸下的文本占用。
## @param control: 目标文本控件。
## @param font_size: 字体尺寸。
## @param options: fit_control() 使用的设置。
## @return 文本尺寸；目标无效或字体缺失时返回 Vector2.ZERO。
static func measure_control_text(control: Control, font_size: int, options: Dictionary = {}) -> Vector2:
	if control == null:
		return Vector2.ZERO

	var text_info := _get_control_text_info(control, options)
	if text_info.is_empty():
		return Vector2.ZERO

	var resolved_options := _merge_control_text_options(options, text_info)
	resolved_options["available_size"] = _resolve_content_available_size(control, resolved_options)
	return measure_text(control, String(text_info.get("text", "")), font_size, resolved_options)


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


static func _merge_control_text_options(options: Dictionary, text_info: Dictionary) -> Dictionary:
	var merged := options.duplicate(true)
	if not merged.has("font_name"):
		merged["font_name"] = text_info.get("font_name", &"font")
	if not merged.has("font_size_name"):
		merged["font_size_name"] = text_info.get("font_size_name", &"font_size")
	if not merged.has("content_insets"):
		merged["content_insets"] = text_info.get("content_insets", Vector4.ZERO)
	return merged


static func _get_control_text_info(control: Control, options: Dictionary) -> Dictionary:
	if options.has("text"):
		return {
			"text": String(options.get("text", "")),
			"font_name": StringName(options.get("font_name", &"font")),
			"font_size_name": StringName(options.get("font_size_name", &"font_size")),
			"content_insets": options.get("content_insets", Vector4.ZERO),
		}
	if control is Button:
		return _get_button_text_info(control as Button)
	if control is LineEdit:
		return _get_line_edit_text_info(control as LineEdit, options)
	if control is TextEdit:
		return {
			"text": (control as TextEdit).text,
			"font_name": &"font",
			"font_size_name": &"font_size",
			"content_insets": _get_stylebox_insets(control, &"normal"),
		}
	return {}


static func _get_button_text_info(button: Button) -> Dictionary:
	var insets := _get_stylebox_insets(button, &"normal")
	var icon := button.icon
	if icon != null:
		var icon_size := icon.get_size()
		insets.x += icon_size.x + float(button.get_theme_constant(&"h_separation", &"Button"))
	return {
		"text": button.text,
		"font_name": &"font",
		"font_size_name": &"font_size",
		"content_insets": insets,
	}


static func _get_line_edit_text_info(line_edit: LineEdit, options: Dictionary) -> Dictionary:
	var text := line_edit.text
	if text.is_empty() and bool(options.get("use_placeholder", true)):
		text = line_edit.placeholder_text
	return {
		"text": text,
		"font_name": &"font",
		"font_size_name": &"font_size",
		"content_insets": _get_stylebox_insets(line_edit, &"normal"),
	}


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


static func _resolve_content_available_size(control: Control, options: Dictionary) -> Vector2:
	var size := _resolve_available_size(control, options)
	var insets := _resolve_content_insets(options.get("content_insets", Vector4.ZERO))
	return Vector2(
		maxf(size.x - insets.x - insets.z, 0.0),
		maxf(size.y - insets.y - insets.w, 0.0)
	)


static func _resolve_content_insets(value: Variant) -> Vector4:
	if value is Vector4:
		return value as Vector4
	if value is Rect2:
		var rect := value as Rect2
		return Vector4(rect.position.x, rect.position.y, rect.size.x, rect.size.y)
	if value is Dictionary:
		var data := value as Dictionary
		return Vector4(
			float(data.get("left", 0.0)),
			float(data.get("top", 0.0)),
			float(data.get("right", 0.0)),
			float(data.get("bottom", 0.0))
		)
	return Vector4.ZERO


static func _get_stylebox_insets(control: Control, stylebox_name: StringName) -> Vector4:
	var stylebox := control.get_theme_stylebox(stylebox_name)
	if stylebox == null:
		return Vector4.ZERO
	return Vector4(
		stylebox.get_margin(SIDE_LEFT),
		stylebox.get_margin(SIDE_TOP),
		stylebox.get_margin(SIDE_RIGHT),
		stylebox.get_margin(SIDE_BOTTOM)
	)


static func _measure_lines(font: Font, text: String, font_size: int, wrap_width: float) -> Vector2:
	var lines := text.split("\n")
	var max_width := 0.0
	var total_height := 0.0
	for line: String in lines:
		var line_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
		var line_height := maxf(line_size.y, float(font_size))
		if wrap_width > 0.0 and line_size.x > wrap_width:
			var wrapped_size := _measure_wrapped_line(font, line, font_size, wrap_width, line_height)
			max_width = maxf(max_width, wrapped_size.x)
			total_height += wrapped_size.y
		else:
			max_width = maxf(max_width, line_size.x)
			total_height += line_height
	return Vector2(max_width, total_height)


static func _measure_wrapped_line(
	font: Font,
	line: String,
	font_size: int,
	wrap_width: float,
	line_height: float
) -> Vector2:
	if line.is_empty():
		return Vector2(0.0, line_height)

	var max_width := 0.0
	var line_count := 1
	var current_text := ""
	for index: int in range(line.length()):
		var next_text := current_text + line.substr(index, 1)
		var next_width := font.get_string_size(next_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
		if not current_text.is_empty() and next_width > wrap_width:
			var current_width := font.get_string_size(current_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
			max_width = maxf(max_width, minf(current_width, wrap_width))
			line_count += 1
			current_text = line.substr(index, 1)
		else:
			current_text = next_text

	if not current_text.is_empty():
		var current_width := font.get_string_size(current_text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
		max_width = maxf(max_width, minf(current_width, wrap_width))
	return Vector2(max_width, line_height * float(line_count))


static func _strip_bbcode(text: String) -> String:
	var regex := RegEx.new()
	var error := regex.compile("\\[[^\\]]*\\]")
	if error != OK:
		return text
	return regex.sub(text, "", true)
