## GFSettingsUtility: 通用设置注册、读写与持久化工具。
##
## 设置项以 StringName 键访问，可选使用 GFSettingDefinition 声明默认值和类型。
## 该工具只管理抽象设置值，不直接绑定窗口、音频、输入或任何项目业务。
class_name GFSettingsUtility
extends GFUtility


# --- 信号 ---

## 设置值变化时发出。
## @param key: 设置键。
## @param old_value: 旧值。
## @param new_value: 新值。
signal setting_changed(key: StringName, old_value: Variant, new_value: Variant)

## 设置加载完成时发出。
## @param data: 已加载的持久化设置数据。
signal settings_loaded(data: Dictionary)

## 设置保存完成时发出。
## @param data: 已保存的持久化设置数据。
signal settings_saved(data: Dictionary)


# --- 常量 ---

const _SETTING_TYPE_KEY: String = "__gf_setting_type"
const _SETTING_VALUE_KEY: String = "value"


# --- 公共变量 ---

## 默认持久化文件名。
var storage_file_name: String = "settings.sav"

## init() 时是否自动读取持久化设置。
var auto_load_on_init: bool = true

## set_value() 修改持久化设置时是否自动保存。
var auto_save_on_change: bool = true


# --- 私有变量 ---

var _definitions: Dictionary = {}
var _values: Dictionary = {}


# --- Godot 生命周期方法 ---

func init() -> void:
	if auto_load_on_init:
		load_settings()
	else:
		_apply_defaults_to_missing()


func dispose() -> void:
	_definitions.clear()
	_values.clear()


# --- 公共方法 ---

## 注册一个设置定义。
## @param definition: 设置定义。
## @param apply_default: 缺少当前值时是否写入默认值。
func register_definition(definition: GFSettingDefinition, apply_default: bool = true) -> void:
	if definition == null:
		push_error("[GFSettingsUtility] register_definition 失败：definition 为空。")
		return

	var key := definition.get_setting_key()
	if key == &"":
		push_error("[GFSettingsUtility] register_definition 失败：设置键为空。")
		return

	_definitions[key] = definition.duplicate_definition()
	if _values.has(key):
		_values[key] = definition.coerce_value(_values[key])
	elif apply_default:
		_values[key] = definition.coerce_value(definition.default_value)


## 使用参数快速注册一个设置定义。
## @param key: 设置键。
## @param default_value: 默认值。
## @param value_type: 值类型。
## @param persistent: 是否持久化。
## @param metadata: 可选元数据。
## @return 新设置定义。
func register_setting(
	key: StringName,
	default_value: Variant = null,
	value_type: GFSettingDefinition.ValueType = GFSettingDefinition.ValueType.ANY,
	persistent: bool = true,
	metadata: Dictionary = {}
) -> GFSettingDefinition:
	var definition := GFSettingDefinition.new()
	definition.key = key
	definition.default_value = default_value
	definition.value_type = value_type
	definition.persistent = persistent
	definition.metadata = metadata.duplicate(true)
	register_definition(definition)
	return definition


## 批量注册设置定义。
## @param definitions: 设置定义数组。
func register_definitions(definitions: Array[GFSettingDefinition]) -> void:
	for definition: GFSettingDefinition in definitions:
		register_definition(definition)


## 获取指定设置定义。
## @param key: 设置键。
## @return 设置定义；不存在时返回 null。
func get_definition(key: StringName) -> GFSettingDefinition:
	var definition := _definitions.get(key) as GFSettingDefinition
	if definition == null:
		return null
	return definition.duplicate_definition()


## 获取所有设置定义。
## @return 设置定义数组。
func get_definitions() -> Array[GFSettingDefinition]:
	var result: Array[GFSettingDefinition] = []
	for definition: GFSettingDefinition in _definitions.values():
		result.append(definition.duplicate_definition())
	return result


## 设置一个值。
## @param key: 设置键。
## @param value: 设置值。
## @param save_after_change: 若为持久化设置，变化后是否保存。
func set_value(key: StringName, value: Variant, save_after_change: bool = true) -> void:
	_set_value_internal(key, value, true, save_after_change)


