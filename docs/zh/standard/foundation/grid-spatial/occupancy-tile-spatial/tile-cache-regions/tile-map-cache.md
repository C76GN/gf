# TileMap 缓存

`GFTileMapCache` 是通用格子数据快照与差分缓存，适合把 `TileMapLayer` 当前格子信息采集成纯字典，也可以完全由项目手动写入。

它不规定字段语义，因此可用于自动铺砖预览、地图差分刷新、编辑器工具或存档片段。

```gdscript
var previous := GFTileMapCache.new()
previous.update_from_tile_map(tile_map_layer)

# 项目层修改地图后再次采集。
var current := GFTileMapCache.new()
current.update_from_tile_map(tile_map_layer)

for cell in current.diff_cells(previous, &"source_id"):
	refresh_cell_visual(cell)

var saved := current.to_dict()
```

缓存输出仍是普通数据。字段如何对应地形、渲染刷新、碰撞、寻路或存档，由项目层决定。
