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

3.0.0 已完成包结构与文档结构收口。后续新工作可重新创建 `[未发布]` 小节，发布时再合并为具体版本条目；旧版本历史以 Git 历史或 GitHub Releases 为准，避免正式文档长期膨胀。

---

## [3.0.0] - 2026-05-12

**版本概述**：本轮以最佳实践优先，集中偿还旧目录、旧命名和旧兼容债。源码分层收敛为 `kernel`、`standard`、`packages`，官方包和社区包有了 manifest、启用设置、编辑器包管理器和导出排除能力；同时修复事件、存档、输入、tick、状态机启动通知等边界问题，并系统重命名职责漂移的类。

### Added

- 新增 `GFPackageManifest`、`GFPackageCatalog`、`GFPackageSettings` 与 `GFPackageUsageAudit`，用于读取 `gf_package.json`、扫描包目录、管理启用状态、解析依赖、收集包 Installer 和检查禁用包引用。
- 新增 `GF Packages` 底部面板，可查看包名称、ID、版本、来源、说明、依赖、Installer、标签、校验状态和引用风险，并支持分类、搜索、恢复默认、批量启用/禁用和保存设置。
- `GF Packages` 面板新增“引用禁用包时阻止导出”开关，可直接控制 `gf/packages/export_fail_on_disabled_references`。
- 新增包导出过滤插件。`gf/packages/export_exclude_disabled` 开启时，导出流程会跳过禁用包目录。
- `GFPackageManifest` 新增 `enabled_by_default`、`editor_action_paths`、`editor_dock_paths`、`editor_inspector_paths`、`export_plugin_paths` 与 `access_generator_extension_paths`。
- `GFAccessGenerator` 支持启用包声明的访问器扩展脚本。扩展可以贡献访问器记录，也可以追加生成源码。
- `GFArchitecture`、`Gf`、`GFNodeContext`、`GFController`、`GFCommand`、`GFQuery`、`GFSystem` 与 `GFUtility` 的依赖查询新增 `require_ready` 可选参数。
- `GFArchitecture` 新增 `is_module_ready(instance)`；`GFModel`、`GFSystem`、`GFUtility` 新增 `is_lifecycle_active()` 与 `is_ready_in_architecture()`。
- 新增 `GFPluginDockTools`、`GFStorageViewerDock` 与 `addons/gf/standard/editor/gf_standard_editor_extensions.gd`，用于集中管理标准库编辑器扩展。
- 官方包新增 `gf_package.json` manifest。需要参与架构生命周期的官方包新增 `package.gd` 安装器。
- 新增 `GFFixedTickClock` 的单 tick 循环信号、预算耗尽诊断、`get_tick_factor()` 与 `get_lag_seconds()`。
- 新增网络字段级编码与快照 Schema：`GFNetworkFieldSerializer`、`GFNetworkSnapshotSchema`。
- 新增战斗通用动作、修正器、结果、数值槽和 2D/3D hitscan 桥：`GFCombatAction`、`GFCombatActionModifier`、`GFCombatActionResult`、`GFCombatGauge`、`GFHitScan2D`、`GFHitScan3D`。
- `GFCombatSystem` 新增 `get_buff()`、`has_buff()`、`get_buffs()` 与 `refresh_buff_modifiers()`，用于安全查询和调整运行中的 Buff。
- `GFHitBox2D`、`GFHitBox3D`、`GFHurtBox2D` 与 `GFHurtBox3D` 新增 `enabled_changed(enabled)` 信号。
- 新增 `GFGridSelection2D`、`GFGridGenerationStep2D` 与 `GFGridGenerationPipeline2D`。
- 新增 `GFSourceBuilder`，统一访问器和模板生成时的源码拼装、缩进、section 与文档注释格式。
- 新增 `GFTimeProvider`，作为 `GFArchitecture` 识别时间缩放、暂停和物理子步的内核协议。
- 包级 `editor_action_paths` 支持通过 `get_template_records()` 贡献脚本模板记录；Capability 包的 Capability/NodeCapability 模板改为由包自己声明。
- 新增 `GFResultDictionary`，统一 `ok`、`data`、`metadata`、`error` 等结果字典字段和构造入口。
- `GFStorageUtility` 新增 `strict_schema_migrations`。
- `GFNodeState` 与 `GFNodeStateMachine` 新增架构代理，可在节点状态内直接使用 `get_model()`、`get_system()`、`get_utility()`、`send_command()`、`send_query()` 和事件注册代理。
- Read the Docs 新增顶层 `FAQ` 页面，用于解释分层、包边界、文档目录和旧 Wiki 策略。

