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

## [3.20.0] - 2026-05-27

**版本概述**：新增通用对象池、回放时间线、网络快照路径级 patch、统一标签来源和技能激活上下文，并补充数据绑定、分析压缩、网格算法、背包槽位规则与本地 AI 维护入口。

### 🚀 新增特性 (Added)

- `GFBindableProperty` 新增 `subscribe(callback, emit_current)`，可在无 Node 生命周期绑定时获取取消订阅函数，并可选择立即推送当前值。
- `GFAnalyticsConfig` 新增 `compress_payload`，内置 HTTP 分析上报可选择使用 gzip 压缩 JSON 请求体，并自动维护一致的 `Content-Encoding: gzip` Header。
- `GFGridMath` 新增矩形、范围、外环、Bresenham 直线和视线检测入口，便于网格选区、AOE、画刷候选和离散射线复用同一套纯算法原语。
- 新增 `GFInventorySlotDefinition`，`GFSlotInventoryModel` 可按槽位配置允许/拒绝物品 ID、物品分类和项目自定义接收回调。
- `GFTagSourceAdapter` 新增 `get_tag_counts()`、`to_tag_set()` 与 `merge_sources()`，便于跨模块统一规范化标签来源。
- `GFNetworkSnapshot` 新增路径级 patch 生成与应用能力，`GFNetworkSnapshotSchema` 可复用字段编码器编码和解码 patch set 值。
- 新增 `GFRefCountedPool`，为短生命周期纯数据对象提供显式 reset 协议和容量可控的复用池。
- 新增 `GFReplayTimeline`，用于把命令、输入、状态快照或项目自定义事件串成可查询、可合并、可序列化的纯数据时间线。
- 新增 `GFSkillActivationContext`，`GFSkill` 可通过激活上下文、标签查询、检查回调和提交回调组织通用施放流程。

### 🔄 机制更改 (Changed)

- 新增可选本地维护入口 `tools/gf_maintenance.py` 与 `tools/gf_mcp_server.py`，为 AI 维护流程提供项目摘要、工作区变更快照、API 查询、单模块 API 摘要、预设检查套件和版本一致性检查；该能力仅属于仓库维护基础设施，不进入 `addons/gf` 运行时。

### 🔌 API 变动说明 (API Changes)

- `GFBindableProperty` 新增公开方法 `subscribe(callback, emit_current := false) -> Callable`。
- `GFAnalyticsConfig` 新增公开导出属性 `compress_payload`。
- `GFGridMath` 新增公开方法 `get_rectangle_cells()`、`get_range()`、`get_ring()`、`get_line()` 与 `has_line_of_sight()`。
- 新增公开类 `GFInventorySlotDefinition`。
- `GFSlotInventoryModel` 新增公开字段 `slot_definitions`，以及公开方法 `set_slot_definition()`、`get_slot_definition()` 和 `can_accept_item_at_slot()`。
- `GFTagSourceAdapter` 新增公开方法 `get_tag_counts()`、`to_tag_set()` 与 `merge_sources()`。
- `GFNetworkSnapshot` 新增公开方法 `make_patch_to()` 与 `apply_patch()`。
- `GFNetworkSnapshotSchema` 新增公开方法 `encode_patch()` 与 `decode_patch()`。
- 新增公开类 `GFRefCountedPool`。
- 新增公开类 `GFReplayTimeline`。
- 新增公开类 `GFSkillActivationContext`。
- `GFSkill` 新增公开信号 `activation_failed` 与 `activation_committed`，新增公开字段 `activation_query`、`activation_checks` 与 `activation_commit_callbacks`，并新增公开方法 `build_activation_context()` 与 `get_activation_report()`。
- 所有 GF 内置扩展 `version` 同步到 `3.20.0`；`gf.combat` 的 `extension_version` 升至 `1.8.0`，`gf.domain` 与 `gf.network` 的 `extension_version` 升至 `2.1.0`。

### 📘 升级指南 (Migration Guide)

- 现有项目无需立即修改；新增能力均为可选入口。
- 继续使用 `GFSkill._try_execute(targets)` 的旧技能仍可工作；需要成本检查、资源提交或更完整上下文时，可逐步迁移到 `activation_checks`、`activation_commit_callbacks` 或 `_try_activate(context)`。
- 简单网络状态仍可继续使用 `make_delta_to()` / `apply_delta()`；嵌套字典状态可改用 `make_patch_to()` / `apply_patch()`。

### 📁 核心受影响文件 (Affected Files)

- `addons/gf/kernel/core/gf_bindable_property.gd`
- `addons/gf/standard/utilities/analytics/gf_analytics_config.gd`
- `addons/gf/standard/utilities/analytics/gf_analytics_utility.gd`
- `addons/gf/standard/foundation/math/gf_grid_math.gd`
- `addons/gf/extensions/domain/inventory/gf_inventory_slot_definition.gd`
- `addons/gf/extensions/domain/inventory/gf_slot_inventory_model.gd`
- `addons/gf/standard/foundation/tags/gf_tag_source_adapter.gd`
- `addons/gf/standard/utilities/pooling/gf_ref_counted_pool.gd`
- `addons/gf/standard/foundation/timeline/gf_replay_timeline.gd`
- `addons/gf/extensions/network/snapshot/gf_network_snapshot.gd`
- `addons/gf/extensions/network/snapshot/gf_network_snapshot_schema.gd`
- `addons/gf/extensions/combat/skills/gf_skill.gd`
- `addons/gf/extensions/combat/skills/gf_skill_activation_context.gd`
- `tests/gf_core/kernel/core/test_gf_bindable_property.gd`
- `tests/gf_core/standard/utilities/analytics/test_gf_analytics_utility.gd`
- `tests/gf_core/standard/foundation/math/test_gf_grid_math.gd`
- `tests/gf_core/extensions/domain/test_gf_domain_extensions.gd`
- `tests/gf_core/standard/foundation/tags/test_gf_tag_query.gd`
- `tests/gf_core/standard/utilities/pooling/test_gf_ref_counted_pool.gd`
- `tests/gf_core/standard/foundation/test_gf_timeline_region_map.gd`
- `tests/gf_core/extensions/network/test_gf_network_extension.gd`
- `tests/gf_core/extensions/combat/test_gf_combat_extension.gd`
- `docs/zh/kernel/scene-controller/bindable-property/**`
- `docs/zh/extensions/domain/inventory.md`
- `docs/zh/extensions/network-turnbased/network-snapshots.md`
- `docs/zh/extensions/combat/core-model/buffs-skills.md`
- `docs/zh/extensions/combat/runtime-usage/buff-skill-examples.md`
- `docs/zh/standard/foundation/data-validation/tags-blackboard/tag-expression-source.md`
- `docs/zh/standard/foundation/data-validation/budget-collections-timeline/replay-timeline.md`
- `docs/zh/standard/utilities/runtime/time-signal-pool/object-pool.md`
- `docs/zh/standard/utilities/io/config-remote-outbox/analytics-events.md`
- `docs/zh/standard/foundation/grid-spatial/grid-2d-hex/grid-math.md`
- `addons/gf/plugin.cfg`
- `addons/gf/extensions/*/gf_extension.json`
- `ASSET_LIBRARY.md`
- `tools/gf_maintenance.py`
- `tools/gf_mcp_server.py`
