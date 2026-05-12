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

当前包结构重整仍处于未发布收口阶段，最终版本号需在发布确认时再确定。后续新工作仍先记录到未发布小节，发布时再合并为具体版本条目；旧版本历史以 Git 历史或 GitHub Releases 为准，避免正式 Wiki 长期膨胀。

---

## [未发布]

**版本概述**：本轮以最佳实践优先，集中偿还旧目录、旧命名和旧兼容债。源码分层收敛为 `kernel`、`standard`、`packages`，官方包和社区包有了 manifest、启用设置、编辑器包管理器和导出排除能力；同时修复事件、存档、输入、tick、状态机启动通知等边界问题，并系统重命名职责漂移的类。

### 🚀 新增特性 (Added)

- 新增 `GFPackageManifest`、`GFPackageCatalog` 与 `GFPackageSettings`，用于读取 `gf_package.json`、扫描官方/社区包、管理启用包 ID、补齐包依赖、收集启用包 Installer 和控制导出排除。
- `GFPackageSettings` 新增 manifest 扫描缓存控制和包依赖图报告接口，可清理缓存并一次性检查重复包 ID、缺失依赖、无效 manifest 与循环依赖。
- `GFPackageSettings` 新增 `gf/packages/export_fail_on_disabled_references` 策略和未知启用包诊断，方便 CI 或正式导出把“禁用包仍被引用”作为错误处理。
- 新增 `GFPackageUsageAudit`，用于检查禁用包是否仍被项目脚本、场景或资源通过路径或 `class_name` 直接引用。
- 新增编辑器 `GF Packages` 底部面板，可查看包名称、ID、版本、来源、说明、依赖、Installer、标签和校验状态，并启用/禁用官方包或社区包；面板支持分类、搜索、恢复默认、批量勾选和明确的保存设置动作。
- 新增包导出过滤插件：`gf/packages/export_exclude_disabled` 开启时，导出流程会跳过禁用包目录，减少最终导出体积。
- `GFPackageManifest` 新增 `enabled_by_default`；官方包默认启用，社区包默认不启用。
- `GFPackageManifest` 新增 `editor_inspector_paths`，包可以在 manifest 中声明自己的 `EditorInspectorPlugin` 扩展入口。
- `GFPackageManifest` 新增 `editor_action_paths`、`editor_dock_paths`、`export_plugin_paths` 与 `access_generator_extension_paths`，包可以声明菜单动作、底部面板、导出插件，并为访问器生成扩展提供统一声明入口。
- `GFAccessGenerator` 会执行启用包声明的访问器扩展脚本；扩展可以实现 `append_access_records(records)` 贡献类型记录，也可以实现 `append_access_source(builder, records)` 或 `get_access_source_sections(records)` 追加生成源码。
- `GFArchitecture`、`Gf`、`GFNodeContext`、`GFController`、`GFCommand`、`GFQuery`、`GFSystem` 与 `GFUtility` 的依赖查询新增兼容可选参数 `require_ready`，用于只返回已完成 `ready()` 的模块。
- `GFArchitecture` 新增 `is_module_ready(instance)`；`GFModel`、`GFSystem`、`GFUtility` 新增 `is_lifecycle_active()` 与 `is_ready_in_architecture()` 便捷方法。
- 新增 `GFPluginDockTools` 与 `GFStorageViewerDock`，将底部面板装配和 Save Viewer UI 从插件主脚本拆出。
- 新增 `addons/gf/standard/editor/gf_standard_editor_extensions.gd`，集中声明标准库自带的 Inspector、Dock 和导出插件扩展。
- 新增 Save 包编辑器菜单动作入口 `GFSaveEditorActions`，SaveGraph 诊断菜单由 Save 包 manifest 注册。
- 官方包中需要参与架构生命周期的服务新增包安装器：ActionQueue、Capability、Combat、Domain、Feedback、Network、Save 和 TurnBased 会通过各自 `package.gd` 注册包级 System/Utility。
- 所有官方包新增 `gf_package.json` manifest，并统一进入 `addons/gf/packages/official/<package>`。
- 新增 `GFFixedTickClock` 的单 tick 循环信号、预算耗尽诊断、`get_tick_factor()` 与 `get_lag_seconds()`。
- 新增网络字段级编码与快照 Schema：`GFNetworkFieldSerializer`、`GFNetworkSnapshotSchema`。
- 新增战斗通用动作、修正器、结果、数值槽和 2D/3D hitscan 桥：`GFCombatAction`、`GFCombatActionModifier`、`GFCombatActionResult`、`GFCombatGauge`、`GFHitScan2D`、`GFHitScan3D`。
- `GFHitBox2D`、`GFHitBox3D`、`GFHurtBox2D` 与 `GFHurtBox3D` 新增 `enabled_changed(enabled)` 信号，便于项目同步调试可见性或外部状态。
- 新增 `GFGridSelection2D`、`GFGridGenerationStep2D` 与 `GFGridGenerationPipeline2D`，提供通用 2D 网格生成管线。
- 新增编辑器 `GFSourceBuilder`，统一访问器和模板生成时的源码拼装、缩进、section 与文档注释格式。
- 新增 Foundation 级 `GFResultDictionary`，统一 `ok`、`data`、`metadata`、`error` 等结果字典字段和构造入口。
- `GFStorageUtility` 新增 `strict_schema_migrations`，项目可选择把“版本升高但没有显式迁移链”的存档读取视为失败。

