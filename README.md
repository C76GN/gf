# GF Framework

GF Framework 是一个面向 Godot 4 的轻量级游戏架构框架，核心目标是把数据、逻辑、表现和通用工具拆开管理，让项目在规模变大后仍然保持清晰的生命周期和依赖边界。

## 核心分层

- `GFModel`：数据层，保存游戏状态，提供 `to_dict()` / `from_dict()` 用于存档与快照。
- `GFSystem`：逻辑层，处理业务规则、事件响应、命令执行和逐帧逻辑。
- `GFController`：表现层，继承 `Node`，连接 Godot 场景树、UI、输入和框架数据。
- `GFUtility`：工具层，提供存档、资源加载、时间控制、对象池、UI 栈、日志等通用能力。

## 安装

将 `addons/gf` 复制到目标 Godot 项目的 `addons` 目录，然后在 Godot 的 `Project > Project Settings > Plugins` 中启用 `GF Framework`。

插件启用后会注册 `Gf` AutoLoad。也可以手动在项目设置中添加：

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

## 常用模块

- `TypeEventSystem`：强类型事件与轻量 `StringName` 事件。
- `BindableProperty`：响应式属性，适合 Model 到 UI 的数据绑定。
- `GFAssetUtility`：异步资源加载与 LRU 缓存。
- `GFSceneUtility`：异步场景切换与瞬态模块清理。
- `GFObjectPoolUtility`：节点对象池。
- `GFCommandHistoryUtility`：可撤销命令历史。
- `GFActionQueueSystem`：表现动作队列。
- `GFCombatSystem`：轻量战斗扩展。

## 测试

测试使用 GUT。若本地没有 `addons/gut`，请先安装 GUT 插件，再运行：

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gf_core -ginclude_subdirs -gexit
```

## 文档

更完整的设计说明在 `addons/gf/docs/wiki`：

- `01_Architecture_Overview.md`
- `02_Lifecycle_Initialization.md`
- `04_Event_System.md`
- `08_Utility_Toolkit.md`
- `CHANGELOG.md`
