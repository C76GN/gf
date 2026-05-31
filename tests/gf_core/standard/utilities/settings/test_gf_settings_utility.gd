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
	var _register_setting_result_28: Variant = _settings.register_setting(&"gameplay/max_lives", 3, GFSettingDefinition.ValueType.INT)
	_settings.set_value(&"gameplay/max_lives", "5")

	assert_eq(_setting_int(_settings, &"gameplay/max_lives"), 5, "设置值应按定义转换为 int。")


func test_string_settings_accept_non_string_values() -> void:
	var _register_setting_result_35: Variant = _settings.register_setting(&"profile/slot", "", GFSettingDefinition.ValueType.STRING)
	var _register_setting_result_36: Variant = _settings.register_setting(&"profile/tag", &"", GFSettingDefinition.ValueType.STRING_NAME)
	_settings.set_value(&"profile/slot", 42)
	_settings.set_value(&"profile/tag", 7)

	assert_eq(_setting_text(_settings, &"profile/slot"), "42", "字符串设置应使用安全字符串化。")
	assert_eq(_setting_string_name(_settings, &"profile/tag"), &"7", "StringName 设置应使用安全字符串化。")


func test_register_definition_coerces_preloaded_value() -> void:
	_settings.from_dict({
		"display/window_size": {
			"__gf_setting_type": "Vector2",
			"x": 1280,
			"y": 720,
		},
	}, false)
	var _register_setting_result_52: Variant = _settings.register_setting(
		&"display/window_size",
		Vector2i(800, 600),
		GFSettingDefinition.ValueType.VECTOR2I
	)

	assert_eq(_setting_vector2i(_settings, &"display/window_size"), Vector2i(1280, 720), "后注册定义时应钳制已加载值。")


func test_to_dict_skips_non_persistent_definitions() -> void:
	var _register_setting_result_62: Variant = _settings.register_setting(&"runtime/debug", true, GFSettingDefinition.ValueType.BOOL, false)
	var _register_setting_result_63: Variant = _settings.register_setting(&"audio/master", 0.5, GFSettingDefinition.ValueType.FLOAT, true)

	var data: Dictionary = _settings.to_dict(true)

	assert_false(data.has("runtime/debug"), "非持久化设置不应写入持久化字典。")
	assert_true(data.has("audio/master"), "持久化设置应写入持久化字典。")


func test_serialized_values_roundtrip_structured_types() -> void:
	var _register_setting_result_72: Variant = _settings.register_setting(&"video/size", Vector2i.ZERO, GFSettingDefinition.ValueType.VECTOR2I)
	var _register_setting_result_73: Variant = _settings.register_setting(&"ui/accent", Color.WHITE, GFSettingDefinition.ValueType.COLOR)
	_settings.set_value(&"video/size", Vector2(1024.4, 768.6))
	_settings.set_value(&"ui/accent", Color(0.25, 0.5, 0.75, 1.0))

	var restored: GFSettingsUtility = GFSettingsUtility.new()
	restored.auto_load_on_init = false
	restored.auto_save_on_change = false
	restored.init()
	restored.from_dict(_settings.to_dict(true), false)
	var _register_setting_result_82: Variant = restored.register_setting(&"video/size", Vector2i.ZERO, GFSettingDefinition.ValueType.VECTOR2I)
	var _register_setting_result_83: Variant = restored.register_setting(&"ui/accent", Color.WHITE, GFSettingDefinition.ValueType.COLOR)

	assert_eq(_setting_vector2i(restored, &"video/size"), Vector2i(1024, 769), "Vector2i 设置应可序列化往返。")
	assert_eq(_setting_color(restored, &"ui/accent"), Color(0.25, 0.5, 0.75, 1.0), "Color 设置应可序列化往返。")
	restored.dispose()


func test_serialized_settings_preserve_unsafe_int64_values_through_json() -> void:
	var large_revision: int = 9_007_199_254_740_993
	var _register_setting_result_92: Variant = _settings.register_setting(&"sync/revision", 0, GFSettingDefinition.ValueType.INT)
	_settings.set_value(&"sync/revision", large_revision)

	var parsed: Dictionary = GFVariantData.as_dictionary(JSON.parse_string(JSON.stringify(_settings.to_dict(true))))
	var restored: GFSettingsUtility = GFSettingsUtility.new()
	restored.auto_load_on_init = false
	restored.auto_save_on_change = false
	restored.init()
	restored.from_dict(parsed, false)
	var _register_setting_result_101: Variant = restored.register_setting(&"sync/revision", 0, GFSettingDefinition.ValueType.INT)

	assert_eq(_setting_int(restored, &"sync/revision"), large_revision, "持久化设置中的大整数应精确往返 JSON。")
	restored.dispose()


