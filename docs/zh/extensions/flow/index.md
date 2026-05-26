# Flow 流程图

Flow 扩展提供资源化流程图执行基础。它只负责节点查找、后继推进、Signal 等待、取消、循环保护和编辑器元数据；节点具体做什么、如何分支、是否驱动 UI、剧情、任务或教程，由项目层通过继承 `GFFlowNode` 决定。

## 阅读入口

- [基础执行](basic-execution.md)：定义 `GFFlowNode`、创建 `GFFlowGraph`，并用 `GFFlowRunner` 启动流程。
- [端口、连接与拓扑校验](ports-validation.md)：`GFFlowPort`、连接端点、类型兼容性和通用拓扑诊断。
- [编辑器元数据与视图模型](editor-model.md)：节点显示字段、编辑器目录、报告、GraphEdit 视图模型和 GF 工作区面板。
- [运行时语义](runtime-semantics.md)：后继选择、Signal 等待、取消、条件查询、节点运行态和资源隔离。

## 使用边界

流程图适合做“可配置流程编排”的底座，但 GF 不提供业务节点库。项目可以把命令、交互、UI 动画、等待条件等封装为自己的节点资源。

## 元数据约束

`GFFlowGraph.metadata_schema` 是轻量元数据约束，支持 `required`、`type`、`class_name`、`allow_null` 和 `allowed_values` 这类通用规则。`validate_graph_metadata()` 只校验 `editor_metadata` 的结构，不解释字段业务含义。业务字段含义、版本迁移和项目级错误分级仍应由项目工具负责。

## API Reference

完整类、方法和信号列表见 [Flow API Reference](../../reference/api/extensions-flow.md)。
