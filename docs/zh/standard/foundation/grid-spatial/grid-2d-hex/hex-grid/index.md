# Hex 网格

`GFHexGridMath` 是面向六边形网格的纯算法工具。它和 `GFGridMath` 一样不依赖 `GFArchitecture`，但使用 cube 坐标作为内部拓扑，适合 hex 战棋、策略地图、蜂窝状解谜、区域范围和视线判定。

## 阅读入口

- [坐标与邻居](coordinates-neighbors.md)：cube/offset 坐标转换、邻居枚举、pointy-top/flat-top 布局参数和像素换算。
- [路径、范围与视线](path-range-los.md)：A*、可达范围、视线判定和项目回调。

## 使用边界

GF 只提供坐标、邻居、路径、范围和 Flow Field 原语，不规定地形、阵营、迷雾、单位或渲染语义。
