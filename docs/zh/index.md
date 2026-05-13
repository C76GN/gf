# GF Framework

**Godot 4 轻量级架构框架：关注点分离、生命周期管理、事件驱动、标准库与可选原子扩展生态。**

GF Framework 用一套清晰的运行时架构，把游戏项目中的数据、规则、表现、服务和纯算法拆开管理。它不替代 Godot 场景树，而是让场景树继续负责输入、显示、节点和引擎能力，让核心逻辑拥有可测试、可诊断、可组合的生命周期。

## 核心理念

- **逻辑与表现分离**：核心规则放在 `GFSystem`，状态放在 `GFModel`，Godot 节点和 UI 通过 `GFController` 桥接。
- **生命周期可控**：`GFArchitecture` 统一推进 `init()`、`async_init()`、`ready()` 和 `dispose()`，并支持 Installer、局部架构和依赖诊断。
- **通信边界明确**：强类型事件、simple 事件、命令、查询和规则对象分别服务不同粒度的模块协作。
- **工具层不混乱**：需要生命周期、缓存、异步或运行时状态的能力放入 `GFUtility`；纯算法、纯数据和纯格式化留在 `standard/foundation`。
- **扩展能力可选**：Capability、Save、Combat、Network、Flow、ActionQueue 等通用能力以官方原子扩展形式随 GF 发布，可启用、禁用或从导出中排除；跨扩展组合留给项目和社区。

## 当前源码结构

```text
addons/gf/
  kernel/              # 运行内核、基础契约、架构容器、事件、绑定、扩展基础设施、核心编辑器装配
  standard/            # 稳定标准库：foundation、input、utilities、state_machine、sequence 等
  extensions/
    official/          # 随 GF 发布的可选原子通用扩展
    community/         # 项目本地、社区或组合扩展约定入口
```

这套结构对应三个判断：

- 必须支撑 GF 启动与基础契约的内容进 `kernel`。
- 足够稳定、通用、默认随框架理解的能力进 `standard`。
- 通用但并非所有项目都需要的官方原子能力进 `extensions/official`；项目组合和第三方扩展进 `extensions/community` 或外部插件。

## 文档结构

本项目文档使用 MkDocs 构建，并由 Read the Docs 托管。`docs/zh` 的目录与网站导航保持一致：

```text
docs/zh/
  index.md
  faq.md
  changelog.md
  overview/
  kernel/
  standard/
  extensions/
  editor/
  maintenance/
```

后续增加英文文档时，`docs/en` 应保留相同目录 slug、页面职责和导航层级；翻译标题可以不同，但不要为局部措辞反复重命名已有路径。

## 推荐阅读顺序

1. [总览与快速开始](overview/index.md)：安装、最小示例、源码布局和阅读路线。
2. [Kernel 架构容器](kernel/index.md)：`GFArchitecture`、模块注册、依赖查询、事件、工厂和调试快照。
3. [生命周期、装配与依赖](kernel/lifecycle/index.md)：Installer、三阶段初始化、局部架构、异步初始化和依赖诊断。
4. [消息、事件、命令与查询](kernel/messaging/index.md)：模块通信总览，再按事件、命令查询、命令历史拆分查阅。
5. [场景桥接、Controller 与数据绑定](kernel/scene-controller/index.md)：Controller、NodeContext、数据绑定、tick 更新和场景树边界。
6. [Standard 标准库总览](standard/index.md)：标准库定位、放置边界和阅读入口。
7. [Foundation 基础能力](standard/foundation/index.md)：基础件总览，再按数值、网格空间、数据校验拆分查阅。
8. [Utilities 工具总览](standard/utilities/index.md)：标准库运行时工具总览。
9. [资源、存储与 IO](standard/utilities/io/index.md)：资源、存储和 IO 总览，再按资源加载、存储快照、远程请求拆分查阅。
10. [运行时服务与调试](standard/utilities/runtime/index.md)：运行时服务总览，再按时间对象、UI 场景、音频、调试观测拆分查阅。
11. [输入、流程与玩法支撑](standard/input-flow/index.md)：输入与流程总览，再按状态机、命令序列、输入辅助、空间查询拆分查阅。
12. [官方扩展总览与扩展规范](extensions/index.md)：manifest、启用状态、扩展 Installer、导出排除、社区扩展规范。
13. [编辑器工具、访问器与项目常量](editor/index.md)：GF 插件、扩展管理器、Inspector、Dock、导出插件和代码生成。
14. [最佳实践、维护与测试](maintenance/index.md)：项目落地建议、分层边界、测试和文档维护。
15. [FAQ](faq.md)：高频分层、扩展、Wiki 和文档结构问题。

