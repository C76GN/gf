# 失败状态与超时

从 `2.0.0` 起，Installer 路径为空、脚本无法加载或未继承 `GFInstaller` 时会输出错误并中断初始化。此时架构会进入 `has_initialization_failed()` 状态，并记录 `last_initialization_error`。

修正配置后再次调用 `await Gf.init()` 会在新一轮 Installer 开始时清除旧失败状态，并复用同一个架构继续重试初始化。

迁移旧项目或原型阶段如果确实需要沿用“跳过错误 Installer”的行为，可把 `Project Settings > gf/project/fail_on_installer_error` 显式设为 `false`，但建议只作为短期过渡。

如果项目级 Installer 可能等待外部资源、网络或编辑器回调，可以设置 `Project Settings > gf/project/installer_timeout_seconds`。

该值小于等于 `0.0` 时不启用超时；大于 `0.0` 时，单个 `install()` 或 `install_bindings()` 超时会让架构进入初始化失败状态。

和模块 `async_init()` 一样，Godot coroutine 无法被框架强制取消。超时只能阻止本轮初始化继续推进；已经挂起的 Installer 恢复后应避免继续写回失效架构，可检查 `architecture.is_project_installers_running()`。

架构进入初始化失败状态后，模块、工厂和别名注册入口会拒绝迟到写入，避免超时 coroutine 恢复后污染失败架构。
