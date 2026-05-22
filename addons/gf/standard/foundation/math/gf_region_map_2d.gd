## GFRegionMap2D: 通用二维区域分块数据映射。
##
## 按固定区域尺寸管理格子数据，并追踪发生变化的区域，适合大地图、编辑器批处理或局部保存。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFRegionMap2D
extends RefCounted


# --- 公共变量 ---

## 每个区域包含的格子尺寸。
## [br]
## @api public
var region_size: Vector2i = Vector2i(32, 32)

## 读写值时是否复制集合类型。
## [br]
## @api public
var duplicate_values: bool = true


# --- 私有变量 ---

var _regions: Dictionary = {}
var _dirty_regions: Dictionary = {}


# --- 公共方法 ---

## 根据格坐标获取区域键。
## [br]
## @api public
## [br]
## @param cell: 格坐标。
## [br]
## @return 区域键。
func get_region_key_for_cell(cell: Vector2i) -> Vector2i:
	var safe_size := Vector2i(maxi(region_size.x, 1), maxi(region_size.y, 1))
	return Vector2i(floori(float(cell.x) / float(safe_size.x)), floori(float(cell.y) / float(safe_size.y)))


## 设置格子数据。
## [br]
## @api public
## [br]
## @param cell: 格坐标。
## [br]
## @param value: 格子数据。
## [br]
## @schema value: Variant cell value stored in the region map.
func set_cell(cell: Vector2i, value: Variant) -> void:
	var region_key := get_region_key_for_cell(cell)
	var region := _get_or_create_region(region_key)
	region[cell] = _copy_value(value)
	_mark_dirty(region_key)


## 获取格子数据。
## [br]
## @api public
## [br]
## @param cell: 格坐标。
## [br]
## @param default_value: 缺失时返回的默认值。
## [br]
## @schema default_value: Variant fallback value returned when the cell is missing.
## [br]
## @return 格子数据。
## [br]
## @schema return: Variant cell value or default_value.
func get_cell(cell: Vector2i, default_value: Variant = null) -> Variant:
	var region_key := get_region_key_for_cell(cell)
	var region := _regions.get(region_key) as Dictionary
	if region == null or not region.has(cell):
		return default_value
	return _copy_value(region[cell])


## 移除格子数据。
## [br]
## @api public
## [br]
## @param cell: 格坐标。
## [br]
## @return 移除成功返回 true。
func erase_cell(cell: Vector2i) -> bool:
	var region_key := get_region_key_for_cell(cell)
	var region := _regions.get(region_key) as Dictionary
	if region == null or not region.has(cell):
		return false
	region.erase(cell)
	if region.is_empty():
		_regions.erase(region_key)
	_mark_dirty(region_key)
	return true


## 检查格子是否存在。
## [br]
## @api public
## [br]
## @param cell: 格坐标。
## [br]
## @return 存在返回 true。
func has_cell(cell: Vector2i) -> bool:
	var region := _regions.get(get_region_key_for_cell(cell)) as Dictionary
	return region != null and region.has(cell)


## 获取区域内全部格子坐标。
## [br]
## @api public
## [br]
## @param region_key: 区域键。
## [br]
## @return 格坐标列表。
func get_region_cells(region_key: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var region := _regions.get(region_key) as Dictionary
	if region == null:
		return result
	for cell: Vector2i in region.keys():
		result.append(cell)
	return result


## 获取区域数据快照。
## [br]
## @api public
## [br]
## @param region_key: 区域键。
## [br]
## @return 区域数据字典。
## [br]
## @schema return: Dictionary mapping Vector2i cells to stored cell values.
func get_region_snapshot(region_key: Vector2i) -> Dictionary:
	var region := _regions.get(region_key) as Dictionary
	return region.duplicate(true) if region != null else {}


## 获取已存在的区域键。
## [br]
## @api public
## [br]
## @return 区域键列表。
func get_region_keys() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for region_key: Vector2i in _regions.keys():
		result.append(region_key)
	return result


## 获取脏区域键。
## [br]
## @api public
## [br]
## @return 脏区域键列表。
func get_dirty_region_keys() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for region_key: Vector2i in _dirty_regions.keys():
		result.append(region_key)
	return result


## 清理脏区域标记。
## [br]
## @api public
## [br]
## @param region_key: 指定区域；为 null 时清空全部。
## [br]
## @schema region_key: Variant null or Vector2i region key.
func clear_dirty(region_key: Variant = null) -> void:
	if region_key == null:
		_dirty_regions.clear()
	elif region_key is Vector2i:
		_dirty_regions.erase(region_key)


## 清空全部区域数据。
## [br]
## @api public
func clear() -> void:
	_regions.clear()
	_dirty_regions.clear()


## 获取调试快照。
## [br]
## @api public
## [br]
## @return 调试快照字典。
## [br]
## @schema return: Dictionary with region_size, region_count, and dirty_region_count.
func get_debug_snapshot() -> Dictionary:
	return {
		"region_size": region_size,
		"region_count": _regions.size(),
		"dirty_region_count": _dirty_regions.size(),
	}


# --- 私有/辅助方法 ---

func _get_or_create_region(region_key: Vector2i) -> Dictionary:
	if not _regions.has(region_key):
		_regions[region_key] = {}
	return _regions[region_key] as Dictionary


func _mark_dirty(region_key: Vector2i) -> void:
	_dirty_regions[region_key] = true


func _copy_value(value: Variant) -> Variant:
	if not duplicate_values:
		return value
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value
