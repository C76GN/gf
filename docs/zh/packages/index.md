# 官方包总览与包规范

本页解释 GF 官方包与社区包的定位、manifest、启用状态、Installer、编辑器扩展和导出排除规则。

GF Framework 采用三层稳定结构：

- `addons/gf/kernel`：运行内核，只放框架能否启动、注册、注入、派发和编辑器集成所必需的代码。
- `addons/gf/standard`：标准库，放足够通用、稳定、默认随框架理解的基础能力，例如 `foundation`、输入体系、通用运行时工具、状态机、命令、序列和消息支撑。
- `addons/gf/packages`：包生态入口，放官方包和社区包。

`foundation` 位于 `standard/foundation`，保持纯算法、纯数据和纯适配职责，不参与 `GFArchitecture` 生命周期注册。

依赖方向必须保持单向：`kernel` 不直接依赖 `standard` 或任何可选包；`standard` 可以依赖 `kernel`；官方包和社区包可以依赖 `kernel`，也可以按需依赖稳定的 `standard` 能力。凡是 `kernel` 必须直接识别的概念，都应收敛为 `kernel` 中的契约或基础设施，再由 `standard` 或包提供具体实现。

这条边界不仅是目录约定，也是加载约定：`kernel` 和 `standard` 都不能硬 preload 官方包脚本、写死 `res://addons/gf/packages/official/**` 资源路径、硬编码 `gf.official.*` 包 ID，或直接使用官方包里的具体 `class_name`。`standard` 不保留任何官方包弱联动白名单；如果某个包希望出现在诊断、Overlay、工具快照或其他标准库通道里，应由包侧依赖 `standard` 的通用注册入口主动贡献能力，而不是让 `standard` 主动探测包。

官方包之间默认独立，但不是永远禁止协作。需要硬引用另一个官方包时，必须把对方写入 `dependencies`，并确保依赖图无环；未声明依赖的官方包不能互相引用路径、包 ID 或 `class_name`。可选增强使用 `optional_dependencies`、扩展点、服务注册、项目装配或独立 bridge 包表达，不能因为“有它更好用”就在核心脚本里硬 preload 对方。

## 包根目录

```text
addons/gf/
  kernel/
  standard/
  packages/
    official/
    community/
```

`packages` 是统一包根目录，`official` 和 `community` 表示包来源，不是新的架构层。

## 包内结构

包内部不机械复制整个 GF 目录，但官方包需要遵循一个硬边界：包根目录只放包元数据、可选装配入口和说明文档，业务代码进入稳定槽位。这样从文件树上就能看出“这是包入口”还是“这是运行时代码”。

```text
addons/gf/packages/official/example/
  gf_package.json
  package.gd              # 可选，继承 GFInstaller
  README.md               # 可选，包内说明
  foundation/             # 可选：包内纯算法、值对象、codec
  runtime/                # 可选：Model/System/Utility 等运行时模块
  resources/              # 可选：配置、定义、Resource 数据
  nodes/                  # 可选：场景节点、Controller、桥接节点
  editor/                 # 可选：Inspector、生成器、导入器
  actions/                # 可选：动作/步骤/命令式表现单元
  tests/                  # 可选：包内测试
  examples/               # 可选：示例场景或资源
```

如果包已经像 `combat`、`network`、`save` 这类大型官方包一样有更清楚的内部领域，也可以继续使用领域子目录，例如 `hit_detection`、`serialization`、`serializers`。原则是目录名表达稳定职责，而不是表达临时实现细节。小包则优先使用 `runtime`、`resources`、`nodes`、`editor` 这些通用槽位，避免每个包都发明一套命名。

## Manifest

每个包应提供 `gf_package.json`：

