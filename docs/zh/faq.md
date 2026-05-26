# FAQ

## GF 是游戏框架还是一组工具类？

GF 是面向 Godot 项目的轻量架构框架。它提供启动装配、模块生命周期、事件、命令、查询、数据绑定、标准库工具和可选扩展，目标是让项目代码有稳定的分层和组合方式，而不是只提供零散 helper。

## GF 会替代 Godot 的节点和场景系统吗？

不会。GF 负责架构层、数据流和通用能力边界；Godot 的节点、场景、资源、信号、物理和渲染仍然是项目的主要运行环境。通常做法是让 GF 的 Model/System 保存状态和流程，让 Controller、节点脚本或场景资源负责具体表现。

## 什么时候使用 kernel、standard 或 extensions？

`kernel` 只承载框架启动、生命周期、注册、依赖、事件、命令、查询、绑定和扩展基础设施。`standard` 放稳定通用能力，例如 Foundation、输入、状态机、资源、存储、时间、日志、诊断和音频。`extensions` 放可选通用能力，例如 Capability、Save、Combat、Network、Flow、Domain、BehaviorTree、Camera 和 Dialogue。

## 我需要启用所有 GF 内置扩展吗？

不需要。GF 内置扩展按能力拆分，可以按项目需要启用。扩展之间保持原子化，不把其他扩展当作隐藏依赖；如果项目需要把多个扩展组合成完整玩法，应在项目 Installer 或项目自己的插件中完成组合。

## 项目代码应该放进 `addons/gf` 吗？

不应该。`addons/gf` 是框架源码目录，项目自己的 Model、System、Controller、资源、场景和扩展组合应放在项目目录或独立插件中。这样升级 GF 时不会混入项目业务代码，也能保持框架测试和发布边界清晰。

## 找具体类、属性、信号和方法签名时看哪里？

先读对应指南页理解职责边界和典型组合方式，再查 [API Reference](reference/api/index.md)。API Reference 由源码 API 注释生成，覆盖公开类、属性、信号、枚举、常量和方法签名。

## API Reference 是手写的吗？

不是。生成链路是 `addons/gf/**/*.gd` 源码 API 注释 -> `docs/api_catalog` XML Catalog -> `docs/zh/reference/api` Markdown 页面。正文指南负责解释概念和工作流，API Reference 负责提供可检索的 API 清单。
