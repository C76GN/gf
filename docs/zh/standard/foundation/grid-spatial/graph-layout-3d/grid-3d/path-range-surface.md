# 寻路、范围与表面邻居

`GFGrid3DMath` 是 3D 整数格子的纯算法工具，提供 6/26 邻域、A*、可达范围和台阶式表面邻居。

```gdscript
var path := GFGrid3DMath.find_path_a_star(
	Vector3i(32, 8, 32),
	start_cell,
	goal_cell,
	func(cell: Vector3i) -> bool:
		return not blocked_cells.has(cell)
)

var surface_path := GFGrid3DMath.find_surface_path_a_star(
	Vector3i(32, 8, 32),
	start_surface_cell,
	goal_surface_cell,
	func(cell: Vector3i) -> bool:
		return walkable_surface_cells.has(cell),
	1,
	2
)
```

表面路径只提供“从当前站立格向水平邻列寻找可站立高度”的机制。是否需要脚底实体、头顶空间、坡度、跳跃、体型半径或动画状态，应继续由项目自己的移动系统和碰撞系统负责。
