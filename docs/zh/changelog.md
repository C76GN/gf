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

## [3.13.0] - 2026-05-19

**版本概述**：统一框架校验报告字段，并增强通用设置预设应用能力，让编辑器、导入器、CI 和项目设置界面更容易消费标准化结果。

### 🚀 新增特性

- `GFSettingsUtility.apply_values()` 可批量应用设置值并返回标准报告；需要重置缺失键时必须显式传入 `scope`，避免项目预设误修改不属于自身的设置。

### 🔄 机制更改

- `GFDialogueResource.validate_resource()` 现在返回兼容 `GFValidationReportDictionary` 的标准报告字段，统一使用 `severity`、`kind`、`message`、`path`、统计、摘要和下一步建议描述问题。
- `GFSignalBridge.get_validation_report()` 现在返回标准校验报告字典，不再把 `issues` 作为字符串列表输出。
- `GFValidationIssue`、`GFValidationDiagnosticAdapter` 与 `GFValidationReportDictionary` 统一只使用 `kind` 作为问题类别，不再输出或回退读取旧的 `code` / `type` 问题类别字段。
- Network 契约校验入口与批量生成报告现在统一通过 `GFValidationReportDictionary` 生成报告，补齐 `issue_count`、`issue_counts_by_kind`、`summary` 和 `next_action`。
- Config 导表校验、导入、引用解析和合并工具的问题标识统一使用标准 `kind` 字段，不再输出旧的 `code` 字段。
- Save 槽位元数据校验与 Input 工作区诊断现在返回标准校验报告字段，区分 `ok`（无错误）与 `healthy`（无警告和错误）。
- Domain 背包校验报告的问题标识统一使用标准 `kind` 字段，不再输出旧的 `code` 字段。

### 🐛 Bug 修复

- 修复 `GFDialogueResource.start_line_id` 指向不存在的行时资源校验仍可能通过的问题；现在会报告 `missing_start_line` 错误。

### 🔌 API 变动说明

- `validate_resource()` 的既有 `ok` 与 `issues` 保持可用；单个问题不再输出旧的 `issue_id` 字段，请读取标准 `kind` 字段作为稳定问题标识。
- `GFSignalBridge.get_validation_report()["issues"]` 的元素从字符串改为标准问题字典，请读取 `issues[i]["kind"]`。
- `GFValidationIssue.to_dict()` 和 `GFValidationDiagnosticAdapter.issue_to_diagnostic()` 不再输出 `code` 字段；`GFValidationIssue.from_dict()`、`GFValidationDiagnosticAdapter` 与 `GFValidationReportDictionary` 不再把 `code` / `type` 当作 `kind` 的兼容别名。
- `GFSettingsUtility` 新增 `apply_values(values, options = {})`；`options` 支持 `save_after_change`、`emit_changes`、`reset_missing` 与 `scope`。
- `GFNetworkContract`、`GFNetworkContractMessage` 与 `GFNetworkContractField` 的校验报告新增标准统计和诊断字段；既有 `ok`、`healthy`、`error_count`、`warning_count`、`issues` 字段保持同名语义。
- `GFConfigTableSchema`、`GFConfigValidationRule`、`GFConfigTableImporter`、`GFConfigReferenceResolver`、`GFConfigTableMergeTools` 与 `GFConfigProvider` 的校验问题不再输出 `code` 字段，请读取标准 `kind` 字段。
- `GFSaveSlotMetadata.validate_metadata()` 与 `GF Workspace > Input` 的诊断报告新增 `healthy`、`issue_count`、`issue_counts_by_kind`、`summary` 和 `next_action` 等标准字段；只有 warning 时 `ok` 为 `true`，`healthy` 为 `false`。
- `GFSlotInventoryModel.validate_inventory()` 的校验问题不再输出 `code` 字段，请读取标准 `kind` 字段。

### 📘 升级指南

