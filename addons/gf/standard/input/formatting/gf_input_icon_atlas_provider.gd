## GFInputIconAtlasProvider: 可配置输入图标图集 Provider。
##
## 将 InputEvent 归一化为通用图标键，再通过显式映射或路径模板解析 Texture2D / RichText 图标。
## 框架不附带图标资源，也不规定项目的美术风格或平台命名。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFInputIconAtlasProvider
extends GFInputIconProvider


# --- 导出变量 ---

## 图标根目录。路径模板中的 {root} 会使用该值。
## [br]
## @api public
@export var root_path: String = ""

## 图标风格名。路径模板中的 {style} 会使用该值。
## [br]
## @api public
@export var style: StringName = &"default"

## 平台名。为空时使用 options.platform 或 fallback_platform。
## [br]
## @api public
@export var platform: StringName = &""

## 平台回退名。
## [br]
## @api public
@export var fallback_platform: StringName = &"generic"

## 路径模板。可使用 {root}、{style}、{platform}、{icon}。
## [br]
## @api public
@export var path_pattern: String = "{root}/{style}/{platform}/{icon}.png"

## 显式路径映射，key 为 get_event_icon_candidates() 产生的图标键。
## [br]
## @api public
## [br]
## @schema icon_paths: Dictionary，以 StringName 或 String 图标键为键，值为 String Texture2D 资源路径。
@export var icon_paths: Dictionary = {}

## 显式纹理映射，key 为 get_event_icon_candidates() 产生的图标键。
## [br]
## @api public
## [br]
## @schema icon_textures: Dictionary，以 StringName 或 String 图标键为键，值为 Texture2D。
@export var icon_textures: Dictionary = {}

## RichText 输出多个图标时使用的分隔文本。
## [br]
## @api public
@export var rich_text_separator: String = " "

## 是否为带修饰键的键盘事件输出多个图标。
## [br]
## @api public
@export var split_key_modifiers: bool = true


# --- 私有变量 ---

var _texture_cache: Dictionary = {}


# --- 公共方法 ---

## 设置图标路径映射。
## [br]
## @api public
## [br]
## @param icon_key: 图标键。
## [br]
## @param resource_path: Texture2D 资源路径。
func set_icon_path(icon_key: StringName, resource_path: String) -> void:
	if icon_key == &"":
		return
	if resource_path.is_empty():
		icon_paths.erase(icon_key)
	else:
		icon_paths[icon_key] = resource_path
	_texture_cache.erase(resource_path)


## 设置图标纹理映射。
## [br]
## @api public
## [br]
## @param icon_key: 图标键。
## [br]
## @param texture: 图标纹理。
func set_icon_texture(icon_key: StringName, texture: Texture2D) -> void:
	if icon_key == &"":
		return
	if texture == null:
		icon_textures.erase(icon_key)
	else:
		icon_textures[icon_key] = texture


## 清空已加载的纹理缓存。
## [br]
## @api public
func clear_cache() -> void:
	_texture_cache.clear()


## 判断是否支持指定输入事件。
## [br]
## @api public
## [br]
## @param input_event: 输入事件。
## [br]
## @param options: 调用选项。
## [br]
## @schema options: Dictionary，可包含 allow_missing_paths、root_path、style、platform、path_pattern、split_key_modifiers 和 include_key_modifier_combo。
## [br]
## @return 支持返回 true。
func supports_event(input_event: InputEvent, options: Dictionary = {}) -> bool:
	if input_event == null:
		return false
	if _resolve_texture_for_candidates(get_event_icon_candidates(input_event, options)) != null:
		return true
	return not get_event_icon_path(input_event, options).is_empty()


