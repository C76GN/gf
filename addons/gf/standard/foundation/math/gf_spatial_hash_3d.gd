## GFSpatialHash3D: 纯逻辑 3D 空间哈希。
##
## 适用于大量动态 3D 实体的粗粒度范围查询。它只维护 AABB 索引，
## 不负责物理碰撞、可见性或玩法规则。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFSpatialHash3D
extends RefCounted


# --- 公共变量 ---

## 单个哈希格子的世界尺寸。
## [br]
## @api public
var cell_size: float:
	get:
		return _cell_size
	set(value):
		_cell_size = maxf(value, 0.0001)
		_rebuild()


# --- 私有变量 ---

var _cell_size: float = 4.0
var _entity_records: Dictionary = {}
var _bucket_entities: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init(p_cell_size: float = 4.0) -> void:
	_cell_size = maxf(p_cell_size, 0.0001)


# --- 公共方法 ---

## 配置格子尺寸并清空索引。
## [br]
## @api public
## [br]
## @param p_cell_size: 单格世界尺寸。
func configure(p_cell_size: float) -> void:
	_cell_size = maxf(p_cell_size, 0.0001)
	clear()


## 插入实体。
## [br]
## @api public
## [br]
## @param entity: 实体标识或 Object。
## [br]
## @schema entity: Variant entity identity stored by value or weak Object reference.
## [br]
## @param bounds: 实体 AABB。
## [br]
## @return 成功时返回 true。
func insert(entity: Variant, bounds: AABB) -> bool:
	var entity_key: String = _make_entity_key(entity)
	if entity_key.is_empty():
		return false

	remove(entity)
	var normalized_bounds: AABB = _normalize_aabb(bounds)
	var cells: Array[Vector3i] = _get_cells_for_aabb(normalized_bounds)
	_entity_records[entity_key] = _make_entity_record(entity, normalized_bounds, cells)
	for cell_key: Vector3i in cells:
		var bucket: Array = _get_or_create_bucket(cell_key)
		if not bucket.has(entity_key):
			bucket.append(entity_key)
	return true


## 移除实体。
## [br]
## @api public
## [br]
## @param entity: 实体标识或 Object。
## [br]
## @schema entity: Variant entity identity stored by value or weak Object reference.
func remove(entity: Variant) -> void:
	var entity_key: String = _make_entity_key(entity)
	if entity_key.is_empty() or not _entity_records.has(entity_key):
		return
	_remove_by_key(entity_key)


## 更新实体 AABB。
## [br]
## @api public
## [br]
## @param entity: 实体标识或 Object。
## [br]
## @schema entity: Variant entity identity stored by value or weak Object reference.
## [br]
## @param bounds: 新 AABB。
## [br]
## @return 成功时返回 true。
func update(entity: Variant, bounds: AABB) -> bool:
	return insert(entity, bounds)


## 检查实体是否存在。
## [br]
## @api public
## [br]
## @param entity: 实体标识或 Object。
## [br]
## @schema entity: Variant entity identity stored by value or weak Object reference.
## [br]
## @return 存在时返回 true。
func has_entity(entity: Variant) -> bool:
	var entity_key: String = _make_entity_key(entity)
	if entity_key.is_empty():
		return false

	var record: Dictionary = _get_record(entity_key)
	if record.is_empty():
		return false
	if not _record_is_valid(record):
		_remove_by_key(entity_key)
		return false
	return true


## 获取实体数量。
## [br]
## @api public
## [br]
## @return 实体数量。
func get_entity_count() -> int:
	prune_invalid_entities()
	return _entity_records.size()


## 查询与 AABB 相交的实体。
## [br]
## @api public
## [br]
## @param area: 查询 AABB。
## [br]
## @return 实体数组。
## [br]
## @schema return: Array entity values restored from spatial hash records.
func query_aabb(area: AABB) -> Array[Variant]:
	prune_invalid_entities()
	var normalized_area: AABB = _normalize_aabb(area)
	var candidate_keys: Array[String] = _query_candidate_keys(normalized_area)
	var result: Array[Variant] = []
	for entity_key: String in candidate_keys:
		var record: Dictionary = _get_record(entity_key)
		if record.is_empty():
			continue
		var bounds: AABB = _get_record_bounds(record)
		if bounds.intersects(normalized_area):
			result.append(_record_to_entity(record))
	return result


