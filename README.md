# GF Framework

GF Framework is a lightweight game architecture framework for Godot 4. It keeps data, logic, presentation, runtime services, and pure algorithm utilities in clear layers so larger projects can keep predictable lifecycles and dependency boundaries.

## English Overview

- `Foundation`: pure value objects, algorithms, resourceized formulas, formatting helpers, big numbers, fixed decimals, progression curves, tile/grid helpers, spatial hashes, and offline reward calculations.
- `GFModel`: data layer for game state, snapshots, and save/restore methods through `to_dict()` / `from_dict()`.
- `GFSystem`: logic layer for rules, events, commands, queries, and frame-based updates.
- `GFController`: presentation layer based on `Node`, connecting Godot scenes, UI, input, and framework data.
- `GFUtility`: runtime services such as storage, save graph composition, resource loading, remote caching, time, object pools, UI stack handling, audio, input, logging, and diagnostics.

## Installation

Copy `addons/gf` into your Godot project, then enable `GF Framework` from `Project > Project Settings > Plugins`.

Godot does not automatically enable editor plugins that are copied into a project. This is expected: plugin enablement is stored in the target project's `project.godot`, and the user must opt in before editor plugin code runs.

When the plugin is enabled, it registers the `Gf` AutoLoad automatically:

```text
Gf -> res://addons/gf/core/gf.gd
```

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

GF Framework includes lifecycle-managed models, systems, controllers, utilities, typed events, bindable properties with computed/effect helpers, commands and queries, state machines with guards, command sequences, turn-flow helpers, action queues with resourceized tween configs, object pooling, scene switching with preload caching and transition configs, storage helpers, save slot workflows, save graph composition, pipeline traces and diagnostics, settings and display adapters, audio banks with BGM/ambient helpers, player-scoped input mapping with modifiers/triggers, conflict reports and formatter providers, debug draw command buffering, analytics events, capability components with inspection reports, interaction flows, resourceized flow graphs with ports/connections, optional ENet network transport with session/channel metadata, runtime diagnostics, notification queues, lightweight combat helpers, generic domain models, grid/tile primitives, 3D spatial hashing, 3D surface material lookup, and editor tools for typed accessor generation.

## Testing

