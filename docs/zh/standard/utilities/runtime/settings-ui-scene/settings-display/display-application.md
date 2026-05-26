# 显示、语言与音频总线

`GFDisplaySettingsUtility` 把通用设置应用到 Godot 的窗口、VSync、语言和音频总线层。它只处理常见引擎 API 边界，不定义项目设置页 UI、文案或业务分组。

```gdscript
var display := Gf.get_utility(GFDisplaySettingsUtility) as GFDisplaySettingsUtility

display.set_fullscreen(true)
display.set_vsync_mode(DisplayServer.VSYNC_ENABLED)
display.set_locale("zh_CN")
display.register_audio_bus_volume("Master", 1.0)
display.set_audio_bus_volume("Master", 0.75)
```

显示设置是否允许某个分辨率、是否需要平台白名单、是否要同步到项目配置档，仍由项目层决定。
