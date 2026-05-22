## GFInputFormatter: 输入事件与绑定的轻量文本格式化工具。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFInputFormatter
extends RefCounted


# --- 私有变量 ---

static var _text_providers: Array[GFInputTextProvider] = []
static var _icon_providers: Array[GFInputIconProvider] = []


# --- 公共方法 ---

## 将 Godot 输入事件格式化为通用文本。
## [br]
## @api public
## [br]
## @param input_event: 输入事件。
## [br]
## @param options: 可选格式化参数。
## [br]
## @schema options: Dictionary，可包含 unbound_text 和 provider 特定格式化字段。
## [br]
## @return 可显示文本。
static func input_event_as_text(input_event: InputEvent, options: Dictionary = {}) -> String:
	if input_event == null:
		return String(options.get("unbound_text", "Unbound"))

	for provider: GFInputTextProvider in _text_providers:
		if provider == null or not provider.supports_event(input_event, options):
			continue
		var provider_text := provider.get_event_text(input_event, options)
		if not provider_text.is_empty():
			return provider_text

	if input_event is InputEventAction:
		return String((input_event as InputEventAction).action)

	if input_event is InputEventKey:
		return _key_event_as_text(input_event as InputEventKey)

	if input_event is InputEventMouseButton:
		return _mouse_button_as_text((input_event as InputEventMouseButton).button_index)

	if input_event is InputEventJoypadButton:
		return GFInputDeviceTextProvider.format_joypad_event(input_event, options)

	if input_event is InputEventJoypadMotion:
		return GFInputDeviceTextProvider.format_joypad_event(input_event, options)

	if input_event is InputEventScreenTouch:
		return "Touch"

	return input_event.as_text()


## 将 Godot 输入事件格式化为 RichTextLabel BBCode。
## [br]
## @api public
## [br]
## @param input_event: 输入事件。
## [br]
## @param options: 可选格式化参数。
## [br]
## @schema options: Dictionary，可包含 unbound_text、icon_size 和 provider 特定富文本字段。
## [br]
## @return BBCode 文本。
static func input_event_as_rich_text(input_event: InputEvent, options: Dictionary = {}) -> String:
	if input_event == null:
		return _escape_bbcode(String(options.get("unbound_text", "Unbound")))

	for provider: GFInputIconProvider in _icon_providers:
		if provider == null or not provider.supports_event(input_event, options):
			continue
		var rich_text := provider.get_event_rich_text(input_event, options)
		if not rich_text.is_empty():
			return rich_text

	return _escape_bbcode(input_event_as_text(input_event, options))


## 获取输入事件图标。
## [br]
## @api public
## [br]
## @param input_event: 输入事件。
## [br]
## @param options: 可选格式化参数。
## [br]
## @schema options: Dictionary，透传给已注册的图标 provider。
## [br]
## @return 图标资源。
static func input_event_icon(input_event: InputEvent, options: Dictionary = {}) -> Texture2D:
	if input_event == null:
		return null

	for provider: GFInputIconProvider in _icon_providers:
		if provider == null or not provider.supports_event(input_event, options):
			continue
		var icon := provider.get_event_icon(input_event, options)
		if icon != null:
			return icon
	return null


## 将绑定格式化为通用文本。
## [br]
## @api public
## [br]
## @param binding: 输入绑定。
## [br]
## @param options: 可选格式化参数。
## [br]
## @schema options: Dictionary，可包含 unbound_text 和 provider 特定格式化字段。
## [br]
## @return 可显示文本。
static func binding_as_text(binding: GFInputBinding, options: Dictionary = {}) -> String:
	if binding == null:
		return String(options.get("unbound_text", "Unbound"))
	if not binding.display_name.is_empty():
		return binding.display_name
	return input_event_as_text(binding.input_event, options)


## 将绑定格式化为 RichTextLabel BBCode。
## [br]
## @api public
## [br]
## @param binding: 输入绑定。
## [br]
## @param options: 可选格式化参数。
## [br]
## @schema options: Dictionary，可包含 unbound_text、icon_size 和 provider 特定富文本字段。
## [br]
## @return BBCode 文本。
static func binding_as_rich_text(binding: GFInputBinding, options: Dictionary = {}) -> String:
	if binding == null:
		return _escape_bbcode(String(options.get("unbound_text", "Unbound")))
	if not binding.display_name.is_empty():
		return _escape_bbcode(binding.display_name)
	return input_event_as_rich_text(binding.input_event, options)


## 将映射的当前有效绑定格式化为通用文本。
## [br]
## @api public
## [br]
## @param mapping: 输入映射。
## [br]
## @param context_id: 上下文标识。
## [br]
## @param remap_config: 可选重映射配置。
## [br]
## @param options: 可选格式化参数。
## [br]
## @schema options: Dictionary，可包含 unbound_text 和 provider 特定格式化字段。
## [br]
## @return 可显示文本。
static func mapping_as_text(
	mapping: GFInputMapping,
	context_id: StringName = &"",
	remap_config: GFInputRemapConfig = null,
	options: Dictionary = {}
) -> String:
	if mapping == null:
		return ""

	var action_id := mapping.get_action_id()
	var parts: Array[String] = []
	for index: int in range(mapping.bindings.size()):
		var binding := mapping.bindings[index]
		if binding == null:
			continue

		var event := binding.input_event
		if remap_config != null and remap_config.has_binding(context_id, action_id, index):
			event = remap_config.get_bound_event_or_null(context_id, action_id, index)
		parts.append(input_event_as_text(event, options))

	return " / ".join(parts)


