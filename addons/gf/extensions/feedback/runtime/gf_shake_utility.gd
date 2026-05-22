## GFShakeUtility: 通用反馈播放与采样工具。
##
## 管理命名 channel 上的 `GFShakePreset` 播放状态，项目可按需把采样结果应用到
## Camera、Node2D、Node3D、Control 或任意自定义表现对象。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFShakeUtility
extends GFUtility


# --- 信号 ---

## 反馈播放开始时发出。
## [br]
## @api public
## [br]
## @param shake_id: 播放实例 ID。
## [br]
## @param channel: 反馈 channel。
signal shake_started(shake_id: int, channel: StringName)

## 反馈播放结束时发出。
## [br]
## @api public
## [br]
## @param shake_id: 播放实例 ID。
## [br]
## @param channel: 反馈 channel。
signal shake_finished(shake_id: int, channel: StringName)

## 反馈播放被停止时发出。
## [br]
## @api public
## [br]
## @param shake_id: 播放实例 ID。
## [br]
## @param channel: 反馈 channel。
signal shake_stopped(shake_id: int, channel: StringName)


# --- 枚举 ---

## 活跃反馈达到上限时的处理方式。
## [br]
## @api public
enum OverflowPolicy {
	## 跳过新的播放请求。
	SKIP_NEW,
	## 停止最早的播放实例。
	STOP_OLDEST,
}


# --- 公共变量 ---

## 默认 channel。
## [br]
## @api public
var default_channel: StringName = &"default"

## 最大活跃反馈数量；小于等于 0 表示不限制。
## [br]
## @api public
var max_active_shakes: int = 64

## 达到上限时的处理方式。
## [br]
## @api public
var overflow_policy: OverflowPolicy = OverflowPolicy.STOP_OLDEST

## 是否为每次播放随机化相位。
## [br]
## @api public
var randomize_phase: bool = true


# --- 私有变量 ---

var _shake_serial: int = 0
var _active_shakes: Dictionary = {}
var _play_order: PackedInt32Array = PackedInt32Array()
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


# --- GF 生命周期方法 ---

## 初始化反馈运行时状态和随机源。
## [br]
## @api public
func init() -> void:
	clear()
	_rng.randomize()


## 释放全部反馈播放状态。
## [br]
## @api public
func dispose() -> void:
	clear()


## 推进反馈播放状态。
## [br]
## @api public
## [br]
## @param delta: 本帧时间增量。
func tick(delta: float) -> void:
	if _active_shakes.is_empty():
		return

	var finished_ids := PackedInt32Array()
	for shake_id: int in _active_shakes.keys():
		var state := _active_shakes[shake_id] as Dictionary
		if state == null:
			finished_ids.append(shake_id)
			continue
		state["elapsed_seconds"] = float(state.get("elapsed_seconds", 0.0)) + maxf(delta, 0.0)
		var preset := state.get("preset") as GFShakePreset
		if preset == null or float(state["elapsed_seconds"]) >= preset.get_duration_seconds():
			finished_ids.append(shake_id)

	for shake_id: int in finished_ids:
		_finish_shake(shake_id)


# --- 公共方法 ---

## 播放一个反馈预设。
## [br]
## @api public
## [br]
## @param channel: 反馈 channel；为空时使用 default_channel。
## [br]
## @param preset: 反馈预设。
## [br]
## @param strength: 播放强度倍率。
## [br]
## @param metadata: 项目自定义元数据。
## [br]
## @schema metadata: Dictionary，播放实例自定义元数据，会在 get_shake_info() 快照中复制返回。
## [br]
## @return 播放实例 ID；无法播放时返回 -1。
func play_shake(
	channel: StringName,
	preset: GFShakePreset,
	strength: float = 1.0,
	metadata: Dictionary = {}
) -> int:
	if preset == null or preset.get_duration_seconds() <= 0.0:
		return -1
	if not _reserve_capacity():
		return -1

	_shake_serial += 1
	var shake_id := _shake_serial
	var effective_channel := _resolve_channel(channel)
	_active_shakes[shake_id] = {
		"id": shake_id,
		"channel": effective_channel,
		"preset": preset,
		"strength": maxf(strength, 0.0),
		"elapsed_seconds": 0.0,
		"phase_offset": _rng.randf() if randomize_phase else 0.0,
		"metadata": metadata.duplicate(true),
	}
	_play_order.append(shake_id)
	shake_started.emit(shake_id, effective_channel)
	return shake_id


## 停止指定反馈实例。
## [br]
## @api public
## [br]
## @param shake_id: 播放实例 ID。
## [br]
## @param emit_stopped: 是否发出停止信号。
## [br]
## @return 成功停止返回 true。
func stop_shake(shake_id: int, emit_stopped: bool = true) -> bool:
	if not _active_shakes.has(shake_id):
		return false

	var state := _active_shakes[shake_id] as Dictionary
	var channel := StringName(state.get("channel", default_channel)) if state != null else default_channel
	_active_shakes.erase(shake_id)
	var order_index := _play_order.find(shake_id)
	if order_index >= 0:
		_play_order.remove_at(order_index)
	if emit_stopped:
		shake_stopped.emit(shake_id, channel)
	return true


