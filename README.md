# GF Framework

GF Framework is a lightweight game architecture framework for Godot 4. It keeps data, logic, presentation, runtime services, and pure algorithm utilities in clear layers so larger projects can keep predictable lifecycles and dependency boundaries.

## English Overview

- `Foundation`: pure value objects, algorithms, resourceized formulas, formatting helpers, typed JSON Variant conversion, big numbers, fixed decimals, progression curves, weighted selection, tag queries, blackboard schemas, graph search, 2D/3D grid pathfinding and flow fields, tile helpers, spatial hashes, and offline reward calculations.
- `GFModel`: data layer for game state, snapshots, and save/restore methods through `to_dict()` / `from_dict()`.
- `GFSystem`: logic layer for rules, events, commands, queries, and frame-based updates.
- `GFController`: presentation layer based on `Node`, connecting Godot scenes, UI, input, and framework data.
- `GFUtility`: runtime services such as storage, request outboxes, snapshot history, save graph composition, resource loading, remote caching, scene transitions, build info, time, object pools, UI stack handling, audio, input, logging, and diagnostics.

## Installation

Copy `addons/gf` into your Godot project, then enable `GF Framework` from `Project > Project Settings > Plugins`.

Godot does not automatically enable editor plugins that are copied into a project. This is expected: plugin enablement is stored in the target project's `project.godot`, and the user must opt in before editor plugin code runs.

When the plugin is enabled, it registers the `Gf` AutoLoad automatically:

```text
Gf -> res://addons/gf/kernel/core/gf.gd
```

The plugin also opens a `GF Packages` bottom panel. Use it to inspect package manifests, enable or disable GF packages, auto-run enabled package installers, and exclude disabled package folders from exported builds. Official packages do not have hard dependencies on each other; packages you do not use can also be removed as long as project scripts, scenes, resources, and preloads no longer point to them. The package panel and export flow warn when disabled packages are still referenced by project files.

## Quick Start

```gdscript
extends Node


func _ready() -> void:
	Gf.register_model(PlayerModel.new())
	Gf.register_utility(GFStorageUtility.new())
	Gf.register_system(BattleSystem.new())

	await Gf.init()

	var player_model := Gf.get_model(PlayerModel) as PlayerModel
	var battle_system := Gf.get_system(BattleSystem) as BattleSystem
	battle_system.start_encounter(player_model)
```

## Included Modules

GF Framework includes lifecycle-managed models, systems, controllers, utilities, architecture dependency diagnostics, typed events, bindable properties with computed/effect helpers, commands and queries, state machines with guards, command sequences, turn-flow helpers, action queues with resourceized tween configs, interceptors and shake feedback actions, object pooling, node tree helpers, scene switching with preload caching, preload maps, transition params and history, storage helpers, request outboxes, snapshot history, rich text formatting, typed JSON Variant conversion, save slot workflows, save graph composition, pipeline traces and diagnostics, settings and display adapters, build info snapshots and optional export-time metadata writing, asset handles and groups, audio banks with BGM/ambient helpers, playback handles and scene bank mounters, player-scoped input mapping with virtual input sources and recording/playback, modifiers/triggers, conflict reports and formatter providers, debug draw command buffering, analytics events, capability components with recipes, inspection reports and editor validation, interaction flows, interaction sender/receiver nodes and 3D pointer interaction bridging, resourceized flow graphs with ports/connections/topology diagnostics/editor view models, optional ENet and WebSocket network transports with session/channel metadata, runtime diagnostics, notification queues, lightweight combat helpers with configurable Buff refresh/tick policies and 2D/3D hit context bridge nodes, generic domain models including slot inventory resources, weighted selection, tag queries, blackboard schemas, graph search, grid pathfinding and tile primitives, 3D grid math, 3D spatial hashing, steering collision avoidance, 3D gravity fields, 3D surface material lookup, and editor tools for typed GF/config accessor generation.

## Source Layout

- `addons/gf/kernel`: GF runtime kernel, base module contracts, architecture container, binding, events, Autoload entry, and editor integration.
- `addons/gf/standard`: standard library shipped with GF, including `foundation`, `input`, `utilities`, `state_machine`, command, sequence, and common support primitives.
- `addons/gf/packages/official`: official packages shipped with GF but kept outside the kernel and standard library, such as combat, save, network, flow, capability, interaction, behavior tree, action queue, feedback, physics, turn-based, and generic domain models. Package roots contain manifests and docs; code lives in stable slots such as `runtime`, `resources`, `nodes`, `editor`, or package-specific domains.
- `addons/gf/packages/community`: optional location for local or third-party packages that follow the GF package manifest and directory standard.

