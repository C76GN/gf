# Type Event

Type Event 按事件对象脚本类型派发，适合带明确数据协议的业务通信。例如受到伤害、任务完成、资源加载完成等事件，都应把数据放进稳定 payload 类型。

## 阅读入口

- [定义 Payload](payload.md)：事件对象脚本类型、`GFPayload` 约定和序列化字典。
- [发送与监听事件](send-listen.md)：`Gf.send_event()`、`register_event()`、监听优先级、注销、`is_consumed` 和高频事件边界。

## 使用边界

底层事件系统只要求事件实例附加脚本。继承 `GFPayload` 是推荐约定，用于统一获得 `is_consumed`、序列化和校验能力。
