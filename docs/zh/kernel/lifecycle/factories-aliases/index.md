# Kernel 短生命周期工厂与别名

这一组文档说明不进入完整生命周期的对象如何通过 factory 创建并获得依赖，以及项目如何用 alias 暴露抽象类型。

## 阅读入口

- [短生命周期对象工厂](factories.md)：`register_factory()`、transient/singleton、父子架构回退和工厂实例清理。
- [别名注册与抽象获取](aliases.md)：`register_utility_as()`、显式 alias、继承匹配和歧义处理。

## 使用边界

工厂适合命令、查询、技能执行载体和局部玩法 helper。长期存在并参与完整生命周期、tick 或跨系统协作的对象仍应注册为 `Model`、`System` 或 `Utility`。
