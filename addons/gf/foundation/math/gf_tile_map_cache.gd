## GFTileMapCache: 通用格子数据快照与差分缓存。
##
## 用 Vector2i 管理格子字典数据，既可手动写入，也可从 TileMapLayer 采集基础
## source/atlas/alternative/terrain 信息。它不规定字段语义，项目可扩展记录内容。
class_name GFTileMapCache
extends Resource


# --- 导出变量 ---

## 格子数据，结构为 Vector2i -> Dictionary。
@export var cells: Dictionary = {}


# --- 公共方法 ---

## 从 TileMapLayer 更新缓存。
## @param layer: 目标 TileMapLayer。
## @param target_cells: 要更新的格子；为空时采集 layer.get_used_cells()。
func update_from_tile_map(layer: TileMapLayer, target_cells: Array[Vector2i] = []) -> void:
	if layer == null:
		return

	var cells_to_update := target_cells
	if cells_to_update.is_empty():
		cells_to_update = layer.get_used_cells()

	for cell: Vector2i in cells_to_update:
		var source_id := layer.get_cell_source_id(cell)
		if source_id == -1:
			erase_cell(cell)
			continue

		var record := {
			"source_id": source_id,
			"atlas_coords": layer.get_cell_atlas_coords(cell),
			"alternative_tile": layer.get_cell_alternative_tile(cell),
		}
		var tile_data := layer.get_cell_tile_data(cell)
		if tile_data != null:
			record["terrain"] = tile_data.get("terrain")
			record["terrain_set"] = tile_data.get("terrain_set")
		set_cell_data(cell, record)


## 设置一个格子的字典数据。
## @param cell: 格坐标。
## @param data: 格子数据。
func set_cell_data(cell: Vector2i, data: Dictionary) -> void:
	cells[cell] = data.duplicate(true)


## 移除一个格子。
## @param cell: 格坐标。
func erase_cell(cell: Vector2i) -> void:
	cells.erase(cell)


## 检查格子是否存在。
## @param cell: 格坐标。
## @return 存在时返回 true。
func has_cell(cell: Vector2i) -> bool:
	return cells.has(cell)


## 获取格子数据副本。
## @param cell: 格坐标。
## @return 格子数据。
func get_cell_data(cell: Vector2i) -> Dictionary:
	var data := cells.get(cell) as Dictionary
	if data == null:
		return {}
	return data.duplicate(true)


## 获取格子字段值。
## @param cell: 格坐标。
## @param key: 字段名。
## @param default_value: 默认值。
## @return 字段值。
func get_value(cell: Vector2i, key: StringName, default_value: Variant = null) -> Variant:
	var data := cells.get(cell) as Dictionary
	if data == null:
		return default_value
	return data.get(key, default_value)


## 清空缓存。
func clear() -> void:
	cells.clear()


## 和另一个缓存做差分。
## @param other: 另一个缓存。
## @param compare_key: 为空时比较完整字典；否则只比较指定字段。
## @return 发生变化的格子列表。
func diff_cells(other: GFTileMapCache, compare_key: StringName = &"") -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if other == null:
		for cell: Vector2i in cells:
			result.append(cell)
		return result

	for cell: Vector2i in cells:
		if not other.cells.has(cell) or _cell_value_changed(cell, other, compare_key):
			result.append(cell)
	for cell: Vector2i in other.cells:
		if not cells.has(cell):
			result.append(cell)
	return result


## 序列化为字典。
## @return 可保存的字典。
func to_dict() -> Dictionary:
	var result: Dictionary = {}
	for cell: Vector2i in cells:
		result["%d,%d" % [cell.x, cell.y]] = (cells[cell] as Dictionary).duplicate(true)
	return result


## 从字典恢复。
## @param data: to_dict() 生成的数据。
func from_dict(data: Dictionary) -> void:
	cells.clear()
	for key: Variant in data.keys():
		var cell := _parse_cell_key(String(key))
		if cell == Vector2i(-2_147_483_648, -2_147_483_648):
			continue
		var record := data[key] as Dictionary
		if record != null:
			cells[cell] = record.duplicate(true)


# --- 私有/辅助方法 ---

func _cell_value_changed(cell: Vector2i, other: GFTileMapCache, compare_key: StringName) -> bool:
	var current := cells[cell] as Dictionary
	var previous := other.cells[cell] as Dictionary
	if compare_key == &"":
		return current != previous
	return current.get(compare_key) != previous.get(compare_key)


func _parse_cell_key(key: String) -> Vector2i:
	var parts := key.split(",")
	if parts.size() != 2:
		return Vector2i(-2_147_483_648, -2_147_483_648)
	if not parts[0].is_valid_int() or not parts[1].is_valid_int():
		return Vector2i(-2_147_483_648, -2_147_483_648)
	return Vector2i(int(parts[0]), int(parts[1]))
