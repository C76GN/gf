# Kernel 总览

Kernel 是 GF 的运行内核，负责全局入口、架构容器、生命周期、事件、命令、查询、场景桥接、依赖解析和编辑器基础设施。它只放框架启动与运行所必需的契约和机制，不依赖标准库或可选扩展的具体实现。

## 阅读入口

- [架构容器](architecture/index.md)：`Gf`、`GFArchitecture`、层级边界、装配诊断、五层分工、编辑器访问器和内核基础设施。
- [生命周期、装配与依赖](lifecycle/index.md)：Installer、三阶段初始化、动态注册、局部上下文、工厂、别名和 Controller 初始化。
- [消息、事件、命令与查询](messaging/index.md)：事件系统、命令、查询、规则和命令历史。
- [场景桥接、Controller 与数据绑定](scene-controller/index.md)：`GFController`、System 更新、绑定属性和局部响应式组合。

## 使用边界

需要被 Kernel 直接识别的能力应收敛为内核契约。纯算法和数据结构放入 Foundation；默认稳定服务放入 Standard Utilities；可选原子能力放入 Extensions；项目玩法、SDK 适配和跨扩展组合留给项目代码或独立插件。

## API Reference

完整类、方法和信号列表见 [Kernel API Reference](../reference/api/kernel.md)。
