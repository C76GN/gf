# 预算账本

`GFBudgetLedger` 是通用资源预算账本，用于记录一组抽象资源的容量、可用量、消费结果和释放。它不规定资源含义：可以用于体力、行动点、并发额度、构建预算、编辑器批处理配额或任何项目自定义资源。

```gdscript
var ledger := GFBudgetLedger.new()
ledger.set_capacity(&"energy", 10.0)

var result := ledger.consume(&"energy", 3.0, {
	"source": "dash",
})
if result["ok"]:
	print(ledger.get_available(&"energy"))

ledger.release(&"energy", 1.0)
ledger.reset(&"energy")
```

`consume()` 返回统一结果字典，包含 `ok`、`budget_id`、`amount`、`reason`、`available`、`capacity` 和调用方传入的 `metadata`。预算不足、负数请求和缺失预算都会被拒绝并发出 `budget_rejected`；成功消费会发出 `budget_consumed` 与 `budget_changed`。

GF 只维护账本，不决定何时恢复、如何显示、是否允许透支或哪个玩法系统拥有预算。
