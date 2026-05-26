# 兼容字典报告

已有模块如果仍返回字典报告，可以先使用 `GFValidationReportDictionary.append_issue()` 和 `GFValidationReportDictionary.finalize_report()` 统一统计字段，而不必立刻迁移成对象式报告。

```gdscript
var legacy_report := {
	"row_count": 2,
	"issues": [],
}

GFValidationReportDictionary.append_source_issue(
	legacy_report,
	"warning",
	&"missing_optional",
	"Optional field is missing.",
	{ "source": "res://data/items.csv", "line": 10 },
	{ "row_key": 1 }
)
GFValidationReportDictionary.finalize_report(legacy_report, "Config table")
```

`finalize_report()` 会把 `issues` 中的字典问题归一化为标准问题字典，并回写 `severity`、`kind`、`message`、定位字段和附加字段。旧的 `code` / `type` 不再作为问题类别别名读取，也不会继续透出；需要稳定问题标识时请显式写入 `kind`。

复杂数据结构如果需要输出质量审计报告，也应优先复用这套格式：用 `extra_fields` 或字典报告的自定义字段携带 `stats`、`quality_score`、`checked_count` 等统计，用 `issues` 表达可定位的问题。这样编辑器、导入器、CI 和项目工具仍能共享 `ok`、`healthy`、`error_count`、`warning_count`、`summary` 与 `next_action`，而不是为每个数据结构重新定义报告字段。
