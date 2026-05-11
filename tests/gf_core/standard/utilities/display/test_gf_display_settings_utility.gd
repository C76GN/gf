## 测试 GFDisplaySettingsUtility 的运行时设置应用和 GFSettingsUtility 集成。
extends GutTest


# --- 私有变量 ---

var _arch: GFArchitecture = null
var _original_locale: String = ""


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_original_locale = TranslationServer.get_locale()


func after_each() -> void:
	TranslationServer.set_locale(_original_locale)
	if _arch != null:
		_arch.dispose()
		_arch = null
	Gf._architecture = null


# --- 测试方法 ---

func test_runtime_locale_works_without_settings_utility() -> void:
	var display := GFDisplaySettingsUtility.new()
	display.init()

	display.set_locale("en")

	assert_eq(display.get_locale(), "en", "未注册 GFSettingsUtility 时也应保留运行时设置值。")
	assert_eq(TranslationServer.get_locale(), "en", "运行时设置应直接应用到 TranslationServer。")
	display.dispose()


func test_external_settings_change_auto_applies_locale() -> void:
	_arch = GFArchitecture.new()
	var settings := GFSettingsUtility.new()
	settings.auto_load_on_init = false
	settings.auto_save_on_change = false
	var display := GFDisplaySettingsUtility.new()
	display.register_defaults_on_ready = false
	display.apply_on_ready = false

	await _arch.register_utility_instance(settings)
	await _arch.register_utility_instance(display)
	await Gf.set_architecture(_arch)

	settings.set_value(GFDisplaySettingsUtility.LOCALE_KEY, "en", false)

	assert_eq(TranslationServer.get_locale(), "en", "外部设置变化应自动应用到引擎层。")


func test_audio_bus_volume_uses_registered_setting_value() -> void:
	_arch = GFArchitecture.new()
	var settings := GFSettingsUtility.new()
	settings.auto_load_on_init = false
	settings.auto_save_on_change = false
	var display := GFDisplaySettingsUtility.new()
	display.register_defaults_on_ready = false
	display.apply_on_ready = false

	await _arch.register_utility_instance(settings)
	await _arch.register_utility_instance(display)
	await Gf.set_architecture(_arch)

	var original_volume := db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	display.register_audio_bus_volume("Master", original_volume)
	display.set_audio_bus_volume("Master", 0.5)
	var applied_volume := db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))

	assert_almost_eq(applied_volume, 0.5, 0.05, "音频总线音量设置应应用到 AudioServer。")
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(maxf(original_volume, 0.0001)))
