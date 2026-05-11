## GFInputAssistUtility: 输入手感辅助工具。
##
## 负责动作意图缓冲和通用宽容窗口。它不读取 InputEvent、不处理重绑定、
## 不维护玩家设备，也不替代 GFInputMappingUtility；正式输入映射仍应由
## GFInputMappingUtility 负责。
class_name GFInputAssistUtility
extends GFUtility


# --- 私有变量 ---

var _action_buffers: Dictionary = {}
var _grace_windows: Dictionary = {}


# --- Godot 生命周期方法 ---

func init() -> void:
	ignore_time_scale = true
	_action_buffers.clear()
	_grace_windows.clear()


func dispose() -> void:
	_action_buffers.clear()
	_grace_windows.clear()


# --- 公共方法 ---

## 每帧驱动计时器递减。所有计时器归零后自动清除。
## @param delta: 帧间隔时间（秒）。
func tick(delta: float) -> void:
	_tick_timers(_action_buffers, delta)
	_tick_timers(_grace_windows, delta)


## 缓冲一个动作意图，在 duration 秒内可被消费。
## @param action_id: 动作标识。
## @param duration: 缓冲持续时间（秒）。
## @param player_index: 玩家索引；小于 0 时使用全局缓冲。
func buffer_action(action_id: StringName, duration: float, player_index: int = -1) -> void:
	if action_id == &"" or duration <= 0.0:
		return

	var key := _make_scoped_key(action_id, player_index)
	var current := float(_action_buffers.get(key, 0.0))
	_action_buffers[key] = maxf(current, duration)


## 尝试消费一个缓冲动作。
## @param action_id: 动作标识。
## @param player_index: 玩家索引；小于 0 时使用全局缓冲。
## @return 是否成功消费。
func consume_buffered_action(action_id: StringName, player_index: int = -1) -> bool:
	var key := _make_scoped_key(action_id, player_index)
	if _action_buffers.has(key) and float(_action_buffers[key]) > 0.0:
		_action_buffers.erase(key)
		return true
	return false


## 查询指定动作是否有活跃的缓冲（不消费）。
## @param action_id: 动作标识。
## @param player_index: 玩家索引；小于 0 时使用全局缓冲。
## @return 是否有活跃缓冲。
func has_buffered_action(action_id: StringName, player_index: int = -1) -> bool:
	var key := _make_scoped_key(action_id, player_index)
	return _action_buffers.has(key) and float(_action_buffers[key]) > 0.0


## 清除指定动作缓冲。
## @param action_id: 动作标识。
## @param player_index: 玩家索引；小于 0 时使用全局缓冲。
func clear_buffered_action(action_id: StringName, player_index: int = -1) -> void:
	_action_buffers.erase(_make_scoped_key(action_id, player_index))


## 开始一个通用宽容窗口。
## @param window_id: 窗口标识。
## @param duration: 宽容窗口持续时间（秒）。
## @param player_index: 玩家索引；小于 0 时使用全局窗口。
func start_grace_window(window_id: StringName, duration: float, player_index: int = -1) -> void:
	var key := _make_scoped_key(window_id, player_index)
	if window_id == &"" or duration <= 0.0:
		_grace_windows.erase(key)
		return
	_grace_windows[key] = duration


## 查询指定宽容窗口是否活跃。
## @param window_id: 窗口标识。
## @param player_index: 玩家索引；小于 0 时使用全局窗口。
## @return 是否在窗口内。
func is_grace_window_active(window_id: StringName, player_index: int = -1) -> bool:
	var key := _make_scoped_key(window_id, player_index)
	return _grace_windows.has(key) and float(_grace_windows[key]) > 0.0


## 手动取消指定宽容窗口。
## @param window_id: 窗口标识。
## @param player_index: 玩家索引；小于 0 时使用全局窗口。
func cancel_grace_window(window_id: StringName, player_index: int = -1) -> void:
	_grace_windows.erase(_make_scoped_key(window_id, player_index))


## 清除指定玩家的全部输入辅助状态。
## @param player_index: 玩家索引。
func clear_player(player_index: int) -> void:
	_clear_keys_with_prefix(_action_buffers, _make_scope_prefix(player_index))
	_clear_keys_with_prefix(_grace_windows, _make_scope_prefix(player_index))


## 清除所有缓冲和宽容窗口状态。
func clear_all() -> void:
	_action_buffers.clear()
	_grace_windows.clear()


## 获取调试快照。
## @return 包含缓冲和宽容窗口剩余时间的字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"action_buffers": _duplicate_timer_snapshot(_action_buffers),
		"grace_windows": _duplicate_timer_snapshot(_grace_windows),
	}


# --- 私有/辅助方法 ---

func _tick_timers(timers: Dictionary, delta: float) -> void:
	if timers.is_empty() or delta <= 0.0:
		return

	var expired: Array[String] = []

	for key: String in timers:
		timers[key] = float(timers[key]) - delta
		if float(timers[key]) <= 0.0:
			expired.append(key)

	for key: String in expired:
		timers.erase(key)


func _make_scoped_key(id: StringName, player_index: int) -> String:
	return "%s/%s" % [_make_scope_prefix(player_index), String(id)]


func _make_scope_prefix(player_index: int) -> String:
	if player_index >= 0:
		return "player:%d" % player_index
	return "global"


func _clear_keys_with_prefix(timers: Dictionary, prefix: String) -> void:
	var keys_to_remove: Array[String] = []
	for key: String in timers.keys():
		if key.begins_with(prefix + "/"):
			keys_to_remove.append(key)

	for key: String in keys_to_remove:
		timers.erase(key)


func _duplicate_timer_snapshot(timers: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: String in timers.keys():
		result[key] = float(timers[key])
	return result
