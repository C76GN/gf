# Kernel 装配入口与依赖诊断

这一组文档概述全局 Installer、局部 `GFNodeContext`、声明式装配、工厂和依赖诊断。完整生命周期细节见 [生命周期、装配与依赖](../../lifecycle/index.md)。

## 阅读入口

- [装配入口与局部上下文](assembly-context.md)：Installer 装配、节点级上下文和两者的职责边界。
- [声明式装配与工厂](binder-factories.md)：`GFBinder`、`GFBindBuilder`、别名、singleton/transient 和父子架构回退。
- [依赖诊断](dependency-diagnostics.md)：模块依赖声明、诊断报告和项目级分级边界。

## 使用边界

Installer 解决“项目启动时装什么”，NodeContext 解决“某个场景或玩法片段拥有自己的临时模块”。依赖诊断只读，不会自动注册缺失模块，也不会改变现有依赖解析语义。
