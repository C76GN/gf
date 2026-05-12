# 消息、事件、命令与查询

本组文档覆盖 GF 中的模块通信与操作表达：事件负责广播通知，命令和查询负责显式读写动作，命令历史负责撤销、重做和持久化。

## 阅读入口

- [事件系统](events.md)：Simple Event、Type Event、监听器所有权、派发时序和最佳实践。
- [命令、查询与规则](commands-queries-rules.md)：`GFCommand`、`GFQuery`、`GFRule`、工厂注入和跨模块调用。
- [命令历史与撤销重做](command-history.md)：`GFCommandHistoryUtility` 的执行历史、序列化、恢复和异步撤销。

## 选择建议

- 想通知多个模块“某件事发生了”，优先读事件系统。
- 想表达一次明确写操作，使用 `GFCommand`。
- 想跨模块读取数据，使用 `GFQuery`。
- 想让操作可撤销、可重做或可存档，继续读命令历史。
