# 纯代码能力、依赖与 Recipe

本组页面说明纯代码能力如何挂载、查询、声明依赖、自动补齐依赖，以及如何用 `GFCapabilityRecipe` 复用一组能力配置。

## 阅读入口

- [纯代码能力](code-capabilities.md)：继承 `GFCapability`、挂载、查询和 receiver 注入。
- [显式依赖](dependencies.md)：`required_capabilities`、自动补齐、依赖移除策略和 Hook 边界。
- [能力组合 Recipe](recipes.md)：`GFCapabilityRecipe`、条目、事务应用和反向移除。

## 使用边界

纯代码能力适合挂载到任意 receiver 对象上，表达小范围、可组合、可启停的对象能力。需要场景节点生命周期、Inspector 添加或节点树扫描时，使用 [Node 能力与场景容器](../node-capabilities.md)。