- 如果项目代码曾读取 `GFDialogueResource.validate_resource()["issues"][i]["issue_id"]`，请改为读取 `["kind"]`。`kind` 与 `GFValidationDiagnosticAdapter`、报告统计和编辑器诊断使用同一套字段。
- 如果项目代码曾判断 `GFSignalBridge.get_validation_report()["issues"].has("invalid_callable_target")`，请改为遍历问题字典并读取 `issue["kind"]`。
- 如果项目代码曾向 `GFValidationIssue.from_dict()` 或 `GFValidationReportDictionary.finalize_report()` 传入只含 `code` / `type` 的问题字典，请改为写入 `kind`。
- 如果项目代码曾读取 Config 校验问题的 `issue["code"]`，请改为 `issue["kind"]`。字段、行列、表名和规则 ID 等上下文字段保持原语义。
- 如果项目或编辑器扩展曾用 `ok == false` 判断 Input 工作区是否存在 warning，请改为读取 `healthy == false` 或 `warning_count > 0`。
- 如果项目代码曾读取 Domain 背包校验问题的 `issue["code"]`，请改为 `issue["kind"]`。

### 📁 核心受影响文件

- Dialogue 资源校验：`addons/gf/extensions/dialogue/resources/gf_dialogue_resource.gd`。
- SignalBridge 校验：`addons/gf/standard/utilities/signals/bridge/gf_signal_bridge.gd`。
- Foundation 校验基础件：`addons/gf/standard/foundation/validation/gf_validation_issue.gd`、`addons/gf/standard/foundation/validation/gf_validation_diagnostic_adapter.gd`、`addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd`。
- Network 契约校验与生成报告：`addons/gf/extensions/network/contracts/gf_network_contract.gd`、`addons/gf/extensions/network/contracts/gf_network_contract_message.gd`、`addons/gf/extensions/network/contracts/gf_network_contract_field.gd`、`addons/gf/extensions/network/editor/gf_network_contract_generator.gd`。
- Config 校验报告：`addons/gf/standard/utilities/config/gf_config_table_schema.gd`、`addons/gf/standard/utilities/config/validation/gf_config_validation_rule.gd`、`addons/gf/standard/utilities/config/gf_config_table_importer.gd`、`addons/gf/standard/utilities/config/gf_config_reference_resolver.gd`、`addons/gf/standard/utilities/config/gf_config_table_merge_tools.gd`、`addons/gf/standard/utilities/config/gf_config_provider.gd`。
- Save 与 Input 诊断报告：`addons/gf/extensions/save/slots/gf_save_slot_metadata.gd`、`addons/gf/standard/input/editor/gf_input_mapping_dock.gd`。
- Domain 背包校验：`addons/gf/extensions/domain/inventory/gf_slot_inventory_model.gd`。
- 设置预设应用：`addons/gf/standard/utilities/settings/gf_settings_utility.gd`。
- 测试与文档：`tests/gf_core/extensions/dialogue/test_gf_dialogue_extension.gd`、`tests/gf_core/standard/foundation/validation/test_gf_validation_report_dictionary.gd`、`tests/gf_core/standard/utilities/signals/bridge/test_gf_signal_bridge.gd`、`tests/gf_core/extensions/network/test_gf_network_extension.gd`、`tests/gf_core/standard/utilities/config/test_gf_config_table_schema.gd`、`tests/gf_core/standard/utilities/config/test_gf_config_table_merge_tools.gd`、`tests/gf_core/extensions/save/test_gf_save_slot_metadata.gd`、`tests/gf_core/standard/input/editor/test_gf_input_mapping_dock.gd`、`tests/gf_core/extensions/domain/test_gf_domain_extensions.gd`、`tests/gf_core/standard/utilities/settings/test_gf_settings_utility.gd`、`docs/zh/extensions/dialogue/index.md`、`docs/zh/standard/foundation/data-validation.md`、`docs/zh/standard/input-flow/input-assist.md`、`docs/zh/extensions/save-graph/index.md`、`docs/zh/extensions/network-turnbased/index.md`、`docs/zh/standard/utilities/io/config-remote-outbox.md`、`docs/zh/standard/utilities/runtime/settings-ui-scene.md`。
