# GFBindableProperty 基础绑定

`GFBindableProperty` 提供局部、无事件总线开销的数据驱动绑定机制。它适合 Model 暴露单个字段状态，并让 Controller 或 UI 直接订阅该字段变化。

## 阅读入口

- [Model 属性定义](model-definition.md)：`GFBindableProperty` 的定位、观察者模型和 Model 内字段声明。
- [Controller 订阅](controller-binding.md)：Controller 如何绑定字段变化并立即刷新初始 UI。
- [生命周期与清理](lifecycle-cleanup.md)：`bind_to()` 自动解绑、手动解绑和订阅清理语义。

## 使用边界

绑定属性适合局部展示更新，不经过全局事件总线。跨系统业务动作仍应使用事件、命令或查询。
