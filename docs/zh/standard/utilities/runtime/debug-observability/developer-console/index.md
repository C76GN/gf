# 运行时开发者控制台

`GFConsoleUtility` 提供运行时调试命令、日志输出和控制台窗口。控制台默认只面向 debug 构建；如果项目要暴露到非 debug 构建，必须自行处理命令白名单、认证和权限。

## 阅读入口

- [控制台窗口与内置命令](window-builtins.md)：F1 呼出、全屏/窗口模式、内置命令、日志显示和输入体验。
- [命令注册与参数解析](command-registration.md)：自定义命令、资源化命令定义、别名和参数解析。
- [安全等级与输出限制](safety-limits.md)：`debug_only`、命令 tier、危险命令确认、输出行数和历史容量。
- [显示配置与生命周期](display-lifecycle.md)：窗口配置、GUI 创建策略、`dispose()` 清理和日志信号断开。

## 使用边界

控制台适合运行中快速执行调试指令、查看实时日志输出。需要认证 token、远程调试入口或完整审计记录时，仍建议把命令注册到 `GFDiagnosticsUtility`，再由控制台或其他调试 UI 调用诊断命令。
