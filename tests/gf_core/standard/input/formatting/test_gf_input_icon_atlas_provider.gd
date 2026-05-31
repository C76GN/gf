## 测试 GFInputIconAtlasProvider 的输入图标键与路径解析。
extends GutTest


# --- 测试方法 ---

## 验证键盘事件可以解析为显式路径。
func test_input_icon_atlas_resolves_explicit_key_path() -> void:
	var provider: GFInputIconAtlasProvider = GFInputIconAtlasProvider.new()
	provider.set_icon_path(&"key:k", "res://icons/keyboard/k.png")

	var path: String = provider.get_event_icon_path(_make_key_event(KEY_K), { "allow_missing_paths": true })

	assert_eq(path, "res://icons/keyboard/k.png", "显式路径应优先于模板路径。")
	assert_true(provider.supports_event(_make_key_event(KEY_K), { "allow_missing_paths": true }), "允许缺失路径时显式映射应视为支持。")


## 验证路径模板可按风格和平台生成通用路径。
func test_input_icon_atlas_builds_template_path() -> void:
	var provider: GFInputIconAtlasProvider = GFInputIconAtlasProvider.new()
	provider.root_path = "res://icons"
	provider.style = &"line"
	provider.platform = &"pc"

	var path: String = provider.get_event_icon_path(_make_mouse_event(MOUSE_BUTTON_LEFT), { "allow_missing_paths": true })

	assert_eq(path, "res://icons/line/pc/mouse_left.png", "模板路径应使用 root/style/platform/icon。")


## 验证组合键 RichText 可拆成多个图标。
func test_input_icon_atlas_splits_modifier_rich_text() -> void:
	var provider: GFInputIconAtlasProvider = GFInputIconAtlasProvider.new()
	provider.set_icon_path(&"key:ctrl", "res://icons/ctrl.png")
	provider.set_icon_path(&"key:shift", "res://icons/shift.png")
	provider.set_icon_path(&"key:k", "res://icons/k.png")
	var event: InputEventKey = _make_key_event(KEY_K)
	event.ctrl_pressed = true
	event.shift_pressed = true

	var rich_text: String = provider.get_event_rich_text(event, { "allow_missing_paths": true, "icon_size": 16 })

	assert_true(rich_text.contains("ctrl.png"), "组合键应包含 Ctrl 图标。")
	assert_true(rich_text.contains("shift.png"), "组合键应包含 Shift 图标。")
	assert_true(rich_text.contains("k.png"), "组合键应包含主键图标。")


# --- 私有/辅助方法 ---

func _make_key_event(key: Key) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = true
	return event


func _make_mouse_event(button: MouseButton) -> InputEventMouseButton:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = button
	event.pressed = true
	return event
