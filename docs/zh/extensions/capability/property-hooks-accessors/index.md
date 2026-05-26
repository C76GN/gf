# Capability 动态属性、Hook 与访问器

这一组文档说明动态属性包、能力 Hook，以及编辑器强类型访问器生成。它们是辅助能力组合和调用体验的工具，不应承载项目核心数据模型。

## 阅读入口

- [动态属性包](property-bag.md)：`GFPropertyBagCapability` 的轻量键值存取和类型化读取。
- [能力 Hook 与依赖](hooks-dependencies.md)：能力添加、移除、激活变化、依赖移除策略和依赖注入。
- [强类型访问器生成](typed-accessors.md)：编辑器菜单生成 `GFAccess` helper、局部架构传入和 Command/Query 创建语义。

## 使用边界

动态属性包适合原型、调试或少量临时运行时数据。长期核心状态仍应放在 `GFModel` 或配置资源中，避免把属性包变成隐藏数据模型。
