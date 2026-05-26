# 场景树节点状态机

`GFNodeStateMachine`、`GFNodeState` 和 `GFNodeStateGroup` 服务于角色控制器、UI 流程和复杂交互对象这类依赖场景树的状态。

## 阅读入口

- [节点结构与状态脚本](structure-states.md)：状态机节点树、`GFNodeState` 脚本和跨组状态路径。
- [启动时机](start-mode.md)：`ON_READY`、`AFTER_HOST_READY`、`MANUAL` 和宿主 `_ready()` 顺序。
- [状态栈与动态清理](state-stack-cleanup.md)：覆盖式状态、暂停/恢复、重定向和运行时移除。
- [配置资源与运行时查询](config-runtime-query.md)：`GFNodeStateMachineConfig`、状态历史、栈深度和宿主访问。

## 使用边界

当状态逻辑需要直接引用动画、碰撞、输入节点或子节点时，可以使用节点式状态机。它不会替代纯代码 `GFStateMachine`，而是服务于天然依赖场景树的状态。
