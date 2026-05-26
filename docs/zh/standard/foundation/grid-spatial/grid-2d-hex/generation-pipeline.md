# 2D 网格生成管线

`GFGridSelection2D`、`GFGridGenerationStep2D` 和 `GFGridGenerationPipeline2D` 提供通用 2D 网格生成数据管线。

它们只处理 `Vector2i` 候选格子和 `Dictionary[Vector2i, Variant]` 输出，不绑定房间、地牢、TileMap、GridMap、Mesh、碰撞或具体玩法。

- `GFGridSelection2D` 负责从候选格子中筛选坐标，支持显式包含/排除、矩形边界、反选、自定义回调和子类重写。
- `GFGridGenerationStep2D` 负责把选择器命中的格子写入一个通用值，或从结果字典中移除。
- `GFGridGenerationPipeline2D` 负责按步骤生成或修改网格字典，并提供矩形候选格子构造辅助。

```gdscript
var candidates := GFGridGenerationPipeline2D.make_rect_candidates(Vector2i.ZERO, Vector2i(8, 8))

var inner := GFGridSelection2D.new()
inner.use_bounds = true
inner.bounds_position = Vector2i(1, 1)
inner.bounds_size = Vector2i(6, 6)

var step := GFGridGenerationStep2D.new()
step.selection = inner
step.value = &"walkable"

var pipeline := GFGridGenerationPipeline2D.new()
pipeline.fill_default_value = true
pipeline.default_value = &"blocked"
pipeline.add_step(step)

var grid := pipeline.generate(candidates)
```

输出值是什么、如何转换成瓦片、场景节点、导航、碰撞或存档，仍由项目层决定。

需要 3D 或六边形生成时，也应沿用“候选数据 -> 选择器 -> 步骤 -> 输出数据”的模式扩展，而不是把具体地图业务写进基础层。
