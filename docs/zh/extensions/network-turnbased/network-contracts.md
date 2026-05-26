# Network 契约、生成器与重连策略

这一页说明如何用契约资源声明消息类型、payload 字段、生成辅助类，并用重连策略统一退避间隔。契约只约束消息结构，不定义房间、鉴权、服务器权威或玩法语义。

## 消息契约

当项目希望减少手写 `message_type` 和 payload 字段名时，可以用 `GFNetworkContract` 描述一组消息契约。单条消息由 `GFNetworkContractMessage` 声明 `message_type`、默认 `channel_id` 和字段列表；字段由 `GFNetworkContractField` 声明名称、值类型、必填性、默认值和可选类名提示。

```gdscript
var slot := GFNetworkContractField.new()
slot.field_name = &"slot"
slot.value_type = GFNetworkContractField.ValueType.INT

var ready := GFNetworkContractMessage.new()
ready.message_type = &"player_ready"
ready.channel_id = &"lobby"
ready.fields = [slot]

var contract := GFNetworkContract.new()
contract.contract_id = &"lobby"
contract.messages = [ready]

var message := contract.make_message(&"player_ready", { &"slot": 1 })
var report := contract.validate_message(message)
```

`validate_contract()`、`validate_message()`、`GFNetworkContractMessage.validate_payload()` 和 `GFNetworkContractField.validate_value()` 都返回标准校验报告字典。字段名、消息类型和契约 ID 只作为附加上下文保留，便于生成器、编辑器面板、CI 和项目工具复用同一套诊断展示逻辑。

## 辅助类生成

`GFNetworkContractGenerator` 可把契约资源生成 GDScript 辅助类，提供强类型构造、发送、匹配和字段读取函数。生成器不会扫描或推断项目业务协议；需要生成哪些契约由项目显式配置。

```gdscript
var generator := GFNetworkContractGenerator.new()
generator.generate(contract, "res://gf/generated/network/lobby_network_messages.gd", true, {
	"class_name": "LobbyNetworkMessages",
})

var typed_message := LobbyNetworkMessages.make_player_ready(1)
LobbyNetworkMessages.send_player_ready(network, -1, 1)
```

生成脚本只是项目侧便捷层；底层仍然发送普通 `GFNetworkMessage`，也仍然遵守项目注册的 `GFNetworkChannel`、serializer、validator 和 backend。没有默认值的可选字段会把 `null` 视为“未提供”，默认不写入 payload；如果确实需要显式发送 null，可在 options 中传入 `{ "include_null_optional_fields": true }`。

## 重连策略

需要断线重连时，可以让项目后端使用 `GFNetworkReconnectPolicy` 统一退避间隔和尝试次数。它只返回下一次等待多少毫秒，不负责打开 socket、鉴权、频道恢复或 presence 语义。

```gdscript
var reconnect := GFNetworkReconnectPolicy.new()
reconnect.delays_msec = [500, 1000, 2000, 5000]
reconnect.max_attempts = 0

var delay_msec := reconnect.get_next_delay_msec()
if delay_msec >= 0:
	# 项目后端自行安排 timer 后再次 connect。
	pass
```

## 使用边界

项目层应在后端中处理连接、鉴权、重连、可靠性、频道和平台差异；GF 层只提供稳定的消息载体、序列化、消息大小/结构校验、会话快照和可替换边界。

从 `2.0.0` 起，`GFNetworkMessageValidator.max_packet_size` 默认使用 `64 KiB`。需要传输更大快照或自定义分片协议时应显式调大，或设为 `0` 关闭全局上限；高频通道仍建议配置更小的 `GFNetworkChannel.max_packet_size`。
