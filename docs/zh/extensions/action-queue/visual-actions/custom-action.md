# 自定义 Action

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

自定义动作如果持有 Tween、Timer、临时信号连接或外部任务，应重写 `cancel()` 清理这些副作用，并释放正在等待该动作完成的调用点。

基础 `GFVisualAction.cancel()` 不知道项目动作内部资源，默认不做处理。

等待 Signal 的动作默认有 30 秒超时，`with_signal_timeout(seconds, respect_time_scale)` 可调整超时时间，并默认跟随 `GFTimeUtility` 的暂停与 `time_scale`。

Signal 可以带任意载荷参数，动作队列只把发射本身视为等待完成，不解释参数内容。
