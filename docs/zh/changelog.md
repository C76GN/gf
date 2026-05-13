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

## [3.2.0] - 2026-05-13

**版本概述**：未发布变更收敛为框架自身的通用能力，并将扩展体系定型为官方原子层加项目/社区组合层：官方扩展保持原子化，项目、社区或外部扩展负责组合。

### 🚀 新增特性

- 新增 `GFNodeStateMachineValidator`，用于校验节点状态机的空组、重复状态名、初始状态和条件/行为资源挂接，并返回 `GFValidationReport`。
- `GFNodeStateMachine` Inspector 增加结构验证入口，方便在编辑器中快速检查状态机配置。
- `GFDiagnosticsUtility` 新增只读场景树快照与 `diagnostics.scene` 命令，可按深度、节点数量、分组、脚本路径等选项采集结构摘要。
- `GFResourceTableEditor` 新增搜索过滤、可见行索引、排序、插入、复制、移动、移除和可见行提交接口。
- 新增 `GFPointerActivityUtility`，用于把显式转发的鼠标/触摸事件整理为按下、移动、拖拽和空闲状态。
- 新增 `GFTileMetadataLayer`，在通用格子字典上提供元数据绘制、字段擦除、按值查询、schema 和 `GFTileMapCache` 转换能力。
- 新增 `GFAudioBackend` 可插拔音频后端协议，`GFAudioUtility` 可按后端声明接管部分 BGM、SFX、环境音、空间音效和总线音量请求。
- 新增 `GFAudioBankTools`，支持扫描音频路径、按路径生成 `GFAudioBank`、向现有 bank 导入片段，并检查音频扩展名和 bus 配置。
- 新增 `GFAudioBank` Inspector 验证入口，复用 `GFAudioBankTools.validate_bank_playback()` 进行播放前检查。
- Combat 扩展新增 `GFProjectile2D`、`GFProjectile3D`、`GFProjectileMotion`、`GFLinearProjectileMotion`、`GFHomingProjectileMotion` 和 `GFProjectileLifetimePolicy`，以 Resource 策略组合移动和生命周期，命中仍通过 `GFCombatHitContext` 发送。
- Combat 扩展新增 `GFModifiedAttributeSet`，用于集中管理一组运行时 `GFModifiedAttribute`。
- `GFHitCollisionShapeConfig2D` / `GFHitCollisionShapeConfig3D` 新增 `debug_color`，HitBox / HurtBox 新增 `collision_shape_configs` 与 `apply_collision_shape_configs()` 以支持多个自动生成碰撞形状。
- `GFExtensionManifest` 保留 `optional_dependencies` 作为社区、项目或外部扩展的弱提示；官方扩展不得使用它表达内部协作。

### 🔄 机制更改

- `GFAudioUtility` 保留默认 Godot 播放路径，只有当前后端明确声明可处理并成功返回时才接管请求；不支持的路径继续回退到原实现。
- `GFDiagnosticsUtility.collect_snapshot()` 可通过 `include_scene_tree` 显式包含场景树摘要，默认仍不采集场景树以避免额外开销。
- `GFProjectileLifetimePolicy` 可按成功命中次数结束发射体；`GFProjectile2D` / `GFProjectile3D` 会在上下文中记录命中尝试次数和成功命中次数。
- `extensions` 基础设施统一承载可选能力：目录、manifest 文件、核心类、ProjectSettings 键和维护测试路径均使用扩展命名。
- 官方扩展边界固定为原子化：manifest 只能依赖 `gf.kernel` 和 `gf.standard`，不得声明可选依赖，也不得在源码中引用、探测或 preload 其他官方扩展。
- 跨官方扩展组合只能发生在项目、社区扩展或外部扩展层；框架本体不内置 bridge 扩展矩阵，避免组合数量失控。
- 禁用扩展引用审计默认改为严格模式，导出发现项目仍引用禁用扩展时默认报错。
- `GFExtensionSettings.get_manifest_graph_report()` 会把缺失可选依赖作为 warning 记录，不让扩展图失败，也不会把可选依赖加入启用闭包。
- 本版本所有官方扩展的 `version` 同步为 `3.2.0`；Combat 扩展因新增发射体、多碰撞形状配置和运行时属性集合，将 `extension_version` 递增为 `1.3.0`，其余未发生扩展内公开行为变化的官方扩展保持原有 `extension_version`。

### ⚠️ 废弃与移除

- 公开 API 只保留当前扩展命名。
- 移除官方扩展之间的软协作入口：`GFShakeAction`、Interaction Capability provider 和相关查询辅助。

### 🔌 API 变动说明