func test_setting_changed_signal_reports_old_and_new_value() -> void:
	var _register_setting_result_108: Variant = _settings.register_setting(&"audio/master", 1.0, GFSettingDefinition.ValueType.FLOAT)
	watch_signals(_settings)

	_settings.set_value(&"audio/master", 0.25)

	assert_signal_emitted(_settings, "setting_changed", "设置变化时应发出信号。")
	assert_signal_emitted_with_parameters(_settings, "setting_changed", [&"audio/master", 1.0, 0.25])


func test_apply_values_coerces_values_and_reports_counts() -> void:
	var _register_setting_result_118: Variant = _settings.register_setting(&"audio/master", 1.0, GFSettingDefinition.ValueType.FLOAT)
	var _register_setting_result_119: Variant = _settings.register_setting(&"video/fullscreen", false, GFSettingDefinition.ValueType.BOOL)

	var report: Dictionary = _settings.apply_values({
		"audio/master": "0.5",
		&"video/fullscreen": true,
	}, { "save_after_change": false })

	assert_true(GFVariantData.get_option_bool(report, "ok"), "合法预设应应用成功。")
	assert_true(GFVariantData.get_option_bool(report, "healthy"), "无警告和错误时报告应 healthy。")
	assert_eq(GFVariantData.get_option_int(report, "applied_count"), 2, "应报告已应用设置数量。")
	assert_eq(GFVariantData.get_option_int(report, "changed_count"), 2, "应报告实际变化数量。")
	assert_eq(_setting_float(_settings, &"audio/master"), 0.5, "批量应用应沿用设置定义做类型转换。")
	assert_eq(_setting_bool(_settings, &"video/fullscreen"), true, "批量应用应支持 StringName 键。")


func test_apply_values_batches_auto_save_once() -> void:
	var settings: RecordingSettingsUtility = RecordingSettingsUtility.new()
	settings.auto_load_on_init = false
	settings.auto_save_on_change = true
	settings.save_debounce_seconds = 0.5
	settings.init()
	var _register_setting_result_140: Variant = settings.register_setting(&"audio/master", 1.0, GFSettingDefinition.ValueType.FLOAT)
	var _register_setting_result_141: Variant = settings.register_setting(&"audio/music", 1.0, GFSettingDefinition.ValueType.FLOAT)

	var report: Dictionary = settings.apply_values({
		"audio/master": 0.8,
		"audio/music": 0.6,
	})
	settings.tick(0.25)
	settings.tick(0.25)

	assert_true(GFVariantData.get_option_bool(report, "ok"), "批量应用设置应成功。")
	assert_eq(settings.save_count, 1, "批量应用设置时应合并自动保存。")
	assert_eq(settings.saved_files, [settings.storage_file_name], "批量应用保存应使用当前 storage_file_name。")

	settings.dispose()


func test_apply_values_requires_scope_before_reset_missing() -> void:
	var _register_setting_result_158: Variant = _settings.register_setting(&"audio/master", 1.0, GFSettingDefinition.ValueType.FLOAT)
	_settings.set_value(&"audio/master", 0.25)

	var report: Dictionary = _settings.apply_values({}, { "reset_missing": true, "save_after_change": false })
	var issues: Array = GFVariantData.as_array(GFVariantData.get_option_value(report, "issues"))
	var first_issue: Dictionary = GFVariantData.as_dictionary(issues[0])

	assert_false(GFVariantData.get_option_bool(report, "ok"), "缺少 scope 时不应执行 reset_missing。")
	assert_eq(GFVariantData.get_option_int(report, "error_count"), 1, "缺少 scope 应报告一个错误。")
	assert_eq(GFVariantData.get_option_string(first_issue, "kind"), "missing_reset_scope", "问题类型应说明缺少重置作用域。")
	assert_eq(_setting_float(_settings, &"audio/master"), 0.25, "失败的重置预设不应改变设置。")


