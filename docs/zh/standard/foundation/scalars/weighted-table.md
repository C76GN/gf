# 权重表

`GFWeightedTable` 是通用权重选择原语。它只管理候选值、权重、随机源和可选元数据，不解释这些值是奖励、AI 决策、音效变体还是关卡片段。

需要可复现结果时，传入 `RandomNumberGenerator` 或设置表上的 `deterministic_seed`。

```gdscript
var table := GFWeightedTable.new()
table.add_entry(&"small", 70.0)
table.add_entry(&"medium", 25.0)
table.add_entry(&"large", 5.0)

var rng := RandomNumberGenerator.new()
rng.seed = 12345
var picked_value := table.pick_value(rng)
var batch := table.pick_many(3, rng, false)
```

资源化条目适合编辑器配置或导表后转换；字典序列化方法只保留通用字段，项目层可以自由决定 `value` 与 `metadata` 的结构。

复杂业务校验仍应放在项目自己的配置管线中，而不是塞进权重表。
