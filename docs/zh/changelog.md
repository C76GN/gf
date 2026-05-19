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

## [3.16.0] - 2026-05-20

**版本概述**：新增通用资产元数据扩展、glTF 导入桥接、内核级对象属性访问工具，并增强标准下载队列的临时网络失败重试能力、SaveGraph 属性 payload 持久化边界、支持报告 Markdown 摘要导出与后台工作主线程应用预算，让项目可以读取结构化导入 metadata、复用统一 Godot 属性边界判断，并更稳健地下载远程文件、保存显式属性、提交人工可读诊断报告和分帧应用后台结果，而不把业务字段写入框架。

### 🚀 新增特性 (Added)

- 新增 `GF Asset Metadata` 扩展，提供 `GFAssetMetadataUtility`、`GFAssetMetadataRecord` 与 glTF 节点 `extras` 到 `gf_asset_metadata` 的导入桥接。
- 扩展 manifest 新增 `import_plugin_paths` 与 `gltf_document_extension_paths`，启用扩展可通过 manifest 贡献 `EditorImportPlugin` 与 `GLTFDocumentExtension`。
- 新增 `GFObjectPropertyTools`，集中提供对象属性信息查询、`NodePath` 属性路径读写、只读判断、基础类型校验和安全转换。
- `GFDownloadUtility` 新增可配置重试能力，可对临时网络失败、限流或服务器错误进行有限重试。
- `GFSupportReportUtility` 新增 Markdown 摘要导出能力，便于把同一份支持报告贴入 Issue、PR、客服工单或测试记录。
- `GFBackgroundWorkUtility` 新增可选主线程应用时间预算，便于把大量后台结果的主线程写回拆到多个 tick。
- 新增 `GFConfigValidationReport`，统一配置表 schema、导入器、引用解析与补丁合并的校验报告构建。

### 🔄 机制更改 (Changed)

- `GFResourceTableEditor`、`GFRuntimeTunableProperty` 与 `GFNodePropertySerializer` 改为复用 `GFObjectPropertyTools` 执行通用属性访问，减少重复的反射与类型处理逻辑。
- `GFNodePropertySerializer` 采集的显式属性现在会转换为 JSON 友好的类型化 payload，并可按 `resource_path` 保存外部 `Resource` 引用；无路径内嵌资源、节点对象引用和其他裸 `Object` 会被跳过并输出 warning，避免生成无法稳定落盘的通用属性载荷。
- `GFConfigTableSchema` 新增 schema 定义自检流程，可在校验表数据前报告空字段、重复字段、无效索引、引用来源字段缺失和空校验规则等通用声明问题。
- `GFConfigReferenceResolver.validate_tables()` 会在启用 `validate_schema` 时同时合并 schema 定义自检报告，避免跨表校验被无效声明误导。

### 🐛 Bug 修复

- 修复 `GFConfigTableSchema.require_unique_id` 只覆盖 Array 表的问题，现在 Dictionary 表也会按记录 `id_field` 报告重复 ID。

### 🔌 API 变动说明 (API Changes)

- `GFExtensionManifest` 新增 `gltf_document_extension_paths` 字段。
- `GFExtensionManifest` 新增 `import_plugin_paths` 字段。
- `GFExtensionSettings` 新增 `get_enabled_import_plugin_paths()` 与 `get_enabled_gltf_document_extension_paths()`。
- `GFDownloadUtility` 新增 `default_max_retries` 与 `default_retry_delay_seconds`。
- `GFDownloadTask` 新增 `max_retries`、`retry_count`、`retry_delay_seconds` 与 `retry_not_before_msec`。
- `GFSupportReportUtility` 新增 `export_report_markdown(report, options = {})`。
- `GFBackgroundWorkUtility` 新增 `max_apply_seconds_per_tick`。
- 新增公开类 `GFObjectPropertyTools`。该类不提供属性绑定、自动派发、表达式执行或业务字段映射，只作为底层属性访问辅助。
- 新增公开类 `GFConfigValidationReport`，用于创建、合并和补全配置表校验报告。
- `GFConfigTableSchema` 新增 `validate_definition(options = {})`。

### 📘 升级指南 (Migration Guide)

- 使用 `GFNodePropertySerializer` 读取自定义 payload 的项目，应把 payload 视为存档格式而不是直接业务字典；常见 Godot 值类型会以 GF 类型标记保存，应用时会自动恢复。需要保存内嵌资源快照、节点对象引用或业务对象图时，请改写项目自己的 `GFNodeSerializer` 或 `GFSavePipelineStep`。
- 项目若需要消费导入资产 metadata，可启用 `gf.asset_metadata` 并通过 `GFAssetMetadataUtility` 收集节点树记录。

### 📁 核心受影响文件 (Affected Files)

- 扩展基础设施：`addons/gf/kernel/extension/gf_extension_manifest.gd`、`addons/gf/kernel/extension/gf_extension_settings.gd`、`addons/gf/kernel/editor/gf_plugin_import_tools.gd`、`addons/gf/kernel/editor/gf_plugin_gltf_document_tools.gd`、`addons/gf/plugin.gd`。
- 标准下载工具：`addons/gf/standard/utilities/io/gf_download_utility.gd`、`addons/gf/standard/utilities/io/gf_download_task.gd`。
- 标准任务工具：`addons/gf/standard/utilities/jobs/gf_background_work_utility.gd`。
- 资产元数据扩展：`addons/gf/extensions/asset_metadata/**`。
- 对象属性工具：`addons/gf/kernel/core/gf_object_property_tools.gd`、`addons/gf/kernel/editor/gf_resource_table_editor.gd`、`addons/gf/standard/utilities/debug/gf_runtime_tunable_property.gd`、`addons/gf/extensions/save/serializers/gf_node_property_serializer.gd`。
- 支持报告：`addons/gf/standard/utilities/debug/gf_support_report_utility.gd`。
- 配置表校验：`addons/gf/standard/utilities/config/gf_config_validation_report.gd`、`addons/gf/standard/utilities/config/gf_config_table_schema.gd`、`addons/gf/standard/utilities/config/gf_config_provider.gd`、`addons/gf/standard/utilities/config/gf_config_table_importer.gd`、`addons/gf/standard/utilities/config/gf_config_reference_resolver.gd`、`addons/gf/standard/utilities/config/gf_config_table_merge_tools.gd`、`addons/gf/standard/utilities/config/validation/gf_config_validation_rule.gd`、`tests/gf_core/standard/utilities/config/test_gf_config_table_schema.gd`、`tests/gf_core/standard/utilities/config/test_gf_config_validation_report.gd`、`docs/zh/standard/utilities/io/config-remote-outbox.md`。
- 测试与文档：`tests/gf_core/extensions/asset_metadata/**`、`tests/gf_core/extensions/save/test_gf_node_serializers_focused.gd`、`tests/gf_core/kernel/extension/test_gf_extension_manifest.gd`、`tests/gf_core/kernel/core/test_gf_object_property_tools.gd`、`tests/gf_core/standard/utilities/debug/test_gf_support_report_utility.gd`、`tests/gf_core/standard/utilities/io/test_gf_download_utility.gd`、`tests/gf_core/standard/utilities/jobs/test_gf_background_work_utility.gd`、`docs/zh/extensions/asset-metadata/index.md`、`docs/zh/extensions/save-graph/index.md`、`docs/zh/kernel/index.md`、`docs/zh/standard/utilities/runtime/debug-observability.md`、`docs/zh/standard/utilities/io/assets-jobs-warmup.md`。
