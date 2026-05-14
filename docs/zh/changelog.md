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

## [3.5.0] - 2026-05-14

**版本概述**：本轮聚焦编辑器结构检查体验、Network 契约代码生成、标准库校验诊断定位，以及运行时取消、等待和类型契约的稳健性加固；新增能力保持为显式、通用和可选工具，不引入项目业务语义。

### 🚀 新增特性

- 标准库新增 `GFNodeStateMachineDock`，可在 GF 工作区扫描当前场景中的节点状态机并集中展示结构校验结果。
- Flow 扩展新增 `GFFlowGraphDock`，可加载 `GFFlowGraph` 资源、查看节点/连接/校验问题，并显式触发通用自动布局。
- Network 扩展新增 `GFNetworkContract`、`GFNetworkContractMessage`、`GFNetworkContractField` 与 `GFNetworkContractGenerator`，用于声明消息 payload 契约并生成 GDScript 强类型辅助函数。
- Network 扩展新增 GF 工具菜单项“生成 Network Contract 访问器”，读取 `gf/network/contract_paths` 与 `gf/network/contract_output_dir`。
- 标准库 Foundation 新增 `GFSourceSpan` 与 `GFValidationDiagnosticAdapter`，用于把通用校验问题转换为可被编辑器、导入器、CI 或项目工具消费的纯诊断字典。
- BehaviorTree 新增 `BTNode.clear_debug_state()`、`Runner.clear_debug_state()` 与 `Cooldown.clear_cooldown()`，用于显式区分运行态重置、调试状态清空和冷却清空。
- `GFControlValueAdapter` 新增可断开的值变化连接句柄 API，`GFBuff` 新增 `refresh_from()` 与 `max_periodic_ticks_per_update`。

### 🔄 机制更改

- Flow 与 Network 的编辑器增强均由各自官方扩展 manifest 注入；kernel 与 standard 不硬编码可选官方扩展路径或类型。
- `GFValidationIssue`、`GFValidationReport` 与 `GFValidationReportDictionary` 支持 source span 字段和便捷追加入口，旧字典式报告可渐进接入源码定位。
- `GFAsyncWaitSupport` 统一承接 Signal 安全等待逻辑，Flow、Action Queue 与 Command Sequence 共享发射源失效、保护节点离树、取消检查和超时处理。
- `GFNetworkContractGenerator` 对没有默认值的可选字段保留“未提供”语义，默认不把 null primitive 写入 payload；批量生成报告区分尝试数量和成功数量。
- `GFInputRemapConfig` 新写入的重映射记录改为白名单事件类型和结构化属性，旧 `event` 文本记录仍可读取以兼容已有存档。
- `GFGridMath` 与 `GFGraphMath` 的 A* / Dijkstra 优先队列改为二叉堆实现，`GFNetworkHistoryBuffer` 与 `GFTypeEventSystem` 减少前端裁剪和派发缓存中的重复分配。
- `GFTextFitter` 的自动换行测量改为逐字符贪心估算，避免仅按总宽度除以 wrap width 造成明显偏差。
- 扩展文档补充 `export_plugin_paths` 与抽象 backend / fallback 的边界建议，平台或业务后端继续留在项目、社区扩展或外部插件中装配。
- BehaviorTree 改为由每个节点记录自身 tick 状态；`reset()` 只重置运行态，最近调试状态需要通过 `clear_debug_state()` 显式清空。
- `GFSaveGraphUtility.load_scope()` 读取存储数据后会先执行 payload 校验；`GFNodePropertySerializer` 应用数据前会检查属性可写性与基础类型兼容性。
- `GFCombatSystem` 的同 ID Buff 刷新改为调用已有 Buff 的 `refresh_from(new_buff)`，默认仍保持只刷新 duration / stacks 的兼容语义。
- 本版本所有官方扩展的 `version` 同步为 `3.5.0`；Action Queue 因新增等待/重复安全契约将 `extension_version` 递增到 `1.2.0`，BehaviorTree 因新增运行态与调试清理公开 API 将 `extension_version` 递增到 `1.2.0`，Combat 因新增 Buff 刷新 hook 和周期 Tick 预算将 `extension_version` 递增到 `1.5.0`，Flow 因新增编辑器图检查面板将 `extension_version` 递增到 `1.2.0`，Network 因新增契约生成器将 `extension_version` 递增到 `1.1.0`；Capability、Domain 与 Save 因公开行为修复分别递增到 `1.0.1`、`1.1.1` 和 `1.0.1`。

