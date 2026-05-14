# ActionQueue 表现动作队列

本页聚焦 ActionQueue 扩展中的视觉动作、复合动作、命名队列和拦截器。
## 视觉队列缓冲系统 (`GFActionQueueSystem`)

战斗、卡牌、战棋、剧情和教程经常需要把“规则已经结算完成”和“表现仍在播放”分开。`GFActionQueueSystem` 让表现动作按队列、并行组或命名流执行，避免把动画等待逻辑塞回战斗或回合结算系统。

Action Queue 位于 `addons/gf/extensions/action_queue/`。动作可以继承 `GFVisualAction`，也可以实现动作协议方法，例如 `execute()`、`can_execute()` 和 `cancel()`。

### `GFVisualActionGroup` 复合动作与并行执行

`GFVisualActionGroup` 可以将一组 `GFVisualAction` 打包为一个大动作：

```gdscript
# 将两张卡牌的移动动作并行执行，全部完成后再进入后续动作。
var group: GFVisualActionGroup = GFVisualActionGroup.new([
	GFMoveTweenAction.new(card_a, target_pos_a),
	GFMoveTweenAction.new(card_b, target_pos_b),
], true)

action_queue_sys.enqueue(group)
```

也可以直接使用 `enqueue_parallel([action_a, action_b])`，队列会把它们封装成并行动作组。

### 编写继承的 Action 动效

耗时动作应在 `execute()` 中返回可等待的 `Signal`；立即完成或 fire-and-forget 动作可以返回 `null`。

```gdscript
class_name PlayCardVisualAction
extends GFVisualAction

var target_card: CardNode

func execute() -> Variant:
	var tween := target_card.create_tween()
	tween.tween_property(target_card, "position", Vector2(400, 300), 2.0)
	return tween.finished
```

自定义动作如果持有 Tween、Timer、临时信号连接或外部任务，应重写 `cancel()` 清理这些副作用；基础 `GFVisualAction.cancel()` 不知道项目动作内部资源，默认不做处理。等待 Signal 的动作默认有 30 秒超时，`with_signal_timeout(seconds, respect_time_scale)` 可调整超时时间，并默认跟随 `GFTimeUtility` 的暂停与 `time_scale`。

### 入队执行

```gdscript
var q_sys := Gf.get_system(GFActionQueueSystem) as GFActionQueueSystem
var grp := GFVisualActionGroup.new()
grp.add(PlayCardVisualAction.new(...))

q_sys.enqueue(grp)
```

### 显式 Fire-and-Forget 动作

`GFActionQueueSystem` 使用自动完成模式：`execute()` 返回 `Signal` 就等待，返回 `null` 就继续。如果某个动作只是发出音效、粒子、非阻塞 Tween，不希望占住队列，可以显式声明 fire-and-forget：

```gdscript
var q_sys := Gf.get_system(GFActionQueueSystem) as GFActionQueueSystem

var action := GFAudioAction.new("res://audio/hit.wav")
q_sys.enqueue_fire_and_forget(action)

# 或者在动作自身上声明
q_sys.enqueue(MyParticleAction.new(...).as_fire_and_forget())
```

### 命名队列与节点绑定队列

默认队列适合单条表现流；如果战斗、对白、教程提示需要互不阻塞，可以使用命名队列：

```gdscript
var q_sys := Gf.get_system(GFActionQueueSystem) as GFActionQueueSystem

q_sys.enqueue_to(&"battle", PlayHitAction.new(enemy))
q_sys.enqueue_to(&"dialogue", ShowLineAction.new("hello"))
q_sys.enqueue_parallel_to(&"tutorial", [
	HighlightAction.new(button),
	TooltipAction.new(button),
])
```

临时 UI 或实体可以创建绑定节点生命周期的队列。绑定节点释放后，队列会取消当前动作并清空待执行动作：

```gdscript
var popup_queue := q_sys.get_linked_queue(&"popup_intro", popup_node)
popup_queue.enqueue(FadeInAction.new(popup_node))
```

如需跳过当前表现动作并继续后续队列，可以调用：

```gdscript
q_sys.skip_current_action()
```

### 动作拦截器

当项目需要让状态、配置或调试工具在动作执行前后做横切处理时，可以继承 `GFActionInterceptor` 并注册到队列。拦截器返回 `GFActionInterceptionResult`，可继续、跳过、替换当前动作，或停止后续队列；默认没有拦截器时，`GFActionQueueSystem` 行为保持不变。

