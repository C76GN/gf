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

本页面只保留最近三个大版本线的更新记录，当前保留 `1.25.x`、`1.24.x` 与 `1.23.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

---

## [1.26.0] - 2026-05-08

**版本概述**：补齐通用导表校验、文件下载、运行时工具快照与开发期资源表格能力，保持框架抽象边界，不引入具体业务规则。

### 🚀 新增特性 (Added)
- **导表结构声明与导入校验**：新增 `GFConfigTableColumn`、`GFConfigTableSchema` 与 `GFConfigTableImporter`，支持 JSON/CSV 解析、字段类型校验、必填/空值检查、默认值转换和统一 issue 报告。
- **ConfigProvider Schema 注册**：`GFConfigProvider` 新增 schema 注册、查询、校验和记录转换入口，子类仍可保持原有 `get_record()` / `get_table()` 适配方式。
- **通用文件下载队列**：新增 `GFDownloadTask` 与 `GFDownloadUtility`，支持顺序下载、临时文件提交、可选续传、SHA-256 校验、暂停、取消、结果缓存和诊断快照。
- **定时器调度增强**：`GFTimerUtility` 新增重复任务、owner 绑定任务、owner 批量取消和 debug snapshot。
- **运行时工具快照**：`GFAssetUtility`、`GFRemoteCacheUtility`、`GFActionQueueSystem` 新增 `get_debug_snapshot()`，`GFDiagnosticsUtility` 新增工具快照聚合、`diagnostics.tools` 命令和 `tools` 监控预设。
- **事件系统派发统计**：`TypeEventSystem.get_debug_stats()` 新增派发次数、当前派发深度和历史最大嵌套深度。
- **开发期资源表格控件**：新增 `GFEditorValueField` 与 `GFResourceTableEditor`，用于通用 Resource 属性输入、扫描、列推导和单元格提交。

### 🔄 机制更改 (Changed)
- `GFTimerUtility.cancel()` 现在可在重复任务回调执行期间取消当前句柄，避免回调结束后再次排入队列。
- `GFDiagnosticsUtility.collect_snapshot()` 的结果新增 `tools` 字段；未注册对应工具时自动跳过，不影响旧调用。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFConfigTableColumn`、`GFConfigTableSchema`、`GFConfigTableImporter`。
- 新增 `GFDownloadTask`、`GFDownloadUtility`。
- 新增 `GFEditorValueField`、`GFResourceTableEditor`。
- `GFConfigProvider` 新增 `register_schema()`、`unregister_schema()`、`has_schema()`、`get_schema()`、`get_schema_ids()`、`validate_record()`、`validate_table()` 与 `coerce_record()`。
- `GFTimerUtility` 新增 `execute_after_owned()`、`execute_repeating()`、`execute_repeating_owned()`、`cancel_owner()` 与 `get_debug_snapshot()`。
- `GFDiagnosticsUtility` 新增内置命令 `diagnostics.tools`，`collect_snapshot()` 返回值新增 `tools` 字段，内置监控预设新增 `tools`。
- `GFAssetUtility`、`GFRemoteCacheUtility`、`GFActionQueueSystem` 新增 `get_debug_snapshot()`。
- `TypeEventSystem.get_debug_stats()` 返回值新增派发统计字段。

