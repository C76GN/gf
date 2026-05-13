## GFAudioBackendCapability: 音频后端能力声明。
##
## 用布尔能力与元数据描述一个后端能处理哪些通用音频请求。
class_name GFAudioBackendCapability
extends Resource


# --- 导出变量 ---

## 是否支持 BGM。
@export var supports_bgm: bool = false

## 是否支持 SFX。
@export var supports_sfx: bool = false

## 是否支持环境音。
@export var supports_ambient: bool = false

## 是否支持空间音效。
@export var supports_spatial_sfx: bool = false

## 是否支持资源化事件。
@export var supports_events: bool = false

## 是否支持参数写入。
@export var supports_parameters: bool = false

## 是否支持状态写入。
@export var supports_states: bool = false

## 是否支持开关写入。
@export var supports_switches: bool = false

## 是否支持监听器。
@export var supports_listeners: bool = false

## 是否支持异步加载或卸载。
@export var supports_async_loading: bool = false

## 可选元数据，供项目层或调试面板展示。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 检查能力是否存在。
## @param capability_id: 能力标识。
## @return 支持返回 true。
func has_capability(capability_id: StringName) -> bool:
	match capability_id:
		&"bgm":
			return supports_bgm
		&"sfx":
			return supports_sfx
		&"ambient":
			return supports_ambient
		&"spatial_sfx":
			return supports_spatial_sfx
		&"events":
			return supports_events
		&"parameters":
			return supports_parameters
		&"states":
			return supports_states
		&"switches":
			return supports_switches
		&"listeners":
			return supports_listeners
		&"async_loading":
			return supports_async_loading
		_:
			return false


## 创建同内容拷贝。
## @return 新能力声明。
func duplicate_capability() -> GFAudioBackendCapability:
	var capability := GFAudioBackendCapability.new()
	capability.supports_bgm = supports_bgm
	capability.supports_sfx = supports_sfx
	capability.supports_ambient = supports_ambient
	capability.supports_spatial_sfx = supports_spatial_sfx
	capability.supports_events = supports_events
	capability.supports_parameters = supports_parameters
	capability.supports_states = supports_states
	capability.supports_switches = supports_switches
	capability.supports_listeners = supports_listeners
	capability.supports_async_loading = supports_async_loading
	capability.metadata = metadata.duplicate(true)
	return capability


## 转换为字典。
## @return 能力字典。
func to_dictionary() -> Dictionary:
	return {
		"bgm": supports_bgm,
		"sfx": supports_sfx,
		"ambient": supports_ambient,
		"spatial_sfx": supports_spatial_sfx,
		"events": supports_events,
		"parameters": supports_parameters,
		"states": supports_states,
		"switches": supports_switches,
		"listeners": supports_listeners,
		"async_loading": supports_async_loading,
		"metadata": metadata.duplicate(true),
	}
