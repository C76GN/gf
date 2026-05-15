# GF 扩展总览与扩展规范

本页解释 GF 内置扩展的定位、manifest、启用状态、Installer、编辑器扩展和导出排除规则。项目组合、第三方能力和业务适配应作为项目代码或 `addons/gf` 外的独立 Godot 插件维护。

GF Framework 采用三层稳定结构：

- `addons/gf/kernel`：运行内核，只放框架能否启动、注册、注入、派发和编辑器集成所必需的代码。
- `addons/gf/standard`：标准库，放足够通用、稳定、默认随框架理解的基础能力，例如 `foundation`、输入体系、通用运行时工具、状态机、命令、序列和消息支撑。
- `addons/gf/extensions`：GF 随框架分发的可选原子能力，例如 Capability、Interaction、Camera、Dialogue、Combat、Save、Flow、Network、BehaviorTree、Physics 和 Domain。

依赖方向必须保持单向：`kernel` 不直接依赖 `standard` 或任何可选扩展；`standard` 可以依赖 `kernel`；GF 内置扩展可以依赖 `kernel`，也可以按需依赖稳定的 `standard` 能力。凡是 `kernel` 必须直接识别的概念，都应收敛为 `kernel` 中的契约或基础设施，再由 `standard` 或扩展提供具体实现。

这条边界不仅是目录约定，也是加载约定：`kernel` 和 `standard` 都不能硬 preload GF 内置扩展脚本、写死 `res://addons/gf/extensions/**` 资源路径、硬编码 `gf.*` 扩展 ID，或直接使用 GF 内置扩展里的具体 `class_name`。如果某个扩展希望出现在诊断、Overlay、工具快照或其他标准库通道里，应由扩展侧依赖 `standard` 的通用注册入口主动贡献能力，而不是让 `standard` 主动探测扩展。

GF 内置扩展是 GF 维护的原子能力，彼此不互相依赖、不声明隐式协作关系、不探测对方存在，也不通过路径、扩展 ID、`class_name` 或动态加载引用其他内置扩展。内置扩展 manifest 的 `dependencies` 只允许声明 `gf.kernel` 与 `gf.standard`。跨扩展组合属于项目 Installer 或独立插件；GF 内置扩展层只提供最小抽象和可独立启用的能力单元。

## 扩展根目录

```text
addons/gf/
  kernel/
  standard/
  extensions/
    action_queue/
    behavior_tree/
    capability/
    combat/
    ...
```

`addons/gf/extensions` 是 GF 内置扩展根目录。每个内置扩展直接位于该目录下一层，并以独立子目录维护自己的 manifest、运行时代码、资源和编辑器贡献。外部扩展可以复用 GF 的 manifest 约定，但应作为项目代码或独立 Godot 插件维护在 `addons/gf` 外。

## 扩展内结构

扩展内部不机械复制整个 GF 目录。扩展根目录只放扩展元数据、可选装配入口和说明文档，业务代码进入稳定槽位。这样从文件树上就能看出“这是扩展入口”还是“这是运行时代码”。

