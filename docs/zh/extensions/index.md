# 官方扩展总览与扩展规范

本页解释 GF 官方扩展与社区扩展的定位、manifest、启用状态、Installer、编辑器扩展和导出排除规则。

GF Framework 采用三层稳定结构：

- `addons/gf/kernel`：运行内核，只放框架能否启动、注册、注入、派发和编辑器集成所必需的代码。
- `addons/gf/standard`：标准库，放足够通用、稳定、默认随框架理解的基础能力，例如 `foundation`、输入体系、通用运行时工具、状态机、命令、序列和消息支撑。
- `addons/gf/extensions`：扩展生态入口，放官方原子扩展和社区/项目扩展。

`foundation` 位于 `standard/foundation`，保持纯算法、纯数据和纯适配职责，不参与 `GFArchitecture` 生命周期注册。

依赖方向必须保持单向：`kernel` 不直接依赖 `standard` 或任何可选扩展；`standard` 可以依赖 `kernel`；官方扩展和社区扩展可以依赖 `kernel`，也可以按需依赖稳定的 `standard` 能力。凡是 `kernel` 必须直接识别的概念，都应收敛为 `kernel` 中的契约或基础设施，再由 `standard` 或扩展提供具体实现。

这条边界不仅是目录约定，也是加载约定：`kernel` 和 `standard` 都不能硬 preload 官方扩展脚本、写死 `res://addons/gf/extensions/official/**` 资源路径、硬编码 `gf.official.*` 扩展 ID，或直接使用官方扩展里的具体 `class_name`。`standard` 不保留任何官方扩展弱联动白名单；如果某个扩展希望出现在诊断、Overlay、工具快照或其他标准库通道里，应由扩展侧依赖 `standard` 的通用注册入口主动贡献能力，而不是让 `standard` 主动探测扩展。

官方扩展是 GF 维护的原子能力，彼此不互相依赖、不软协作、不探测对方存在，也不通过路径、扩展 ID、`class_name` 或动态加载引用其他官方扩展。官方扩展 manifest 的 `dependencies` 只允许声明 `gf.kernel` 与 `gf.standard`，官方扩展不使用 `optional_dependencies`。跨官方扩展组合属于项目 Installer、社区扩展或外部插件；GF 官方层只提供最小抽象和可独立启用的能力单元。

## 扩展根目录

```text
addons/gf/
  kernel/
  standard/
  extensions/
    official/
    community/
```

`extensions` 是统一扩展根目录，但 `official` 与 `community` 不是同一种治理层级。`official` 是 GF 随框架发布的原子能力集合；`community` 是项目、本地团队或第三方按 GF 扩展规范自由组合、适配和发布扩展的空间。

## 扩展内结构

扩展内部不机械复制整个 GF 目录，但官方扩展需要遵循一个硬边界：扩展根目录只放扩展元数据、可选装配入口和说明文档，业务代码进入稳定槽位。这样从文件树上就能看出“这是扩展入口”还是“这是运行时代码”。

```text
addons/gf/extensions/official/example/
  gf_extension.json
  extension.gd              # 可选，继承 GFInstaller
  README.md               # 可选，扩展内说明
  foundation/             # 可选：扩展内纯算法、值对象、codec
  runtime/                # 可选：Model/System/Utility 等运行时模块
  resources/              # 可选：配置、定义、Resource 数据
  nodes/                  # 可选：场景节点、Controller、桥接节点
  editor/                 # 可选：Inspector、生成器、导入器
  actions/                # 可选：动作/步骤/命令式表现单元
  tests/                  # 可选：扩展内测试
  examples/               # 可选：示例场景或资源
```

如果扩展已经像 `combat`、`network`、`save` 这类大型官方扩展一样有更清楚的内部领域，也可以继续使用领域子目录，例如 `hit_detection`、`serialization`、`serializers`。原则是目录名表达稳定职责，而不是表达临时实现细节。小扩展则优先使用 `runtime`、`resources`、`nodes`、`editor` 这些通用槽位，避免每个扩展都发明一套命名。

## Manifest

每个扩展应提供 `gf_extension.json`：

