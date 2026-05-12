# 运行时服务与调试

本组文档覆盖标准库中需要生命周期、运行时状态、场景协作或开发期观测的 Utility。它们通常注册进 `GFArchitecture`，并由架构统一初始化、tick 或释放。

## 阅读入口

- [时间、信号与对象池](time-signal-pool.md)：逻辑计时、时间缩放、信号连接、节点对象池。
- [设置、UI、场景与表面查询](settings-ui-scene.md)：设置应用、UI 栈、场景切换、节点树操作、表面查询。
- [音频管理](audio.md)：背景音乐、音效、环境音、音频片段和播放历史。
- [调试、日志、诊断与控制台](debug-observability.md)：DebugDraw、Overlay、随机种子、日志、构建信息、支持报告、通知、控制台。

## 放置边界

- 纯算法和纯数据结构应放在 [Foundation 基础能力](../../foundation/index.md)。
- 文件、资源、存储和远程请求见 [资源、存储与 IO](../io/index.md)。
- 输入、状态机、序列和流程控制见 [输入、流程与玩法支撑](../../input-flow/index.md)。
