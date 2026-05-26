# 信号桥接

如果项目需要把信号连接保存成资源或配置，而不是在脚本里手写所有 `connect()`，可以使用 `GFSignalBridge`。

桥接由 `GFSignalSourceRef` 描述来源节点和信号名，由 `GFCallableTargetRef` 描述目标节点和方法名，再通过参数索引、常量参数和上下文字典完成通用转发。

```gdscript
var bridge := GFSignalBridge.new()
bridge.source.source_path = get_path_to(button)
bridge.source.signal_name = &"pressed"
bridge.target.target_path = get_path_to(panel_controller)
bridge.target.method_name = &"open_panel"
bridge.constant_args = [&"inventory"]

var binding := bridge.connect_bridge(self, self, signals)
```

桥接资源不解释信号业务含义，也不要求目标方法属于某个具体类。

参数重排只处理“把第几个原始参数传给目标方法”。`append_context` 只追加包含桥接 ID、来源路径、信号名、原始参数和元数据的字典。

是否把这些信号用于 UI、动画、场景逻辑或调试工具，仍由项目自己的目标方法决定。

`get_validation_report(root)` 会返回标准校验报告字典，问题使用 `severity` / `kind` / `message` / `path` 字段，并包含 `error_count`、`issue_count`、`summary` 和 `next_action`。

报告会提前检查来源信号、目标方法、负数或越界的 `argument_indices`，以及桥接后实际传给目标方法的参数数量是否匹配。

项目编辑器面板或 CI 工具可以直接把报告交给 `GFValidationDiagnosticAdapter`，而不需要解析字符串问题列表。
