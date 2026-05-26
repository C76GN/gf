# Pattern2D

`GFPattern2D` 是资源化二维格子模式，用 `Array[Vector2i]` 表达范围、形状、阵型、AOE 或 tile pattern。它只负责尺寸、去重、边界过滤和查询，不规定格子含义。

启用 GF 插件后，Inspector 会为 `cells` 提供网格化编辑器，便于小尺寸 pattern 直接勾选、拖拽涂抹，并可按住 Ctrl 擦除格子。

```gdscript
var pattern := GFPattern2D.new()
pattern.pattern_dimensions = Vector2i(5, 5)
pattern.set_cell(Vector2i(2, 2), true)
pattern.set_cell(Vector2i(2, 3), true)

for cell in pattern.get_cells():
	# 项目层自行解释这些格子是攻击范围、建筑 footprint 还是生成模板。
	pass
```
