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

## [3.22.0] - 2026-05-28

**版本概述**：统一基础层结果、报告、metadata 和 options 字典语义，降低后续模块手写字段与复制规则漂移。

### 🚀 新增特性 (Added)

- `GFResultDictionary` 新增 `reason`、`message`、`issues`、`issue_count`、`healthy`、`summary` 与 `next_action` 等通用字段常量，并新增 `make_rejected()`、`make_with_issues()`、`normalize()`、`is_ok()` 和 `merge_metadata()`。
- `GFVariantData` 新增字典归一化、metadata 复制 / 合并和 options 类型读取入口。

### 🔄 机制更改 (Changed)

- `GFResultDictionary.make()` 现在会深拷贝调用方字段，避免结果字典与外部集合共享可变状态。
- `GFValidationReportDictionary.finalize_report()` 现在始终输出 `issue_count`，让字典式报告字段与对象式报告保持一致。
- UI 面板策略、UI 路由、通知、后台任务和下载任务的 options / metadata 读取改为复用 `GFVariantData`，减少高频 Utility 中的手写字典解析。
- 音频 Bank 扫描 / 导入工具的 options 读取改为复用 `GFVariantData`，并统一规范化扩展名、StringName 键和字符串数字选项。
- 存储同步工具的结果状态、后端记录、resolver metadata 和写回选项改为复用 `GFResultDictionary` / `GFVariantData`，减少同步结果字典的字段漂移。
- 后台任务的线程结果改为复用 `GFResultDictionary` 归一化失败信息，支持 `error`、`message` 与 `reason` 兜底。
- 发布流程新增 Asset Store 专用 ZIP 打包步骤，生成的下载包以 `addons/` 为根目录，并由 release metadata 检查验证包结构。
- API Surface Contract 增加公开 `options: Dictionary` 参数必须提供 `@schema options` 的显式回归用例。

### 🐛 Bug 修复 (Fixed)

- 修复 3 个测试脚本中的 GDScript 局部变量遮蔽 / 易混淆声明警告。

### 🔌 API 变动说明 (API Changes)

- `GFResultDictionary.make_failure()` 会补齐 `reason` 与 `message` 字段；旧的 `error` 字段仍保留为通用错误文本。
- `GFVariantData.deep_merge_defaults()` 复用新的字典合并语义，行为仍为只补缺失字段。

### 📁 核心受影响文件 (Affected Files)

- `addons/gf/standard/foundation/validation/gf_result_dictionary.gd`
- `addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd`
- `addons/gf/standard/foundation/variant/gf_variant_data.gd`
- `addons/gf/standard/utilities/ui/gf_ui_utility.gd`
- `addons/gf/standard/utilities/ui/gf_ui_route.gd`
- `addons/gf/standard/utilities/ui/gf_notification_utility.gd`
- `addons/gf/standard/utilities/jobs/gf_background_work_utility.gd`
- `addons/gf/standard/utilities/io/gf_download_utility.gd`
- `addons/gf/standard/utilities/audio/gf_audio_bank_tools.gd`
- `addons/gf/standard/utilities/storage/gf_storage_sync_utility.gd`
- `.github/workflows/release.yml`
- `tools/build_asset_store_package.py`
- `tools/gf_maintenance.py`
- `ASSET_LIBRARY.md`
- `ASSET_STORE.md`
- `tests/gf_core/standard/foundation/validation/test_gf_result_dictionary.gd`
- `tests/gf_core/standard/foundation/validation/test_gf_validation_report_dictionary.gd`
- `tests/gf_core/standard/foundation/variant/test_gf_variant_data_and_json_codec.gd`
- `tests/gf_core/standard/utilities/ui/test_gf_ui_utility.gd`
- `tests/gf_core/standard/utilities/ui/test_gf_ui_router_utility.gd`
- `tests/gf_core/standard/utilities/ui/test_gf_notification_utility.gd`
- `tests/gf_core/standard/utilities/jobs/test_gf_background_work_utility.gd`
- `tests/gf_core/standard/utilities/io/test_gf_download_utility.gd`
- `tests/gf_core/standard/utilities/audio/test_gf_audio_bank_tools.gd`
- `tests/gf_core/standard/utilities/storage/test_gf_storage_sync_utility.gd`
- `tests/gf_core/maintenance/test_api_surface_contract_validation.gd`
- `tests/gf_core/standard/utilities/pooling/test_gf_ref_counted_pool.gd`
- `tests/gf_core/standard/utilities/assets/test_gf_resource_registry.gd`
- `tests/gf_core/extensions/combat/test_gf_combat_extension.gd`
- `docs/zh/standard/foundation/data-validation/validation-reporting/result-dictionary.md`
- `docs/zh/standard/foundation/data-validation/validation-reporting/reports-diagnostics/dictionary-reports.md`
- `docs/zh/standard/foundation/data-validation/formula-variant/variant-data-json.md`
