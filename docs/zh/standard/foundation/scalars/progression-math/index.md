# 成长曲线

`GFProgressionMath` 用于承载挂机、模拟经营项目常见的纯数值原语。它刻意只解决“怎么算”，不解决“由谁驱动建筑、生产线、仓库和资源流转状态机”。

它覆盖价格曲线、收益曲线、分段曲线、特定等级 override、里程碑倍率、软上限和分段式离线收益结算。这些能力只处理数值计算；建筑、生产线、仓库、资源流转和状态机仍由项目层系统负责。

## 阅读入口

- [曲线示例](curve-example.md)：分段曲线、特定等级 override 和 `evaluate_curve()`。
- [离线收益](offline-progress.md)：按分段规则结算离线产出。

## 使用边界

`GFProgressionMath` 适合与 `GFConfigProvider`、JSON、CSV 或外部导表产物配合使用，但不直接承担具体玩法系统职责。
