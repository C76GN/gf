## GFLevelProgressModel: 通用关卡解锁与完成进度模型。
##
## 只记录关卡是否解锁、是否完成以及项目层自定义结果字典。
class_name GFLevelProgressModel
extends GFModel


# --- 信号 ---

## 关卡解锁时发出。
## @param level_id: 关卡 ID。
signal level_unlocked(level_id: StringName)

## 关卡锁定时发出。
## @param level_id: 关卡 ID。
signal level_locked(level_id: StringName)

## 关卡完成时发出。
## @param level_id: 关卡 ID。
## @param result: 完成结果。
signal level_completed(level_id: StringName, result: Dictionary)

## 关卡结果更新时发出。
## @param level_id: 关卡 ID。
## @param result: 结果字典。
signal level_result_updated(level_id: StringName, result: Dictionary)


# --- 私有变量 ---

var _unlocked_levels: Dictionary = {}
var _completed_levels: Dictionary = {}
var _level_results: Dictionary = {}


# --- 公共方法 ---

## 解锁关卡。
## @param level_id: 关卡 ID。
func unlock_level(level_id: StringName) -> void:
	if level_id == &"" or _unlocked_levels.has(level_id):
		return

	_unlocked_levels[level_id] = true
	level_unlocked.emit(level_id)


## 锁定关卡。
## @param level_id: 关卡 ID。
func lock_level(level_id: StringName) -> void:
	if not _unlocked_levels.has(level_id):
		return

	_unlocked_levels.erase(level_id)
	level_locked.emit(level_id)


## 检查关卡是否解锁。
## @param level_id: 关卡 ID。
## @return 已解锁时返回 true。
func is_level_unlocked(level_id: StringName) -> bool:
	return bool(_unlocked_levels.get(level_id, false))


## 标记关卡完成。
## @param level_id: 关卡 ID。
## @param result: 项目层结果数据。
## @param merge_result: 是否合并已有结果。
func complete_level(level_id: StringName, result: Dictionary = {}, merge_result: bool = true) -> void:
	if level_id == &"":
		return

	unlock_level(level_id)
	_completed_levels[level_id] = true
	set_level_result(level_id, result, merge_result)
	level_completed.emit(level_id, get_level_result(level_id))


## 检查关卡是否完成。
## @param level_id: 关卡 ID。
## @return 已完成时返回 true。
func is_level_completed(level_id: StringName) -> bool:
	return bool(_completed_levels.get(level_id, false))


## 设置关卡结果。
## @param level_id: 关卡 ID。
## @param result: 结果字典。
## @param merge_result: 是否合并已有结果。
func set_level_result(level_id: StringName, result: Dictionary, merge_result: bool = true) -> void:
	if level_id == &"":
		return

	var next_result := result.duplicate(true)
	if merge_result and _level_results.has(level_id):
		next_result = (_level_results[level_id] as Dictionary).duplicate(true)
		for key: Variant in result.keys():
			next_result[key] = result[key]

	_level_results[level_id] = next_result
	level_result_updated.emit(level_id, next_result.duplicate(true))


## 获取关卡结果。
## @param level_id: 关卡 ID。
## @return 结果字典副本。
func get_level_result(level_id: StringName) -> Dictionary:
	var result_variant: Variant = _level_results.get(level_id, {})
	if result_variant is Dictionary:
		return (result_variant as Dictionary).duplicate(true)
	return {}


## 清空所有进度。
func clear_progress() -> void:
	_unlocked_levels.clear()
	_completed_levels.clear()
	_level_results.clear()


## 序列化进度。
## @return 字典数据。
func to_dict() -> Dictionary:
	return {
		"unlocked_levels": _stringify_key_dictionary(_unlocked_levels),
		"completed_levels": _stringify_key_dictionary(_completed_levels),
		"level_results": _stringify_key_dictionary(_level_results),
	}


## 反序列化进度。
## @param data: 字典数据。
func from_dict(data: Dictionary) -> void:
	_unlocked_levels = _string_name_key_dictionary(data.get("unlocked_levels", {}))
	_completed_levels = _string_name_key_dictionary(data.get("completed_levels", {}))
	_level_results = _string_name_key_dictionary(data.get("level_results", {}))


# --- 私有/辅助方法 ---

func _stringify_key_dictionary(data: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in data.keys():
		result[String(key)] = data[key]
	return result


func _string_name_key_dictionary(data_variant: Variant) -> Dictionary:
	var result: Dictionary = {}
	if not data_variant is Dictionary:
		return result

	var data := data_variant as Dictionary
	for key: Variant in data.keys():
		var level_id := StringName(key)
		var value: Variant = data[key]
		result[level_id] = value.duplicate(true) if value is Dictionary or value is Array else value
	return result