### Changed

- 源码顶层结构调整为：
  - `addons/gf/kernel`：框架启动、基础契约、架构容器、绑定、事件、AutoLoad、包基础设施和核心编辑器集成。
  - `addons/gf/standard`：稳定标准库，包括 `foundation`、输入体系、通用 Utility、状态机、命令、序列和 common 支撑。
  - `addons/gf/packages/official`：随 GF 发布但保持可选边界的官方包。
  - `addons/gf/packages/community`：项目本地或社区包约定入口。
- 官方包内部结构规范化。包根保留 manifest、可选安装器和说明文档，代码进入 `runtime`、`resources`、`nodes`、`editor`、`actions` 或包内稳定领域目录。
- 官方包之间不保留隐藏弱联动；需要协作时通过上层通用协议、运行时接口、显式注册或项目装配完成。
- `kernel` 与 `standard` 不硬 preload 官方包脚本。可选包禁用或删除时，核心与标准库仍应可加载。
- `kernel` 不再直接依赖 `standard`：`GFScriptTypeInspector` 迁入 `kernel/core`，架构时间控制改为识别 `GFTimeProvider` 协议，标准库编辑器增强和标准库脚本模板由根插件组合后传入 `kernel/editor`。
- `GFConfigAccessGenerator` 不再在 kernel/editor 中硬引用 `GFConfigProvider` 或 `GFConfigTableSchema`；生成源码默认使用 `Variant` provider，项目可按需传入自己的 `provider_accessor`。
- `standard` 不再保留任何官方包弱联动。`GFDiagnosticsUtility` 去除 ActionQueue / Network 包 ID 与包路径探测，改为提供通用快照分区和工具快照 provider 注册入口；ActionQueue / Network 包在自身运行时模块 ready 时主动贡献诊断信息。
- `GFLevelUtility` 不再按包 ID 动态探测 ActionQueue 包；重开关卡时仍会清理命令历史，其他运行时残留通过 `register_runtime_cleanup()` 显式注册。
- `GFPluginActions` / `GFPluginMenu` 改为声明式菜单记录和模板记录；`kernel/editor` 不再硬编码标准库 NodeState 模板、Capability 包模板、可选包 ID 或包内类型名。
- 包专属 Inspector、菜单动作、Dock、导出插件和访问器扩展统一由 manifest 驱动装载。
- Capability Inspector、Flow Graph Inspector、SaveGraph 诊断菜单和强类型访问器生成器尊重包启用状态。
- Capability 访问器记录改由 Capability 包自己的访问器扩展贡献，`kernel` 不再内建官方能力包识别逻辑。
- Interaction 包不再按包 ID 动态探测 Capability 包；需要能力查询时，项目或调用方通过 `with_capability_provider()` 显式传入能力提供者。
- `Gf` 会先运行启用包的 `installer_paths`，再运行项目级 `gf/project/installers`。
- 新项目会把默认启用的官方包 ID 明确写入 `gf/packages/enabled`。
- `Gf` AutoLoad 路径调整为 `res://addons/gf/kernel/core/gf.gd`。
- `GFStateMachine.start()` 默认会在初始状态进入成功后发出 `state_changed(&"", initial_state_name)`；需要静默启动时传入第三个参数 `false`。
- `GFNodeStateMachine` 与 `GFNodeStateGroup` 的状态相关信号和 getter 收敛为 `GFNodeStateGroup` / `GFNodeState` 强类型参数，不再让常规使用者从 `Node` 手动转型。
- `GFArchitecture` 的 Model、System、Utility 注册表收敛为共享内部结构，统一注册、别名、继承匹配缓存、注销和生命周期推进逻辑。
- `GFTypeEventSystem` 将 exact、assignable 与 simple 三组监听器的 pending add/remove/owner-remove 规则收敛为共享内部轨道。
- `GFArchitecture` tick 缓存基于显式 `tick_enabled` / `physics_tick_enabled` 或脚本真实声明的 `tick()` / `physics_tick()` 构建。
- `GFStorageUtility` 的路径策略、文件操作和事务恢复收敛为内部组件，公开 API 和文件格式保持一致。
- `GFStorageCodec`、`GFStorageBackend` 与 `GFStorageUtility` 的结果字典复用 `GFResultDictionary`。
- `GFNetworkReconnectPolicy` 的 jitter 随机源改为实例初始化时播种，便于测试和复现退避序列。
- 层级边界维护检查扩展到 `kernel` / `standard` 对官方包的具体类名、硬路径和包 ID 禁止规则，不再保留弱探测白名单。
- GDScript 静态维护检查新增旧路径 / 旧类名残留、重复 `class_name`、孤儿 `.gd.uid` 与 UID 冲突检查。
- 文档结构维护检查新增 `docs/zh` 页面导航覆盖、MkDocs 路径存在性和语义目录结构校验，要求文件目录与 Read the Docs 导航保持一致。
- `docs/zh` 从编号章节目录重组为 `overview/`、`kernel/`、`standard/`、`packages/`、`editor/`、`maintenance/` 语义目录；官方包页面拆到单包或小包组目录下，文件树与网站导航保持一致。
- 旧 GitHub Wiki 收敛为 Home、Sidebar 和 Footer 三个 Read the Docs 入口文件，维护检查要求不再保留章节页或迁移页，避免与正式文档长期双写。
- 根 README 改为 `README.md` / `README.zh.md` 双语切换结构，插件目录 README 收敛为分发说明；维护检查要求两个根 README 同步保留分层、测试和正式文档入口。
- `GFActionQueueSystem` 改为动作协议优先。推荐继续继承 `GFVisualAction`，同时支持实现 `execute()` / `can_execute()` / `cancel()` 等方法的对象。
- GUT 测试目录按框架层级调整为 `maintenance`、`kernel`、`standard`、`packages/official` 和 `fixtures`。
- 文档按当前源码结构重组为核心、标准库、官方包、编辑器工具和维护实践页面，并迁移为 MkDocs / Read the Docs 构建结构。

