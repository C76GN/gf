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

## [3.19.0] - 2026-05-27

**版本概述**：新增无状态 UUID、2D 曲线折线辅助和可选空间音效设置资源，用于统一框架内通用字符串标识、几何路径处理与空间 SFX 播放参数。

### 🚀 新增特性 (Added)

- 新增 `GFUuid`，提供 UUID v4、UUID v7 生成和 canonical UUID 校验。
- 新增 `GFCurve2DMath`，提供折线长度、归一化采样、点距简化，以及闭合矩形和椭圆 `Curve2D` 生成/复用写入。
- 新增 `GFAudioSpatialSettings`，可挂到 `GFAudioClip.spatial_settings`，为 2D/3D 空间 SFX 配置距离衰减、区域、复音、播放类型、3D 发射角、滤波和多普勒参数。
- `GFValidationReportDictionary` 新增通用问题指纹与报告过滤能力，方便项目工具、导入器和 CI 复用同一份报告格式实现忽略项与基线。

### 🔄 机制更改 (Changed)

- `tools/generate_api_reference.py` 生成的 class XML 改用单类 `classDigest`，全局 `sourceDigest` 仅保留在 Catalog 索引中，且正式 Catalog 不再记录源码行号，减少后续单类 API 变更或纯位置变化造成的生成文件噪声。
- `tools/generate_api_reference.py` 与 `tools/generate_ai_api.py` 现在能正确解析 `@export_range(...) var`、`@export_file(...) var`、`@export_node_path(...) var` 等 Godot 装饰导出变量，避免 API Reference 漏掉公开属性。
- `tools/generate_api_reference.py` 与 `tools/generate_ai_api.py` 改为复用 `tools/gdscript_api_parser.py`，让正式 API Reference 和 AI API 摘要保持同一套 GDScript 声明与 API 注释解析规则。
- `GFAnalyticsUtility` 内部生成 client/session id 时改用 `GFUuid.generate_v4()`，收敛重复私有实现。
- `GFAudioUtility` 播放空间 SFX 时会读取 `GFAudioClip.spatial_settings`，为空时保持 Godot 播放器默认空间参数。

### 🐛 Bug 修复 (Fixed)

- 修复 3D 空间 SFX 播放器在进入场景树前写入 `global_position` 时触发 Godot `!is_inside_tree()` 错误的问题。

### 🔌 API 变动说明 (API Changes)

- 新增公开类 `GFUuid`。
- 新增公开类 `GFCurve2DMath`。
- 新增公开类 `GFAudioSpatialSettings`。
- `GFAudioClip` 新增公开字段 `spatial_settings`。
- `GFValidationReportDictionary` 新增 `make_issue_fingerprint()` 与 `filter_issues()`。
- 所有 GF 内置扩展仅同步 `version` 到 `3.19.0`；`extension_version` 不变。

### 📘 升级指南 (Migration Guide)

- 现有项目无需修改；需要生成通用字符串标识时可直接使用 `GFUuid`，需要处理通用 2D 折线或基础闭合曲线时可使用 `GFCurve2DMath`。
- 现有音频片段默认行为不变；只有显式设置 `GFAudioClip.spatial_settings` 的空间 SFX 会应用新参数。

### 📁 核心受影响文件 (Affected Files)

- `addons/gf/standard/foundation/identity/gf_uuid.gd`
- `addons/gf/standard/foundation/math/gf_curve_2d_math.gd`
- `addons/gf/standard/utilities/analytics/gf_analytics_utility.gd`
- `addons/gf/standard/utilities/audio/gf_audio_clip.gd`
- `addons/gf/standard/utilities/audio/gf_audio_spatial_settings.gd`
- `addons/gf/standard/utilities/audio/gf_audio_utility.gd`
- `addons/gf/standard/foundation/validation/gf_validation_report_dictionary.gd`
- `tools/generate_api_reference.py`
- `tools/generate_ai_api.py`
- `tools/gdscript_api_parser.py`
- `tests/gf_core/standard/foundation/identity/test_gf_uuid.gd`
- `tests/gf_core/standard/foundation/math/test_gf_curve_2d_math.gd`
- `tests/gf_core/standard/foundation/validation/test_gf_validation_report_dictionary.gd`
- `tests/gf_core/standard/utilities/audio/test_gf_audio_utility.gd`
- `docs/zh/standard/foundation/data-validation/identity/index.md`
- `docs/zh/standard/foundation/grid-spatial/curve-2d.md`
- `docs/zh/standard/foundation/data-validation/validation-reporting/reports-diagnostics/dictionary-reports.md`
- `docs/zh/standard/utilities/runtime/audio/**`
- `addons/gf/plugin.cfg`
- `addons/gf/extensions/*/gf_extension.json`
- `ASSET_LIBRARY.md`
