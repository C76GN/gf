# 标签表达式与来源适配

需要表达更复杂的组合条件时，用 `GFTagExpression` 组合多个 `GFTagQuery`。

```gdscript
var burning_enemy := GFTagExpression.from_query(
	GFTagQuery.new().configure([&"team.enemy", &"state.burning"])
)
var boss := GFTagExpression.from_query(
	GFTagQuery.new().configure([&"rank.boss"])
)

var target_rule := GFTagExpression.new().configure_any([burning_enemy, boss])
if target_rule.matches(tags):
	pass
```

`GFTagSourceAdapter` 可读取 `GFTagSet`、`Array`、`PackedStringArray`、`Dictionary`，也可读取实现了 `has_tag()`、`get_tag_count()`、`get_tags()` 的对象。需要把不同来源汇入同一套规则时，先通过 `get_tag_counts()`、`to_tag_set()` 或 `merge_sources()` 规范化，再交给查询或表达式执行匹配。

```gdscript
var merged := GFTagSourceAdapter.merge_sources([
	unit_tags,
	equipment_tags,
	{ "tag_counts": { &"state.burning": 2 } },
])

if rule.matches(merged):
	pass
```

来源适配只负责把对象暴露为可查询标签视图，不规定标签命名、层级设计或匹配后的业务行为。
