## GFShakePreset: 通用反馈采样预设。
##
## 描述一段可采样的位移、旋转和缩放偏移，不绑定相机、角色、UI 或业务事件。
class_name GFShakePreset
extends Resource


# --- 枚举 ---

## 反馈采样波形。
enum Waveform {
	## 正弦波，适合可预期的摆动。
	SINE,
	## 逐步随机值，适合冲击感。
	RANDOM,
	## 平滑随机值，适合持续扰动。
	NOISE,
	## 使用 wave_curve 采样，曲线值 0.5 表示零偏移。
	CURVE,
}


# --- 常量 ---

const GFShakeTrackBase = preload("res://addons/gf/extensions/feedback/resources/gf_shake_track.gd")


# --- 导出变量 ---

## 持续时间，单位秒。
@export_range(0.0, 60.0, 0.001, "or_greater") var duration_seconds: float = 0.25

## 采样振幅倍率。
@export_range(0.0, 1000.0, 0.001, "or_greater") var amplitude: float = 1.0

## 每秒采样频率。
@export_range(0.0, 240.0, 0.001, "or_greater") var frequency: float = 24.0

## 波形类型。
@export var waveform: Waveform = Waveform.NOISE

## 位移轴权重。
@export var position_axis: Vector3 = Vector3.ONE

## 旋转轴权重，单位度。
@export var rotation_axis_degrees: Vector3 = Vector3.ZERO

## 缩放偏移轴权重。返回值是叠加到基础 scale 上的偏移。
@export var scale_axis: Vector3 = Vector3.ZERO

## 包络曲线。为空时使用线性衰减；曲线值越高，当前采样越强。
@export var decay_curve: Curve = null

## 自定义波形曲线。仅在 waveform 为 CURVE 时使用，曲线值 0.5 表示零偏移。
@export var wave_curve: Curve = null

## 确定性采样种子。
@export var seed: int = 1

## 可组合反馈轨道。为空时使用兼容的单波形字段。
@export var tracks: Array[GFShakeTrackBase] = []


# --- 公共方法 ---

## 获取有效持续时间。
## @return 持续时间，最小为 0。
func get_duration_seconds() -> float:
	return maxf(duration_seconds, 0.0)


## 按时间采样反馈偏移。
## @param elapsed_seconds: 已经过的秒数。
## @param strength: 本次播放强度倍率。
## @param phase_offset: 相位偏移，用于同一预设多次播放时错开采样。
## @return 采样结果字典。
func sample(elapsed_seconds: float, strength: float = 1.0, phase_offset: float = 0.0) -> Dictionary:
	var duration := maxf(duration_seconds, 0.0001)
	var progress := clampf(elapsed_seconds / duration, 0.0, 1.0)
	return sample_at_progress(progress, elapsed_seconds, strength, phase_offset)


## 按归一化进度采样反馈偏移。
## @param progress: 归一化进度，范围 0 到 1。
## @param elapsed_seconds: 已经过的秒数。
## @param strength: 本次播放强度倍率。
## @param phase_offset: 相位偏移。
## @return 采样结果字典。
func sample_at_progress(
	progress: float,
	elapsed_seconds: float,
	strength: float = 1.0,
	phase_offset: float = 0.0
) -> Dictionary:
	var normalized_progress := clampf(progress, 0.0, 1.0)
	if has_tracks():
		return _sample_tracks(normalized_progress, elapsed_seconds, strength, phase_offset)

	var intensity := amplitude * maxf(strength, 0.0) * _sample_envelope(normalized_progress)
	var wave_value := _sample_wave_vector(elapsed_seconds, normalized_progress, phase_offset) * intensity
	return {
		"position": Vector3(
			position_axis.x * wave_value.x,
			position_axis.y * wave_value.y,
			position_axis.z * wave_value.z
		),
		"rotation_degrees": Vector3(
			rotation_axis_degrees.x * wave_value.x,
			rotation_axis_degrees.y * wave_value.y,
			rotation_axis_degrees.z * wave_value.z
		),
		"scale": Vector3(
			scale_axis.x * wave_value.x,
			scale_axis.y * wave_value.y,
			scale_axis.z * wave_value.z
		),
		"intensity": intensity,
		"progress": normalized_progress,
	}


## 添加反馈轨道。
## @param track: 反馈轨道。
## @return 添加成功返回 true。
func add_track(track: GFShakeTrackBase) -> bool:
	if track == null:
		return false
	tracks.append(track)
	return true


