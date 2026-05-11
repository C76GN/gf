## GFInputPlayback: 抽象输入录制回放器。
##
## 按时间把 GFInputRecording 中的动作值写入 GFVirtualInputSource，适合测试、
## 复现、教程或 AI 控制桥接。它只回放抽象动作，不模拟具体键鼠或手柄事件。
class_name GFInputPlayback
extends RefCounted


# --- 信号 ---

## 回放开始。
## @param recording: 回放录制。
signal playback_started(recording: RefCounted)

## 回放停止。
signal playback_stopped

## 回放自然完成。
signal playback_finished

## 一个录制事件已被应用。
## @param event: 事件副本。
signal event_applied(event: Dictionary)


# --- 常量 ---

const GFInputRecordingBase = preload("res://addons/gf/standard/input/recording/gf_input_recording.gd")
const GFVirtualInputSourceBase = preload("res://addons/gf/standard/input/sources/gf_virtual_input_source.gd")


# --- 公共变量 ---

## 当前录制。
var recording: GFInputRecordingBase = null

## 目标虚拟输入源。
var source: GFVirtualInputSourceBase = null

## 回放速度倍率。
var speed: float = 1.0

## 到达末尾后是否循环。
var loop: bool = false

## 为 true 时，事件带 player_index 时会写入对应玩家。
var respect_recorded_player_index: bool = false

## 当前是否正在播放。
var is_playing: bool = false

## 当前回放时间，单位秒。
var elapsed_seconds: float = 0.0


# --- 私有变量 ---

var _next_event_index: int = 0


# --- 公共方法 ---

## 开始回放。
## @param next_recording: 要回放的录制。
## @param next_source: 目标虚拟输入源。
## @param restart: 是否从头开始。
## @return 成功开始时返回 true。
func start(
	next_recording: GFInputRecordingBase,
	next_source: GFVirtualInputSourceBase,
	restart: bool = true
) -> bool:
	if next_recording == null or next_source == null:
		return false

	recording = next_recording
	source = next_source
	is_playing = true
	if restart:
		elapsed_seconds = 0.0
		_next_event_index = 0
	else:
		_next_event_index = _find_next_event_index(elapsed_seconds)
	playback_started.emit(recording)
	return true


## 停止回放。
## @param clear_source: 是否清空目标虚拟输入源。
func stop(clear_source: bool = false) -> void:
	if clear_source and source != null:
		source.clear_all()
	is_playing = false
	playback_stopped.emit()


## 重置到起点。
func reset() -> void:
	elapsed_seconds = 0.0
	_next_event_index = 0


## 推进回放并应用到期事件。
## @param delta: 时间增量，单位秒。
## @return 本次应用的事件数量。
func tick(delta: float) -> int:
	if not is_playing or recording == null or source == null:
		return 0

	elapsed_seconds += maxf(delta, 0.0) * maxf(speed, 0.0)
	var applied := _apply_due_events()
	if _next_event_index >= recording.events.size():
		_handle_end_reached()
	return applied


## 跳转到指定时间。
## @param time_seconds: 目标时间，单位秒。
func seek(time_seconds: float) -> void:
	elapsed_seconds = maxf(time_seconds, 0.0)
	_next_event_index = _find_next_event_index(elapsed_seconds)


## 检查是否已到达末尾。
## @return 到达末尾时返回 true。
func is_finished() -> bool:
	return recording == null or _next_event_index >= recording.events.size()


## 获取调试快照。
## @return 调试快照。
func get_debug_snapshot() -> Dictionary:
	return {
		"is_playing": is_playing,
		"elapsed_seconds": elapsed_seconds,
		"speed": speed,
		"loop": loop,
		"respect_recorded_player_index": respect_recorded_player_index,
		"next_event_index": _next_event_index,
		"event_count": recording.get_event_count() if recording != null else 0,
		"source_id": source.source_id if source != null else &"",
	}


# --- 私有/辅助方法 ---

func _apply_due_events() -> int:
	var applied := 0
	while _next_event_index < recording.events.size():
		var event: Dictionary = recording.events[_next_event_index]
		if float(event.get("time_seconds", 0.0)) > elapsed_seconds + 0.0001:
			break
		if _apply_event(event):
			applied += 1
		_next_event_index += 1
	return applied


func _apply_event(event: Dictionary) -> bool:
	var action_id := event.get("action_id", &"") as StringName
	if action_id == &"":
		return false

	var value: Variant = event.get("value", false)
	var player_index := int(event.get("player_index", -1))
	var applied := false
	if respect_recorded_player_index and player_index >= 0:
		applied = source.set_action_value_for_player(action_id, value, player_index)
	else:
		applied = source.set_action_value(action_id, value)
	if applied:
		event_applied.emit(GFVariantData.duplicate_variant(event) as Dictionary)
	return applied


func _handle_end_reached() -> void:
	if loop and recording.duration_seconds > 0.0:
		elapsed_seconds = fmod(elapsed_seconds, recording.duration_seconds)
		_next_event_index = 0
		_apply_due_events()
		return
	is_playing = false
	playback_finished.emit()


func _find_next_event_index(time_seconds: float) -> int:
	if recording == null:
		return 0
	for index: int in range(recording.events.size()):
		if float(recording.events[index].get("time_seconds", 0.0)) > time_seconds:
			return index
	return recording.events.size()