```gdscript
class_name SkipInvalidTargetVisuals
extends GFActionInterceptor


func before_execute(action: GFVisualAction, _queue: GFActionQueueSystem) -> GFActionInterceptionResult:
	if action.has_method("has_target") and not action.call("has_target"):
		return GFActionInterceptionResult.skip_action()
	return GFActionInterceptionResult.continue_action()


var q_sys := Gf.get_system(GFActionQueueSystem) as GFActionQueueSystem
q_sys.add_interceptor(SkipInvalidTargetVisuals.new())
```

拦截器按 `priority` 从高到低执行，适合做表现替换、诊断记录、运行时门禁或模块化修正。它不提供卡牌、Buff、剧情或回合规则；这些规则应留在项目自己的 System、Command 或 Action 子类中，再把最终通用决策表达成拦截结果。

框架也内置了几个常用动作，避免每个项目重复写样板类：

```gdscript
q_sys.enqueue(GFMoveTweenAction.new(card_node, Vector2(400, 300), 0.25))
q_sys.enqueue(GFFlashAction.new(card_node, Color.WHITE, 0.12))
q_sys.enqueue(GFAudioAction.new("res://audio/sfx/hit.wav"))
```

需要更短的组合写法时，可以使用 `GFAction` 静态工厂创建常见动作。它只负责生成 `GFVisualAction`，不隐含任何业务流程：

```gdscript
q_sys.enqueue(GFAction.sequence([
	GFAction.move_to(card_node, Vector2(400, 300), 0.2),
	GFAction.parallel([
		GFAction.fade_to(card_node, 0.4, 0.12),
		GFAction.wait(0.12, card_node),
	]),
	GFAction.callback(func() -> void:
		print("visual done")
	),
]))
```

`GFAction` 也提供 `tween_by()`、`move_by()`、`scale_to()`、`scale_by()`、`rotate_to()`、`rotate_by()`、`fade_by()`、`colorize()`、`set_property()`、`show()`、`hide()` 和 `remove_node()` 等便捷工厂。这些工厂仅将常见属性写入、Tween 或节点释放转换为 `GFVisualAction`；调度方式、业务对象含义和流程语义仍由调用方决定。

`GFCallableAction` 用于把普通 `Callable` 插入队列；`GFWaitAction` 表达通用时间等待，取消后不会再由旧计时器触发动作完成；`GFRepeatAction` 会通过工厂每轮创建新动作，避免重复复用带 Tween、Timer 或节点引用的旧动作实例。无限重复的瞬时动作会按 `max_immediate_iterations_per_frame` 分批让出主循环，避免把表现队列锁在同一帧。运行时如果需要控制当前表现，可调用 `pause_current_action()`、`resume_current_action()`、`finish_current_action()` 或 `skip_current_action()`；自定义动作可以重写 `pause()`、`resume()`、`finish()` 和 `cancel()` 响应这些控制。队列控制只表达表现时序，不应承担回合结算、伤害结果或剧情状态修改。

如果表现动画需要被多个界面、实体或流程复用，可以把属性 Tween 抽成资源配置，再生成动作交给队列：

```gdscript
var config := GFTweenActionConfig.new()
config.add_property_step(^"position", Vector2(400, 300), 0.25)
config.add_property_step(^"modulate", Color.WHITE, 0.12)

q_sys.enqueue(config.create_action(card_node))
```

`GFTweenActionConfig` 只描述属性路径、目标值、时长、缓动和并行关系；每一段属性变化由 `GFTweenActionStep` 保存，支持延迟、相对值、并行、transition 和 ease。`GFTweenActionStep.can_apply_to(target)` / `get_validation_error(target)` 可在执行前检查目标属性是否存在、相对值类型是否匹配；无效步骤会被跳过并给出警告，避免把拼写错误推迟到 Tween 执行时才暴露。`create_action(target)` 会生成 `GFConfiguredTweenAction`，由它在执行时创建 Tween、追加步骤、返回 `finished` 信号并在取消时 kill 当前 Tween。具体节点含义、动画命名和业务时机仍由项目层决定。

### 外部动作

ActionQueue 只定义队列协议和通用动作，不内置面向其他 GF 内置扩展的适配动作。项目代码或独立插件可以把自己的表现逻辑封装为实现 `execute()`、`can_execute()`、`cancel()` 和 `should_wait_for_result()` 的对象，再交给队列调度。

---
