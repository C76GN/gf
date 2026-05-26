# 菜单与脚本模板

`工具 > GF` 菜单提供常用脚本模板和生成入口。

## 内置入口

- `System`、`Model`、`Utility`、`Command` 模板用于创建基础架构层脚本。
- Capability 相关模板由 Capability 扩展通过 `editor_action_paths` 注入，只在该扩展启用时可用。
- Node State 与 Node State Machine 模板由标准库编辑器扩展注入，用于标准库节点状态机。
- `生成强类型访问器` 会生成 `GFAccess`。
- `生成项目常量访问器` 会生成 `GFProjectAccess`。

`GFPluginActions` 只持有通用文件对话框、占位符替换和核心模板；标准库或扩展的模板应以记录形式注入，记录至少包含 `type`、`label`、`base_class` 和 `template`。

模板生成出的源码遵循项目代码布局规则。修改模板后应重新生成样本并运行对应维护测试。
