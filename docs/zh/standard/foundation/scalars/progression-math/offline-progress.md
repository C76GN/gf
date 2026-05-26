# 离线收益

离线收益可以按“先分段，再结算”的思路描述。

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

离线结算只返回通用计算结果。玩家资源入账、仓库上限、离线时间来源、防作弊和提示 UI 仍由项目系统处理。
