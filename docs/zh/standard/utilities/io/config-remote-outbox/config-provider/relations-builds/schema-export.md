# Schema 推导与导出

已有样本数据但暂时没有 schema 时，可以用 `GFConfigTableSchema.infer_from_records()` 从 `Array[Dictionary]` 或 `Dictionary` 表推导字段和值类型，再由项目层人工校正必填、默认值、枚举或业务约束。

```gdscript
var inferred_schema := GFConfigTableSchema.infer_from_records(&"items", rows, {
	"required_if_present_in_all_rows": true,
})

var exported := GFConfigTableImporter.export_csv_table(rows, inferred_schema)
if exported["success"]:
	print(exported["text"])
```

Schema 推导只提供初始结构，不应替代项目的数据契约设计。导出工具只处理通用表结构，字段排序、发布管线和业务环境差异由项目层决定。
