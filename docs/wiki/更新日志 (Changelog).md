# 更新日志 (Changelog)

## 📝 日志条目结构标准

每次版本更新应包含以下核心模块（若无相关变动可省略该模块）：

1. **版本号与日期**：格式为 `## [主版本.次版本.修订号] - YYYY-MM-DD`
2. **版本概述**：简短描述该版本的核心目标（如：大型特性更新、紧急修复、性能重构等）。
3. **🚀 新增特性 (Added)**：新加入的类、方法、系统、扩展组件等。
4. **🔄 机制更改 (Changed)**：对现有功能逻辑的修改、内部重构、性能优化等。
5. **🐛 Bug 修复 (Fixed)**：修复的逻辑错误、内存泄漏、崩溃问题等。
6. **⚠️ 废弃与移除 (Deprecated/Removed)**：标记为废弃（将在未来移除）或本次直接移除的接口、文件。
7. **🔌 API 变动说明 (API Changes)**：极其重要。详细列出函数签名改变、属性重命名等直接导致旧代码报错的改动。
8. **📘 升级指南 (Migration Guide)**：为使用旧版本框架的开发者提供 Step-by-Step 的升级建议和兼容性处理方案。
9. **📁 核心受影响文件 (Affected Files)**：列出改动最大的核心源码文件，方便开发者进行二次开发比对。

---

## 维护策略

