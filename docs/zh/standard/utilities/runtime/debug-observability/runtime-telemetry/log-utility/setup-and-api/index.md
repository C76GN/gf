# 注册与日志 API

本组页面说明 `GFLogUtility` 的装配方式、基础日志调用、过滤策略、懒构造、日志信号和内存读取入口。项目需要日志时，应在 Installer 中显式注册日志工具。

## 阅读入口

- [注册与基础日志](registration-basic.md)：Installer 装配、分级日志和结构化上下文。
- [过滤与懒构造](filtering-lazy.md)：`min_level`、标签静音和 `*_lazy()`。
- [信号与最近日志](signals-reading.md)：`log_emitted`、`log_entry_emitted` 和 `get_recent_entries()`。

## 使用边界

这些页面只说明日志工具的装配、调用和读取入口。日志持久化策略、远程上传、敏感字段脱敏、玩家可见输出和崩溃归因应由 sink 或项目层工具处理。