### 🐛 Bug 修复

- 修复 `GFRepeatAction` 无限重复瞬时动作可能锁住主线程的问题。
- 修复 `GFVisualActionGroup` 并行动作在启动循环尚未结束时可能提前发出完成信号的问题。
- 修复 `GFFlowRunner` 在 Signal 等待期间取消后仍可能报告节点完成并推进后继节点的问题。
- 修复 `GFNetworkUtility` 替换或清空 backend 时旧 backend 未关闭，以及 host 失败前短暂标记 session connected 的问题。
- 修复 `GFWaitAction.cancel()` 无法阻止旧 `SceneTreeTimer` 后续触发动作完成信号的问题。
- 修复 `GFValidationReport.add_source_issue()` 字符串 severity 与文档不一致的问题。
- 修复 `GFPropertyBagCapability` typed getter 在类型不匹配时强制转换而不是返回默认值的问题。
- 修复 `GFQuadTreeUtility` 未初始化根节点、无效深度/容量、负半径查询和重复结果去重成本的问题。
- 修复 `GFNodeTreeOps`、`GFNodeSerializer` 和 Network contract object class hint 对 GDScript `class_name` 字符串匹配不完整的问题。
- 修复 BehaviorTree `Cooldown` 被父节点终态 reset 清空、`Probability` 中断 RUNNING 子节点，以及 Runner 对根节点重复计数的问题。
- 修复 `GFSaveSource.apply_save_data()` 对非 Dictionary source data 静默成功的问题。
- 修复 `GFInputMappingUtility.clear_player_input_state()` 清理玩家状态后可能留下全局输入贡献的问题。
- 修复 `GFFormBinder` 重复绑定或解绑字段后旧匿名信号连接仍触发的问题。
- 修复 `GFCombatSystem.refresh_buff_modifiers()` 在没有实际刷新属性时也返回 true 的问题。
- 修复 `GFBuff` 周期 tick 在卡顿后一帧无上限补偿的问题。
- 修复 `GFAttributeSet` base / limits 改变但 current 不变时派生属性可能不重算的问题。
- 修复池化发射体旧 `projectile_finished` 回调可能影响新一轮发射的问题。
- 修复配置表 schema 测试中的 enum cast 与内置函数同名变量 GDScript 警告。

### 🔌 API 变动说明

- 新增公开类：`GFNodeStateMachineDock`、`GFFlowGraphDock`。
- 新增公开类：`GFNetworkContract`、`GFNetworkContractMessage`、`GFNetworkContractField`、`GFNetworkContractGenerator`。
- 新增公开类：`GFSourceSpan`、`GFValidationDiagnosticAdapter`。
- `GFValidationIssue` 新增 `source_path`、`line`、`column`、`length`、`end_line`、`end_column`、`preview` 字段，以及 `set_source_span()`、`get_source_span()`、`has_source_position()`、`get_location_text()`。
- `GFValidationReport` 新增 `add_source_issue()`、`add_source_info()`、`add_source_warning()`、`add_source_error()`。
- `GFValidationReportDictionary` 新增 `append_source_issue()`。
- `GFRepeatAction` 新增 `max_immediate_iterations_per_frame`，用于限制单帧连续瞬时重复次数。
- `GFWaitAction` 新增 `wait_completed` 信号作为可取消等待的完成信号。
- `GFBehaviorTree.BTNode` 新增 `clear_debug_state(recursive := true)`；`GFBehaviorTree.Runner` 新增 `clear_debug_state()`；`GFBehaviorTree.Cooldown` 新增 `clear_cooldown()`。
- `GFControlValueAdapter` 新增 `connect_value_changed_with_handles()` 与 `disconnect_value_changed_handles()`。
- `GFBuff` 新增 `refresh_from(source_buff)` 与 `max_periodic_ticks_per_update`。

