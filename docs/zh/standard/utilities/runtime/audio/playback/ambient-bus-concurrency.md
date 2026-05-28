# 环境音、总线与并发

环境音按 channel 独立播放和停止。它适合雨声、风声、场景底噪等长期背景层，不替代项目自己的音频状态机或声音优先级规则。

```gdscript
var audio := Gf.get_utility(GFAudioUtility) as GFAudioUtility

audio.play_ambient("res://audio/ambient/rain.ogg", &"rain")
audio.stop_ambient(&"rain", 0.25)
```

## 总线音量

```gdscript
audio.set_bus_volume("SFX", 0.8)
audio.set_bus_volume("BGM", 0.5)
audio.set_bus_volume_db("BGM", -6.0, 0.25)
```

默认播放总线名为 `BGM` / `SFX`。播放请求解析不到总线时会回退到 `Master`；显式总线控制则只操作已存在的总线，找不到时返回失败并发出警告。`set_bus_volume(bus, 0.0)` 会把总线静音并让 `get_bus_volume()` 返回 `0.0`；再次设置大于 `0.0` 的值会解除静音。

`set_bus_volume_db()` 适合需要精确 dB 和平滑过渡的混音控制。`transition_seconds <= 0` 时立即应用；目标音量小于等于 `GFAudioUtility.SILENCE_VOLUME_DB` 时会静音该总线。

## 混音快照与效果属性

```gdscript
var before_menu := audio.capture_mix_snapshot(PackedStringArray(["BGM", "SFX"]))

audio.apply_mix_snapshot({
	"buses": {
		"BGM": { "volume_db": -12.0 },
		"SFX": { "volume_linear": 0.7 },
	},
	"effects": [
		{
			"bus": "BGM",
			"effect": "lowpass",
			"property": "cutoff_hz",
			"value": 900.0,
		},
	],
}, 0.25)

audio.apply_mix_snapshot(before_menu, 0.25)
```

混音快照只描述 Godot 总线和效果属性，不规定“菜单”“战斗”“对话”等业务状态。`effect` 可以是效果索引，也可以是效果 `resource_name`、类名或类名片段；具体效果是否存在仍由项目的 Audio Bus Layout 决定。

需要临时压低某条总线时可使用 `duck_bus()` / `restore_ducked_bus()`：

```gdscript
audio.duck_bus("BGM", 0.5, 0.2, &"dialogue")
audio.restore_ducked_bus("BGM", 0.3, &"dialogue")
```

## SFX 并发

```gdscript
audio.max_sfx_players = 24
audio.sfx_overflow_policy = GFAudioUtility.SFXOverflowPolicy.STOP_OLDEST
audio.stop_all_sfx(0.1)
```

`max_sfx_players <= 0` 表示不限制同时播放的 SFX 数量。溢出策略只管理 GF 创建的 SFX 播放器，不处理项目外部音频节点或第三方音频 SDK。