## 清空反馈轨道。
func clear_tracks() -> void:
	tracks.clear()


## 检查是否存在有效轨道。
## @return 存在有效轨道返回 true。
func has_tracks() -> bool:
	for track: GFShakeTrackBase in tracks:
		if track != null and track.enabled:
			return true
	return false


## 创建空采样结果。
## @return 空采样结果字典。
static func zero_sample() -> Dictionary:
	return {
		"position": Vector3.ZERO,
		"rotation_degrees": Vector3.ZERO,
		"scale": Vector3.ZERO,
		"intensity": 0.0,
		"progress": 1.0,
	}


## 合并多个反馈采样。
## @param samples: 采样结果数组。
## @return 合并后的采样结果。
static func combine_samples(samples: Array[Dictionary]) -> Dictionary:
	var result := zero_sample()
	var max_intensity := 0.0
	var max_progress := 0.0
	for sample: Dictionary in samples:
		result["position"] = (result["position"] as Vector3) + (sample.get("position", Vector3.ZERO) as Vector3)
		result["rotation_degrees"] = (result["rotation_degrees"] as Vector3) + (sample.get("rotation_degrees", Vector3.ZERO) as Vector3)
		result["scale"] = (result["scale"] as Vector3) + (sample.get("scale", Vector3.ZERO) as Vector3)
		max_intensity = maxf(max_intensity, float(sample.get("intensity", 0.0)))
		max_progress = maxf(max_progress, float(sample.get("progress", 0.0)))
	result["intensity"] = max_intensity
	result["progress"] = max_progress
	return result


# --- 私有/辅助方法 ---

func _sample_envelope(progress: float) -> float:
	if decay_curve != null:
		return maxf(decay_curve.sample_baked(progress), 0.0)
	return 1.0 - progress


func _sample_tracks(
	progress: float,
	elapsed_seconds: float,
	strength: float,
	phase_offset: float
) -> Dictionary:
	var result := zero_sample()
	result["progress"] = progress
	for track: GFShakeTrackBase in tracks:
		if track == null or not track.enabled:
			continue
		var track_sample := track.sample(progress, elapsed_seconds, strength, phase_offset)
		result = GFShakeTrackBase.blend_sample(result, track_sample, track.blend_mode)
	result["progress"] = progress
	return result


func _sample_wave_vector(elapsed_seconds: float, progress: float, phase_offset: float) -> Vector3:
	match waveform:
		Waveform.SINE:
			var phase := (elapsed_seconds * maxf(frequency, 0.0) + phase_offset) * TAU
			return Vector3(
				sin(phase),
				sin(phase + TAU / 3.0),
				sin(phase + TAU * 2.0 / 3.0)
			)
		Waveform.RANDOM:
			var step := int(floor(elapsed_seconds * maxf(frequency, 1.0)))
			return Vector3(
				_hash_noise(step, seed + 11),
				_hash_noise(step, seed + 37),
				_hash_noise(step, seed + 73)
			)
		Waveform.CURVE:
			var curve_value := 0.5
			if wave_curve != null:
				curve_value = wave_curve.sample_baked(progress)
			var mapped := clampf(curve_value, 0.0, 1.0) * 2.0 - 1.0
			return Vector3(mapped, mapped, mapped)
		_:
			return _sample_noise_vector(elapsed_seconds)


func _sample_noise_vector(elapsed_seconds: float) -> Vector3:
	var sample_frequency := maxf(frequency, 1.0)
	var cursor := elapsed_seconds * sample_frequency
	var step := int(floor(cursor))
	var blend := smoothstep(0.0, 1.0, cursor - float(step))
	return Vector3(
		lerpf(_hash_noise(step, seed + 11), _hash_noise(step + 1, seed + 11), blend),
		lerpf(_hash_noise(step, seed + 37), _hash_noise(step + 1, seed + 37), blend),
		lerpf(_hash_noise(step, seed + 73), _hash_noise(step + 1, seed + 73), blend)
	)


func _hash_noise(step: int, salt: int) -> float:
	var value := int(step * 1103515245 + salt * 12345 + seed * 2654435761)
	value = value ^ (value >> 13)
	value = value * 1274126177
	value = value ^ (value >> 16)
	var normalized := float(value & 0x7fffffff) / float(0x7fffffff)
	return normalized * 2.0 - 1.0
