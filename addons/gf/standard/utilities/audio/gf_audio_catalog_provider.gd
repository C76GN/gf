## GFAudioCatalogProvider: 通用音频目录提供器。
##
## 为编辑器选择器或构建工具提供事件、参数、状态和开关 ID 查询入口。
class_name GFAudioCatalogProvider
extends RefCounted


# --- 公共变量 ---

## 事件目录。
var events: Dictionary = {}

## 参数目录。
var parameters: Dictionary = {}

## 状态目录。
var states: Dictionary = {}

## 开关目录。
var switches: Dictionary = {}


# --- 公共方法 ---

## 设置目录条目。
## @param catalog_id: 目录标识，如 events、parameters、states、switches。
## @param entry_id: 条目标识。
## @param metadata: 条目元数据。
func set_entry(catalog_id: StringName, entry_id: StringName, metadata: Dictionary = {}) -> void:
	if entry_id == &"":
		return
	_get_catalog(catalog_id)[entry_id] = metadata.duplicate(true)


## 移除目录条目。
## @param catalog_id: 目录标识。
## @param entry_id: 条目标识。
func remove_entry(catalog_id: StringName, entry_id: StringName) -> void:
	_get_catalog(catalog_id).erase(entry_id)


## 获取目录 ID 列表。
## @param catalog_id: 目录标识。
## @return 排序后的条目 ID。
func get_ids(catalog_id: StringName) -> PackedStringArray:
	var result := PackedStringArray()
	for key: Variant in _get_catalog(catalog_id).keys():
		result.append(String(key))
	result.sort()
	return result


## 获取目录条目描述。
## @param catalog_id: 目录标识。
## @param entry_id: 条目标识。
## @return 条目元数据副本。
func describe_entry(catalog_id: StringName, entry_id: StringName) -> Dictionary:
	var data := _get_catalog(catalog_id).get(entry_id) as Dictionary
	return data.duplicate(true) if data != null else {}


## 获取完整目录快照。
## @return 目录快照字典。
func describe_catalog() -> Dictionary:
	return {
		"events": events.duplicate(true),
		"parameters": parameters.duplicate(true),
		"states": states.duplicate(true),
		"switches": switches.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _get_catalog(catalog_id: StringName) -> Dictionary:
	match catalog_id:
		&"events":
			return events
		&"parameters":
			return parameters
		&"states":
			return states
		&"switches":
			return switches
		_:
			return events
