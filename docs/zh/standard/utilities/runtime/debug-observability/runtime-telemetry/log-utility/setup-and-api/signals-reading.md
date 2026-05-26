# 信号与最近日志

每条日志会生成结构化条目，并通过 `log_emitted` / `log_entry_emitted` 广播给控制台、诊断面板或项目自定义采集器。

```gdscript
log_util.log_emitted.connect(func(level: int, tag: String, msg: String) -> void:
	print("收到日志: [%d] %s - %s" % [level, tag, msg])
)

log_util.log_entry_emitted.connect(func(entry: Dictionary) -> void:
	print(entry["context"])
)

for entry in log_util.get_recent_entries(50):
	print(entry["text"])
```

`GFConsoleUtility` 会自动监听兼容日志信号。诊断 UI 需要分页或导出时，优先读取 `get_recent_entries()`，不要解析本地文本日志。
