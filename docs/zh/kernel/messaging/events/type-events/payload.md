# 定义 Payload

```gdscript
class_name DamagePayload extends GFPayload

var attacker: Node
var target: Node
var amount: int

# 你还可以实现 to_dict 以支持序列化日志打印
func to_dict() -> Dictionary:
	return {
		"attacker": attacker,
		"amount": amount
	}
```

Payload 应保持稳定和轻量。业务事件需要明确数据协议时，优先定义独立 payload 类型。
