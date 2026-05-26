# SFX 与音频片段

`GFAudioUtility` 会优先借助 `GFAssetUtility` 异步加载音频资源；未注册时退回同步 `load()`。SFX 播放会在存在 `GFObjectPoolUtility` 时复用池化 `AudioStreamPlayer`，未注册对象池时则创建普通播放器并在播放结束后释放。

```gdscript
var audio := Gf.get_utility(GFAudioUtility) as GFAudioUtility

audio.play_sfx("res://audio/sfx/hit.wav")

var clip := GFAudioClip.new()
clip.stream = preload("res://audio/sfx/confirm.wav")
clip.bus_name = "SFX"
clip.volume_db = -3.0
audio.play_sfx_clip(clip)
```

`GFAudioEmitterHandle.stop()` 即使在异步资源返回前调用，也会记录停止请求；迟到的 SFX 资源不会再创建播放器。`stop_all_sfx()` 会递增 SFX 生命周期序号，停止普通 SFX 和 2D/3D 空间 SFX，并阻止尚未返回的异步 SFX 继续落地。

池化播放器归还前会重置 stream、bus、音量和 pitch，避免上一次播放设置污染下一次请求。