```text
addons/gf/extensions/example/
  gf_extension.json
  extension.gd            # 可选，继承 GFInstaller
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

如果扩展已经像 `combat`、`network`、`save` 这类大型内置扩展一样有清晰的内部领域，也可以使用领域子目录，例如 `hit_detection`、`serialization`、`serializers`。原则是目录名表达稳定职责，而不是表达临时实现细节。小扩展则优先使用 `runtime`、`resources`、`nodes`、`editor` 这些通用槽位，保持扩展结构一致。

## Manifest

每个扩展应提供 `gf_extension.json`：

```json
{
  "id": "gf.combat",
  "display_name": "GF Combat",
  "version": "3.5.0",
  "extension_version": "1.5.0",
  "kind": "extension",
  "description": "Abstract combat attributes, modifiers, buffs, skills, gauges, and hit detection bridges.",
  "dependencies": ["gf.kernel", "gf.standard"],
  "installer_paths": [
    "res://addons/gf/extensions/combat/extension.gd"
  ],
  "editor_action_paths": [],
  "editor_dock_paths": [],
  "editor_dock_order": 1000,
  "editor_dock_short_label": "",
  "editor_inspector_paths": [],
  "export_plugin_paths": [],
  "access_generator_extension_paths": [],
  "enabled_by_default": true,
  "tags": ["combat", "attributes", "hit-detection"]
}
```

`version` 表示 manifest 的发行版本。GF 内置扩展的 `version` 必须始终等于当前 GF 发行版本，例如 GF 3.5.0 发布时所有 `addons/gf/extensions/*/gf_extension.json` 都应写入 `"version": "3.5.0"`；外部插件可使用自己的发行版本。

`extension_version` 表示扩展自身版本。GF 内置扩展必须显式填写该字段，并按扩展内公开行为独立递增：兼容 bug 修复递增 patch，向后兼容的新公开 API、配置或功能递增 minor，破坏兼容才递增 major。没有发生扩展内行为变化的内置扩展，在 GF 发行版本递增时只同步 `version`，不递增 `extension_version`。

`kind` 对 GF 内置扩展使用 `extension`；标准库内部 manifest 使用 `standard`。扩展工具只处理这两个稳定类型。

`dependencies` 是硬依赖：启用当前扩展时，`GFExtensionSettings` 会自动补齐这些依赖，并让依赖扩展排在依赖方之前。GF 内置扩展只允许声明 `gf.kernel` 与 `gf.standard`，并且源码只能引用自身、`kernel` 和稳定的 `standard`。外部插件如果要组合多个 GF 内置扩展，应在自己的代码、Installer 或文档中表达组合关系，不写回 GF 内置扩展。

`enabled_by_default`、`installer_paths`、`editor_action_paths`、`editor_dock_paths`、`editor_dock_order`、`editor_dock_short_label`、`editor_inspector_paths`、`export_plugin_paths` 与 `access_generator_extension_paths` 可省略。没有安装器或编辑器扩展的扩展可以把对应数组留空。manifest 声明的扩展脚本路径必须位于扩展根目录内，避免扩展通过 manifest 越界绑定其他扩展或项目脚本；校验时会先规范化路径，所以包含 `..` 后实际逃出根目录的路径也会被拒绝。`editor_dock_order` 只影响 GF 工作区页面排序，数值越小越靠前；`editor_dock_short_label` 只影响顶部页面入口短标签，不改变页面脚本路径或运行时行为。

`GFExtensionManifest` 负责读取和校验 manifest。`GFExtensionCatalog` 负责扫描 `addons/gf/extensions` 下的一层扩展目录。`GFExtensionSettings` 负责读取项目启用状态、查询扩展是否存在或启用、补齐依赖闭包、收集启用扩展的 Installer 路径和编辑器扩展路径，并提供按扩展 ID 解析扩展内资源或加载启用扩展脚本的统一入口。这个设计在 Godot 中保持为轻量文件约定，不引入依赖安装器。

`GFExtensionSettings` 会缓存一次 manifest 扫描结果，避免编辑器 Inspector、扩展面板和扩展查询在同一会话里反复读盘；扩展目录发生变化时可调用 `clear_manifest_cache()` 刷新。依赖补齐会检测循环依赖并停止递归；正常无环时，`resolve_extension_dependencies()`、`get_enabled_manifests()` 和启用扩展路径收集都会保持依赖优先顺序，不依赖 manifest 扫描顺序。`get_manifest_graph_report()` 可一次性报告重复扩展 ID、缺失硬依赖、无效 manifest 与依赖环。`gf.kernel` 和 `gf.standard` 是允许声明的内置依赖 ID，它们不是可启停扩展目录。

## 安装与装配

扩展代码存在并不代表会自动注册运行时模块。需要参与 `GFArchitecture` 的扩展，应提供一个继承 `GFInstaller` 的 `extension.gd` 或安装器脚本，并在 manifest 的 `installer_paths` 中声明。

插件启用后，GF 会注册这些项目设置：

- `gf/extensions/enabled`：启用的扩展 ID 列表。
- `gf/extensions/auto_install_enabled_installers`：是否在 `Gf.init()` / `Gf.set_architecture()` 时自动执行启用扩展的 `installer_paths`。
- `gf/extensions/export_exclude_disabled`：导出时是否跳过禁用扩展目录。
- `gf/extensions/export_fail_on_disabled_references`：导出审计发现项目仍引用禁用扩展时，是否把结果报告为错误；默认开启，避免导出产物缺失仍被引用的扩展文件。

新项目会把 GF 内置扩展的默认启用列表写入 `gf/extensions/enabled`。如果希望项目只启用其中一部分，可以通过 `GF Workspace` 的 `GF Extensions` 页面或 `GFExtensionSettings.set_enabled_extension_ids()` 保存显式选择。扩展 ID 统一使用 manifest 中声明的稳定 ID，GF 内置扩展使用 `gf.*` 命名空间。

启用状态解析只会产生当前可发现的 manifest ID。项目设置中如果残留不存在的扩展 ID，`GFExtensionSettings.get_extension_selection_report()` 会在 `unknown_enabled_ids` 中报告，并且这些 ID 不会进入最终启用集合；通过 `set_enabled_extension_ids()` 或扩展管理器保存设置时，也会只写回当前可发现的扩展 ID。

`Gf` 会先按依赖优先顺序收集启用扩展的 `installer_paths`，再追加 `gf/project/installers` 中的项目级 Installer。这样内置扩展负责装配自己的抽象模块，项目仍然可以在后面继续注册业务模块或覆盖绑定。

GF 内置扩展中，只有需要参与 `GFArchitecture` 生命周期的服务会进入 `extension.gd`。例如 `save` 注册 `GFSaveGraphUtility`，`combat` 注册 `GFSkillTargetingUtility` 和 `GFCombatSystem`，`domain` 注册 `GFLevelUtility` 和 `GFQuestUtility`；纯数据模型、Resource、动作对象和节点桥接不会被扩展安装器自动注册，仍由项目或局部上下文按使用场景装配。

项目 Installer 通常只注册项目自己的 `GFModel`、`GFSystem` 和 `GFUtility`。如果某个内置扩展已启用，不需要再手动注册它的扩展级服务；重复注册会被忽略并提示使用 `replace_*()`。确实需要替换默认实现时，应显式调用 `replace_utility()` 或 `replace_system()`，让覆盖意图和所有权边界清楚可见。

## 编辑器扩展管理器

启用 GF 编辑器插件后，会默认打开独立的 `GF Workspace`，其中 `GF Extensions` 页面用于查看所有 GF 内置扩展的 manifest 信息、启用/禁用扩展、查看发行版本与扩展版本、依赖、标签、Installer 路径、编辑器扩展路径和校验状态。

面板中的“有效/无效”表示 manifest 是否通过基础校验；“保存设置”会把当前勾选状态和扩展相关开关写入 ProjectSettings。搜索框只影响当前列表显示，不会自动修改启用状态。

扩展管理器保存的是 GF 自己的扩展启用状态，不是 Godot 原生插件开关。Godot 仍会在编辑器中看到项目里存在的脚本和 `class_name`；真正影响运行时的是启用扩展的 Installer 是否自动执行，真正影响导出内容的是导出插件是否跳过禁用扩展目录。

GF 自带的扩展相关编辑器增强会读取同一套启用状态。扩展可以用 `editor_action_paths` 声明 GF 工具菜单动作和脚本模板记录，用 `editor_dock_paths` 声明 `GF` 工作区页面，并通过 `editor_dock_order` 与 `editor_dock_short_label` 给页面提供排序和短标签，用 `editor_inspector_paths` 声明 `EditorInspectorPlugin`，用 `export_plugin_paths` 声明导出插件入口，用 `access_generator_extension_paths` 声明访问器生成扩展。核心插件只负责按 manifest 装载启用扩展的贡献，不在 `kernel` 中硬编码可选扩展脚本、扩展 ID 或扩展内模板类型。

`access_generator_extension_paths` 会被 `GFAccessGenerator` 消费。扩展脚本建议继承 `RefCounted`，并实现 `append_access_source(builder, records)` 直接使用 `GFSourceBuilder` 追加源码；如果只需要返回静态片段，也可以实现 `get_access_source_sections(records)` 并返回字符串数组。扩展只会从当前启用扩展中读取，因此禁用扩展不会继续影响新生成的访问器。

面板提供“扫描引用”，底层由 `GFExtensionUsageAudit` 检查当前禁用扩展是否仍被项目文件直接引用。保存设置和导出开始时也会执行同类检查；如果发现项目脚本、场景或资源里仍出现禁用扩展根目录路径，或直接使用了禁用扩展导出的 `class_name`，会输出警告并列出文件位置。发布前应保持“引用禁用扩展时阻止导出”开启；只有在调试引用清理流程时，才关闭 `gf/extensions/export_fail_on_disabled_references`。

导出排除有一个重要前提：项目不应直接引用禁用扩展里的脚本、场景或资源。如果某个场景、preload 或导出资源仍然依赖禁用扩展，排除该扩展会让导出产物缺文件。扩展管理器负责表达意图和执行排除，项目层仍需要保证依赖关系一致。

如果项目完全不使用某个 GF 内置扩展，也可以删除该扩展目录。`kernel` 与 `standard` 不会硬 preload 内置扩展脚本，也不会直接类型引用内置扩展；编辑器工具遇到缺失的可选扩展会动态跳过对应增强功能。删除目录前仍要确认项目代码、场景、资源和生成脚本没有直接引用被删除扩展。

扩展可以向标准库的通用扩展点贡献能力，但依赖方向必须从扩展指向标准库。例如 ActionQueue 扩展可以在运行时向 `GFDiagnosticsUtility` 注册自己的工具快照和监控项，Network 扩展可以注册 `network` 诊断分区；`GFDiagnosticsUtility` 本身不写死这些扩展的 ID、路径或类名。这样扩展禁用或删除时，贡献自然消失，标准库仍保持完整可运行。

## 放置规则

- 框架启动、生命周期、注册、事件、绑定、插件入口：放 `kernel`。
- 需要 `kernel` 直接识别的协议、基类、类型关系工具和诊断结构：放 `kernel`。
- 纯算法、纯数据、通用输入、通用运行时服务、状态机等稳定标准能力：放 `standard`。
- 战斗、网络、存档、流程图、能力、交互、行为树、领域模型等可选但通用的内置能力：放 `addons/gf/extensions/<name>`。
- SDK、地形生成器、画笔、跨扩展组合、项目适配、业务偏强工具：放项目代码或 `addons/gf` 外的独立插件。

当一个新能力难以归类时，先问它是否必须被 `kernel` 直接引用。如果是，抽出最小内核契约放入 `kernel`，具体实现仍可在 `standard` 或扩展中。若不是，再问它是否足够基础到所有项目都应默认理解；如果不是，不进 `standard`，最后再判断它是否足够通用、抽象、可独立启用，适合成为 GF 内置扩展。跨扩展组合和项目语义始终留在项目层或独立插件中。
