# 更新日志 (Changelog)

## 📝 日志条目结构标准

每次版本更新应包含以下核心模块（若无相关变动可省略该模块）：

1. **版本号与日期**：格式为 `## [主版本.次版本.修订号] - YYYY-MM-DD`
2. **版本概述**：简短描述该版本的核心目标（如：大型特性更新、紧急修复、性能重构等）。
3. **🚀 新增特性 (Added)**：新加入的类、方法、系统、扩展组件等。
4. **🔄 机制更改 (Changed)**：对现有功能逻辑的修改、内部重构、性能优化等。
5. **🐛 Bug 修复 (Fixed)**：修复的逻辑错误、内存泄漏、崩溃问题等。
6. **⚠️ 废弃与移除 (Deprecated/Removed)**：标记为废弃（将在未来移除）或本次直接移除的接口、文件。
7. **🔌 API 变动说明 (API Changes)**：详细列出函数签名改变、属性重命名等直接导致旧代码报错的改动。
8. **📘 升级指南 (Migration Guide)**：为使用旧版本框架的开发者提供 Step-by-Step 的升级建议和兼容性处理方案。
9. **📁 核心受影响文件 (Affected Files)**：列出改动最大的核心源码文件，方便开发者进行二次开发比对。

---

## 维护策略

正式文档中的更新日志只保留当前最新发布版本。发布新版本时，应将 `[未发布]` 合并为具体版本条目，并删除上一个正式版本条目；旧版本历史以 Git 历史和 GitHub Releases 为准，避免正式文档长期膨胀。

---

## [3.7.0] - 2026-05-14

**版本概述**：继续收敛 GF 编辑器工作区产品形态，补充输入映射、诊断快照和 SaveGraph 场景检查页面，保持页面能力抽象、只读优先，并延续扩展自声明接入方式。

### 🚀 新增特性

- GF Workspace 新增 Input Mapping 页面，可读取 `GFInputContext` 资源并展示动作、绑定、结构问题和重绑定冲突诊断。
- GF Workspace 新增 Diagnostics 页面，可采集性能、架构、工具监控、最近日志和可选场景树快照。
- Save 扩展新增 `editor_dock_paths` 工作区页面，用于查看当前场景的 `GFSaveScope` / `GFSaveSource` 健康报告，并可按需采集预览 payload 与 pipeline trace。
- `GFAudioUtility` 新增 `mount_audio_bank()` / `unmount_audio_bank()`，用于按栈管理同一 `bank_id` 的临时音频集合挂载。

### 🔄 机制更改

- 标准库的本地存档文件查看页面在工作区中命名为 Storage Viewer，用于和 Save 扩展的场景存档图页面区分职责。
- GF Workspace 页面入口统一使用短标签和稳定排序：标准库页面由记录声明，扩展页面由 manifest 声明，核心只负责按元数据装配。
- 输入映射、SaveGraph、诊断和节点状态机页面优化了空状态与默认详情内容，减少大面积空面板和重复提示。
- HTTP 响应、异步批处理、下载队列、网络反序列化、存储同步和 ActionQueue 取消语义收敛为明确终止契约，调用方不再需要通过空值或晚到信号推断状态。
- Singleton 工厂缓存实例在工厂替换、注销或架构销毁时会清理 owner 事件监听、调用 `dispose()`（如果存在）并释放依赖作用域，旧对象不再继续访问已失效的架构归属。
- Combat 发射器的对象池依赖改为显式赋值、架构注入或 `GFNodeContext` 局部上下文查询，不再从扩展运行时代码直接访问全局 `Gf`。
- 扩展启用状态解析只保留当前可发现的 manifest ID，项目设置中残留的未知扩展 ID 会进入诊断报告，但不会混入最终启用集合或保存结果。
- `GFAudioBankMounter` 改为使用音频集合挂载栈，多个场景或 UI 交错挂载同一 `bank_id` 时，下层卸载不再覆盖仍处于顶层的音频集合。
- `GFCommandSequence.cancel()` 会通知当前步骤的取消入口，再停止等待与后续步骤。
- `GFRequestOutboxUtility.replay()` 会等待 `transport_callback` 返回的 Signal，再根据异步结果移除、重试或归档请求。
- `GFJobWorker` 会把异步 processor 的 Signal 结果按同步返回值同样写回任务完成或失败状态。
- `GFRemoteCacheUtility` 缓存写入改为临时文件提交，避免刷新中断时污染已有缓存内容。
- `GFVariantJsonCodec` 类型化 JSON 标记改为专用 `__gf_variant__` wrapper，避免普通业务字典中的 `type` / `value` 类字段被误判为 Godot 类型。
- `GFNodeStateMachine` / `GFNodeStateGroup` 的运行时子节点重载只响应状态结构节点，普通辅助节点可以安全挂在状态机或状态组下。
- `GFAsyncWaitSupport` 会按 Signal 定义忽略等待载荷参数，命令序列、Flow 运行器和 Action Queue 不再受固定参数数量限制。
- `GFNodeContext` 的 `INHERITED` 模式会在继承架构 ready 后发出 `context_ready`，与 `SCOPED` 模式保持一致的就绪信号语义。
- `GFTypeEventSystem` 会拒绝空 `StringName` 简单事件 ID，避免无名事件通道进入正式运行时。
- `GFBindableProperty.unbind_all()` 语义收敛为只清理 `bind_to()` 创建的节点绑定；清空所有订阅者需显式调用 `disconnect_all_subscribers()`。

