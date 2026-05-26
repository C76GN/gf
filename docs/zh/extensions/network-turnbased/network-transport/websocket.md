# WebSocket 后端

需要浏览器、工具链或 WebSocket 网关时，可以换成 WebSocket 后端。它仍然只收发 `PackedByteArray`，上层继续复用 `GFNetworkMessage` / channel / validator。

```gdscript
var client_network := Gf.get_utility(GFNetworkUtility) as GFNetworkUtility
client_network.set_backend(GFWebSocketNetworkBackend.new())
client_network.connect_to_endpoint("wss://example.invalid/session")

# 本地工具或原生端也可启动一个简单 WebSocket host。
var host_network := GFNetworkUtility.new()
host_network.set_backend(GFWebSocketNetworkBackend.new())
host_network.host({
	"port": 19090,
	"bind_address": "127.0.0.1",
})
```

`GFWebSocketNetworkBackend` 使用 `WebSocketPeer`，客户端发送时可把目标 peer 传 `GFWebSocketNetworkBackend.SERVER_PEER_ID` 或 `-1`；服务器模式下 `-1` 表示广播。

它不负责鉴权、心跳、房间、重连恢复或消息压缩，这些仍应由项目后端或更高层协议决定。
