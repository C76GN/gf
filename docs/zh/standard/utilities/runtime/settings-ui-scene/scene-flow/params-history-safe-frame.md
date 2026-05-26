# 参数、历史与安全帧

切换参数可直接传给 `load_scene_async(path, loading_scene_path, params, minimum_duration_seconds)`，也可以写在 `GFSceneTransitionConfig.params` 中。`begin_background_scene_load(path, params, fixed)` 会复用预加载缓存并记录稍后激活时使用的参数；`activate_background_scene(path, loading_scene_path, minimum_duration_seconds)` 只激活已经预加载或正在预加载的场景，不会把任意缺失资源变成隐式切换请求。

切换成功后，`get_current_scene_params()` 返回当前场景参数副本，适合场景入口脚本读取出生点、入口来源、过场配置或项目自定义 DTO。

## 安全帧切换

`load_scene_async()` 可以在 `_ready()`、初始化完成回调、按钮回调或普通系统逻辑中调用。GF 会把 loading scene、缓存命中的目标场景和失败恢复都调度到安全帧执行，避免 Godot 在父节点仍处于添加/移除子节点阶段时报 `remove_child()` 时序错误。

即使命中预加载缓存，也不要依赖调用栈内立即完成场景切换；需要观察完成结果时监听 `scene_load_completed` / `scene_switch_completed`。在 headless 运行环境中，活动场景加载会自动改用同步资源解析作为降级路径，但仍沿用同一套 loading 状态、缓存写入、完成信号和安全切场流程，便于命令行启动链路和 CI 验证复用项目的标准场景路由。

## 场景历史

`GFSceneUtility` 会在成功切换后记录上一场景路径和参数，可通过 `get_scene_history()`、`pop_scene_history()`、`clear_scene_history()` 和 `load_previous_scene()` 实现通用返回上一个场景流程。历史只保存路径与参数，不保存节点实例或项目运行状态；需要恢复关卡内实体、UI 或玩家数据时仍应使用项目自己的 Model 或存档结构。
