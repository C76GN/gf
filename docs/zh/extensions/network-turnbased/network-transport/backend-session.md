# 后端与 Session

`GFNetworkUtility` 把消息编码、后端传输和运行时信号分开。框架提供 `GFNetworkMessage`、`GFNetworkSerializer`、`GFNetworkBackend`、`GFNetworkRateLimiter`、`GFNetworkSession`、`GFNetworkChannel`、`GFNetworkMessageValidator`、可选 `GFENetNetworkBackend` 与 `GFWebSocketNetworkBackend`，但不内置具体服务器、房间、平台账号或业务同步规则。

```gdscript
class_name GameNetworkBackend
extends GFNetworkBackend


func send_bytes(peer_id: int, bytes: PackedByteArray, options: Dictionary = {}) -> Error:
	# 交给项目选择的底层传输实现。
	return OK
```

```gdscript
var network := Gf.get_utility(GFNetworkUtility) as GFNetworkUtility
network.set_backend(GFENetNetworkBackend.new())
network.host({ "port": 24567 })

var message := GFNetworkMessage.new(&"player_ready", { "slot": 1 })
network.send_message(-1, message)
```

`GFNetworkSession` 只记录后端连接意图和状态快照。`host()` 会在后端真正返回成功或报告 connected 后再标记 `is_connected`；如果后端启动失败，会关闭本次会话而不会短暂发出 connected 状态。

`options.metadata` 必须是 `Dictionary`，传入其他类型会被忽略并输出 warning，避免把错误配置静默保存到会话快照里。替换或清空 backend 时，`GFNetworkUtility` 会关闭旧后端并清理旧会话，避免把底层连接资源留给已失效的 backend。
