# 预算、集合与时间文本

本组页面说明通用预算账本、值索引、变更批次和时间段文本轨道。它们负责保存、查询和归一化底层数据，不决定资源恢复策略、编辑器交互、字幕样式或项目业务流程。

## 阅读入口

- [预算账本](budget-ledger.md)：`GFBudgetLedger` 的容量、可用量、消费结果和释放。
- [值索引与变更批次](value-index-mutation-batch.md)：`GFValueIndex` 的多字段查询与 `GFMutationBatch` 的提交/回滚。
- [时间段文本轨道](timed-text.md)：`GFTimedTextEntry`、`GFTimedTextTrack` 和 `GFTimedTextImporter`。

## 使用边界

这些类型只维护通用数据结构和轻量解析结果。资源恢复规则、字幕渲染、编辑器工作流、业务事务和项目状态提交策略应由项目层或上层 Utility 负责。