### 🔄 机制更改 (Changed)

- 源码顶层收敛为 `addons/gf/kernel`、`addons/gf/standard`、`addons/gf/packages`。
- `kernel` 只承载框架启动、基础契约、架构容器、绑定、事件、AutoLoad、包基础设施和编辑器集成。
- `standard` 承载稳定标准库：`foundation`、输入体系、通用 Utility、状态机、命令、序列和 common 支撑。
- `packages/official` 承载随 GF 发布但保持可选边界的官方包；`packages/community` 作为项目本地或第三方包约定入口。
- 官方包内部结构规范化：包根只保留 manifest、可选安装器和说明文档，代码进入 `runtime`、`resources`、`nodes`、`editor`、`actions` 或包内稳定领域目录。
- 官方包之间不再声明强依赖；需要联动时通过协议、运行时接口或动态探测完成，保持每个官方包都能单独启用、禁用或删除。
- `kernel` 与 `standard` 不再硬 preload 官方包脚本；编辑器增强工具在可选包缺失时会自动跳过对应能力。
- Wiki 文档结构按当前 `kernel`、`standard`、`packages` 分层重排，旧的流水号功能页拆分为核心、标准库、官方包、编辑器与维护实践几组页面，降低大型页面和旧结构造成的查找成本。
- 包专属 Inspector 扩展从 `kernel/editor` 下放到对应官方包目录，并由核心插件按启用包 manifest 统一装载。
- 包专属菜单动作、底部面板、Inspector 和导出插件统一走 manifest 驱动装载，`plugin.gd` 只保留插件生命周期编排。
- 标准库自带的 BuildInfo 导出插件、节点状态机 Inspector、Pattern2D Inspector 和 Save Viewer 归属从 `kernel/editor` 收敛到 `standard`；`kernel` 只读取标准库声明并负责装载。
- Capability Inspector、Flow Graph Inspector、SaveGraph 诊断菜单和强类型访问器生成器会尊重包启用状态；对应包禁用时不再继续暴露或生成会引用该包的增强入口。
- Capability 访问器记录改由 Capability 包自己的访问器扩展贡献，`kernel` 不再内建官方能力包脚本识别逻辑。
- Interaction 包的 Capability 辅助会先检查 `gf.official.capability` 是否启用，再动态读取能力工具，避免包间联动绕过包启用状态。
- 可选包脚本加载收敛到 `GFPackageSettings`，调用方可通过包 ID 和包内相对路径解析启用包资源，减少散落的路径拼接与启用状态判断。
- `GFPackageSettings` 会缓存 manifest 扫描结果，编辑器面板、Inspector、访问器生成和运行时扩展查询在同一会话内不再反复读盘；包目录变化时可显式清理缓存。
- Debug 诊断、Level 运行时清理等标准能力改为通过包 ID 动态探测可选官方包，避免 `standard` 或其他可选包因硬 `class_name` 引用锁死 `action_queue`、`network` 等包。
- 包管理器和导出插件会在禁用包被项目文件直接引用时输出警告，降低导出排除造成缺文件的风险。
- `GFCapabilityUtility.tick()` 的失效 receiver 清理改为按 `prune_invalid_receivers_per_tick` 分批推进；主动调用 `prune_invalid_receivers()` 仍执行全量清理。
- GUT 测试目录按框架层级重排为 `tests/gf_core/maintenance`、`kernel`、`standard`、`packages/official` 和 `fixtures`。
- 维护测试新增 GF 源码脚本解析加载校验，用于提前发现漏搬脚本或丢失全局类导致的隐藏解析错误。
- 启用包的 `installer_paths` 会在 `Gf.init()` / `Gf.set_architecture()` 中先于项目级 `gf/project/installers` 执行；项目 Installer 仍可继续装配业务模块或覆盖绑定。
- 新项目会把默认启用的官方包 ID 明确写入 `gf/packages/enabled`，避免空数组被误读为“全部禁用”。
- 官方包 manifest 的 `installer_paths` 现在只声明包级生命周期服务；纯数据模型、动作对象、Resource 和节点桥接仍由项目或局部上下文按使用场景装配。
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
- 修复包依赖循环会在依赖补齐时无限递归的问题；循环依赖现在会停止递归、输出警告，并在包选择报告中暴露。
- 修复 `GFArchitecture` 初始化超时或失败后，迟到恢复的异步 Installer 仍可能注册模块、工厂或别名的问题。
- 修复项目 Installer 配置错误导致初始化失败后，修正配置并再次调用 `Gf.init()` 时同一架构仍保留旧失败状态、无法完成重试初始化的问题。
- 修复池化 `GFController` 在归还对象池时会丢失 `_ready()` 中注册的事件监听，或休眠期间继续接收事件的问题。
- 修复 `GFVariantJsonCodec` 与 `GFLogUtility` 遇到自引用 `Array` / `Dictionary` 时可能递归展开的问题；现在会写入稳定的循环引用标记。
- 修复 `GFSaveGraphUtility.apply_scope()` 处理损坏存档时，`sources`、`scopes`、子 scope 或 serializer `data` 不是字典会触发类型崩溃的问题；现在会返回失败结果并附带错误信息。
- 修复 `GFQuestUtility` 重新初始化、完成或取消最后一个监听事件任务后，事件监听器可能残留的问题。
- 修复 `GFQuestUtility.get_quest_progress()` 在异常负计数下可能返回小于 0 的进度值，和文档承诺的 `0.0` 到 `1.0` 区间不一致的问题。
- 修复插件文件生成在目标父目录不存在时无法创建文件的问题。
- 移除内核编辑器中已失效的 SaveGraph 校验菜单常量，避免测试和插件菜单注册继续引用不存在的动作。
- 修复 `GFStorageUtility.save_data()` / `load_data()` / `load_data_result()` / `save_data_async()` / `load_data_async()` 空 `file_name` 会落入内部兜底文件名的问题。
- 修复 `GFInputMappingUtility` 玩家级动作状态未把真实输入来源纳入 binding key，导致同一玩家多来源输入可能互相覆盖的问题。
- 修复未重写 `tick()` / `physics_tick()` 的 `GFSystem` 被误判为具备真实 tick 能力的问题。
- 修复编辑器公开 API 注释与函数签名不一致的问题。
- 修复可选官方包被编辑器 preload 锁死，导致删除包目录后框架主体可能无法加载的问题。
- 修复 `GFBuildInfo` 与 `GFBuildInfoUtility` 在结构迁移中被漏搬，导致构建信息导出、诊断快照和支持报告脚本解析失败的问题。
- 修复 `gf/packages/enabled` 为空时，Interaction/Capability 相关测试仍假设官方包启用的问题；全禁用状态现在有维护测试覆盖。
- 修正脚本文档注释中的英文残留和中英混杂表达，使公开 API 注释保持中文说明和术语一致性。

