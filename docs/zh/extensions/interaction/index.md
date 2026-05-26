# Interaction 交互上下文

Interaction 扩展提供一次性交互上下文、链式交互辅助、交互发送/接收节点和 3D 指针桥接。它只组织“谁向谁发送了什么上下文、接收方是否接受”，不负责能力查询、冷却、权限、目标合法性、效果结算、碰撞层筛选或 UI 提示。

## 阅读入口

- [上下文与链式流程](context-flow.md)：`GFInteractionContext`、`GFInteractions`、命令执行和事件发送。
- [Sensor 与 Receiver](sensor-receiver.md)：`GFInteractionSensor`、`GFInteractionReceiver`、交互 ID 过滤、接收报告和业务目标桥接。
- [3D 指针桥接](pointer-3d.md)：`GFPointerInteraction3D`、hover、press、release、click 和 wheel 到交互上下文的转换。

## 使用边界

Interaction 适合作为项目交互协议的通用载体。对象是否可交互、是否有权限、是否消耗物品、是否命中、是否触发动画和反馈，应由项目代码、Capability、Combat、ActionQueue 或其他项目级系统明确组合。

## API Reference

完整类、方法和信号列表见 [Interaction API Reference](../../reference/api/extensions-interaction.md)。
