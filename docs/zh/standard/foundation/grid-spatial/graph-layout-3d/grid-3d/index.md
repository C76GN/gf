# 3D 整数格算法

这一组文档覆盖 3D 整数格子的纯算法工具：`GFGrid3DMath`、`GFGridKey3D` 和 `GFGridPlaneMapper3D`。

## 阅读入口

- [寻路、范围与表面邻居](path-range-surface.md)：6/26 邻域、A*、可达范围和台阶式表面邻居。
- [稳定 Key](stable-key.md)：`GFGridKey3D` 的有限范围 bit packing。
- [平面映射](plane-mapper.md)：用 axis-aligned 法线把 3D 表面映射为局部 2D 坐标。

## 使用边界

这些工具不绑定 `GridMap`、`TileMapLayer`、物理查询或角色控制器。哪些格子可站立、上下台阶限制、移动代价都由调用方回调决定。
