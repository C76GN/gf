# 08. 实用工具箱 (Utility Toolkit)

GF Framework 的核心极具克制，但针对实际 Godot 开发中屡屡遇到的通用需求问题，在 `addons/gf/utilities/` 下提供了一组被广泛验证过的 "开箱即用" 的原生工具组件。

工具在使用前需确保在启动时被注册进了主容器： `Gf.register_utility(...)`。

---

## 1. 异步按需加载缓存池 (`GFAssetUtility`)

**应用场景：** 当你要按需实例化特效，加载图标，为了防止卡顿，你决定拥抱 `ResourceLoader` 放在子线程里做。但是管理起来由于各种竞态条件导致异常崩溃。

**如何使用：**

```gdscript
var assets := Gf.get_utility(GFAssetUtility) as GFAssetUtility

# 异步加载一个带路径的资源（例如怪物Prefab）。如果缓存已有直接吐出，
# 如果正在被别人加载，则一起等待那一个完成；如果没有，在无阻塞线程中拉起请求。
var monster_scene = await assets.load_asset_async("res://enemies/goblin.tscn")
```
它内置了 LRU （最近最少使用）算法上限，当缓存过大时会自动清理长期未被提取引用的资源。

## 2. 脱离时间的独立定时器 (`GFTimerUtility`)

**应用场景：** Node 自带的 `get_tree().create_timer(1.0).timeout` 是与场景绑定的。如果在等待中更换了场景树，通常会导致意想不到的内存泄露或报错。如果你需要一个受 `GFTimeUtility` (见下条) 控制的、可以在任何代码纯纯等待周期的定时器，请用它。

**如何使用：**
```gdscript
var timer_util := Gf.get_utility(GFTimerUtility) as GFTimerUtility

# 完全纯代码、与场景节点无关的安全等待
await timer_util.delay(1.5)
print("1.5秒真实时间后触发")
```

## 3. 动态时间缩放流 (`GFTimeUtility`)

**应用场景：** 实现子弹时间、暂停特定组内的系统、在受击时定帧 (Hit Stop)。

**如何使用：**
```gdscript
var time_scale_util := Gf.get_utility(GFTimeUtility) as GFTimeUtility
# 将包含战斗组标签的系统帧率全部放慢 10 倍！
time_scale_util.set_time_scale_by_group("CombatSystems", 0.1) 
```

## 4. 节点对象池 (`GFObjectPoolUtility`)

**应用场景：** 子弹、伤害飘字、特效。不要频繁的进行性能极其昂贵的 `queue_free()` 和 `instantiate()`。

```gdscript
var pool := Gf.get_utility(GFObjectPoolUtility) as GFObjectPoolUtility

# 借出一个实例
var bullet = pool.get_instance(bullet_scene) as Node2D

# 归还它进入休眠
pool.return_instance(bullet_scene, bullet)
```

## 5. 增强存档管理器 (`GFStorageUtility`)

内置跨段存档系统（支持 PC 上的二进制与文件写入以及 HTML5 的本地 localStorage 隔离）。能够将 `Model` 直接转化为字典后序列化至磁盘，安全地加载回来。
新版支持多槽位存储、元文件分离（在存档列表 UI 只需读取 Metadata 即可，不用加载上 MB 体积的 `data.json`），以及防篡改的简单的基线级别的 Base64 XOR 加密。
同时原生支持 Godot 的 `Resource` 类型（如 `.tres` 或 `.res`）的直接存取。

**如何使用：**
```gdscript
var storage := Gf.get_utility(GFStorageUtility) as GFStorageUtility

# -- 字典与槽位存档 --
# 保存槽位，后一个字典是高层预览专用的 Metadata
storage.save_slot(1, {"player_hp": 100}, {"play_time": "12:00", "level": 5})

# 在读档选单展示
var meta := storage.load_slot_meta(1)
print(meta.get("level"))

# 正式进入游戏后提取极大的核心数据字典
var full_data := storage.load_slot(1)

# -- Resource 存档 --
var my_res := Resource.new()
storage.save_resource("my_custom_resource.tres", my_res)

var loaded_res := storage.load_resource("my_custom_resource.tres")
```

## 6. 输入与土狼时间 (`GFInputUtility`)

通过引入 Action 缓冲池，让动作游戏的连招手感倍增。允许玩家在硬直动作快结束前提早按下按钮，动作结束后立即顺滑接续。

## 7. 逻辑四叉树 (`GFQuadTreeUtility`)

抛开需要碰撞体积的 Godot Area2D 体系；对于上千同屏单位仅仅用于查询范围索敌时，可以使用这个纯代码的二维空间分桶查询算法加速！

