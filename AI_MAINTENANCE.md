# GF AI 维护指南

本文档只给 AI 维护者使用，不作为面向普通用户的正式说明。它用于约束 AI 辅助维护 GF Framework 时的工作方式，重点说明：改完代码或文档后要同步检查哪些文件、文档应按什么标准补全、如何生成 AI 专用 API 文档，以及临时 AI 工作记录如何与 Git 提交内容隔离。

## 核心规则

- 文件优先按 UTF-8 读取和输出。
- GDScript 代码必须遵循 `CODING_STYLE.md`，包括文件结构、注释、类型提示、格式、编码和换行。
- 除非维护者明确批准破坏性升级，否则 GF 当前稳定主版本线保持向后兼容。
- 文档修改要小而聚焦。概念属于哪个页面，就优先补哪个页面，不要把同一段解释散落到多个地方。
- 不要修改 vendored `addons/gut/**`，除非任务明确要求处理 GUT。
- 不要提交临时分析、任务草稿、本地生成的临时上下文文件、调试报告或 AI 会话记录。
- 在大规模理解源码、补正式文档或检查 API 覆盖前，优先生成并阅读 AI 专用 API 文档。

## 层级边界规范

GF 源码依赖方向必须保持稳定单向：

```text
addons/gf/kernel <- addons/gf/standard <- addons/gf/extensions
```

- `addons/gf/kernel/**` 不能 `preload()`、`load()`、直接写入路径或直接引用 `addons/gf/standard/**` 的具体类名。
- `standard` 可以依赖 `kernel`；扩展可以依赖 `kernel`，也可以按需依赖稳定的 `standard`。
- 如果 `kernel` 运行时必须直接识别某个能力，应把最小契约、协议或基础工具放入 `kernel`，再让 `standard` 或扩展提供具体实现。例如内核识别 `GFTimeProvider`，标准库的 `GFTimeUtility` 只是实现。
- 可选官方扩展不能被 `kernel` 或 `standard` 硬 preload、硬编码 `res://addons/gf/extensions/official/**` 脚本路径、硬编码 `gf.official.*` 扩展 ID，或直接引用扩展内 `class_name`。
- `standard` 不能主动认识、探测或弱联动任何官方扩展。需要让标准库能力呈现扩展信息时，必须由扩展侧依赖 `standard` 的通用注册入口主动贡献，例如向 `GFDiagnosticsUtility` 注册快照、监控项或命令。
- 官方扩展必须保持原子化。官方扩展 manifest 的 `dependencies` 只能声明 `gf.kernel` 与 `gf.standard`，不能声明其他官方扩展硬依赖；官方扩展也不能声明 `optional_dependencies`。
- 官方扩展之间不能通过其他官方扩展的路径、扩展 ID、`class_name`、动态脚本加载、动态扩展探测或隐藏协议形成软协作。跨官方扩展组合属于项目 Installer、社区扩展或外部插件，不能写回官方扩展。
- `optional_dependencies` 只面向社区扩展、项目扩展或外部插件，用于表达不会自动启用、也不允许硬引用源码的可选关系；官方扩展不使用这个字段。
- `kernel/editor` 可以承载通用菜单、文件对话框和模板生成器，但不能硬编码 `standard` 或可选扩展的具体模板类型、基类或扩展 ID；标准库模板由 `gf_standard_editor_extensions.gd` 注入，可选扩展模板由扩展自己的 `editor_action_paths` 注入。
- 根插件 `addons/gf/plugin.gd` 是组合入口，可以收集标准库编辑器增强并传给 `kernel/editor` 辅助脚本；这个例外不允许扩散到 `addons/gf/kernel/**`。
- 移动层级边界时，同步更新源码路径、测试、正式文档、`docs/zh/changelog.md` 和 API 摘要；不要留下重复路径副本造成重复 `class_name` 或 UID 冲突。
- 修改层级依赖后，必须运行 `tests/gf_core/maintenance/test_layer_boundary_validation.gd`，确保 `kernel` 不引用 `standard` / 官方扩展具体类型、`kernel` 不硬编码官方扩展 ID、`standard` 不引用官方扩展路径、扩展 ID 或扩展内类名，并确保官方扩展保持原子化、只依赖 `gf.kernel` 与 `gf.standard`。
- 重命名、移动或移除公开脚本后，必须运行 `tests/gf_core/maintenance/test_gdscript_parse_validation.gd`，确认已移除公开类名没有残留、公开 `class_name` 没有重复、`.gd.uid` 没有孤儿文件或 UID 冲突。

