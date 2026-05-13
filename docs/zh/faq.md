# FAQ

## 为什么文档目录按 overview、kernel、standard、extensions 划分？

GF 3.0.0 的源码边界已经稳定为 `kernel <- standard <- extensions`，文档目录也按同一套分层组织。这样维护者从文件树就能判断页面所属层级，Read the Docs 左侧导航和仓库目录也保持一致。

## 什么时候放进 kernel？

只有框架启动、生命周期、注册、注入、事件、绑定、扩展基础设施、核心编辑器扩展点，以及 `kernel` 必须识别的最小协议才放进 `kernel`。如果某个能力只是通用实现，而不是框架启动契约，应继续放在 `standard` 或 `extensions`。

## 什么时候放进 standard？

足够稳定、通用、默认随框架理解的能力放进 `standard`。例如 foundation、输入体系、状态机、命令序列、资源、存储、时间、日志、诊断、音频等。`standard` 可以依赖 `kernel`，但不能探测或硬绑定官方扩展。

## 什么时候放进 extensions？

通用但不是所有项目都需要的能力放进 `extensions`，例如 Capability、Interaction、Combat、ActionQueue、Network、Save、Flow、Domain、BehaviorTree 等。官方扩展只依赖 `kernel` 和稳定的 `standard`，并保持原子化；如果项目需要组合多个官方扩展，应放在项目 Installer、社区扩展或外部插件中。

## 为什么官方扩展不互相依赖？

官方扩展是 GF 随框架发布的最小可选能力单元。如果官方扩展彼此依赖或软探测，扩展边界会逐渐变成隐藏组合图，禁用、导出排除和测试都会越来越难控。GF 因此把官方扩展固定为原子层，把组合自由留给项目和社区。

## 为什么 standard 不能弱探测官方扩展？

弱探测会让“可选扩展”变成事实上的隐藏依赖。3.0.0 的规则是：如果扩展能力需要出现在标准库诊断、Overlay 或工具快照里，由扩展侧依赖标准库的通用注册入口主动贡献；标准库本身不写扩展 ID、扩展路径或扩展内类型名。

## GitHub Wiki 还维护正文吗？

不维护。旧 Wiki 只保留 Home、Sidebar 和 Footer 入口，正式正文统一维护在 Read the Docs 源文件 `docs/zh/**` 中，避免 Wiki 和 Read the Docs 双写分叉。