## 8. 基于栈的 UI 管理系统 (`GFUIUtility`)

**应用场景：** 当你需要管理复杂的全屏UI、弹窗、顶层提示，处理多层级（HUD、POPUP、TOP）入栈出栈，以及自动隐藏下层UI以实现全屏UI时。

**如何使用：**
```gdscript
var ui_util := Gf.get_utility(GFUIUtility) as GFUIUtility

# 异步推入一个面板到 POPUP 层（自动结合 GFAssetUtility 加载面板）
ui_util.push_panel_async("res://ui/settings_panel.tscn", GFUIUtility.Layer.POPUP)

# 或者是直接同步推入已实例化的面板
ui_util.push_panel("res://ui/inventory_panel.tscn", GFUIUtility.Layer.POPUP)

# 弹出栈顶面板
ui_util.pop_panel(GFUIUtility.Layer.POPUP)
```

## 9. 场景与流程切换管理器 (`GFSceneUtility`)

**应用场景：** 当你需要进行游戏的大关卡/大场景切换，且希望播放一个过渡 Loading UI（后台预加载），而且在切换时要把旧场景专用系统（如 `BattleSystem`）清理出框架时。

**如何使用：**
```gdscript
var scene_util := Gf.get_utility(GFSceneUtility) as GFSceneUtility

# 标记 BattleSystem 为瞬态，它会在切场景时自动从架构中被注销/销毁
scene_util.mark_transient(BattleSystem)

# 开始带 Loading 过渡的异步切换
scene_util.load_scene_async("res://levels/level_2.tscn", "res://ui/loading_screen.tscn")
```

## 10. 全局音频管理器 (`GFAudioUtility`)

**应用场景：** 处理 BGM 切歌与自动交叉淡入淡出（通过内部机制），并在 SFX 播放时自动处理 `AudioStreamPlayer` 的基于 `GFObjectPoolUtility` 的池化复用，杜绝卡顿。

**如何使用：**
```gdscript
var audio := Gf.get_utility(GFAudioUtility) as GFAudioUtility

# 异步无阻加载并播放背景音乐 (放入 BGM Bus)
audio.play_bgm("res://audio/bgm/battle.ogg")

# 从池子里分配一个播放器来播放音效 (放入 SFX Bus)
audio.play_sfx("res://audio/sfx/hit.wav")

# 设置总线音量 (0.0~1.0 标准化线性音量)
audio.set_bus_volume("SFX", 0.8)
audio.set_bus_volume("BGM", 0.5)
```

## 11. 内部通信控制台 (`GFDebugOverlayUtility`)

**应用场景：** 当你在运行游戏时觉得变量状态不对劲，但没有连上编辑器检查时。本工具利用纯代码提供一个轻量级 GUI，利用反射扫描目前所有存在于框架内的 `GFModel` 及其用户变量。

**如何使用：**
```gdscript
var debug := Gf.get_utility(GFDebugOverlayUtility) as GFDebugOverlayUtility
# 开启（在游戏里按下 `~` 波浪号键即可呼出/隐藏透明面板）
```

## 12. 纯代码行为树 (`GFBehaviorTree`)

**应用场景：** 当你需要为敌人或者 NPC 编写非状态机的、更复杂的优先级逻辑 AI 时，无需臃肿的图形化编辑器插件，直接用代码组装极简的行为树逻辑。

**如何使用：**
```gdscript
var check_hp := GFBehaviorTree.Condition.new(func(bb): return bb.hp < 30)
var flee_act := GFBehaviorTree.Action.new(func(bb):
    print("Fleeing!")
    return GFBehaviorTree.Status.SUCCESS
)
var attack_act := GFBehaviorTree.Action.new(func(bb):
    print("Attacking!")
    return GFBehaviorTree.Status.SUCCESS
)

# 如果 hp < 30，则逃跑 (Sequence)。否则，这个 Sequence 会 Fail，Selector 就会去执行 attack_act。
var root := GFBehaviorTree.Selector.new([
    GFBehaviorTree.Sequence.new([check_hp, flee_act]),
    attack_act
])

var runner := GFBehaviorTree.Runner.new(root)
runner.blackboard = {"hp": 100}

# 在 System 中每帧驱动它
runner.tick()
```

## 13. 任务与进度管理 (`GFQuestUtility`)

**应用场景：** 当你需要构建一个成就、任务及进度累加系统，且希望它基于解耦的数据事件框架（如每一次击杀发送一条轻量级事件）时。