```json
{
  "id": "gf.official.combat",
  "display_name": "GF Combat",
  "version": "3.1.0",
  "package_version": "1.1.0",
  "kind": "official",
  "description": "Abstract combat attributes, modifiers, buffs, skills, gauges, and hit detection bridges.",
  "dependencies": ["gf.kernel", "gf.standard"],
  "optional_dependencies": [],
  "installer_paths": [
    "res://addons/gf/packages/official/combat/package.gd"
  ],
  "editor_action_paths": [],
  "editor_dock_paths": [],
  "editor_inspector_paths": [],
  "export_plugin_paths": [],
  "access_generator_extension_paths": [],
  "enabled_by_default": true,
  "tags": ["combat", "attributes", "hit-detection"]
}
```

`version` 表示 manifest 的发行版本。官方包的 `version` 必须始终等于当前 GF 发行版本，例如 GF 3.1.0 发布时所有 `addons/gf/packages/official/*/gf_package.json` 都应写入 `"version": "3.1.0"`；社区包没有随 GF 发行的约束，可以用自己的发行版本。

`package_version` 表示包自身版本。官方包必须显式填写该字段，并按包内公开行为独立递增：兼容 bug 修复递增 patch，向后兼容的新公开 API、配置或功能递增 minor，破坏兼容才递增 major。没有发生包内行为变化的官方包，在 GF 发行版本递增时只同步 `version`，不递增 `package_version`。社区包可以省略 `package_version`，省略时工具会回退使用 `version`。

`dependencies` 是硬依赖：启用当前包时，`GFPackageSettings` 会自动补齐这些依赖；官方包源码只有在声明硬依赖后，才允许硬引用对方公开 API。`optional_dependencies` 是软协作提示：它不会自动启用包，不参与依赖闭包，也不允许硬引用对方源码；它只用于包管理器、诊断和文档说明“如果项目同时启用这些包，可以通过扩展点或 bridge 获得增强”。如果两个可选包的组合需要自己的代码，优先做第三个 bridge 包，让 bridge 包通过 `dependencies` 同时依赖两边。

`enabled_by_default`、`installer_paths`、`editor_action_paths`、`editor_dock_paths`、`editor_inspector_paths`、`export_plugin_paths` 与 `access_generator_extension_paths` 可省略。省略时，`official` 与 `standard` 包默认启用，`community` 包默认不启用；没有安装器或编辑器扩展的包可以把对应数组留空。manifest 声明的扩展脚本路径必须位于包根目录内，避免包通过 manifest 越界绑定其他包或项目脚本。

`access_generator_extension_paths` 会被 `GFAccessGenerator` 消费。扩展脚本建议继承 `RefCounted`，并实现 `append_access_source(builder, records)` 直接使用 `GFSourceBuilder` 追加源码；如果只需要返回静态片段，也可以实现 `get_access_source_sections(records)` 并返回字符串数组。扩展只会从当前启用包中读取，因此禁用包不会继续影响新生成的访问器。

`GFPackageManifest` 负责读取和校验 manifest，`GFPackageCatalog` 负责扫描 `packages/official` 与 `packages/community` 下的一层包目录，`GFPackageSettings` 负责读取项目启用状态、查询包是否存在或启用、补齐依赖闭包、收集启用包的 Installer 路径和编辑器扩展路径，并提供按包 ID 解析包内资源或加载启用包脚本的统一入口。这个设计在 Godot 中保持为轻量文件约定，不引入依赖安装器。

`GFPackageSettings` 会缓存一次 manifest 扫描结果，避免编辑器 Inspector、包面板和扩展查询在同一会话里反复读盘；包目录发生变化时可调用 `clear_manifest_cache()` 刷新。依赖补齐会检测循环依赖并停止递归，`get_manifest_graph_report()` 可一次性报告重复包 ID、缺失硬依赖、缺失可选依赖提示、无效 manifest 与依赖环。`gf.kernel` 和 `gf.standard` 是允许声明的内置依赖 ID，它们不是可启停包目录。