## 按变更类型检查文件

### 源码变更

修改 `addons/gf/**` 的公开行为后，检查并按需更新：

- `tests/gf_core/**`：为新增或变化的行为补充聚焦的 GUT 测试。
- `docs/zh/**`：更新负责解释该模块或概念的文档页面。
- `docs/zh/changelog.md`：记录新增、修复、行为变化、API 变化和迁移说明。
- `README.md` 与 `addons/gf/README.md`：仅当功能列表、快速开始、安装说明或项目定位发生变化时更新。
- `ASSET_LIBRARY.md`：仅当 Asset Library 描述、版本、最低 Godot 版本或发布元数据变化时更新。
- `addons/gf/plugin.cfg`：仅在明确进行版本号升级时更新。

修改任何 `.gd` 文件后，额外执行以下布局检查：

- 对照 `CODING_STYLE.md` 的代码布局顺序检查被修改文件。
- 对照本文件的层级边界规范检查新增 preload、load、class_name 引用和路径常量。
- 顶层 section 必须遵循 `CODING_STYLE.md` 的整体顺序，不得在私有/辅助或内部类 section 后回到普通公共区。
- 以下划线 `_` 开头的内部方法，不得放在公共方法、获取方法、注册方法、事件方法等普通公共区。
- 供子类重写的 `_` 方法必须放在明确的可重写钩子或虚方法区。
- Godot 生命周期方法和信号回调方法必须放在对应区，或在确有必要时放在私有/辅助区。
- 通过反射、`has_method()`、`call()` 或约定名称调用的内部方法，不因此变成公共方法；仍按命名和语义归类。
- 带 `class_name` 的文件必须先写文件级 `##` 说明，再声明 `class_name` 与 `extends`。
- 顶层内部类必须放在明确的内部类 section 中，并优先位于文件末尾。

### 公开 API 变更

公开 API 包括 `class_name`、信号、导出变量、公共变量、枚举、公共方法、Resource 字段、ProjectSettings 项、存档格式和已文档化的行为。

新增或修改公开 API 后，检查：

- 变更文件中的 API 注释，尤其是公共函数的 `## @param`。
- `tests/gf_core/maintenance/test_api_docs_validation.gd` 的隐含要求：注释参数必须和函数签名双向一致。
- 对应文档页面。
- `docs/zh/changelog.md` 的 `API Changes` 与 `Migration Guide`。

移除公开 API 或改变默认行为时：

- 当前稳定主版本线默认不做，除非维护者明确批准。
- 一旦批准，应说明为什么破坏兼容，并按 SemVer 的下一个主版本处理。

### 纯文档变更

只改文档时，检查：

- `docs/zh/index.md` 与 `mkdocs.yml`：新增、删除、重命名页面或调整阅读顺序时更新。
- `README.md` 与 `README.zh.md`：根目录概览、文档索引或项目定位过期时同步更新，保持同一章节顺序和信息粒度。
- `addons/gf/README.md`：安装扩展内说明需要与根目录概览保持一致时更新。
- `docs/wiki/**`：只保留 GitHub Wiki 入口、侧栏和页脚；正式正文只能维护在 Read the Docs 源文件 `docs/zh/**` 中。
- 新增、删除或重命名 `docs/zh/**/*.md` 时，运行 `tests/gf_core/maintenance/test_docs_structure_validation.gd` 和 `python -m mkdocs build --strict`，确认页面已进入导航且链接有效。
- 修改 `docs/wiki/**` 时，同样运行 `tests/gf_core/maintenance/test_docs_structure_validation.gd`，确认旧 Wiki 没有重新变成正文副本。

仅修错字或改善措辞时，不需要为 changelog 添加条目，除非改动影响发布说明或迁移指导。

### 发布变更

明确进行版本发布或版本号升级时，这些文件必须一起检查：

- `addons/gf/plugin.cfg`
- `ASSET_LIBRARY.md`
- `docs/zh/changelog.md`
- `README.md` 与 `addons/gf/README.md`，如果公开概览发生变化

版本与提交流程：

