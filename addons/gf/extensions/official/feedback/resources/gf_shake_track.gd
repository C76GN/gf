## GFShakeTrack: 通用反馈采样轨道。
##
## 描述一段可组合的反馈偏移轨道，供 GFShakePreset 混合采样。
## 轨道只输出通用 position、rotation_degrees 和 scale 偏移，不绑定目标节点或业务事件。
class_name GFShakeTrack
extends Resource


# --- 枚举 ---

## 反馈采样波形。
enum Waveform {
	## 正弦波，适合可预期的摆动。
	SINE,
	## 逐步随机值，适合短促冲击。
	RANDOM,
	## 平滑随机值，适合持续扰动。
	NOISE,
	## 使用 wave_curve 采样，曲线值 0.5 表示零偏移。
	CURVE,
}

## 轨道混合模式。
enum BlendMode {
	## 叠加到已有采样上。
	ADD,
	## 覆盖已有采样。
	OVERRIDE,
	## 按分量相乘。
	MULTIPLY,
	## 从已有采样中减去当前轨道。
	SUBTRACT,
	## 与已有采样求平均。
	AVERAGE,
	## 逐分量取最大值。
	MAX,
	## 逐分量取最小值。
	MIN,
}


# --- 导出变量 ---

## 是否启用该轨道。
@export var enabled: bool = true

## 轨道混合模式。
@export var blend_mode: BlendMode = BlendMode.ADD

## 轨道采样波形。
@export var waveform: Waveform = Waveform.NOISE

## 轨道开始进度，范围 0 到 1。
@export_range(0.0, 1.0, 0.001) var start_progress: float = 0.0

## 轨道结束进度，范围 0 到 1。
@export_range(0.0, 1.0, 0.001) var end_progress: float = 1.0

## 轨道振幅倍率。
@export_range(0.0, 1000.0, 0.001, "or_greater") var amplitude: float = 1.0

## 每秒采样频率。
@export_range(0.0, 240.0, 0.001, "or_greater") var frequency: float = 24.0

## 位移轴权重。
@export var position_axis: Vector3 = Vector3.ONE

## 旋转轴权重，单位度。
@export var rotation_axis_degrees: Vector3 = Vector3.ZERO

## 缩放偏移轴权重。
@export var scale_axis: Vector3 = Vector3.ZERO

## 轨道包络曲线。为空时使用线性衰减。
@export var envelope_curve: Curve = null

## 自定义波形曲线。仅在 waveform 为 CURVE 时使用。
@export var wave_curve: Curve = null

## 确定性采样种子。
@export var seed: int = 1

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 按预设归一化进度采样轨道。
## @param preset_progress: 预设归一化进度，范围 0 到 1。
## @param elapsed_seconds: 预设已播放秒数。
## @param strength: 播放强度倍率。
## @param phase_offset: 相位偏移。
## @return 采样结果字典。
func sample(
	preset_progress: float,
	elapsed_seconds: float,
	strength: float = 1.0,
	phase_offset: float = 0.0
) -> Dictionary:
	if not enabled:
		return zero_sample()

	var range_start := clampf(start_progress, 0.0, 1.0)
	var range_end := clampf(end_progress, range_start, 1.0)
	var clamped_progress := clampf(preset_progress, 0.0, 1.0)
	if clamped_progress < range_start or clamped_progress > range_end:
		return zero_sample()

	var local_progress := 1.0
	if range_end > range_start:
		local_progress = (clamped_progress - range_start) / (range_end - range_start)

	var intensity := amplitude * maxf(strength, 0.0) * _sample_envelope(local_progress)
	var wave_value := _sample_wave_vector(elapsed_seconds, local_progress, phase_offset) * intensity
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
		"progress": clamped_progress,
		"track_progress": local_progress,
		"metadata": metadata.duplicate(true),
	}


## 创建空采样结果。
## @return 空采样结果字典。
static func zero_sample() -> Dictionary:
	return {
		"position": Vector3.ZERO,
		"rotation_degrees": Vector3.ZERO,
		"scale": Vector3.ZERO,
		"intensity": 0.0,
		"progress": 1.0,
		"track_progress": 1.0,
		"metadata": {},
	}


