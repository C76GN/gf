# Foundation 数值、成长与权重

本页拆出 Standard Foundation 中的数值表达、格式化、成长曲线和权重表能力。它们都是纯数据或纯算法基础件，不参与 `GFArchitecture` 生命周期。

## `GFBigNumber`

适合挂机/放置类游戏的超大数值。它使用尾数 + 指数的形式表达量级，可用于：

- 超出原生 `float` 直观显示范围的资源数量
- 跨数量级比较
- 高阶增长、收益结算、战力显示

```gdscript
var gold := GFBigNumber.from_string("1.25e18")
var bonus := GFBigNumber.from_string("2e17")
var total := gold.add(bonus)
print(total.to_scientific_string()) # 1.45e18
```

`GFBigNumber` 是显示和量级计算用的近似大数。它适合挂机资源、战力、收益预估和跨数量级比较，不适合作为付费货币、强精度经济结算、竞技排行榜最终判定或任何要求逐分逐厘精确的权威数据源。


## `GFFixedDecimal`

适合货币、税率、百分比、经营数值这类对累计误差更敏感的场景。它内部用整数缩放保存值。

```gdscript
var price := GFFixedDecimal.from_string("12.34", 2)
var tax := GFFixedDecimal.from_string("0.08", 2)
var total := price.multiply(tax, 2).add(price)
print(total.to_decimal_string()) # 13.33
```

普通十进制字符串会走整数缩放解析；科学计数法字符串会先退回 float 路径再构建定点数，可能存在浮点舍入。需要严格十进制导入时，建议用普通十进制字符串，或在项目导表阶段把科学计数法预处理成固定小数文本。


## `GFNumberFormatter`

统一的数字显示格式化工具，支持：

- `FULL`：普通十进制
- `COMPACT_SHORT`：紧凑缩写，如 `12.3k`
- `SCIENTIFIC`：科学计数法，如 `1.23e8`
- `ENGINEERING`：工程计数法
- `AUTO`：自动模式

```gdscript
var coins := GFBigNumber.from_string("12345000")
print(GFNumberFormatter.format_compact(coins, 2)) # 12.35M
print(GFNumberFormatter.format_scientific(coins, 2)) # 1.23e7
```


## `GFDecimalStringFormatter`

小数字符串格式化与校验辅助，主要用于框架内部的 `GFNumberFormatter`、`GFBigNumber` 和 `GFFixedDecimal` 共享同一套舍入、截断、尾零裁剪和纯数字校验规则。项目层如果也需要这些纯文本规则，可以直接静态调用；它不负责本地化、货币符号或业务单位选择。

```gdscript
var rounded := GFDecimalStringFormatter.format_decimal_value(12.345, 2, false, false)
var truncated := GFDecimalStringFormatter.format_decimal_value(12.345, 2, false, true)
var valid := GFDecimalStringFormatter.is_valid_decimal_parts("12", "34", true)
```


## `GFProgressionMath`

用于承载挂机/模拟经营项目最常见的纯数值原语：

- 价格曲线、收益曲线
- 分段曲线与特定等级 override
- 里程碑倍率
- 软上限
- 分段式离线收益结算

它刻意只解决“怎么算”，不解决“由谁驱动建筑、生产线、仓库和资源流转状态机”。  
所以它非常适合与 `GFConfigProvider`、JSON、CSV、Luban 等导表结果配合使用，但不直接承担具体玩法系统职责。

```gdscript
var cost_curve := {
	"base_value": 10,
	"phases": [
		{ "start_level": 0, "mode": "exponential", "multiplier": 1.15 },
		{ "start_level": 50, "mode": "linear", "per_level": 5000 },
	],
	"overrides": {
		10: 500,
		25: 10000,
	},
}

var level_cost := GFProgressionMath.evaluate_curve(25, cost_curve)
print(level_cost.to_plain_string(0)) # 10000
```

离线收益也可以按“先分段，再结算”的思路描述：

```gdscript
var offline_result := GFProgressionMath.settle_offline_progress(
	10,
	3600.0,
	{
		"segments": [
			{ "duration_seconds": 600.0, "multiplier": 2.0 },
		],
		"storage_remaining": 50000,
	}
)

print(offline_result["produced"].to_plain_string(0))
```


## `GFWeightedEntry` / `GFWeightedTable`

`GFWeightedTable` 是通用权重选择原语。它只管理候选值、权重、随机源和可选元数据，不解释这些值是奖励、AI 决策、音效变体还是关卡片段。需要可复现结果时，传入 `RandomNumberGenerator` 或设置表上的 `deterministic_seed`。

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

资源化条目适合编辑器配置或导表后转换；字典序列化方法只保留通用字段，项目层可以自由决定 `value` 与 `metadata` 的结构。复杂业务校验仍应放在项目自己的配置管线中，而不是塞进权重表。

