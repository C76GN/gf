# 坐标与邻居

`GFHexGridMath` 使用 cube 坐标作为内部拓扑，并提供 offset 坐标转换入口。

```gdscript
var cube := GFHexGridMath.offset_to_cube(Vector2i(2, 3), GFHexGridMath.OffsetLayout.ODD_R)
var cell := GFHexGridMath.cube_to_offset(cube, GFHexGridMath.OffsetLayout.ODD_R)

var neighbors := GFHexGridMath.get_neighbors(
	Vector2i(4, 4),
	Vector2i(16, 16),
	GFHexGridMath.OffsetLayout.ODD_R
)
```

布局选择应与项目地图数据保持一致。GF 只负责坐标转换和邻域关系，不负责 TileMap、Mesh 或编辑器资源生成。

像素换算支持 pointy-top 与 flat-top。`hex_size` 表示六边形外接圆半径。这些函数只返回中心点或顶点偏移，最终如何创建 TileMap、Polygon2D、Mesh、碰撞或相机仍由项目层决定。
