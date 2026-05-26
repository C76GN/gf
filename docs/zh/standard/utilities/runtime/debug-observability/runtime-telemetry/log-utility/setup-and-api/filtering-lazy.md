# 过滤与懒构造

低于 `min_level` 或被 `set_tag_muted()` 静音的日志不会打印、写入文件、进入内存缓存、写入 sink 或发出日志信号。

```gdscript
log_util.set_tag_muted("Network", true)
log_util.warn("Network", "延迟过高：%d ms。" % 150)

log_util.min_level = GFLogUtility.LogLevel.WARN
log_util.error("AudioBus", "找不到总线: %s" % "Master")
log_util.fatal("Core", "不可恢复的致命错误！")
```

## 懒构造

`*_lazy()` 系列只有在日志实际会输出时才调用 `message_builder` 和可选 `context_builder`，适合构造成本高的调试文本与上下文。

```gdscript
var message_builder := func() -> String:
	return "节点数：%d" % 10000

var context_builder := func() -> Dictionary:
	return {"frame": Engine.get_process_frames()}

log_util.warn_lazy("PathFinding", message_builder, context_builder)
```

懒构造只避免日志被过滤时的构造成本；如果 builder 本身有副作用，应移出日志路径。
