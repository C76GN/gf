# Standard 标准库总览

`standard` 是 GF 的稳定标准库层。它可以依赖 `kernel`，但不能认识、探测或弱联动任何 GF 内置扩展；需要扩展能力出现在标准库工具中时，由扩展侧通过通用注册入口主动贡献。

标准库适合放足够通用、稳定、默认随框架理解的能力。它不承载具体项目玩法，也不承载可选扩展特有的运行时系统。

## 阅读入口

- [Foundation 基础能力](foundation/index.md)：纯算法、纯数据、格式化、校验、数值、网格和通用结果对象。
- [Utilities 工具总览](utilities/index.md)：需要生命周期、缓存、异步、全局状态或跨模块服务的通用工具。
- [输入、流程与玩法支撑](input-flow/index.md)：输入映射、状态机、命令序列、输入辅助和逻辑空间查询。

## 使用边界

- 纯算法、纯数据、无生命周期的基础件优先放入 `standard/foundation`。
- 需要注册到 `GFArchitecture`、持有缓存或管理异步任务的能力优先放入 `standard/utilities`。
- 输入、状态机、命令序列和项目常见流程支撑放入 `standard/input-flow`。
- Combat、Save、Network、Capability、Interaction、BehaviorTree 等可选能力放入 [Extensions](../extensions/index.md)。

## API Reference

完整类、方法和信号列表见 [Standard API Reference](../reference/api/standard.md)。