## 停止指定 channel 上的全部反馈实例。
## [br]
## @api public
## [br]
## @param channel: 反馈 channel；为空时使用 default_channel。
## [br]
## @return 停止数量。
func stop_channel(channel: StringName) -> int:
	var effective_channel := _resolve_channel(channel)
	var stopped_count := 0
	for shake_id: int in _active_shakes.keys():
		var state := _active_shakes[shake_id] as Dictionary
		if state != null and StringName(state.get("channel", default_channel)) == effective_channel:
			if stop_shake(shake_id):
				stopped_count += 1
	return stopped_count


## 清空全部反馈实例。
## [br]
## @api public
func clear() -> void:
	_active_shakes.clear()
	_play_order = PackedInt32Array()


## 检查反馈实例是否仍在播放。
## [br]
## @api public
## [br]
## @param shake_id: 播放实例 ID。
## [br]
## @return 正在播放返回 true。
func is_shake_active(shake_id: int) -> bool:
	return _active_shakes.has(shake_id)


## 获取活跃反馈数量。
## [br]
## @api public
## [br]
## @param channel: 可选 channel；为空时统计全部。
## [br]
## @return 活跃反馈数量。
func get_active_shake_count(channel: StringName = &"") -> int:
	if channel == &"":
		return _active_shakes.size()

	var count := 0
	for state_variant: Variant in _active_shakes.values():
		var state := state_variant as Dictionary
		if state != null and StringName(state.get("channel", default_channel)) == channel:
			count += 1
	return count


## 采样指定 channel 当前的合成反馈。
## [br]
## @api public
## [br]
## @param channel: 反馈 channel；为空时使用 default_channel。
## [br]
## @return 合成采样结果。
## [br]
## @schema return: Dictionary，包含 position: Vector3、rotation_degrees: Vector3、scale: Vector3、intensity: float 与 progress: float。
func sample_channel(channel: StringName = &"") -> Dictionary:
	var effective_channel := _resolve_channel(channel)
	var samples: Array[Dictionary] = []
	for state_variant: Variant in _active_shakes.values():
		var state := state_variant as Dictionary
		if state == null or StringName(state.get("channel", default_channel)) != effective_channel:
			continue
		var preset := state.get("preset") as GFShakePreset
		if preset == null:
			continue
		samples.append(preset.sample(
			float(state.get("elapsed_seconds", 0.0)),
			float(state.get("strength", 1.0)),
			float(state.get("phase_offset", 0.0))
		))
	return GFShakePreset.combine_samples(samples)


## 采样多个 channel 当前的合成反馈。
## [br]
## @api public
## [br]
## @param channels: 反馈 channel 列表。
## [br]
## @return 合成采样结果。
## [br]
## @schema return: Dictionary，包含 position: Vector3、rotation_degrees: Vector3、scale: Vector3、intensity: float 与 progress: float。
func sample_channels(channels: PackedStringArray) -> Dictionary:
	var samples: Array[Dictionary] = []
	for channel: String in channels:
		samples.append(sample_channel(StringName(channel)))
	return GFShakePreset.combine_samples(samples)


## 获取指定反馈实例的只读快照。
## [br]
## @api public
## [br]
## @param shake_id: 播放实例 ID。
## [br]
## @return 播放实例快照。
## [br]
## @schema return: Dictionary，包含 id、channel、elapsed_seconds、duration_seconds、strength 与 metadata；实例不存在时为空。
func get_shake_info(shake_id: int) -> Dictionary:
	var state := _active_shakes.get(shake_id) as Dictionary
	if state == null:
		return {}
	var preset := state.get("preset") as GFShakePreset
	return {
		"id": shake_id,
		"channel": state.get("channel", default_channel),
		"elapsed_seconds": float(state.get("elapsed_seconds", 0.0)),
		"duration_seconds": preset.get_duration_seconds() if preset != null else 0.0,
		"strength": float(state.get("strength", 1.0)),
		"metadata": (state.get("metadata", {}) as Dictionary).duplicate(true),
	}


## 获取反馈系统调试快照。
## [br]
## @api public
## [br]
## @return 调试快照。
## [br]
## @schema return: Dictionary，包含 active_count、max_active_shakes、channels 与 play_order。
func get_debug_snapshot() -> Dictionary:
	var channels: Dictionary = {}
	for state_variant: Variant in _active_shakes.values():
		var state := state_variant as Dictionary
		if state == null:
			continue
		var channel := String(state.get("channel", default_channel))
		channels[channel] = int(channels.get(channel, 0)) + 1
	return {
		"active_count": _active_shakes.size(),
		"max_active_shakes": max_active_shakes,
		"channels": channels,
		"play_order": _play_order,
	}


# --- 私有/辅助方法 ---

func _reserve_capacity() -> bool:
	if max_active_shakes <= 0 or _active_shakes.size() < max_active_shakes:
		return true
	if overflow_policy == OverflowPolicy.SKIP_NEW:
		return false
	while _active_shakes.size() >= max_active_shakes and not _play_order.is_empty():
		stop_shake(_play_order[0])
	return _active_shakes.size() < max_active_shakes


func _finish_shake(shake_id: int) -> void:
	if not _active_shakes.has(shake_id):
		return
	var state := _active_shakes[shake_id] as Dictionary
	var channel := StringName(state.get("channel", default_channel)) if state != null else default_channel
	_active_shakes.erase(shake_id)
	var order_index := _play_order.find(shake_id)
	if order_index >= 0:
		_play_order.remove_at(order_index)
	shake_finished.emit(shake_id, channel)


func _resolve_channel(channel: StringName) -> StringName:
	return default_channel if channel == &"" else channel
