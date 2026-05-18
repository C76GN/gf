## GFAudioBackend: GFAudioUtility 的可插拔音频后端协议。
##
## 默认实现不处理任何请求。项目或扩展可继承它，把部分音频事件转交给
## 外部中间件、平台接口或自定义混音系统；未声明可处理的请求会回退到 Godot 默认播放器。
class_name GFAudioBackend
extends RefCounted


# --- 公共变量 ---

## 后端能力声明。
var capabilities: GFAudioBackendCapability = GFAudioBackendCapability.new()


# --- 私有变量 ---

var _host_ref: WeakRef = null


# --- 公共方法 ---

## 绑定宿主音频工具。
## @param host: GFAudioUtility 实例。
func setup(host: Object) -> void:
	_host_ref = weakref(host) if host != null else null


## 释放后端状态。
func dispose() -> void:
	_host_ref = null


## 获取宿主音频工具。
## @return 宿主对象；不存在时返回 null。
func get_host() -> Object:
	return _host_ref.get_ref() if _host_ref != null else null


## 获取后端能力声明副本。
## @return 后端能力声明。
func get_capabilities() -> GFAudioBackendCapability:
	return capabilities.duplicate_capability() if capabilities != null else GFAudioBackendCapability.new()


## 检查后端是否声明了指定能力。
## @param capability_id: 能力标识。
## @return 支持返回 true。
func has_capability(capability_id: StringName) -> bool:
	return capabilities != null and capabilities.has_capability(capability_id)


## 判断后端是否可处理指定资源路径。
## @param _path: 音频资源路径或后端事件路径。
## @param _channel: 通道标识，如 bgm、sfx、ambient。
## @param _context: 请求上下文。
## @return 可处理时返回 true。
func can_handle_path(_path: String, _channel: StringName, _context: Dictionary = {}) -> bool:
	return false


## 判断后端是否可处理指定音频片段。
## @param _clip: 音频片段配置。
## @param _channel: 通道标识，如 bgm、sfx、ambient。
## @param _context: 请求上下文。
## @return 可处理时返回 true。
func can_handle_clip(_clip: GFAudioClip, _channel: StringName, _context: Dictionary = {}) -> bool:
	return false


## 播放 BGM 路径。
## @param _path: 音频资源路径或后端事件路径。
## @param _options: 请求选项。
## @return 已处理返回 true。
func play_bgm_path(_path: String, _options: Dictionary = {}) -> bool:
	return false


## 播放 BGM Clip。
## @param _clip: 音频片段配置。
## @param _options: 请求选项。
## @return 已处理返回 true。
func play_bgm_clip(_clip: GFAudioClip, _options: Dictionary = {}) -> bool:
	return false


## 停止 BGM。
## @param _fade_seconds: 淡出秒数。
## @return 已处理返回 true。
func stop_bgm(_fade_seconds: float = 0.0) -> bool:
	return false


## 暂停 BGM。
## @param _fade_seconds: 淡出到暂停的秒数。
## @return 已处理返回 true。
func pause_bgm(_fade_seconds: float = 0.0) -> bool:
	return false


## 恢复 BGM。
## @param _from_position: 大于等于 0 时从指定秒数恢复。
## @param _fade_seconds: 淡入秒数。
## @return 已处理返回 true。
func resume_bgm(_from_position: float = -1.0, _fade_seconds: float = 0.0) -> bool:
	return false


## 跳转当前 BGM 播放位置。
## @param _position_seconds: 目标秒数。
## @return 已处理返回 true。
func seek_bgm(_position_seconds: float) -> bool:
	return false


## 获取当前 BGM 播放位置。
## @return 播放秒数；负数表示后端不处理该查询。
func get_bgm_playback_position() -> float:
	return -1.0


## 查询 BGM 是否暂停。
## @return 已暂停返回 true。
func is_bgm_paused() -> bool:
	return false


