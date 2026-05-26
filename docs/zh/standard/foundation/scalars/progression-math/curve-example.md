# 曲线示例

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

曲线配置可以来自代码、JSON、CSV 或项目自定义导表产物。GF 只解释通用曲线字段，不规定它代表建筑价格、经验、生产速度还是其他业务数值。
