# 编辑器维护约束

本页收拢 GF 编辑器层的维护规则。面向使用者的编辑器说明在 `docs/zh/editor/`。

## 入口归属

- 新增编辑器入口时，先判断它属于 `kernel`、`standard` 还是某个扩展。
- 只服务某个可选扩展的 Inspector、菜单动作、工作区页面或访问器扩展，应放进该扩展的 `editor` 目录并写入 manifest。
- 标准库通用编辑器增强和标准库模板应登记到 `gf_standard_editor_extensions.gd`，由根插件传给内核辅助脚本；不要在 `addons/gf/kernel/**` 里直接 preload 标准库增强或硬编码标准库类型名。
- 可选扩展模板应由扩展自己的 `editor_action_paths` 贡献 `get_template_records()`，不要把扩展 ID、扩展类型名或模板基类写进 `kernel/editor`。

## 工作区页面

- 工作区页面应优先复用 `GFEditorWorkspaceUI` 的通用控件。
- 页面脚本只保留资源加载、校验、连接、保存等抽象编辑行为。
- 可选扩展被禁用或删除时，核心插件和标准库页面仍应可加载。

## 生成物与测试

- 改动公开生成物或模板时，应同步更新正式文档、changelog 和聚焦测试。
- 改动 `.gd` 后至少运行 `tests/gf_core/maintenance`。
- 提交前按维护指南跑完整 `tests/gf_core`。
