# 输入、流程与玩法支撑

本组文档覆盖标准库中的输入映射、状态机、指令序列、撤销历史和轻量空间查询。关卡、任务和行为树已经收敛到 GF 内置扩展页面。

## 阅读入口

- [纯代码状态机与节点状态机](state-machines.md)：`GFStateMachine` 与 `GFNodeStateMachine`。
- [撤销历史与指令序列](command-sequence.md)：`GFUndoableCommand`、`GFCommandHistoryUtility`、`GFCommandSequence`。
- [输入映射与手感辅助](input-assist.md)：输入动作、玩家设备、输入缓冲、连击和方向辅助。
- [逻辑空间查询与相关扩展](spatial-query.md)：逻辑四叉树和 GF 内置扩展跳转。