### 📘 升级指南

- 现有项目无需迁移；新增编辑器面板、Network 契约生成器和校验诊断定位均为显式使用能力。
- 如果项目依赖 `GFPropertyBagCapability` 的 typed getter 把字符串、数字或布尔互相强制转换，请改用 `get_property_value()` 后自行转换；typed getter 现在按文档在类型不匹配时返回默认值。
- 如果项目读取 `GFNetworkContractGenerator.generate_many()` 的 `generated_count`，该字段现在表示成功生成数量；需要总尝试数量请读取新增的 `attempted_count`。
- `GFInputRemapConfig` 仍能读取旧 `event` 文本记录；重新保存后会写入结构化记录。
- 如果项目依赖 BehaviorTree `reset()` 同时清空调试快照，请改用 `clear_debug_state()`；如果需要手动重置 `Cooldown` 冷却，请调用 `clear_cooldown()`。
- 如果项目自定义 Buff 需要在同 ID 刷新时合并新配置，请覆写 `refresh_from(source_buff)`；默认仍不替换 tags、modifiers 或其他项目语义字段。
- `GFBuff.max_periodic_ticks_per_update` 默认限制单次补偿 Tick。需要完全保留旧的无限补偿行为时，可显式设为 `0` 或负数。

### 📁 核心受影响文件

- `addons/gf/standard/foundation/validation/**`
- `addons/gf/standard/common/gf_async_wait_support.gd`
- `addons/gf/standard/input/rebinding/gf_input_remap_config.gd`
- `addons/gf/standard/utilities/spatial/gf_quad_tree_utility.gd`
- `addons/gf/standard/foundation/math/gf_grid_math.gd`
- `addons/gf/standard/foundation/math/gf_graph_math.gd`
- `addons/gf/kernel/core/gf_type_event_system.gd`
- `addons/gf/extensions/official/action_queue/**`
- `addons/gf/extensions/official/network/runtime/**`
- `addons/gf/extensions/official/network/session/gf_network_session.gd`
- `addons/gf/standard/state_machine/node/editor/gf_node_state_machine_dock.gd`
- `addons/gf/extensions/official/flow/editor/gf_flow_graph_dock.gd`
- `addons/gf/extensions/official/flow/runtime/gf_flow_runner.gd`
- `addons/gf/extensions/official/network/contracts/**`
- `addons/gf/extensions/official/network/editor/**`
- `addons/gf/extensions/official/behavior_tree/runtime/gf_behavior_tree.gd`
- `addons/gf/extensions/official/save/**`
- `addons/gf/extensions/official/combat/**`
- `addons/gf/extensions/official/domain/attributes/gf_attribute_set.gd`
- `addons/gf/standard/input/runtime/gf_input_mapping_utility.gd`
- `addons/gf/standard/utilities/ui/gf_control_value_adapter.gd`
- `addons/gf/standard/utilities/ui/gf_form_binder.gd`
- `docs/zh/standard/foundation/data-validation.md`
- `docs/zh/extensions/index.md`
- `docs/zh/maintenance/index.md`
- `tests/gf_core/standard/foundation/validation/test_gf_validation_source_diagnostics.gd`
- `tests/gf_core/extensions/official/network/test_gf_network_extension.gd`
- `tests/gf_core/extensions/official/flow/test_gf_flow_graph.gd`
- `tests/gf_core/standard/state_machine/node/test_gf_node_state_machine_validator.gd`