The test suite uses GUT:

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gf_core -ginclude_subdirs -gexit
```

## 中文说明

GF Framework 是一个面向 Godot 4 的轻量级游戏架构框架，核心目标是把数据、逻辑、表现、运行时服务和纯算法基础件拆开管理，让项目在规模变大后仍然保持清晰的生命周期和依赖边界。

## 核心分层

- `Foundation`：纯值对象、纯算法、资源化公式和纯格式化工具，不参与 `GFArchitecture` 注册，适合承载大数、定点数、显示格式化、价格/收益曲线与离线收益结算等基础件。
- `GFModel`：数据层，保存游戏状态，提供 `to_dict()` / `from_dict()` 用于存档与快照。
- `GFSystem`：逻辑层，处理业务规则、事件响应、命令执行和逐帧逻辑。
- `GFController`：表现层，继承 `Node`，连接 Godot 场景树、UI、输入和框架数据。
- `GFUtility`：工具层，提供存档、资源加载、远程缓存、时间控制、对象池、UI 栈、日志等通用能力。

## 安装

将 `addons/gf` 复制到目标 Godot 项目的 `addons` 目录，然后在 Godot 的 `Project > Project Settings > Plugins` 中启用 `GF Framework`。

Godot 不会自动启用被复制到项目中的编辑器插件，这是正常行为。插件启用状态属于目标项目的 `project.godot` 配置，需要用户在插件面板中明确启用后，编辑器插件代码才会运行。

插件启用后会自动注册 `Gf` AutoLoad。也可以手动在项目设置中添加：

```text
Gf -> res://addons/gf/core/gf.gd
```

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

然后在 `Project Settings > gf/project/installers` 中加入该脚本路径。调用 `await Gf.init()` 或 `await Gf.set_architecture(arch)` 时，框架会在生命周期初始化前自动执行安装器。

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

## 常用模块

- `GFBigNumber`：适合挂机/放置游戏的尾数 + 指数大数值对象。
- `GFFixedDecimal`：适合货币、税率与经营数值的定点小数值对象。
- `GFNumberFormatter`：统一的完整显示、紧凑缩写、科学计数法格式化工具。
- `GFProgressionMath`：价格曲线、收益曲线、里程碑倍率、软上限与分段离线收益结算工具。
- `GFGridMath`：网格索引、邻居、泛洪、BFS 与两折连线等纯算法工具。
- `GFGridOccupancy` / `GFTileMapCache` / `GFTileRuleSet` / `GFSpatialHash3D`：通用格子占用、预约、瓦片数据快照/差分、邻域规则匹配与 3D 空间哈希结构，可用于棋盘、战棋、推箱子、解谜、自动铺砖和大量 3D 实体粗筛查询。
- `GFFormula` / `GFFormulaSet`：资源化公式与参数容器，适合把可替换计算策略从系统逻辑中抽离。
- `TypeEventSystem`：强类型事件与轻量 `StringName` 事件。
- `BindableProperty` / `GFReactiveEffect` / `GFComputedProperty`：响应式属性、组合副作用和只读派生属性，适合 Model 到 UI 的局部数据绑定。
- `GFAssetUtility`：异步资源加载与 LRU 缓存。
- `GFRemoteCacheUtility`：通用远程文本/JSON 请求、本地 TTL 缓存与失败回退。
- `GFSignalUtility`：Godot 原生 Signal 的 owner 绑定、安全断开、filter/map/delay/debounce/once 链式处理。
- `GFSceneUtility` / `GFSceneTransitionConfig`：异步场景切换、预加载 LRU 缓存、资源化切换配置、加载状态快照与瞬态模块清理。
- `GFSurfaceUtility`：根据 3D 碰撞 face index 查询 Mesh surface 与材质，不绑定材质业务语义。
- `GFStorageUtility` / `GFStorageCodec` / `GFSaveGraphUtility` / `GFSaveSlotWorkflow`：槽位存档、元数据、读档卡片 DTO、事务恢复、Resource 存取、完整性校验、版本迁移、可配置编码、通用节点存档图编排、默认节点序列化器、存档 pipeline trace 和结构诊断。
- `GFLevelUtility`：关卡开始、重开、胜负信号与常见运行时残留清理。
- `GFSettingsUtility` / `GFDisplaySettingsUtility`：抽象设置注册、持久化、显示/语言/音频应用，以及设置界面控件绑定辅助。
- `GFObjectPoolUtility`：节点对象池。
- `GFAudioUtility`：BGM/SFX/环境音播放、BGM 淡入淡出与历史、资源化音频片段/集合、音量总线、SFX 对象池与并发上限控制。
- `GFInputMappingUtility` / `GFInputAction` / `GFInputContext` / `GFInputFormatter` / `GFInputConflictAnalyzer`：资源化输入动作、上下文切换、运行时重绑定、一维/二维/三维动作值、修饰器、触发器、文本/图标 provider、冲突分析与重绑定报告、全局与玩家级动作状态查询。
- `GFInputDeviceUtility` / `GFTouchJoystick` / `GFTouchButton`：本地设备席位映射、活跃玩家追踪、通用触屏虚拟摇杆与触屏按钮。
- `GFAnalyticsUtility`：通用事件采集、稳定 client id、批量 flush、本地 dry-run、传输 hook 与可选 HTTP 上报。
- `GFCommandHistoryUtility`：可撤销命令历史。
- `GFCommandSequence`：顺序执行 `GFSequenceStep`、命令对象或任意 callable 的通用流程编排器，支持失败策略、运行报告和可选回滚。
- `GFFlowGraph` / `GFFlowNode` / `GFFlowPort` / `GFFlowRunner`：资源化通用流程图执行基础、端口描述、连接表和图结构校验。
- `GFActionQueueSystem` / `GFTweenActionConfig`：表现动作队列、配置化 Tween 步骤和可复用表现动作资源。
- `GFActionQueueSystem` 命名队列：可为战斗、对白、教程等不同表现流创建独立队列，并支持绑定节点生命周期。
- `GFMoveTweenAction` / `GFFlashAction` / `GFAudioAction`：常见队列表现动作。
- `GFNodeStateMachine` / `GFNodeStateGroup` / `GFNodeState`：面向场景树的可选状态机扩展，支持配置资源、状态历史、栈式子状态、守卫、黑板与节点宿主访问。
- `GFConsoleUtility` / `GFConsoleCommandDefinition` / `GFLogUtility`：运行时开发者控制台与集中式日志，支持资源化命令定义、命令注册、日志接入、标签过滤、输出行数上限和内存日志环形缓存。
- `GFCombatSystem`：轻量战斗扩展。
- `GFCapabilityUtility`：对象能力组件管理，可为任意 Object/Node 挂载、启停、索引查询和诊断可复用能力。
- `GFCapabilityContainer`：场景树能力容器，支持把子节点注册为父节点能力。
- `GFNodeCapability`：可直接作为场景节点使用的能力基类，适合碰撞、输入、动画和子节点引用。
- `GFPropertyBagCapability`：轻量动态属性包能力，适合原型、调试和少量运行时键值。
- `GFInteractionContext`：轻量交互上下文，便于在命令、事件或能力方法之间传递 sender、target 与 payload。
- `GFInteractions`：交互上下文与链式交互流程创建入口。
- `GFTurnFlowSystem`：通用回合阶段与行动解析流程系统。
- `GFNetworkUtility` / `GFNetworkBackend` / `GFENetNetworkBackend`：可插拔网络后端、可选 ENet 传输、通用消息载体、消息序列化、会话/通道描述、消息校验、限流基础和调试快照。
- `GFDiagnosticsUtility`：运行时架构、事件、性能、日志和可选网络状态快照，以及带等级和认证治理的可注册诊断命令。
- `GFNotificationUtility`：通用通知队列、去重、时长推进和生命周期信号，不规定具体 UI 表现。
- `GFInventoryModel` / `GFLevelProgressModel` / `GFAttributeSet` / `GFTraitSet` / `GFEquipmentSet`：库存、关卡进度、数值属性、特征和槽位的通用数据模型。
- `GFThumbnailRenderer`：可复用的编辑器 3D/Mesh/MeshLibrary 缩略图渲染辅助节点。
- `GFAccessGenerator`：编辑器强类型访问器生成器，通过 `工具 > GF > 生成强类型访问器` 和 `生成项目常量访问器` 菜单生成 `GFAccess` / `GFProjectAccess`。

## 测试

测试使用 GUT。若本地没有 `addons/gut`，请先安装 GUT 插件，再运行：

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gf_core -ginclude_subdirs -gexit
```

## 文档

更完整的设计说明在 `addons/gf/docs/wiki`：

> GitHub Wiki 的页面标题由文件名决定，因此本目录中的 Wiki 页面文件名采用“可直接展示”的标题命名，而不是下划线式文档名。

- `Home.md`
- `01. 架构概览 (Architecture).md`
- `02. 生命周期与初始化 (Lifecycle).md`
- `04. 事件系统 (Event System).md`
- `11. 基础层 (Foundation Layer).md`
- `08. 实用工具箱 (Utility Toolkit).md`
- `12. 能力组件 (Capabilities).md`
- `更新日志 (Changelog).md`
