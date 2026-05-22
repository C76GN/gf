## GFInputProfileBank: 命名输入重映射配置集合。
##
## 用于保存、切换和复制多个 GFInputRemapConfig。它只管理配置资源，
## 不规定玩家、存档槽位、UI 展示或项目业务语义。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFInputProfileBank
extends Resource


# --- 导出变量 ---

## 命名重映射配置。结构为 profile_id -> GFInputRemapConfig。
## [br]
## @api public
## [br]
## @schema profiles: Dictionary，以 StringName 或 String profile id 为键，值为 GFInputRemapConfig。
@export var profiles: Dictionary = {}

## 当前激活的配置 ID。为空表示尚未选择。
## [br]
## @api public
@export var active_profile_id: StringName = &""

## 项目自定义数据。框架不解释该字段。
## [br]
## @api public
## [br]
## @schema custom_data: Dictionary，项目持有的 UI、存档槽或平台元数据。
@export var custom_data: Dictionary = {}


# --- 公共方法 ---

## 设置一个命名配置。默认会深拷贝传入配置，避免外部继续修改污染 bank。
## [br]
## @api public
## [br]
## @param profile_id: 配置 ID。
## [br]
## @param config: 输入重映射配置；为 null 时移除该配置。
## [br]
## @param duplicate_config: 是否保存配置副本。
func set_profile(
	profile_id: StringName,
	config: GFInputRemapConfig,
	duplicate_config: bool = true
) -> void:
	if profile_id == &"":
		return
	if config == null:
		remove_profile(profile_id)
		return

	profiles[profile_id] = _duplicate_config(config) if duplicate_config else config
	if active_profile_id == &"":
		active_profile_id = profile_id


## 确保指定配置存在并返回它。
## [br]
## @api public
## [br]
## @param profile_id: 配置 ID。
## [br]
## @return 现有或新建的重映射配置。
func ensure_profile(profile_id: StringName) -> GFInputRemapConfig:
	if profile_id == &"":
		return null

	var config := _get_stored_profile(profile_id)
	if config == null:
		config = GFInputRemapConfig.new()
		profiles[profile_id] = config
		if active_profile_id == &"":
			active_profile_id = profile_id
	return config


## 获取指定命名配置。
## [br]
## @api public
## [br]
## @param profile_id: 配置 ID。
## [br]
## @param duplicate_result: 是否返回深拷贝。
## [br]
## @return 重映射配置；不存在时返回 null。
func get_profile(profile_id: StringName, duplicate_result: bool = false) -> GFInputRemapConfig:
	var config := _get_stored_profile(profile_id)
	if config == null:
		return null
	return _duplicate_config(config) if duplicate_result else config


## 检查指定配置是否存在。
## [br]
## @api public
## [br]
## @param profile_id: 配置 ID。
## [br]
## @return 是否存在。
func has_profile(profile_id: StringName) -> bool:
	return _get_stored_profile(profile_id) != null


## 移除指定配置。
## [br]
## @api public
## [br]
## @param profile_id: 配置 ID。
## [br]
## @return 成功移除时返回 true。
func remove_profile(profile_id: StringName) -> bool:
	var key := _find_profile_key(profile_id)
	if key == null:
		return false

	profiles.erase(key)
	if active_profile_id == profile_id:
		var ids := get_profile_ids()
		active_profile_id = StringName(ids[0]) if not ids.is_empty() else &""
	return true


## 获取所有有效配置 ID。
## [br]
## @api public
## [br]
## @return 排序后的配置 ID。
func get_profile_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for key: Variant in profiles.keys():
		var config := profiles[key] as GFInputRemapConfig
		if config != null:
			ids.append(String(key))
	ids.sort()
	return ids


## 清空所有配置。
## [br]
## @api public
func clear_profiles() -> void:
	profiles.clear()
	active_profile_id = &""


## 设置当前激活配置。
## [br]
## @api public
## [br]
## @param profile_id: 配置 ID。
## [br]
## @return 成功设置时返回 true。
func set_active_profile(profile_id: StringName) -> bool:
	if not has_profile(profile_id):
		return false
	active_profile_id = profile_id
	return true


## 获取当前激活配置。
## [br]
## @api public
## [br]
## @param duplicate_result: 是否返回深拷贝。
## [br]
## @return 当前配置；未设置或不存在时返回 null。
func get_active_profile(duplicate_result: bool = false) -> GFInputRemapConfig:
	if active_profile_id == &"":
		return null
	return get_profile(active_profile_id, duplicate_result)


## 创建 bank 的深拷贝。
## [br]
## @api public
## [br]
## @return 新的配置集合。
func duplicate_bank() -> GFInputProfileBank:
	var bank := GFInputProfileBank.new()
	for profile_id_string: String in get_profile_ids():
		var profile_id := StringName(profile_id_string)
		bank.set_profile(profile_id, get_profile(profile_id), true)
	bank.active_profile_id = active_profile_id
	bank.custom_data = GFVariantData.duplicate_variant(custom_data)
	return bank


# --- 私有/辅助方法 ---

func _get_stored_profile(profile_id: StringName) -> GFInputRemapConfig:
	var key := _find_profile_key(profile_id)
	if key == null:
		return null
	return profiles[key] as GFInputRemapConfig


func _find_profile_key(profile_id: StringName) -> Variant:
	if profiles.has(profile_id):
		return profile_id

	var string_key := String(profile_id)
	if profiles.has(string_key):
		return string_key
	return null


func _duplicate_config(config: GFInputRemapConfig) -> GFInputRemapConfig:
	if config == null:
		return null
	if config.has_method("duplicate_config"):
		return config.duplicate_config()

	var duplicated := GFInputRemapConfig.new()
	duplicated.remapped_events = GFVariantData.duplicate_variant(config.remapped_events)
	duplicated.custom_data = GFVariantData.duplicate_variant(config.custom_data)
	return duplicated
