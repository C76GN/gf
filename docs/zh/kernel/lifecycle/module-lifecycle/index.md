# 模块三阶段生命周期

本组页面说明 `GFModel`、`GFSystem` 和 `GFUtility` 在 `Gf.init()` 后经历的三阶段生命周期，以及初始化完成后的动态注册行为。

## 阅读入口

- [三阶段初始化](init-stages.md)：`init()`、`async_init()`、`ready()` 的执行顺序与职责。
- [异步超时与 Ready 查询](async-ready.md)：异步初始化超时、生命周期有效性和 `require_ready` 查询。
- [初始化后的动态注册](dynamic-registration.md)：架构 ready 后注册新模块时的自动补跑流程。

## 使用边界

GF 生命周期只覆盖注册进架构的 Model、System 和 Utility。Godot 节点生命周期仍由场景树负责；场景桥接逻辑应放在 `GFController`、`GFNodeContext` 或普通节点中。