本页面只保留最近三个大版本线的更新记录，当前保留 `1.31.x`、`1.30.x` 与 `1.29.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

---

## [1.31.0] - 2026-05-09

**版本概述**：补强框架级运行时可观察性、资源所有权、UI 栈导航、配置访问器生成、网格算法、存储迁移和通知队列能力，保持 1.x 默认兼容语义。

### 🚀 新增特性 (Added)
- `GFAssetUtility` 新增 `GFAssetHandle` 资源句柄、路径引用计数、owner 批量释放、资源分组预加载/卸载和分组锁定缓存。
- `GFUIUtility` 新增面板打开/关闭/导航信号、层级替换、回退到指定面板、栈查询和诊断快照。
- `TypeEventSystem` 新增最大嵌套派发深度保护、可选派发追踪和追踪清理 API，并通过 `GFArchitecture` / `Gf` 提供配置与读取入口。
- `GFModel` / `GFSystem` / `GFUtility` 新增生命周期优先级；`GFSystem` / `GFUtility` 新增 tick 与 physics tick 优先级。
- `GFGridMath` 新增 A* 路径查找和 Flow Field 生成。
- 新增 `GFHexGridMath`，提供纯六边形坐标转换、邻居、范围、环、线段、视线、A*、Flow Field 和可达域算法。
- 新增 `GFConfigAccessGenerator`，可根据 `GFConfigTableSchema` 生成静态导表访问器源码。
- `GFLogUtility` 新增 trace id、全局上下文、日志值清洗和上次异常退出标记检测。
- `GFNotificationUtility` 新增通知优先级、sticky 通知、暂停/恢复和动作触发信号。
- `GFUIUtility` 新增面板 options、Modal 策略、取消请求和焦点约束辅助方法。
- `GFStorageUtility` 新增注册式版本迁移链；新增 `GFStorageBackend` 与 `GFStorageConflictReport` 作为远端/同步扩展点。

### 🔄 机制更改 (Changed)
- 架构初始化在同一 Model/System/Utility 注册表内按 `lifecycle_priority` 从高到低推进，释放时反向处理；默认值 `0` 保持原注册顺序。
- tick 缓存会按 `tick_priority` / `physics_tick_priority` 从高到低排序；默认值 `0` 保持原注册顺序。
- `GFAssetUtility.pin_cache()` 现在以引用计数形式管理锁定，重复 pin 需要对应次数 unpin。
- `GFNotificationUtility` 等待队列会按优先级调度；默认 `NORMAL` 优先级保持旧通知行为。
- `GFStorageUtility.migrate_data()` 会先执行已注册迁移链，再应用版本默认值；未注册迁移时保持旧默认迁移行为。

### 🔌 API 变动说明 (API Changes)
- 新增 API 均为向后兼容；旧 `load_async()`、`push_panel()`、`push_notification()`、事件监听、BFS/Grid 和存储调用保持有效。
- `GFAssetUtility.get_debug_snapshot()` 新增引用计数和分组数量字段。
- `TypeEventSystem.get_debug_stats()` 新增最大深度、追踪开关和追踪数量字段。
- `GFArchitecture.get_debug_lifecycle_state()` 的模块条目新增生命周期与 tick 优先级字段。
- `GFLogUtility` 结构化日志条目新增 `trace_id` 字段，`context` 会包含已清洗后的全局上下文与单条日志上下文。
- `GFUIUtility.get_debug_snapshot()` 的层级条目新增 `top_modal` 字段。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。只有存在明确依赖顺序或更新顺序需求时，才设置 `lifecycle_priority` / `tick_priority`；不要把业务流程顺序硬编码进框架基类。
- 资源句柄适合表达“调用方仍持有该路径资源”的所有权；临时加载仍可继续使用 `load_async()`。
- UI 新增方法只管理栈、状态信号和轻量面板策略，不替项目决定动画、输入路由、视觉层级或面板通信规则。
- 六边形、通知、存储后端和日志增强均为通用工具层能力；项目应在业务层定义地形、阵营、上传、同步冲突解决和 UI 表现。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/base/gf_model.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/base/gf_utility.gd`
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_asset_handle.gd`
- `addons/gf/utilities/gf_log_utility.gd`
- `addons/gf/utilities/gf_notification_utility.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_storage_backend.gd`
- `addons/gf/utilities/gf_storage_conflict_report.gd`
- `addons/gf/utilities/gf_ui_utility.gd`
- `addons/gf/foundation/math/gf_grid_math.gd`
- `addons/gf/foundation/math/gf_hex_grid_math.gd`
- `addons/gf/editor/gf_config_access_generator.gd`
- `tests/gf_core/**`
- `docs/wiki/**`

---

## [1.30.0] - 2026-05-08

**版本概述**：融合通用运行时工具增强，补齐信号链式操作、音频事件集合、任务队列、任务生命周期、交互检测桥接、场景后台激活和构建元数据辅助。

### 🚀 新增特性 (Added)
- 新增 `GFJob` 与 `GFJobQueueUtility`，提供通用等待/执行/完成/失败/取消任务状态、进度更新、队列暂停和调试快照。
- `GFSignalConnection` 新增 `throttle()`、`skip()`、`take()`、`first()`、`scan()` 与 `start_with()`；`GFSignalUtility` 新增 `connect_any()` 与 `disconnect_connections()`。
- `GFAudioClip` 新增候选权重和 pitch 随机范围；`GFAudioBank` 支持同一 ID 多候选、权重抽取与分层 ID 回退；`GFAudioUtility` 新增注册音频集合、事件式 BGM/环境音/SFX 播放和 2D/3D 空间 SFX 播放入口。
- `GFQuestUtility` 新增可用/接取/完成/取消生命周期、完成阻塞器、状态查询、任务报告和调试快照。
- `GFSceneUtility` 新增 `begin_background_scene_load()`、`activate_background_scene()` 与 `get_background_scene_params()`，用于后台预加载后延迟激活。
- `GFInteractionSensor` 新增 RayCast2D/RayCast3D/Area2D/Area3D 到交互接收器的通用桥接方法。
- `GFInputRemapConfig` 新增 `to_dict()`、`apply_dict()`、`from_dict()` 与 `duplicate_config()`，用于保存、恢复和复制运行时改键覆盖与显式解绑。
- `GFBuildInfo` 新增 `tag`、`commit_count`、`is_dirty` 字段，以及可选 Git 元数据采集和写入 ProjectSettings 的静态辅助方法。
- `GFSceneSignalAudit` 新增 `build_signal_graph(root, options)`，可生成运行中节点树的信号连接图快照。

### 🔄 机制更改 (Changed)
- `GFAudioUtility.play_*_from_bank()` 会使用 `GFAudioBank.get_clip_with_fallback()`，旧的单片段 bank 仍保持兼容。
- `GFSceneUtility.get_scene_cache_debug_snapshot()` 新增 `background.paths` 字段。

### 🔌 API 变动说明 (API Changes)
- 新增 API 均为向后兼容；旧调用保持有效。
- `GFBuildInfo.to_dict()` / `apply_dict()` 返回和读取的字典新增 `tag`、`commit_count` 与 `is_dirty` 字段。
- `GFInputRemapConfig.to_dict()` 输出的是适合持久化的覆盖字典，不会包含默认输入上下文绑定。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移；单片段 `GFAudioBank`、`start_quest()`、`load_scene_async()` 和现有 Signal 连接代码保持原语义。
- 需要保存改键时，把 `GFInputRemapConfig.to_dict()` 放进项目自己的设置或存档，再用 `from_dict()` 恢复。
- 新的任务队列只管理状态和报告，不会替项目取消外部线程、下载或长任务；取消语义应由业务处理器自行响应。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_signal_utility.gd`
- `addons/gf/utilities/gf_signal_connection.gd`
- `addons/gf/utilities/gf_audio_clip.gd`
- `addons/gf/utilities/gf_audio_bank.gd`
- `addons/gf/utilities/gf_audio_utility.gd`
- `addons/gf/utilities/gf_job.gd`
- `addons/gf/utilities/gf_job_queue_utility.gd`
- `addons/gf/utilities/gf_quest_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_build_info.gd`
- `addons/gf/input/gf_input_remap_config.gd`
- `addons/gf/extensions/interaction/gf_interaction_sensor.gd`
- `addons/gf/editor/gf_scene_signal_audit.gd`
- `tests/gf_core/**`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/12. 能力组件 (Capabilities).md`

---

## [1.29.0] - 2026-05-08

**版本概述**：增强纯代码状态机与节点状态机的通用性，补齐分层状态路径、事件分发、守卫和运行时快照能力。

### 🚀 新增特性 (Added)
- `GFStateMachine` 支持通过 `parent_state_name` 注册父子状态路径，并按最近公共祖先执行分层状态切换。
- `GFStateMachine` 新增进入/退出守卫、状态事件上抛、共享黑板、激活路径查询和调试快照。
- `GFNodeStateMachine` / `GFNodeStateGroup` / `GFNodeState` 新增状态事件分发、处理信号和运行时状态快照。

### 🔄 机制更改 (Changed)
- `GFStateMachine.update(delta)` 默认仍只更新当前叶子状态；传入 `include_ancestors = true` 时可按 root -> leaf 顺序更新整条激活路径。
- `GFNodeStateGroup` 的状态事件会先交给当前状态，再交给暂停栈中的状态，便于覆盖式状态把未处理事件交回下层状态。

### 🐛 Bug 修复 (Fixed)
- `GFCapabilityUtility.get_capability()` 会在查询时同步扫描 receiver 直属 GF 能力容器，修复旧场景或 Inspector 创建的 `GFCapabilityContainer2D` / `3D` / `Control` 仅保留容器标记或命名时，子能力在 receiver `_ready()` 中无法查询的问题。

### 🔌 API 变动说明 (API Changes)
- `GFStateMachine.add_state(state_name, state, parent_state_name = &"")` 新增可选父状态参数，旧二参调用保持兼容。
- 新增 `GFStateMachine.transition_blocked`、`state_event_handled`、`blackboard`、`set_state_parent()`、`dispatch_state_event()`、`get_state()`、`get_current_state()`、`has_state()`、`get_state_names()`、`get_parent_state_name()`、`get_active_state_path()`、`is_in_state()`、`get_blackboard()` 与 `get_state_snapshot()`。
- `GFStateMachine.update(delta, include_ancestors = false)` 新增可选参数，旧一参调用保持兼容。
- `GFState.setup(machine, state_name = &"")` 新增可选注册名参数；新增 `get_state_name()`、`can_enter()`、`can_exit()`、`handle_state_event()`、`dispatch_state_event()`、`get_parent_state_name()`、`is_in_state()` 与 `get_blackboard()`。
- 新增 `GFNodeState.handle_state_event()` 与 `_handle_state_event()`。
- 新增 `GFNodeStateGroup.state_event_handled`、`dispatch_state_event()` 与 `get_state_snapshot()`。
- 新增 `GFNodeStateMachine.state_event_handled`、`dispatch_state_event()` 与 `get_state_snapshot()`。

### 📘 升级指南 (Migration Guide)
- 旧状态机代码无需迁移；平铺状态注册和 `update(delta)` 的默认行为保持不变。
- 需要真正分层语义时，为子状态注册 `parent_state_name`，并把跨多个子状态共享的逻辑放入父状态的 `enter()` / `exit()` / `handle_state_event()`。
- 节点状态事件只负责分发和处理结果，不规定输入、动画、权限或业务效果；这些仍应由项目层状态脚本决定。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `addons/gf/extensions/state_machine/gf_state.gd`
- `addons/gf/extensions/state_machine/gf_node_state_machine.gd`
- `addons/gf/extensions/state_machine/gf_node_state_group.gd`
- `addons/gf/extensions/state_machine/gf_node_state.gd`
- `tests/gf_core/test_gf_state_machine.gd`
- `tests/gf_core/test_gf_node_state_machine.gd`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