## Testing

The test suite uses GUT:

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gf_core -ginclude_subdirs -gexit
```

## 中文说明

GF Framework 是一个面向 Godot 4 的轻量级游戏架构框架，核心目标是把数据、逻辑、表现、运行时服务和纯算法基础件拆开管理，让项目在规模变大后仍然保持清晰的生命周期和依赖边界。

## 核心分层

- `Foundation`：纯值对象、纯算法、资源化公式和纯格式化工具，不参与 `GFArchitecture` 注册，适合承载大数、定点数、显示格式化、类型化 JSON Variant 转换、价格/收益曲线、权重选择、标签查询、黑板 Schema、图搜索、2D/3D 网格寻路与离线收益结算等基础件。
- `GFModel`：数据层，保存游戏状态，提供 `to_dict()` / `from_dict()` 用于存档与快照。
- `GFSystem`：逻辑层，处理业务规则、事件响应、命令执行和逐帧逻辑。
- `GFController`：表现层，继承 `Node`，连接 Godot 场景树、UI、输入和框架数据。
- `GFUtility`：工具层，提供存档、请求 Outbox、快照历史、资源加载、远程缓存、场景切换、构建信息、时间控制、对象池、UI 栈、日志等通用能力。

## 安装

将 `addons/gf` 复制到目标 Godot 项目的 `addons` 目录，然后在 Godot 的 `Project > Project Settings > Plugins` 中启用 `GF Framework`。

Godot 不会自动启用被复制到项目中的编辑器插件，这是正常行为。插件启用状态属于目标项目的 `project.godot` 配置，需要用户在插件面板中明确启用后，编辑器插件代码才会运行。

插件启用后会自动注册 `Gf` AutoLoad。也可以手动在项目设置中添加：

```text
Gf -> res://addons/gf/kernel/core/gf.gd
```

插件底部面板中还会出现 `GF Packages`。它用于查看 `gf_package.json`、启用/禁用官方包或社区包、让启用包的 Installer 自动参与 `Gf.init()`，并在导出时跳过禁用包目录以减少包体。官方包之间不互相强依赖；完全不用的官方包也可以删除目录，但项目侧不能再直接引用被删除包里的脚本、场景或资源。禁用包仍被项目文件引用时，包管理面板和导出流程会给出警告。

## 快速开始

```gdscript
extends Node


func _ready() -> void:
	Gf.register_model(PlayerModel.new())
	Gf.register_utility(GFStorageUtility.new())
	Gf.register_system(BattleSystem.new())
	
	await Gf.init()
	
	var player_model := Gf.get_model(PlayerModel) as PlayerModel
	var battle_system := Gf.get_system(BattleSystem) as BattleSystem
	battle_system.start_encounter(player_model)
```

如果需要自定义架构实例，可以先把模块注册到该实例，再交给 `Gf.set_architecture()` 初始化：

```gdscript
var arch := GFArchitecture.new()
arch.register_model_instance(PlayerModel.new())
arch.register_utility_instance(GFStorageUtility.new())
arch.register_system_instance(BattleSystem.new())

await Gf.set_architecture(arch)
```

也可以使用项目级 Installer 集中装配模块。先创建安装器脚本：

```gdscript
class_name GameInstaller
extends GFInstaller


func install(architecture: GFArchitecture) -> void:
	architecture.register_model_instance(PlayerModel.new())
	architecture.register_utility_instance(GFStorageUtility.new())
	architecture.register_system_instance(BattleSystem.new())
```

如果更喜欢声明式装配，也可以重写 `install_bindings()`：

```gdscript
func install_bindings(binder: Variant) -> void:
	binder.bind_model(PlayerModel).as_singleton()
	binder.bind_utility(GFStorageUtility).as_singleton()
	binder.bind_system(BattleSystem).as_singleton()
	binder.bind_factory(DealDamageCommand).from_factory(func() -> Object:
		return DealDamageCommand.new()
	).as_transient()
```

然后在 `Project Settings > gf/project/installers` 中加入该脚本路径。调用 `await Gf.init()` 或 `await Gf.set_architecture(arch)` 时，框架会在生命周期初始化前自动执行安装器。启用 GF 包也可以通过 manifest 的 `installer_paths` 提供安装器；这些包安装器会先于项目级安装器执行。

局部玩法或关卡模块可以挂载 `GFNodeContext`。`SCOPED` 模式会创建带父级回退的局部架构，并在节点退出树时自动 `dispose()` 局部模块；`INHERITED` 模式则直接复用最近父级或全局架构。

`GFController` 会优先沿场景树查找最近的 `GFNodeContext`，因此局部 UI/输入节点可以直接使用 `get_model()`、`get_system()`、`get_utility()` 访问所属上下文。

对于短生命周期对象，例如命令、查询、技能执行载体，可以使用工厂：

```gdscript
Gf.register_factory(DealDamageCommand, func() -> Object:
	return DealDamageCommand.new()
)

