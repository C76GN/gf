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

本页面只保留最近三个大版本线的更新记录，当前保留 `1.34.x`、`1.33.x` 与 `1.32.x`。更早版本的完整历史请通过 Git 历史或 GitHub Releases 查询，避免 Wiki 页面随着每次发布持续膨胀。

---

## [1.34.0] - 2026-05-09

**版本概述**：新增一组通用运行时准备、诊断报告、输入图标、网络同步原语和 FlowGraph 编辑器元数据能力，保持 GF 1.x 兼容。

### 🚀 新增特性 (Added)
- 新增 `GFRenderWarmupManifest` 与 `GFRenderWarmupUtility`，支持按清单或节点树收集渲染资源，并按帧预算预热 Mesh、Material、Texture、Shader 等通用资源。
- 新增 `GFSupportReportUtility`，支持聚合用户描述、构建信息、诊断快照、日志和项目自定义分区，并导出 JSON、写入文件或交给项目回调提交。
- 新增 `GFInputIconAtlasProvider`，通过显式路径、纹理映射或路径模板把输入事件解析为项目自有图标资源。
- 新增 `GFFixedTickClock`、`GFNetworkSnapshot` 与 `GFNetworkHistoryBuffer`，提供固定 tick、状态快照、浅层 delta 和有限历史缓冲原语。
- 新增 `GFScriptTypeUtility` 与 `GFDecimalStringUtility`，将脚本继承判断和小数字符串规则收敛为可复用 Foundation API。

### 🔄 机制更改 (Changed)
- `GFFlowPort` 新增编辑器颜色、类型提示、类名提示和语义标签字段，并提供端口兼容性报告。
- `GFFlowGraph` 新增可选 `validate_port_compatibility` 校验和连接兼容性查询；默认关闭，旧资源行为保持兼容。
- 编辑器索引、访问器生成、能力系统、资源表过滤和插件诊断改为复用 `GFScriptTypeUtility`；数字格式化、大数和定点数解析改为复用 `GFDecimalStringUtility`。
- FlowGraph 字典校验报告改为复用 `GFValidationUtility.finalize_report()`，异步 Signal 等待清理改为复用内部支持脚本，返回字段与等待语义保持兼容。
- `GFRenderWarmupManifest` 与 `GFRenderWarmupUtility` 共用同一套预热条目规范化规则，避免清单描述与队列处理出现分叉。
- `GFNetworkSnapshot` 差量删除列表保留原始 key 类型，避免非字符串状态键在浅层 delta 中丢失类型。

### 🐛 Bug 修复 (Fixed)
- 加固输入图标、渲染预热和支持报告中的 Variant 到文本转换，避免非字符串配置值触发 Godot `String` 构造错误。

### 🔌 API 变动说明 (API Changes)
- 新增 API 均为向后兼容；未移除、重命名或改变现有公开类、信号、导出变量与公共方法签名。
- `GFRenderWarmupUtility` 与 `GFSupportReportUtility` 是可注册 Utility；网络同步原语为独立 `RefCounted`，不需要注册到架构。
- `GFRenderWarmupManifest` 新增静态方法 `normalize_entry(entry)`；`GFScriptTypeUtility` 与 `GFDecimalStringUtility` 是 Foundation API，不需要注册到架构。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。需要更严格 FlowGraph 端口检查时，显式开启 `validate_port_compatibility`。
- 输入图标、支持报告提交和网络同步策略仍由项目层配置；GF 只提供通用抽象和数据结构。
- 项目层若已有同类脚本继承判断、小数字符串格式化或预热条目清洗辅助，可逐步替换为新的 Foundation / Manifest API。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/utilities/gf_render_warmup_manifest.gd`
- `addons/gf/utilities/gf_render_warmup_utility.gd`
- `addons/gf/utilities/gf_support_report_utility.gd`
- `addons/gf/input/gf_input_icon_atlas_provider.gd`
- `addons/gf/extensions/network/gf_fixed_tick_clock.gd`
- `addons/gf/extensions/network/gf_network_snapshot.gd`
- `addons/gf/extensions/network/gf_network_history_buffer.gd`
- `addons/gf/extensions/flow/gf_flow_port.gd`
- `addons/gf/extensions/flow/gf_flow_graph.gd`
- `addons/gf/foundation/reflection/gf_script_type_utility.gd`
- `addons/gf/foundation/formatting/gf_decimal_string_utility.gd`
- `addons/gf/extensions/common/gf_async_wait_support.gd`
- `tests/gf_core/**`
- `docs/wiki/11. 基础层 (Foundation Layer).md`
- `docs/wiki/07. 高级扩展 (Advanced Extensions).md`
- `docs/wiki/08. 实用工具箱 (Utility Toolkit).md`

---

## [1.33.0] - 2026-05-09

**版本概述**：收敛框架内部重复辅助逻辑，新增通用 Variant Foundation 工具，并保持 GF 1.x 公开行为兼容。

### 🚀 新增特性 (Added)
- 新增 `GFVariantUtility`，提供 Dictionary/Array 深拷贝、递归默认值合并以及 Vector2/Vector3/Color 与数组之间的 JSON 友好转换。

### 🔄 机制更改 (Changed)
- Combat Hit/HurtBox、Interaction Sensor/Receiver、节点序列化器和基础依赖作用域改为复用内部 support 脚本，减少 2D/3D、收发桥接与基类重复实现，公开 API 与行为保持不变。
- 节点序列化器的通用字段采集与应用改为规格表驱动，保留现有存档 payload 字段和应用顺序语义。
- 校验、存储、导表字段、设置定义、输入重映射和交互/命中上下文的集合复制逻辑改为复用 `GFVariantUtility`。

### 🔌 API 变动说明 (API Changes)
- 新增 `GFVariantUtility` 为向后兼容的 Foundation API，不需要注册到 `Gf.register_utility()`。
- 未移除、重命名或改变现有公开类、信号、导出变量与公共方法签名。

### 📘 升级指南 (Migration Guide)
- 旧项目无需迁移。项目层若已有相同的 Dictionary/Array 深拷贝或 Vector/Color 数组转换辅助，可逐步替换为 `GFVariantUtility`。
- `GFVariantUtility.duplicate_variant()` 不会序列化 `Object` / `Resource` 引用；需要持久化对象时仍应由项目层转换为纯数据。

### 📁 核心受影响文件 (Affected Files)
- `addons/gf/foundation/variant/gf_variant_utility.gd`
- `addons/gf/base/gf_dependency_scope_support.gd`
- `addons/gf/base/gf_model.gd`
- `addons/gf/base/gf_system.gd`
- `addons/gf/base/gf_utility.gd`
- `addons/gf/base/gf_command.gd`
- `addons/gf/base/gf_query.gd`
- `addons/gf/extensions/common/**`
- `addons/gf/extensions/combat/**`
- `addons/gf/extensions/save/**`
- `addons/gf/extensions/interaction/**`
- `addons/gf/foundation/validation/**`
- `addons/gf/utilities/gf_storage_utility.gd`
- `addons/gf/utilities/gf_config_table_column.gd`
- `addons/gf/utilities/gf_setting_definition.gd`
- `addons/gf/input/**`
- `tests/gf_core/test_gf_variant_utility.gd`
- `docs/wiki/11. 基础层 (Foundation Layer).md`

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
