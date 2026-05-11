## GFDisplaySettingsUtility: 通用显示、语言与音频总线设置应用器。
##
## 该工具把抽象设置值应用到 Godot 引擎层。设置值本身由 GFSettingsUtility 管理；
## 未注册 GFSettingsUtility 时，也可以直接作为运行时应用器使用。
class_name GFDisplaySettingsUtility
extends GFUtility


# --- 信号 ---

## 某个引擎设置应用完成时发出。
## @param key: 设置键。
## @param value: 已应用的值。
signal display_setting_applied(key: StringName, value: Variant)


# --- 常量 ---

const WINDOW_MODE_KEY: StringName = &"display/window_mode"
const WINDOW_SIZE_KEY: StringName = &"display/window_size"
const VSYNC_MODE_KEY: StringName = &"display/vsync_mode"
const LOCALE_KEY: StringName = &"display/locale"


# --- 公共变量 ---

## ready() 时是否注册默认设置定义。
var register_defaults_on_ready: bool = true

## ready() 时是否立刻应用当前设置。
var apply_on_ready: bool = true

## GFSettingsUtility 中相关设置变化时是否自动应用。
var auto_apply_setting_changes: bool = true

## 设置变化时是否写入 GFSettingsUtility。
var persist_changes: bool = true

## 音频设置键前缀。
var audio_setting_prefix: StringName = &"audio"


# --- 私有变量 ---

var _runtime_values: Dictionary = {}
var _connected_settings: GFSettingsUtility = null
var _internal_setting_write_depth: int = 0


# --- Godot 生命周期方法 ---

func init() -> void:
	ignore_pause = true
	ignore_time_scale = true


func ready() -> void:
	if register_defaults_on_ready:
		register_default_settings()
	_connect_settings_changed()
	if apply_on_ready:
		apply_all()


func dispose() -> void:
	_disconnect_settings_changed()
	_runtime_values.clear()


# --- 公共方法 ---

## 注册显示相关默认设置定义。
func register_default_settings() -> void:
	var settings := _get_settings_utility()
	if settings == null:
		return

	settings.register_setting(
		WINDOW_MODE_KEY,
		int(DisplayServer.window_get_mode()),
		GFSettingDefinition.ValueType.INT
	)
	settings.register_setting(
		WINDOW_SIZE_KEY,
		DisplayServer.window_get_size(),
		GFSettingDefinition.ValueType.VECTOR2I
	)
	settings.register_setting(
		VSYNC_MODE_KEY,
		int(DisplayServer.window_get_vsync_mode()),
		GFSettingDefinition.ValueType.INT
	)
	settings.register_setting(
		LOCALE_KEY,
		OS.get_locale_language(),
		GFSettingDefinition.ValueType.STRING
	)


## 应用所有当前已知显示设置。
func apply_all() -> void:
	apply_window_mode()
	apply_window_size()
	apply_vsync_mode()
	apply_locale()
	apply_registered_audio_bus_volumes()


## 设置窗口模式并应用。
## @param mode: 目标窗口模式。
func set_window_mode(mode: DisplayServer.WindowMode) -> void:
	_set_setting_value(WINDOW_MODE_KEY, int(mode))
	apply_window_mode()


## 获取窗口模式设置。
## @return 窗口模式。
func get_window_mode() -> DisplayServer.WindowMode:
	return int(_get_setting_value(WINDOW_MODE_KEY, int(DisplayServer.window_get_mode()))) as DisplayServer.WindowMode


## 设置是否全屏。
## @param enabled: true 时切换到全屏，false 时切回窗口模式。
func set_fullscreen(enabled: bool) -> void:
	set_window_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)


## 切换全屏状态。
func toggle_fullscreen() -> void:
	var current_mode := get_window_mode()
	set_fullscreen(current_mode != DisplayServer.WINDOW_MODE_FULLSCREEN)


## 应用窗口模式设置。
func apply_window_mode() -> void:
	var mode := get_window_mode()
	DisplayServer.window_set_mode(mode)
	display_setting_applied.emit(WINDOW_MODE_KEY, int(mode))


## 设置窗口尺寸并应用。
## @param size: 窗口尺寸。
func set_window_size(size: Vector2i) -> void:
	if size.x <= 0 or size.y <= 0:
		push_error("[GFDisplaySettingsUtility] set_window_size 失败：窗口尺寸必须大于 0。")
		return

	_set_setting_value(WINDOW_SIZE_KEY, size)
	apply_window_size()


## 获取窗口尺寸设置。
## @return 窗口尺寸。
func get_window_size() -> Vector2i:
	var value: Variant = _get_setting_value(WINDOW_SIZE_KEY, DisplayServer.window_get_size())
	if value is Vector2i:
		return value as Vector2i
	if value is Vector2:
		var vector2 := value as Vector2
		return Vector2i(roundi(vector2.x), roundi(vector2.y))
	return DisplayServer.window_get_size()


## 应用窗口尺寸设置。
func apply_window_size() -> void:
	var size := get_window_size()
	if size.x <= 0 or size.y <= 0:
		return

	DisplayServer.window_set_size(size)
	display_setting_applied.emit(WINDOW_SIZE_KEY, size)


## 设置垂直同步模式并应用。
## @param mode: VSync 模式。
func set_vsync_mode(mode: DisplayServer.VSyncMode) -> void:
	_set_setting_value(VSYNC_MODE_KEY, int(mode))
	apply_vsync_mode()


## 获取垂直同步模式设置。
## @return VSync 模式。
func get_vsync_mode() -> DisplayServer.VSyncMode:
	return int(_get_setting_value(VSYNC_MODE_KEY, int(DisplayServer.window_get_vsync_mode()))) as DisplayServer.VSyncMode