### 🐛 Bug 修复

- 修复 Input Mapping 页面未加载资源时顶部摘要和正文提示重复的问题。
- 修复 `GFSignalConnection.debounce()` 在部分测试调度时可能晚一帧触发，导致防抖结果不稳定的问题。
- 修复 `GFHttpResponse.cancel()` 只修改状态但不取消底层请求、且晚到响应仍可能覆盖状态的问题。
- 修复 `GFAsyncBatch.clear()` 后仍可能被旧响应回调完成的问题。
- 修复 `GFDownloadUtility` 在目标文件已存在且禁止覆盖时，未校验 `expected_sha256` 就直接视为成功的问题。
- 修复 `GFStorageSyncUtility` 未解决冲突仍通过完成信号报告，导致调用方难以区分冲突与成功的问题。
- 修复 `GFWaitAction` 取消后可能被误判为正常完成的问题，并收敛动作组和 Tween 类动作取消时的等待状态。
- 修复 Singleton 工厂缓存节点已释放后再次解析时，清理旧缓存实例可能触发类型绑定错误的问题。
- 修复 Singleton 工厂缓存实例释放时未调用自身 `dispose()` 且 owner 事件监听可能残留的问题。
- 修复 `GFAudioUtility` 未注册 `GFObjectPoolUtility` 时直接跳过 SFX 播放的问题，现在会回退到普通播放器。
- 修复移动与闪色动作在属性或目标值类型不匹配时可能把错误推迟到 Tween 执行阶段的问题。
- 修复 `GFVariantJsonCodec` 解码普通字典时，遇到保留字段组合可能错误恢复为 typed Variant 的问题。
- 修复运行时向节点状态机或状态组添加普通辅助子节点时，当前状态被重复退出、初始化和进入的问题。
- 修复等待携带 5 个及以上参数的 Signal 时，通用等待工具可能无法恢复执行的问题。
- 修复 `GFNodeContext` 继承已存在或稍后 ready 的父级架构时，监听者可能收不到 `context_ready` 的问题。
- 修复简单事件可以注册或发送空事件 ID，导致事件语义不可追踪的问题。
- 修复 `GFBindableProperty.unbind_all()` 可能误断开业务层直接订阅的问题。

### ⚠️ 废弃与移除

- 移除 `GFNetworkSerializer.deserialize_dictionary()` 的模糊空字典返回入口；字典解码统一使用 `deserialize_dictionary_result()`。

### 🔌 API 变动说明

- `GFExtensionManifest` 新增 `editor_dock_order` 与 `editor_dock_short_label`，用于扩展声明 GF Workspace 页面排序和短标签；不影响运行时装配。
- `GFHttpResponse` 新增 `cancel_callback`，请求构建器会通过它取消底层 `HTTPRequest` 并释放节点。
- `GFNetworkSerializer` 新增 `deserialize_dictionary_result()` 与 `deserialize_message_result()`，结果字典包含 `ok`、`data` 和 `error`。
- `GFStorageSyncUtility` 新增 `sync_conflict_unresolved(file_name, result)`，用于报告未解决冲突的终止状态。
- `GFProjectileEmitter2D` / `GFProjectileEmitter3D` 新增 `object_pool_utility` 与 `inject_dependencies(architecture)`，用于显式提供对象池依赖。
- `GFAutoload` 新增 `get_ready_architecture_or_null()` 与 `get_ready_architecture()`，用于区分“全局架构实例存在”和“架构已完成初始化”。
- `GFAudioUtility` 新增 `mount_audio_bank(bank_id, bank, restore_previous_bank)` 与 `unmount_audio_bank(bank_id, mount_token)`，`GFAudioBankMounter` 会使用返回的挂载令牌卸载对应层。
- `GFSequenceStep` 新增 `cancel(context)` 钩子，用于释放当前步骤持有的等待、动画或请求资源。
- `GFVariantJsonCodec.JSON_TYPE_KEY` 改为新 wrapper 内部的 `type` 字段，并新增 `JSON_MARKER_KEY`、`JSON_VERSION_KEY` 与 `JSON_SCHEMA_VERSION`。
- `GFBinding` 新增 `dispose_cached_instance()`，用于释放 Singleton 工厂缓存实例的生命周期归属。
- `GFBindableProperty` 新增 `unbind_all_node_bindings()` 与 `disconnect_all_subscribers()`，用于区分节点绑定清理和全订阅者断开。
- `GFReactiveEffect` / `GFComputedProperty` 新增 `dispose()`，等价于停止当前响应式监听。

