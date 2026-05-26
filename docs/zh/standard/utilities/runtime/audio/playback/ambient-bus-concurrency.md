# 环境音、总线与并发

环境音按 channel 独立播放和停止。它适合雨声、风声、场景底噪等长期背景层，不替代项目自己的音频状态机或混音快照。

```gdscript
var audio := Gf.get_utility(GFAudioUtility) as GFAudioUtility

audio.play_ambient("res://audio/ambient/rain.ogg", &"rain")
audio.stop_ambient(&"rain", 0.25)
```

## 总线音量

```gdscript
audio.set_bus_volume("SFX", 0.8)
audio.set_bus_volume("BGM", 0.5)
```

默认总线名为 `BGM` / `SFX`，找不到时会回退到 `Master` 并按总线名只警告一次。`set_bus_volume(bus, 0.0)` 会把总线静音并让 `get_bus_volume()` 返回 `0.0`；再次设置大于 `0.0` 的值会解除静音。

## SFX 并发

```gdscript
audio.max_sfx_players = 24
audio.sfx_overflow_policy = GFAudioUtility.SFXOverflowPolicy.STOP_OLDEST
audio.stop_all_sfx(0.1)
```

`max_sfx_players <= 0` 表示不限制同时播放的 SFX 数量。溢出策略只管理 GF 创建的 SFX 播放器，不处理项目外部音频节点或第三方音频 SDK。
