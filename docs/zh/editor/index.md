# 编辑器工具、访问器与项目常量

本页聚焦 GF 编辑器插件提供的工具入口：AutoLoad 注册、ProjectSettings、脚本模板、扩展管理、菜单、工作区页面、Inspector、导出插件、访问器生成和项目常量生成。

GF 的编辑器层只负责装配和生成，不承载可选扩展的运行时逻辑。核心插件位于 `addons/gf/plugin.gd`，实际职责拆到 `addons/gf/kernel/editor` 下的辅助脚本：

- `GFPluginAutoload`：确保 `Gf -> res://addons/gf/kernel/core/gf.gd` AutoLoad 存在。
- `GFPluginProjectSettings`：注册 GF 项目设置默认值和编辑器属性提示。
- `GFPluginActions`：注册 GF 菜单动作、脚本模板和访问器生成入口。
- `GFPluginMenu`：把声明式菜单项挂到 Godot 编辑器菜单。
- `GFPluginInspectorTools`：装载 Inspector 与导出插件。
- `GFPluginDockTools`：装载 GF 独立工作区窗口。

## ProjectSettings

插件启用后会写入几组设置：

- `gf/project/installers`：项目级 `GFInstaller` 路径数组。
- `gf/project/fail_on_installer_error`：Installer 配置或执行失败时是否中断初始化。
- `gf/project/installer_timeout_seconds`：单个 Installer 的最长等待时间。
- `gf/codegen/access_output_path`：`GFAccess` 生成路径。
- `gf/codegen/project_access_output_path`：`GFProjectAccess` 生成路径。
- `gf/build/export/*`：构建信息导出相关设置。
- `gf/extensions/*`：扩展启用、扩展 Installer 自动装配、禁用扩展导出排除和禁用扩展引用审计策略。

这些设置是项目级配置，不是运行时全局常量。运行时代码需要读取时，应通过对应工具类或 `ProjectSettings.get_setting()` 明确访问。

## GF Workspace

`GF Workspace` 是核心插件固定提供的独立编辑器窗口。它把 GF 自带的扩展管理、输入映射、存档文件查看、场景存档图、信号诊断和诊断快照等面板收束到一个响应式工作区，避免多个 GF 面板挤占 Godot 底部栏，也给 Flow 这类复杂工具保留足够横向空间。标准库和启用扩展贡献的 `editor_dock_paths` 会作为工作区页面加入，而不是各自注册成独立底部标签。窗口右上角的“置顶”开关可让独立工作区保持在其他窗口上方，便于一边操作编辑器或运行窗口一边观察调试页面。

插件启用或编辑器打开项目时，GF 会默认弹出工作区窗口；关闭窗口后，可从 `工具 > GF > 打开 GF 工作区` 再次打开。工作区顶部提供自动换行的短页面入口，完整页面名保留在 tooltip；内置页面默认按“状态、输入、保存、流程、存储、信号、诊断、扩展”的产品顺序展示。标准库页面通过记录里的 `order` 和 `short_label` 声明顺序与短标签，扩展页面通过 manifest 的 `editor_dock_order` 和 `editor_dock_short_label` 声明对应信息，核心插件只按记录排序。内容区仍只显示当前页面，避免多个工具同时挤压。每个页面都会放进无最小高度的裁剪容器，页面内容不会把窗口撑坏。右上角的“关于”按钮会打开 GF Framework 简介，并提供项目地址、正式文档地址、Issues、Releases、维护者联系方式和手动最新版本检测入口。

内置页面共享 `GFEditorWorkspaceUI` 提供的页面根、工具栏、摘要、空状态和详情输出构建方式。新增页面应优先复用这些通用控件，再把真正的业务无关编辑逻辑放在页面自身脚本中，这样工作区的密度、状态颜色、空态文案和只读详情区会保持一致。

### Extensions 页面

`GF Extensions` 页面用于查看 `gf_extension.json`、启用或禁用扩展、检查 manifest 状态、扫描禁用扩展引用并保存扩展相关设置。

面板里的三个开关含义不同：

