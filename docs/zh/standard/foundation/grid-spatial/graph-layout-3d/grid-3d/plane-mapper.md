# 平面映射

`GFGridPlaneMapper3D` 用 axis-aligned 法线把 3D 表面映射为局部 2D 坐标。

它可以让 `GFTileRuleSet` 这类 2D 邻域规则复用在地面、墙面或天花板格子上。GF 只负责坐标映射和回调采样，不解释面上的瓦片、墙体、建造或体素含义。

```gdscript
var sampled := GFGridPlaneMapper3D.sample_neighbor_values(
	Vector3i(8, 2, 8),
	Vector3i(0, 1, 0),
	func(cell: Vector3i) -> Variant:
		return surface_values.get(cell, 0)
)

var result := rules.resolve(sampled)
```