### Fixed

- 修复 `GFTypeEventSystem` 在派发中注册后立即注销仍可能在 flush 后落地的问题。
- 修复事件回调签名未拦截额外未绑定必填参数的问题。
- 修复 `GFStorageUtility` 注册迁移步骤但缺少完整迁移链时，旧存档仍被标记为当前 `save_version` 的问题。
- 修复包依赖循环会在依赖补齐时无限递归的问题。
- 修复 `GFArchitecture` 初始化超时或失败后，迟到恢复的异步 Installer 仍可能注册模块、工厂或别名的问题。
- 修复项目 Installer 配置错误导致初始化失败后，同一架构无法完成重试初始化的问题。
- 修复池化 `GFController` 归还对象池时丢失 `_ready()` 中注册的事件监听，或休眠期间继续接收事件的问题。
- 修复 `GFVariantJsonCodec` 与 `GFLogUtility` 遇到自引用 `Array` / `Dictionary` 时可能递归展开的问题。
- 修复 `GFSaveGraphUtility.apply_scope()` 处理损坏存档时可能触发类型崩溃的问题。
- 修复 `GFQuestUtility` 事件监听器残留和异常负计数进度问题。
- 修复插件文件生成在目标父目录不存在时无法创建文件的问题。
- 修复 `GFStorageUtility.save_data()` / `load_data()` / `load_data_result()` / `save_data_async()` / `load_data_async()` 空 `file_name` 会落入内部兜底文件名的问题。
- 修复 `GFInputMappingUtility` 玩家级动作状态未把真实输入来源纳入 binding key 的问题。
- 修复未重写 `tick()` / `physics_tick()` 的 `GFSystem` 被误判为具备真实 tick 能力的问题。
- 修复编辑器公开 API 注释与函数签名不一致的问题。
- 修复可选官方包被编辑器 preload 锁死，导致删除包目录后框架主体可能无法加载的问题。
- 修复 `GFBuildInfo` 与 `GFBuildInfoUtility` 在结构迁移中被漏搬的问题。
- 修复 `GFAccessGenerator` 对只贡献访问器记录、不追加源码的包扩展误报缺少源码钩子的问题。
- 修复空 `GFSourceBuilder` 构建结果包含孤立换行，导致访问器扩展空源码判断失败的问题。

