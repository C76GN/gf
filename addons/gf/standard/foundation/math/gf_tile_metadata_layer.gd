## GFTileMetadataLayer: 通用格子元数据层。
##
## 在 Vector2i 格坐标上维护任意键值元数据，可服务于编辑器画刷、运行时标记、
## 规则查询或导出流程。它只管理数据结构，不绑定 TileSet、TileMapLayer 或项目业务语义。
class_name GFTileMetadataLayer
extends GFTileMapCache


# --- 导出变量 ---

## 可选字段 schema。框架不解释 schema 内容，项目可用于编辑器 UI、校验或导出。
@export var schema: Dictionary = {}


# --- 公共方法 ---

## 设置格子字段值。
## @param cell: 格坐标。
## @param key: 字段名。
## @param value: 字段值。
func set_cell_value(cell: Vector2i, key: StringName, value: Variant) -> void:
	if key == &"":
		return
	var data := get_cell_data(cell)
	data[key] = GFVariantData.duplicate_variant(value)
	set_cell_data(cell, data)


## 获取格子数据副本。
## @param cell: 格坐标。
## @return 格子数据。
func get_cell_data(cell: Vector2i) -> Dictionary:
	if not cells.has(cell):
		return {}
	var value: Variant = cells[cell]
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}


## 获取格子字段值。
## @param cell: 格坐标。
## @param key: 字段名。
## @param default_value: 默认值。
## @return 字段值。
func get_cell_value(cell: Vector2i, key: StringName, default_value: Variant = null) -> Variant:
	var data := get_cell_data(cell)
	return data.get(key, default_value)


## 合并格子数据。
## @param cell: 格坐标。
## @param data: 要合并的数据。
## @param overwrite: 为 false 时不覆盖已有字段。
func merge_cell_data(cell: Vector2i, data: Dictionary, overwrite: bool = true) -> void:
	var current := get_cell_data(cell)
	for key: Variant in data.keys():
		if overwrite or not current.has(key):
			current[key] = GFVariantData.duplicate_variant(data[key])
	set_cell_data(cell, current)


## 移除格子字段。
## @param cell: 格坐标。
## @param key: 字段名。
## @return 成功移除返回 true。
func erase_cell_key(cell: Vector2i, key: StringName) -> bool:
	if not cells.has(cell):
		return false
	var value: Variant = cells[cell]
	if not (value is Dictionary):
		return false
	var data := value as Dictionary
	if not data.has(key):
		return false
	data.erase(key)
	if data.is_empty():
		erase_cell(cell)
	else:
		set_cell_data(cell, data)
	return true


## 检查格子字段是否存在。
## @param cell: 格坐标。
## @param key: 字段名。
## @return 存在时返回 true。
func has_cell_key(cell: Vector2i, key: StringName) -> bool:
	if not cells.has(cell):
		return false
	var value: Variant = cells[cell]
	return value is Dictionary and (value as Dictionary).has(key)


## 批量为格子绘制同一个字段值。
## @param target_cells: 目标格子。
## @param key: 字段名。
## @param value: 字段值。
## @return 实际写入的格子数量。
func paint_cells(target_cells: Array[Vector2i], key: StringName, value: Variant) -> int:
	if key == &"":
		return 0
	var count := 0
	for cell: Vector2i in target_cells:
		set_cell_value(cell, key, value)
		count += 1
	return count


## 批量移除格子字段。
## @param target_cells: 目标格子。
## @param key: 字段名。
## @return 实际移除的字段数量。
func erase_cells_key(target_cells: Array[Vector2i], key: StringName) -> int:
	var count := 0
	for cell: Vector2i in target_cells:
		if erase_cell_key(cell, key):
			count += 1
	return count


## 查找拥有指定字段值的格子。
## @param key: 字段名。
## @param value: 目标值。
## @return 匹配格子列表。
func get_cells_with_value(key: StringName, value: Variant) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell: Vector2i in cells:
		var cell_value: Variant = cells[cell]
		if cell_value is Dictionary and (cell_value as Dictionary).get(key) == value:
			result.append(cell)
	return result


## 设置 schema 字段元数据。
## @param key: 字段名。
## @param metadata: 字段元数据。
func set_schema_entry(key: StringName, metadata: Dictionary) -> void:
	if key == &"":
		return
	schema[key] = metadata.duplicate(true)


## 获取 schema 字段元数据。
## @param key: 字段名。
## @return schema 元数据副本。
func get_schema_entry(key: StringName) -> Dictionary:
	var data := schema.get(key) as Dictionary
	return data.duplicate(true) if data != null else {}


## 移除 schema 字段元数据。
## @param key: 字段名。
func erase_schema_entry(key: StringName) -> void:
	schema.erase(key)


## 转换为基础 TileMap 缓存。
## @return 缓存副本。
func to_tile_map_cache() -> GFTileMapCache:
	var cache := GFTileMapCache.new()
	for cell: Vector2i in cells:
		var value: Variant = cells[cell]
		if value is Dictionary:
			cache.set_cell_data(cell, value as Dictionary)
	return cache


## 从基础 TileMap 缓存复制数据。
## @param cache: 源缓存。
## @param merge: 为 true 时合并到现有数据，否则先清空。
func from_tile_map_cache(cache: GFTileMapCache, merge: bool = false) -> void:
	if cache == null:
		return
	if not merge:
		clear()
	for cell: Vector2i in cache.cells:
		var value: Variant = cache.cells[cell]
		if value is Dictionary:
			set_cell_data(cell, value as Dictionary)