## 将轨道采样混合到当前采样。
## @param base_sample: 当前合成采样。
## @param track_sample: 轨道采样。
## @param mode: 混合模式。
## @return 合成后的采样。
static func blend_sample(base_sample: Dictionary, track_sample: Dictionary, mode: BlendMode) -> Dictionary:
	var result := _normalize_sample(base_sample)
	var next := _normalize_sample(track_sample)
	match mode:
		BlendMode.OVERRIDE:
			result["position"] = next["position"]
			result["rotation_degrees"] = next["rotation_degrees"]
			result["scale"] = next["scale"]
		BlendMode.MULTIPLY:
			result["position"] = (result["position"] as Vector3) * (next["position"] as Vector3)
			result["rotation_degrees"] = (result["rotation_degrees"] as Vector3) * (next["rotation_degrees"] as Vector3)
			result["scale"] = (result["scale"] as Vector3) * (next["scale"] as Vector3)
		BlendMode.SUBTRACT:
			result["position"] = (result["position"] as Vector3) - (next["position"] as Vector3)
			result["rotation_degrees"] = (result["rotation_degrees"] as Vector3) - (next["rotation_degrees"] as Vector3)
			result["scale"] = (result["scale"] as Vector3) - (next["scale"] as Vector3)
		BlendMode.AVERAGE:
			result["position"] = ((result["position"] as Vector3) + (next["position"] as Vector3)) * 0.5
			result["rotation_degrees"] = ((result["rotation_degrees"] as Vector3) + (next["rotation_degrees"] as Vector3)) * 0.5
			result["scale"] = ((result["scale"] as Vector3) + (next["scale"] as Vector3)) * 0.5
		BlendMode.MAX:
			result["position"] = _vector3_max(result["position"] as Vector3, next["position"] as Vector3)
			result["rotation_degrees"] = _vector3_max(result["rotation_degrees"] as Vector3, next["rotation_degrees"] as Vector3)
			result["scale"] = _vector3_max(result["scale"] as Vector3, next["scale"] as Vector3)
		BlendMode.MIN:
			result["position"] = _vector3_min(result["position"] as Vector3, next["position"] as Vector3)
			result["rotation_degrees"] = _vector3_min(result["rotation_degrees"] as Vector3, next["rotation_degrees"] as Vector3)
			result["scale"] = _vector3_min(result["scale"] as Vector3, next["scale"] as Vector3)
		_:
			result["position"] = (result["position"] as Vector3) + (next["position"] as Vector3)
			result["rotation_degrees"] = (result["rotation_degrees"] as Vector3) + (next["rotation_degrees"] as Vector3)
			result["scale"] = (result["scale"] as Vector3) + (next["scale"] as Vector3)

	result["intensity"] = maxf(float(result.get("intensity", 0.0)), float(next.get("intensity", 0.0)))
	result["progress"] = maxf(float(result.get("progress", 0.0)), float(next.get("progress", 0.0)))
	return result


# --- 私有/辅助方法 ---

static func _normalize_sample(sample: Dictionary) -> Dictionary:
	return {
		"position": sample.get("position", Vector3.ZERO) as Vector3,
		"rotation_degrees": sample.get("rotation_degrees", Vector3.ZERO) as Vector3,
		"scale": sample.get("scale", Vector3.ZERO) as Vector3,
		"intensity": float(sample.get("intensity", 0.0)),
		"progress": float(sample.get("progress", 0.0)),
	}


static func _vector3_max(left: Vector3, right: Vector3) -> Vector3:
	return Vector3(
		maxf(left.x, right.x),
		maxf(left.y, right.y),
		maxf(left.z, right.z)
	)


static func _vector3_min(left: Vector3, right: Vector3) -> Vector3:
	return Vector3(
		minf(left.x, right.x),
		minf(left.y, right.y),
		minf(left.z, right.z)
	)


func _sample_envelope(progress: float) -> float:
	if envelope_curve != null:
		return maxf(envelope_curve.sample_baked(progress), 0.0)
	return 1.0 - progress


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
