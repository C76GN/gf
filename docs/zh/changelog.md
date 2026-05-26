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

## [3.18.1] - 2026-05-27

**版本概述**：重构正式文档体系，新增结构化 API Catalog 与生成式 API Reference，并把文档形态、链接、渲染语法和公开 API 覆盖纳入自动校验。本版本不改变运行时公开 API。

### 🚀 新增特性 (Added)

- 新增 `tools/generate_api_reference.py`，从 `addons/gf/**/*.gd` 的 API 注释生成 `docs/api_catalog` XML Catalog，再生成 `docs/zh/reference/api` Markdown Reference。
- 新增 API Reference 覆盖校验，确认 XML Catalog 中的公开类和公开成员都能在对应 Reference 页面找到。
- 新增 `tools/check_docs_quality.py`，用于检查手写文档的页面长度、段落长度、H1、代码块语言、页面粒度、入口模板、本地链接、Mermaid 渲染语法、维护流程泄漏和长正文结构。
- 新增维护者资料区，集中维护发布、文档治理、页面粒度和编辑器维护规则，避免维护流程混入用户正文。

### 🔄 机制更改 (Changed)

- 重组中文文档目录，使 `overview`、`kernel`、`standard`、`extensions`、`editor`、`reference` 的文件目录与 MkDocs 导航严格对应。
- 将大型组合页拆成稳定语义目录和子页，同时增加页面粒度边界，避免继续把同一组内容拆成碎片页。
- 重写 Standard 与 Extensions 入口页，使正文以职责、阅读入口和使用边界为主，API 清单改由生成式 Reference 承担。
- 更新 README、维护说明、MkDocs 导航和 Release 工作流，使发布构建校验 API Reference 与手写文档质量。

### 🐛 Bug 修复 (Fixed)

- 修复 Mermaid 内容只显示源码、不渲染图表的问题。
- 修复 API Reference 生成器未覆盖公开内部类的问题，例如 `GFBehaviorTree.BTNode` 与 `GFCombatPayloads.GFBuffAppliedPayload`。
- 修复 `@return:` 标签解析，确保返回值说明进入 XML Catalog 和 Markdown Reference。
- 移除公开正文中的治理性说明、目录定位说明和维护流程残留。

### 🔌 API 变动说明 (API Changes)

- 本版本不新增、移除或重命名运行时公开 API。
- 所有 GF 内置扩展仅同步 `version` 到 `3.18.1`；`extension_version` 不变。

### 📘 升级指南 (Migration Guide)

- 现有项目无需修改运行时代码。
- 文档入口调整为 Read the Docs 导航和 [API Reference](reference/api/index.md)；旧组合页的内容已移动到对应语义目录。
- 维护者更新 API 注释后应运行 `python tools\generate_api_reference.py`，提交前运行 `python tools\generate_api_reference.py --check` 与 `python tools\check_docs_quality.py --strict`。

### 📁 核心受影响文件 (Affected Files)

- 文档生成与质量门禁：`tools/generate_api_reference.py`、`tools/check_docs_quality.py`、`.github/workflows/release.yml`。
- 生成物：`docs/api_catalog/**`、`docs/zh/reference/api/**`。
- 正式文档：中文文档源、维护者资料区、`mkdocs.yml`。
- 维护测试与入口：`tests/gf_core/maintenance/test_docs_structure_validation.gd`、`README.md`、`README.zh.md`、AI 维护指南。
- 发布元数据：`addons/gf/plugin.cfg`、`addons/gf/extensions/*/gf_extension.json`、`ASSET_LIBRARY.md`。
