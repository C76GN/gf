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

本页面只保留最近三个大版本线的更新记录，当前保留 `1.32.x`、`1.31.x` 与 `1.30.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

---

## [1.32.0] - 2026-05-09

**版本概述**：补齐一组通用框架能力：槽位库存、反馈采样、任务消费、音频集合挂载、输入文本、构建导出、信号图索引、音频播放句柄、场景命中桥接和校验报告基础件，保持 1.x 兼容。

### 🚀 新增特性 (Added)
- 新增 `GFInventoryItemDefinition`、`GFInventoryItemRegistry`、`GFInventoryStack`、`GFInventoryOperationResult` 与 `GFSlotInventoryModel`，提供可选槽位库存、堆叠容量、实例数据兼容、移动/交换和序列化能力。
- 新增 `GFShakePreset`、`GFShakeUtility`、`GFShakeAction`、`GFShakeReceiver2D` 与 `GFShakeReceiver3D`，提供资源化反馈采样、命名 channel 播放、动作队列入口和 2D/3D 节点接收器。
- 新增 `GFJobWorker`，可作为场景节点按批次消费 `GFJobQueueUtility` 队列。
- 新增 `GFAudioBankMounter`，支持场景生命周期自动注册、恢复或卸载 `GFAudioBank`。
- 新增 `GFInputDeviceTextProvider`，为 Joypad 输入提供通用方位文本和 options 覆盖。
- 新增 `GFBuildInfoExportPlugin`，提供可选导出时 Git 构建元数据写入入口。
- 新增 `GFAudioEmitterHandle` 与 `GFAudioUtility` 的 SFX/空间音效 handle 播放方法，用于主动停止、淡出、owner 绑定释放和读取本次播放状态；空间音效播放入口新增可选声源跟随。
- 新增 `GFCombatHitContext`、`GFHitBox2D`、`GFHitBox3D`、`GFHurtBox2D` 与 `GFHurtBox3D`，提供通用 2D/3D 命中上下文收发桥接。
- 新增 `GFValidationIssue`、`GFValidationReport` 与 `GFValidationUtility`，提供通用校验问题、报告聚合、摘要统计和字典报告兼容辅助。
- `GFSceneSignalAudit` 新增运行时节点 DTO 与 `index_signal_graph()`，便于项目调试 UI 构建信号图索引。
- `GFSceneUtility` 新增 loading scene 错误回调方法名 `loading_screen_error_method`，默认调用 `show_error(message)`。

### 🔄 机制更改 (Changed)
- `GFInputFormatter` 的 Joypad 默认文本从泛化编号升级为通用方位/轴文本；项目仍可通过 provider 或 options 覆盖。
- GF 编辑器插件新增构建信息导出设置项，默认关闭自动写入，避免改变现有导出流程。
- `GFCapabilityRecipe.validate_recipe()` 改为通过通用校验报告基础件生成结果，保留原有字典字段并补齐空报告摘要。
- `GFSaveGraphUtility` 的诊断报告统计与下一步建议改为复用通用字典报告辅助，返回字段保持兼容。
- `GFGridMath` 连线访问状态、`GFGridOccupancy` 格子索引和 `GFSpatialHash3D` 空间桶索引改用坐标值 key，减少高频查询中的临时字符串分配，公开 API 保持不变。
- `TypeEventSystem` 类型派发缓存改为按受影响脚本类型局部失效，并缓存脚本继承链查询，降低动态监听注册/注销后的派发抖动。

### 🔌 API 变动说明 (API Changes)
- 新增 API 均为向后兼容；现有轻量 `GFInventoryModel`、`GFJobQueueUtility`、`GFAudioUtility`、`GFInputFormatter`、`GFCombatSystem`、`GFSceneUtility` 和字典式校验报告调用保持有效。
- `GFValidationIssue`、`GFValidationReport` 与 `GFValidationUtility` 是新增 Foundation API，不需要注册到 `Gf.register_utility()`。
- `GFAudioEmitterHandle` 新增 `bind_to_owner()`、`unbind_owner()`，调试快照新增 `owner_valid` 字段。
- `GFAudioUtility` 新增 `play_sfx_handle()`、`play_sfx_clip_handle()`、`play_sfx_from_bank_handle()`、`play_sfx_event_handle()`、`play_sfx_clip_2d_handle()`、`play_sfx_clip_3d_handle()`、`play_sfx_event_2d_handle()`、`play_sfx_event_3d_handle()` 与 `get_ambient_handle()`；2D/3D 空间 SFX 播放方法新增可选 `follow_source` 参数，默认 `false` 保持旧行为。
- `GFSceneSignalAudit.build_signal_graph()` 返回字典新增 `nodes` 字段。
- `GFSceneUtility` 新增公开变量 `loading_screen_error_method`。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。需要格子背包时新增 `GFSlotInventoryModel`，不要替换已有计数型 `GFInventoryModel`。
- 反馈采样只输出通用偏移；项目应自行决定目标节点、相机、UI 或 shader 的应用方式。
- 音频 handle 只控制本次播放器，旧的 fire-and-forget 播放方法无需迁移；空间 SFX 默认仍是当前位置一次性播放，只有显式传入 `follow_source = true` 时才跟随声源节点。
- Hit/HurtBox 只传递 `GFCombatHitContext` 和报告；项目仍应在业务层决定伤害、治疗、阵营、无敌帧或表现反馈。
- 自动构建元数据默认关闭；需要导出时写入 Git 字段时，在 Project Settings 中启用 `gf/build/export/write_git_metadata`。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/extensions/domain/**`
- `addons/gf/extensions/feedback/**`
- `addons/gf/extensions/combat/**`
- `addons/gf/foundation/validation/**`
- `addons/gf/foundation/math/gf_grid_math.gd`
- `addons/gf/foundation/math/gf_grid_occupancy.gd`
- `addons/gf/foundation/math/gf_spatial_hash_3d.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/extensions/capability/gf_capability_recipe.gd`
- `addons/gf/extensions/save/gf_save_graph_utility.gd`
- `addons/gf/utilities/gf_audio_emitter_handle.gd`
- `addons/gf/utilities/gf_job_worker.gd`
- `addons/gf/utilities/gf_audio_bank_mounter.gd`
- `addons/gf/input/gf_input_device_text_provider.gd`
- `addons/gf/editor/gf_build_info_export_plugin.gd`
- `addons/gf/editor/gf_scene_signal_audit.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `tests/gf_core/**`
- `docs/wiki/**`

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