## 查询与球体相交的实体。
## [br]
## @api public
## [br]
## @param center: 球心。
## [br]
## @param radius: 半径。
## [br]
## @return 实体数组。
## [br]
## @schema return: Array entity values restored from spatial hash records.
func query_radius(center: Vector3, radius: float) -> Array[Variant]:
	var safe_radius: float = maxf(radius, 0.0)
	var query_bounds: AABB = AABB(
		center - Vector3.ONE * safe_radius,
		Vector3.ONE * safe_radius * 2.0
	)
	var candidates: Array[Variant] = query_aabb(query_bounds)
	var result: Array[Variant] = []
	var radius_sq: float = safe_radius * safe_radius
	for entity: Variant in candidates:
		var record: Dictionary = _get_record(_make_entity_key(entity))
		if record.is_empty():
			continue
		var bounds: AABB = _get_record_bounds(record)
		var closest: Vector3 = Vector3(
			clampf(center.x, bounds.position.x, bounds.position.x + bounds.size.x),
			clampf(center.y, bounds.position.y, bounds.position.y + bounds.size.y),
			clampf(center.z, bounds.position.z, bounds.position.z + bounds.size.z)
		)
		if center.distance_squared_to(closest) <= radius_sq:
			result.append(entity)
	return result


## 清理已释放 Object 实体。
## [br]
## @api public
func prune_invalid_entities() -> void:
	var keys_to_remove: Array[String] = []
	for entity_key: String in _entity_records.keys():
		if not _record_is_valid(_get_record(entity_key)):
			keys_to_remove.append(entity_key)

	for entity_key: String in keys_to_remove:
		_remove_by_key(entity_key)


## 清空索引。
## [br]
## @api public
func clear() -> void:
	_entity_records.clear()
	_bucket_entities.clear()


# --- 私有/辅助方法 ---

func _get_or_create_bucket(cell_key: Vector3i) -> Array:
	if _bucket_entities.has(cell_key):
		return _get_bucket(cell_key)

	var bucket: Array = []
	_bucket_entities[cell_key] = bucket
	return bucket


func _get_bucket(cell_key: Vector3i) -> Array:
	var bucket_value: Variant = GFVariantData.get_option_value(_bucket_entities, cell_key, [])
	if bucket_value is Array:
		return GFVariantData.as_array(bucket_value)
	return []


func _get_record_bounds(record: Dictionary) -> AABB:
	return _variant_to_aabb(GFVariantData.get_option_value(record, "bounds", AABB()))


func _get_record_cells(record: Dictionary) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	var cells_value: Variant = GFVariantData.get_option_value(record, "cells", [])
	if not (cells_value is Array):
		return result

	var cells: Array = GFVariantData.as_array(cells_value)
	for cell_value: Variant in cells:
		if cell_value is Vector3i:
			var cell: Vector3i = cell_value
			result.append(cell)
	return result


func _erase_dictionary_key(target: Dictionary, key: Variant) -> void:
	var _removed: bool = target.erase(key)


func _variant_to_aabb(value: Variant) -> AABB:
	if value is AABB:
		var result: AABB = value
		return result
	return AABB()


func _variant_to_object(value: Variant) -> Object:
	if value is Object:
		var result: Object = value
		return result
	return null


func _variant_to_weak_ref(value: Variant) -> WeakRef:
	if value is WeakRef:
		var result: WeakRef = value
		return result
	return null


func _query_candidate_keys(area: AABB) -> Array[String]:
	var result: Array[String] = []
	var seen: Dictionary = {}
	for cell_key: Vector3i in _get_cells_for_aabb(area):
		var bucket: Array = _get_bucket(cell_key)
		for entity_key: String in bucket:
			if seen.has(entity_key):
				continue
			seen[entity_key] = true
			result.append(entity_key)
	return result


