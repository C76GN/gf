# 标签集合与查询

`GFTagSet` 和 `GFTagQuery` 提供 Foundation 级标签查询原语，适合在技能条件、AI 感知、配置校验、编辑器过滤或任意项目对象上复用。

它们只处理 `StringName` 标签、层数、all/any/none 查询和层级匹配，不维护全局标签表，也不规定标签命名语义。

```gdscript
var tags := GFTagSet.new()
tags.add_tag(&"state.burning", 2)
tags.add_tag(&"team.enemy")

var query := GFTagQuery.new()
query.all_tags = [&"state"]
query.any_tags = [&"team.enemy", &"team.ally"]
query.none_tags = [&"state.frozen"]
query.include_child_tags = true

if query.matches(tags):
	# 项目层自行决定匹配后的行为。
	pass
```

层级匹配只使用点号前缀，例如查询 `state` 时可匹配 `state.burning`；是否采用这种命名规范由项目层决定。
