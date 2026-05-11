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

3.0.0 是一次大版本结构重整，本页面当前只保留 `3.0.0`。后续新工作仍先记录到未发布小节，发布时再合并为具体版本条目；旧版本历史以 Git 历史或 GitHub Releases 为准，避免正式 Wiki 长期膨胀。

---

## [3.0.0] - 2026-05-11

**版本概述**：3.0.0 以最佳实践优先，集中偿还旧目录、旧命名和旧兼容债。源码分层收敛为 `kernel`、`standard`、`packages`，官方包和社区包有了 manifest、启用设置、编辑器包管理器和导出排除能力；同时修复事件、存档、输入、tick、状态机启动通知等边界问题，并系统重命名职责漂移的类。

### 🚀 新增特性 (Added)

- 新增 `GFPackageManifest`、`GFPackageCatalog` 与 `GFPackageSettings`，用于读取 `gf_package.json`、扫描官方/社区包、管理启用包 ID、补齐包依赖、收集启用包 Installer 和控制导出排除。
- 新增 `GFPackageUsageAudit`，用于检查禁用包是否仍被项目脚本、场景或资源通过路径或 `class_name` 直接引用。
- 新增编辑器 `GF Packages` 底部面板，可查看包名称、ID、版本、来源、说明、依赖、Installer、标签和校验状态，并启用/禁用官方包或社区包；面板支持分类、搜索、恢复默认、批量勾选和明确的保存设置动作。
- 新增包导出过滤插件：`gf/packages/export_exclude_disabled` 开启时，导出流程会跳过禁用包目录，减少最终导出体积。
- `GFPackageManifest` 新增 `enabled_by_default`；官方包默认启用，社区包默认不启用。
- 所有官方包新增 `gf_package.json` manifest，并统一进入 `addons/gf/packages/official/<package>`。
- 新增 `GFFixedTickClock` 的单 tick 循环信号、预算耗尽诊断、`get_tick_factor()` 与 `get_lag_seconds()`。
- 新增网络字段级编码与快照 Schema：`GFNetworkFieldSerializer`、`GFNetworkSnapshotSchema`。
- 新增战斗通用动作、修正器、结果、数值槽和 2D/3D hitscan 桥：`GFCombatAction`、`GFCombatActionModifier`、`GFCombatActionResult`、`GFCombatGauge`、`GFHitScan2D`、`GFHitScan3D`。
- 新增 `GFGridSelection2D`、`GFGridGenerationStep2D` 与 `GFGridGenerationPipeline2D`，提供通用 2D 网格生成管线。
- 新增编辑器 `GFSourceBuilder`，统一访问器和模板生成时的源码拼装、缩进、section 与文档注释格式。
- 新增 Foundation 级 `GFResultDictionary`，统一 `ok`、`data`、`metadata`、`error` 等结果字典字段和构造入口。

### 🔄 机制更改 (Changed)

- 源码顶层收敛为 `addons/gf/kernel`、`addons/gf/standard`、`addons/gf/packages`。
- `kernel` 只承载框架启动、基础契约、架构容器、绑定、事件、AutoLoad、包基础设施和编辑器集成。
- `standard` 承载稳定标准库：`foundation`、输入体系、通用 Utility、状态机、命令、序列和 common 支撑。
- `packages/official` 承载随 GF 发布但保持可选边界的官方包；`packages/community` 作为项目本地或第三方包约定入口。
- 官方包内部结构规范化：包根只保留 manifest、可选安装器和说明文档，代码进入 `runtime`、`resources`、`nodes`、`editor`、`actions` 或包内稳定领域目录。
- 官方包之间不再声明强依赖；需要联动时通过协议、运行时接口或动态探测完成，保持每个官方包都能单独启用、禁用或删除。
- `kernel` 与 `standard` 不再硬 preload 官方包脚本；编辑器增强工具在可选包缺失时会自动跳过对应能力。
- 包管理器和导出插件会在禁用包被项目文件直接引用时输出警告，降低导出排除造成缺文件的风险。
- GUT 测试目录按框架层级重排为 `tests/gf_core/maintenance`、`kernel`、`standard`、`packages/official` 和 `fixtures`。
- 启用包的 `installer_paths` 会在 `Gf.init()` / `Gf.set_architecture()` 中先于项目级 `gf/project/installers` 执行；项目 Installer 仍可继续装配业务模块或覆盖绑定。
- `Gf` AutoLoad 路径迁移为 `res://addons/gf/kernel/core/gf.gd`，插件启用后使用新路径注册。
- `GFInputUtility` 重命名为 `GFInputAssistUtility`，职责明确为动作缓冲和通用宽容窗口；`consume_action()` 改为 `consume_buffered_action()`，土狼时间接口改为 `grace_window` 命名。
- `GFValidationUtility` 重命名为 `GFValidationReportDictionary`。
- `GFDecimalStringUtility`、`GFScriptTypeUtility`、`GFTagUtility`、`GFTextFitUtility` 与 `GFNodeTreeUtility` 分别重命名为 `GFDecimalStringFormatter`、`GFScriptTypeInspector`、`GFTagSourceAdapter`、`GFTextFitter` 与 `GFNodeTreeOps`。
- `GFVariantUtility` 拆分为 `GFVariantData` 与 `GFVariantJsonCodec`，分离复制/默认值合并和 JSON/数组 codec。
- `GFAttribute` 重命名为 `GFModifiedAttribute`，和领域层 `GFAttributeSet`、节点型 `GFCombatGauge` 拉开职责边界。
- `GFStateMachine.start()` 默认会在初始状态进入成功后发出 `state_changed(&"", initial_state_name)`；需要静默启动时传入第三个参数 `false`。
- `GFArchitecture` 的 Model、System、Utility 注册表收敛为共享内部结构，统一注册、别名、继承匹配缓存、注销和生命周期推进逻辑。
- `GFTypeEventSystem` 将 exact、assignable 与 simple 三组监听器的 pending add/remove/owner-remove 规则收敛为共享内部轨道。
- `GFArchitecture` 的 tick 缓存基于显式 `tick_enabled` / `physics_tick_enabled` 或脚本真实声明的 `tick()` / `physics_tick()` 构建；未重写空模板的 `GFSystem` 不再每帧空转。
- `GFStorageUtility` 的路径策略、文件操作和事务恢复收敛为内部组件，公开 API 和文件格式保持一致。
- `GFStorageCodec`、`GFStorageBackend` 与 `GFStorageUtility` 的结果字典改为复用 `GFResultDictionary` 构造。
- `GFNetworkReconnectPolicy` 的 jitter 随机源改为实例初始化时播种，便于测试和复现退避序列。
- `GFWeightedEntry` / `GFWeightedTable` 复用 `GFVariantData.duplicate_variant(..., duplicate_resources = true)` 复制集合与资源值。
- `GFActionQueueSystem` 改为动作协议优先：推荐继续继承 `GFVisualAction`，但队列、动作组、重复动作和拦截器也可消费直接实现 `execute()` / `can_execute()` / `cancel()` 等方法的对象。

