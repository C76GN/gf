@tool

## GFPattern2DEditorProperty: 在 Inspector 中用网格编辑 GFPattern2D.cells。
extends EditorProperty


# --- 常量 ---

const GF_PATTERN_2D_BASE := preload("res://addons/gf/foundation/math/gf_pattern_2d.gd")


# --- 私有变量 ---

var _root: MarginContainer
var _grid: GridContainer
var _is_updating: bool = false


# --- Godot 生命周期方法 ---

func _init() -> void:
	_root = MarginContainer.new()
	add_child(_root)
	_grid = GridContainer.new()
	_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_root.add_child(_grid)


# --- Godot 回调方法 ---

func _update_property() -> void:
	var pattern := get_edited_object() as GF_PATTERN_2D_BASE
	if pattern == null:
		return

	_is_updating = true
	_rebuild_grid(pattern)
	_is_updating = false


# --- 私有/辅助方法 ---

func _rebuild_grid(pattern: Resource) -> void:
	for child: Node in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()

	var dimensions := pattern.get("pattern_dimensions") as Vector2i
	_grid.columns = maxi(dimensions.x, 1)
	var cells := pattern.get("cells") as Array
	for y: int in range(dimensions.y):
		for x: int in range(dimensions.x):
			_grid.add_child(_create_cell_button(Vector2i(x, y), cells))


func _create_cell_button(cell: Vector2i, cells: Array) -> CheckBox:
	var checkbox := CheckBox.new()
	checkbox.focus_mode = Control.FOCUS_NONE
	checkbox.tooltip_text = "%d,%d" % [cell.x, cell.y]
	checkbox.button_pressed = cells.has(cell)
	checkbox.custom_minimum_size = Vector2(22.0, 22.0)
	checkbox.toggled.connect(_on_cell_toggled.bind(cell))
	return checkbox


func _make_next_cells(cell: Vector2i, enabled: bool) -> Array[Vector2i]:
	var pattern := get_edited_object() as GF_PATTERN_2D_BASE
	var next_cells: Array[Vector2i] = []
	if pattern == null:
		return next_cells

	next_cells.append_array(pattern.get_cells())
	if enabled:
		if not next_cells.has(cell):
			next_cells.append(cell)
	else:
		next_cells.erase(cell)
	next_cells.sort_custom(func(left: Vector2i, right: Vector2i) -> bool:
		if left.y == right.y:
			return left.x < right.x
		return left.y < right.y
	)
	return next_cells


# --- 信号处理函数 ---

func _on_cell_toggled(enabled: bool, cell: Vector2i) -> void:
	if _is_updating:
		return
	emit_changed("cells", _make_next_cells(cell, enabled))
