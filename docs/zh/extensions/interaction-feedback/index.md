# Interaction 与 Feedback

本页聚焦 Interaction 扩展的一次性交互上下文，以及 Feedback 扩展的通用反馈采样。
## 交互上下文

`GFInteractionContext` 是一个轻量数据载体，用于在命令、事件或项目自定义方法之间传递 sender、target、payload 和可选分组名：

```gdscript
var context := GFInteractionContext.new(player, enemy, { "amount": 10 }, &"enemies")
```

也可以使用 `GFInteractions` 创建链式交互流程。`GFInteractions.with_sender(...)` 会返回一个 `GFInteractionFlow`，后者负责继续设置 target、payload、group，并在执行命令或发送事件前把 `GFInteractionContext` 注入到对象中：

```gdscript
var command := DealDamageCommand.new()
GFInteractions.with_sender(player).to(enemy).with_payload({ "amount": 10 }).execute(command)
```

`execute(command)` 会优先通过当前架构发送命令，找不到架构时才回退直接调用命令的 `execute()`。`send_event(event)` 必须依赖当前或全局架构，没有架构时不会派发。命令或事件可通过 `interaction_context` 属性或 `set_interaction_context(context)` 方法接收上下文。Interaction 扩展只组织一次性交互上下文，不负责能力查询、冷却、权限、目标合法性或效果结算；这些组合关系应由项目、外部扩展或外部扩展显式装配。

如果项目需要把场景节点之间的交互发送与接收标准化，可使用 `GFInteractionSensor` 和 `GFInteractionReceiver`。Sensor 负责构建上下文并调用接收对象的 `receive_interaction()`，Receiver 提供启用状态、交互 ID 白名单/黑名单、自定义校验回调和统一报告：

```gdscript
var sensor := GFInteractionSensor.new()
sensor.interaction_id = &"use"
sensor.payload = { "source": "keyboard" }

var receiver := GFInteractionReceiver.new()
receiver.accepted_interaction_ids = [&"use"]
receiver.validation_callback = func(context: GFInteractionContext, report: Dictionary) -> Dictionary:
	return {
		"ok": context.sender != null,
		"metadata": {
			"checked": true,
		},
	}

var result := sensor.send_to(receiver)
```

当碰撞区域只想承担检测和过滤，而业务逻辑在角色、物品或能力节点上时，可以把 `GFInteractionReceiver` 放在碰撞对象自身或其父级，并通过 `receiver_path` 指向真正的业务接收节点。Receiver 会先执行自己的 `enabled`、交互 ID 过滤和 `validation_callback`，通过后再调用目标节点的 `receive_interaction(context, interaction_id)`；如果上下文的 `target` 为空或仍指向桥接 Receiver，会在转发前更新为业务接收节点。

这组节点只表达“谁向谁发送了什么上下文、接收方是否接受”，不会绑定碰撞层、提示 UI、距离规则、冷却、物品消耗或目标效果。需要 2D/3D 范围或射线时，可把项目自己的 `RayCast2D` / `RayCast3D` / `Area2D` / `Area3D` 检测结果交给 `send_to_raycast_2d()`、`send_to_raycast_3d()`、`broadcast_to_area_2d()` 或 `broadcast_to_area_3d()`；Sensor 会从碰撞对象向父节点查找具备 `receive_interaction()` 的接收器。输入触发、碰撞层筛选、UI 焦点和目标合法性仍由项目层决定。

3D 鼠标/指针点击可使用 `GFPointerInteraction3D` 作为场景桥接节点。它监听绑定的 `CollisionObject3D.input_event`、`mouse_entered` 和 `mouse_exited`，把 hover、press、release、click、wheel 转为 `GFInteractionContext`，payload 中包含 `pointer_position`、`pointer_normal`、`pointer_shape_idx`、`pointer_button_index`、`pointer_tags` 和 `pointer_metadata` 等通用字段：

```gdscript
var pointer := GFPointerInteraction3D.new()
pointer.interaction_id = &"inspect"
pointer.payload = { "source": "mouse" }
pointer.receiver_path = NodePath("../InteractionReceiver")
static_body.add_child(pointer)
```

默认只在 click 完成时发送交互；`send_on_pressed`、`send_on_released`、`send_on_wheel` 和 `send_on_hover` 可按需开启。桥接节点不会替项目判断距离、可见性、焦点、阵营、物品权限或点击后的效果，只负责把 Godot 3D 指针事件转换为 GF 通用交互上下文。


## 与表现队列的关系

Feedback 扩展只负责采样和应用反馈偏移；如果项目需要把反馈纳入表现队列，应在项目代码、外部扩展或外部扩展中把 `GFShakeUtility.play_shake()` 包装成自己的队列动作。


## 通用反馈采样 (`GFShakePreset` / `GFShakeUtility`)

表现层如果需要相机抖动、UI 冲击、节点轻微扰动或任意“按时间采样的反馈偏移”，可以使用 `GFShakePreset` 描述曲线和轴权重，再由 `GFShakeUtility` 管理命名 channel 上的播放状态。它只输出 `position`、`rotation_degrees`、`scale` 这类通用偏移，不知道目标是 Camera、角色、Control 还是项目自定义对象。

```gdscript
var shake := Gf.get_utility(GFShakeUtility) as GFShakeUtility

var preset := GFShakePreset.new()
preset.duration_seconds = 0.18
preset.frequency = 18.0
preset.position_axis = Vector3(6.0, 4.0, 0.0)
preset.rotation_axis_degrees = Vector3(0.0, 0.0, 1.2)

shake.play_shake(&"camera", preset, 1.0, { "source": "impact" })
var sample := shake.sample_channel(&"camera")
```

简单反馈可直接使用 `GFShakePreset` 上的单波形字段；需要把多段位移、旋转、缩放或不同波形组合在一起时，可添加 `GFShakeTrack`。轨道支持独立进度区间、包络曲线、波形曲线和混合模式，仍然只输出通用偏移采样，不绑定相机、角色、UI 或某个事件系统。

```gdscript
var track := GFShakeTrack.new()
track.start_progress = 0.0
track.end_progress = 0.35
track.position_axis = Vector3(4.0, 0.0, 0.0)
track.rotation_axis_degrees = Vector3.ZERO
preset.add_track(track)
```

`GFShakeReceiver2D` 和 `GFShakeReceiver3D` 是可选场景桥接节点：它们记录目标节点的基础变换，并把某个 channel 的采样叠加到目标上。接收器按“上一帧已应用偏移”做差量更新，因此目标节点在抖动期间仍可被移动系统、动画或布局逻辑改位置，新的外部变换不会被下一次采样覆盖；`reset_to_base()` 会移除最后一次反馈偏移并更新基准。项目也可以完全不用接收器，直接读取 `sample_channel()` 后应用到自己的相机系统、UI 动画或 shader 参数。

---