### ⚠️ 废弃与移除 (Deprecated/Removed)

- 本轮结构重整不保留旧源码路径兼容。直接 `preload()` / `load()` 旧路径的项目需要迁移到新目录。
- 移除旧类名：`GFInputUtility`、`GFValidationUtility`、`GFDecimalStringUtility`、`GFScriptTypeUtility`、`GFTagUtility`、`GFTextFitUtility`、`GFNodeTreeUtility`、`GFVariantUtility`、`GFAttribute`。
- 移除旧顶层目录：`addons/gf/base`、`core`、`editor`、`foundation`、`input`、`utilities`、`extensions`。对应内容已迁入 `kernel`、`standard` 或 `packages`。

### 🔌 API 变动说明 (API Changes)

- 新增 `GFPackageSettings`：
  - `clear_manifest_cache()`
  - `get_default_enabled_package_ids()`
  - `get_enabled_package_ids()`
  - `set_enabled_package_ids(package_ids, include_dependencies = true)`
  - `get_manifest_by_id(package_id, include_community = true)`
  - `has_package(package_id, include_community = true)`
  - `get_package_resource_path(package_id, relative_path = "", include_community = true)`
  - `is_package_enabled(package_id, include_dependencies = true, include_community = true)`
  - `load_enabled_package_script(package_id, relative_path, include_dependencies = true, include_community = true)`
  - `get_enabled_manifests(include_community = true)`
  - `get_disabled_manifests(include_community = true)`
  - `get_enabled_installer_paths(include_community = true)`
  - `get_enabled_editor_action_paths(include_community = true)`
  - `get_enabled_editor_dock_paths(include_community = true)`
  - `get_enabled_editor_inspector_paths(include_community = true)`
  - `get_enabled_export_plugin_paths(include_community = true)`
  - `get_enabled_access_generator_extension_paths(include_community = true)`
  - `resolve_package_dependencies(package_ids, manifests = [])`
  - `get_manifest_graph_report(manifests = [])`
  - `get_package_selection_report()`
