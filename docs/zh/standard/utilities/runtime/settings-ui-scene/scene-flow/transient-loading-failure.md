# 瞬态模块、Loading 与失败恢复

`mark_transient()` 可标记随场景切换清理的 `GFModel`、`GFSystem` 或 `GFUtility` 脚本类型。清理时会调用架构对应的注销流程，不适合标记跨场景长期服务。

切换期间如果注册了 `GFTimeUtility`，工具会暂时设置全局暂停，并在成功或失败后恢复旧暂停状态。带 loading scene 的失败恢复依赖上一场景的 `scene_file_path`；如果当前场景没有资源路径，工具会跳过 loading scene，避免失败后无法切回。

## Loading Scene 协议

Loading scene 可以选择实现以下方法：

- `fade_in()`
- `fade_out()`
- `set_progress(progress)` / `update_progress(progress)`
- `show_error(message)`

GF 会在切入、进度变化、失败和退出前按约定调用这些方法。它们只是协议钩子，不规定 UI 样式、文案或动画。

GF 只管理场景资源生命周期、切换、进度信号和瞬态模块清理。具体加载界面表现、场景内初始化和关卡解锁规则仍属于项目层。
