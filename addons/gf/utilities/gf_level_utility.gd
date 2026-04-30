## GFLevelUtility: 关卡流程管理工具。
##
## 负责统一关卡数据读取、开始、重开、胜利和失败信号派发。
## 默认通过 GFConfigProvider 读取静态关卡表，并可在重开关卡时清理
## GFCommandHistoryUtility 与 GFActionQueueSystem 的运行时残留。
class_name GFLevelUtility
extends GFUtility


# --- 信号 ---

## 当关卡开始时发出。
## @param level_id: 关卡 ID。
## @param level_data: 当前关卡数据。
signal level_started(level_id: Variant, level_data: Dictionary)

## 当关卡重开时发出。
## @param level_id: 关卡 ID。
## @param level_data: 当前关卡数据。
signal level_restarted(level_id: Variant, level_data: Dictionary)

## 当关卡胜利时发出。
## @param level_id: 关卡 ID。
signal level_won(level_id: Variant)

## 当关卡失败时发出。
## @param level_id: 关卡 ID。
signal level_lost(level_id: Variant)


# --- 公共变量 ---

## 默认关卡配置表名。
var level_table_name: StringName = &"levels"

## 当前关卡 ID。
var current_level_id: Variant = null

## 当前关卡数据副本。
var current_level_data: Dictionary = {}

## 可选关卡目录资源。
var catalog: GFLevelCatalog = null


# --- 私有变量 ---

var _current_level_override: Dictionary = {}


# --- Godot 生命周期方法 ---

func init() -> void:
	current_level_id = null
	current_level_data.clear()
	_current_level_override.clear()


func dispose() -> void:
	current_level_id = null
	current_level_data.clear()
	_current_level_override.clear()
	catalog = null


# --- 公共方法 ---

## 配置关卡数据表名。
## @param table_name: 用于 GFConfigProvider.get_record() 的表名。
func configure(table_name: StringName = &"levels") -> void:
	level_table_name = table_name


## 设置关卡目录资源。
## @param level_catalog: 关卡目录。
func set_catalog(level_catalog: GFLevelCatalog) -> void:
	catalog = level_catalog


## 获取关卡目录资源。
## @return 关卡目录；不存在时返回 null。
func get_catalog() -> GFLevelCatalog:
	return catalog


## 获取目录中的关卡条目。
## @param level_id: 关卡 ID。
## @return 关卡条目；不存在时返回 null。
func get_level_entry(level_id: StringName) -> GFLevelEntry:
	if catalog == null:
		return null
	return catalog.get_entry(level_id)


## 获取目录中的关卡列表。
## @param pack_id: 可选关卡包 ID；为空时返回全部。
## @return 关卡条目数组。
func get_catalog_levels(pack_id: StringName = &"") -> Array[GFLevelEntry]:
	if catalog == null:
		return []
	return catalog.get_levels(pack_id)


## 读取关卡数据。
## @param level_id: 关卡 ID。
## @return 关卡数据副本，找不到时返回空字典。
func load_level_data(level_id: Variant) -> Dictionary:
	var config_provider := _get_config_provider()
	if config_provider != null:
		var record: Variant = config_provider.get_record(level_table_name, level_id)
		if typeof(record) == TYPE_DICTIONARY:
			return (record as Dictionary).duplicate(true)

		if is_instance_valid(record) and record.has_method("to_dict"):
			var data: Variant = record.to_dict()
			if typeof(data) == TYPE_DICTIONARY:
				return (data as Dictionary).duplicate(true)

	var entry := get_level_entry(_to_level_id(level_id))
	if entry != null:
		var entry_data := entry.metadata.duplicate(true)
		entry_data["level_id"] = entry.get_level_id()
		entry_data["pack_id"] = entry.pack_id
		entry_data["scene_path"] = entry.scene_path
		entry_data["sort_order"] = entry.sort_order
		entry_data["unlocks_on_complete"] = entry.unlocks_on_complete.duplicate()
		return entry_data

	return {}


## 开始指定关卡。
## @param level_id: 关卡 ID。
## @param level_data_override: 可选的外部数据覆盖；为空时从配置表读取。
## @return 当前关卡数据副本。
func start_level(level_id: Variant, level_data_override: Dictionary = {}) -> Dictionary:
	current_level_id = level_id
	_current_level_override = level_data_override.duplicate(true)
	current_level_data = _resolve_level_data(level_id)
	level_started.emit(current_level_id, current_level_data)
	return current_level_data.duplicate(true)