官方包默认只声明 `gf.kernel` 与 `gf.standard`。只有当一个包没有另一个包就无法提供自身核心能力时，才声明官方包硬依赖；只是“同时启用时体验更好”的关系，应保持为软协作、项目装配或 bridge 包。这样既允许 `dialogue -> flow` 这类真实依赖，也避免把所有官方包粘成一个不可拆的大包。

## 安装与装配

包代码存在并不代表会自动注册运行时模块。需要参与 `GFArchitecture` 的包，应提供一个继承 `GFInstaller` 的 `package.gd` 或安装器脚本，并在 manifest 的 `installer_paths` 中声明。

插件启用后，GF 会注册这些项目设置：

- `gf/packages/enabled`：启用的包 ID 列表。
- `gf/packages/auto_install_enabled_installers`：是否在 `Gf.init()` / `Gf.set_architecture()` 时自动执行启用包的 `installer_paths`。
- `gf/packages/export_exclude_disabled`：导出时是否跳过禁用包目录。
- `gf/packages/export_fail_on_disabled_references`：导出审计发现项目仍引用禁用包时，是否把结果报告为错误；默认关闭以兼容旧项目。

新项目会把官方包的默认启用列表写入 `gf/packages/enabled`。如果希望项目只启用其中一部分，可以通过 `GF Packages` 面板或 `GFPackageSettings.set_enabled_package_ids()` 保存显式选择。

`Gf` 会先收集启用包的 `installer_paths`，再追加 `gf/project/installers` 中的项目级 Installer。这样官方包或社区包可以提供自己的装配入口，而项目仍然可以在后面继续注册业务模块或覆盖绑定。

官方包中，只有需要参与 `GFArchitecture` 生命周期的服务会进入 `package.gd`。例如 `save` 注册 `GFSaveGraphUtility`，`combat` 注册 `GFSkillTargetingUtility` 和 `GFCombatSystem`，`domain` 注册 `GFLevelUtility` 和 `GFQuestUtility`；纯数据模型、Resource、动作对象和节点桥接不会被包安装器自动注册，仍由项目或局部上下文按使用场景装配。

这条规则保持两个边界：

- 包是代码分发单位。
- `GFInstaller` 是运行时装配单位。

## 编辑器包管理器

启用 GF 编辑器插件后，底部面板会出现 `GF Packages`。它用于查看所有官方包和社区包的 manifest 信息、启用/禁用包、查看发行版本与包版本、依赖、标签、Installer 路径、编辑器扩展路径和校验状态。

面板中的“有效/无效”表示 manifest 是否通过基础校验；“保存设置”会把当前勾选状态和包相关开关写入 ProjectSettings。分类下拉框和搜索框只影响当前列表显示，不会自动修改启用状态。

包管理器保存的是 GF 自己的包启用状态，不是 Godot 原生插件开关。Godot 仍会在编辑器中看到项目里存在的脚本和 `class_name`；真正影响运行时的是启用包的 Installer 是否自动执行，真正影响导出包体的是导出插件是否跳过禁用包目录。

GF 自带的包相关编辑器增强会读取同一套启用状态。包可以用 `editor_action_paths` 声明 GF 工具菜单动作和脚本模板记录，用 `editor_dock_paths` 声明底部面板，用 `editor_inspector_paths` 声明 `EditorInspectorPlugin`，用 `export_plugin_paths` 声明导出插件入口，用 `access_generator_extension_paths` 声明访问器生成扩展。核心插件只负责按 manifest 装载启用包的扩展，不在 `kernel` 中硬编码可选官方包脚本、包 ID 或包内模板类型。菜单动作脚本可以实现 `get_menu_entries()` / `handle_menu_action(action_id)` 贡献普通工具，也可以实现 `get_template_records()` 贡献脚本模板。访问器扩展可以实现 `append_access_records(records)` 贡献类型记录，也可以实现 `append_access_source(builder, records)` 或 `get_access_source_sections(records)` 追加生成源码。Capability Inspector、Capability 模板、Flow Graph Inspector、SaveGraph 诊断菜单和强类型访问器生成器只在对应包启用且脚本存在时启用相关能力；禁用包后，访问器生成器也不会再把该包的工具路径写入新生成脚本。这样可以降低“包已禁用但生成物仍引用包路径”的导出风险。