### 📘 升级指南 (Migration Guide)
- 旧项目不需要迁移；所有新增能力均为向后兼容 API。需要导表校验时，先用 `GFConfigTableSchema` 描述结构，再在现有 `GFConfigProvider` 子类初始化阶段注册 schema。
- 需要下载文件时优先使用 `GFDownloadUtility`；只拉取远程文本或 JSON 并复用 TTL 缓存时继续使用 `GFRemoteCacheUtility`。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_config_provider.gd`
- `addons/gf/utilities/gf_timer_utility.gd`
- `addons/gf/utilities/gf_diagnostics_utility.gd`
- `addons/gf/utilities/gf_download_utility.gd`
- `addons/gf/editor/gf_resource_table_editor.gd`
- `tests/gf_core/**`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`

---

## [1.25.0] - 2026-05-08

**版本概述**：增强运行时调试、日志、本地多人输入、场景切换、存档图健康检查、流程图编辑器辅助、能力组合与开发期维护基础设施，在保持旧调用兼容的前提下，为常用框架能力补充更通用的验证、监控和组合入口。

### 🚀 新增特性 (Added)
- **结构化日志上下文**：`GFLogUtility` 各等级日志方法和 `log()` 可附加 `Dictionary` 上下文，日志条目会保留 `context`、`level_name`、`text`、时间戳等结构化字段。
- **日志 Sink 扩展点**：新增 `GFLogSink` 基类，项目可通过 `add_sink()` 接入 JSONL、编辑器面板、本地诊断或其他自定义采集目标。
- **JSONL 日志 Sink**：新增 `GFJsonLineLogSink`，可把结构化日志条目写入一行一个 JSON 对象的本地文件，便于测试、诊断工具和离线分析读取。
- **结构化日志信号**：`GFLogUtility` 新增 `log_entry_emitted(entry)`，在保留 `log_emitted(level, tag, message)` 的同时广播完整条目。
- **控制台窗口模式**：`GFConsoleUtility` 新增可配置窗口模式，支持拖拽、缩放、背景透明度、初始尺寸比例、最小尺寸、层级和 debug-only 创建策略。
- **调试覆盖层 Watch**：`GFDebugOverlayUtility` 新增通用运行时 watch API，可显示项目主动推送或由 provider 拉取的小型调试值，不要求这些值进入 `GFModel`。
- **诊断监控注册表**：`GFDiagnosticsUtility` 新增 monitor / preset 机制，可采集内置性能、架构和项目自定义监控项，并导出 JSON、文本或 CSV。
- **存档图健康报告**：`GFSaveGraphUtility.inspect_scope()` 与 `validate_payload_for_scope()` 报告新增健康摘要、错误/警告计数、issue 统计和 `next_action`，并提供 `build_scope_health_report()` / `build_payload_health_report()` 语义入口。
- **场景缓存分层与 Loading 协议**：`GFSceneUtility` 支持固定预加载缓存、场景资源信息快照、加载进度查询、切换流程信号和 loading scene 可选 `fade_in` / `fade_out` / `set_progress` / `update_progress` 协议。
- **流程图编辑器辅助**：`GFFlowNode` 新增显示名、分类和编辑器布局元数据，`GFFlowGraph` 新增编辑器目录、编辑器报告和 Inspector 校验辅助。
- **能力组合 Recipe**：新增 `GFCapabilityRecipe` 与 `GFCapabilityRecipeEntry`，`GFCapabilityUtility` 可按 Recipe 批量应用或移除能力和分组。
- **输入配置 Profile Bank**：新增 `GFInputProfileBank`，用于保存、切换和复制多个命名 `GFInputRemapConfig`，不绑定账号、UI、存档槽或玩家业务语义。
- **本地加入输入与手柄反馈**：`GFInputDeviceUtility` 新增 join 输入模板、玩家加入请求信号，以及按玩家席位转发手柄震动的薄封装。
- **场景信号连接审计**：新增 `GFSceneSignalAudit`，可在开发期扫描 `.tscn` 中保存的编辑器信号连接，报告缺失节点、缺失信号、缺失方法和参数数量不匹配。

### 🔄 机制更改 (Changed)
- **日志输出链路统一**：低于 `min_level` 或被 tag 静音的日志不会写文件、进入内存缓存、写入 sink 或发出日志信号；`*_lazy()` 现在也会延迟构造可选上下文。
- **控制台默认兼容**：`GFConsoleUtility.windowed` 默认仍为 `false`，保持原全屏覆盖行为；只有显式启用时才使用窗口面板。
- **输入扩展保持 opt-in**：join 输入默认不启用，只有项目填充 `join_events` 或调用 `configure_default_join_events()` 后才会响应加入请求。
- **Debug Overlay 可消费诊断预设**：注册 `GFDiagnosticsUtility` 时，Debug Overlay 默认合并显示 `overlay` 监控预设；项目可切换预设或关闭该行为。
- **表面材质查询轻量化**：`GFSurfaceUtility` 优先从 Mesh surface arrays 统计面数，减少材质查询前的几何分析开销，并保留兼容回退路径。

### 🐛 Bug 修复 (Fixed)
- **Debug Overlay 兼容性**：改用内部 BBCode 转义逻辑，避免 Godot 4.6 中缺失 `String.escape_bbcode()` 导致脚本解析失败，并在释放时先停用 overlay 回调，避免销毁期间访问已释放架构。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFLogSink`。
- 新增 `GFJsonLineLogSink`。
- 新增 `GFInputProfileBank`。
- 新增 `GFSceneSignalAudit`。
- 新增 `GFCapabilityRecipe`。
- 新增 `GFCapabilityRecipeEntry`。
- `GFJsonLineLogSink` 提供 `file_path`、`omit_formatted_text`、`flush_interval_msec`、`flush_immediately`、`max_jsonl_files` 与 `get_file_path()`。
- `GFInputProfileBank` 提供 `set_profile()`、`ensure_profile()`、`get_profile()`、`has_profile()`、`remove_profile()`、`get_profile_ids()`、`clear_profiles()`、`set_active_profile()`、`get_active_profile()` 与 `duplicate_bank()`。
- `GFSceneSignalAudit` 提供 `audit_directory()`、`audit_scene_paths()`、`audit_scene()` 与 `collect_scene_paths()`。
- 新增 `GFLogUtility.log_entry_emitted(entry: Dictionary)`。
- 新增 `GFLogUtility.add_sink(sink)`、`remove_sink(sink, shutdown := true)`、`clear_sinks(shutdown := true)`、`get_sinks()`、`flush_sinks()`、`get_log_file_path()`。
- `GFLogUtility.debug/info/warn/error/fatal/log()` 新增可选 `context: Dictionary = {}` 参数；旧调用保持可用。
- `GFLogUtility.*_lazy()` 新增可选 `context_builder: Callable = Callable()` 参数；旧调用保持可用。
- 新增 `GFConsoleUtility.background_alpha`、`windowed`、`initial_window_size_ratio`、`minimum_window_size`、`keep_topmost`、`debug_only`。
- 新增 `GFDebugOverlayUtility.watch_value()`、`push_watch_value()`、`remove_watch()`、`clear_watches()`、`has_watch()` 与 `get_watch_snapshot()`。
- 新增 `GFDebugOverlayUtility.include_diagnostics_monitors`、`diagnostics_monitor_preset` 与 `set_diagnostics_monitor_preset()`。
- 新增 `GFDiagnosticsUtility.monitor_sampled`、`register_monitor()`、`unregister_monitor()`、`has_monitor()`、`get_monitor_catalog()`、`register_monitor_preset()`、`unregister_monitor_preset()`、`has_monitor_preset()`、`get_monitor_preset_ids()`、`collect_monitor_snapshot()`、`collect_monitor_preset()` 与 `export_monitor_snapshot()`。
- 新增 `GFSaveGraphUtility.build_scope_health_report()` 与 `build_payload_health_report()`；`inspect_scope()` / `validate_payload_for_scope()` 返回值新增 `healthy`、`error_count`、`warning_count`、`issue_counts_by_kind`、`summary`、`next_action`。
- 新增 `GFSceneUtility.scene_switch_started`、`scene_switch_completed`、`scene_switch_failed`、`loading_scene_shown`、`loading_scene_hidden`、`scene_cache_added`、`scene_cache_removed`。
- `GFSceneUtility.preload_scene()`、`preload_scenes()`、`put_preloaded_scene()`、`clear_preloaded_scenes()` 新增兼容可选参数；新增 `move_preloaded_scene_to_fixed()`、`move_preloaded_scene_to_temporary()`、`is_preloaded_scene_fixed()`、`get_loading_progress()` 与 `get_scene_resource_info()`。
- 新增 `GFSceneTransitionConfig.preload_as_fixed_cache`。
- 新增 `GFFlowNode.display_name`、`category`、`editor_position`、`editor_size`、`editor_collapsed`、`get_display_name()` 与 `describe_editor()`。
- 新增 `GFFlowGraph.editor_groups`、`editor_metadata`、`set_node_editor_position()`、`set_node_editor_layout()`、`get_editor_catalog()` 与 `build_editor_report()`。
- 新增 `GFCapabilityUtility.apply_recipe()` 与 `remove_recipe()`。
- 新增 `GFInputDeviceUtility.player_join_requested(player_index, assignment, event)`。
- 新增 `GFInputDeviceUtility.join_events` 与 `auto_assign_devices_on_join`。
- 新增 `GFInputDeviceUtility.handle_join_input_event()`、`is_join_input_event()`、`configure_default_join_events()`、`clear_join_events()`、`start_vibration_for_player()` 与 `stop_vibration_for_player()`。
- 无破坏性函数签名变更。

### 📘 升级指南 (Migration Guide)
1. 旧日志调用无需修改；需要结构化字段时，把上下文作为最后一个参数传入即可。
2. 自定义日志 sink 应继承 `GFLogSink`，并把 sink 视为输出目标，不要在 sink 内反向持有业务生命周期。
3. 控制台仍默认全屏；需要边运行边观察时设置 `windowed = true`，发布构建可按项目策略设置 `debug_only = true` 或不注册该工具。
4. Debug Overlay 仍会反射已注册 `GFModel`；项目只在需要观察非 Model 临时值时额外注册 watch，避免把业务字段或敏感信息默认暴露到覆盖层。
5. 需要更稳定的运行时调试面板时，优先把通用指标注册为 `GFDiagnosticsUtility` monitor，再让 Overlay、控制台或编辑器工具按预设消费；不要把一次性业务字段硬塞进框架内置 monitor。
6. 需要多套输入重映射配置时，可把现有 `GFInputRemapConfig` 放入 `GFInputProfileBank`；旧的单配置调用方式保持可用。
7. 本地多人加入流程应显式配置 join 输入模板，并在收到 `player_join_requested` 后由项目层决定 UI、角色、队伍或出生点。
8. `GFSceneSignalAudit` 和 SaveGraph 当前场景校验都是可选开发期工具，不需要注册到 `GFArchitecture`；项目可在 CI、编辑器按钮或维护脚本中按需调用。
9. 需要实体能力预设时，用 `GFCapabilityRecipe` 描述组合结构，把具体数值、目标规则和表现逻辑继续放在项目能力资源或项目系统中。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_log_sink.gd`
- `addons/gf/utilities/gf_json_line_log_sink.gd`
- `addons/gf/utilities/gf_log_utility.gd`
- `addons/gf/utilities/gf_console_utility.gd`
- `addons/gf/utilities/gf_debug_overlay_utility.gd`
- `addons/gf/utilities/gf_diagnostics_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_scene_transition_config.gd`
- `addons/gf/extensions/save/gf_save_graph_utility.gd`
- `addons/gf/extensions/flow/gf_flow_node.gd`
- `addons/gf/extensions/flow/gf_flow_graph.gd`
- `addons/gf/extensions/capability/gf_capability_recipe.gd`
- `addons/gf/extensions/capability/gf_capability_recipe_entry.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/editor/gf_flow_graph_inspector_plugin.gd`
- `addons/gf/utilities/gf_input_device_utility.gd`
- `addons/gf/utilities/gf_surface_utility.gd`
- `addons/gf/input/gf_input_profile_bank.gd`
- `addons/gf/editor/gf_scene_signal_audit.gd`
- `tests/gf_core/test_gf_log_utility.gd`
- `tests/gf_core/test_gf_console_utility.gd`
- `tests/gf_core/test_gf_debug_overlay_utility.gd`
- `tests/gf_core/test_gf_diagnostics_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `tests/gf_core/test_gf_save_graph_utility.gd`
- `tests/gf_core/test_gf_flow_graph.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `tests/gf_core/test_gf_input_device_utility.gd`
- `tests/gf_core/test_gf_surface_utility.gd`
- `tests/gf_core/test_gf_input_profile_bank.gd`
- `tests/gf_core/test_gf_scene_signal_audit.gd`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/12. 能力组件 (Capabilities).md`
- `docs/wiki/01. 架构概览 (Architecture).md`
- `docs/wiki/更新日志 (Changelog).md`

---

## [1.24.0] - 2026-05-07

**版本概述**：收敛事件、命令、查询、规则和撤销历史的边界说明，增强 Command / Query 误用诊断，并加固 Utility 工具箱中的存储、音频、场景瞬态清理、定时器和 UI 入栈行为。

### 🚀 新增特性 (Added)
- **严格 checksum 缺失校验**：`GFStorageCodec` / `GFStorageUtility` 新增 `require_integrity_checksum`，可在启用完整性校验时把缺少 `_meta.checksum` 的旧载荷视为失败。
- **可取消逻辑定时器**：`GFTimerUtility.execute_after()` 现在会为排队任务返回句柄，新增 `cancel(handle)` 取消尚未触发的延迟回调。
- **实例面板配置回调**：`GFUIUtility.push_panel_instance()` 新增可选 `config_callback`，与同步/异步场景入栈接口保持一致。

### 🔄 机制更改 (Changed)
- **Command / Query 误用诊断**：`GFArchitecture.send_command()` 与 `send_query()` 收到缺少 `execute()` 方法的对象时会输出 warning 并继续返回 `null`，避免错误对象被静默忽略。
- **Storage dispose 完成通知**：`GFStorageUtility.dispose()` 会等待已启动的异步任务并发出对应完成信号，对尚未开始的队列任务发出失败结果，避免等待方悬挂。
- **音频总线静音语义**：`GFAudioUtility.set_bus_volume(bus, 0.0)` 会真正 mute 总线，`get_bus_volume()` 对 mute 总线返回 `0.0`。

### 📚 文档 (Docs)
- **事件边界说明**：修正 Simple Event 可携带 `Variant` payload、Type Event 推荐而非强制继承 `GFPayload`、`is_consumed` 字段约定、同步监听器和 exact / assignable 重复监听语义。
- **Command / Query / Rule 约定**：明确 Command 不提供事务、自动回滚或幂等保护，Query 只读性由项目规范保证，`GFRule.validate()` 不会自动执行且 `GFRule` 不参与架构注入。
- **撤销历史限制**：补充 `GFUndoableCommand.set_snapshot()` 对对象引用快照的限制，以及 `GFCommandHistoryUtility` 异步超时不会取消已开始副作用的说明。
- **Utility 边界说明**：补充 Asset / Scene 取消不等于中止 Godot 线程请求、Signal 参数上限、Storage 绝对路径兼容默认、Debug Overlay 敏感字段风险、Analytics shutdown 尽力 flush 和同步 transport hook 约定。
- **数据绑定说明**：明确普通 `BindableProperty` 不阻止外部写入，推荐对外暴露只读视图，并补充引用值原地变更需要 `force_emit()` 或重新 `set_value()` 的边界。

### 🐛 Bug 修复 (Fixed)
- **瞬态 Utility 未清理**：`GFSceneUtility.cleanup_transients()` 现在会同时注销标记为 transient 的 `GFUtility`，不再只处理 System / Model。
- **空 BGM 路径忽略淡出参数**：`GFAudioUtility.play_bgm("", crossfade_seconds)` 现在会按传入淡出时长停止当前 BGM。
- **对象池注释误导**：修正 `GFObjectPoolUtility.acquire()` 参数说明，明确释放节点会移动到内部池根节点。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFStorageCodec.require_integrity_checksum: bool`。
- 新增 `GFStorageCodec.has_integrity_checksum(data: Dictionary) -> bool`。
- 新增 `GFStorageUtility.require_integrity_checksum: bool`。
- `GFTimerUtility.execute_after(delay: float, callback: Callable)` 返回值从 `void` 扩展为 `int` 句柄；忽略返回值的旧调用保持可用。
- 新增 `GFTimerUtility.cancel(handle: int) -> bool`。
- `GFUIUtility.push_panel_instance(panel_instance: Node, layer: Layer = Layer.POPUP)` 新增可选 `config_callback: Callable = Callable()` 参数；旧调用保持可用。
- `send_command()` / `send_query()` 对无 `execute()` 对象的返回值仍为 `null`，但现在会额外输出 warning。

### 📘 升级指南 (Migration Guide)
1. 如果项目依赖 `send_command()` / `send_query()` 静默忽略普通对象，升级后会看到新的 warning；应改为传入实现 `execute()` 的 Command / Query，或直接调用项目自己的普通对象方法。
2. 在 `GFNodeContext` 局部上下文中，依赖框架访问器的 Command / Query 应通过当前 architecture 创建或发送，避免未注入对象回退到全局架构。
3. 旧存档默认仍兼容缺少 checksum 的载荷；只有同时启用 `use_integrity_checksum`、`strict_integrity` 和 `require_integrity_checksum` 时，缺少 checksum 才会被拒绝。
4. 如果项目此前用 `set_bus_volume(bus, 0.0)` 期望保留极低但非静音的音量，请改用一个大于 `0.0` 的线性音量值。
5. `GFTimerUtility.execute_after()` 的旧调用无需修改；需要取消任务时保存返回句柄并传给 `cancel(handle)`。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/utilities/gf_audio_utility.gd`
- `addons/gf/utilities/gf_object_pool_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_storage_codec.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_timer_utility.gd`
- `addons/gf/utilities/gf_ui_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_audio_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `tests/gf_core/test_gf_storage_codec.gd`
- `tests/gf_core/test_gf_storage_utility.gd`
- `tests/gf_core/test_gf_timer_utility.gd`
- `tests/gf_core/test_gf_ui_utility.gd`
- `docs/wiki/04. 事件系统 (Event System).md`
- `docs/wiki/05. 数据绑定 (Data Binding).md`
- `docs/wiki/06. 命令与查询 (Commands & Queries).md`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/Home.md`

---

## [1.23.3] - 2026-05-07

**版本概述**：生命周期与依赖注入体验优化，聚焦 Installer 超时、Scoped Context 手动初始化、工厂误用提示、访问器注入一致性和隐式基类查询热路径。

### 🚀 新增特性 (Added)
- **Installer 超时保护**：新增项目设置 `gf/project/installer_timeout_seconds`，可限制单个项目级 Installer `install()` 或 `install_bindings()` 的等待时间。
- **NodeContext 手动初始化入口**：`GFNodeContext` 新增 `initialize_context()`，让 `auto_init=false` 的 scoped 上下文可以通过公开 API 统一完成初始化并沿用 `context_ready` / `context_failed` 信号语义。

### 🔄 机制更改 (Changed)
- **隐式基类查询缓存**：`GFArchitecture` 会缓存唯一的 assignable 查询结果，并在注册、注销、alias 或 dispose 时失效缓存，减少热路径重复继承树扫描。
- **工厂注册期校验**：`register_factory()` 与 `replace_factory()` 会在注册期拒绝未知 lifecycle 值，避免错误延迟到 `create_instance()` 才暴露。
- **Factory alias 误用提示**：`GFBindBuilder.with_alias()` 用在 factory 绑定时会输出 warning，并继续完成原始 factory 绑定。
- **访问器 fallback 注入一致性**：`GFAccessGenerator` 生成的 `new()` fallback 路径会先绑定内部依赖作用域，再调用自定义注入 Hook，和 `GFArchitecture.inject_object()` / factory 注入路径保持一致。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFNodeContext.initialize_context() -> GFArchitecture`。
- 新增项目设置 `gf/project/installer_timeout_seconds: float`，默认 `0.0` 表示不启用超时。
- 无破坏性函数签名变更。

### 📘 升级指南 (Migration Guide)
1. 如果项目级 Installer 可能长期等待外部资源，可设置 `gf/project/installer_timeout_seconds`；超时无法强制取消 Godot coroutine，Installer 恢复后仍应避免继续写回失效架构。
2. 如果 `GFNodeContext.auto_init=false`，推荐改用 `await context.initialize_context()` 完成手动初始化，而不是直接调用 `context.get_architecture().init()`。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_bind_builder.gd`
- `addons/gf/core/gf_node_context.gd`
- `addons/gf/editor/gf_access_generator.gd`
- `addons/gf/plugin.gd`

---

## [1.23.2] - 2026-05-07

**版本概述**：核心架构可靠性维护，聚焦全局架构切换、Installer 失败策略、上下文失败传播、事件系统热路径、注销后的依赖作用域边界，以及维护规则机器化。

### 🚀 新增特性 (Added)
- **架构生命周期活动查询**：`GFArchitecture` 新增 `is_lifecycle_active()` 与 `fail_initialization()`，便于长异步流程恢复后判断当前架构是否仍可安全写回，也允许启动流程显式标记初始化失败。
- **Installer 严格失败策略**：新增项目设置 `gf/project/fail_on_installer_error`，可让项目级 Installer 配置或实例化错误直接中断架构初始化。

### 🔄 机制更改 (Changed)
- **注销模块的注入作用域释放**：`GFModel`、`GFSystem`、`GFUtility`、`GFCommand` 与 `GFQuery` 被注入后若所属作用域释放，将不再静默回退到全局架构。
- **类型事件派发表缓存**：`TypeEventSystem` 会缓存 exact 与 assignable listener 合并后的派发表，并在注册、注销、owner 清理和 clear 时失效缓存。
- **类型事件注册校验收敛**：无效 Callable 或参数数量不足的对象方法会输出运行时错误并跳过注册，不再依赖 debug assert。
- **全局架构切换串行保护**：`Gf.set_architecture()` / `Gf.init()` 在 await Installer 后会确认当前架构仍是同一次赋值，避免并发切换后旧流程继续初始化新架构。
- **维护规则机器化**：补充 GDScript section 布局规则和 GUT 静态检查，覆盖 section 顺序、下划线方法归类、私有变量归类和公共方法误入私有区等问题；插件生成的 NodeState 模板也会把可重写钩子放入独立 section。
- **文件级说明顺序统一**：补充 `class_name` 文件级说明顺序检查，并统一少量旧文件头部布局，让 `##` 类说明位于 `class_name` 之前。
- **内部类 section 统一**：补充内部类布局检查，要求顶层内部类放入明确的内部类 section，并调整少量旧文件的内部类位置或 section 标记。

### 🐛 Bug 修复 (Fixed)
- **NodeContext 父级失败等待悬挂**：`GFNodeContext.wait_until_ready()` 和子 scoped 上下文等待父级时会识别 `has_initialization_failed()`，失败后返回 `null` 并发出 `context_failed`。
- **Controller 上下文失败错误回退**：`GFController.wait_for_context_ready()` 在最近上下文失败时返回 `null`，不再回退到同一个未就绪或失败架构。
- **Controller 事件清理归属**：`GFController` 会记录注册事件时使用的架构，并在注销或退出树时清理对应架构上的 owner 监听。
- **全局快照类型防御**：`GFArchitecture.restore_global_snapshot()` 遇到非 `Dictionary` 的 `models` 字段时会跳过恢复并警告，避免错误快照触发运行时类型问题。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFArchitecture.is_lifecycle_active() -> bool`。
- 新增 `GFArchitecture.fail_initialization(reason: String) -> void`。
- 新增项目设置 `gf/project/fail_on_installer_error: bool`。
- 无破坏性函数签名变更；旧项目默认仍会跳过错误 Installer，只有显式开启 `gf/project/fail_on_installer_error` 才中断初始化。

### 📘 升级指南 (Migration Guide)
1. 如果项目希望 Installer 配置错误在开发期或 CI 中立即失败，可开启 `gf/project/fail_on_installer_error`；旧项目默认保持跳过错误 Installer 的兼容行为。
2. 如果长异步模块在超时或架构释放后仍可能恢复，应在恢复后检查当前架构生命周期是否仍 active，再写回外部状态。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_binding.gd`
- `addons/gf/core/gf_node_context.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/editor/gf_capability_inspector_plugin.gd`
- `addons/gf/editor/gf_node_state_machine_inspector_plugin.gd`
- `addons/gf/plugin.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/extensions/network/gf_enet_network_backend.gd`
- `addons/gf/extensions/network/gf_network_utility.gd`
- `addons/gf/extensions/state_machine/gf_node_state.gd`
- `addons/gf/extensions/state_machine/gf_state_machine.gd`
- `addons/gf/utilities/gf_audio_utility.gd`
- `addons/gf/utilities/gf_log_utility.gd`
- `addons/gf/utilities/gf_seed_utility.gd`
- `addons/gf/utilities/gf_signal_connection.gd`
- `addons/gf/base/gf_controller.gd`
- `addons/gf/base/gf_command.gd`
- `addons/gf/base/gf_model.gd`
- `addons/gf/base/gf_query.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/base/gf_utility.gd`
- `addons/gf/extensions/combat/gf_combat_payloads.gd`
- `addons/gf/extensions/combat/gf_modifier.gd`
- `addons/gf/extensions/combat/gf_tag_component.gd`
- `addons/gf/utilities/gf_behavior_tree.gd`
- `addons/gf/utilities/gf_debug_overlay_utility.gd`
- `addons/gf/utilities/gf_analytics_utility.gd`
- `addons/gf/utilities/gf_input_mapping_utility.gd`
- `addons/gf/utilities/gf_quest_utility.gd`
- `addons/gf/plugin.cfg`
- `ASSET_LIBRARY.md`
- `AI_MAINTENANCE.md`
- `CODING_STYLE.md`
- `docs/wiki/01. 架构概览 (Architecture).md`
- `docs/wiki/02. 生命周期与初始化 (Lifecycle).md`
- `docs/wiki/03. 更新机制 (Update Loop).md`
- `docs/wiki/更新日志 (Changelog).md`
- `tests/gf_core/test_gdscript_layout_validation.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_type_event_system.gd`
- `tests/gf_core/test_gf_model_serialization.gd`

---

## [1.23.1] - 2026-05-06

**版本概述**：收敛 GF 1.23.0 引入的大型扩展能力中的可靠性边界，重点修复存储写入校验、异步存档调度、存档图重复 key、空间节点能力基类、场景 UID 校验、Signal 去重语义、事件优先级、输入 just-started 生命周期、网络收包预算和运行时状态机 reload 行为。

### 🚀 新增特性 (Added)
- **异步存档并发预算**：`GFStorageUtility` 新增 `max_async_thread_count`，异步保存/读取会进入内部队列，并按同文件串行、不同文件受预算限制的策略启动线程。
- **空间节点能力基类**：新增 `GFNode2DCapability`、`GFNode3DCapability` 与 `GFControlCapability`，分别继承 `Node2D`、`Node3D` 与 `Control`，便于通用能力保留空间变换或 UI 布局语义。
- **响应式补跑上限**：`GFReactiveEffect` 新增 `max_reruns_per_run`，当 effect 回调运行中再次修改来源属性时会补跑，并用上限避免自激循环。
- **节点状态机 reload 状态保持**：`GFNodeStateMachine` 新增 `preserve_current_state_on_reload`，运行时从子节点重新加载状态时会尽量恢复原当前状态。
- **ENet 收包预算**：`GFENetNetworkBackend` 新增 `max_packets_per_poll`，默认每帧最多派发 64 个入站包，避免异常流量占满单帧。
- **架构生命周期扫描上限**：`GFArchitecture` 新增 `module_lifecycle_max_stage_passes`，避免模块在生命周期回调中无限注册新模块导致初始化阶段无法结束。

### 🔄 机制更改 (Changed)
- **存储路径收敛**：`GFStorageUtility` 会规范化相对路径，并拒绝 `../` 形式的跨目录路径；禁用绝对路径时仍回落到存档目录内同名文件。
- **Signal 连接去重更精确**：`GFSignalUtility` 去重现在同时匹配 once 语义、owner、默认参数和连接标记；`connect_once()` 不再把已有常驻连接意外改成一次性连接。
- **类型事件优先级全局排序**：`TypeEventSystem` 会把精确监听和可赋值监听合并后按 priority 排序；同优先级仍保持注册顺序。
- **输入 just-started 生命周期延后**：`GFInputMappingUtility` 不再在 Utility tick 开头清理 just-started，而是保留到当前帧结束，便于 Controller `_process` 稳定消费。
- **节点能力共享实现收敛**：`GFNodeCapability` 与空间节点能力基类共用内部 support 脚本处理架构注入和能力查询，减少不同原生父类基类之间的重复实现。
- **严格依赖模式覆盖工厂回退**：`GFArchitecture.strict_dependency_lookup` 现在也会阻止工厂查找回退到父架构。
- **入站网络通道校验**：`GFNetworkUtility` 在解码入站消息后，会按 `message_type` 或 payload 中的 `channel_id` 匹配注册通道，并应用通道级包体大小限制。
- **场景完成信号时机收敛**：`GFSceneUtility.scene_load_completed` 只在目标场景切换成功后发出；切换失败只发出 `scene_load_failed`。
- **节点能力编辑器识别范围**：Capability Inspector、GF 模板菜单与强类型访问器生成器会识别 `GFNode2DCapability`、`GFNode3DCapability` 与 `GFControlCapability` 子类。

### 🐛 Bug 修复 (Fixed)
- **存储写入静默成功**：修复 `GFStorageUtility` 写入 buffer/string 后未检查 `FileAccess.get_error()`，导致磁盘满或写入失败时仍返回 `OK` 的问题。
- **异步保存旧结果覆盖新结果**：修复同一文件多次异步保存可能并发提交、旧结果覆盖新结果的问题。
- **存档图重复 Source key 无法回放**：`GFSaveGraphUtility.gather_scope()` 遇到同一 Scope 内重复 Source/子 Scope key 时会失败并报错，不再生成 `key#2` 这类无法匹配应用端 source 的载荷。
- **空存档载荷误报成功**：`GFSaveGraphUtility.apply_scope()` 对空 payload 返回失败，避免坏档被当作成功应用。
- **槽位逻辑 ID 索引错误**：`GFSaveSlotWorkflow` 可从默认 `slot_{index}` 形式和尾部数字的逻辑 `slot_id` 中反推索引，不再把 `"slot_1"` 强转为 `0`。
- **UID 场景路径被误拒绝**：`GFSceneUtility` 对普通路径使用 `PackedScene` 识别扩展名校验，对 `uid://` 路径同步加载确认类型，既支持无扩展名场景 UID，也避免 `icon.svg` 这类非场景资源误入加载流程。
- **事件 owner ID 误判为空**：`TypeEventSystem` 只将 `0` 视为无 owner，兼容 Godot 4.6 下可能为负数的 `Object.get_instance_id()`，避免同 Callable 不同 owner 被误去重或派发期 owner 注销失效。
- **能力 Inspector 控件生命周期**：`GFCapabilityInspectorPlugin` 会先构建完整自定义 Inspector UI，再交给 Godot Inspector 管理，避免选中已挂载能力的宿主时偶发 `previously freed instance` 编辑器报错。
- **Asset 缓存 null 条目**：`GFAssetUtility.put_cache()` 会拒绝空路径或 null Resource，并补强脚本 `class_name` / 脚本路径形式的类型提示兼容。
- **Flow 等待 Node 退出树悬挂**：`GFFlowRunner` 等待 Node 信号时会监听 `tree_exited`，避免节点离树后流程长期等待。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFStorageUtility.max_async_thread_count: int`。
- 新增 `GFNode2DCapability`。
- 新增 `GFNode3DCapability`。
- 新增 `GFControlCapability`。
- 新增 `GFReactiveEffect.max_reruns_per_run: int`。
- 新增 `GFNodeStateMachine.preserve_current_state_on_reload: bool`。
- 新增 `GFENetNetworkBackend.max_packets_per_poll: int`。
- 新增 `GFArchitecture.module_lifecycle_max_stage_passes: int`。
- 无破坏性函数签名变更；但 `strict_dependency_lookup` 对工厂父级回退的语义更严格，开启该模式的项目应显式在局部架构注册需要的工厂。

### 📘 升级指南 (Migration Guide)
1. 如果项目使用 `GFStorageUtility.save_data_async()` 高频自动保存，建议按磁盘 IO 压力调整 `max_async_thread_count`；同一文件现在会按调用顺序串行提交。
2. 如果项目依赖 `connect_once()` 复用已有连接并把它改为一次性连接，需要改为显式保存返回的 `GFSignalConnection` 并调用 `once()`。
3. 如果项目开启了 `strict_dependency_lookup` 且仍希望从父架构创建工厂实例，需要在局部架构显式注册对应工厂，或关闭严格模式。
4. 如果项目在类型事件中同时注册 exact 与 assignable listener，请按全局 priority 重新确认事件消费顺序。
5. 如果项目有运行时动态增删 `GFNodeStateMachine` 子状态，默认会尽量保持当前状态；需要旧的重载即重启行为时可关闭 `preserve_current_state_on_reload`。
6. 如果项目已有 2D、3D 或 UI Node 能力，建议把需要空间变换或 UI 布局继承的能力基类切换为 `GFNode2DCapability`、`GFNode3DCapability` 或 `GFControlCapability`；不依赖空间分支的能力继续使用 `GFNodeCapability`。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_reactive_effect.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/plugin.gd`
- `addons/gf/base/gf_model.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/base/gf_utility.gd`
- `addons/gf/editor/gf_access_generator.gd`
- `addons/gf/editor/gf_capability_inspector_plugin.gd`
- `addons/gf/extensions/flow/gf_flow_runner.gd`
- `addons/gf/extensions/network/gf_enet_network_backend.gd`
- `addons/gf/extensions/network/gf_network_utility.gd`
- `addons/gf/extensions/capability/gf_node_capability.gd`
- `addons/gf/extensions/capability/gf_node_capability_support.gd`
- `addons/gf/extensions/capability/gf_node_2d_capability.gd`
- `addons/gf/extensions/capability/gf_node_3d_capability.gd`
- `addons/gf/extensions/capability/gf_control_capability.gd`
- `addons/gf/extensions/save/gf_save_graph_utility.gd`
- `addons/gf/extensions/save/gf_save_slot_workflow.gd`
- `addons/gf/extensions/state_machine/gf_node_state_group.gd`
- `addons/gf/extensions/state_machine/gf_node_state_machine.gd`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_input_mapping_utility.gd`
- `addons/gf/utilities/gf_quad_tree_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_signal_connection.gd`
- `addons/gf/utilities/gf_signal_utility.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_ui_utility.gd`
- `docs/wiki/12. 能力组件 (Capabilities).md`
- `docs/wiki/更新日志 (Changelog).md`
- `tests/gf_core/test_gf_access_generator.gd`
- `tests/gf_core/test_bindable_property.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `tests/gf_core/test_gf_input_mapping_utility.gd`
- `tests/gf_core/test_gf_network_extension.gd`
- `tests/gf_core/test_gf_save_graph_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `tests/gf_core/test_gf_signal_utility.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_storage_utility.gd`
- `tests/gf_core/test_type_event_system.gd`

## [1.23.0] - 2026-05-06

**版本概述**：围绕 GF 的横向框架能力继续补强，新增响应式组合、瓦片/网格、3D 表面材质、场景预加载与配置化切换、存档槽位工作流、存档流程 trace、输入展示 provider、调试绘制命令缓冲、配置化 Tween 动作、能力诊断和流程失败治理。新增内容保持抽象、可选接入，不把自动铺砖、脚步声、关卡、战斗或 UI 等业务语义写入框架层。

### 🚀 新增特性 (Added)
- **响应式组合辅助**：新增 `GFReactiveEffect`，可监听多个 `BindableProperty` 并在任一来源变化时执行回调，支持绑定 `Node` 生命周期。
- **只读派生属性**：新增 `GFComputedProperty`，可由多个 `BindableProperty` 派生只读值，用于局部 UI/Controller 数据组合。
- **瓦片数据快照**：新增 `GFTileMapCache`，提供通用格子字典数据缓存、`TileMapLayer` 采集、差分比较和 `to_dict()` / `from_dict()`。
- **瓦片邻域规则表**：新增 `GFTileRuleSet`，用邻域值序列解析结果，支持 fallback 邻域值、默认结果、权重结果和确定性选择。
- **3D 表面材质查询**：新增 `GFSurfaceUtility`，可根据 RayCast/碰撞命中的 face index 推导 `MeshInstance3D` surface、基础材质、override 材质和 active material。
- **场景资源预加载缓存**：`GFSceneUtility` 新增场景预加载信号、LRU PackedScene 缓存、取消预加载、缓存状态查询和调试快照。
- **资源化场景切换配置**：新增 `GFSceneTransitionConfig`，并为 `GFSceneUtility` 增加 `load_scene_with_transition()`，可用资源描述目标场景、loading scene、预加载和缓存策略。
- **通用存档槽位工作流**：新增 `GFSaveSlotMetadata`、`GFSaveSlotCard` 与 `GFSaveSlotWorkflow`，用于构建槽位元数据、读档卡片 DTO 和槽位索引/逻辑标识映射。
- **存档流程上下文与事件**：新增 `GFSavePipelineContext` 与 `GFSavePipelineEvent`，`GFSaveGraphUtility` 可按需输出采集/应用流程 trace，也允许调用方传入上下文收集事件。
- **输入展示 provider**：新增 `GFInputTextProvider` 与 `GFInputIconProvider`，允许项目为平台、设备、本地化或图标字体扩展输入展示。
- **调试绘制命令缓冲**：新增 `GFDebugDrawUtility`，提供 2D/3D 线段、矩形、圆、文本和自定义命令的通用缓冲、频道过滤和生命周期管理。
- **配置化 Tween 动作**：新增 `GFTweenActionStep`、`GFTweenActionConfig` 与 `GFConfiguredTweenAction`，可把表现属性动画资源化后交给 `GFActionQueueSystem` 编排。
- **能力诊断报告**：`GFCapabilityUtility` 新增 `inspect_receiver()` 与 `validate_receiver_dependencies()`，便于调试能力、依赖和分组状态。
- **命令序列失败治理**：`GFCommandSequence` 新增失败信号、失败策略、运行报告和可选逆序回滚。
- **架构初始化超时保护**：`GFArchitecture` 新增 `module_async_init_timeout_seconds`、`initialization_failed`、`last_initialization_error` 与 `has_initialization_failed()`，可在开发期或高风险模块初始化中避免 `async_init()` 永久挂起。
- **严格依赖查询模式**：`GFArchitecture` 新增 `strict_dependency_lookup` 与 `get_local_model()` / `get_local_system()` / `get_local_utility()`；`GFNodeContext` 新增同名严格查询开关和本地查询代理，便于分屏、战斗房间等局部上下文暴露漏注册依赖。
- **存档异步纯数据管线**：`GFStorageUtility` 新增 `save_data_async()`、`load_data_async()`、`save_completed` 与 `load_completed`，把字典编码、解码和文件 IO 移到线程执行，完成通知回到主线程。
- **时间缩放保护**：`GFTimeUtility` 新增 `max_scaled_delta`、`physics_substep_max_delta`、`max_physics_substeps`、`get_physics_scaled_delta_steps()` 与 `should_substep_physics()`，可限制高倍速或掉帧后的单步 delta。
- **资源缓存锁定**：`GFAssetUtility` 新增 `pin_cache()`、`unpin_cache()` 与 `is_cache_pinned()`，可让关键预加载资源暂时跳过 LRU 淘汰。
- **对象池时间预算预热**：`GFObjectPoolUtility` 新增 `prewarm_async_budget()`，按单帧毫秒预算分批实例化复杂场景。
- **表现动作条件跳过**：`GFVisualAction` 新增 `is_valid()` 与 `can_execute()`，`GFActionQueueSystem` 和 `GFVisualActionGroup` 会在执行前跳过无效动作。
- **API 注释校验测试**：新增 `test_api_docs_validation.gd`，自动校验公开 API 带参数函数必须提供 `## @param`，并与函数签名在名称、数量和顺序上双向一致。

### 🔄 机制更改 (Changed)
- **日志内存缓存改为环形缓冲**：`GFLogUtility` 的内存日志保留最新条目，避免长时间运行时数组无限增长；`get_recent_entries()` 支持在环形缓存上稳定分页读取。
- **场景切换可复用预加载资源**：`GFSceneUtility.load_scene_async()` 会优先使用已预加载的 `PackedScene`，也可按 `cache_loaded_scenes` 将正常加载完成的场景写入缓存。
- **场景切换缓存策略可按次覆盖**：`GFSceneUtility.load_scene_with_transition()` 会把 `GFSceneTransitionConfig.cache_loaded_scene` 捕获到当前加载任务，不污染全局默认缓存策略。
- **存档图流程自动记录通用事件**：`GFSaveGraphUtility.gather_scope()` / `apply_scope()` 会在 context 中维护可选 `GFSavePipelineContext`，记录 Scope、Source 和 PipelineStep 的通用阶段事件。
- **输入格式化改为 provider 优先**：`GFInputFormatter` 保持原有文本 API，同时优先尝试已注册 provider，并新增 RichText 与 Texture2D 图标查询入口。
- **命令序列失败结果协议收敛**：`GFCommandSequence` 会识别 `{"ok": false}`、`{"success": false}`、`{"status": "error"}` / `failed` / `failure` 这类失败字典，并把失败步骤写入 `last_run_report.results`。
- **瓦片规则内部结构更稳健**：`GFTileRuleSet` 的 trie 节点使用 `branches` / `results` 分区，允许邻域值本身为 `"results"` 等普通字符串。
- **物理帧可选子步进驱动**：当注册的 `GFTimeUtility.physics_substep_max_delta > 0` 且缩放后物理 delta 超过阈值时，`GFArchitecture.physics_tick()` 会把该帧拆成多个缩放子步驱动模块；默认关闭，旧项目行为不变。
- **定点数大位移除法减少分配**：`GFFixedDecimal` 的字符串除法、减法和按位乘法改为数组收集后一次 join，降低极端精度路径中的字符串拼接压力。
- **轻量事件派发热路径优化**：`TypeEventSystem.send_simple()` 在 pending 列表为空时跳过每监听器数组扫描，降低高频简单事件的固定开销。
- **API 注释校验收紧**：`test_api_docs_validation.gd` 支持多行签名和带逗号默认值解析；公开函数名不以 `_` 开头且带参数时强制要求 `@param`，私有函数与 Godot 生命周期函数继续豁免。

### 🐛 Bug 修复 (Fixed)
- **命令序列失败步骤统计修正**：当 `stop_on_error = false` 时，失败步骤不再被计入成功步骤和回滚候选，但仍会发出 `step_completed` 以保持旧的继续执行语义。
- **命令序列空错误兜底**：失败字典未提供 `error` / `message` / `reason` 时，运行报告使用稳定默认错误 `"Step failed."`。
- **响应式测试生命周期修正**：`GFReactiveEffect` 测试显式持有 effect 引用，并避免局部变量遮蔽 `Node.owner`。
- **3D 表面工具测试清理**：`GFSurfaceUtility` 测试创建的 `MeshInstance3D` 交由 GUT 自动释放，不再产生 orphan 报告。
- **API 注释参数名修正**：修正 `Gf.set_architecture()` 文档中的 `@param` 名称，避免注释与签名不一致。
- **公开 API @param 注释补齐**：补齐公开 API 参数说明，并修正抽象基类、能力查询、Buff、命令历史和配置 provider 中 `@param` 与函数签名不一致的问题。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFReactiveEffect`。
- 新增 `GFComputedProperty`。
- 新增 `GFTileMapCache`。
- 新增 `GFTileRuleSet`。
- 新增 `GFSurfaceUtility`。
- 新增 `GFSceneTransitionConfig`。
- 新增 `GFSavePipelineContext`。
- 新增 `GFSavePipelineEvent`。
- 新增 `GFSaveSlotMetadata`。
- 新增 `GFSaveSlotCard`。
- 新增 `GFSaveSlotWorkflow`。
- 新增 `GFInputTextProvider`。
- 新增 `GFInputIconProvider`。
- 新增 `GFDebugDrawUtility`。
- 新增 `GFTweenActionStep`。
- 新增 `GFTweenActionConfig`。
- 新增 `GFConfiguredTweenAction`。
- `GFSceneUtility` 新增 `scene_preload_started`、`scene_preload_progress`、`scene_preload_completed`、`scene_preload_failed` 与 `scene_preload_cancelled` 信号。
- `GFSceneUtility` 新增 `SceneResourceState` 枚举。
- `GFSceneUtility` 新增 `max_preloaded_scene_resources` 与 `cache_loaded_scenes`。
- `GFSceneUtility` 新增 `preload_scene()`、`preload_scenes()`、`cancel_scene_preload()`、`cancel_all_scene_preloads()`、`is_scene_preloading()`、`is_scene_preloaded()`、`get_preloaded_scene()`、`put_preloaded_scene()`、`remove_preloaded_scene()`、`clear_preloaded_scenes()`、`get_preloading_scene_paths()`、`get_scene_cache_debug_snapshot()` 与 `get_scene_resource_state()`。
- `GFSceneUtility` 新增 `load_scene_with_transition(config: GFSceneTransitionConfig) -> Error`。
- `GFSaveGraphUtility` 新增 `create_pipeline_context(operation: StringName, scope: GFSaveScope = null, shared: Dictionary = {}) -> GFSavePipelineContext`。
- `GFSaveGraphUtility.gather_scope()` 支持通过 context 传入 `pipeline_context` 或 `include_pipeline_trace`。
- `GFSaveGraphUtility.apply_scope()` 支持通过 context 传入 `pipeline_context` 或 `include_pipeline_trace`。
- `GFInputFormatter.input_event_as_text()`、`binding_as_text()` 与 `mapping_as_text()` 新增可选 `options: Dictionary = {}` 参数，旧调用保持兼容。
- `GFInputFormatter` 新增 `input_event_as_rich_text()`、`input_event_icon()`、`binding_as_rich_text()`、`mapping_as_rich_text()`、`add_text_provider()`、`remove_text_provider()`、`clear_text_providers()`、`get_text_providers()`、`add_icon_provider()`、`remove_icon_provider()`、`clear_icon_providers()` 与 `get_icon_providers()`。
- `GFCapabilityUtility` 新增 `inspect_receiver()` 与 `validate_receiver_dependencies()`。
- `GFCommandSequence` 新增 `step_failed` 与 `sequence_failed` 信号。
- `GFCommandSequence` 新增 `stop_on_error`、`rollback_on_failure` 与 `last_run_report`。
- `GFCommandSequence` 新增 `with_failure_policy(should_stop_on_error: bool = true, should_rollback_on_failure: bool = false) -> GFCommandSequence`。
- `GFArchitecture` 新增 `initialization_failed(reason: String)` 信号。
- `GFArchitecture` 新增 `module_async_init_timeout_seconds`、`strict_dependency_lookup` 与 `last_initialization_error`。
- `GFArchitecture` 新增 `has_initialization_failed()`、`get_local_model()`、`get_local_system()` 与 `get_local_utility()`。
- `Gf` 新增 `get_local_model()`、`get_local_system()` 与 `get_local_utility()`。
- `GFNodeContext` 新增 `strict_dependency_lookup`、`module_async_init_timeout_seconds`、`get_local_model()`、`get_local_system()` 与 `get_local_utility()`。
- `GFController` 新增 `get_local_model()`、`get_local_system()` 与 `get_local_utility()`。
- `GFStorageUtility` 新增 `save_completed(file_name: String, error: Error)` 与 `load_completed(file_name: String, result: Dictionary)` 信号。
- `GFStorageUtility` 新增 `save_data_async(file_name: String, data: Dictionary) -> Error` 与 `load_data_async(file_name: String) -> Error`。
- `GFTimeUtility` 新增 `max_scaled_delta`、`physics_substep_max_delta`、`max_physics_substeps`、`get_physics_scaled_delta_steps()` 与 `should_substep_physics()`。
- `GFAssetUtility` 新增 `pin_cache()`、`unpin_cache()` 与 `is_cache_pinned()`。
- `GFObjectPoolUtility` 新增 `prewarm_async_budget(scene: PackedScene, parent: Node, count: int, msec_budget_per_frame: float = 8.0) -> void`。
- `GFVisualAction` 新增 `is_valid()` 与 `can_execute()`。
- 无破坏性 API 变更；旧项目不使用新增能力时无需修改现有调用。

### 📘 升级指南 (Migration Guide)
1. 旧项目可直接升级；新增类和 Utility 均为可选接入。
2. 如果项目已有 UI 多属性刷新逻辑，可逐步用 `GFReactiveEffect` 或 `GFComputedProperty` 替代临时事件转发；核心状态仍应放在项目 `Model` 中。
3. 如果项目有 TileMap 编辑器工具、自动铺砖或地图差分刷新，可用 `GFTileMapCache` / `GFTileRuleSet` 作为纯数据底座；邻域采样顺序、规则含义和最终落图策略仍由项目层决定。
4. 如果项目需要按 3D 命中材质分发脚步声、弹孔或特效，可注册 `GFSurfaceUtility` 并读取 surface/material；材质标签和效果映射仍由项目层维护。
5. 如果项目已有场景加载入口，可按需调用 `GFSceneUtility.preload_scene()` 预热场景资源；loading UI、解锁规则和传送流程不进入 GF 内部。
6. 如果项目希望把场景切换参数资源化，可使用 `GFSceneTransitionConfig`，并通过 `GFSceneUtility.load_scene_with_transition()` 发起切换。
7. 如果项目需要读档选单数据，可使用 `GFSaveSlotWorkflow` 生成 `GFSaveSlotMetadata` 与 `GFSaveSlotCard`；真正的数据字段和 UI 布局仍由项目层决定。
8. 如果项目需要存档流程审计，可在 context 中传入 `include_pipeline_trace = true`，或显式创建并复用 `GFSavePipelineContext`。
9. 如果项目已有输入图标或本地化系统，可注册 `GFInputTextProvider` / `GFInputIconProvider`，无需替换现有输入映射资源。
10. 如果项目需要开发期绘制碰撞、路径或范围，可注册 `GFDebugDrawUtility` 收集命令，再用项目自己的 Overlay 渲染。
11. 如果项目有可复用表现 Tween，可用 `GFTweenActionConfig` 资源化步骤，并生成 `GFConfiguredTweenAction` 加入 `GFActionQueueSystem`。
12. 如果项目已有能力调试面板，可接入 `GFCapabilityUtility.inspect_receiver()` 展示能力依赖和分组报告。
13. 如果项目使用 `GFCommandSequence` 编排可失败流程，可通过 `with_failure_policy()` 开启失败停止和可选回滚；已有不关心失败字典的序列保持继续执行行为。
14. 如果项目存在网络、远程配置或大资源预加载等高风险初始化，可为开发期架构设置 `module_async_init_timeout_seconds`，并监听 `initialization_failed` 输出诊断。
15. 如果项目使用 `GFNodeContext.SCOPED` 承载独立战斗、房间或分屏玩家状态，可开启 `strict_dependency_lookup`，让漏注册的局部依赖立刻报错；需要显式读取父级依赖时保持默认关闭或调用父架构。
16. 如果项目存档数据较大，可把纯字典保存/读取入口迁移到 `save_data_async()` / `load_data_async()`，并在注册为 Utility 后由架构 tick 派发完成信号。
17. 如果项目使用高倍速或快进物理逻辑，可设置 `GFTimeUtility.physics_substep_max_delta` 和 `max_physics_substeps`，避免单次 `physics_tick` delta 过大。
18. 如果项目批量预加载表现资源，可在使用期间对关键资源调用 `pin_cache()`，使用结束后调用 `unpin_cache()` 恢复 LRU 淘汰。
19. 如果项目动作队列中的表现依赖运行时目标，可在自定义 `GFVisualAction.is_valid()` 或 `can_execute()` 中检查目标是否仍有效，框架会自动跳过失效动作。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/core/gf_reactive_effect.gd`
- `addons/gf/core/gf_computed_property.gd`
- `addons/gf/core/gf_architecture.gd`
- `addons/gf/core/gf_node_context.gd`
- `addons/gf/core/gf.gd`
- `addons/gf/core/type_event_system.gd`
- `addons/gf/plugin.gd`
- `addons/gf/base/gf_controller.gd`
- `addons/gf/base/gf_payload.gd`
- `addons/gf/base/gf_rule.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/core/gf_installer.gd`
- `addons/gf/editor/gf_access_generator.gd`
- `addons/gf/editor/gf_editor_type_index.gd`
- `addons/gf/foundation/math/gf_tile_map_cache.gd`
- `addons/gf/foundation/math/gf_tile_rule_set.gd`
- `addons/gf/foundation/numeric/gf_fixed_decimal.gd`
- `addons/gf/utilities/gf_surface_utility.gd`
- `addons/gf/utilities/gf_scene_utility.gd`
- `addons/gf/utilities/gf_scene_transition_config.gd`
- `addons/gf/utilities/gf_debug_draw_utility.gd`
- `addons/gf/utilities/gf_asset_utility.gd`
- `addons/gf/utilities/gf_object_pool_utility.gd`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_time_utility.gd`
- `addons/gf/utilities/gf_log_utility.gd`
- `addons/gf/utilities/gf_config_provider.gd`
- `addons/gf/extensions/capability/gf_capability_utility.gd`
- `addons/gf/extensions/combat/gf_buff.gd`
- `addons/gf/extensions/combat/gf_combat_system.gd`
- `addons/gf/extensions/combat/gf_modifier.gd`
- `addons/gf/extensions/command/gf_undoable_command.gd`
- `addons/gf/extensions/interaction/gf_interaction_context.gd`
- `addons/gf/extensions/interaction/gf_interaction_flow.gd`
- `addons/gf/extensions/interaction/gf_interactions.gd`
- `addons/gf/extensions/network/gf_enet_network_backend.gd`
- `addons/gf/extensions/network/gf_network_utility.gd`
- `addons/gf/extensions/state_machine/gf_state.gd`
- `addons/gf/extensions/sequence/gf_command_sequence.gd`
- `addons/gf/extensions/save/gf_save_graph_utility.gd`
- `addons/gf/extensions/save/gf_save_pipeline_context.gd`
- `addons/gf/extensions/save/gf_save_pipeline_event.gd`
- `addons/gf/extensions/save/gf_save_slot_metadata.gd`
- `addons/gf/extensions/save/gf_save_slot_card.gd`
- `addons/gf/extensions/save/gf_save_slot_workflow.gd`
- `addons/gf/input/gf_input_formatter.gd`
- `addons/gf/input/gf_input_text_provider.gd`
- `addons/gf/input/gf_input_icon_provider.gd`
- `addons/gf/input/gf_input_*_modifier.gd`
- `addons/gf/input/gf_input_*_trigger.gd`
- `addons/gf/extensions/action_queue/gf_tween_action_step.gd`
- `addons/gf/extensions/action_queue/gf_tween_action_config.gd`
- `addons/gf/extensions/action_queue/gf_configured_tween_action.gd`
- `addons/gf/extensions/action_queue/gf_visual_action.gd`
- `addons/gf/extensions/action_queue/gf_visual_action_group.gd`
- `addons/gf/extensions/action_queue/gf_action_queue_system.gd`
- `tests/gf_core/test_api_docs_validation.gd`
- `tests/gf_core/test_bindable_property.gd`
- `tests/gf_core/test_gf_tile_utilities.gd`
- `tests/gf_core/test_gf_surface_utility.gd`
- `tests/gf_core/test_gf_scene_utility.gd`
- `tests/gf_core/test_gf_save_graph_utility.gd`
- `tests/gf_core/test_gf_input_mapping_utility.gd`
- `tests/gf_core/test_gf_visual_actions.gd`
- `tests/gf_core/test_gf_debug_draw_utility.gd`
- `tests/gf_core/test_gf_log_utility.gd`
- `tests/gf_core/test_gf_capability_utility.gd`
- `tests/gf_core/test_gf_command_sequence.gd`
- `tests/gf_core/test_gf_singleton.gd`
- `tests/gf_core/test_gf_storage_utility.gd`
- `tests/gf_core/test_gf_time_utility.gd`
- `tests/gf_core/test_gf_asset_utility.gd`
- `tests/gf_core/test_gf_object_pool_utility.gd`
