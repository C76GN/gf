# 路径、范围与视线

需要路径、移动范围或视线时，传入项目自己的通行、代价和阻挡回调。

```gdscript
var path := GFHexGridMath.find_path_a_star(
	Vector2i(32, 32),
	unit_cell,
	target_cell,
	func(cell: Vector2i) -> bool:
		return not blocked_cells.has(cell),
	GFHexGridMath.OffsetLayout.ODD_R,
	func(_from_cell: Vector2i, to_cell: Vector2i) -> float:
		return terrain_costs.get(to_cell, 1.0)
)

var visible := GFHexGridMath.has_line_of_sight(
	unit_cell,
	target_cell,
	func(cell: Vector2i) -> bool:
		return wall_cells.has(cell)
)

var reachable := GFHexGridMath.find_reachable(
	Vector2i(32, 32),
	unit_cell,
	5.0,
	func(cell: Vector2i) -> bool:
		return not blocked_cells.has(cell)
)
```

地形、阵营、迷雾、单位体积和行动规则都应通过项目回调或上层系统表达。
