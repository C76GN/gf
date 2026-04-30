## 测试 GFSettingsUtility 与 GFSettingDefinition 的设置注册、类型钳制和序列化行为。
extends GutTest


# --- 私有变量 ---

var _settings: GFSettingsUtility


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_settings = GFSettingsUtility.new()
	_settings.auto_load_on_init = false
	_settings.auto_save_on_change = false
	_settings.init()


func after_each() -> void:
	if _settings != null:
		_settings.dispose()
		_settings = null


# --- 测试方法 ---

func test_register_setting_applies_default_and_coerces_values() -> void:
	_settings.register_setting(&"gameplay/max_lives", 3, GFSettingDefinition.ValueType.INT)
	_settings.set_value(&"gameplay/max_lives", "5")

	assert_eq(_settings.get_value(&"gameplay/max_lives"), 5, "设置值应按定义转换为 int。")


func test_register_definition_coerces_preloaded_value() -> void:
	_settings.from_dict({
		"display/window_size": {
			"__gf_setting_type": "Vector2",
			"x": 1280,
			"y": 720,
		},
	}, false)
	_settings.register_setting(
		&"display/window_size",
		Vector2i(800, 600),
		GFSettingDefinition.ValueType.VECTOR2I
	)

	assert_eq(_settings.get_value(&"display/window_size"), Vector2i(1280, 720), "后注册定义时应钳制已加载值。")


func test_to_dict_skips_non_persistent_definitions() -> void:
	_settings.register_setting(&"runtime/debug", true, GFSettingDefinition.ValueType.BOOL, false)
	_settings.register_setting(&"audio/master", 0.5, GFSettingDefinition.ValueType.FLOAT, true)

	var data := _settings.to_dict(true)

	assert_false(data.has("runtime/debug"), "非持久化设置不应写入持久化字典。")
	assert_true(data.has("audio/master"), "持久化设置应写入持久化字典。")


func test_serialized_values_roundtrip_structured_types() -> void:
	_settings.register_setting(&"video/size", Vector2i.ZERO, GFSettingDefinition.ValueType.VECTOR2I)
	_settings.register_setting(&"ui/accent", Color.WHITE, GFSettingDefinition.ValueType.COLOR)
	_settings.set_value(&"video/size", Vector2(1024.4, 768.6))
	_settings.set_value(&"ui/accent", Color(0.25, 0.5, 0.75, 1.0))

	var restored := GFSettingsUtility.new()
	restored.auto_load_on_init = false
	restored.auto_save_on_change = false
	restored.init()
	restored.from_dict(_settings.to_dict(true), false)
	restored.register_setting(&"video/size", Vector2i.ZERO, GFSettingDefinition.ValueType.VECTOR2I)
	restored.register_setting(&"ui/accent", Color.WHITE, GFSettingDefinition.ValueType.COLOR)

	assert_eq(restored.get_value(&"video/size"), Vector2i(1024, 769), "Vector2i 设置应可序列化往返。")
	assert_eq(restored.get_value(&"ui/accent"), Color(0.25, 0.5, 0.75, 1.0), "Color 设置应可序列化往返。")
	restored.dispose()


func test_setting_changed_signal_reports_old_and_new_value() -> void:
	_settings.register_setting(&"audio/master", 1.0, GFSettingDefinition.ValueType.FLOAT)
	watch_signals(_settings)

	_settings.set_value(&"audio/master", 0.25)

	assert_signal_emitted(_settings, "setting_changed", "设置变化时应发出信号。")
	assert_signal_emitted_with_parameters(_settings, "setting_changed", [&"audio/master", 1.0, 0.25])
