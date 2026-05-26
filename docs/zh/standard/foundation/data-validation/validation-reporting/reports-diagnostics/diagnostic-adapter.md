# 诊断适配

`GFValidationDiagnosticAdapter` 把 `GFValidationIssue`、`GFValidationReport` 或兼容字典转换为纯诊断字典，不创建 Dock、Inspector 或具体控件。编辑器面板、导入器、CI 输出和项目自定义工具都可以消费同一份数据，再自行决定如何展示。

```gdscript
var diagnostics := GFValidationDiagnosticAdapter.report_to_diagnostics(report, {
	"include_positionless": false,
})
var line_records := GFValidationDiagnosticAdapter.make_line_records(diagnostics)
```

诊断记录会包含 `severity`、`kind`、`message`、`source_path`、`line`、`column`、0-based 的 `line_index` / `column_index`、`display_text`、`tooltip` 和 `source_span`。

这些字段只表达通用定位信息，不规定点击行为、修复命令、表格 schema 或业务校验规则。