## 按主题查阅

### Kernel

- [Kernel 架构容器](kernel/index.md)
- [生命周期、装配与依赖](kernel/lifecycle/index.md)
- [消息、事件、命令与查询](kernel/messaging/index.md)
- [事件系统](kernel/messaging/events.md)
- [命令、查询与规则](kernel/messaging/commands-queries-rules.md)
- [命令历史与撤销重做](kernel/messaging/command-history.md)
- [场景桥接、Controller 与数据绑定](kernel/scene-controller/index.md)

### Standard

- [Standard 标准库总览](standard/index.md)
- [Foundation 基础能力](standard/foundation/index.md)
- [Foundation 数值、成长与权重](standard/foundation/scalars.md)
- [Foundation 网格、路径与空间索引](standard/foundation/grid-spatial.md)
- [Foundation 标签、公式、序列化与结果报告](standard/foundation/data-validation.md)
- [Utilities 工具总览](standard/utilities/index.md)
- [资源、存储与 IO](standard/utilities/io/index.md)
- [资源加载、下载、任务队列与预热](standard/utilities/io/assets-jobs-warmup.md)
- [本地存储、编码、同步与快照](standard/utilities/io/storage-snapshot.md)
- [导表、分析、远程缓存与请求 Outbox](standard/utilities/io/config-remote-outbox.md)
- [运行时服务与调试](standard/utilities/runtime/index.md)
- [时间、信号与对象池](standard/utilities/runtime/time-signal-pool.md)
- [设置、UI、场景与表面查询](standard/utilities/runtime/settings-ui-scene.md)
- [音频管理](standard/utilities/runtime/audio.md)
- [调试、日志、诊断与控制台](standard/utilities/runtime/debug-observability.md)
- [输入、流程与玩法支撑](standard/input-flow/index.md)
- [纯代码状态机与节点状态机](standard/input-flow/state-machines.md)
- [撤销历史与指令序列](standard/input-flow/command-sequence.md)
- [输入映射与手感辅助](standard/input-flow/input-assist.md)
- [逻辑空间查询与相关扩展](standard/input-flow/spatial-query.md)

### Extensions

- [官方扩展总览与扩展规范](extensions/index.md)
- [Capability 能力组合](extensions/capability/index.md)
- [Interaction 与 Feedback](extensions/interaction-feedback/index.md)
- [Combat 战斗通用能力](extensions/combat/index.md)
- [ActionQueue 表现动作队列](extensions/action-queue/index.md)
- [Network 与 TurnBased](extensions/network-turnbased/index.md)
- [Flow、Domain 与 Physics](extensions/flow-domain-physics/index.md)
- [Save 场景存档图](extensions/save-graph/index.md)
- [Level、BehaviorTree 与 Quest](extensions/level-behaviortree-quest/index.md)

### Editor And Maintenance

- [编辑器工具、访问器与项目常量](editor/index.md)
- [最佳实践、维护与测试](maintenance/index.md)
- [更新日志](changelog.md)

## 常用入口

- `Gf`：全局 AutoLoad 入口，默认路径为 `res://addons/gf/kernel/core/gf.gd`。
- `GFArchitecture`：运行时容器，负责模块注册、依赖查询、事件派发、工厂和生命周期。
- `GFInstaller`：项目或扩展的集中装配入口。
- `GFNodeContext`：场景树中的局部架构上下文。
- `GFAccessGenerator`：强类型访问器生成器。
- `GF` Workspace：编辑器底部统一入口，内部包含扩展管理、存档查看和信号图等页面。

## 使用提示

在任何地方从架构获取模块时，推荐使用明确类型断言：

```gdscript
var player_model := Gf.get_model(PlayerModel) as PlayerModel
if player_model == null:
	return
```

这能保留 Godot 编辑器补全，也让依赖缺失在调用点被显式处理。
