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

## [未发布]

**版本概述**：未发布变更收敛为框架自身的通用能力：可观测性与编辑器资源表增强、输入活动与格子元数据工具、可插拔音频后端、状态机结构校验、音频集合导入/校验辅助，以及 Combat 包中不绑定业务规则的发射体组合节点。

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
- Combat 包新增 `GFProjectile2D`、`GFProjectile3D`、`GFProjectileMotion`、`GFLinearProjectileMotion`、`GFHomingProjectileMotion` 和 `GFProjectileLifetimePolicy`，以 Resource 策略组合移动和生命周期，命中仍通过 `GFCombatHitContext` 发送。
- `GFPackageManifest` 新增 `optional_dependencies`，用于声明不会自动启用、也不允许硬引用的可选协作包。

### 🔄 机制更改

- `GFAudioUtility` 保留默认 Godot 播放路径，只有当前后端明确声明可处理并成功返回时才接管请求；不支持的路径继续回退到原实现。
- `GFDiagnosticsUtility.collect_snapshot()` 可通过 `include_scene_tree` 显式包含场景树摘要，默认仍不采集场景树以避免额外开销。
- `GFProjectileLifetimePolicy` 可按成功命中次数结束发射体；`GFProjectile2D` / `GFProjectile3D` 会在上下文中记录命中尝试次数和成功命中次数。
- 官方包边界从“绝对不能互相硬引用”调整为“只能硬引用 manifest `dependencies` 中声明的官方依赖”；未声明依赖的跨包引用仍由维护测试阻止，可选协作应使用 `optional_dependencies`、扩展点、项目装配或 bridge 包。
- `GFPackageSettings.get_manifest_graph_report()` 会把缺失可选依赖作为 warning 记录，不让包图失败，也不会把可选依赖加入启用闭包。
- Feedback 与 Interaction 包通过 manifest 声明可选协作关系，并分别将 `package_version` 递增为 `1.1.0`；Combat 包因新增追踪发射体与命中次数生命周期，将 `package_version` 递增为 `1.2.0`。

### 🔌 API 变动说明

- 新增公开类：`GFNodeStateMachineValidator`、`GFAudioBackend`、`GFAudioBankTools`、`GFPointerActivityUtility`、`GFTileMetadataLayer`、`GFProjectile2D`、`GFProjectile3D`、`GFProjectileMotion`、`GFLinearProjectileMotion`、`GFHomingProjectileMotion`、`GFProjectileLifetimePolicy`。
- 新增 `GFAudioUtility.set_audio_backend()`、`get_audio_backend()`、`clear_audio_backend()` 和 `get_debug_snapshot()`。
- 新增 `GFPackageManifest.optional_dependencies`；`to_dictionary()` 会输出该字段。
- `GFPackageSettings.get_manifest_graph_report()` 新增 `warning_count` 与 `optional_dependency_warnings`，`get_package_selection_report()` 同步暴露可选依赖提示。
- 新增 `GFDiagnosticsUtility.collect_scene_tree_snapshot()`，并扩展 `collect_snapshot()` 的 `include_scene_tree` / `scene_tree_options` 选项。
- 新增 `GFResourceTableEditor` 的资源列表操作和过滤相关公开接口；既有 `commit_cell_value()` 行索引语义保持为原始资源索引。
- 发射体节点默认不解释 payload 内容；项目可继续把 `GFCombatHitContext.payload` 解释为伤害、治疗、交互或任意自定义命中语义。
- `GFProjectileLifetimePolicy.max_impacts` 可用于对象池、穿透或多目标命中这类通用生命周期控制；它只统计成功发送的命中，不定义穿透筛选或伤害规则。

### 📁 核心受影响文件