var command := Gf.create_instance(DealDamageCommand) as DealDamageCommand
Gf.send_command(command)
```

工厂创建的对象会自动接收当前架构注入，适合在对象内部继续使用 `get_model()` / `get_utility()`。工厂默认是 transient，也可通过 `GFBindingLifetimes.Lifetime.SINGLETON` 注册为单例工厂。

需要检查大型装配是否缺依赖时，可以让模块选择实现 `get_required_dependencies()` 或 `get_required_models/systems/utilities/factories()`，再调用 `GFArchitecture.get_dependency_diagnostics()` 生成只读报告。它只做诊断，不改变注册和初始化行为。

## 常用模块

- `GFBigNumber`：适合挂机/放置游戏的尾数 + 指数大数值对象。
- `GFFixedDecimal`：适合货币、税率与经营数值的定点小数值对象。
- `GFNumberFormatter`：统一的完整显示、紧凑缩写、科学计数法格式化工具。
- `GFVariantData` / `GFVariantJsonCodec`：Variant 深拷贝、默认值合并、Vector/Color 数组转换和类型化 JSON codec。
- `GFRichTextFormatter`：RichTextLabel BBCode 安全转义、Markdown 子集转换、变量占位符和 token 替换辅助。
- `GFProgressionMath`：价格曲线、收益曲线、里程碑倍率、软上限与分段离线收益结算工具。
- `GFTagSet` / `GFTagQuery` / `GFTagSourceAdapter`：通用标签集合、all/any/none 查询和多来源标签适配。
- `GFBlackboardEntry` / `GFBlackboardSchema`：通用黑板字段契约、默认值补齐、类型转换和字典校验。
- `GFGridMath`：网格索引、邻居、泛洪、BFS 与两折连线等纯算法工具。
- `GFGridOccupancy` / `GFPattern2D` / `GFTileMapCache` / `GFTileRuleSet` / `GFSpatialHash3D`：通用格子占用、二维格子模式、瓦片数据快照/差分、邻域规则匹配与 3D 空间哈希结构，可用于棋盘、战棋、推箱子、解谜、自动铺砖和大量 3D 实体粗筛查询。
- `GFSteeringAgent` / `GFSteeringAcceleration` / `GFSteeringMath`：seek、flee、arrive、pursue、evade、face、分离、聚合、动态避碰、混合和路径跟随等纯 steering 计算原语。
- `GFFormula` / `GFFormulaSet`：资源化公式与参数容器，适合把可替换计算策略从系统逻辑中抽离。
- `GFTypeEventSystem`：强类型事件与轻量 `StringName` 事件。
- `GFBindableProperty` / `GFReactiveEffect` / `GFComputedProperty`：响应式属性、组合副作用和只读派生属性，适合 Model 到 UI 的局部数据绑定。
- `GFAssetUtility`：异步资源加载与 LRU 缓存。
- `GFRemoteCacheUtility`：通用远程文本/JSON 请求、本地 TTL 缓存与失败回退。
- `GFRequestEnvelope` / `GFRequestOutboxUtility`：通用离线请求队列、持久化、重试和 transport callback 边界。
- `GFNodeTreeOps`：通用节点树添加、重挂、替换、类型查找、遍历、owner 传播和子节点释放操作集合。
- `GFSignalUtility`：Godot 原生 Signal 的 owner 绑定、安全断开、批量连接、filter/map/delay/debounce/throttle/take/scan/once 链式处理。
- `GFJobQueueUtility` / `GFJob`：通用任务队列、进度、暂停、完成/失败/取消状态和诊断快照。
- `GFJobWorker`：场景节点形式的任务队列批处理消费器。
- `GFSceneUtility` / `GFSceneTransitionConfig` / `GFScenePreloadMap` / `GFScenePreloadEntry`：异步场景切换、后台预加载激活、预加载 LRU 缓存、相邻场景预加载图谱、切换参数、场景历史、资源化切换配置、加载状态快照与瞬态模块清理。
- `GFUIUtility` / `GFUIRouterUtility` / `GFUIRoute`：分层 UI 栈、Modal/焦点策略、面板打开选项、路由 ID 到面板场景映射和轻量路由历史。
- `GFSurfaceUtility`：根据 3D 碰撞 face index 查询 Mesh surface 与材质，不绑定材质业务语义。
- `GFStorageUtility` / `GFStorageCodec` / `GFStorageSyncUtility` / `GFSnapshotHistoryUtility` / `GFSaveGraphUtility` / `GFSaveSlotWorkflow`：槽位存档、元数据、读档卡片 DTO、事务恢复、Resource 存取、通用文件管理、完整性校验、版本迁移、可配置编码、双后端同步协调、通用快照历史、通用节点存档图编排、默认节点序列化器、存档 pipeline trace 和结构诊断。
- `GFLevelUtility`：关卡开始、重开、胜负信号与常见运行时残留清理。
- `GFSettingsUtility` / `GFDisplaySettingsUtility`：抽象设置注册、持久化、显示/语言/音频应用，以及设置界面控件绑定辅助。
- `GFObjectPoolUtility`：节点对象池。
- `GFAudioUtility` / `GFAudioEmitterHandle` / `GFAudioBankMounter`：BGM/SFX/环境音播放、BGM 淡入淡出与历史、资源化音频片段/集合、音频事件 ID、播放句柄、owner 绑定释放、场景级音频集合挂载、候选权重、pitch 随机、2D/3D 空间 SFX 与可选声源跟随、音量总线、SFX 对象池与并发上限控制。
- `GFInputMappingUtility` / `GFVirtualInputSource` / `GFInputRecording` / `GFInputPlayback` / `GFInputAction` / `GFInputContext` / `GFInputFormatter` / `GFInputDeviceTextProvider` / `GFInputConflictAnalyzer`：资源化输入动作、上下文切换、虚拟输入源、抽象动作录制回放、运行时重绑定、一维/二维/三维动作值、修饰器、触发器、手柄文本、文本/图标 provider、冲突分析与重绑定报告、全局与玩家级动作状态查询。
- `GFInputDeviceUtility` / `GFInputDirectionHistory` / `GFTouchJoystick` / `GFTouchButton`：本地设备席位映射、最后按下方向优先仲裁、活跃玩家追踪、通用触屏虚拟摇杆与触屏按钮。
- `GFAnalyticsUtility`：通用事件采集、稳定 client id、批量 flush、本地 dry-run、传输 hook 与可选 HTTP 上报。
- `GFCommandHistoryUtility`：可撤销命令历史。
- `GFCommandSequence`：顺序执行 `GFSequenceStep`、命令对象或任意 callable 的通用流程编排器，支持失败策略、运行报告和可选回滚。
- `GFFlowGraph` / `GFFlowNode` / `GFFlowPort` / `GFFlowRunner` / `GFFlowGraphEditorModel`：资源化通用流程图执行基础、端口描述、连接表、拓扑诊断和编辑器视图模型。
- `GFActionQueueSystem` / `GFActionInterceptor` / `GFActionInterceptionResult` / `GFAction` / `GFTweenActionConfig`：表现动作队列、执行拦截器、常见动作工厂、配置化 Tween 步骤和可复用表现动作资源。
- `GFShakePreset` / `GFShakeUtility` / `GFShakeAction`：通用反馈采样、命名 channel 播放和动作队列入口。
- `GFActionQueueSystem` 命名队列：可为战斗、对白、教程等不同表现流创建独立队列，并支持绑定节点生命周期。
- `GFMoveTweenAction` / `GFFlashAction` / `GFAudioAction` / `GFWaitAction` / `GFRepeatAction`：常见队列表现动作。
- `GFStateMachine` / `GFState`：纯代码分层状态机，支持父子状态路径、最近公共祖先切换、进入/退出守卫、事件上抛、黑板和调试快照。
- `GFNodeStateMachine` / `GFNodeStateGroup` / `GFNodeState` / `GFNodeStateCondition` / `GFNodeStateBehavior`：面向场景树的可选状态机扩展，支持配置资源、状态历史、栈式子状态、守卫、Resource 条件/行为钩子、黑板、状态事件分发、快照与节点宿主访问。
- `GFConsoleUtility` / `GFConsoleCommandDefinition` / `GFLogUtility`：运行时开发者控制台与集中式日志，支持资源化命令定义、命令注册、日志接入、标签过滤、输出行数上限和内存日志环形缓存。
- `GFCombatSystem` / `GFHitBox2D` / `GFHurtBox2D`：轻量战斗扩展与通用命中上下文桥接。
- `GFCapabilityUtility`：对象能力组件管理，可为任意 Object/Node 挂载、启停、索引查询、Recipe 组合和诊断可复用能力。
- `GFCapabilityContainer`：场景树能力容器，支持把子节点注册为父节点能力。
- `GFNodeCapability`：可直接作为场景节点使用的能力基类，适合碰撞、输入、动画和子节点引用。
- `GFPropertyBagCapability`：轻量动态属性包能力，适合原型、调试和少量运行时键值。
- `GFInteractionContext` / `GFInteractionSensor` / `GFInteractionReceiver` / `GFPointerInteraction3D`：轻量交互上下文与通用交互收发节点，便于在命令、事件、能力方法、RayCast/Area 检测、3D 指针事件或场景节点之间传递 sender、target 与 payload。
- `GFInteractions`：交互上下文与链式交互流程创建入口。
- `GFTurnFlowSystem`：通用回合阶段与行动解析流程系统。
- `GFNetworkUtility` / `GFNetworkBackend` / `GFENetNetworkBackend` / `GFWebSocketNetworkBackend` / `GFNetworkReconnectPolicy`：可插拔网络后端、可选 ENet/WebSocket 传输、通用消息载体、消息序列化、会话/通道描述、消息校验、限流基础、重连退避策略和调试快照。
- `GFBuildInfo` / `GFBuildInfoUtility` / `GFBuildInfoExportPlugin`：构建信息快照、可选 Git 元数据写入辅助和导出时元数据入口，用于诊断、日志、存档元数据或项目版本界面。
- `GFDiagnosticsUtility`：运行时构建、架构、事件、性能、日志和可选网络状态快照，以及带等级和认证治理的可注册诊断命令。
- `GFNotificationUtility`：通用通知队列、去重、时长推进和生命周期信号，不规定具体 UI 表现。
- `GFViewportUtility`：通用 SubViewport 分屏布局、相机挂载、后处理材质和调试快照。
- `GFInventoryModel` / `GFSlotInventoryModel` / `GFInventoryItemRegistry` / `GFLevelProgressModel` / `GFAttributeSet` / `GFTraitSet` / `GFEquipmentSet`：计数库存、槽位库存、关卡进度、数值属性、特征和槽位的通用数据模型。
- `GFGravityField3D` / `GFGravityProbe3D`：通用 3D 加速度场和采样器，可用于局部重力、风场、磁场或自定义空间力场。
- `GFThumbnailRenderer` / `GFPattern2D` Inspector：可复用的编辑器 3D/Mesh/MeshLibrary 缩略图渲染辅助节点，以及二维格子模式网格编辑器。
- `GFAccessGenerator`：编辑器强类型访问器生成器，通过 `工具 > GF > 生成强类型访问器` 和 `生成项目常量访问器` 菜单生成 `GFAccess` / `GFProjectAccess`。

## 源码布局

- `addons/gf/kernel`：GF 运行内核，包含基础模块契约、架构容器、绑定、事件、Autoload 入口和编辑器集成。
- `addons/gf/standard`：随 GF 稳定提供的标准库，包含 `foundation`、`input`、`utilities`、`state_machine`、命令、序列和通用支撑原语。
- `addons/gf/packages/official`：随 GF 发布但和内核/标准库保持边界的官方包，例如战斗、存档、网络、流程图、能力、交互、行为树、动作队列、反馈、物理、回合制和通用领域模型。包根只放 manifest、说明和可选安装器，代码进入 `runtime`、`resources`、`nodes`、`editor` 或包内稳定领域目录。
- `addons/gf/packages/community`：项目本地或第三方包的约定位置，包应提供 `gf_package.json` 并遵循 GF 包目录规范。

## 测试

测试使用 GUT。若本地没有 `addons/gut`，请先安装 GUT 插件，再运行：

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gf_core -ginclude_subdirs -gexit
```

`tests/gf_core` 的目录结构和框架层级对应：`kernel`、`standard`、`packages/official` 与 `maintenance` 分别覆盖内核、标准库、官方包和静态维护检查。

## 文档

更完整的设计说明在根目录 `docs/wiki`：

> GitHub Wiki 的页面标题由文件名决定，因此本目录中的 Wiki 页面文件名采用“可直接展示”的标题命名，而不是下划线式文档名。

- `Home.md`
- `01. 架构概览 (Architecture).md`
- `02. 生命周期与初始化 (Lifecycle).md`
- `04. 事件系统 (Event System).md`
- `11. 基础层 (Foundation Layer).md`
- `08. 实用工具箱 (Utility Toolkit).md`
- `12. 能力组件 (Capabilities).md`
- `更新日志 (Changelog).md`
