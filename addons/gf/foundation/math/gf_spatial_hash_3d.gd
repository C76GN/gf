## GFSpatialHash3D: 纯逻辑 3D 空间哈希。
##
## 适用于大量动态 3D 实体的粗粒度范围查询。它只维护 AABB 索引，
## 不负责物理碰撞、可见性或玩法规则。
class_name GFSpatialHash3D
extends RefCounted


# --- 公共变量 ---

## 单个哈希格子的世界尺寸。
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
## @param p_cell_size: 单格世界尺寸。
func configure(p_cell_size: float) -> void:
	_cell_size = maxf(p_cell_size, 0.0001)
	clear()


## 插入实体。
## @param entity: 实体标识或 Object。
## @param bounds: 实体 AABB。
## @return 成功时返回 true。
func insert(entity: Variant, bounds: AABB) -> bool:
	var entity_key := _make_entity_key(entity)
	if entity_key.is_empty():
		return false

	remove(entity)
	var normalized_bounds := _normalize_aabb(bounds)
	var cells := _get_cells_for_aabb(normalized_bounds)
	_entity_records[entity_key] = _make_entity_record(entity, normalized_bounds, cells)
	for cell_key: String in cells:
		if not _bucket_entities.has(cell_key):
			_bucket_entities[cell_key] = []
		var bucket := _bucket_entities[cell_key] as Array
		if not bucket.has(entity_key):
			bucket.append(entity_key)
	return true


## 移除实体。
## @param entity: 实体标识或 Object。
func remove(entity: Variant) -> void:
	var entity_key := _make_entity_key(entity)
	if entity_key.is_empty() or not _entity_records.has(entity_key):
		return
	_remove_by_key(entity_key)


## 更新实体 AABB。
## @param entity: 实体标识或 Object。
## @param bounds: 新 AABB。
## @return 成功时返回 true。
func update(entity: Variant, bounds: AABB) -> bool:
	return insert(entity, bounds)


## 检查实体是否存在。
## @param entity: 实体标识或 Object。
## @return 存在时返回 true。
func has_entity(entity: Variant) -> bool:
	var entity_key := _make_entity_key(entity)
	if entity_key.is_empty():
		return false

	var record := _get_record(entity_key)
	if record.is_empty():
		return false
	if not _record_is_valid(record):
		_remove_by_key(entity_key)
		return false
	return true


## 获取实体数量。
## @return 实体数量。
func get_entity_count() -> int:
	prune_invalid_entities()
	return _entity_records.size()


## 查询与 AABB 相交的实体。
## @param area: 查询 AABB。
## @return 实体数组。
func query_aabb(area: AABB) -> Array:
	prune_invalid_entities()
	var normalized_area := _normalize_aabb(area)
	var candidate_keys := _query_candidate_keys(normalized_area)
	var result: Array = []
	for entity_key: String in candidate_keys:
		var record := _get_record(entity_key)
		if record.is_empty():
			continue
		var bounds := record["bounds"] as AABB
		if bounds.intersects(normalized_area):
			result.append(_record_to_entity(record))
	return result


## 查询与球体相交的实体。
## @param center: 球心。
## @param radius: 半径。
## @return 实体数组。
func query_radius(center: Vector3, radius: float) -> Array:
	var safe_radius := maxf(radius, 0.0)
	var query_bounds := AABB(
		center - Vector3.ONE * safe_radius,
		Vector3.ONE * safe_radius * 2.0
	)
	var candidates := query_aabb(query_bounds)
	var result: Array = []
	var radius_sq := safe_radius * safe_radius
	for entity: Variant in candidates:
		var record := _get_record(_make_entity_key(entity))
		if record.is_empty():
			continue
		var bounds := record["bounds"] as AABB
		var closest := Vector3(
			clampf(center.x, bounds.position.x, bounds.position.x + bounds.size.x),
			clampf(center.y, bounds.position.y, bounds.position.y + bounds.size.y),
			clampf(center.z, bounds.position.z, bounds.position.z + bounds.size.z)
		)
		if center.distance_squared_to(closest) <= radius_sq:
			result.append(entity)
	return result