**如何使用：**
```gdscript
var quest := Gf.get_utility(GFQuestUtility) as GFQuestUtility

# 开始一个任务，监听 "enemy_died" 事件，目标为 10 次
quest.start_quest(&"kill_slimes", &"enemy_died", 10)

# 在敌人的死亡逻辑中
Gf.send_simple_event(&"enemy_died", 1)

# 获取进度或判断完成
var progress := quest.get_quest_progress(&"kill_slimes")
var done := quest.is_quest_completed(&"kill_slimes")
```

## 14. 通用的静态导表数据适配器 (`GFConfigProvider`)

**应用场景：** 为了让框架无缝衔接不同项目的导表工具（JSON, CSV, Luban 等），提供统一的读取接口。具体项目应该继承此基类，并实现其数据加载和查询逻辑。

**如何使用：**
```gdscript
class_name JSONConfigProvider
extends GFConfigProvider

var _configs: Dictionary = {}

func async_init() -> void:
    # 异步加载你的表...
    pass

func get_record(table_name: StringName, id: Variant) -> Variant:
    if _configs.has(table_name) and _configs[table_name].has(id):
        return _configs[table_name][id]
    return null

func get_table(table_name: StringName) -> Variant:
    return _configs.get(table_name)
```

## 15. 全局随机数种子管理器 (`GFSeedUtility`)

**应用场景：** 当你需要管理全局随机流以保证游戏的核心随机事件（如掉落、遇敌、甚至战斗回放）具有确定性和可观测性时。它支持恢复指定的随机序列状态，并且可以通过标签派生出完全独立的子随机发生器。

**如何使用：**
```gdscript
var seed_util := Gf.get_utility(GFSeedUtility) as GFSeedUtility

# 设置全局主种子
seed_util.set_global_seed(12345)

# 可以随时获取当前的主种子
var current_seed := seed_util.get_global_seed()

# 获取并保存当前主 RNG 的精确内部状态，为稍后的回放或状态恢复做准备
var current_state := seed_util.get_state()

# ...进行一系列随机操作...

# 恢复此前保存的状态，使得接下来的随机序列能完全复现
seed_util.set_state(current_state)

# 派生出一个专门用于某模块的子 RNG
var combat_rng := seed_util.get_branched_rng("combat_calculations")
print(combat_rng.randi())
```

## 16. 集中式日志系统 (`GFLogUtility`)

**应用场景：** 当你厌倦了散落在各处的 `print` / `push_error`，需要统一分级日志输出、自动写入本地文件以便事后排查，并让运行时控制台也能同步显示时。

初始化时会在 `user://logs/` 下创建按日期时间命名的日志文件，并自动清理超出保留数量的旧日志。通过信号 `log_emitted` 广播每条日志，供 `GFConsoleUtility` 等消费者着色回显。

**如何使用：**
```gdscript
var log_util := Gf.get_utility(GFLogUtility) as GFLogUtility

# 各等级日志 —— 第一个参数是标签（推荐用类名或模块名），第二个是消息内容
log_util.debug("CombatSystem", "伤害计算开始。")
log_util.info("SaveManager", "存档写入成功。")
log_util.warn("Network", "延迟过高：%d ms。" % latency)
log_util.error("AudioBus", "找不到总线: %s" % bus_name)
log_util.fatal("Core", "不可恢复的致命错误！")

# 监听日志信号（GFConsoleUtility 已自动监听）
log_util.log_emitted.connect(func(level: int, tag: String, msg: String) -> void:
    print("收到日志: [%d] %s - %s" % [level, tag, msg])
)

# 可选：调整最大日志文件保留数量（默认 10）
log_util.max_log_files = 20
```

## 17. 运行时开发者控制台 (`GFConsoleUtility`)

**应用场景：** 当你需要在运行中的游戏里快速执行调试指令、查看实时日志输出，而不想来回切换编辑器或依赖外部终端时。

按下 **F1**（可配置）即可呼出全屏半透明控制台，内置 `help`（列出所有指令）和 `clear`（清空输出）。支持自定义指令注册，同时自动接收 `GFLogUtility` 的日志信号并着色显示（Error/Fatal 红色、Warn 黄色、Debug 青色）。

**如何使用：**
```gdscript
var console := Gf.get_utility(GFConsoleUtility) as GFConsoleUtility

# 注册自定义指令 —— 回调签名: func(args: PackedStringArray) -> void
console.register_command("tp", func(args: PackedStringArray) -> void:
    if args.size() >= 2:
        var x := args[0].to_float()
        var y := args[1].to_float()
        player.global_position = Vector2(x, y)
, "传送玩家到指定坐标。用法: tp <x> <y>")

# 注销指令
console.unregister_command("tp")

# 也可以在代码中直接执行指令
console.execute_command("help")

# 可选：更换呼出快捷键（默认 F1）
console.toggle_key = KEY_F2
```

