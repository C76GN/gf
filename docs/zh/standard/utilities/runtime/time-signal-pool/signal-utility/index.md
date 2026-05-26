# 原生信号连接工具

业务事件请继续使用 `GFTypeEventSystem`。UI 按钮、动画完成、Area 进入、滑条变化这类 Godot 原生 Signal，经常需要 owner 归属清理、默认参数、一次性监听或防抖处理。`GFSignalUtility` 专门处理这类连接。

## 阅读入口

- [链式连接](chain-connections.md)：`connect_signal()`、默认参数、`filter()`、`map()`、一次性监听、批量断开、owner 清理和防抖节流边界。
- [信号桥接](signal-bridge.md)：`GFSignalBridge`、来源和目标引用、参数转发、校验报告。

## 使用边界

`GFSignalUtility` 面向 Godot 原生 Signal 的连接管理。它不是业务事件系统，也不是 `GFTimerUtility` 的替代品。
