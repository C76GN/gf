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

## [3.17.0] - 2026-05-22

**版本概述**：完成 GF Framework 全量 API Surface 严格规范迁移，把 `addons/gf` 的公开 API、protected 扩展点、框架内部 API、层内部 API 与私有实现边界整理为可查阅、可测试、可维护的发布契约；同步补齐 Godot 文档渲染换行、结构化 schema、版本标记与发布元数据。

### 🚀 新增特性 (Added)

- 新增 `API_SURFACE.md`，正式定义 `@api public`、`@api protected`、`@api framework_internal`、`@api layer_internal`、`@category`、`@schema`、canonical section 顺序、私有成员静默规则与迁移标记规则。
- 新增 API Surface 契约维护测试与正例夹具，覆盖公开类文档、公开成员文档、protected hook section、结构化类型 schema、Godot `[br]` 文档换行、占位 `@since 1.0.0` 禁止项以及迁移标记归零检查。
- 新增或稳定化多个公开诊断入口与 debug snapshot，让测试和项目诊断可以读取公开契约，而不是直接依赖 `_queue`、`_rng`、`_pending_timers`、对象池内部字典、四叉树 `_root` 等私有状态。
- `GFSlotInventoryModel` 新增 `slot_state_changed`、`slot_filled`、`slot_emptied` 信号，新增 `sort_slots()` 公开排序入口与 protected `_should_sort_slot_before()` 扩展点，便于项目以稳定契约实现槽位整理规则。

### 🔄 机制更改 (Changed)

- `addons/gf` 已完成全量 API Surface 迁移：所有公开类补齐 `@api public`、`@category` 与 `@since 3.17.0`，公开成员补齐 `##` 文档与 `@api public`，结构化 `Dictionary`、`Array`、`Variant` 与嵌套数据补齐 `@schema`。
- 所有可覆写但不适合作为普通调用入口的 `_` 方法集中到 `# --- 可重写钩子 / 虚方法 ---`，并标记为 `@api protected`；真正私有的变量和方法收敛为无 `##`、无 `@api private` 的实现细节。
- Godot 文档注释中的机器标签统一使用 `## [br]` 分隔，使编辑器悬浮文档中的 `@api`、`@param`、`@return`、`@schema` 等标签逐行显示，避免挤在同一段里。
- 公开签名不再暴露 preload 别名，改用真实 `class_name` 类型；内部 helper 类型和 preload 常量不再被误当作公开 API。
- `CODING_STYLE.md`、`AI_MAINTENANCE.md` 与维护文档补充 API Surface Contract、section 布局、`@onready` 适用范围、私有成员文档约束、迁移标记策略、changelog 同步规则与发布版本同步规则。
- `GFSlotInventoryModel` 现在会批量收集一次库存变更中的槽位、物品与整体变化通知，在派发期间拒绝同步重入修改，避免监听器回调中的排序或移动污染后续通知上下文。
- `GFSlotInventoryModel.get_index_debug_snapshot()` 的索引字段由旧 `items` 调整为 `stack_count_by_item` 与 `slot_indices_by_item`，避免把物品计数与槽位索引混淆。
- 对象池异步预热文档补充 Godot `ready` 一次性信号的时序说明，提醒调用方先等待宿主就绪或检查 `is_node_ready()` 再执行跨帧预热。

### ⚠️ 废弃与移除 (Deprecated/Removed)

- 移除 `addons/gf` 内全部 `# @api_surface_migration partial` 标记；当前迁移债务基线归零。
- 移除 GF 源码和 API 示例中的占位 `@since 1.0.0`，本轮发布后的严格 API Surface 起点统一记录为 `3.17.0`。
- 移除公开 API 对 preload 类型别名的依赖，后续项目代码应以 `class_name` 类型作为公开签名参照。

### 🔌 API 变动说明 (API Changes)

