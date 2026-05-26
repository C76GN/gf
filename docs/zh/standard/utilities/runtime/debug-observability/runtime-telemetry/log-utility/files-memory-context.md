# 文件、缓存与上下文

`GFLogUtility` 初始化时会在 `user://logs/` 下创建按日期时间命名的日志文件，并自动清理超出保留数量的旧日志。每条日志会同时生成结构化条目，进入内存环形缓存，写入本地文件，并转发给已注册的 sink。

## 文件保留与 Flush

```gdscript
var log_util := Gf.get_utility(GFLogUtility) as GFLogUtility
if log_util == null:
	return

log_util.max_log_files = 20

print(log_util.get_log_file_path())
```

文件默认按 `flush_interval_msec` 批量 flush。`flush_immediately = true` 或 `flush_interval_msec <= 0` 时，每条日志立即 flush；`ERROR` / `FATAL` 会强制尽快写盘。当前日志文件路径可通过 `get_log_file_path()` 读取，便于测试、诊断界面或导出工具定位文件。

## 内存缓存

内存缓存由 `max_memory_entries` 控制，超出后按环形缓冲覆盖最旧条目。项目可通过 `get_recent_entries()` 读取最近日志，并通过 `get_dropped_memory_entry_count()` 观察已丢弃条目数量。

## 全局上下文

`trace_id` 是每次运行的轻量关联字段。项目可以显式设置，也可以使用默认生成值；全局上下文会合并到后续结构化日志条目中。

```gdscript
log_util.set_trace_id("session-20260509-001")
log_util.set_global_context({
	"scene": "battle",
	"profile": "debug",
})
```

结构化上下文会经过 `sanitize_log_value()` 清洗。过深嵌套、超长字符串和非 JSON 原生对象会被转换为可写入日志的稳定值，避免调试数据破坏日志文件或 sink。

## 崩溃标记

`crash_marker_enabled` 开启时，日志工具会在初始化时检查上一次运行是否留下未清理标记，并通过 `previous_crash_detected` 发出报告。该信号只提示“上次可能异常退出”，不替项目判断崩溃原因、上传策略或恢复流程。
