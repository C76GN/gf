# Network 固定 tick、快照与历史

这一页说明面向同步、重放或插值的轻量原语。它们只保存 tick、状态字典和历史窗口，不实现预测、回滚、实体复制或服务器权威规则。

## 核心模型

- `GFFixedTickClock`：把真实时间转换为固定 tick 步数。
- `GFNetworkSnapshot`：保存某个 tick 的状态字典，并能生成浅层 delta 或路径级 patch。
- `GFNetworkHistoryBuffer`：按 tick 保存有限历史。
- `GFNetworkFieldSerializer` / `GFNetworkSnapshotSchema`：按字段编码和解码状态字典。

## Tick 与快照

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
var patch_payload := previous.make_patch_to(latest)
```

`GFFixedTickClock` 除了批量 `ticks_advanced`，也会在每个固定步发出 `tick_started` / `tick_finished`，并在单帧预算不足时发出 `tick_budget_exhausted`。时钟只负责说明本帧该处理哪些 tick；具体输入采样、实体更新、状态广播和视觉插值仍由项目系统决定。

## 字段编码

```gdscript
var position_serializer := GFNetworkFieldSerializer.new()
position_serializer.value_type = GFNetworkFieldSerializer.ValueType.VECTOR2
position_serializer.quantize_decimals = 2

var schema := GFNetworkSnapshotSchema.new()
schema.set_field_serializer(&"position", position_serializer)

var encoded := schema.encode_snapshot(latest)
var decoded := schema.decode_snapshot(encoded)
```

Schema 只改变状态字段的表示形式，不决定哪些字段应该同步、发给谁、是否可靠、如何预测或如何解决冲突。

路径级 patch 用 `set` / `erase` 操作描述嵌套字典变化。它适合状态字典中有实体表、组件表或多层配置片段的同步场景；数组、向量和其他非字典值仍作为整体字段比较。需要压缩或量化 patch 时，`GFNetworkSnapshotSchema.encode_patch()` / `decode_patch()` 会复用已注册的顶层字段编码器。

```gdscript
var patch := previous.make_patch_to(latest, {
	"max_depth": 8,
})

var encoded_patch := schema.encode_patch(patch)
var decoded_patch := schema.decode_patch(encoded_patch)
var next_snapshot := previous.apply_patch(decoded_patch)
```

## 使用边界

`GFNetworkHistoryBuffer` 可查询 tick 范围或某个 tick 前后的快照，方便项目做插值、对账或回放定位。`GFNetworkSnapshot.make_message()` 可以把快照打包成 `GFNetworkMessage`，方便复用已有 serializer、channel 和 backend。

浅层 delta 只比较字典第一层字段，适合简单状态或需要保持载荷结构极直观的流程；路径级 patch 只负责表达嵌套字典的字段变化，不决定实体复制、冲突解决、预测、回滚或安全过滤。接收端处理入站消息时，`GFNetworkUtility` 会以底层 backend 报告的 `peer_id` 覆盖 `message.sender_id`，项目不要信任客户端 payload 中自带的 sender 身份。
