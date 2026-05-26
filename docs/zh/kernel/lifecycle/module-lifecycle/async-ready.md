# 异步超时与 Ready 查询

`async_init()` 适合等待网络请求、本地 IO 或大批量资源异步加载。项目应避免让开发期资源加载、网络请求或外部回调永久挂起。

## 异步超时

可通过 `GFArchitecture.module_async_init_timeout_seconds` 设置模块异步初始化超时。超时会让架构进入初始化失败状态，并唤醒等待 `init()` / `GFNodeContext.wait_until_ready()` 的调用方。

Godot coroutine 无法被框架强制取消。超时只能阻止架构继续推进；已经挂起的 `async_init()` 如果之后恢复，模块内部应避免继续写回已失效的外部状态。持有架构引用的异步流程可以用 `architecture.is_lifecycle_active()` 判断当前架构是否仍可安全写回；继承 `GFModel`、`GFSystem`、`GFUtility` 的模块也可以直接调用自身的 `is_lifecycle_active()`。

## Ready 查询

依赖查询默认保持兼容，会返回已注册但仍处于初始化过程中的模块。如果代码必须只消费完成 `ready()` 的模块，可以在 `GFArchitecture`、`Gf`、`GFNodeContext`、`GFController`、`GFCommand`、`GFQuery`、`GFSystem` 或 `GFUtility` 的 `get_model()` / `get_system()` / `get_utility()` 中传入 `require_ready = true`。

本地查询 `get_local_*()` 也支持相同参数。需要判断某个实例是否已经完成 `ready()` 时，可调用 `architecture.is_module_ready(instance)`，模块自身可用 `is_ready_in_architecture()`。
