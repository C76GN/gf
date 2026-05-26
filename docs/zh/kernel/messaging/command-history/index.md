# 命令历史与撤销重做

`GFCommandHistoryUtility` 用于管理命令执行历史、撤销、重做、序列化、恢复和异步操作约束。

当你使用 `GFCommand` 编码操作指令时，可以接入 GF Framework 提供的基于 `GFUndoableCommand` 的撤销重做栈扩展体系。基本接入步骤是：让命令继承 `GFUndoableCommand`，使用 `GFCommandHistoryUtility.execute_command(cmd)` 统一执行，再通过历史工具统一撤销和重做。

## 使用边界

`GFCommandHistoryUtility` 只管理历史栈和调用顺序。每个命令如何执行、撤销、保存快照和恢复状态，仍由命令类自己负责。

## 阅读入口

- [序列化与恢复](persistence.md)：`serialize_history()`、`deserialize_history()`、命令构建器和历史容量。
- [异步撤销与重做](async-constraints.md)：Signal 等待、异步超时、并发操作拒绝和项目层排队。

命令历史、快照历史和流程编排的更多用法，可继续阅读 [本地存储、编码、同步与快照](../../../standard/utilities/io/storage-snapshot/index.md) 与 [撤销历史与指令序列](../../../standard/input-flow/command-sequence/index.md)。