- 功能开发、修复或文档补充过程中，如果需要记录发布说明，先写入 `docs/zh/changelog.md` 的 `[未发布]` 小节；如果没有 `[未发布]` 小节，就在最新正式版本上方创建。
- 在用户确认本轮修改没有问题之前，不要把 `[未发布]` 改成具体版本号，也不要更新 `addons/gf/plugin.cfg` 或 `ASSET_LIBRARY.md` 的版本号。
- 用户确认进入发布或提交阶段后，根据实际变更确定 SemVer 版本号：兼容 bug 修复或小型加固用 patch；向后兼容的新公开 API、设置或功能通常用 minor；破坏兼容只允许在用户明确批准后按 major 处理。
- 确定版本后，把 `[未发布]` 改为具体版本条目，同步更新 `addons/gf/plugin.cfg`、`ASSET_LIBRARY.md`、所有官方扩展 `gf_extension.json` 的 `version` 和必要的发布说明；保留未来新工作的 `[未发布]` 创建时机由下一轮维护决定。
- 官方扩展 manifest 的 `version` 表示 GF 官方发行版本，发布时所有 `addons/gf/extensions/official/*/gf_extension.json` 必须同步为当前 GF 版本。官方扩展 manifest 的 `extension_version` 表示单个扩展自身版本，只有该扩展的公开 API、配置、行为或兼容性契约发生变化时才按 SemVer 递增；本轮未改变的官方扩展只同步 `version`，不递增 `extension_version`。
- 正式 `docs/zh/changelog.md` 只保留当前最新发布版本。发布新版本时必须删除上一个正式版本条目，旧版本历史以 Git 历史和 GitHub Releases 为准，不要让旧日志长期堆积在正式文档中。
- 除非用户明确要求 AI 直接提交，否则只准备 commit message 和待提交文件清单，让用户手动提交。若用户明确要求 AI 提交，提交前必须再次运行相关测试和文档/API 校验。
- 提交后不要自动创建 Git tag；只有用户明确要求打 tag 时，才创建对应版本 tag。

Commit message 模板：

```text
<Imperative summary>

<One paragraph or short bullet-style body describing what changed. Files changed: list the main modules, tests, docs, and metadata touched. Purpose: explain why the change exists and what project-level problem it solves.>
```

示例：

```text
Release 1.23.3 lifecycle dependency hardening

Add installer timeout protection, manual scoped context initialization, assignable lookup caching, factory lifetime validation, factory alias warnings, and GFAccess fallback injection consistency. Files changed: core lifecycle and binding scripts under addons/gf/kernel/core, accessor generation under addons/gf/kernel/editor, plugin project settings metadata, focused gf_core tests, lifecycle/accessor docs, changelog, plugin.cfg, and ASSET_LIBRARY.md. Purpose: make lifecycle and dependency ownership failures surface earlier while keeping GF current stable behavior compatible.
```

源码变更后优先运行：

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gf_core -ginclude_subdirs -gexit
```

该测试集包含静态维护检查，例如 API 注释同步和 GDScript 布局约束。能用机器稳定判断的维护规则，应优先补到测试或工具中，而不是只写在文字说明里。

层级边界变更后至少额外运行：

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/gf_core/maintenance/test_layer_boundary_validation.gd -gexit
```

## 文档维护标准

每个文档页面应尽量回答这些问题：

- 这个模块解决什么问题？
- 项目什么时候应该用它，什么时候不该用？
- 主要入口类有哪些？
- 生命周期、所有权或注册规则是什么？
- 常见工作流是什么？
- 和旧版本或兼容 API 有什么关系？
- 哪些源码或测试文件适合作为参考？

页面可按需要使用这些章节：

- `定位`
- `核心类`
- `典型流程`
- `常用 API`
- `注意事项`
- `与其他模块的关系`
- `迁移与兼容`

示例要短，并尽量保持 Godot 4.6 / GDScript 风格可用。除非页面就是示例页，否则不要把具体项目玩法规则写成框架规则。

MkDocs 页面拆分约定：

