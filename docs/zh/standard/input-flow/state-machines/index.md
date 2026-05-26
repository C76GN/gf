# 纯代码状态机与节点状态机总览

标准库提供两种状态组织方式：`GFStateMachine` 适合纯代码逻辑流程和实体决策，`GFNodeStateMachine` 适合天然依赖场景树、动画、碰撞、输入节点或 UI 子节点的状态。

## 阅读入口

- [分层纯代码有限状态机](code-state-machine/index.md)：`GFStateMachine`、`GFState`、分层状态路径、守卫、事件分发和依赖代理。
- [场景树节点状态机](node-state-machine/index.md)：`GFNodeStateMachine`、`GFNodeState`、状态组、启动时机、状态栈和运行时查询。
- [节点状态 Hook、资源片段与校验](node-state-hooks-validation/index.md)：状态依赖代理、条件/行为资源、状态事件、快照和编辑器结构校验。

## 使用边界

需要脱离场景树、便于测试和复用的业务流程优先使用纯代码状态机。状态需要直接操作动画节点、碰撞节点、UI 控件或场景子树时，使用节点状态机。两者都只提供状态组织机制，不规定项目的动画命名、输入动作、AI 黑板字段或状态转移表。
