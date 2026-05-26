# 事件系统

GF 事件系统提供 Simple Event 与 Type Event 两条通信轨道，并围绕监听器所有权、派发时序、消费语义和诊断能力建立约束。

大型项目里，UI、计分板、敌人、任务和战斗模块如果直接互相引用，重构和测试都会变得困难。事件系统用于广播“某件事已经发生”，让多个模块可以在不直接依赖彼此的情况下响应变化。

两条事件轨道都由当前 `GFArchitecture` 承载，并透明映射到纯 GDScript 路由机制中。

## 阅读入口

- [Simple Event](simple-events.md)：用非空 `StringName` 匹配，适合高频、轻量、可选 payload 的通知。
- [Type Event](type-events/index.md)：按事件对象脚本类型派发，推荐基于 `GFPayload`，适合主要业务通信。

## 生命周期与派发

- [监听器所有权与生命周期](owner-lifecycle.md)：owner 绑定监听、自动清理、状态退出和普通节点接入方式。
- [派发语义与诊断](dispatch-diagnostics.md)：签名校验、同步执行、消费、嵌套派发、深度保护和 trace。

## 使用边界

事件适合通知多个模块“某件事发生了”。如果调用方需要明确返回值、串行等待、失败处理、超时控制或可取消流程，应使用查询、命令、`GFCommandSequence`、Flow、ActionQueue 或项目层 System 调度。