- `自动装配启用扩展 Installer`：`Gf.init()` / `Gf.set_architecture()` 时执行启用扩展 manifest 声明的 `installer_paths`。
- `导出时排除禁用扩展`：导出阶段跳过禁用扩展根目录下的文件。
- `引用禁用扩展时阻止导出`：导出审计发现项目仍引用禁用扩展时，以错误形式报告，适合发布前或 CI 使用。

扩展启用状态不会让编辑器中的脚本或 `class_name` 立刻消失。它影响的是扩展 Installer 是否自动参与运行时装配，以及导出时是否排除禁用扩展目录。禁用或删除扩展前，应先清理项目脚本、场景、资源、preload 和已生成访问器中的直接引用。

## 菜单与脚本模板

`工具 > GF` 菜单提供常用脚本模板和生成入口：

- `System`、`Model`、`Utility`、`Command` 模板用于创建基础架构层脚本。
- Capability 相关模板由 Capability 扩展通过 `editor_action_paths` 注入，只在该扩展启用时可用。
- Node State 与 Node State Machine 模板由标准库编辑器扩展注入，用于标准库节点状态机。
- `生成强类型访问器` 会生成 `GFAccess`。
- `生成项目常量访问器` 会生成 `GFProjectAccess`。

`GFPluginActions` 只持有通用文件对话框、占位符替换和核心模板；标准库或扩展的模板应以记录形式注入，记录至少包含 `type`、`label`、`base_class` 和 `template`。新增模板或修改模板时，生成源码必须遵循 `CODING_STYLE.md` 的 section 顺序，并同步跑维护测试，避免生成代码一落地就违反布局规则。

## 编辑器命令、动作与工具协议

复杂编辑器工具建议把入口、交互和修改拆开：

- `GFEditorCommand`：封装一次可执行、可撤销的编辑器修改，可直接 `execute()` / `revert()`，也可写入 `EditorUndoRedoManager`。
- `GFEditorActionDefinition`：描述菜单、按钮或快捷键入口，通过 `command_factory` 按上下文创建命令。
- `GFEditorTool`：封装需要持续激活、接收输入和绘制辅助的交互工具。
- `GFEditorToolContext`：在工具、动作和命令之间传递 `EditorPlugin`、UndoRedo、当前场景根节点、选中节点和元数据。
- `GFEditorToolOption` / `GFEditorToolOptionSchema`：声明工具设置项和值规范化规则，供项目自己的工具面板生成 UI 或持久化配置。
- `GFEditorPickOperation`：描述拾取、预览、ready、应用和取消这类分阶段交互。

这些类都位于 `kernel/editor`，只定义协议，不知道标准库或 GF 内置扩展的具体类型。标准库、GF 内置扩展、外部扩展和项目插件都可以复用这套拆分，让 UI 按钮只负责触发动作，真正修改资源或节点的逻辑集中到命令中，并自然接入 Godot UndoRedo。

工具选项 Schema 只描述“有哪些设置、默认值和基础类型”，不创建具体控件；拾取操作只传递通用字典，不假设拾取的是节点、点、资源还是端口：

```gdscript
var radius := GFEditorToolOption.new()
radius.option_id = &"radius"
radius.value_type = GFEditorToolOption.ValueType.INT
radius.default_value = 3
radius.min_value = 1.0
radius.max_value = 16.0

var schema := GFEditorToolOptionSchema.new()
schema.add_option(radius)
tool.set_option_schema(schema)
tool.set_tool_option(&"radius", 8)
```

## 访问器生成

`GFAccessGenerator` 扫描项目中注册到 GF 架构的公开类型，生成类型化访问器，减少项目侧到处手写 `Gf.get_model(...) as ...` 的重复样板。

扩展可以通过 manifest 的 `access_generator_extension_paths` 扩展生成结果。扩展脚本可实现以下约定方法：

- `append_access_records(records)`：向记录列表追加扩展内类型。
- `append_access_source(builder, records)`：直接使用 `GFSourceBuilder` 追加源码。
- `get_access_source_sections(records)`：返回源码片段数组。

