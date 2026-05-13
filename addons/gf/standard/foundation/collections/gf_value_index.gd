## GFValueIndex: 通用值索引。
##
## 为任意 item_id 关联值和字段，并支持按字段快速查询。它只维护索引结构，
## 不规定字段含义、业务规则或生命周期。
class_name GFValueIndex
extends RefCounted


# --- 信号 ---

## 条目写入索引后发出。
## @param item_id: 条目标识。
signal item_indexed(item_id: StringName)

## 条目从索引移除后发出。
## @param item_id: 条目标识。
signal item_removed(item_id: StringName)

## 索引清空后发出。
signal cleared


# --- 公共变量 ---

## 读取或写入值时是否复制 Dictionary / Array。
var duplicate_values: bool = true


# --- 私有变量 ---

var _items: Dictionary = {}
var _indexes: Dictionary = {}


# --- 公共方法 ---

## 写入或替换一个条目。
## @param item_id: 条目标识。
## @param value: 条目值。
## @param fields: 可索引字段，字段值可为单值、Array 或 PackedStringArray。
## @return 写入成功返回 true。
func set_item(item_id: StringName, value: Variant, fields: Dictionary = {}) -> bool:
	if item_id == &"":
		return false

	remove_item(item_id)
	var normalized_fields := _normalize_fields(fields)
	_items[item_id] = {
		"value": _copy_value(value),
		"fields": normalized_fields,
	}
	_index_fields(item_id, normalized_fields)
	item_indexed.emit(item_id)
	return true


## 移除条目。
## @param item_id: 条目标识。
## @return 移除成功返回 true。
func remove_item(item_id: StringName) -> bool:
	if not _items.has(item_id):
		return false

	var entry := _items[item_id] as Dictionary
	var fields := entry.get("fields", {}) as Dictionary
	if fields != null:
		_remove_fields_from_indexes(item_id, fields)
	_items.erase(item_id)
	item_removed.emit(item_id)
	return true


## 检查条目是否存在。
## @param item_id: 条目标识。
## @return 存在返回 true。
func has_item(item_id: StringName) -> bool:
	return _items.has(item_id)


## 获取条目值。
## @param item_id: 条目标识。
## @param default_value: 不存在时返回的默认值。
## @return 条目值或默认值。
func get_item(item_id: StringName, default_value: Variant = null) -> Variant:
	if not _items.has(item_id):
		return default_value
	var entry := _items[item_id] as Dictionary
	return _copy_value(entry.get("value", default_value))


## 获取条目字段。
## @param item_id: 条目标识。
## @return 字段副本。
func get_fields(item_id: StringName) -> Dictionary:
	if not _items.has(item_id):
		return {}
	var entry := _items[item_id] as Dictionary
	return (entry.get("fields", {}) as Dictionary).duplicate(true)


## 按单个字段值查询条目标识。
## @param field_id: 字段标识。
## @param field_value: 字段值。
## @return 条目标识列表。
func query(field_id: StringName, field_value: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	var field_index := _indexes.get(field_id, {}) as Dictionary
	if field_index == null:
		return result

	var value_key := _make_value_key(field_value)
	var item_lookup := field_index.get(value_key, {}) as Dictionary
	if item_lookup == null:
		return result

	for item_id_variant: Variant in item_lookup.keys():
		result.append(String(item_id_variant))
	result.sort()
	return result


## 按多个字段查询条目标识。
## @param criteria: 字段到值的查询条件。
## @param match_all: true 表示交集查询，false 表示并集查询。
## @return 条目标识列表。
func query_many(criteria: Dictionary, match_all: bool = true) -> PackedStringArray:
	var result_lookup: Dictionary = {}
	var initialized := false
	for field_id_variant: Variant in criteria.keys():
		var matches := query(StringName(field_id_variant), criteria[field_id_variant])
		if not initialized:
			for item_id_text: String in matches:
				result_lookup[StringName(item_id_text)] = true
			initialized = true
			continue

		if match_all:
			result_lookup = _intersect_lookup(result_lookup, matches)
		else:
			for item_id_text: String in matches:
				result_lookup[StringName(item_id_text)] = true

	return _lookup_to_sorted_ids(result_lookup)


## 清空索引。
func clear() -> void:
	_items.clear()
	_indexes.clear()
	cleared.emit()


## 获取条目数量。
## @return 条目数量。
func get_item_count() -> int:
	return _items.size()


## 获取字段索引数量。
## @return 字段索引数量。
func get_index_count() -> int:
	return _indexes.size()


## 获取调试快照。
## @return 调试信息字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"item_count": _items.size(),
		"index_count": _indexes.size(),
		"duplicate_values": duplicate_values,
	}


# --- 私有/辅助方法 ---

func _copy_value(value: Variant) -> Variant:
	if duplicate_values:
		return GFVariantData.duplicate_variant(value)
	return value


func _normalize_fields(fields: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for field_id_variant: Variant in fields.keys():
		var field_id := StringName(field_id_variant)
		if field_id == &"":
			continue
		var values := _normalize_field_values(fields[field_id_variant])
		if not values.is_empty():
			result[field_id] = values
	return result


func _normalize_field_values(value: Variant) -> Array:
	var result: Array = []
	if value == null:
		return result
	if value is PackedStringArray:
		for text: String in value:
			result.append(text)
	elif value is Array:
		for item: Variant in value:
			if item != null:
				result.append(item)
	else:
		result.append(value)
	return result


func _index_fields(item_id: StringName, fields: Dictionary) -> void:
	for field_id: StringName in fields.keys():
		var values := fields[field_id] as Array
		if values == null:
			continue
		for value: Variant in values:
			_add_index_value(field_id, value, item_id)


func _remove_fields_from_indexes(item_id: StringName, fields: Dictionary) -> void:
	for field_id: StringName in fields.keys():
		var values := fields[field_id] as Array
		if values == null:
			continue
		for value: Variant in values:
			_remove_index_value(field_id, value, item_id)


func _add_index_value(field_id: StringName, field_value: Variant, item_id: StringName) -> void:
	if not _indexes.has(field_id):
		_indexes[field_id] = {}
	var field_index := _indexes[field_id] as Dictionary
	var value_key := _make_value_key(field_value)
	if not field_index.has(value_key):
		field_index[value_key] = {}
	(field_index[value_key] as Dictionary)[item_id] = true


func _remove_index_value(field_id: StringName, field_value: Variant, item_id: StringName) -> void:
	var field_index := _indexes.get(field_id, {}) as Dictionary
	if field_index == null:
		return

	var value_key := _make_value_key(field_value)
	var item_lookup := field_index.get(value_key, {}) as Dictionary
	if item_lookup == null:
		return

	item_lookup.erase(item_id)
	if item_lookup.is_empty():
		field_index.erase(value_key)
	if field_index.is_empty():
		_indexes.erase(field_id)


func _make_value_key(value: Variant) -> String:
	return "%d:%s" % [typeof(value), var_to_str(value)]


func _intersect_lookup(left_lookup: Dictionary, right_ids: PackedStringArray) -> Dictionary:
	var right_lookup: Dictionary = {}
	for item_id_text: String in right_ids:
		right_lookup[StringName(item_id_text)] = true

	var result: Dictionary = {}
	for item_id: StringName in left_lookup.keys():
		if right_lookup.has(item_id):
			result[item_id] = true
	return result


func _lookup_to_sorted_ids(lookup: Dictionary) -> PackedStringArray:
	var result := PackedStringArray()
	for item_id_variant: Variant in lookup.keys():
		result.append(String(item_id_variant))
	result.sort()
	return result