```json
{
  "id": "gf.official.combat",
  "display_name": "GF Combat",
  "version": "3.2.0",
  "extension_version": "1.3.0",
  "kind": "official",
  "description": "Abstract combat attributes, modifiers, buffs, skills, gauges, and hit detection bridges.",
  "dependencies": ["gf.kernel", "gf.standard"],
  "installer_paths": [
    "res://addons/gf/extensions/official/combat/extension.gd"
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

`version` 表示 manifest 的发行版本。官方扩展的 `version` 必须始终等于当前 GF 发行版本，例如 GF 3.2.0 发布时所有 `addons/gf/extensions/official/*/gf_extension.json` 都应写入 `"version": "3.2.0"`；社区扩展没有随 GF 发行的约束，可以用自己的发行版本。

`extension_version` 表示扩展自身版本。官方扩展必须显式填写该字段，并按扩展内公开行为独立递增：兼容 bug 修复递增 patch，向后兼容的新公开 API、配置或功能递增 minor，破坏兼容才递增 major。没有发生扩展内行为变化的官方扩展，在 GF 发行版本递增时只同步 `version`，不递增 `extension_version`。社区扩展可以省略 `extension_version`，省略时工具会回退使用 `version`。

`dependencies` 是硬依赖：启用当前扩展时，`GFExtensionSettings` 会自动补齐这些依赖。官方扩展只允许声明 `gf.kernel` 与 `gf.standard`，并且源码只能引用自身、`kernel` 和稳定的 `standard`。社区扩展、项目扩展或外部插件可以在自己的 manifest 中声明其他扩展依赖；如果它们要组合多个官方扩展，应把组合代码放在自己的扩展内，而不是写回 GF 官方扩展。

`optional_dependencies` 是社区扩展、项目扩展或外部插件的软协作提示：它不会自动启用扩展，不参与依赖闭包，也不允许硬引用对方源码；它只用于扩展管理器、诊断和文档说明“如果项目同时启用这些扩展，可以通过扩展点获得增强”。官方扩展不使用 `optional_dependencies`，因为官方层不承载跨扩展组合关系。

`enabled_by_default`、`installer_paths`、`editor_action_paths`、`editor_dock_paths`、`editor_inspector_paths`、`export_plugin_paths` 与 `access_generator_extension_paths` 可省略。省略时，`official` 与 `standard` 扩展默认启用，`community` 扩展默认不启用；没有安装器或编辑器扩展的扩展可以把对应数组留空。manifest 声明的扩展脚本路径必须位于扩展根目录内，避免扩展通过 manifest 越界绑定其他扩展或项目脚本。

`access_generator_extension_paths` 会被 `GFAccessGenerator` 消费。扩展脚本建议继承 `RefCounted`，并实现 `append_access_source(builder, records)` 直接使用 `GFSourceBuilder` 追加源码；如果只需要返回静态片段，也可以实现 `get_access_source_sections(records)` 并返回字符串数组。扩展只会从当前启用扩展中读取，因此禁用扩展不会继续影响新生成的访问器。

`GFExtensionManifest` 负责读取和校验 manifest，`GFExtensionCatalog` 负责扫描 `extensions/official` 与 `extensions/community` 下的一层扩展目录，`GFExtensionSettings` 负责读取项目启用状态、查询扩展是否存在或启用、补齐依赖闭包、收集启用扩展的 Installer 路径和编辑器扩展路径，并提供按扩展 ID 解析扩展内资源或加载启用扩展脚本的统一入口。这个设计在 Godot 中保持为轻量文件约定，不引入依赖安装器。

`GFExtensionSettings` 会缓存一次 manifest 扫描结果，避免编辑器 Inspector、扩展面板和扩展查询在同一会话里反复读盘；扩展目录发生变化时可调用 `clear_manifest_cache()` 刷新。依赖补齐会检测循环依赖并停止递归，`get_manifest_graph_report()` 可一次性报告重复扩展 ID、缺失硬依赖、社区/项目扩展缺失可选依赖提示、无效 manifest 与依赖环。`gf.kernel` 和 `gf.standard` 是允许声明的内置依赖 ID，它们不是可启停扩展目录。

官方扩展固定只声明 `gf.kernel` 与 `gf.standard`。即使两个官方扩展经常一起使用，GF 官方扩展也不记录“推荐组合”或“增强组合”；这些组合关系放在项目 Installer、社区扩展、外部插件、文档示例或用户自己的架构装配中表达。

## 安装与装配

扩展代码存在并不代表会自动注册运行时模块。需要参与 `GFArchitecture` 的扩展，应提供一个继承 `GFInstaller` 的 `extension.gd` 或安装器脚本，并在 manifest 的 `installer_paths` 中声明。

插件启用后，GF 会注册这些项目设置：

- `gf/extensions/enabled`：启用的扩展 ID 列表。
- `gf/extensions/auto_install_enabled_installers`：是否在 `Gf.init()` / `Gf.set_architecture()` 时自动执行启用扩展的 `installer_paths`。
- `gf/extensions/export_exclude_disabled`：导出时是否跳过禁用扩展目录。
- `gf/extensions/export_fail_on_disabled_references`：导出审计发现项目仍引用禁用扩展时，是否把结果报告为错误；默认开启，避免导出产物缺失仍被引用的扩展文件。

新项目会把官方扩展的默认启用列表写入 `gf/extensions/enabled`。如果希望项目只启用其中一部分，可以通过 `GF Extensions` 面板或 `GFExtensionSettings.set_enabled_extension_ids()` 保存显式选择。

`Gf` 会先收集启用扩展的 `installer_paths`，再追加 `gf/project/installers` 中的项目级 Installer。这样官方扩展或社区扩展可以提供自己的装配入口，而项目仍然可以在后面继续注册业务模块或覆盖绑定。

官方扩展中，只有需要参与 `GFArchitecture` 生命周期的服务会进入 `extension.gd`。例如 `save` 注册 `GFSaveGraphUtility`，`combat` 注册 `GFSkillTargetingUtility` 和 `GFCombatSystem`，`domain` 注册 `GFLevelUtility` 和 `GFQuestUtility`；纯数据模型、Resource、动作对象和节点桥接不会被扩展安装器自动注册，仍由项目或局部上下文按使用场景装配。

项目 Installer 通常只注册项目自己的 `GFModel`、`GFSystem` 和 `GFUtility`。如果某个官方扩展已启用，不需要再手动注册它的扩展级服务；重复注册会被忽略并提示使用 `replace_*()`。确实需要替换默认实现时，应显式调用 `replace_utility()` 或 `replace_system()`，让覆盖意图和所有权边界清楚可见。

这条规则保持两个边界：

- 扩展是代码分发单位。
- `GFInstaller` 是运行时装配单位。

## 编辑器扩展管理器

启用 GF 编辑器插件后，底部面板会出现 `GF Extensions`。它用于查看所有官方扩展和社区扩展的 manifest 信息、启用/禁用扩展、查看发行版本与扩展版本、依赖、标签、Installer 路径、编辑器扩展路径和校验状态。

面板中的“有效/无效”表示 manifest 是否通过基础校验；“保存设置”会把当前勾选状态和扩展相关开关写入 ProjectSettings。分类下拉框和搜索框只影响当前列表显示，不会自动修改启用状态。

扩展管理器保存的是 GF 自己的扩展启用状态，不是 Godot 原生插件开关。Godot 仍会在编辑器中看到项目里存在的脚本和 `class_name`；真正影响运行时的是启用扩展的 Installer 是否自动执行，真正影响导出内容的是导出插件是否跳过禁用扩展目录。

GF 自带的扩展相关编辑器增强会读取同一套启用状态。扩展可以用 `editor_action_paths` 声明 GF 工具菜单动作和脚本模板记录，用 `editor_dock_paths` 声明底部面板，用 `editor_inspector_paths` 声明 `EditorInspectorPlugin`，用 `export_plugin_paths` 声明导出插件入口，用 `access_generator_extension_paths` 声明访问器生成扩展。核心插件只负责按 manifest 装载启用扩展的贡献，不在 `kernel` 中硬编码可选官方扩展脚本、扩展 ID 或扩展内模板类型。菜单动作脚本可以实现 `get_menu_entries()` / `handle_menu_action(action_id)` 贡献普通工具，也可以实现 `get_template_records()` 贡献脚本模板。访问器扩展可以实现 `append_access_records(records)` 贡献类型记录，也可以实现 `append_access_source(builder, records)` 或 `get_access_source_sections(records)` 追加生成源码。Capability Inspector、Capability 模板、Flow Graph Inspector、SaveGraph 诊断菜单和强类型访问器生成器只在对应扩展启用且脚本存在时启用相关能力；禁用扩展后，访问器生成器也不会再把该扩展的工具路径写入新生成脚本。这样可以降低“扩展已禁用但生成物仍引用扩展路径”的导出风险。

标准库自带的编辑器增强不走扩展 manifest，而是集中声明在 `addons/gf/standard/editor/gf_standard_editor_extensions.gd`。根插件 `addons/gf/plugin.gd` 作为组合入口读取这份声明，再把记录传给 `kernel/editor` 辅助脚本装载；BuildInfo 导出插件、节点状态机 Inspector、Pattern2D Inspector、Save Viewer 和标准库脚本模板的实际声明继续由 `standard` 拥有，`kernel` 本身不硬编码标准库脚本路径或标准库类型名。

面板提供“扫描引用”，底层由 `GFExtensionUsageAudit` 检查当前禁用扩展是否仍被项目文件直接引用。保存设置和导出开始时也会执行同类检查；如果发现项目脚本、场景或资源里仍出现禁用扩展根目录路径，或直接使用了禁用扩展导出的 `class_name`，会输出警告并列出文件位置。发布前应保持“引用禁用扩展时阻止导出”开启；只有在本地调试引用清理流程时，才临时关闭 `gf/extensions/export_fail_on_disabled_references`。

导出排除有一个重要前提：项目不应直接引用禁用扩展里的脚本、场景或资源。如果某个场景、preload 或导出资源仍然依赖禁用扩展，排除该扩展会让导出产物缺文件。扩展管理器负责表达意图和执行排除，项目层仍需要保证依赖关系一致。

如果项目完全不使用某个官方扩展，也可以删除该扩展目录。`kernel` 与 `standard` 不会硬 preload 官方扩展脚本，也不会直接类型引用官方扩展；编辑器工具遇到缺失的可选扩展会动态跳过对应增强功能。删除目录前仍要确认项目代码、场景、资源和生成脚本没有直接引用被删除扩展。

扩展可以向标准库的通用扩展点贡献能力，但依赖方向必须从扩展指向标准库。例如 ActionQueue 扩展可以在运行时向 `GFDiagnosticsUtility` 注册自己的工具快照和监控项，Network 扩展可以注册 `network` 诊断分区；`GFDiagnosticsUtility` 本身不写死这些扩展的 ID、路径或类名。这样扩展禁用或删除时，贡献自然消失，标准库仍保持完整可运行。

## 官方扩展与社区扩展

官方扩展随 GF 发布，是因为 Godot Asset Library 不提供 npm 风格的依赖自动安装。官方扩展只能依赖 `gf.kernel` 和 `gf.standard`，并且必须保持抽象、通用、原子化、可选，不写具体项目业务逻辑，也不写跨官方扩展组合逻辑。

社区扩展可以放在 `addons/gf/extensions/community`，也可以作为独立 Godot 插件发布。GF 只定义规范，不强制社区扩展一定进入 GF 仓库。社区扩展如果依赖 GF，应在自己的 manifest 或 README 中声明需要的 GF 版本；如果社区扩展要组合多个官方扩展，可以用自己的 `dependencies`、`optional_dependencies`、Installer 和扩展点表达清楚。

## 放置规则

- 框架启动、生命周期、注册、事件、绑定、插件入口：放 `kernel`。
- 需要 `kernel` 直接识别的协议、基类、类型关系工具和诊断结构：放 `kernel`。
- 纯算法、纯数据、通用输入、通用运行时服务、状态机等稳定标准能力：放 `standard`。
- 战斗、网络、存档、流程图、能力、交互、行为树、领域模型等可选能力：放 `extensions/official`。
- SDK、地形生成器、画笔、官方扩展组合、项目适配、业务偏强工具：放 `extensions/community` 或外部插件。

当一个新能力难以归类时，先问它是否必须被 `kernel` 直接引用。如果是，抽出最小内核契约放入 `kernel`，具体实现仍可在 `standard` 或扩展中。若不是，再问它是否足够基础到所有项目都应默认理解；如果不是，不进 `standard`，最后再决定它是官方通用扩展还是社区/项目扩展。