### 📘 升级指南

- 如果项目直接调用 `GFNetworkSerializer.deserialize_dictionary(bytes)`，改为 `deserialize_dictionary_result(bytes)`，并先判断 `ok` 后再读取 `data`；失败原因从 `error` 读取。
- 如果项目监听 `GFStorageSyncUtility.sync_completed` 处理所有同步结束，现在应额外监听 `sync_conflict_unresolved`，把未解决冲突交给人工流程或项目自定义 resolver。
- 如果自定义 `GFVisualAction.cancel()` 持有可等待 Signal，不要把取消伪装成正常完成；队列会用取消令牌停止当前等待。只有确实希望外部 await 调用被立即唤醒的自定义动作，才应提供独立的取消或 settled 信号。
- 如果项目长期持有 `GFArchitecture` singleton 工厂创建的对象，请在工厂替换、注销或架构销毁后停止使用该对象访问框架依赖；缓存实例如果实现了 `dispose()`，该方法会随工厂归属释放一起执行。需要完整生命周期的对象应注册为 Model、System 或 Utility。
- 如果项目启用了发射器的 `use_object_pool`，请确保显式设置 `object_pool_utility`，或在生成前通过架构/`GFNodeContext` 注入可用的 `GFObjectPoolUtility`。
- 如果项目调用 `GFRequestOutboxUtility.replay()`，建议统一使用 `await` 获取重放报告；transport 可以同步返回结果，也可以返回会发出结果值的 Signal。
- 如果项目手写或持久化了旧的 `_gf_type` / `value` typed JSON 标记，请重新通过 `GFVariantJsonCodec.variant_to_json_compatible()` 生成数据；新的解码器只识别专用 `__gf_variant__` wrapper。
- 如果项目设置里存在已经不存在的扩展 ID，可在 GF Workspace 的 Extensions 页面重新保存设置，或调用 `GFExtensionSettings.set_enabled_extension_ids()` 写回当前有效选择。
- 如果项目曾用 `GFBindableProperty.unbind_all()` 断开所有 `value_changed` 订阅，请改用 `disconnect_all_subscribers()`；`unbind_all()` 现在只清理由 `bind_to()` 创建的节点生命周期绑定。

### 📁 核心受影响文件

