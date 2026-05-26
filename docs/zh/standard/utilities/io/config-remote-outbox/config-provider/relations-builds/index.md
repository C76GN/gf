# 引用、合并与构建 Profile

配置表工具可以表达通用唯一索引、跨表引用、补丁合并、构建 profile、Schema 推导和导出。它们只处理表结构，不解释业务含义。

## 阅读入口

- [索引与跨表引用](indexes-references.md)：唯一索引、跨表引用和引用解析。
- [表合并与构建 Profile](merge-profile.md)：补丁表合并、记录过滤和 schema 过滤。
- [Schema 推导与导出](schema-export.md)：从样本记录推导 schema，并按 schema 导出 CSV。

## 使用边界

这些能力只处理通用索引、引用、合并和 schema 形状。补丁来源、分端构建策略、业务枚举、资源分类和热更发布流程应由项目导表流水线定义。