- `docs/zh` 的文件目录必须和 Read the Docs 导航保持一致，顶层只保留 `index.md`、`faq.md`、`changelog.md` 以及 `overview/`、`kernel/`、`standard/`、`extensions/`、`editor/`、`maintenance/` 等语义目录。
- 每个语义目录的 `index.md` 作为本组导读，只放定位、入口和边界，不再承载大量具体 API 说明。
- 具体能力放入所属层级下的语义子目录或子页，例如 `standard/utilities/io/storage-snapshot.md`；新增专题时优先追加同组子页，不要把无关能力重新塞回一个长页面。
- 中英文本地化时，`docs/zh` 与未来 `docs/en` 应保持相同目录 slug、子页 slug 和导航层级；翻译标题可以不同，但页面职责和内容边界必须一致。

旧 GitHub Wiki 维护约定：

- `docs/wiki/Home.md`、`_Sidebar.md` 和 `_Footer.md` 只作为 Read the Docs 入口与旧链接导航。
- 不保留其他 `docs/wiki/*.md` 章节页、迁移页或兼容页。
- 不在 Wiki 中复制正式正文、API 说明、迁移指南或示例代码，避免与 Read the Docs 双写分叉。

README 双语维护约定：

- `README.md` 是 GitHub 默认英文入口，顶部保留 `README.zh.md` 的语言切换链接。
- `README.zh.md` 是中文入口，顶部保留返回 `README.md` 的语言切换链接。
- 两个根 README 的章节顺序、项目定位、安装步骤、核心概念、分层说明、测试命令和文档入口应保持一致；只允许语言表达不同。
- `addons/gf/README.md` 是插件分发目录的简短说明，只链接根 README 与 Read the Docs，不承载完整项目正文。

## AI 专用 API 文档

GF 的公开类和函数数量较多，AI 不可能每次都完整重读全部源码。维护任务开始时，应先生成或校验一份面向 AI 的 API 摘要，再按模块打开相关源码做抽查。

生成命令：

```powershell
python tools\generate_ai_api.py --source addons\gf --output ai_analysis\generated_api
```

校验当前生成结果是否和源码一致：

```powershell
python tools\generate_ai_api.py --source addons\gf --output ai_analysis\generated_api --check
```

同时校验正式文档是否覆盖所有公开 `class_name`：

```powershell
python tools\generate_ai_api.py --source addons\gf --output ai_analysis\generated_api --check --check-wiki-coverage
```

使用规则：

- 生成结果默认放在 `ai_analysis/generated_api/`，该目录被 Git 忽略，不提交。
- 生成脚本 `tools/generate_ai_api.py` 是维护工具，可以提交。
- 如果 `--check` 失败，先重新生成，再继续文档维护。
- `--check-wiki-coverage` 会递归扫描 `docs/zh/**/*.md` 并排除 `changelog.md`，要求每个公开 `class_name` 至少在正式功能页中出现一次；它只证明有入口，不证明描述已经足够准确。
- 先读 `ai_analysis/generated_api/index.md`，确认模块分组和类路径。
- 查具体模块时读 `ai_analysis/generated_api/modules/*.md`。
- 需要结构化检索时读 `ai_analysis/generated_api/api.json`。
- 生成文档只是索引，不是最终事实来源。涉及行为细节、兼容语义、生命周期、副作用、存档格式或迁移说明时，必须再打开对应 `.gd` 源码和相关 `tests/gf_core/**` 测试核对。

生成内容包含：

- `class_name`、`extends`、文件路径和类摘要。
- 公共信号、枚举、常量、导出变量、公共变量和公共方法。
- 方法签名及其附近的 `##` 文档注释。
- 按目录或模块分组的 Markdown 摘要。
- `api.json` 结构化索引和 `source_digest`，用于判断摘要是否来自同一批源码。

每次公开 API 变化后，都要重新运行生成命令，并用 `--check` 确认当前 AI API 摘要准确。

## AI 临时工作区

`ai_analysis/` 是 AI 临时工作区，已在 `.gitignore` 中忽略。

建议用途：

- `ai_analysis/ai_analysis.md`：当前任务摘要、决策、开放问题和下一步。
- `ai_analysis/todo.md`：大型未完成任务的临时清单。
- `ai_analysis/generated_api/`：本地生成的 AI API 摘要。
- `ai_analysis/reports/`：本地审计、diff、一次性检查结果。

使用规则：

- 内容要事实化、简洁，只记录恢复上下文所需的信息。
- 不把它当作面向用户的正式文档。
- 不在公开文档中把它写成必需项目文件。
- 除非维护者明确改变忽略策略，否则不要提交其中内容。