- 新增公开类：`GFNodeStateMachineValidator`、`GFAudioBackend`、`GFAudioBankTools`、`GFPointerActivityUtility`、`GFTileMetadataLayer`、`GFProjectile2D`、`GFProjectile3D`、`GFProjectileMotion`、`GFLinearProjectileMotion`、`GFHomingProjectileMotion`、`GFProjectileLifetimePolicy`。
- 新增公开类：`GFModifiedAttributeSet`。
- `GFHitCollisionShapeConfig2D` / `GFHitCollisionShapeConfig3D` 新增 `debug_color`；`GFHitBox2D`、`GFHurtBox2D`、`GFHitBox3D`、`GFHurtBox3D` 新增 `collision_shape_configs`、`apply_collision_shape_configs()`、`get_generated_collision_shapes()` 和 `clear_generated_collision_shapes()`。
- 新增 `GFAudioUtility.set_audio_backend()`、`get_audio_backend()`、`clear_audio_backend()` 和 `get_debug_snapshot()`。
- 新增 `GFExtensionManifest.optional_dependencies`；`to_dictionary()` 会输出该字段。
- `GFExtensionSettings.get_manifest_graph_report()` 新增 `warning_count` 与 `optional_dependency_warnings`，`get_extension_selection_report()` 同步暴露可选依赖提示。
- 扩展体系公开类固定为 `GFExtensionManifest`、`GFExtensionCatalog`、`GFExtensionSettings` 和 `GFExtensionUsageAudit`。
- 扩展 manifest 文件固定为 `gf_extension.json`，扩展自身版本字段固定为 `extension_version`，源码入口固定为 `addons/gf/extensions`。
- 扩展 ProjectSettings 固定使用 `gf/extensions/*`；相关方法也统一使用 extension 命名。
- `gf/extensions/export_fail_on_disabled_references` 默认值改为 `true`。
- 移除官方扩展中的软协作适配：Feedback 不再提供 `GFShakeAction`，Interaction 不再提供 Capability provider、`GFInteractionContext.inject_dependencies()`、`sender_as()`、`target_as()`、`get_*_capability()` 或 `get_group_receivers()`；这些组合应移到项目、社区扩展或外部扩展。
- 新增 `GFDiagnosticsUtility.collect_scene_tree_snapshot()`，并扩展 `collect_snapshot()` 的 `include_scene_tree` / `scene_tree_options` 选项。
- 新增 `GFResourceTableEditor` 的资源列表操作和过滤相关公开接口；既有 `commit_cell_value()` 行索引语义保持为原始资源索引。
- 发射体节点默认不解释 payload 内容；项目可继续把 `GFCombatHitContext.payload` 解释为伤害、治疗、交互或任意自定义命中语义。
- `GFProjectileLifetimePolicy.max_impacts` 可用于对象池、穿透或多目标命中这类通用生命周期控制；它只统计成功发送的命中，不定义穿透筛选或伤害规则。

### 📘 升级指南

- 项目集成应统一使用 `addons/gf/extensions/**`、`gf_extension.json`、`extension_version`、`GFExtension*` 和 `gf/extensions/*`。
- 移除对官方扩展之间隐式协作的依赖；需要组合多个官方扩展时，在项目代码、社区扩展或外部扩展中显式装配。
- 如果项目使用过 `GFShakeAction` 或 Interaction 到 Capability 的查询辅助，应在项目层创建自己的动作/查询适配器，或放入社区/外部组合扩展。
- 重新生成访问器，并清理禁用扩展的 preload、脚本、场景和资源引用；默认严格导出审计会拦截这些残留引用。

### 📁 核心受影响文件

- `addons/gf/kernel/editor/gf_resource_table_editor.gd`
- `addons/gf/kernel/core/gf_architecture.gd`
- `addons/gf/kernel/extension/gf_extension_manifest.gd`
- `addons/gf/kernel/extension/gf_extension_settings.gd`
- `addons/gf/kernel/editor/extension/gf_extension_manager_dock.gd`
- `addons/gf/standard/foundation/math/gf_tile_metadata_layer.gd`
- `addons/gf/standard/input/runtime/gf_pointer_activity_utility.gd`
- `addons/gf/standard/state_machine/node/**`
- `addons/gf/standard/utilities/audio/**`
- `addons/gf/standard/utilities/debug/gf_diagnostics_utility.gd`
- `addons/gf/extensions/official/combat/attributes/**`
- `addons/gf/extensions/official/combat/hit_detection/**`
- `addons/gf/extensions/official/combat/projectiles/**`
- `tests/gf_core/kernel/editor/test_gf_resource_table_editor.gd`
- `tests/gf_core/kernel/core/test_gf_singleton.gd`
- `tests/gf_core/kernel/extension/test_gf_extension_manifest.gd`
- `tests/gf_core/maintenance/test_layer_boundary_validation.gd`
- `tests/gf_core/standard/foundation/math/test_gf_tile_metadata_layer.gd`
- `tests/gf_core/standard/input/runtime/test_gf_pointer_activity_utility.gd`
- `tests/gf_core/standard/state_machine/node/test_gf_node_state_machine_validator.gd`
- `tests/gf_core/standard/utilities/audio/test_gf_audio_utility.gd`
- `tests/gf_core/standard/utilities/audio/test_gf_audio_bank_tools.gd`
- `tests/gf_core/standard/utilities/debug/test_gf_diagnostics_utility.gd`
- `tests/gf_core/extensions/official/combat/test_gf_combat_extension.gd`
- `tests/gf_core/extensions/official/combat/test_gf_projectiles.gd`
- `docs/zh/standard/input-flow/state-machines.md`
- `docs/zh/standard/utilities/runtime/audio.md`
- `docs/zh/extensions/combat/index.md`
