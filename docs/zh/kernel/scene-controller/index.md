# 场景桥接、Controller 与数据绑定

这一组文档说明 Godot `Node` 世界如何接入 GF：核心 `System` 如何脱离场景树集中更新，`GFController` 如何承担表现层桥接，以及 UI 如何通过绑定属性订阅 Model 状态。

## 阅读入口

- [更新机制与 Controller](updates-and-controllers/index.md)：`GFSystem.tick()` / `physics_tick()`、tick 优先级、时间缩放和 Controller 更新边界。
- [GFBindableProperty 基础绑定](bindable-property/index.md)：Model 中的绑定属性、Controller 订阅、自动解绑和手动清理。
- [派生属性、组合副作用与绑定边界](reactive-computed-bindings.md)：`GFReactiveEffect`、`GFComputedProperty`、只读绑定属性和何时使用全局事件。

## 使用边界

核心规则、状态推进和跨模块调度放在 `GFSystem`；场景输入、动画、UI 和节点引用放在 `GFController` 或普通节点；字段展示优先用绑定属性；跨系统业务动作仍使用事件、命令或查询。