## 播放环境音路径。
## @param _path: 音频资源路径或后端事件路径。
## @param _channel: 环境音通道。
## @param _options: 请求选项。
## @return 已处理返回 true。
func play_ambient_path(_path: String, _channel: StringName = &"default", _options: Dictionary = {}) -> bool:
	return false


## 播放环境音 Clip。
## @param _clip: 音频片段配置。
## @param _channel: 环境音通道。
## @param _options: 请求选项。
## @return 已处理返回 true。
func play_ambient_clip(_clip: GFAudioClip, _channel: StringName = &"default", _options: Dictionary = {}) -> bool:
	return false


## 停止环境音通道。
## @param _channel: 环境音通道。
## @param _fade_seconds: 淡出秒数。
## @return 已处理返回 true。
func stop_ambient(_channel: StringName = &"default", _fade_seconds: float = 0.0) -> bool:
	return false


## 停止全部环境音。
## @param _fade_seconds: 淡出秒数。
## @return 已处理返回 true。
func stop_all_ambient(_fade_seconds: float = 0.0) -> bool:
	return false


## 查询环境音通道是否播放中。
## @param _channel: 环境音通道。
## @return 后端通道正在播放时返回 true。
func is_ambient_playing(_channel: StringName = &"default") -> bool:
	return false


## 播放 SFX 路径。
## @param _path: 音频资源路径或后端事件路径。
## @param _options: 请求选项。
## @return 控制句柄；未处理返回 null。
func play_sfx_path(_path: String, _options: Dictionary = {}) -> GFAudioEmitterHandle:
	return null


## 播放 SFX Clip。
## @param _clip: 音频片段配置。
## @param _options: 请求选项。
## @return 控制句柄；未处理返回 null。
func play_sfx_clip(_clip: GFAudioClip, _options: Dictionary = {}) -> GFAudioEmitterHandle:
	return null


## 停止全部 SFX。
## @param _fade_seconds: 淡出秒数。
## @return 已处理返回 true。
func stop_all_sfx(_fade_seconds: float = 0.0) -> bool:
	return false


## 播放空间 SFX Clip。
## @param _clip: 音频片段配置。
## @param _source: 2D 或 3D 声源节点。
## @param _follow_source: 是否跟随声源。
## @param _options: 请求选项。
## @return 控制句柄；未处理返回 null。
func play_spatial_sfx_clip(
	_clip: GFAudioClip,
	_source: Node,
	_follow_source: bool = false,
	_options: Dictionary = {}
) -> GFAudioEmitterHandle:
	return null


## 判断后端是否可处理资源化音频事件。
## @param _event: 音频事件。
## @param _options: 请求选项。
## @return 可处理时返回 true。
func can_handle_event(_event: GFAudioEvent, _options: Dictionary = {}) -> bool:
	return false


## 发布资源化音频事件。
## @param _event: 音频事件。
## @param _options: 请求选项。
## @return 控制句柄；未处理返回 null。
func post_event(_event: GFAudioEvent, _options: Dictionary = {}) -> GFAudioEmitterHandle:
	return null


## 设置音频参数。
## @param _parameter: 参数请求。
## @return 已处理返回 true。
func set_parameter(_parameter: GFAudioParameter) -> bool:
	return false


## 设置音频状态。
## @param _state: 状态请求。
## @return 已处理返回 true。
func set_state(_state: GFAudioState) -> bool:
	return false


## 设置音频开关。
## @param _switch: 开关请求。
## @return 已处理返回 true。
func set_switch(_switch: GFAudioSwitch) -> bool:
	return false


## 设置总线音量。
## @param _bus_name: 总线名或后端通道名。
## @param _volume_linear: 线性音量。
## @return 已处理返回 true。
func set_bus_volume(_bus_name: String, _volume_linear: float) -> bool:
	return false


## 获取总线音量。返回负数表示未处理。
## @param _bus_name: 总线名或后端通道名。
## @return 线性音量；负数表示后端不处理该总线。
func get_bus_volume(_bus_name: String) -> float:
	return -1.0


## 获取后端调试快照。
## @return 调试数据。
func get_debug_snapshot() -> Dictionary:
	return {}