func _get_cells_for_aabb(bounds: AABB) -> Array[Vector3i]:
	var cells: Array[Vector3i] = []
	var min_cell: Vector3i = _world_to_cell(bounds.position)
	var max_corner: Vector3 = bounds.position + bounds.size
	var max_cell: Vector3i = _world_to_cell(max_corner)
	for x: int in range(min_cell.x, max_cell.x + 1):
		for y: int in range(min_cell.y, max_cell.y + 1):
			for z: int in range(min_cell.z, max_cell.z + 1):
				cells.append(Vector3i(x, y, z))
	return cells


func _world_to_cell(position: Vector3) -> Vector3i:
	return Vector3i(
		floori(position.x / _cell_size),
		floori(position.y / _cell_size),
		floori(position.z / _cell_size)
	)


func _make_entity_key(entity: Variant) -> String:
	if entity == null:
		return ""
	if entity is Object:
		var object: Object = _variant_to_object(entity)
		return "object:%d" % object.get_instance_id()
	return "%d:%s" % [typeof(entity), str(entity)]


func _make_entity_record(entity: Variant, bounds: AABB, cells: Array[Vector3i]) -> Dictionary:
	if entity is Object:
		var object: Object = _variant_to_object(entity)
		return {
			"entity_ref": weakref(object),
			"entity": null,
			"bounds": bounds,
			"cells": cells,
		}

	return {
		"entity_ref": null,
		"entity": entity,
		"bounds": bounds,
		"cells": cells,
	}


func _record_to_entity(record: Dictionary) -> Variant:
	var entity_ref_variant: Variant = GFVariantData.get_option_value(record, "entity_ref")
	if entity_ref_variant is WeakRef:
		var entity_ref: WeakRef = _variant_to_weak_ref(entity_ref_variant)
		return entity_ref.get_ref()
	return GFVariantData.get_option_value(record, "entity")


func _record_is_valid(record: Dictionary) -> bool:
	if record.is_empty():
		return false

	var entity_ref_variant: Variant = GFVariantData.get_option_value(record, "entity_ref")
	if entity_ref_variant is WeakRef:
		var entity_ref: WeakRef = _variant_to_weak_ref(entity_ref_variant)
		return entity_ref.get_ref() != null
	return true


func _get_record(entity_key: String) -> Dictionary:
	var record_variant: Variant = GFVariantData.get_option_value(_entity_records, entity_key, {})
	if record_variant is Dictionary:
		return GFVariantData.as_dictionary(record_variant)
	return {}


func _remove_by_key(entity_key: String) -> void:
	var record: Dictionary = _get_record(entity_key)
	if record.is_empty():
		return

	var cells: Array[Vector3i] = _get_record_cells(record)
	for cell_key: Vector3i in cells:
		if not _bucket_entities.has(cell_key):
			continue
		var bucket: Array = _get_bucket(cell_key)
		bucket.erase(entity_key)
		if bucket.is_empty():
			_erase_dictionary_key(_bucket_entities, cell_key)
	_erase_dictionary_key(_entity_records, entity_key)


func _normalize_aabb(bounds: AABB) -> AABB:
	var position: Vector3 = bounds.position
	var size: Vector3 = bounds.size
	if size.x < 0.0:
		position.x += size.x
		size.x = -size.x
	if size.y < 0.0:
		position.y += size.y
		size.y = -size.y
	if size.z < 0.0:
		position.z += size.z
		size.z = -size.z
	return AABB(position, size)


func _rebuild() -> void:
	var records: Dictionary = _entity_records.duplicate(true)
	_entity_records.clear()
	_bucket_entities.clear()
	for record_variant: Variant in records.values():
		var record: Dictionary = GFVariantData.as_dictionary(record_variant)
		if record.is_empty() or not _record_is_valid(record):
			continue
		var _inserted: bool = insert(_record_to_entity(record), _get_record_bounds(record))