## 将映射的当前有效绑定格式化为 RichTextLabel BBCode。
## [br]
## @api public
## [br]
## @param mapping: 输入映射。
## [br]
## @param context_id: 上下文标识。
## [br]
## @param remap_config: 可选重映射配置。
## [br]
## @param options: 可选格式化参数。
## [br]
## @schema options: Dictionary，可包含 unbound_text、icon_size 和 provider 特定富文本字段。
## [br]
## @return BBCode 文本。
static func mapping_as_rich_text(
	mapping: GFInputMapping,
	context_id: StringName = &"",
	remap_config: GFInputRemapConfig = null,
	options: Dictionary = {}
) -> String:
	if mapping == null:
		return ""

	var action_id := mapping.get_action_id()
	var parts: Array[String] = []
	for index: int in range(mapping.bindings.size()):
		var binding := mapping.bindings[index]
		if binding == null:
			continue

		var event := binding.input_event
		if remap_config != null and remap_config.has_binding(context_id, action_id, index):
			event = remap_config.get_bound_event_or_null(context_id, action_id, index)
		parts.append(input_event_as_rich_text(event, options))

	return " / ".join(parts)


## 注册文本 provider。
## [br]
## @api public
## [br]
## @param provider: 文本 provider。
static func add_text_provider(provider: GFInputTextProvider) -> void:
	if provider == null or _text_providers.has(provider):
		return
	_text_providers.append(provider)
	_sort_text_providers()


## 移除文本 provider。
## [br]
## @api public
## [br]
## @param provider: 文本 provider。
static func remove_text_provider(provider: GFInputTextProvider) -> void:
	_text_providers.erase(provider)


## 清空文本 provider。
## [br]
## @api public
static func clear_text_providers() -> void:
	_text_providers.clear()


## 获取已注册文本 provider。
## [br]
## @api public
## [br]
## @return provider 列表副本。
static func get_text_providers() -> Array[GFInputTextProvider]:
	return _text_providers.duplicate()


## 注册图标 provider。
## [br]
## @api public
## [br]
## @param provider: 图标 provider。
static func add_icon_provider(provider: GFInputIconProvider) -> void:
	if provider == null or _icon_providers.has(provider):
		return
	_icon_providers.append(provider)
	_sort_icon_providers()


## 移除图标 provider。
## [br]
## @api public
## [br]
## @param provider: 图标 provider。
static func remove_icon_provider(provider: GFInputIconProvider) -> void:
	_icon_providers.erase(provider)


## 清空图标 provider。
## [br]
## @api public
static func clear_icon_providers() -> void:
	_icon_providers.clear()


## 获取已注册图标 provider。
## [br]
## @api public
## [br]
## @return provider 列表副本。
static func get_icon_providers() -> Array[GFInputIconProvider]:
	return _icon_providers.duplicate()


# --- 私有/辅助方法 ---

static func _sort_text_providers() -> void:
	_text_providers.sort_custom(func(left: GFInputTextProvider, right: GFInputTextProvider) -> bool:
		return left.get_priority() > right.get_priority()
	)


static func _sort_icon_providers() -> void:
	_icon_providers.sort_custom(func(left: GFInputIconProvider, right: GFInputIconProvider) -> bool:
		return left.get_priority() > right.get_priority()
	)


static func _key_event_as_text(event: InputEventKey) -> String:
	var parts: Array[String] = []
	if event.ctrl_pressed:
		parts.append("Ctrl")
	if event.alt_pressed:
		parts.append("Alt")
	if event.shift_pressed:
		parts.append("Shift")
	if event.meta_pressed:
		parts.append("Meta")

	var keycode := event.physical_keycode
	if keycode == KEY_NONE:
		keycode = event.keycode

	var key_text := OS.get_keycode_string(keycode)
	parts.append(key_text if not key_text.is_empty() else "Key %d" % int(keycode))
	return " + ".join(parts)


static func _mouse_button_as_text(button: MouseButton) -> String:
	match button:
		MOUSE_BUTTON_LEFT:
			return "Mouse Left"
		MOUSE_BUTTON_RIGHT:
			return "Mouse Right"
		MOUSE_BUTTON_MIDDLE:
			return "Mouse Middle"
		MOUSE_BUTTON_WHEEL_UP:
			return "Mouse Wheel Up"
		MOUSE_BUTTON_WHEEL_DOWN:
			return "Mouse Wheel Down"
		_:
			return "Mouse Button %d" % int(button)


static func _escape_bbcode(text: String) -> String:
	return text.replace("]", "[rb]").replace("[", "[lb]")
