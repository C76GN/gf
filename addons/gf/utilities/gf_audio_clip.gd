## GFAudioClip: 可资源化的音频播放配置。
##
## 支持直接引用 `AudioStream`，也支持提供资源路径交给 `GFAudioUtility`
## 按需加载。
class_name GFAudioClip
extends Resource


# --- 导出变量 ---

## 音频资源路径。`stream` 为空时使用该路径加载。
@export_file("*.wav", "*.ogg", "*.mp3") var path: String = ""

## 音频流资源。
@export var stream: AudioStream

## 音频总线。为空时由播放方法使用默认 BGM/SFX 总线。
@export var bus_name: String = ""

## 播放音量，单位 dB。
@export_range(-80.0, 24.0, 0.1) var volume_db: float = 0.0

## 播放音高。
@export_range(0.01, 4.0, 0.01) var pitch_scale: float = 1.0


# --- 公共方法 ---

## 检查该配置是否有可播放来源。
## @return 有 stream 或 path 时返回 true。
func has_source() -> bool:
	return stream != null or not path.is_empty()


## 解析实际总线名称。
## @param default_bus: 默认总线。
## @return 实际总线名称。
func resolve_bus(default_bus: String) -> String:
	if bus_name.is_empty():
		return default_bus
	return bus_name

