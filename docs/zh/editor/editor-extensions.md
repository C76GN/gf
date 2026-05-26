# Inspector、工作区页面与导出插件

标准库自带编辑器增强集中声明在 `addons/gf/standard/editor/gf_standard_editor_extensions.gd`，再由根插件 `addons/gf/plugin.gd` 作为组合入口传给 `kernel/editor` 辅助脚本。

## 标准库页面

这些通用页面会进入 `GF Workspace`：

- State Tools 页面，用于扫描当前场景中的节点状态机并展示结构校验报告。
- Input Mapping 页面，用于读取 `GFInputContext` 资源，查看动作、绑定与重绑定冲突诊断。
- Storage Viewer 页面，用于按 `GFStorageCodec` 选项查看本地存档文件内容。
- Signal Diagnostics 页面，用于查看当前编辑场景的信号连接、未连接信号和显式开启后的发射记录。
- Diagnostics 页面，用于采集通用性能、架构、工具监控与可选场景树快照。

Inspector 与导出插件仍按对应类型装载，例如 Node State Machine Inspector、Pattern2D Inspector、AudioBank Inspector 和 BuildInfo 导出插件。

## 扩展贡献

GF 内置扩展或外部扩展的编辑器增强由各自 manifest 声明：

- `editor_action_paths`：GF 菜单动作，也可贡献脚本模板记录。
- `editor_dock_paths`：GF 工作区页面。
- `editor_inspector_paths`：`EditorInspectorPlugin`。
- `export_plugin_paths`：扩展自己的导出插件。
- `access_generator_extension_paths`：访问器生成扩展。

核心插件只按启用状态装载这些入口，不在 `kernel` 中硬编码标准库或可选扩展脚本。这样可选扩展被禁用或删除时，核心和标准库仍应可加载；标准库增强存在与否也不会改变 `kernel` 的源码依赖边界。
