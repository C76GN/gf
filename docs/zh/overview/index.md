# 总览与快速开始

本页是 GF 文档的第一篇上手教程：把插件放进项目、启用 `Gf` AutoLoad、注册最小模块，并知道下一步该读哪一页。

如果想先了解完整文档地图、源码分层和所有页面职责，请从 [Home](../index.md) 开始。

## 你会用到什么

- `Gf`：全局 AutoLoad 入口。
- `GFModel`：保存项目状态。
- `GFSystem`：处理规则、事件、命令和逐帧逻辑。
- `GFUtility`：提供存档、资源、时间、日志等运行时服务。
- `GFInstaller`：集中装配项目或扩展的模块。

## 安装

将 `addons/gf` 复制到目标项目，然后在 Godot 的 `Project > Project Settings > Plugins` 中启用 `GF Framework`。

插件启用后会自动注册：

```text
Gf -> res://addons/gf/kernel/core/gf.gd
```

插件也会默认打开独立的 `GF Workspace`，其中 `GF Extensions` 页面用于查看扩展信息、启用或禁用扩展、控制扩展 Installer 是否自动装配，以及控制导出时是否排除禁用扩展。扩展机制的完整说明见 [GF 内置扩展总览与扩展规范](../extensions/index.md)。

## 最小启动

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

这个例子表达的是最小流程：

1. 注册 `GFModel`、`GFUtility` 和 `GFSystem`。
2. 调用 `await Gf.init()` 进入生命周期。
3. 从架构取回模块时使用 `as Type` 保留补全和显式失败处理。

真实项目通常不会把所有注册写在某个场景 `_ready()` 里，而是使用 Installer。

## 使用 Installer

如果项目需要统一装配，可以创建 `GFInstaller`：

```gdscript
class_name GameInstaller
extends GFInstaller


func install(architecture: GFArchitecture) -> void:
	architecture.register_model_instance(PlayerModel.new())
	architecture.register_utility_instance(GFStorageUtility.new())
	architecture.register_system_instance(BattleSystem.new())
```

然后把安装器路径加入 `Project Settings > gf/project/installers`。调用 `await Gf.init()` 时，GF 会先运行启用扩展的 Installer，再运行项目 Installer，最后进入模块生命周期。

Installer 只负责注册模块，不应该直接启动关卡、打开 UI 或执行玩法流程。启动流程更适合放在引导场景或专门的 `GFSystem` 中。

## 下一步

- 想理解容器和分层边界：读 [Kernel 架构容器](../kernel/index.md)。
- 想理解 Installer、三阶段初始化和局部架构：读 [生命周期、装配与依赖](../kernel/lifecycle/index.md)。
- 想写事件、命令和查询：读 [消息、事件、命令与查询](../kernel/messaging/index.md)。
- 想把场景节点、UI 和输入接入 GF：读 [场景桥接、Controller 与数据绑定](../kernel/scene-controller/index.md)。
- 想查标准库或 GF 内置扩展能力：回到 [Home](../index.md) 按主题查阅。

## 上手原则

- 纯算法和纯数据优先放在 `standard/foundation` 或扩展内 `foundation`。
- 需要生命周期、缓存、异步、事件或跨模块复用的能力放入 `GFUtility`。
- 具体玩法规则放在项目的 `Model` / `System` / `Controller` 中。
- 可复用但不是所有项目都需要的通用能力，优先作为扩展维护。
