# 表合并与构建 Profile

如果项目需要对基础表应用补丁表，可以使用 `GFConfigTableMergePolicy` 和 `GFConfigTableMergeTools`。默认策略按 `id` 生成记录键，支持插入、更新、删除标记和嵌套 Dictionary 字段合并。

项目可以改用复合 key、Dictionary 外层 key、整条替换或禁用插入/删除。它只处理通用表结构，不决定补丁来自热更、编辑器覆盖、模组还是构建步骤。

```gdscript
var policy := GFConfigTableMergePolicy.new()
policy.key_fields = PackedStringArray(["id"])
policy.update_mode = GFConfigTableMergePolicy.UpdateMode.MERGE_FIELDS

var merged := GFConfigTableMergeTools.merge_tables(base_rows, patch_rows, policy)
if merged["ok"]:
	rows = merged["data"]
```

## 构建 Profile

多目标构建可以用 `GFConfigBuildProfile` 按 metadata 中的 groups/tags 过滤 schema 和记录。GF 不内置任何分端含义，`include_groups`、`exclude_groups`、`include_tags` 和 `exclude_tags` 的命名都由项目自己决定；记录级 metadata 默认读取 `_metadata` 字段，字段、索引和引用则读取各自的 `metadata`。

```gdscript
var profile := GFConfigBuildProfile.new()
profile.include_groups = PackedStringArray(["runtime"])
profile.exclude_tags = PackedStringArray(["internal_only"])

var runtime_schema := profile.filter_schema(schema)
var runtime_rows := profile.filter_records(rows)
```
