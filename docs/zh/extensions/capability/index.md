# Capability 能力组合

Capability 扩展用于把局部、可组合的对象能力挂到 receiver 上，例如可交互、可选中、可承伤、临时无敌、命中盒或场景提示节点。它适合表达对象级局部行为，不替代全局生命周期模块、核心数据模型或跨实体调度系统。

## 阅读入口

- [运行时接口与 Utility 注册](runtime-interface.md)：Capability 作为 receiver 的小型运行时接口，以及 `GFCapabilityUtility` 的装配方式。
- [纯代码能力、依赖与 Recipe](code-recipes/index.md)：`GFCapability`、显式依赖、自动补齐、依赖移除策略和 `GFCapabilityRecipe`。
- [Node 能力与场景容器](node-capabilities.md)：`GFNodeCapability`、2D/3D/UI 能力、能力容器、Inspector 添加和场景扫描。
- [能力启停、索引与诊断](state-index-diagnostics.md)：active 状态、反向索引、分组查询和 `inspect_receiver()`。
- [动态属性、Hook 与访问器](property-hooks-accessors/index.md)：`GFPropertyBagCapability`、能力 Hook 和强类型访问器生成。

## 使用边界

如果能力需要参与全局生命周期、tick 顺序、跨模块调度或长期核心数据，应继续使用 `GFSystem`、`GFUtility` 或 `GFModel`。Capability 应保持职责小、receiver 明确、实例不复用；需要复用配置时使用新实例或 `GFCapabilityRecipe`。

## API Reference

完整 Capability API 见 [Capability API Reference](../../reference/api/extensions-capability.md)。
