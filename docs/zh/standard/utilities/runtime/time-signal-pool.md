# 时间、信号与对象池

本页拆出运行时基础服务中最常被系统层复用的时间、信号和对象池能力。
## 纯逻辑延迟定时器 (`GFTimerUtility`)

**应用场景：** Godot 的 `get_tree().create_timer(1.0).timeout` 与场景树绑定。如果等待期间切换场景，临时节点或控制器容易留下失效回调。需要受 `GFTimeUtility` 控制、可按 owner 自动清理的逻辑计时时，使用 `GFTimerUtility`。

**如何使用：**
```gdscript
var timer_util := Gf.get_utility(GFTimerUtility) as GFTimerUtility

# 延迟 1.5 秒后执行一次回调
timer_util.execute_after(1.5, func() -> void:
	print("1.5秒逻辑时间后触发")
)

var handle := timer_util.execute_repeating(0.25, func() -> void:
	print("tick")
, 4)

timer_util.execute_after_owned(self, 2.0, func() -> void:
	print("owner 仍然存在时才会触发")
)
```

`execute_after()` 处理一次性延迟任务；`execute_repeating()` 处理固定间隔任务，`repeat_count < 0` 表示无限重复。`execute_after_owned()` / `execute_repeating_owned()` 会用弱引用追踪 owner，owner 释放后任务自动丢弃，适合 UI、临时场景对象或短生命周期控制器注册逻辑计时。排队成功时会返回大于 `0` 的句柄，可用 `cancel(handle)` 取消，或用 `cancel_owner(owner)` 批量取消同一 owner 的任务。它由架构 tick 传入的逻辑 delta 推进；通常会自然受到 `GFTimeUtility` 的缩放和暂停结果影响，但如果项目手动调用 `timer_util.tick(delta)`，传入什么 delta 就按什么时间推进。`get_debug_snapshot()` 可查看 pending 数量、句柄和 owner 绑定任务数量；框架 `dispose()` 时会清空尚未触发的任务。


## 动态时间缩放流 (`GFTimeUtility`)

**应用场景：** 实现子弹时间、暂停特定组内的系统、在受击时定帧 (Hit Stop)。

**如何使用：**
```gdscript
var time_scale_util := Gf.get_utility(GFTimeUtility) as GFTimeUtility
# 全局逻辑时间放慢 10 倍
time_scale_util.time_scale = 0.1

# 或暂停某个自定义组，并在系统内主动获取该组 delta
time_scale_util.set_group_paused(&"CombatSystems", true)
```

`max_scaled_delta` 可限制单帧传入普通 `tick()` 的最大缩放步长，避免掉帧或极端加速造成逻辑跳变；物理逻辑可通过 `physics_substep_max_delta` 和 `max_physics_substeps` 把一次 `physics_tick` 拆成多个子步。全局暂停会让未标记 `ignore_pause` 的系统收到 `0.0`，分组暂停则需要系统或项目代码使用 `get_group_scaled_delta()` 主动读取对应组的 delta。


## 原生信号连接工具 (`GFSignalUtility`)

**应用场景：** 业务事件请继续使用 `GFTypeEventSystem`；但 UI 按钮、动画完成、Area 进入、滑条变化这类 Godot 原生 Signal，经常需要 owner 归属清理、默认参数、一次性监听或防抖处理。`GFSignalUtility` 专门处理这类连接。

**如何使用：**
```gdscript
var signals := Gf.get_utility(GFSignalUtility) as GFSignalUtility

signals.connect_signal(
	button.pressed,
	func(panel_id: String) -> void:
		_open_panel(panel_id),
	self,
	["inventory"]
).once()

signals.connect_signal(slider.value_changed, func(value: float) -> void:
	_update_volume(value)
, self).filter(func(value: float) -> bool:
	return value >= 0.0
).debounce(0.05)

# 节点或对象销毁前也可以按 owner 一次性断开
signals.disconnect_owner(self)
```

`filter()`、`map()`、`delay()`、`debounce()`、`throttle()`、`skip()`、`take()`、`scan()` 会按链式顺序执行；`first()` 是 `take(1)` 的语义糖，`start_with(value)` 可立即向链路注入一次初始值。`connect_any()` 可把多个 Signal 接到同一个回调，返回的连接列表可交给 `disconnect_connections()` 批量断开。`connect_once()` 或 `once()` 会在首次成功触发后自动断开并从工具追踪中移除。`connect_signal()` 返回的链式对象类型是 `GFSignalConnection`，通常不需要手动保存；只有需要主动 `disconnect_signal()`、延迟追加操作或查询连接状态时才保留引用。

连接会用弱引用追踪 owner，`prune_invalid_connections()` 会清理 owner 或信号源已经失效的连接。当前连接包装器最多收集 8 个信号参数；超过这个数量的极少数自定义信号应直接使用 Godot 原生连接或自行封装 payload。`delay()` / `debounce()` 使用 SceneTree 计时器或帧等待做信号层延迟，`throttle()` 使用系统毫秒时间做信号层节流，适合 UI、编辑器工具和轻量运行时事件；它不是 `GFTimerUtility` 的替代品，也不会表达 GF 逻辑时间组的暂停语义。


## 节点对象池 (`GFObjectPoolUtility`)

**应用场景：** 子弹、伤害飘字、特效等短生命周期节点需要反复创建和回收时，可以使用对象池降低实例化和释放成本。

```gdscript
var pool := Gf.get_utility(GFObjectPoolUtility) as GFObjectPoolUtility

# 借出一个实例（传入资源以及它的父节点）
var bullet = pool.acquire(bullet_scene, get_tree().root) as Node2D

# 归还它进入休眠
pool.release(bullet, bullet_scene)
```

首次使用前可以预热，避免战斗开始时一次性实例化大量节点：

```gdscript
pool.max_available_per_scene = 128
pool.prewarm(bullet_scene, get_tree().root, 64)
await pool.prewarm_async_budget(explosion_scene, get_tree().root, 40, 4.0)
```

池化节点可以选择实现两个 hook，让节点自己清理旧状态：

```gdscript
func on_gf_pool_release() -> void:
	# 清理 Tween、临时信号连接、运行时 meta 等
	pass

func on_gf_pool_acquire() -> void:
	# 重置本次使用需要的状态
	pass
```

归还时节点会被移动到内部 `GFObjectPoolRoot`，并恢复/关闭 `process_mode`、`CanvasItem.visible` 和常见 `disabled` 属性；`manage_descendant_active_state` 控制是否递归处理子节点。`release()` 会校验节点是否确实来自对应池，避免把外部节点或其他 `PackedScene` 的实例混入。继承 `GFController` 的池化节点会在归还或预热时自动暂停由基类 `register_event()` / `register_simple_event()` 记录的事件监听，并在再次 `acquire()` 后恢复；这避免 `_ready()` 只执行一次的控制器复用后丢监听，也避免休眠节点继续接收事件。默认 `prune_invalid_on_each_operation = true` 会在高频接口前清理已释放节点引用，换取更稳的计数；极端热路径可在项目层确认生命周期后关闭，并在低频点主动调用 `prune_invalid_nodes()`。`get_available_count()`、`get_active_count()`、`get_debug_snapshot()` 可用于调试池容量。

