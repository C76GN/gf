# 索引与跨表引用

需要表达唯一键或跨表关系时，可以在 `GFConfigTableSchema.indexes` 中加入 `GFConfigTableIndexDefinition`，在 `references` 中加入 `GFConfigTableReference`。唯一索引会参与单表校验；跨表引用由 `GFConfigReferenceResolver.validate_tables()` 在多表上下文中检查。

`resolve_record_references()` 可把一条记录的引用解析为目标记录副本。GF 只理解字段、复合键和报告结构，不解释外键背后的业务含义。

```gdscript
var unique_index := GFConfigTableIndexDefinition.new()
unique_index.index_id = &"item_variant"
unique_index.field_names = PackedStringArray(["item_id", "variant"])
unique_index.unique = true
item_schema.indexes.append(unique_index)

var reference := GFConfigTableReference.new()
reference.source_fields = PackedStringArray(["item_id"])
reference.target_table_name = &"items"
reference.target_fields = PackedStringArray(["id"])
owner_schema.references.append(reference)

var report := GFConfigReferenceResolver.validate_tables({
	&"items": item_rows,
	&"owners": owner_rows,
}, [item_schema, owner_schema])
```
