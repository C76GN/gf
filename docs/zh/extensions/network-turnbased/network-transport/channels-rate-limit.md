# Channel 与限流

可注册通道描述传输偏好，再按通道发送消息。

```gdscript
var state_channel := GFNetworkChannel.new()
state_channel.channel_id = &"state"
state_channel.transfer_channel = 1
state_channel.reliable = false
network.register_channel(state_channel)

network.send_message_on_channel(-1, GFNetworkMessage.new(&"state_delta", payload), &"state")
```

`send_message_on_channel()` 会把逻辑通道写入消息的 `channel_id` 元信息，接收端会优先按 `channel_id` 匹配通道，再回退到同名 `message_type`。因此消息类型可以继续表达业务语义，例如 `state_delta`，通道则负责包体大小限制和后端发送选项；业务 `payload` 内的 `channel_id` 字段不会参与通道匹配。

`GFNetworkRateLimiter` 是独立令牌桶工具，不会被 `GFNetworkUtility` 自动消费；项目需要在自己的 `System.tick(delta)` 中推进 `rate_limiter.tick(delta)` 并在发送前调用 `consume()`。
