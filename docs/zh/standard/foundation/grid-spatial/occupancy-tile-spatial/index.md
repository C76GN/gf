# 占用、TileMap 缓存、规则表与空间哈希

本组文档覆盖格子占用、TileMap 数据缓存、Tile 规则解析、区域映射和 3D 空间哈希。GF 只维护通用索引、快照和查询结果，不规定棋子规则、地形含义、TileSet 写回或碰撞逻辑。

## 阅读入口

- [格子占用](grid-occupancy.md)：`GFGridOccupancy` 的占用、预约和失效对象清理。
- [TileMap 缓存与区域映射](tile-cache-regions/index.md)：`GFTileMapCache`、`GFTileMetadataLayer`、`GFRegionMap2D/3D`。
- [Tile 规则表](tile-rule-set.md)：`GFTileRuleSet` 的邻域值规则和确定性权重结果。
- [3D 空间哈希](spatial-hash-3d.md)：`GFSpatialHash3D` 的 AABB 索引和粗筛查询。

## 使用边界

这些能力只维护索引、快照和查询结果。实体规则、TileSet 编辑、区块加载、碰撞响应、存档策略和玩法语义应由项目层组合。
