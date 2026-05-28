# 音频后端与事件资源

需要接入外部音频中间件、平台事件音频或项目自定义混音系统时，可以继承 `GFAudioBackend` 并通过 `set_audio_backend()` 注入。

## 后端接入

后端只有在 `can_handle_path()` 或 `can_handle_clip()` 明确返回 `true` 时才接管请求；播放失败或不支持的请求会继续走默认 Godot 播放路径。

```gdscript
class_name ProjectAudioBackend
extends GFAudioBackend

func can_handle_path(path: String, channel: StringName, _context: Dictionary = {}) -> bool:
	return channel == &"sfx" and path.begins_with("event://")

func play_sfx_path(path: String, options: Dictionary = {}) -> GFAudioEmitterHandle:
	# 项目层把 path 映射到自己的音频事件。
	return GFAudioEmitterHandle.new(null, Callable(), &"external", options)

audio.set_audio_backend(ProjectAudioBackend.new())
audio.play_sfx("event://ui/confirm")
```

`GFAudioBackend` 是协议层，不内置任何第三方 SDK、事件命名或业务状态。后端可选择只处理部分 BGM、BGM transport、SFX、stop-all SFX、环境音、空间音效、总线音量、总线静音、总线效果属性或混音快照，其余请求保持默认行为。

`GFAudioUtility.get_debug_snapshot()` 会把后端的 `get_debug_snapshot()` 放进 `backend_snapshot`，并提供 `bgm_paused`、`bgm_position`、`current_bgm_loop`、`active_sfx_count` 和 `active_spatial_sfx_count` 等字段，便于诊断面板统一展示。

## 能力声明

后端可以通过 `GFAudioBackendCapability` 声明支持 BGM、SFX、环境音、空间音效、资源化事件、参数、状态、开关、监听器或异步加载等能力。快照中的 `backend_capabilities` 可供调试面板或项目工具展示。

## 事件资源

需要把音频请求资源化时，可使用 `GFAudioEvent`、`GFAudioParameter`、`GFAudioState` 和 `GFAudioSwitch`，再通过 `post_audio_event()`、`set_audio_parameter()`、`set_audio_state()` 或 `set_audio_switch()` 交给当前后端。

默认 Godot 播放路径只处理通用 BGM/SFX/环境音，不解释外部后端的项目含义。编辑器选择器或构建工具需要列出外部音频 ID 时，可实现或填充 `GFAudioCatalogProvider`。

```gdscript
var event := GFAudioEvent.new()
event.event_id = &"ui_confirm"
event.channel = &"sfx"
audio.post_audio_event(event)

var parameter := GFAudioParameter.new()
parameter.parameter_id = &"intensity"
parameter.value = 0.75
audio.set_audio_parameter(parameter)
```
