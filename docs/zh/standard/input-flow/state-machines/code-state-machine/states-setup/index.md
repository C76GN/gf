# 状态类与装配

`GFStateMachine` 不使用巨型 `switch/case`，而是独立状态类模式。每个状态继承 `GFState`，状态对象会接收架构注入。

## 阅读入口

- [创建状态类](state-class.md)：`GFState` 的 `enter()`、`update()`、`exit()`、`can_exit()` 和事件处理。
- [初始化状态机](machine-setup.md)：添加状态、分层状态、启动和主循环驱动。
- [启动状态变化信号](start-signal.md)：`start()` 初始进入时的 `state_changed` 语义和静默启动选项。

## 使用边界

纯代码状态机适合脱离场景树、便于测试和复用的业务流程。需要直接操作动画节点、碰撞节点、UI 控件或场景子树时，使用节点状态机。