## 获取一个值。
## @param key: 设置键。
## @param fallback: 无当前值和默认值时返回的值。
## @return 设置值。
func get_value(key: StringName, fallback: Variant = null) -> Variant:
	if _values.has(key):
		return _values[key]

	var definition := _definitions.get(key) as GFSettingDefinition
	if definition != null:
		return definition.coerce_value(definition.default_value)

	return fallback


## 检查设置是否存在当前值或定义。
## @param key: 设置键。
## @return 存在时返回 true。
func has_setting(key: StringName) -> bool:
	return _values.has(key) or _definitions.has(key)


## 重置单个设置到默认值。未定义设置会被移除。
## @param key: 设置键。
## @param save_after_change: 若为持久化设置，变化后是否保存。
func reset_value(key: StringName, save_after_change: bool = true) -> void:
	var definition := _definitions.get(key) as GFSettingDefinition
	if definition != null:
		_set_value_internal(key, definition.default_value, true, save_after_change)
		return

	if not _values.has(key):
		return

	var old_value: Variant = _values[key]
	_values.erase(key)
	setting_changed.emit(key, old_value, null)
	if save_after_change and auto_save_on_change:
		save_settings()


## 重置所有已定义设置到默认值，并移除未定义的临时设置。
## @param save_after_change: 是否保存。
func reset_all(save_after_change: bool = true) -> void:
	var previous_values := _values.duplicate(true)
	_values.clear()
	_apply_defaults_to_missing()

	for key_variant: Variant in previous_values.keys():
		var key := key_variant as StringName
		var old_value: Variant = previous_values[key]
		var new_value: Variant = _values.get(key, null)
		if old_value != new_value:
			setting_changed.emit(key, old_value, new_value)

	for key: StringName in _values.keys():
		if not previous_values.has(key):
			setting_changed.emit(key, null, _values[key])

	if save_after_change:
		save_settings()


## 转换为可持久化字典。
## @param persistent_only: 是否仅包含 persistent 定义。
## @return 设置字典。
func to_dict(persistent_only: bool = true) -> Dictionary:
	var result: Dictionary = {}
	for key: StringName in _values.keys():
		var definition := _definitions.get(key) as GFSettingDefinition
		if persistent_only and definition != null and not definition.persistent:
			continue
		result[String(key)] = _serialize_value(_values[key])
	return result


## 从字典恢复设置。
## @param data: 设置数据。
## @param emit_changes: 变化时是否发出 setting_changed。
func from_dict(data: Dictionary, emit_changes: bool = true) -> void:
	for key_variant: Variant in data.keys():
		var key := StringName(key_variant)
		_set_value_internal(key, _deserialize_value(data[key_variant]), emit_changes, false)
	_apply_defaults_to_missing()


## 读取持久化设置。
## @param file_name: 可选文件名；为空时使用 storage_file_name。
## @return 已读取的数据。
func load_settings(file_name: String = "") -> Dictionary:
	var target_file_name := storage_file_name if file_name.is_empty() else file_name
	var data := _read_persisted_data(target_file_name)
	from_dict(data, false)
	settings_loaded.emit(data)
	return data


## 保存持久化设置。
## @param file_name: 可选文件名；为空时使用 storage_file_name。
## @return Godot 错误码。
func save_settings(file_name: String = "") -> Error:
	var target_file_name := storage_file_name if file_name.is_empty() else file_name
	var data := to_dict(true)
	var error := _write_persisted_data(target_file_name, data)
	if error == OK:
		settings_saved.emit(data)
	return error


# --- 私有/辅助方法 ---

