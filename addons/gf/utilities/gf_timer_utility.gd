## GFTimerUtility: 纯代码驱动的全局定时器工具。
## 通过框架 `tick()` 驱动延时回调，不依赖场景树中的 `Timer` 节点，
## 因而可直接受到 `GFTimeUtility` 的时间缩放与暂停控制。适用于在
## `GFSystem`、`GFModel` 或其他纯逻辑模块中调度一次性延时任务。
class_name GFTimerUtility
extends GFUtility


# --- 私有变量 ---

## 待执行的延时任务列表。每项包含 `remaining` 与 `callback` 字段。
var _pending_timers: Array[Dictionary] = []


# --- Godot 生命周期方法 ---

func init() -> void:
	_pending_timers.clear()


func dispose() -> void:
	_pending_timers.clear()


func tick(delta: float) -> void:
	if _pending_timers.is_empty() or delta <= 0.0:
		return

	var ready_callbacks: Array[Callable] = []

	for index in range(_pending_timers.size() - 1, -1, -1):
		var timer_data := _pending_timers[index]
		timer_data["remaining"] = maxf(float(timer_data.get("remaining", 0.0)) - delta, 0.0)
		_pending_timers[index] = timer_data

		if float(timer_data["remaining"]) <= 0.0:
			var callback := timer_data.get("callback", Callable()) as Callable
			if callback.is_valid():
				ready_callbacks.append(callback)
			_pending_timers.remove_at(index)

	ready_callbacks.reverse()
	for callback: Callable in ready_callbacks:
		callback.call()


# --- 公共方法 ---

## 在指定延迟后执行一次回调函数。
## 基于框架 `tick()` 推进计时，因此会自动遵循 `GFTimeUtility` 的暂停与缩放结果。
## @param delay: 延迟时长，单位为秒。
## @param callback: 延迟结束后执行的无参回调函数。
func execute_after(delay: float, callback: Callable) -> void:
	if not callback.is_valid():
		push_error("[GFTimerUtility] execute_after 失败：传入的 callback 无效。")
		return

	if delay <= 0.0:
		callback.call()
		return

	_pending_timers.append({
		"remaining": delay,
		"callback": callback,
	})
