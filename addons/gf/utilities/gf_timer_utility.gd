## GFTimerUtility: 纯代码驱动的全局定时器工具。
## 通过框架 `tick()` 驱动延时回调，不依赖场景树中的 `Timer` 节点，
## 因而可直接受到 `GFTimeUtility` 的时间缩放与暂停控制。适用于在
## `GFSystem`、`GFModel` 或其他纯逻辑模块中调度一次性延时任务。
class_name GFTimerUtility
extends GFUtility


# --- 私有变量 ---

## 待执行的延时任务列表。每项包含 `id`、`remaining` 与 `callback` 字段。
var _pending_timers: Array[Dictionary] = []
var _next_timer_id: int = 1


# --- Godot 生命周期方法 ---

func init() -> void:
	_pending_timers.clear()
	_next_timer_id = 1


func dispose() -> void:
	_pending_timers.clear()
	_next_timer_id = 1


## 推进运行时逻辑。
## @param delta: 本帧时间增量（秒）。
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
## @return 已排队定时器的句柄；无效回调或立即执行时返回 `0`。
func execute_after(delay: float, callback: Callable) -> int:
	if not callback.is_valid():
		push_error("[GFTimerUtility] execute_after 失败：传入的 callback 无效。")
		return 0

	if delay <= 0.0:
		callback.call()
		return 0

	var handle := _next_timer_id
	_next_timer_id += 1
	_pending_timers.append({
		"id": handle,
		"remaining": delay,
		"callback": callback,
	})
	return handle


## 取消一个尚未触发的延时任务。
## @param handle: `execute_after()` 返回的定时器句柄。
## @return 找到并取消任务时返回 `true`。
func cancel(handle: int) -> bool:
	if handle <= 0:
		return false

	for index: int in range(_pending_timers.size() - 1, -1, -1):
		if int(_pending_timers[index].get("id", 0)) == handle:
			_pending_timers.remove_at(index)
			return true
	return false
