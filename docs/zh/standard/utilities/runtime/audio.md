# 音频管理

`GFAudioUtility` 提供背景音乐、音效、环境音、音频片段、播放历史和可插拔后端协议。

## 全局音频管理器 (`GFAudioUtility`)

**应用场景：** 处理 BGM 切歌、音量总线，以及在 SFX 播放时自动处理 `AudioStreamPlayer` 的基于 `GFObjectPoolUtility` 的池化复用，减少频繁实例化带来的卡顿。

**如何使用：**
```gdscript
var audio := Gf.get_utility(GFAudioUtility) as GFAudioUtility

# 异步无阻加载并播放背景音乐 (放入 BGM Bus)
audio.play_bgm("res://audio/bgm/battle.ogg")

# 从池子里分配一个播放器来播放音效 (放入 SFX Bus)
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
print(audio.get_bgm_history())

# 环境音按 channel 独立播放和停止
audio.play_ambient("res://audio/ambient/rain.ogg", &"rain")
audio.stop_ambient(&"rain", 0.25)

# 设置总线音量 (0.0~1.0 标准化线性音量)
audio.set_bus_volume("SFX", 0.8)
audio.set_bus_volume("BGM", 0.5)

# 限制同时播放的 SFX 数量；小于等于 0 表示不限制
audio.max_sfx_players = 24
audio.sfx_overflow_policy = GFAudioUtility.SFXOverflowPolicy.STOP_OLDEST
```

`GFAudioUtility` 会优先借助 `GFAssetUtility` 异步加载音频资源；未注册时退回同步 `load()`。SFX 播放依赖 `GFObjectPoolUtility` 分配 `AudioStreamPlayer`，如果没有注册对象池，工具会跳过 SFX 并输出 warning。BGM 和环境音使用独立播放器，异步加载回调带有请求序号，较旧请求完成得更晚时不会覆盖新的播放请求。

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

`GFAudioBackend` 是协议层，不内置任何第三方 SDK、事件命名或业务混音快照。后端可选择只处理部分 BGM、SFX、环境音、空间音效或总线音量，其余请求保持默认行为；`GFAudioUtility.get_debug_snapshot()` 会把后端的 `get_debug_snapshot()` 放进 `backend_snapshot`，便于诊断面板统一展示。

默认总线名为 `BGM` / `SFX`，找不到时会回退到 `Master` 并按总线名只警告一次。`set_bus_volume(bus, 0.0)` 会把总线静音并让 `get_bus_volume()` 返回 `0.0`；再次设置大于 `0.0` 的值会解除静音。`play_bgm("", crossfade_seconds)` 可按同一淡出参数停止当前 BGM。`GFAudioClip` 可描述 stream/path、bus、音量、基础 pitch、候选权重和本次播放 pitch 随机范围；`GFAudioBank` 的同一 ID 可保存单个片段或多个候选，并支持用 `fallback_separator` 做分层事件 ID 回退。需要编辑器校验、构建前检查或调试 fallback 时，可用 `resolve_clip()` 获取请求 ID、最终命中 ID、是否使用 fallback、尝试过的 ID 和命中的 clip，用 `validate_bank()` 检查空 ID、无效候选、缺失音频源和可选资源路径存在性。

`GFAudioBankTools` 提供纯配置层的扫描、导入和播放前校验辅助，可用于编辑器按钮、构建脚本或项目自己的音频表生成流程。它不会创建全局音频单例，也不会改变 `GFAudioUtility` 的播放路径：

```gdscript
var paths := GFAudioBankTools.scan_audio_paths("res://audio", {
	"include_addons": false,
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
```

选中 `GFAudioBank` 资源时，Inspector 的验证入口也会使用同一套工具检查音频路径、候选片段和 bus 名。推荐把 `GFAudioBankTools` 当作“生成和体检配置”的工具；声音优先级、混音快照、场景预加载策略和具体事件命名仍由项目层决定。

`register_audio_bank()` 后可用 `play_bgm_event()`、`play_ambient_event()`、`play_sfx_event()` 按稳定事件 ID 播放；场景或 UI 想临时拥有一组音频事件时，可使用 `GFAudioBankMounter` 在 ready/exit 时自动注册、恢复或卸载 bank。需要主动停止、淡出或读取本次 SFX/空间音效状态时，使用 `play_sfx_handle()`、`play_sfx_clip_handle()`、`play_sfx_event_handle()` 或 2D/3D 对应 handle 方法取得 `GFAudioEmitterHandle`；环境音通道可用 `get_ambient_handle(channel)` 获取当前播放器句柄。句柄只管理底层播放器的停止、淡出、音量、音高和可选 owner 生命周期绑定，不替项目决定混音快照、声音优先级或业务生命周期。`play_sfx_clip_2d()` / `play_sfx_clip_3d()` 和对应 event 方法默认只在当前位置创建空间播放器；传入 `follow_source = true` 时，播放器会挂到声源节点下并随声源移动。复杂混音、音频快照、距离规则、碰撞触发和平台音频权限仍属于项目层。