### 🐛 Bug 修复 (Fixed)

- 修复 `GFTypeEventSystem` 在派发中跨事件类型/简单事件 ID 注册后立即注销时，pending add 仍会在 flush 后落地的问题。
- 修复事件回调签名只校验最少参数、不拦截额外未绑定必填参数的问题。
- 修复 `GFStorageUtility` 注册迁移步骤但缺少完整迁移链时，旧存档仍被标记为当前 `save_version` 的问题。
- 修复 `GFStorageUtility.save_data()` / `load_data()` / `load_data_result()` / `save_data_async()` / `load_data_async()` 空 `file_name` 会落入内部兜底文件名的问题。
- 修复 `GFInputMappingUtility` 玩家级动作状态未把真实输入来源纳入 binding key，导致同一玩家多来源输入可能互相覆盖的问题。
- 修复未重写 `tick()` / `physics_tick()` 的 `GFSystem` 被误判为具备真实 tick 能力的问题。
- 修复编辑器公开 API 注释与函数签名不一致的问题。
- 修复可选官方包被编辑器 preload 锁死，导致删除包目录后框架主体可能无法加载的问题。

### ⚠️ 废弃与移除 (Deprecated/Removed)

- 3.0.0 不保留旧源码路径兼容。直接 `preload()` / `load()` 旧路径的项目需要迁移到新目录。
- 移除旧类名：`GFInputUtility`、`GFValidationUtility`、`GFDecimalStringUtility`、`GFScriptTypeUtility`、`GFTagUtility`、`GFTextFitUtility`、`GFNodeTreeUtility`、`GFVariantUtility`、`GFAttribute`。
- 移除旧顶层目录：`addons/gf/base`、`core`、`editor`、`foundation`、`input`、`utilities`、`extensions`。对应内容已迁入 `kernel`、`standard` 或 `packages`。

### 🔌 API 变动说明 (API Changes)

- 新增 `GFPackageSettings`：
  - `get_default_enabled_package_ids()`
  - `get_enabled_package_ids()`
  - `set_enabled_package_ids(package_ids, include_dependencies = true)`
  - `get_enabled_manifests(include_community = true)`
  - `get_disabled_manifests(include_community = true)`
  - `get_enabled_installer_paths(include_community = true)`
  - `resolve_package_dependencies(package_ids, manifests = [])`
  - `get_package_selection_report()`
- 新增 ProjectSettings：
  - `gf/packages/enabled`
  - `gf/packages/auto_install_enabled_installers`
  - `gf/packages/export_exclude_disabled`