- 新增 ProjectSettings：
  - `gf/packages/enabled`
  - `gf/packages/auto_install_enabled_installers`
  - `gf/packages/export_exclude_disabled`
  - `gf/packages/export_fail_on_disabled_references`
- `GFPackageManifest` 新增 `enabled_by_default` 与 `editor_inspector_paths` 字段，并在 `to_dictionary()` 中输出。
- `GFPackageManifest` 新增 `editor_action_paths`、`editor_dock_paths`、`export_plugin_paths` 与 `access_generator_extension_paths` 字段，并在 `to_dictionary()` 中输出；manifest 校验会要求这些扩展路径位于包根目录内。
- `GFPackageSettings` 新增 `get_enabled_editor_action_paths()`、`get_enabled_editor_dock_paths()`、`get_enabled_editor_inspector_paths()`、`get_enabled_export_plugin_paths()` 与 `get_enabled_access_generator_extension_paths()`。
- `GFPackageSettings` 新增 `should_fail_export_on_disabled_package_references()` 与 `set_fail_export_on_disabled_package_references(enabled)`；`get_package_selection_report()` 新增 `unknown_enabled_ids` 与整体 `ok` 字段。
- 包级访问器扩展脚本新增约定方法：实现 `append_access_records(records)` 可向生成器贡献类型记录；实现 `append_access_source(builder, records)` 可直接追加 `GFSourceBuilder` 源码；实现 `get_access_source_sections(records)` 可返回字符串数组作为源码片段。
- `GFArchitecture.get_model()`、`get_system()`、`get_utility()`、`get_local_model()`、`get_local_system()`、`get_local_utility()` 新增可选参数 `require_ready = false`；对应 `Gf`、`GFNodeContext`、`GFController`、`GFCommand`、`GFQuery`、`GFSystem`、`GFUtility` 代理同步支持。
- `GFArchitecture.is_module_ready(instance)` 新增为模块 ready 状态查询入口。
- `GFModel`、`GFSystem`、`GFUtility` 新增 `is_lifecycle_active()` 与 `is_ready_in_architecture()`。
- `GFCapabilityUtility` 新增 `prune_invalid_receivers_per_tick`，控制 tick 自动清理失效 receiver 的单次预算。
- `GFActionQueueSystem.enqueue()`、`push_front()`、`enqueue_to()`、`enqueue_parallel()` 等动作入口的动作参数放宽为 `Object` / `Array`；`GFActionInterceptor.before_execute()`、`after_execute()` 与 `GFActionInterceptionResult.replace_with()` 同步改为接收 `Object`。
- `GFStateMachine.start(initial_state_name, msg = {}, emit_changed = true)` 新增可选 `emit_changed` 参数，默认启动时发出状态变化信号。
- `GFSystem` 与 `GFUtility` 支持可选公开属性 `tick_enabled` / `physics_tick_enabled`，用于显式声明参与 tick 缓存。
- `GFVariantData.duplicate_variant(value, deep = true, duplicate_resources = false)` 支持可选 Resource 复制。
- `GFVariantData.duplicate_collection(value, deep = true)` 提供集合字段复制入口。
- `GFStorageUtility.strict_schema_migrations` 新增为兼容默认关闭的公开属性；打开后，没有注册迁移步骤的版本升高也会被视为迁移链缺失。
- 纯数据存取 API 传入空 `file_name` 时会明确返回失败：同步保存返回 `ERR_INVALID_PARAMETER`，同步读取写入失败的 `last_load_result`，异步接口返回 `ERR_INVALID_PARAMETER` 并发出失败完成信号。