## 重开当前关卡，并清理常见运行时队列。
## @param clear_runtime: 是否清理命令历史与表现队列。
## @return 当前关卡数据副本。
func restart_level(clear_runtime: bool = true) -> Dictionary:
	if current_level_id == null:
		return {}

	if clear_runtime:
		clear_level_runtime()

	current_level_data = _resolve_level_data(current_level_id)
	level_restarted.emit(current_level_id, current_level_data)
	return current_level_data.duplicate(true)


## 标记当前关卡胜利。
func win_current_level() -> void:
	if current_level_id == null:
		return

	level_won.emit(current_level_id)


## 完成当前关卡并可选更新通用进度模型与后续解锁。
## @param result: 项目层结果数据。
## @param unlock_next: 是否解锁目录中的后续关卡。
## @param emit_win_signal: 是否发出 level_won。
func complete_current_level(
	result: Dictionary = {},
	unlock_next: bool = true,
	emit_win_signal: bool = true
) -> void:
	if current_level_id == null:
		return

	var level_id := _to_level_id(current_level_id)
	var progress := _get_progress_model()
	if progress != null:
		progress.complete_level(level_id, result)
		_unlock_declared_next_levels(level_id, progress)
		if unlock_next and catalog != null:
			var next_level_id := catalog.get_next_level_id(level_id)
			if next_level_id != &"":
				progress.unlock_level(next_level_id)

	if emit_win_signal:
		level_won.emit(current_level_id)


## 标记当前关卡失败。
func lose_current_level() -> void:
	if current_level_id == null:
		return

	level_lost.emit(current_level_id)


## 清理常见关卡运行时残留。
func clear_level_runtime() -> void:
	var history := _get_utility(GFCommandHistoryUtility) as GFCommandHistoryUtility
	if history != null:
		history.clear()

	var action_queue := _get_system(GFActionQueueSystem) as GFActionQueueSystem
	if action_queue != null:
		action_queue.clear_queue(true)
		action_queue.clear_all_named_queues(true)


## 清除当前关卡记录。
func clear_current_level() -> void:
	current_level_id = null
	current_level_data.clear()
	_current_level_override.clear()


## 启动目录中的下一个关卡。
## @return 下一个关卡数据；没有后续关卡时返回空字典。
func start_next_level() -> Dictionary:
	if current_level_id == null or catalog == null:
		return {}

	var next_level_id := catalog.get_next_level_id(_to_level_id(current_level_id))
	if next_level_id == &"":
		return {}

	return start_level(next_level_id)


## 解锁关卡进度。
## @param level_id: 关卡 ID。
func unlock_level(level_id: StringName) -> void:
	var progress := _get_progress_model()
	if progress != null:
		progress.unlock_level(level_id)


## 检查关卡是否已解锁。
## @param level_id: 关卡 ID。
## @return 已解锁时返回 true；未注册进度模型时返回 true。
func is_level_unlocked(level_id: StringName) -> bool:
	var progress := _get_progress_model()
	if progress == null:
		return true
	return progress.is_level_unlocked(level_id)


# --- 私有/辅助方法 ---

func _get_config_provider() -> GFConfigProvider:
	return _get_utility(GFConfigProvider) as GFConfigProvider


func _get_progress_model() -> GFLevelProgressModel:
	var arch := _get_architecture_or_null()
	if arch == null:
		return null
	return arch.get_model(GFLevelProgressModel) as GFLevelProgressModel


func _resolve_level_data(level_id: Variant) -> Dictionary:
	if not _current_level_override.is_empty():
		return _current_level_override.duplicate(true)

	return load_level_data(level_id)


func _unlock_declared_next_levels(level_id: StringName, progress: GFLevelProgressModel) -> void:
	if catalog == null or progress == null:
		return

	var entry := catalog.get_entry(level_id)
	if entry == null:
		return

	for next_level_id: StringName in entry.unlocks_on_complete:
		progress.unlock_level(next_level_id)


func _to_level_id(value: Variant) -> StringName:
	if typeof(value) == TYPE_STRING_NAME:
		return value as StringName
	return StringName(String(value))


func _get_utility(utility_type: Script) -> Object:
	var arch := _get_architecture_or_null()
	if arch == null:
		return null

	return arch.get_utility(utility_type)


func _get_system(system_type: Script) -> Object:
	var arch := _get_architecture_or_null()
	if arch == null:
		return null

	return arch.get_system(system_type)