## 清理已释放 Object 实体。
func prune_invalid_entities() -> void:
	var keys_to_remove: Array[String] = []
	for entity_key: String in _entity_records.keys():
		if not _record_is_valid(_get_record(entity_key)):
			keys_to_remove.append(entity_key)

	for entity_key: String in keys_to_remove:
		_remove_by_key(entity_key)


## 清空索引。
func clear() -> void:
	_entity_records.clear()
	_bucket_entities.clear()


# --- 私有/辅助方法 ---

func _query_candidate_keys(area: AABB) -> Array[String]:
	var result: Array[String] = []
	var seen: Dictionary = {}
	for cell_key: String in _get_cells_for_aabb(area):
		var bucket := _bucket_entities.get(cell_key, []) as Array
		for entity_key: String in bucket:
			if seen.has(entity_key):
				continue
			seen[entity_key] = true
			result.append(entity_key)
	return result


func _get_cells_for_aabb(bounds: AABB) -> Array[String]:
	var cells: Array[String] = []
	var min_cell := _world_to_cell(bounds.position)
	var max_corner := bounds.position + bounds.size
	var max_cell := _world_to_cell(max_corner)
	for x: int in range(min_cell.x, max_cell.x + 1):
		for y: int in range(min_cell.y, max_cell.y + 1):
			for z: int in range(min_cell.z, max_cell.z + 1):
				cells.append(_cell_key(Vector3i(x, y, z)))
	return cells


func _world_to_cell(position: Vector3) -> Vector3i:
	return Vector3i(
		floori(position.x / _cell_size),
		floori(position.y / _cell_size),
		floori(position.z / _cell_size)
	)


func _cell_key(cell: Vector3i) -> String:
	return "%d:%d:%d" % [cell.x, cell.y, cell.z]


func _make_entity_key(entity: Variant) -> String:
	if entity == null:
		return ""
	if entity is Object:
		return "object:%d" % (entity as Object).get_instance_id()
	return "%d:%s" % [typeof(entity), str(entity)]


func _make_entity_record(entity: Variant, bounds: AABB, cells: Array[String]) -> Dictionary:
	if entity is Object:
		return {
			"entity_ref": weakref(entity),
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
	var entity_ref_variant: Variant = record.get("entity_ref")
	if entity_ref_variant is WeakRef:
		return (entity_ref_variant as WeakRef).get_ref()
	return record.get("entity")


func _record_is_valid(record: Dictionary) -> bool:
	if record.is_empty():
		return false

	var entity_ref_variant: Variant = record.get("entity_ref")
	if entity_ref_variant is WeakRef:
		return (entity_ref_variant as WeakRef).get_ref() != null
	return true


func _get_record(entity_key: String) -> Dictionary:
	var record_variant: Variant = _entity_records.get(entity_key, {})
	if record_variant is Dictionary:
		return record_variant as Dictionary
	return {}


func _remove_by_key(entity_key: String) -> void:
	var record := _get_record(entity_key)
	if record.is_empty():
		return

	var cells := record.get("cells", []) as Array
	for cell_key: String in cells:
		if not _bucket_entities.has(cell_key):
			continue
		var bucket := _bucket_entities[cell_key] as Array
		bucket.erase(entity_key)
		if bucket.is_empty():
			_bucket_entities.erase(cell_key)
	_entity_records.erase(entity_key)


func _normalize_aabb(bounds: AABB) -> AABB:
	var position := bounds.position
	var size := bounds.size
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
	var records := _entity_records.duplicate(true)
	_entity_records.clear()
	_bucket_entities.clear()
	for record_variant: Variant in records.values():
		var record := record_variant as Dictionary
		if record.is_empty() or not _record_is_valid(record):
			continue
		insert(_record_to_entity(record), record["bounds"] as AABB)
