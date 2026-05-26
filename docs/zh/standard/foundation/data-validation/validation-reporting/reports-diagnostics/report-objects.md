# 报告对象

通用校验基础件用于统一表达“某个数据、资源或节点结构有什么问题”。推荐把 `kind` 设计成稳定、抽象的 snake_case 标识，把具体修复策略放在调用方传入的 `next_actions` 映射中。这样框架层只负责报告结构和统计，不把项目业务规则写死进基础件。

```gdscript
var report := GFValidationReport.new("Item table")
report.add_warning(&"missing_optional", "Optional field is missing.", "row_1")
report.add_error(&"invalid_value", "Value is invalid.", "row_2")

var data := report.to_dict({}, {
	"next_actions": {
		"invalid_value": "Fix the invalid value before importing.",
	},
})

print(data["ok"])
print(data["summary"])
```

## Source Span

需要把问题定位到源码、配置表、导入文本或资源片段时，可以使用 `GFSourceSpan`。行列约定为 1-based，`0` 表示未知；`source` 字典字段会作为 `source_path` 的兼容别名读取，方便旧字典报告逐步迁移。

```gdscript
var span := GFSourceSpan.make("res://data/items.csv", 8, 4, 3)
var report := GFValidationReport.new("Item table")
report.add_source_error(&"invalid_value", "Value is invalid.", span)

var issue_data := report.to_dict()["issues"][0]
print(issue_data["source_path"])
print(issue_data["line"])
print(issue_data["source_span"]["column"])
```