### Removed

- 移除旧源码路径兼容。直接 `preload()` / `load()` 旧路径的项目需要迁移到新目录。
- 移除旧类名：`GFInputUtility`、`GFValidationUtility`、`GFDecimalStringUtility`、`GFScriptTypeUtility`、`GFTagUtility`、`GFTextFitUtility`、`GFNodeTreeUtility`、`GFVariantUtility`、`GFAttribute`。
- 移除旧顶层目录：`addons/gf/base`、`addons/gf/core`、`addons/gf/editor`、`addons/gf/foundation`、`addons/gf/input`、`addons/gf/utilities`、`addons/gf/extensions`。
- 移除 `gf_plugin_actions.gd` 内部 helper 的旧调用名 `get_package_menu_entries()`，统一通过 `get_menu_entries()` 获取菜单记录。

### API Changes

- 新增 ProjectSettings：
  - `gf/packages/enabled`
  - `gf/packages/auto_install_enabled_installers`
  - `gf/packages/export_exclude_disabled`
  - `gf/packages/export_fail_on_disabled_references`
- 新增 `GFPackageSettings` 包查询、启用状态、依赖解析、扩展路径收集、导出策略和诊断接口。
- `GFPackageManifest` 新增包启用、编辑器扩展、导出插件和访问器扩展字段。
- 包级访问器扩展脚本可实现 `append_access_records(records)`、`append_access_source(builder, records)` 或 `get_access_source_sections(records)`。
- 包级编辑器动作脚本可实现 `get_template_records()` 贡献脚本模板；模板记录至少应包含 `type`、`label`、`base_class` 和 `template`。
- `GFConfigAccessGenerator.DEFAULT_PROVIDER_ACCESSOR` 改为 `null`，生成的 provider 参数类型改为 `Variant`；需要默认读取标准库导表 provider 的项目应显式传入 provider accessor 表达式。
- `GFDiagnosticsUtility` 新增 `register_snapshot_section_provider()`、`register_tool_snapshot_provider()`、`add_monitor_to_preset()` 及对应注销 / 查询方法，用于包或项目向诊断系统贡献数据而不反向污染 `standard`。
- `GFLevelUtility` 新增 `register_runtime_cleanup()`、`unregister_runtime_cleanup()`、`has_runtime_cleanup()` 和 `get_runtime_cleanup_ids()`。
- `GFInteractionContext` / `GFInteractionFlow` 新增 `with_capability_provider()`，用于显式接入能力查询 provider。
- `GFPluginActions` 不再公开标准库或 Capability 包模板的固定菜单 ID 常量；扩展模板应通过标准库扩展记录或包 manifest 动态注册。
- `GFArchitecture.get_model()`、`get_system()`、`get_utility()`、`get_local_model()`、`get_local_system()`、`get_local_utility()` 新增可选参数 `require_ready = false`；对应代理方法同步支持。
- `GFTimeUtility` 继承 `GFTimeProvider`；自定义时间工具如果要被 `GFArchitecture` 自动识别，应继承该内核协议。
- `GFActionQueueSystem.enqueue()`、`push_front()`、`enqueue_to()`、`enqueue_parallel()` 等动作入口的动作参数放宽为 `Object` / `Array`。
- `GFActionInterceptor.before_execute()`、`after_execute()` 与 `GFActionInterceptionResult.replace_with()` 改为接收 `Object`。
- `GFStateMachine.start(initial_state_name, msg = {}, emit_changed = true)` 新增 `emit_changed` 参数。
- `GFSystem` 与 `GFUtility` 支持可选公开属性 `tick_enabled` / `physics_tick_enabled`。
- `GFVariantData.duplicate_variant(value, deep = true, duplicate_resources = false)` 支持可选 Resource 复制。
- `GFVariantData.duplicate_collection(value, deep = true)` 提供集合字段复制入口。
- 纯数据存取 API 传入空 `file_name` 时会明确返回失败。