func test_apply_values_resets_missing_keys_inside_explicit_scope() -> void:
	var _register_setting_result_172: Variant = _settings.register_setting(&"audio/master", 1.0, GFSettingDefinition.ValueType.FLOAT)
	var _register_setting_result_173: Variant = _settings.register_setting(&"audio/music", 1.0, GFSettingDefinition.ValueType.FLOAT)
	var _register_setting_result_174: Variant = _settings.register_setting(&"video/fullscreen", false, GFSettingDefinition.ValueType.BOOL)
	_settings.set_value(&"audio/master", 0.25)
	_settings.set_value(&"audio/music", 0.3)
	_settings.set_value(&"video/fullscreen", true)

	var report: Dictionary = _settings.apply_values({
		"audio/master": 0.75,
		"video/fullscreen": false,
	}, {
		"reset_missing": true,
		"scope": PackedStringArray(["audio/master", "audio/music"]),
		"save_after_change": false,
	})

	assert_true(GFVariantData.get_option_bool(report, "ok"), "显式作用域内的预设应应用成功。")
	assert_false(GFVariantData.get_option_bool(report, "healthy"), "跳过作用域外键时应标记非 healthy。")
	assert_eq(GFVariantData.get_option_int(report, "applied_count"), 1, "只应应用作用域内传入键。")
	assert_eq(GFVariantData.get_option_int(report, "reset_count"), 1, "缺失的作用域内键应重置。")
	assert_eq(GFVariantData.get_option_int(report, "skipped_count"), 1, "作用域外键应被跳过。")
	assert_eq(GFVariantData.get_option_int(report, "warning_count"), 1, "作用域外键应报告 warning。")
	assert_eq(_setting_float(_settings, &"audio/master"), 0.75, "作用域内值应被应用。")
	assert_eq(_setting_float(_settings, &"audio/music"), 1.0, "作用域内缺失值应重置默认值。")
	assert_eq(_setting_bool(_settings, &"video/fullscreen"), true, "作用域外值不应被修改。")


func test_auto_save_debounce_and_batch_flush_once() -> void:
	var settings: RecordingSettingsUtility = RecordingSettingsUtility.new()
	settings.auto_load_on_init = false
	settings.auto_save_on_change = true
	settings.save_debounce_seconds = 0.5
	settings.init()
	var _register_setting_result_205: Variant = settings.register_setting(&"audio/master", 1.0, GFSettingDefinition.ValueType.FLOAT)

	settings.begin_batch()
	settings.set_value(&"audio/master", 0.8)
	settings.set_value(&"audio/master", 0.6)
	settings.end_batch()
	settings.tick(0.25)
	settings.tick(0.25)

	assert_eq(settings.save_count, 1, "批量修改结束后应合并为一次防抖保存。")
	assert_eq(settings.saved_files, [settings.storage_file_name], "防抖保存应使用当前 storage_file_name。")

	settings.dispose()


# --- 私有/辅助方法 ---

func _setting_bool(settings: GFSettingsUtility, key: StringName) -> bool:
	return GFVariantData.to_bool(settings.get_value(key))


func _setting_int(settings: GFSettingsUtility, key: StringName) -> int:
	return GFVariantData.to_int(settings.get_value(key))


func _setting_float(settings: GFSettingsUtility, key: StringName) -> float:
	return GFVariantData.to_float(settings.get_value(key))


func _setting_text(settings: GFSettingsUtility, key: StringName) -> String:
	return GFVariantData.to_text(settings.get_value(key))


func _setting_string_name(settings: GFSettingsUtility, key: StringName) -> StringName:
	return GFVariantData.to_string_name(settings.get_value(key))


func _setting_vector2i(settings: GFSettingsUtility, key: StringName) -> Vector2i:
	var value: Variant = settings.get_value(key)
	if value is Vector2i:
		var vector: Vector2i = value
		return vector
	if value is Vector2:
		var vector2: Vector2 = value
		return Vector2i(roundi(vector2.x), roundi(vector2.y))
	return Vector2i.ZERO


func _setting_color(settings: GFSettingsUtility, key: StringName) -> Color:
	var value: Variant = settings.get_value(key)
	if value is Color:
		var color: Color = value
		return color
	return Color.TRANSPARENT


# --- 辅助类 ---

class RecordingSettingsUtility:
	extends GFSettingsUtility

	var save_count: int = 0
	var saved_files: Array[String] = []

	func _write_persisted_data(file_name: String, _data: Dictionary) -> Error:
		save_count += 1
		saved_files.append(file_name)
		return OK
