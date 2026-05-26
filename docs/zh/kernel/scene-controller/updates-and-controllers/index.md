# 更新机制与 Controller

本组页面说明核心 `System` 如何由架构集中驱动，以及 `GFController` 为什么仍由 Godot 场景树管理并承担表现层更新。

## 阅读入口

- [System 与 Utility 心跳](system-tick.md)：`tick()`、`physics_tick()`、tick 缓存和热路径依赖读取。
- [优先级与时间缩放](priority-time.md)：tick 优先级、生命周期优先级和 `GFTimeUtility` 时间缩放。
- [Controller 更新边界](controller-updates.md)：Controller 仍使用 Godot `_process()` / `_physics_process()` 承担输入和表现桥接。

## 使用边界

核心业务循环应放在 `GFSystem` 或需要帧驱动的 `GFUtility` 中，由架构集中推进。场景输入、动画插值、特效表现和节点物理细节仍由 Godot 节点或 `GFController` 处理。