## 获取输入事件图标。
## [br]
## @api public
## [br]
## @param input_event: 输入事件。
## [br]
## @param options: 调用选项。
## [br]
## @schema options: Dictionary，可包含 allow_missing_paths、root_path、style、platform、path_pattern、split_key_modifiers 和 include_key_modifier_combo。
## [br]
## @return 图标纹理；不存在时返回 null。
func get_event_icon(input_event: InputEvent, options: Dictionary = {}) -> Texture2D:
	if input_event == null:
		return null

	var candidates := get_event_icon_candidates(input_event, options)
	var mapped_texture := _resolve_texture_for_candidates(candidates)
	if mapped_texture != null:
		return mapped_texture

	var icon_path := _resolve_path_for_candidates(candidates, options)
	if icon_path.is_empty():
		return null
	if _texture_cache.has(icon_path):
		return _texture_cache[icon_path] as Texture2D
	if not ResourceLoader.exists(icon_path, "Texture2D"):
		return null

	var texture := ResourceLoader.load(icon_path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	if texture != null:
		_texture_cache[icon_path] = texture
	return texture


## 获取输入事件 RichTextLabel BBCode。
## [br]
## @api public
## [br]
## @param input_event: 输入事件。
## [br]
## @param options: 调用选项。
## [br]
## @schema options: Dictionary，可包含 allow_missing_paths、icon_size、rich_text_separator、root_path、style、platform、path_pattern、split_key_modifiers 和 include_key_modifier_combo。
## [br]
## @return BBCode；无法解析时返回空字符串。
func get_event_rich_text(input_event: InputEvent, options: Dictionary = {}) -> String:
	if input_event == null:
		return ""

	var paths := _get_rich_text_icon_paths(input_event, options)
	if paths.is_empty():
		return ""

	var parts := PackedStringArray()
	var size := int(options.get("icon_size", icon_size))
	for icon_path: String in paths:
		if size > 0:
			parts.append("[img=%d]%s[/img]" % [size, icon_path])
		else:
			parts.append("[img]%s[/img]" % icon_path)
	return _variant_to_string(options.get("rich_text_separator", rich_text_separator), rich_text_separator).join(parts)


## 获取输入事件的首选图标路径。
## [br]
## @api public
## [br]
## @param input_event: 输入事件。
## [br]
## @param options: 调用选项。
## [br]
## @schema options: Dictionary，可包含 allow_missing_paths、root_path、style、platform、path_pattern、split_key_modifiers 和 include_key_modifier_combo。
## [br]
## @return 图标路径；无法解析时返回空字符串。
func get_event_icon_path(input_event: InputEvent, options: Dictionary = {}) -> String:
	if input_event == null:
		return ""
	return _resolve_path_for_candidates(get_event_icon_candidates(input_event, options), options)


## 获取输入事件的首选图标键。
## [br]
## @api public
## [br]
## @param input_event: 输入事件。
## [br]
## @param options: 调用选项。
## [br]
## @schema options: Dictionary，可包含 split_key_modifiers 和 include_key_modifier_combo。
## [br]
## @return 图标键；无法解析时返回空 StringName。
func resolve_event_icon_key(input_event: InputEvent, options: Dictionary = {}) -> StringName:
	var candidates := get_event_icon_candidates(input_event, options)
	return StringName(candidates[0]) if not candidates.is_empty() else &""


## 获取输入事件可能使用的图标键列表。
## [br]
## @api public
## [br]
## @param input_event: 输入事件。
## [br]
## @param options: 调用选项。
## [br]
## @schema options: Dictionary，可包含 split_key_modifiers 和 include_key_modifier_combo。
## [br]
## @return 图标键列表，按优先级排序。
func get_event_icon_candidates(input_event: InputEvent, options: Dictionary = {}) -> PackedStringArray:
	var candidates := PackedStringArray()
	if input_event == null:
		return candidates

	if input_event is InputEventAction:
		candidates.append("action:%s" % _sanitize_icon_name(str((input_event as InputEventAction).action)))
	elif input_event is InputEventKey:
		_append_key_candidates(candidates, input_event as InputEventKey, options)
	elif input_event is InputEventMouseButton:
		_append_mouse_button_candidates(candidates, (input_event as InputEventMouseButton).button_index)
	elif input_event is InputEventJoypadButton:
		_append_joy_button_candidates(candidates, (input_event as InputEventJoypadButton).button_index)
	elif input_event is InputEventJoypadMotion:
		_append_joy_axis_candidates(candidates, input_event as InputEventJoypadMotion)
	elif input_event is InputEventScreenTouch:
		candidates.append("touch")
	return candidates


# --- 私有/辅助方法 ---

func _get_rich_text_icon_paths(input_event: InputEvent, options: Dictionary) -> PackedStringArray:
	if input_event is InputEventKey and bool(options.get("split_key_modifiers", split_key_modifiers)):
		var key_event := input_event as InputEventKey
		var paths := PackedStringArray()
		for modifier: String in _get_key_modifier_names(key_event):
			var modifier_path := _resolve_path_for_candidates(PackedStringArray(["key:%s" % modifier]), options)
			if modifier_path.is_empty():
				return PackedStringArray()
			paths.append(modifier_path)

		var key_only := key_event.duplicate() as InputEventKey
		key_only.ctrl_pressed = false
		key_only.alt_pressed = false
		key_only.shift_pressed = false
		key_only.meta_pressed = false
		var key_path := get_event_icon_path(key_only, options)
		if key_path.is_empty():
			return PackedStringArray()
		paths.append(key_path)
		return paths

	var icon_path := get_event_icon_path(input_event, options)
	if icon_path.is_empty():
		return PackedStringArray()
	return PackedStringArray([icon_path])


func _append_key_candidates(candidates: PackedStringArray, event: InputEventKey, options: Dictionary) -> void:
	var keycode := event.physical_keycode
	if keycode == KEY_NONE:
		keycode = event.keycode

	var key_name := _sanitize_icon_name(OS.get_keycode_string(keycode))
	var modifiers := _get_key_modifier_names(event)
	if bool(options.get("include_key_modifier_combo", true)) and not modifiers.is_empty():
		var combo_parts := modifiers.duplicate()
		combo_parts.append(key_name)
		candidates.append("key:%s" % "+".join(combo_parts))
	if not key_name.is_empty():
		candidates.append("key:%s" % key_name)
	candidates.append("key:%d" % int(keycode))


func _append_mouse_button_candidates(candidates: PackedStringArray, button: MouseButton) -> void:
	match button:
		MOUSE_BUTTON_LEFT:
			candidates.append("mouse:left")
		MOUSE_BUTTON_RIGHT:
			candidates.append("mouse:right")
		MOUSE_BUTTON_MIDDLE:
			candidates.append("mouse:middle")
		MOUSE_BUTTON_WHEEL_UP:
			candidates.append("mouse:wheel_up")
		MOUSE_BUTTON_WHEEL_DOWN:
			candidates.append("mouse:wheel_down")
	candidates.append("mouse:%d" % int(button))


func _append_joy_button_candidates(candidates: PackedStringArray, button: JoyButton) -> void:
	match button:
		JOY_BUTTON_A:
			candidates.append("joy_button:south")
		JOY_BUTTON_B:
			candidates.append("joy_button:east")
		JOY_BUTTON_X:
			candidates.append("joy_button:west")
		JOY_BUTTON_Y:
			candidates.append("joy_button:north")
		JOY_BUTTON_LEFT_SHOULDER:
			candidates.append("joy_button:left_shoulder")
		JOY_BUTTON_RIGHT_SHOULDER:
			candidates.append("joy_button:right_shoulder")
		JOY_BUTTON_LEFT_STICK:
			candidates.append("joy_button:left_stick")
		JOY_BUTTON_RIGHT_STICK:
			candidates.append("joy_button:right_stick")
		JOY_BUTTON_BACK:
			candidates.append("joy_button:back")
		JOY_BUTTON_START:
			candidates.append("joy_button:start")
		JOY_BUTTON_DPAD_UP:
			candidates.append("joy_button:dpad_up")
		JOY_BUTTON_DPAD_DOWN:
			candidates.append("joy_button:dpad_down")
		JOY_BUTTON_DPAD_LEFT:
			candidates.append("joy_button:dpad_left")
		JOY_BUTTON_DPAD_RIGHT:
			candidates.append("joy_button:dpad_right")
	candidates.append("joy_button:%d" % int(button))


func _append_joy_axis_candidates(candidates: PackedStringArray, event: InputEventJoypadMotion) -> void:
	var suffix := "positive" if event.axis_value >= 0.0 else "negative"
	match event.axis:
		JOY_AXIS_LEFT_X:
			candidates.append("joy_axis:left_x_%s" % suffix)
		JOY_AXIS_LEFT_Y:
			candidates.append("joy_axis:left_y_%s" % suffix)
		JOY_AXIS_RIGHT_X:
			candidates.append("joy_axis:right_x_%s" % suffix)
		JOY_AXIS_RIGHT_Y:
			candidates.append("joy_axis:right_y_%s" % suffix)
		JOY_AXIS_TRIGGER_LEFT:
			candidates.append("joy_axis:left_trigger")
		JOY_AXIS_TRIGGER_RIGHT:
			candidates.append("joy_axis:right_trigger")
	candidates.append("joy_axis:%d:%s" % [int(event.axis), suffix])


func _resolve_texture_for_candidates(candidates: PackedStringArray) -> Texture2D:
	for candidate: String in candidates:
		var texture: Variant = _get_mapping_value(icon_textures, candidate)
		if texture is Texture2D:
			return texture
	return null


func _resolve_path_for_candidates(candidates: PackedStringArray, options: Dictionary) -> String:
	for candidate: String in candidates:
		var mapped_path := _variant_to_string(_get_mapping_value(icon_paths, candidate))
		if not mapped_path.is_empty() and _path_is_allowed(mapped_path, options):
			return mapped_path

	for candidate: String in candidates:
		var generated_path := _build_icon_path(candidate, options)
		if not generated_path.is_empty() and _path_is_allowed(generated_path, options):
			return generated_path
	return ""


func _build_icon_path(icon_key: String, options: Dictionary) -> String:
	var root := _variant_to_string(options.get("root_path", root_path), root_path)
	var selected_style := _variant_to_string(options.get("style", style), str(style))
	var selected_platform := _variant_to_string(options.get("platform", platform), str(platform))
	if selected_platform.is_empty():
		selected_platform = str(fallback_platform)
	var icon_name := _sanitize_icon_name(icon_key.replace(":", "_").replace("+", "_"))
	var resolved_path := _variant_to_string(options.get("path_pattern", path_pattern), path_pattern)
	resolved_path = resolved_path.replace("{root}", root.trim_suffix("/"))
	resolved_path = resolved_path.replace("{style}", selected_style)
	resolved_path = resolved_path.replace("{platform}", selected_platform)
	resolved_path = resolved_path.replace("{icon}", icon_name)
	return resolved_path


func _path_is_allowed(resource_path: String, options: Dictionary) -> bool:
	if resource_path.is_empty():
		return false
	if bool(options.get("allow_missing_paths", false)):
		return true
	return ResourceLoader.exists(resource_path, "Texture2D")


func _get_mapping_value(mapping: Dictionary, key: String) -> Variant:
	var string_name_key := StringName(key)
	if mapping.has(string_name_key):
		return mapping[string_name_key]
	if mapping.has(key):
		return mapping[key]
	return null


func _variant_to_string(value: Variant, fallback: String = "") -> String:
	if value == null:
		return fallback
	if value is String:
		return value as String
	return str(value)


func _get_key_modifier_names(event: InputEventKey) -> PackedStringArray:
	var result := PackedStringArray()
	if event.ctrl_pressed:
		result.append("ctrl")
	if event.alt_pressed:
		result.append("alt")
	if event.shift_pressed:
		result.append("shift")
	if event.meta_pressed:
		result.append("meta")
	return result


func _sanitize_icon_name(value: String) -> String:
	var result := value.strip_edges().to_lower()
	result = result.replace(" ", "_")
	result = result.replace("/", "_")
	result = result.replace("\\", "_")
	result = result.replace(".", "_")
	return result