### Migration Guide

- 直接引用旧路径的代码需要按新结构迁移：内核看 `addons/gf/kernel`，标准能力看 `addons/gf/standard`，官方包看 `addons/gf/packages/official/<package>`。
- 使用旧类名的代码需要迁移到新类名。
- 如果项目依赖纯代码状态机启动时不发 `state_changed`，调用 `start(initial_state_name, msg, false)`。
- 如果项目曾误传空字符串给存档读写接口并依赖兜底文件名，请改为传入明确文件名。
- 使用 `register_migration()` 时请保证旧版本到当前 `save_version` 的迁移链完整。
- 如果项目希望所有存档版本变化都必须有显式迁移链，请设置 `GFStorageUtility.strict_schema_migrations = true`。
- 如果项目代码直接引用了内核编辑器内部的 SaveGraph 校验菜单常量，请改用 Save 包 manifest 注册的编辑器动作入口。
- 如果项目代码直接引用了旧的标准库或 Capability 模板菜单 ID 常量，请改为读取 `GFPluginActions.get_menu_entries()` 或通过对应扩展记录注册模板。
- 如果项目代码直接调用过内部 `GFPluginActions.get_package_menu_entries()`，请改为读取 `get_menu_entries()` 后按菜单 ID 或 section 过滤。
- 如果项目依赖 `GFLevelUtility.restart_level()` 自动清理 ActionQueue，请在装配时调用 `register_runtime_cleanup()` 显式注册清理回调。
- 如果项目依赖 `GFInteractionContext.get_target_capability()` / `get_sender_capability()` 自动寻找 Capability 包，请改为对上下文或 flow 调用 `with_capability_provider(capabilities)`。
- 事件回调方法如果声明了额外必填参数，请改为默认参数或使用 `Callable(...).bind(...)` 绑定额外参数。
- 禁用或删除官方包前，请确认项目脚本、场景、资源、preload 和生成访问器不再引用该包。
- 如果项目生成过旧版 `GFAccess`，调整包启用状态后请重新生成访问器。
- 如果项目自定义时间工具希望继续参与架构 tick 缩放，应改为继承 `GFTimeProvider` 或注册继承该协议的 Utility。
- 单个测试文件路径已按层级迁移；完整测试命令保持使用 `-ginclude_subdirs`。

### Affected Files

- `addons/gf/kernel/core/gf.gd`
- `addons/gf/kernel/core/gf_architecture.gd`
- `addons/gf/kernel/core/gf_script_type_inspector.gd`
- `addons/gf/kernel/core/gf_type_event_system.gd`
- `addons/gf/kernel/base/gf_time_provider.gd`
- `addons/gf/kernel/package/**`
- `addons/gf/kernel/editor/**`
- `addons/gf/standard/**`
- `addons/gf/packages/official/**`
- `addons/gf/packages/README.md`
- `tests/gf_core/maintenance/**`
- `tests/gf_core/kernel/**`
- `tests/gf_core/standard/**`
- `tests/gf_core/packages/official/**`
- `docs/zh/**`
- `mkdocs.yml`
- `.readthedocs.yaml`
- `docs/requirements.txt`
- `README.md`
- `addons/gf/README.md`
- `ASSET_LIBRARY.md`