- `addons/gf/kernel/editor/gf_plugin_dock_tools.gd`
- `addons/gf/standard/editor/gf_standard_editor_extensions.gd`
- `addons/gf/standard/input/editor/gf_input_mapping_dock.gd`
- `addons/gf/standard/utilities/debug/editor/gf_diagnostics_dock.gd`
- `addons/gf/standard/utilities/signals/gf_signal_connection.gd`
- `addons/gf/extensions/save/editor/gf_save_graph_dock.gd`
- `addons/gf/extensions/flow/gf_extension.json`
- `addons/gf/extensions/save/gf_extension.json`
- `addons/gf/kernel/editor/gf_editor_workspace_dock.gd`
- `addons/gf/kernel/extension/gf_extension_manifest.gd`
- `addons/gf/standard/utilities/io/gf_http_response.gd`
- `addons/gf/standard/utilities/io/gf_http_request_builder.gd`
- `addons/gf/standard/utilities/io/gf_async_batch.gd`
- `addons/gf/standard/utilities/io/gf_download_utility.gd`
- `addons/gf/standard/utilities/io/gf_request_outbox_utility.gd`
- `addons/gf/standard/utilities/io/gf_remote_cache_utility.gd`
- `addons/gf/standard/utilities/jobs/gf_job_worker.gd`
- `addons/gf/standard/utilities/storage/gf_storage_sync_utility.gd`
- `addons/gf/extensions/network/serialization/gf_network_serializer.gd`
- `addons/gf/extensions/network/runtime/gf_network_utility.gd`
- `addons/gf/kernel/core/gf_autoload.gd`
- `addons/gf/kernel/core/gf_architecture.gd`
- `addons/gf/kernel/core/gf_binding.gd`
- `addons/gf/kernel/core/gf_node_context.gd`
- `addons/gf/kernel/core/gf_type_event_system.gd`
- `addons/gf/kernel/core/gf_bindable_property.gd`
- `addons/gf/kernel/core/gf_reactive_effect.gd`
- `addons/gf/kernel/core/gf_computed_property.gd`
- `addons/gf/standard/utilities/audio/gf_audio_utility.gd`
- `addons/gf/standard/utilities/audio/gf_audio_bank_mounter.gd`
- `addons/gf/standard/sequence/gf_command_sequence.gd`
- `addons/gf/standard/sequence/gf_sequence_step.gd`
- `addons/gf/standard/foundation/variant/gf_variant_json_codec.gd`
- `addons/gf/standard/common/gf_async_wait_support.gd`
- `addons/gf/standard/state_machine/node/gf_node_state_machine.gd`
- `addons/gf/standard/state_machine/node/gf_node_state_group.gd`
- `addons/gf/extensions/action_queue/actions/gf_visual_action_group.gd`
- `addons/gf/extensions/action_queue/actions/gf_wait_action.gd`
- `addons/gf/extensions/action_queue/actions/gf_configured_tween_action.gd`
- `addons/gf/extensions/action_queue/actions/gf_move_tween_action.gd`
- `addons/gf/extensions/action_queue/actions/gf_flash_action.gd`
- `addons/gf/extensions/combat/projectiles/gf_projectile_emitter_2d.gd`
- `addons/gf/extensions/combat/projectiles/gf_projectile_emitter_3d.gd`
- `addons/gf/kernel/extension/gf_extension_settings.gd`
- `docs/zh/editor/index.md`
- `docs/zh/kernel/index.md`
- `docs/zh/kernel/lifecycle/index.md`
- `docs/zh/kernel/messaging/events.md`
- `docs/zh/kernel/scene-controller/index.md`
- `docs/zh/extensions/index.md`
- `docs/zh/standard/input-flow/input-assist.md`
- `docs/zh/standard/utilities/io/assets-jobs-warmup.md`
- `docs/zh/standard/utilities/io/config-remote-outbox.md`
- `docs/zh/standard/utilities/io/storage-snapshot.md`
- `docs/zh/standard/input-flow/command-sequence.md`
- `docs/zh/standard/foundation/data-validation.md`
- `docs/zh/standard/input-flow/state-machines.md`
- `docs/zh/extensions/flow-domain-physics/index.md`
- `docs/zh/standard/utilities/runtime/debug-observability.md`
- `docs/zh/extensions/network-turnbased/index.md`
- `docs/zh/extensions/action-queue/index.md`
- `docs/zh/extensions/combat/index.md`
- `docs/zh/extensions/save-graph/index.md`
- `docs/zh/standard/utilities/runtime/audio.md`
- `tests/gf_core/kernel/editor/test_gf_plugin_helpers.gd`
- `tests/gf_core/kernel/extension/test_gf_extension_manifest.gd`
- `tests/gf_core/kernel/core/test_gf_singleton.gd`
- `tests/gf_core/kernel/core/test_gf_type_event_system.gd`
- `tests/gf_core/kernel/core/test_gf_bindable_property.gd`
- `tests/gf_core/standard/utilities/io/test_gf_http_request_builder.gd`
- `tests/gf_core/standard/utilities/io/test_gf_download_utility.gd`
- `tests/gf_core/standard/utilities/io/test_gf_request_outbox_utility.gd`
- `tests/gf_core/standard/utilities/io/test_gf_remote_cache_utility.gd`
- `tests/gf_core/standard/utilities/jobs/test_gf_job_queue_utility.gd`
- `tests/gf_core/standard/utilities/audio/test_gf_audio_utility.gd`
- `tests/gf_core/standard/sequence/test_gf_command_sequence.gd`
- `tests/gf_core/standard/foundation/variant/test_gf_variant_data_and_json_codec.gd`
- `tests/gf_core/standard/state_machine/node/test_gf_node_state_machine.gd`
- `tests/gf_core/standard/utilities/storage/test_gf_storage_sync_utility.gd`
- `tests/gf_core/extensions/network/test_gf_network_extension.gd`
- `tests/gf_core/extensions/action_queue/test_gf_visual_actions.gd`
- `tests/gf_core/extensions/combat/test_gf_projectiles.gd`
- `tests/gf_core/maintenance/test_layer_boundary_validation.gd`
- `tests/gf_core/standard/input/editor/test_gf_input_mapping_dock.gd`
- `tests/gf_core/standard/utilities/signals/test_gf_signal_utility.gd`
