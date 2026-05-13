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

## [3.4.0] - 2026-05-14

**版本概述**：本版本新增运行时调参、发射体生成、动作工厂、音频资源作者工具和 GDScript 导表工具链能力。所有新增能力均保持向后兼容，并继续以通用协议和显式配置为边界。

### 🚀 新增特性

- Combat 新增 `GFProjectileEmitter2D` / `GFProjectileEmitter3D`、`GFProjectileCatalog`、发射目录条目和 2D/3D 发射点模式资源，用于通用发射体生成、目录解析和上下文注入。
- ActionQueue 扩展 `GFAction` 常用工厂，新增相对 Tween、透明度偏移、可见性、属性写入和节点释放动作入口。
- 标准库 Debug 新增 `GFRuntimeInspectorUtility` 与 `GFRuntimeTunableProperty`，提供显式 schema 驱动的运行时检查和受控调参注册表。
- `GFAudioBankTools` 新增目录扫描创建与同步入口；`GFAudioBank` Inspector 增加扫描导入 UI。
- 标准库 Config 新增 `GFConfigValidationRule` 及范围、正则、集合、数量、非默认值、资源路径和文本 key 校验规则，可挂载到字段、记录或整表。
- 标准库 Config 新增 `GFConfigTableMergePolicy`、`GFConfigTableMergeTools` 和 `GFConfigBuildProfile`，提供通用表补丁合并、删除标记、metadata groups/tags 过滤和构建前裁剪。

### 🔄 机制更改

- 新增能力保持可选、显式注册和通用协议；发射体、调参、音频与导表工具均不预设伤害、阵营、弹药、音频事件命名、构建目标语义或 UI 样式。
- `GFConfigTableImporter` 的 CSV/JSON 校验报告可携带 source、line 与 column，便于编辑器和 CI 精确定位导表错误。
- `GFConfigAccessGenerator` 新增 GDScript 命名选项和 schema 注释输出，生成内容保持为轻量 Provider 访问器，不生成其他语言代码。
- 本版本所有官方扩展的 `version` 同步为 `3.4.0`；Action Queue 因新增公开动作工厂将 `extension_version` 递增为 `1.1.0`，Combat 因新增发射体目录、发射器和发射模式公开 API 将 `extension_version` 递增为 `1.4.0`，其余官方扩展保持原有 `extension_version`。

### 🔌 API 变动说明

- 新增公开类：`GFProjectileEmitter2D`、`GFProjectileEmitter3D`、`GFProjectileCatalog`、`GFProjectileCatalogEntry`、`GFProjectileSpawnPattern2D`、`GFProjectileBurstPattern2D`、`GFProjectileLineSpawnPattern2D`、`GFProjectileSpawnPattern3D`、`GFProjectileConePattern3D`、`GFProjectileLineSpawnPattern3D`。
- 新增公开类：`GFRuntimeInspectorUtility`、`GFRuntimeTunableProperty`。
- 新增公开类：`GFConfigValidationRule`、`GFConfigRangeValidationRule`、`GFConfigRegexValidationRule`、`GFConfigSetValidationRule`、`GFConfigSizeValidationRule`、`GFConfigNotDefaultValidationRule`、`GFConfigResourcePathValidationRule`、`GFConfigLocalizationKeyValidationRule`。
- 新增公开类：`GFConfigTableMergePolicy`、`GFConfigTableMergeTools`、`GFConfigBuildProfile`。
- `GFConfigTableColumn` 新增 `validation_rules`。
- `GFConfigTableSchema` 新增 `record_validation_rules`、`table_validation_rules`，`validate_record()` 和 `validate_table()` 新增可选 `options` 上下文参数。
- `GFConfigProvider.validate_record()` / `validate_table()` 新增可选 `options` 上下文参数。
- `GFConfigTableImporter.parse_json_table()` / `validate_json_table()` 新增可选 `options` 参数；CSV 解析结果新增 `row_locations`。
- `GFConfigAccessGenerator.generate()` / `build_source()` 新增可选 `options` 参数。
- `GFAction` 新增 `tween_by()`、`fade_by()`、`set_property()`、`set_visible()`、`show()`、`hide()` 和 `remove_node()`。
- `GFAudioBankTools` 新增 `create_bank_from_scan()` 与 `sync_bank_from_scan()`。

### 📁 核心受影响文件

- `addons/gf/extensions/official/combat/projectiles/**`
- `addons/gf/extensions/official/action_queue/core/gf_action.gd`
- `addons/gf/standard/utilities/debug/**`
- `addons/gf/standard/utilities/audio/**`
- `addons/gf/standard/utilities/config/**`
- `addons/gf/kernel/editor/gf_config_access_generator.gd`
- `tests/gf_core/extensions/official/combat/test_gf_projectiles.gd`
- `tests/gf_core/extensions/official/action_queue/test_gf_visual_actions.gd`
- `tests/gf_core/standard/utilities/debug/test_gf_runtime_inspector_utility.gd`
- `tests/gf_core/standard/utilities/audio/test_gf_audio_bank_tools.gd`
- `tests/gf_core/standard/utilities/config/**`
- `tests/gf_core/kernel/editor/test_gf_config_access_generator.gd`