- `GFPackageManifest` 新增 `enabled_by_default` 字段，并在 `to_dictionary()` 中输出。
- `GFActionQueueSystem.enqueue()`、`push_front()`、`enqueue_to()`、`enqueue_parallel()` 等动作入口的动作参数放宽为 `Object` / `Array`；`GFActionInterceptor.before_execute()`、`after_execute()` 与 `GFActionInterceptionResult.replace_with()` 同步改为接收 `Object`。
- `GFStateMachine.start(initial_state_name, msg = {}, emit_changed = true)` 新增可选 `emit_changed` 参数，默认启动时发出状态变化信号。
- `GFSystem` 与 `GFUtility` 支持可选公开属性 `tick_enabled` / `physics_tick_enabled`，用于显式声明参与 tick 缓存。
- `GFVariantData.duplicate_variant(value, deep = true, duplicate_resources = false)` 支持可选 Resource 复制。
- `GFVariantData.duplicate_collection(value, deep = true)` 提供集合字段复制入口。
- 纯数据存取 API 传入空 `file_name` 时会明确返回失败：同步保存返回 `ERR_INVALID_PARAMETER`，同步读取写入失败的 `last_load_result`，异步接口返回 `ERR_INVALID_PARAMETER` 并发出失败完成信号。

### 📘 升级指南 (Migration Guide)

- 直接引用旧路径的代码需要按新结构迁移：内核看 `addons/gf/kernel`，标准能力看 `addons/gf/standard`，官方包看 `addons/gf/packages/official/<package>`。
- 使用旧类名的代码需要迁移到新类名。尤其是输入辅助、Variant、标签、节点树、校验报告、文本适配和属性修正相关类。
- 如果项目依赖纯代码状态机启动时不发 `state_changed`，调用 `start(initial_state_name, msg, false)`；推荐新代码保留默认通知行为。
- 如果项目曾误传空字符串给存档读写接口并依赖兜底文件名，请改为传入明确文件名。
- 使用 `register_migration()` 时请保证旧版本到当前 `save_version` 的迁移链完整；如果只想用默认值补齐字段，不注册迁移步骤即可。
- 事件回调方法如果声明了额外必填参数，请改为默认参数或使用 `Callable(...).bind(...)` 绑定额外参数。
- 包管理器的“禁用”不会让编辑器中的脚本或 `class_name` 消失；它影响启用包 Installer 和导出排除。导出排除禁用包前，请确认项目没有场景、资源或 preload 仍引用该包。若项目完全不使用某个官方包，也可以删除对应包目录，但仍要先清理项目侧直接引用。
- GUT 命令保持不变，因为测试运行使用 `-ginclude_subdirs`；但单个测试文件路径已迁移到分层目录。

### 📁 核心受影响文件 (Affected Files)

- `addons/gf/kernel/core/gf.gd`
- `addons/gf/kernel/core/gf_architecture.gd`
- `addons/gf/kernel/core/gf_type_event_system.gd`
- `addons/gf/kernel/package/gf_package_manifest.gd`
- `addons/gf/kernel/package/gf_package_catalog.gd`
- `addons/gf/kernel/package/gf_package_settings.gd`
- `addons/gf/kernel/package/gf_package_usage_audit.gd`
- `addons/gf/kernel/editor/package/gf_package_manager_dock.gd`
- `addons/gf/kernel/editor/package/gf_package_export_plugin.gd`
- `addons/gf/kernel/editor/gf_access_generator.gd`
- `addons/gf/kernel/editor/gf_capability_inspector_plugin.gd`
- `addons/gf/kernel/editor/gf_flow_graph_inspector_plugin.gd`
- `addons/gf/kernel/editor/gf_plugin_project_settings.gd`
- `addons/gf/kernel/editor/gf_plugin_inspector_tools.gd`
- `addons/gf/plugin.gd`
- `addons/gf/standard/state_machine/pure/gf_state_machine.gd`
- `addons/gf/standard/input/runtime/gf_input_assist_utility.gd`
- `addons/gf/standard/input/runtime/gf_input_mapping_utility.gd`
- `addons/gf/standard/foundation/variant/gf_variant_data.gd`
- `addons/gf/standard/foundation/variant/gf_variant_json_codec.gd`
- `addons/gf/standard/foundation/validation/gf_result_dictionary.gd`
- `addons/gf/packages/official/*/gf_package.json`
- `addons/gf/packages/official/action_queue/core/gf_action_queue_system.gd`
- `addons/gf/packages/official/action_queue/core/gf_action_interceptor.gd`
- `addons/gf/packages/official/action_queue/core/gf_action_interception_result.gd`
- `addons/gf/packages/official/action_queue/core/gf_action_protocol.gd`
- `addons/gf/packages/official/feedback/actions/gf_shake_action.gd`
- `addons/gf/packages/official/interaction/runtime/gf_interaction_context.gd`
- `addons/gf/packages/official/**`
- `tests/gf_core/README.md`
- `tests/gf_core/maintenance/**`
- `tests/gf_core/kernel/**`
- `tests/gf_core/standard/**`
- `tests/gf_core/packages/official/**`
- `docs/wiki/13. 包结构与生态 (Packages).md`
- `README.md`
- `addons/gf/README.md`
- `addons/gf/plugin.cfg`
- `ASSET_LIBRARY.md`
