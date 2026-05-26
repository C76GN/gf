# Foundation 标签、黑板与数据契约

这一组文档说明标签查询和黑板 Schema 的基础能力。它们适合描述可组合的数据条件和运行时字典契约，但不维护全局标签命名表，也不把业务规则写入 Foundation 层。

## 阅读入口

- [标签集合与查询](tag-query.md)：`GFTagSet`、`GFTagQuery` 的标签、层数、all/any/none 查询和层级匹配。
- [标签表达式与来源适配](tag-expression-source.md)：`GFTagExpression` 组合查询，以及 `GFTagSourceAdapter` 读取不同对象形态。
- [黑板 Schema](blackboard-schema.md)：`GFBlackboardEntry`、`GFBlackboardSchema` 的字段契约、默认值、转换和校验边界。

## 使用边界

标签工具只处理 `StringName` 标签和通用查询语义，不维护全局标签表，也不规定标签命名语义。黑板 Schema 只校验字典结构，不解释业务字段含义。
