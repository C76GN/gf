# 诊断快照与命令

`GFDiagnosticsUtility` 可在运行时聚合架构生命周期、事件系统、性能监视器、日志缓存、常见工具快照和外部贡献的诊断分区，并提供可注册的诊断命令入口。

## 阅读入口

- [快照与场景树诊断](snapshot-scene.md)：`collect_snapshot()`、内置诊断命令和只读场景树快照。
- [命令 Schema](command-schema.md)：诊断命令参数 schema、启停控制和 JSON 安全结果。
- [风险等级与认证](command-risk.md)：命令等级、认证 token、控制类命令和 `DANGER` 命令保护。

## 使用边界

诊断命令只提供统一调度和结果包装。若要暴露给远程开发工具、玩家可访问控制台或线上 GM 工具，项目层必须提供权限、脱敏、白名单和审计策略。
