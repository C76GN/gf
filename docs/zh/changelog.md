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

## [3.12.0] - 2026-05-18

**版本概述**：加固编辑器结构诊断，避免刷新 SaveGraph、FlowGraph 或生成配置访问器时执行项目脚本方法。

### 🚀 新增特性

- `GFFlowGraphEditorModel` 新增 `build_editor_report()`、`build_editor_catalog()`、`validate_graph_for_editor()` 和 `validate_metadata_for_editor()`，供 Inspector、工作区和项目自定义编辑器复用同一套 property-only 结构报告。

### 🐛 Bug 修复

- `GF Workspace > Save` 页面和 `工具 > GF > 校验当前场景 SaveGraph` 的健康检查改为读取导出属性，避免 Godot 编辑器中的 placeholder 脚本实例在刷新时因调用 `get_scope_key()` 等方法报错。
- `GFSaveGraphUtility.validate_payload_for_scope()` 与 PipelineContext 根 key 创建也改为读取 SaveScope/SaveSource 的导出属性，载荷结构校验不再调用项目保存方法。
- FlowGraph 的 Inspector、工作区图视图模型、编辑器目录、结构描述和结构校验改为读取 FlowNode/FlowPort 导出属性，避免编辑器刷新触发项目自定义节点或端口方法。
- `GFConfigAccessGenerator` 生成表访问器时改为读取 schema 的 `table_name` / `table_key` 属性，不再通过 `get_table_key()` 调用项目 schema 方法。
- AudioBank 与 NodeStateMachine Inspector 的校验提示改为直接读取 `GFValidationIssue` 字段，Capability Inspector 去掉不必要的动态 `has_method()` 分支。
- `GFSaveScope`、`GFSaveSource` 和 `GFSaveIdentity` 基类声明为 `@tool`，让框架内置 Save 节点在编辑器诊断中保持可读。

### 🔌 API 变动说明

- 新增的 Flow 编辑器模型方法都是向后兼容的公开 API；现有 `GFFlowGraph.build_editor_report()`、`get_editor_catalog()` 和 `validate_graph()` 签名不变，但编辑器结构数据现在以导出属性为准。

### 📘 升级指南

- 只使用导出属性配置 SaveGraph 的项目无需改动；如果项目要在编辑器里预览 payload 并执行自定义保存/加载方法，请确保对应自定义脚本本身也适合 `@tool` 环境。
- SaveGraph 文档补充了 `GFSaveGraphUtility -> GFStorageUtility` 的最短保存/读取闭环，并明确 `GFSavePipelineContext` 是流程日志，不是应写盘的游戏 payload。
- FlowGraph 编辑器工具以 `node_id`、`display_name`、端口数组、连接数组等导出属性为准；项目自定义方法仍可服务运行时，但不应作为编辑器结构数据来源。
- 配置访问器生成器现在要求 schema 通过 `table_name` 或 `table_key` 属性暴露表名。

### 📁 核心受影响文件

- Save 节点基类：`addons/gf/extensions/save/core/gf_save_scope.gd`、`addons/gf/extensions/save/core/gf_save_source.gd`、`addons/gf/extensions/save/core/gf_save_identity.gd`。
- SaveGraph 诊断：`addons/gf/extensions/save/graph/gf_save_graph_utility.gd`、`addons/gf/extensions/save/editor/gf_save_graph_dock.gd`。
- FlowGraph 编辑器结构：`addons/gf/extensions/flow/resources/gf_flow_graph.gd`、`addons/gf/extensions/flow/resources/gf_flow_node.gd`、`addons/gf/extensions/flow/resources/gf_flow_port.gd`、`addons/gf/extensions/flow/editor/gf_flow_graph_editor_model.gd`、`addons/gf/extensions/flow/editor/gf_flow_graph_inspector_plugin.gd`。
- 配置访问器生成器：`addons/gf/kernel/editor/gf_config_access_generator.gd`。
- 其他编辑器提示：`addons/gf/standard/utilities/audio/editor/gf_audio_bank_inspector_plugin.gd`、`addons/gf/standard/state_machine/node/editor/gf_node_state_machine_inspector_plugin.gd`、`addons/gf/extensions/capability/editor/gf_capability_inspector_plugin.gd`。
- 测试：`tests/gf_core/extensions/save/test_gf_save_graph_utility.gd`、`tests/gf_core/extensions/save/test_gf_save_graph_dock.gd`、`tests/gf_core/extensions/flow/test_gf_flow_graph.gd`、`tests/gf_core/kernel/editor/test_gf_config_access_generator.gd`。
- 文档：`docs/zh/extensions/save-graph/index.md`、`docs/zh/extensions/flow-domain-physics/index.md`、`docs/zh/standard/utilities/io/config-remote-outbox.md`。
