# Network 与 TurnBased

本页聚焦 Network 扩展的传输抽象和 TurnBased 扩展的通用回合流程。
## 网络传输抽象 (`GFNetworkUtility`)

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

`GFNetworkSerializer` 默认使用 Godot Variant 二进制格式；切到 `Format.JSON` 时会保持旧的普通 JSON 行为。如果 JSON 通道需要保留 `Vector2`、`Color`、`NodePath`、PackedArray 等 Godot 类型，可显式启用类型化 JSON codec：

```gdscript
network.serializer.format = GFNetworkSerializer.Format.JSON
network.serializer.use_typed_json_codec = true
```

类型化 codec 由 `GFVariantJsonCodec` 提供，只改变当前 serializer 的 JSON 编码方式；旧项目不启用该开关时，已有 JSON 载荷格式不变。

需要浏览器、工具链或 WebSocket 网关时，可以换成 WebSocket 后端。它仍然只收发 `PackedByteArray`，上层继续复用 `GFNetworkMessage` / channel / validator：

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

`GFWebSocketNetworkBackend` 使用 `WebSocketPeer`，客户端发送时可把目标 peer 传 `GFWebSocketNetworkBackend.SERVER_PEER_ID` 或 `-1`；服务器模式下 `-1` 表示广播。它不负责鉴权、心跳、房间、重连恢复或消息压缩，这些仍应由项目后端或更高层协议决定。

可注册通道描述传输偏好，再按通道发送消息：

```gdscript
var state_channel := GFNetworkChannel.new()
state_channel.channel_id = &"state"
state_channel.transfer_channel = 1
state_channel.reliable = false
network.register_channel(state_channel)

network.send_message_on_channel(-1, GFNetworkMessage.new(&"state_delta", payload), &"state")
```

`send_message_on_channel()` 会把逻辑通道写入消息的 `channel_id` 元信息，接收端会优先按 `channel_id` 匹配通道，再回退到同名 `message_type`。因此消息类型可以继续表达业务语义，例如 `state_delta`，通道则负责包体大小限制和后端发送选项；业务 `payload` 内的 `channel_id` 字段不会参与通道匹配。`GFNetworkRateLimiter` 是独立令牌桶工具，不会被 `GFNetworkUtility` 自动消费；项目需要在自己的 `System.tick(delta)` 中推进 `rate_limiter.tick(delta)` 并在发送前调用 `consume()`。

面向同步、重放或插值的项目可以复用三组轻量原语：`GFFixedTickClock` 负责把真实时间转换为固定 tick 步数，`GFNetworkSnapshot` 保存某个 tick 的状态字典并能生成浅层 delta，`GFNetworkHistoryBuffer` 按 tick 保存有限历史。它们不实现预测、回滚、实体复制、房间状态或服务器权威规则，只提供通用数据结构：

```gdscript
var clock := GFFixedTickClock.new(30.0)
var steps := clock.advance(delta)
for i in range(steps):
	simulate_one_tick(clock.current_tick - steps + i + 1)

var history := GFNetworkHistoryBuffer.new(120)
history.add_state(clock.current_tick, {
	"position": player_position,
	"velocity": player_velocity,
})

var previous := history.get_closest_snapshot(clock.current_tick - 2)
var latest := history.get_latest_snapshot()
var delta_payload := previous.make_delta_to(latest)
```

`GFFixedTickClock` 除了批量 `ticks_advanced`，也会在每个固定步发出 `tick_started` / `tick_finished`，并在单帧预算不足时发出 `tick_budget_exhausted`。这让项目可以把“时钟推进”和“模拟执行”分开：时钟只负责告诉你本帧该处理哪些 tick，具体输入采样、实体更新、状态广播和视觉插值仍由项目自己的系统决定。

`GFNetworkHistoryBuffer` 可用 `get_snapshots_between()` 查询 tick 范围，也可用 `get_surrounding_snapshots()` 找到包围某个 tick 的前后快照，方便项目做插值、对账或回放定位。字段级压缩或类型归一化可以交给 `GFNetworkFieldSerializer` 与 `GFNetworkSnapshotSchema`：前者描述单个字段如何转换，后者把一组字段编码器应用到 `GFNetworkSnapshot.state`。

```gdscript
var position_serializer := GFNetworkFieldSerializer.new()
position_serializer.value_type = GFNetworkFieldSerializer.ValueType.VECTOR2
position_serializer.quantize_decimals = 2

var schema := GFNetworkSnapshotSchema.new()
schema.set_field_serializer(&"position", position_serializer)

var encoded := schema.encode_snapshot(latest)
var decoded := schema.decode_snapshot(encoded)
```

Schema 只改变状态字段的表示形式，不决定哪些字段应该同步、发给谁、是否可靠、如何预测或如何解决冲突。需要权限过滤、差量压缩、实体可见性或安全校验时，应继续放在项目协议层。

`GFNetworkSnapshot.make_message()` 可以把快照打包成 `GFNetworkMessage`，方便复用已有 serializer/channel/backend。浅层 delta 只比较字典第一层字段；嵌套对象、实体集合、压缩、校验、冲突解决和安全过滤应由项目层或更上层同步系统决定。

需要断线重连时，可以让项目后端使用 `GFNetworkReconnectPolicy` 统一退避间隔和尝试次数。它只返回下一次等待多少毫秒，不负责打开 socket、鉴权、频道恢复或 presence 语义：

```gdscript
var reconnect := GFNetworkReconnectPolicy.new()
reconnect.delays_msec = [500, 1000, 2000, 5000]
reconnect.max_attempts = 0

var delay_msec := reconnect.get_next_delay_msec()
if delay_msec >= 0:
	# 项目后端自行安排 timer 后再次 connect。
	pass
```

项目层应在后端中处理连接、鉴权、重连、可靠性、频道和平台差异；GF 层只提供稳定的消息载体、序列化、消息大小/结构校验、会话快照和可替换边界。从 `2.0.0` 起，`GFNetworkMessageValidator.max_packet_size` 默认使用 `GFNetworkMessageValidator.DEFAULT_MAX_PACKET_SIZE`，也就是 `64 KiB`；需要传输更大快照或自定义分片协议时应显式调大，或设为 `0` 关闭全局上限。高频通道仍建议配置更小的 `GFNetworkChannel.max_packet_size`。

---


## 通用回合流程 (`GFTurnFlowSystem`)

`GFTurnFlowSystem` 提供阶段推进、行动入队和优先级解析。它适合承载“先收集行动，再按排序规则解析”的通用流程，但不定义参与者字段、目标规则或行动效果。

```gdscript
class_name ResolvePhase
extends GFTurnPhase


func execute(context: GFTurnContext) -> Variant:
	var flow := Gf.get_system(GFTurnFlowSystem) as GFTurnFlowSystem
	flow.resolve_actions()
	return null
```

```gdscript
var flow := GFTurnFlowSystem.new()
flow.set_phases([
	ResolvePhase.new(),
])

flow.start()
flow.enqueue_action(GFTurnAction.new(actor_a, [target_b], { "value": 10 }, 1, 20.0))
flow.advance_phase()
```

默认排序规则是 `priority` 降序，然后 `sort_value` 降序。需要项目自定义排序时，可向 `resolve_actions(order_resolver)` 传入比较回调。

---