- `addons/gf/kernel/editor/gf_resource_table_editor.gd`
- `addons/gf/kernel/package/gf_package_manifest.gd`
- `addons/gf/kernel/package/gf_package_settings.gd`
- `addons/gf/kernel/editor/package/gf_package_manager_dock.gd`
- `addons/gf/standard/foundation/math/gf_tile_metadata_layer.gd`
- `addons/gf/standard/input/runtime/gf_pointer_activity_utility.gd`
- `addons/gf/standard/state_machine/node/**`
- `addons/gf/standard/utilities/audio/**`
- `addons/gf/standard/utilities/debug/gf_diagnostics_utility.gd`
- `addons/gf/packages/official/combat/projectiles/**`
- `tests/gf_core/kernel/editor/test_gf_resource_table_editor.gd`
- `tests/gf_core/kernel/package/test_gf_package_manifest.gd`
- `tests/gf_core/maintenance/test_layer_boundary_validation.gd`
- `tests/gf_core/standard/foundation/math/test_gf_tile_metadata_layer.gd`
- `tests/gf_core/standard/input/runtime/test_gf_pointer_activity_utility.gd`
- `tests/gf_core/standard/state_machine/node/test_gf_node_state_machine_validator.gd`
- `tests/gf_core/standard/utilities/audio/test_gf_audio_utility.gd`
- `tests/gf_core/standard/utilities/audio/test_gf_audio_bank_tools.gd`
- `tests/gf_core/standard/utilities/debug/test_gf_diagnostics_utility.gd`
- `tests/gf_core/packages/official/combat/test_gf_projectiles.gd`
- `docs/zh/standard/input-flow/state-machines.md`
- `docs/zh/standard/utilities/runtime/audio.md`
- `docs/zh/packages/combat/index.md`

---

## [3.1.0] - 2026-05-12

**版本概述**：本版本为 Combat 命中区域补充可复用碰撞形状配置能力，使项目可以在复用同一组 HitBox / HurtBox 节点时按攻击配置切换 Godot 原生碰撞形状，同时明确官方包的 GF 发行版本与包自身版本之间的边界。

### 🚀 新增特性

- 新增 `GFHitCollisionShapeConfig2D` 与 `GFHitCollisionShapeConfig3D`，用于以 Resource 形式复用 HitBox / HurtBox 的 Godot 原生碰撞形状、偏移、旋转、缩放和 disabled 状态。
- `GFHitBox2D`、`GFHurtBox2D`、`GFHitBox3D` 与 `GFHurtBox3D` 新增 `collision_shape_config`、`auto_apply_collision_shape_config`、`apply_collision_shape_config()`、`get_generated_collision_shape()` 和 `clear_generated_collision_shape()`，用于按配置生成或更新框架管理的 CollisionShape 子节点。
- `GFPackageManifest` 新增 `package_version` 字段，用于记录单个包自身的公开行为版本。

### 🔄 机制更改

- 官方包 `gf_package.json` 的 `version` 表示当前 GF 官方发行版本，发布时所有官方包必须同步；`package_version` 表示包自身版本，只有该包的公开 API、配置、行为或兼容性契约发生变化时才按 SemVer 递增。
- 本版本所有官方包的 `version` 同步为 `3.1.0`；Combat 包因新增公开配置能力将 `package_version` 递增为 `1.1.0`，其余未发生包内公开行为变化的官方包保持 `package_version` 为 `1.0.0`。

### 🔌 API 变动说明

- 新增 Combat 命中区域配置化碰撞形状 API；该能力只生成或更新框架管理的 `CollisionShape2D` / `CollisionShape3D` 子节点，不修改用户手写的其他碰撞节点。
- `collision_shape_config` 置空或缺少 `shape` 时会清理框架管理的生成节点，避免切换攻击形状后残留旧碰撞区域。
- 官方包 manifest 新增 `package_version`，旧 manifest 未声明该字段时工具会回退使用 `version`；GF 官方包从本版本起必须显式声明。

### 📁 核心受影响文件

- `addons/gf/kernel/package/gf_package_manifest.gd`
- `addons/gf/kernel/editor/package/gf_package_manager_dock.gd`
- `addons/gf/packages/official/*/gf_package.json`
- `addons/gf/packages/official/combat/hit_detection/**`
- `tests/gf_core/kernel/package/test_gf_package_manifest.gd`
- `tests/gf_core/packages/official/combat/test_gf_combat_extension.gd`
- `AI_MAINTENANCE.md`
- `addons/gf/packages/README.md`
- `docs/zh/packages/index.md`
- `docs/zh/packages/combat/index.md`
