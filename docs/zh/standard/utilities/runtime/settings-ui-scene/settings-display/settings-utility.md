# 通用设置存储

游戏设置页通常会混合窗口模式、分辨率、语言、音量、难度、辅助功能等数据。如果这些逻辑直接写进 UI 节点，后续存档、重置默认值、平台差异和测试都会变得困难。

`GFSettingsUtility` 只管理抽象设置定义和值，不知道它们会被哪个 UI 或引擎 API 使用。

```gdscript
var settings := Gf.get_utility(GFSettingsUtility) as GFSettingsUtility

settings.register_setting(
	&"gameplay/difficulty",
	"normal",
	GFSettingDefinition.ValueType.STRING
)
settings.set_value(&"gameplay/difficulty", "hard")
settings.save_settings()
```

`GFSettingDefinition` 可以资源化描述稳定键、默认值、值类型、是否持久化和 UI 元数据。`set_value()` 会按定义做类型转换，`to_dict(true)` 只导出持久化设置；未注册定义的临时值也能读写，但不会获得默认值、类型钳制或元数据。

持久化设置会保留 `Vector2`、`Vector2i`、`Color`、`StringName` 等常见 Godot 值；其他需要 JSON 类型标记的值会复用 `GFVariantJsonCodec`，因此超出 JSON 安全范围的 64 位整数也能精确往返。

自动保存默认会按 `save_debounce_seconds` 做防抖，避免设置页拖动滑块时每次变化都落盘。需要一次性应用多个字段时，可用 `begin_batch()` / `end_batch()` 包裹，或手动 `queue_save()` 后在合适时机 `flush_pending_save()`。

## 预设应用

需要把“低画质”“无障碍”“手柄方案”这类项目预设一次性应用到设置中时，可以使用 `apply_values()`。它会沿用已注册定义做类型转换，并把自动保存合并成一次。

如果预设希望把缺失的键重置为默认值，必须显式传入 `scope`，避免误重置不属于该预设的其他设置。

```gdscript
var report := settings.apply_values({
	"audio/master": 0.75,
	"video/fullscreen": true,
}, {
	"reset_missing": true,
	"scope": PackedStringArray([
		"audio/master",
		"video/fullscreen",
		"video/vsync",
	]),
})

if not report["ok"]:
	print(report["issues"])
```
