# 拦截器与动作工厂

ActionQueue 支持在动作执行前后注册横切处理。拦截器适合做表现替换、诊断记录、运行时门禁或模块化修正，不应承载项目规则。

## 阅读入口

- [动作拦截器](interceptors.md)：`GFActionInterceptor`、`GFActionInterceptionResult`、优先级和边界。
- [GFAction 工厂](action-factory.md)：内置动作、sequence、parallel、Tween、属性写入和节点操作工厂。

## 使用边界

ActionQueue 不提供卡牌、Buff、剧情或回合规则。这些规则应留在项目自己的 System、Command 或 Action 子类中，再把最终通用决策表达成拦截结果或通用动作。

## 等待与取消语义

`GFCallableAction` 用于把普通 `Callable` 插入队列。`GFWaitAction` 表达通用时间等待，取消后不会发出 `wait_completed`，且不会再由旧计时器触发二次完成。

队列取消、清空或跳过当前动作时，会通过队列自身的取消令牌停止等待并继续收敛状态，而不是把取消伪装成正常完成。`GFRepeatAction` 会通过工厂每轮创建新动作，避免重复复用带 Tween、Timer 或节点引用的旧动作实例。

顺序或并行 `GFVisualActionGroup` 被取消时，也会结束当前组的等待，不会让队列卡在已经被取消的子动作上。无限重复的瞬时动作会按 `max_immediate_iterations_per_frame` 分批让出主循环，避免把表现队列锁在同一帧。
