# BGM 控制

BGM 使用独立播放器，异步加载回调带有请求序号。较旧请求完成得更晚时，不会覆盖新的播放请求。

```gdscript
var audio := Gf.get_utility(GFAudioUtility) as GFAudioUtility

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
```

BGM transport 接口面向暂停菜单、剧情演出、音量淡入淡出和进度恢复。`pause_bgm()` / `resume_bgm()` 使用 Godot `AudioStreamPlayer.stream_paused` 保留当前位置，`seek_bgm()` 和 `get_bgm_playback_position()` 用于显式跳转和记录。

`play_bgm_with_options()` 支持 `crossfade_seconds`、`history_key`、`bus_name`、`volume_db`、`pitch_scale` 与可选 `loop` 覆盖。只有显式传入 `loop` 时才尝试复制当前 `AudioStream` 并设置循环属性，避免修改共享 Resource 或改变默认循环语义。当前 BGM 自然结束时会发出 `bgm_finished(history_key)`。

`play_bgm("", crossfade_seconds)` 可按同一淡出参数停止当前 BGM。
