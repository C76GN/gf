# TileMap 缓存与区域映射

本组页面说明通用格子数据缓存、Tile 元数据层和 2D/3D 区域映射。它们只维护坐标到数据的结构，不解释地形、区块加载、TileSet 写回、存档策略或项目玩法规则。

## 阅读入口

- [TileMap 缓存](tile-map-cache.md)：`GFTileMapCache` 的格子快照、差分和字典序列化。
- [Tile 元数据层](metadata-layer.md)：`GFTileMetadataLayer` 的元数据读写、批量绘制、查询和 schema。
- [区域映射](region-maps.md)：`GFRegionMap2D` / `GFRegionMap3D` 的分块数据、脏区域和区域快照。

## 使用边界

这些类型只提供 Tile 数据缓存和区域索引。地形含义、刷图规则、TileSet 写回、异步区块加载、碰撞生成和地图存档应由项目工具负责。
