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


# --- 公共方法 ---

## 配置关卡数据表名。
## @param table_name: 用于 GFConfigProvider.get_record() 的表名。
func configure(table_name: StringName = &"levels") -> void:
	level_table_name = table_name


## 读取关卡数据。
## @param level_id: 关卡 ID。
## @return 关卡数据副本，找不到时返回空字典。
func load_level_data(level_id: Variant) -> Dictionary:
	var config_provider := _get_config_provider()
	if config_provider == null:
		return {}

	var record: Variant = config_provider.get_record(level_table_name, level_id)
	if typeof(record) == TYPE_DICTIONARY:
		return (record as Dictionary).duplicate(true)

	if is_instance_valid(record) and record.has_method("to_dict"):
		var data: Variant = record.to_dict()
		if typeof(data) == TYPE_DICTIONARY:
			return (data as Dictionary).duplicate(true)

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


# --- 私有/辅助方法 ---

func _get_config_provider() -> GFConfigProvider:
	return _get_utility(GFConfigProvider) as GFConfigProvider


func _resolve_level_data(level_id: Variant) -> Dictionary:
	if not _current_level_override.is_empty():
		return _current_level_override.duplicate(true)

	return load_level_data(level_id)


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
