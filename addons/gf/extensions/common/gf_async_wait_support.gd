## GFAsyncWaitSupport: 内部异步等待辅助。
##
## 提供 Signal 安全断开和受 GFTimeUtility 影响的超时增量计算，供流程、序列和动作队列复用。
extends RefCounted


# --- 公共方法 ---

## 计算超时累计增量。
## @param previous_msec: 上一次采样时间。
## @param current_msec: 当前采样时间。
## @param time_utility: 可选时间工具。
## @param respect_time_scale: 是否跟随暂停和 time_scale。
## @return 超时增量毫秒。
static func get_timeout_elapsed_msec(
	previous_msec: int,
	current_msec: int,
	time_utility: GFTimeUtility,
	respect_time_scale: bool
) -> float:
	var elapsed_msec := float(current_msec - previous_msec)
	if not respect_time_scale:
		return elapsed_msec
	if time_utility == null:
		return elapsed_msec
	if time_utility.is_paused:
		return 0.0
	return elapsed_msec * time_utility.time_scale


## 若信号已连接指定回调，则安全断开。
## @param target_signal: 目标信号。
## @param callback: 回调。
static func disconnect_signal_if_connected(target_signal: Signal, callback: Callable) -> void:
	if target_signal.is_null():
		return
	if not is_instance_valid(target_signal.get_object()):
		return
	if target_signal.is_connected(callback):
		target_signal.disconnect(callback)