标准库自带的编辑器增强不走包 manifest，而是集中声明在 `addons/gf/standard/editor/gf_standard_editor_extensions.gd`。根插件 `addons/gf/plugin.gd` 作为组合入口读取这份声明，再把记录传给 `kernel/editor` 辅助脚本装载；BuildInfo 导出插件、节点状态机 Inspector、Pattern2D Inspector、Save Viewer 和标准库脚本模板的实际声明继续由 `standard` 拥有，`kernel` 本身不硬编码标准库脚本路径或标准库类型名。

面板提供“扫描引用”，底层由 `GFPackageUsageAudit` 检查当前禁用包是否仍被项目文件直接引用。保存设置和导出开始时也会执行同类检查；如果发现项目脚本、场景或资源里仍出现禁用包根目录路径，或直接使用了禁用包导出的 `class_name`，会输出警告并列出文件位置。需要在 CI 或正式导出中更严格处理时，可在面板中启用“引用禁用包时阻止导出”，或直接设置 `gf/packages/export_fail_on_disabled_references`，让导出审计以错误形式报告。

导出排除有一个重要前提：项目不应直接引用禁用包里的脚本、场景或资源。如果某个场景、preload 或导出资源仍然依赖禁用包，排除该包会让导出产物缺文件。包管理器负责表达意图和执行排除，项目层仍需要保证依赖关系一致。

如果项目完全不使用某个官方包，也可以删除该包目录。`kernel` 与 `standard` 不会硬 preload 官方包脚本，也不会直接类型引用官方包；编辑器工具遇到缺失的可选包会动态跳过对应增强功能。删除目录前仍要确认项目代码、场景、资源和生成脚本没有直接引用被删除包。

包可以向标准库的通用扩展点贡献能力，但依赖方向必须从包指向标准库。例如 ActionQueue 包可以在运行时向 `GFDiagnosticsUtility` 注册自己的工具快照和监控项，Network 包可以注册 `network` 诊断分区；`GFDiagnosticsUtility` 本身不写死这些包的 ID、路径或类名。这样包禁用或删除时，贡献自然消失，标准库仍保持完整可运行。

## 官方包与社区包

官方包随 GF 发布，是因为 Godot Asset Library 不提供 npm 风格的依赖自动安装。官方包可以直接依赖 `gf.kernel` 和 `gf.standard`，但仍必须保持抽象、通用、可选，不写具体项目业务逻辑。

社区包可以放在 `addons/gf/packages/community`，也可以作为独立 Godot 插件发布。GF 只定义规范，不强制社区包一定进入 GF 仓库。社区包如果依赖 GF，应在自己的 manifest 或 README 中声明需要的 GF 版本。

## 放置规则

- 框架启动、生命周期、注册、事件、绑定、插件入口：放 `kernel`。
- 需要 `kernel` 直接识别的协议、基类、类型关系工具和诊断结构：放 `kernel`。
- 纯算法、纯数据、通用输入、通用运行时服务、状态机等稳定标准能力：放 `standard`。
- 战斗、网络、存档、流程图、能力、交互、行为树、领域模型等可选能力：放 `packages/official`。
- SDK、地形生成器、画笔、项目适配、业务偏强工具：放 `packages/community` 或外部插件。

当一个新能力难以归类时，先问它是否必须被 `kernel` 直接引用。如果是，抽出最小内核契约放入 `kernel`，具体实现仍可在 `standard` 或包中。若不是，再问它是否足够基础到所有项目都应默认理解；如果不是，不进 `standard`，最后再决定它是官方通用包还是社区/项目包。
