# 结构化日志与日志 Sink

本组页面说明 `GFLogUtility` 的分级日志、结构化上下文、本地文件、内存缓存、日志信号和可扩展 sink。项目需要日志时，应在 Installer 中显式装配；框架不会因为脚本存在就自动注册日志工具。

## 阅读入口

- [注册与日志 API](setup-and-api/index.md)：Installer 装配、分级日志、结构化上下文、标签静音、懒构造和日志信号。
- [文件、缓存与上下文](files-memory-context.md)：本地日志文件、flush 策略、内存环形缓存、上下文清洗、trace id 和崩溃标记。
- [日志 Sink](sinks.md)：`GFLogSink`、`GFJsonLineLogSink`、`GFBatchedLogSink` 和项目自定义输出。

## 使用边界

`GFLogUtility` 提供本地与内存级别的通用观测能力，不内置远端上传、鉴权、脱敏、崩溃归因或线上采集策略。需要接入平台 SDK、后端日志服务、编辑器桥接或玩家支持系统时，应通过 sink 或项目层工具完成。
