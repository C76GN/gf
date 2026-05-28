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

## [3.24.0] - 2026-05-29

**版本概述**：强化节点状态机编辑器结构反馈，为 ActionQueue 并行动作组增加可配置完成策略，并增强文本适配与 JSON 文本工具，保持框架只定义通用等待、排版测量和数据转换边界，不写入项目业务流程。

### 🚀 新增特性 (Added)

- `GFNodeStateMachine` 与 `GFNodeStateGroup` 在 Inspector 配置警告中直接展示结构校验问题，复用 `GFNodeStateMachineValidator` 的报告。
- `GFVisualActionGroup` 新增 `ParallelCompletionPolicy`，支持默认等待全部子动作或任一子动作完成即结束。
- `GFAction.race(actions, cancel_remaining)` 新增首个子动作完成即结束的并行动作组工厂。
- `GFVariantJsonCodec` 新增 `parse_json_text()`、`format_json_text()` 和 `compact_json_text()`，为 JSON 文本解析、格式化和压缩提供统一入口。

### 🔄 机制更改 (Changed)

- 节点状态机和状态组脚本改为编辑器安全的 `@tool`，编辑器模式只刷新配置警告，不创建运行时内部状态组，也不启动状态。
- 并行动作组在 `FIRST_COMPLETED` 策略下默认取消仍在等待的子动作；调用方可关闭该取消策略。
- `GFTextFitter` 测量 `Label`、`RichTextLabel`、`Button`、`LineEdit` 和 `TextEdit` 时会读取控件的对齐、换行、文本方向和 justification 配置，使自动字号更接近 Godot 实际排版。

### 🔌 API 变动说明 (API Changes)

- 新增 `GFVisualActionGroup.ParallelCompletionPolicy`：`WAIT_FOR_ALL` 与 `FIRST_COMPLETED`。
- 新增 `GFVisualActionGroup.parallel_completion_policy`。
- 新增 `GFVisualActionGroup.cancel_remaining_on_first_completed`。
- 新增 `GFAction.race(actions, cancel_remaining = true)`。
- 新增 `GFVariantJsonCodec.parse_json_text(text, fallback = null)`。
- 新增 `GFVariantJsonCodec.format_json_text(text, indent = "\t", sort_keys = false, fallback = "")`。
- 新增 `GFVariantJsonCodec.compact_json_text(text, sort_keys = false, fallback = "")`。

### 📘 升级指南 (Migration Guide)

- 现有 `GFAction.parallel()` 与 `enqueue_parallel()` 默认仍等待所有子动作完成；只需要等待最先完成分支时，改用 `GFAction.race()` 或设置并行动作组的 `parallel_completion_policy`。
- 依赖 `GFTextFitter` 旧版逐字符估算换行的项目，应改用控件自身 `autowrap_mode` / `text_direction` 配置或在 options 中显式传入 `line_break_flags`；新行为以 Godot 文本测量结果为准。

### 📁 核心受影响文件 (Affected Files)

- `addons/gf/standard/state_machine/node/gf_node_state_machine.gd`
- `addons/gf/standard/state_machine/node/gf_node_state_group.gd`
- `addons/gf/standard/state_machine/node/gf_node_state_machine_validator.gd`
- `addons/gf/extensions/action_queue/actions/gf_visual_action_group.gd`
- `addons/gf/extensions/action_queue/core/gf_action.gd`
- `addons/gf/standard/utilities/ui/gf_text_fitter.gd`
- `addons/gf/standard/foundation/variant/gf_variant_json_codec.gd`
- `tests/gf_core/standard/state_machine/node/test_gf_node_state_machine_validator.gd`
- `tests/gf_core/extensions/action_queue/test_gf_visual_actions.gd`
- `tests/gf_core/standard/utilities/ui/test_gf_text_fitter.gd`
- `tests/gf_core/standard/foundation/variant/test_gf_variant_data_and_json_codec.gd`
- `tests/gf_core/maintenance/test_gdscript_layout_validation.gd`
- `docs/zh/standard/input-flow/state-machines/node-state-hooks-validation/editor-validation.md`
- `docs/zh/extensions/action-queue/visual-actions/groups-parallel.md`
- `docs/zh/extensions/action-queue/interceptors-actions/action-factory.md`
- `docs/zh/standard/utilities/runtime/settings-ui-scene/ui-stack-routing/viewport-text-node-tools/text-richtext.md`
- `docs/zh/standard/foundation/data-validation/formula-variant/variant-data-json.md`
