# 编辑器工具、访问器与项目常量

本页聚焦 GF 编辑器插件提供的工具入口：AutoLoad 注册、ProjectSettings、脚本模板、包管理、菜单/Dock/Inspector、导出插件、访问器生成和项目常量生成。

GF 的编辑器层只负责装配和生成，不承载可选包的运行时逻辑。核心插件位于 `addons/gf/plugin.gd`，实际职责拆到 `addons/gf/kernel/editor` 下的辅助脚本：

- `GFPluginAutoload`：确保 `Gf -> res://addons/gf/kernel/core/gf.gd` AutoLoad 存在。
- `GFPluginProjectSettings`：注册 GF 项目设置默认值和编辑器属性提示。
- `GFPluginActions`：注册 GF 菜单动作、脚本模板和访问器生成入口。
- `GFPluginMenu`：把声明式菜单项挂到 Godot 编辑器菜单。
- `GFPluginInspectorTools`：装载 Inspector 与导出插件。
- `GFPluginDockTools`：装载底部面板。

## ProjectSettings

插件启用后会写入几组设置：

- `gf/project/installers`：项目级 `GFInstaller` 路径数组。
- `gf/project/fail_on_installer_error`：Installer 配置或执行失败时是否中断初始化。
- `gf/project/installer_timeout_seconds`：单个 Installer 的最长等待时间。
- `gf/codegen/access_output_path`：`GFAccess` 生成路径。
- `gf/codegen/project_access_output_path`：`GFProjectAccess` 生成路径。
- `gf/build/export/*`：构建信息导出相关设置。
- `gf/packages/*`：包启用、包 Installer 自动装配、禁用包导出排除和禁用包引用审计策略。

这些设置是项目级配置，不是运行时全局常量。运行时代码需要读取时，应通过对应工具类或 `ProjectSettings.get_setting()` 明确访问。

## GF Packages 面板

`GF Packages` 是核心插件固定提供的底部面板，用于查看 `gf_package.json`、启用或禁用包、检查 manifest 状态、扫描禁用包引用并保存包相关设置。

面板里的三个开关含义不同：

- `自动装配启用包 Installer`：`Gf.init()` / `Gf.set_architecture()` 时执行启用包 manifest 声明的 `installer_paths`。
- `导出时排除禁用包`：导出阶段跳过禁用包根目录下的文件。
- `引用禁用包时阻止导出`：导出审计发现项目仍引用禁用包时，以错误形式报告，适合发布前或 CI 使用。

包启用状态不会让编辑器中的脚本或 `class_name` 立刻消失。它影响的是包 Installer 是否自动参与运行时装配，以及导出时是否排除禁用包目录。禁用或删除包前，应先清理项目脚本、场景、资源、preload 和已生成访问器中的直接引用。

## 菜单与脚本模板

`工具 > GF` 菜单提供常用脚本模板和生成入口：

- `System`、`Model`、`Utility`、`Command` 模板用于创建基础架构层脚本。
- Capability 相关模板由 Capability 包通过 `editor_action_paths` 注入，只在该包启用时可用。
- Node State 与 Node State Machine 模板由标准库编辑器扩展注入，用于标准库节点状态机。
- `生成强类型访问器` 会生成 `GFAccess`。
- `生成项目常量访问器` 会生成 `GFProjectAccess`。

`GFPluginActions` 只持有通用文件对话框、占位符替换和核心模板；标准库或包的模板应以记录形式注入，记录至少包含 `type`、`label`、`base_class` 和 `template`。新增模板或修改模板时，生成源码必须遵循 `CODING_STYLE.md` 的 section 顺序，并同步跑维护测试，避免生成代码一落地就违反布局规则。

## 访问器生成

`GFAccessGenerator` 扫描项目中注册到 GF 架构的公开类型，生成类型化访问器，减少项目侧到处手写 `Gf.get_model(...) as ...` 的重复样板。

包可以通过 manifest 的 `access_generator_extension_paths` 扩展生成结果。扩展脚本可实现以下约定方法：

- `append_access_records(records)`：向记录列表追加包内类型。
- `append_access_source(builder, records)`：直接使用 `GFSourceBuilder` 追加源码。
- `get_access_source_sections(records)`：返回源码片段数组。

访问器扩展只从当前启用包读取。禁用包后重新生成访问器，可以避免新生成文件继续引用被禁用包路径。

## Inspector、Dock 与导出插件

标准库自带编辑器增强集中声明在 `addons/gf/standard/editor/gf_standard_editor_extensions.gd`，再由根插件 `addons/gf/plugin.gd` 作为组合入口传给 `kernel/editor` 辅助脚本：

- Node State Machine Inspector。
- Pattern2D Inspector。
- Save Viewer Dock。
- BuildInfo 导出插件。

官方包或社区包的编辑器增强则由各自 manifest 声明：

- `editor_action_paths`：GF 菜单动作，也可贡献脚本模板记录。
- `editor_dock_paths`：底部面板。
- `editor_inspector_paths`：`EditorInspectorPlugin`。
- `export_plugin_paths`：包自己的导出插件。
- `access_generator_extension_paths`：访问器生成扩展。

核心插件只按启用状态装载这些入口，不在 `kernel` 中硬编码标准库或可选包脚本。这样可选包被禁用或删除时，核心和标准库仍应可加载；标准库增强存在与否也不会改变 `kernel` 的源码依赖边界。

## 维护要点

- 新增编辑器入口时，先判断它属于 `kernel`、`standard` 还是某个包。
- 只服务某个可选包的 Inspector、菜单动作、Dock 或访问器扩展，应放进该包的 `editor` 目录并写入 manifest。
- 标准库通用编辑器增强和标准库模板应登记到 `gf_standard_editor_extensions.gd`，由根插件传给内核辅助脚本；不要在 `addons/gf/kernel/**` 里直接 preload 标准库增强或硬编码标准库类型名。
- 可选包模板应由包自己的 `editor_action_paths` 贡献 `get_template_records()`，不要把包 ID、包类型名或模板基类写进 `kernel/editor`。
- 改动公开生成物或模板时，应同步更新正式文档、changelog 和聚焦测试。
- 改动 `.gd` 后至少运行 `tests/gf_core/maintenance`；提交前按维护指南跑完整 `tests/gf_core`。
