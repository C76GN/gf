# 调试覆盖层

`GFDebugOverlayUtility` 会创建一个轻量 `CanvasLayer` 覆盖层，通过反射扫描当前架构内注册的 `GFModel`，并显示脚本变量的实时值。项目也可以主动注册少量运行时 watch，把不适合放进 Model 的临时观察值显示在同一个面板里。

它不是命令行控制台，也不执行指令；需要输入调试命令、查看日志输出时请使用 `GFConsoleUtility`。

覆盖层默认 `debug_only = true`，发布构建不会创建 GUI；如果项目确实需要在非 debug 构建中显示，必须显式关闭该选项，并自行确认数据脱敏和玩家可见性。

覆盖层会直接反射显示脚本变量值，并显示项目注册的 watch 返回值，不做字段脱敏或白名单过滤。

## 基础用法

```gdscript
var debug := Gf.get_utility(GFDebugOverlayUtility) as GFDebugOverlayUtility

# 默认按 `~` 呼出/隐藏，可按项目需要更换快捷键和刷新间隔。
debug.set_toggle_key(KEY_QUOTELEFT)
debug.set_refresh_interval(0.25)

# 可选：主动推送当前值，适合项目层已有刷新点的指标。
debug.push_watch_value(&"fps", Engine.get_frames_per_second(), {
	"label": "FPS",
	"group": "Runtime",
})

# 可选：注册拉取式 provider，Overlay 刷新时读取当前值。
var scene_path_provider := func() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	return scene.scene_file_path

debug.watch_value(&"scene_path", scene_path_provider, {
	"label": "Scene",
	"group": "Runtime",
})
```

`watch_value()` 适合廉价、无副作用的当前状态读取；`push_watch_value()` 适合由项目循环或回调主动更新的值。

注册了 `GFDiagnosticsUtility` 时，Overlay 默认也会显示 `overlay` 诊断监控预设，可用 `set_diagnostics_monitor_preset()` 切换预设，或把 `include_diagnostics_monitors` 设为 `false` 只显示手动 watch。

Watch 只是一层调试显示通道，不保存历史、不做采样统计，也不规定业务字段；需要长期记录请接入 `GFLogUtility` / `GFDiagnosticsUtility` 或项目自己的分析系统。

Overlay 所属 GUI 在 `dispose()` 时会立即从场景树移除，避免调试层在架构销毁同一帧继续残留。

## 面板

需要显示多行结构化内容时，可以用 `register_panel()` 或 `push_panel_text()` 注册 Overlay 面板。面板 provider 可以返回字符串、数组或字典，Overlay 会把它们格式化为只读文本；`include_recent_logs` 开启时还会附加最近日志面板。

面板同样不做脱敏，适合开发期聚合 `GFDiagnosticsUtility` 快照、项目局部状态或自定义工具输出。
