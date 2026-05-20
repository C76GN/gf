# 音频管理

`GFAudioUtility` 提供背景音乐、音效、环境音、音频片段、播放历史和可插拔后端协议。

## 全局音频管理器 (`GFAudioUtility`)

**应用场景：** 处理 BGM 切歌、音量总线，以及在 SFX 播放时自动管理 `AudioStreamPlayer` 的创建、复用和释放。

**如何使用：**
```gdscript
var audio := Gf.get_utility(GFAudioUtility) as GFAudioUtility

# 异步无阻加载并播放背景音乐 (放入 BGM Bus)
audio.play_bgm("res://audio/bgm/battle.ogg")

# 播放音效 (放入 SFX Bus)
audio.play_sfx("res://audio/sfx/hit.wav")

# 也可以使用资源化音频片段和集合
var clip := GFAudioClip.new()
clip.stream = preload("res://audio/sfx/confirm.wav")
clip.bus_name = "SFX"
clip.volume_db = -3.0
audio.play_sfx_clip(clip)

var handle := audio.play_sfx_clip_handle(clip)
if handle != null:
	handle.bind_to_owner(self)
	handle.fade_to(-10.0, 0.2)
	handle.stop(0.1)

var source_2d := $AudioAnchor as Node2D
audio.play_sfx_clip_2d(clip, source_2d, true) # 需要跟随声源时启用 follow_source

var bank := GFAudioBank.new()
bank.set_clip(&"confirm", clip)
audio.play_sfx_from_bank(bank, &"confirm")

var alternate := GFAudioClip.new()
alternate.stream = preload("res://audio/sfx/confirm_alt.wav")
alternate.weight = 2.0
bank.set_clips(&"ui+confirm", [clip, alternate])
audio.register_audio_bank(&"ui", bank)
audio.play_sfx_event(&"ui+confirm+primary", &"ui") # 可逐级回退到 ui+confirm

# BGM 可按需淡入淡出，并可查询最近播放历史
audio.play_bgm("res://audio/bgm/explore.ogg", 0.5)
audio.play_bgm_with_options("res://audio/bgm/boss.ogg", {
	"crossfade_seconds": 0.5,
	"loop": true,
})
audio.pause_bgm(0.2)
var bgm_position := audio.get_bgm_playback_position()
audio.resume_bgm(bgm_position, 0.2)
audio.seek_bgm(12.0)
print(audio.get_bgm_history())

audio.bgm_finished.connect(func(history_key: String) -> void:
	print("BGM finished: ", history_key)
)

# 环境音按 channel 独立播放和停止
audio.play_ambient("res://audio/ambient/rain.ogg", &"rain")
audio.stop_ambient(&"rain", 0.25)

# 设置总线音量 (0.0~1.0 标准化线性音量)
audio.set_bus_volume("SFX", 0.8)
audio.set_bus_volume("BGM", 0.5)

# 限制同时播放的 SFX 数量；小于等于 0 表示不限制
audio.max_sfx_players = 24
audio.sfx_overflow_policy = GFAudioUtility.SFXOverflowPolicy.STOP_OLDEST
audio.stop_all_sfx(0.1)
```

`GFAudioUtility` 会优先借助 `GFAssetUtility` 异步加载音频资源；未注册时退回同步 `load()`。SFX 播放会在存在 `GFObjectPoolUtility` 时复用池化 `AudioStreamPlayer`，未注册对象池时则创建普通播放器并在播放结束后释放。`GFAudioEmitterHandle.stop()` 即使在异步资源返回前调用，也会记录停止请求；迟到的 SFX 资源不会再创建播放器。`stop_all_sfx()` 会递增 SFX 生命周期序号，停止普通 SFX 和 2D/3D 空间 SFX，并阻止尚未返回的异步 SFX 继续落地。池化播放器归还前会重置 stream、bus、音量和 pitch，避免上一次播放设置污染下一次请求。BGM 和环境音使用独立播放器，异步加载回调带有请求序号，较旧请求完成得更晚时不会覆盖新的播放请求。

BGM transport 接口面向暂停菜单、剧情演出、音量淡入淡出和进度恢复：`pause_bgm()` / `resume_bgm()` 使用 Godot `AudioStreamPlayer.stream_paused` 保留当前位置，`seek_bgm()` 和 `get_bgm_playback_position()` 用于显式跳转和记录。`play_bgm_with_options()` 支持 `crossfade_seconds`、`history_key`、`bus_name`、`volume_db`、`pitch_scale` 与可选 `loop` 覆盖；只有显式传入 `loop` 时才尝试复制当前 `AudioStream` 并设置循环属性，避免修改共享 Resource 或改变默认循环语义。当前 BGM 自然结束时会发出 `bgm_finished(history_key)`。

需要接入外部音频中间件、平台事件音频或项目自定义混音系统时，继承 `GFAudioBackend` 并通过 `set_audio_backend()` 注入。后端只有在 `can_handle_path()` 或 `can_handle_clip()` 明确返回 `true` 时才接管请求；播放失败或不支持的请求会继续走默认 Godot 播放路径：

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

`GFAudioBackend` 是协议层，不内置任何第三方 SDK、事件命名或业务混音快照。后端可选择只处理部分 BGM、BGM transport、SFX、stop-all SFX、环境音、空间音效或总线音量，其余请求保持默认行为；`GFAudioUtility.get_debug_snapshot()` 会把后端的 `get_debug_snapshot()` 放进 `backend_snapshot`，并提供 `bgm_paused`、`bgm_position`、`current_bgm_loop`、`active_sfx_count` 和 `active_spatial_sfx_count` 等字段，便于诊断面板统一展示。

