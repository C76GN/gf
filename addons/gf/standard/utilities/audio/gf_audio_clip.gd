## GFAudioClip: 可资源化的音频播放配置。
##
## 支持直接引用 `AudioStream`，也支持提供资源路径交给 `GFAudioUtility`
## 按需加载。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFAudioClip
extends Resource


# --- 导出变量 ---

## 音频资源路径。`stream` 为空时使用该路径加载。
## [br]
## @api public
@export_file("*.wav", "*.ogg", "*.mp3", "*.opus") var path: String = ""

## 音频流资源。
## [br]
## @api public
@export var stream: AudioStream

## 音频总线。为空时由播放方法使用默认 BGM/SFX 总线。
## [br]
## @api public
@export var bus_name: String = ""

## 播放音量，单位 dB。
## [br]
## @api public
@export_range(-80.0, 24.0, 0.1) var volume_db: float = 0.0

## 播放音高。
## [br]
## @api public
@export_range(0.01, 4.0, 0.01) var pitch_scale: float = 1.0

## 在同一片段 ID 存在多个候选时的抽取权重；小于等于 0 表示不参与随机抽取。
## [br]
## @api public
@export_range(0.0, 1000.0, 0.01) var weight: float = 1.0

## 播放音高随机下限，会乘到 pitch_scale 上。
## [br]
## @api public
@export_range(0.01, 4.0, 0.01) var pitch_random_min: float = 1.0

## 播放音高随机上限，会乘到 pitch_scale 上。
## [br]
## @api public
@export_range(0.01, 4.0, 0.01) var pitch_random_max: float = 1.0

## 可选空间播放设置。为空时空间 SFX 使用 Godot 播放器默认空间参数。
## [br]
## @api public
## [br]
## @schema spatial_settings: GFAudioSpatialSettings or compatible Resource with apply_to_2d/apply_to_3d methods.
@export var spatial_settings: Resource = null


# --- 公共方法 ---

## 检查该配置是否有可播放来源。
## [br]
## @api public
## [br]
## @return: 有 stream 或 path 时返回 true。
func has_source() -> bool:
	return stream != null or not path.is_empty()


## 解析实际总线名称。
## [br]
## @api public
## [br]
## @param default_bus: 默认总线。
## [br]
## @return: 实际总线名称。
func resolve_bus(default_bus: String) -> String:
	if bus_name.is_empty():
		return default_bus
	return bus_name


## 解析本次播放使用的实际音高。
## [br]
## @api public
## [br]
## @param rng: 可选随机数生成器；为空时使用确定性的 pitch_scale。
## [br]
## @return: 实际播放音高。
func resolve_pitch(rng: RandomNumberGenerator = null) -> float:
	var min_pitch: float = clampf(pitch_random_min, 0.01, 4.0)
	var max_pitch: float = clampf(pitch_random_max, 0.01, 4.0)
	if min_pitch > max_pitch:
		var swapped: float = min_pitch
		min_pitch = max_pitch
		max_pitch = swapped
	if rng == null:
		return clampf(pitch_scale, 0.01, 16.0)
	var random_scale: float = 1.0
	if not is_equal_approx(min_pitch, max_pitch):
		random_scale = rng.randf_range(min_pitch, max_pitch)
	else:
		random_scale = min_pitch
	return clampf(pitch_scale * random_scale, 0.01, 16.0)