访问器扩展只从当前启用扩展读取。禁用扩展后重新生成访问器，可以避免新生成文件继续引用被禁用扩展路径。

## Inspector、工作区页面与导出插件

标准库自带编辑器增强集中声明在 `addons/gf/standard/editor/gf_standard_editor_extensions.gd`，再由根插件 `addons/gf/plugin.gd` 作为组合入口传给 `kernel/editor` 辅助脚本。这些通用页面会进入 `GF Workspace`：

- State Tools 页面，用于扫描当前场景中的节点状态机并展示结构校验报告。
- Input Mapping 页面，用于读取 `GFInputContext` 资源，查看动作、绑定与重绑定冲突诊断。
- Storage Viewer 页面，用于按 `GFStorageCodec` 选项查看本地存档文件内容。
- Signal Diagnostics 页面，用于查看当前编辑场景的信号连接、未连接信号和显式开启后的发射记录。
- Diagnostics 页面，用于采集通用性能、架构、工具监控与可选场景树快照。

Inspector 与导出插件仍按对应类型装载，例如 Node State Machine Inspector、Pattern2D Inspector、AudioBank Inspector 和 BuildInfo 导出插件。

GF 内置扩展或外部扩展的编辑器增强则由各自 manifest 声明：

- `editor_action_paths`：GF 菜单动作，也可贡献脚本模板记录。
- `editor_dock_paths`：GF 工作区页面。
- `editor_inspector_paths`：`EditorInspectorPlugin`。
- `export_plugin_paths`：扩展自己的导出插件。
- `access_generator_extension_paths`：访问器生成扩展。

核心插件只按启用状态装载这些入口，不在 `kernel` 中硬编码标准库或可选扩展脚本。这样可选扩展被禁用或删除时，核心和标准库仍应可加载；标准库增强存在与否也不会改变 `kernel` 的源码依赖边界。

## 通用 Resource 表格控件

`GFResourceTableEditor` 是 `kernel/editor` 下的通用控件，用于把一组 `Resource` 按导出属性显示成表格。它不绑定具体配置类型，适合项目或扩展自己的编辑器面板复用：

```gdscript
var editor := GFResourceTableEditor.new()
editor.load_resources(resources, GFResourceTableEditor.build_export_columns(resources[0]))
editor.set_search_text("weapon")
editor.sort_by_property(&"priority")
editor.duplicate_resource(0)
editor.move_resource(0, 2)
```

控件提供路径扫描、脚本过滤、列推导、单元格提交、搜索过滤、排序、插入、复制、移动、移除和可见行索引查询。`commit_cell_value()` 始终接收原始资源行索引；启用过滤后可用 `get_visible_row_indices()` 做映射，或直接调用 `commit_visible_cell_value()`。自动保存只会在 `auto_save_committed_resources = true` 且资源已有 `resource_path` 时触发；保存失败通过 `resource_save_failed` 交给调用方处理。

## 维护要点

- 新增编辑器入口时，先判断它属于 `kernel`、`standard` 还是某个扩展。
- 只服务某个可选扩展的 Inspector、菜单动作、工作区页面或访问器扩展，应放进该扩展的 `editor` 目录并写入 manifest。
- 标准库通用编辑器增强和标准库模板应登记到 `gf_standard_editor_extensions.gd`，由根插件传给内核辅助脚本；不要在 `addons/gf/kernel/**` 里直接 preload 标准库增强或硬编码标准库类型名。
- 可选扩展模板应由扩展自己的 `editor_action_paths` 贡献 `get_template_records()`，不要把扩展 ID、扩展类型名或模板基类写进 `kernel/editor`。
- 工作区页面应优先复用 `GFEditorWorkspaceUI` 的通用控件，只把资源加载、校验、连接、保存等抽象编辑行为留在页面脚本中。
- 改动公开生成物或模板时，应同步更新正式文档、changelog 和聚焦测试。
- 改动 `.gd` 后至少运行 `tests/gf_core/maintenance`；提交前按维护指南跑完整 `tests/gf_core`。