- `GFTurnPhase.enter()`、`GFTurnPhase.execute()`、`GFTurnPhase.exit()` 规范化为 protected 扩展点 `_enter()`、`_execute()`、`_exit()`，由 `GFTurnFlowSystem` 调用。
- `GFTurnAction.resolve()` 规范化为 protected 扩展点 `_resolve()`，由 `GFTurnFlowSystem.resolve_actions()` 调用。
- `GFSceneUtility` 的公开签名改用 `GFSceneTransitionConfig` 与 `GFScenePreloadMap`；`GFRenderWarmupUtility` 的公开签名改用 `GFRenderWarmupManifest`；`GFSteeringBehaviorStack.add_behavior()` 改用 `GFSteeringBehaviorResource`。
- `GFProgressionMath.evaluate_curve()`、`apply_milestone_multipliers()`、`apply_soft_cap()` 与 `GFBigNumber.to_big_number()` 的返回类型收窄为 `GFBigNumber`。
- `GFGridOccupancy.get_cell_occupants()`、`GFSpatialHash3D.query_aabb()` 与 `GFSpatialHash3D.query_radius()` 的返回类型补为 `Array[Variant]`。
- `GFSlotInventoryModel.get_index_debug_snapshot()` 不再返回 `items` 字段，改为返回 `stack_count_by_item` 与 `slot_indices_by_item`。

### 📘 升级指南 (Migration Guide)

- 继承 `GFTurnPhase` 的项目阶段类需要把 `enter(context)`、`execute(context)`、`exit(context)` 重命名为 `_enter(context)`、`_execute(context)`、`_exit(context)`。
- 继承 `GFTurnAction` 的项目行动类需要把 `resolve(context)` 重命名为 `_resolve(context)`。
- 对 `GFSceneUtility`、`GFRenderWarmupUtility`、`GFSteeringBehaviorStack` 等类型做静态类型标注时，应改用公开 `class_name` 类型，不要依赖内部 preload 常量名。
- 依赖 `GFProgressionMath` 或 `GFBigNumber.to_big_number()` 返回 `Object` 的项目代码，应改按 `GFBigNumber` 处理。
- 项目测试不要再读取 GF 私有状态；优先改用公开 getter、debug snapshot、protected hook 或稳定行为断言。
- 监听 `GFSlotInventoryModel` 的槽位、物品或库存变化信号时，不要在同步回调里继续调用 `sort_slots()`、`swap_slots()`、`move_between_slots()`、`add_item()`、`remove_item()` 等修改接口；需要由信号触发整理时，使用 `call_deferred("sort_slots")` 或等待当前通知结束后再修改。
- 读取槽位库存索引调试信息的代码应把旧 `index.items[item_id]` 改为 `index.stack_count_by_item[item_id]`；需要槽位编号时读取 `index.slot_indices_by_item[item_id]`。
- 新增公开 API 文档时，应在 `@api`、`@category`、`@since`、`@param`、`@return`、`@schema` 等机器标签前使用 `## [br]`，保证 Godot 编辑器渲染结果可读。

### 📁 核心受影响文件 (Affected Files)

- API Surface 规范与维护测试：`API_SURFACE.md`、`CODING_STYLE.md`、`AI_MAINTENANCE.md`、`docs/zh/maintenance/index.md`、`tests/gf_core/fixtures/api_surface/**`、`tests/gf_core/maintenance/test_api_surface_contract_validation.gd`、`tests/gf_core/maintenance/test_gdscript_layout_validation.gd`。
- 全量严格迁移源码：`addons/gf/kernel/**`、`addons/gf/standard/**`、`addons/gf/extensions/**`、`addons/gf/plugin.gd`。
- 公开契约测试调整：`tests/gf_core/extensions/**`、`tests/gf_core/standard/**` 中依赖公开状态、公开 snapshot 或稳定诊断入口的测试。
- 发布元数据：`addons/gf/plugin.cfg`、`addons/gf/extensions/*/gf_extension.json`、`ASSET_LIBRARY.md`。