### 📘 升级指南 (Migration Guide)

- 直接引用旧路径的代码需要按新结构迁移：内核看 `addons/gf/kernel`，标准能力看 `addons/gf/standard`，官方包看 `addons/gf/packages/official/<package>`。
- 使用旧类名的代码需要迁移到新类名。尤其是输入辅助、Variant、标签、节点树、校验报告、文本适配和属性修正相关类。
- 如果项目依赖纯代码状态机启动时不发 `state_changed`，调用 `start(initial_state_name, msg, false)`；推荐新代码保留默认通知行为。
- 如果项目曾误传空字符串给存档读写接口并依赖兜底文件名，请改为传入明确文件名。
- 使用 `register_migration()` 时请保证旧版本到当前 `save_version` 的迁移链完整；如果只想用默认值补齐字段，不注册迁移步骤即可。
- 如果项目希望所有存档版本变化都必须有显式迁移链，请设置 `GFStorageUtility.strict_schema_migrations = true`；旧的宽松默认行为仍保持兼容。
- 如果项目代码直接引用了内核编辑器内部的 `MENU_VALIDATE_SAVE_GRAPH` 常量，请改用 Save 包 manifest 注册的编辑器动作入口；该常量已不再代表有效菜单项。
- 如果项目读取任务进度时依赖负数百分比，请改读任务调试报告里的原始计数；`get_quest_progress()` 现在始终返回文档承诺的 `0.0` 到 `1.0`。
- 事件回调方法如果声明了额外必填参数，请改为默认参数或使用 `Callable(...).bind(...)` 绑定额外参数。
- 包管理器的“禁用”不会让编辑器中的脚本或 `class_name` 消失；它影响启用包 Installer 和导出排除。导出排除禁用包前，请确认项目没有场景、资源或 preload 仍引用该包。若项目完全不使用某个官方包，也可以删除对应包目录，但仍要先清理项目侧直接引用。
- 如果项目生成过旧版 `GFAccess` 且禁用了 Capability 包，请重新生成访问器，避免保留对 capability 包路径的旧引用。
- 如果项目直接引用过 `addons/gf/kernel/editor/gf_build_info_export_plugin.gd`、`gf_node_state_machine_inspector_plugin.gd` 或 `gf_pattern_2d_*`，请迁移到对应的 `standard` 新路径；这些脚本不再归属内核。
- 如果社区包已经填写了 `access_generator_extension_paths`，请确保扩展脚本实现 `append_access_source(builder, records)` 或 `get_access_source_sections(records)`，否则生成时会输出警告。
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
- `addons/gf/kernel/editor/gf_plugin_actions.gd`
- `addons/gf/kernel/editor/gf_plugin_dock_tools.gd`
- `addons/gf/kernel/editor/gf_plugin_inspector_tools.gd`
- `addons/gf/kernel/editor/gf_plugin_project_settings.gd`
- `addons/gf/plugin.gd`
- `addons/gf/standard/editor/gf_standard_editor_extensions.gd`
- `addons/gf/standard/foundation/math/editor/gf_pattern_2d_editor_property.gd`
- `addons/gf/standard/foundation/math/editor/gf_pattern_2d_inspector_plugin.gd`
- `addons/gf/standard/state_machine/node/editor/gf_node_state_machine_inspector_plugin.gd`
- `addons/gf/standard/utilities/debug/editor/gf_build_info_export_plugin.gd`
- `addons/gf/packages/official/save/editor/gf_save_editor_actions.gd`
- `addons/gf/packages/official/save/graph/gf_save_graph_utility.gd`
- `addons/gf/packages/official/save/core/gf_save_source.gd`
- `addons/gf/packages/official/save/serializers/gf_node_serializer_registry.gd`
- `addons/gf/packages/official/domain/level/gf_level_utility.gd`
- `addons/gf/packages/official/domain/quest/gf_quest_utility.gd`
- `addons/gf/packages/official/capability/editor/gf_capability_inspector_plugin.gd`
- `addons/gf/packages/official/flow/editor/gf_flow_graph_inspector_plugin.gd`
- `addons/gf/standard/utilities/storage/editor/gf_storage_viewer_dock.gd`
- `addons/gf/standard/utilities/storage/gf_storage_utility.gd`
- `addons/gf/standard/utilities/debug/gf_diagnostics_utility.gd`
- `addons/gf/standard/utilities/debug/gf_build_info.gd`
- `addons/gf/standard/utilities/debug/gf_build_info_utility.gd`
- `addons/gf/standard/state_machine/pure/gf_state_machine.gd`
- `addons/gf/standard/input/runtime/gf_input_assist_utility.gd`
- `addons/gf/standard/input/runtime/gf_input_mapping_utility.gd`
- `addons/gf/standard/foundation/variant/gf_variant_data.gd`
- `addons/gf/standard/foundation/variant/gf_variant_json_codec.gd`
- `addons/gf/standard/foundation/validation/gf_result_dictionary.gd`
- `addons/gf/packages/official/*/gf_package.json`
- `addons/gf/packages/official/*/package.gd`
- `addons/gf/packages/README.md`
- `addons/gf/packages/official/README.md`
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
- `docs/wiki/02. 生命周期与初始化 (Lifecycle).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`
- `docs/wiki/更新日志 (Changelog).md`
- `README.md`
- `addons/gf/README.md`
- `ASSET_LIBRARY.md`