## 应用垂直同步设置。
func apply_vsync_mode() -> void:
	var mode := get_vsync_mode()
	DisplayServer.window_set_vsync_mode(mode)
	display_setting_applied.emit(VSYNC_MODE_KEY, int(mode))


## 设置语言并应用。
## @param locale: 语言代码，例如 "en" 或 "zh_CN"。
func set_locale(locale: String) -> void:
	_set_setting_value(LOCALE_KEY, locale)
	apply_locale()


## 获取当前语言设置。
## @return 语言代码。
func get_locale() -> String:
	return String(_get_setting_value(LOCALE_KEY, OS.get_locale_language()))


## 应用语言设置。
func apply_locale() -> void:
	var locale := get_locale()
	if locale.is_empty():
		return

	TranslationServer.set_locale(locale)
	display_setting_applied.emit(LOCALE_KEY, locale)


## 注册一个音频总线音量设置。
## @param bus_name: 音频总线名。
## @param default_linear: 默认线性音量，范围 0 到 1。
func register_audio_bus_volume(bus_name: String, default_linear: float = 1.0) -> void:
	var settings := _get_settings_utility()
	if settings == null:
		return

	settings.register_setting(
		_get_audio_bus_volume_key(bus_name),
		clampf(default_linear, 0.0, 1.0),
		GFSettingDefinition.ValueType.FLOAT
	)


## 设置音频总线音量并应用。
## @param bus_name: 音频总线名。
## @param volume_linear: 线性音量，范围 0 到 1。
func set_audio_bus_volume(bus_name: String, volume_linear: float) -> void:
	var clamped_volume := clampf(volume_linear, 0.0, 1.0)
	_set_setting_value(_get_audio_bus_volume_key(bus_name), clamped_volume)
	apply_audio_bus_volume(bus_name)


## 获取音频总线音量。
## @param bus_name: 音频总线名。
## @param fallback: 设置缺失时的回退值。
## @return 线性音量。
func get_audio_bus_volume(bus_name: String, fallback: float = 1.0) -> float:
	return clampf(float(_get_setting_value(_get_audio_bus_volume_key(bus_name), fallback)), 0.0, 1.0)


## 应用指定音频总线音量。
## @param bus_name: 音频总线名。
func apply_audio_bus_volume(bus_name: String) -> void:
	var volume := get_audio_bus_volume(bus_name)
	var audio := _get_audio_utility()
	if audio != null:
		audio.set_bus_volume(bus_name, volume)
	else:
		var bus_index := AudioServer.get_bus_index(bus_name)
		if bus_index >= 0:
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(volume, 0.0001)))

	display_setting_applied.emit(_get_audio_bus_volume_key(bus_name), volume)


## 应用所有已注册音频总线音量设置。
func apply_registered_audio_bus_volumes() -> void:
	var settings := _get_settings_utility()
	if settings == null:
		return

	var prefix := "%s/" % String(audio_setting_prefix)
	for definition: GFSettingDefinition in settings.get_definitions():
		var key := String(definition.get_setting_key())
		if key.begins_with(prefix) and key.ends_with("/volume"):
			var bus_name := key.trim_prefix(prefix).trim_suffix("/volume")
			apply_audio_bus_volume(bus_name)


# --- 私有/辅助方法 ---

func _set_setting_value(key: StringName, value: Variant) -> void:
	var settings := _get_settings_utility()
	if settings != null:
		_internal_setting_write_depth += 1
		settings.set_value(key, value, persist_changes)
		_internal_setting_write_depth -= 1
	else:
		_runtime_values[key] = value


func _get_setting_value(key: StringName, fallback: Variant = null) -> Variant:
	var settings := _get_settings_utility()
	if settings == null:
		return _runtime_values.get(key, fallback)
	return settings.get_value(key, fallback)


func _get_settings_utility() -> GFSettingsUtility:
	var arch := _get_architecture_or_null()
	if arch == null:
		return null
	return arch.get_utility(GFSettingsUtility) as GFSettingsUtility


func _get_audio_utility() -> GFAudioUtility:
	var arch := _get_architecture_or_null()
	if arch == null:
		return null
	return arch.get_utility(GFAudioUtility) as GFAudioUtility


func _get_audio_bus_volume_key(bus_name: String) -> StringName:
	return StringName("%s/%s/volume" % [String(audio_setting_prefix), bus_name])


func _connect_settings_changed() -> void:
	var settings := _get_settings_utility()
	if settings == null or settings == _connected_settings:
		return

	_disconnect_settings_changed()
	_connected_settings = settings
	if not _connected_settings.setting_changed.is_connected(_on_setting_changed):
		_connected_settings.setting_changed.connect(_on_setting_changed)


func _disconnect_settings_changed() -> void:
	if _connected_settings == null:
		return
	if _connected_settings.setting_changed.is_connected(_on_setting_changed):
		_connected_settings.setting_changed.disconnect(_on_setting_changed)
	_connected_settings = null


func _on_setting_changed(key: StringName, _old_value: Variant, _new_value: Variant) -> void:
	if not auto_apply_setting_changes or _internal_setting_write_depth > 0:
		return

	match key:
		WINDOW_MODE_KEY:
			apply_window_mode()
		WINDOW_SIZE_KEY:
			apply_window_size()
		VSYNC_MODE_KEY:
			apply_vsync_mode()
		LOCALE_KEY:
			apply_locale()
		_:
			var key_text := String(key)
			var prefix := "%s/" % String(audio_setting_prefix)
			if key_text.begins_with(prefix) and key_text.ends_with("/volume"):
				var bus_name := key_text.trim_prefix(prefix).trim_suffix("/volume")
				apply_audio_bus_volume(bus_name)