func _set_value_internal(
	key: StringName,
	value: Variant,
	emit_change: bool,
	save_after_change: bool
) -> void:
	if key == &"":
		push_error("[GFSettingsUtility] set_value 失败：设置键为空。")
		return

	var definition := _definitions.get(key) as GFSettingDefinition
	var next_value: Variant = definition.coerce_value(value) if definition != null else value
	var old_value: Variant = _values.get(key, null)
	if _values.has(key) and old_value == next_value:
		return

	_values[key] = next_value
	if emit_change:
		setting_changed.emit(key, old_value, next_value)

	if save_after_change and auto_save_on_change and _should_persist(key):
		save_settings()


func _should_persist(key: StringName) -> bool:
	var definition := _definitions.get(key) as GFSettingDefinition
	return definition == null or definition.persistent


func _apply_defaults_to_missing() -> void:
	for key: StringName in _definitions.keys():
		if _values.has(key):
			continue
		var definition := _definitions[key] as GFSettingDefinition
		_values[key] = definition.coerce_value(definition.default_value)


func _read_persisted_data(file_name: String) -> Dictionary:
	var storage := _get_storage_utility()
	if storage != null:
		return storage.load_data(file_name)

	var path := _get_fallback_path(file_name)
	if not FileAccess.file_exists(path):
		return {}

	var content := FileAccess.get_file_as_string(path)
	if content.is_empty():
		return {}

	var parsed: Variant = JSON.parse_string(content)
	return parsed as Dictionary if parsed is Dictionary else {}


func _write_persisted_data(file_name: String, data: Dictionary) -> Error:
	var storage := _get_storage_utility()
	if storage != null:
		return storage.save_data(file_name, data)

	var path := _get_fallback_path(file_name)
	var base_dir := path.get_base_dir()
	if not base_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(base_dir)

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()

	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return OK


func _get_storage_utility() -> GFStorageUtility:
	var arch := _get_architecture_or_null()
	if arch == null:
		return null
	return arch.get_utility(GFStorageUtility) as GFStorageUtility


func _get_fallback_path(file_name: String) -> String:
	if file_name.is_absolute_path():
		return file_name
	return "user://" + file_name


func _serialize_value(value: Variant) -> Variant:
	if value is Vector2:
		var vector2 := value as Vector2
		return {
			_SETTING_TYPE_KEY: "Vector2",
			"x": vector2.x,
			"y": vector2.y,
		}
	if value is Vector2i:
		var vector2i := value as Vector2i
		return {
			_SETTING_TYPE_KEY: "Vector2i",
			"x": vector2i.x,
			"y": vector2i.y,
		}
	if value is Color:
		var color := value as Color
		return {
			_SETTING_TYPE_KEY: "Color",
			"r": color.r,
			"g": color.g,
			"b": color.b,
			"a": color.a,
		}
	if typeof(value) == TYPE_STRING_NAME:
		return {
			_SETTING_TYPE_KEY: "StringName",
			_SETTING_VALUE_KEY: String(value),
		}
	if value is Array:
		var result: Array = []
		for item: Variant in value:
			result.append(_serialize_value(item))
		return result
	if value is Dictionary:
		var result: Dictionary = {}
		for key_variant: Variant in value.keys():
			result[String(key_variant)] = _serialize_value(value[key_variant])
		return result
	return value


func _deserialize_value(value: Variant) -> Variant:
	if value is Array:
		var result: Array = []
		for item: Variant in value:
			result.append(_deserialize_value(item))
		return result

	if not value is Dictionary:
		return value

	var data := value as Dictionary
	if data.has(_SETTING_TYPE_KEY):
		match String(data[_SETTING_TYPE_KEY]):
			"Vector2":
				return Vector2(float(data.get("x", 0.0)), float(data.get("y", 0.0)))
			"Vector2i":
				return Vector2i(int(data.get("x", 0)), int(data.get("y", 0)))
			"Color":
				return Color(
					float(data.get("r", 1.0)),
					float(data.get("g", 1.0)),
					float(data.get("b", 1.0)),
					float(data.get("a", 1.0))
				)
			"StringName":
				return StringName(data.get(_SETTING_VALUE_KEY, ""))

	var result: Dictionary = {}
	for key_variant: Variant in data.keys():
		result[key_variant] = _deserialize_value(data[key_variant])
	return result