后端可以通过 `GFAudioBackendCapability` 声明支持 BGM、SFX、环境音、空间音效、资源化事件、参数、状态、开关、监听器或异步加载等能力；快照中的 `backend_capabilities` 可供调试面板或项目工具展示。需要把音频请求资源化时，可使用 `GFAudioEvent`、`GFAudioParameter`、`GFAudioState` 和 `GFAudioSwitch`，再通过 `post_audio_event()`、`set_audio_parameter()`、`set_audio_state()` 或 `set_audio_switch()` 交给当前后端；默认 Godot 播放路径只处理通用 BGM/SFX/环境音，不解释外部后端的项目含义。编辑器选择器或构建工具需要列出外部音频 ID 时，可实现或填充 `GFAudioCatalogProvider`：

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

默认总线名为 `BGM` / `SFX`，找不到时会回退到 `Master` 并按总线名只警告一次。`set_bus_volume(bus, 0.0)` 会把总线静音并让 `get_bus_volume()` 返回 `0.0`；再次设置大于 `0.0` 的值会解除静音。`play_bgm("", crossfade_seconds)` 可按同一淡出参数停止当前 BGM。`GFAudioClip` 可描述 stream/path、bus、音量、基础 pitch、候选权重和本次播放 pitch 随机范围；`GFAudioBank` 的同一 ID 可保存单个片段或多个候选，并支持用 `fallback_separator` 做分层事件 ID 回退。需要编辑器校验、构建前检查或调试 fallback 时，可用 `resolve_clip()` 获取请求 ID、最终命中 ID、是否使用 fallback、尝试过的 ID 和命中的 clip，用 `validate_bank()` 检查空 ID、无效候选、缺失音频源和可选资源路径存在性。

`GFAudioBankTools` 提供纯配置层的扫描、导入和播放前校验辅助，可用于编辑器按钮、构建脚本或项目自己的音频表生成流程。它不会创建全局音频单例，也不会改变 `GFAudioUtility` 的播放路径：

```gdscript
var paths := GFAudioBankTools.scan_audio_paths("res://audio", {
	"include_addons": false,
	"max_scan_depth": 32,
	"max_audio_paths": 10000,
})

var bank := GFAudioBankTools.create_bank_from_paths(paths, {
	"id_mode": "relative_path",
	"base_path": "res://audio",
	"path_separator": "+",
	"bus_name": "SFX",
})

var report := GFAudioBankTools.validate_bank_playback(bank, {
	"check_resource_exists": true,
	"check_bus_exists": true,
})
print(report.make_summary("Audio bank"))

# 扫描并同步到已有 bank，适合编辑器按钮或构建脚本。
var import_report := GFAudioBankTools.sync_bank_from_scan(bank, "res://audio", {
	"id_mode": "relative_path",
	"base_path": "res://audio",
	"overwrite": false,
	"bus_name": "SFX",
})
```

选中 `GFAudioBank` 资源时，Inspector 的验证入口也会使用同一套工具检查音频路径、候选片段和 bus 名；同一面板还提供扫描目录、选择 ID 生成方式、是否覆盖和默认 bus 的轻量导入入口。音频扫描默认限制递归深度和路径数量，项目构建脚本可按音频目录规模调高 `max_scan_depth` / `max_audio_paths`。推荐把 `GFAudioBankTools` 用作生成和校验配置的工具；声音优先级、混音快照、场景预加载策略和具体事件命名仍由项目层决定。

默认扫描与 `GFAudioClip.path` 文件选择器保持同一组常见 Godot 音频扩展名：`wav`、`ogg`、`mp3` 与 `opus`。项目需要额外扩展名时，可以在扫描选项中传入 `extensions`，但是否能被 `ResourceLoader` 实际加载仍由 Godot 导入器和项目资源管线决定。

`register_audio_bank()` 后可用 `play_bgm_event()`、`play_ambient_event()`、`play_sfx_event()` 按稳定事件 ID 播放；场景或 UI 想临时拥有一组音频事件时，可使用 `GFAudioBankMounter` 在 ready/exit 时自动注册、恢复或卸载 bank。同一 `bank_id` 的多个挂载由 `GFAudioUtility` 按栈管理，场景或 UI 交错退出时，较早退出的下层挂载不会覆盖仍处于顶层的 bank；需要手动控制同类逻辑时，可使用 `mount_audio_bank()` / `unmount_audio_bank()`。需要主动停止、淡出或读取本次 SFX/空间音效状态时，使用 `play_sfx_handle()`、`play_sfx_clip_handle()`、`play_sfx_event_handle()` 或 2D/3D 对应 handle 方法取得 `GFAudioEmitterHandle`；环境音通道可用 `get_ambient_handle(channel)` 获取当前播放器句柄。句柄只管理底层播放器的停止、淡出、音量、音高和可选 owner 生命周期绑定，不替项目决定混音快照、声音优先级或业务生命周期。`play_sfx_clip_2d()` / `play_sfx_clip_3d()` 和对应 event 方法默认只在当前位置创建空间播放器；传入 `follow_source = true` 时，播放器会挂到声源节点下并随声源移动。复杂混音、音频快照、距离规则、碰撞触发和平台音频权限仍属于项目层。
