# Level、BehaviorTree 与 Quest

本页聚焦关卡流程、纯代码行为树和任务进度管理。
## 关卡流程管理器 (`GFLevelUtility`)

**应用场景：** 当你的项目有固定关卡概念，需要统一处理开始、重开、胜利、失败，并在重开时清理命令历史与项目显式注册的运行时残留。

**如何使用：**
```gdscript
var level := Gf.get_utility(GFLevelUtility) as GFLevelUtility

# 默认读取 GFConfigProvider 的 "levels" 表，也可以切换表名
level.configure(&"levels")

level.level_started.connect(func(level_id: Variant, data: Dictionary) -> void:
	print("Start level: ", level_id, data)
)

level.start_level(1)
level.restart_level()
level.win_current_level()
```

它只处理通用关卡流程边界，不负责生成地图、刷怪或胜负条件判断；这些具体玩法规则仍应放在项目自己的 `System` 中。
重开关卡时，它会重新读取配置或启动时传入的 override 数据副本，并清理命令历史。其他运行时残留应通过 `register_runtime_cleanup()` 显式接入，避免 Domain 扩展按扩展 ID 主动探测 ActionQueue 等其他可选扩展：

```gdscript
var actions := Gf.get_system(GFActionQueueSystem) as GFActionQueueSystem
level.register_runtime_cleanup(&"action_queue", func() -> void:
	actions.clear_queue(true)
	actions.clear_all_named_queues(true)
)
```

如果项目更适合用资源描述关卡列表，可以把 `GFLevelCatalog` 交给 `GFLevelUtility`。目录条目由 `GFLevelEntry` 描述，只保存稳定 ID、扩展 ID、场景路径、排序、元数据和完成后声明式解锁列表，不绑定具体玩法内容：

```gdscript
var catalog := GFLevelCatalog.new()
var level_entry := GFLevelEntry.new()
level_entry.level_id = &"level_1"
level_entry.scene_path = "res://levels/level_1.tscn"
catalog.add_entry(level_entry)

level.set_catalog(catalog)
level.start_level(&"level_1")
level.complete_current_level({ "stars": 3 })
level.start_next_level()
```

注册 `GFLevelProgressModel` 后，`complete_current_level()` 会写入完成状态、保存项目层结果字典，并按目录顺序或条目声明解锁后续关卡。进度模型可直接进入 `GFArchitecture` 的模型快照流程。

未注册 `GFLevelProgressModel` 时，`is_level_unlocked()` 会返回 `true`，方便没有关卡锁的项目继续使用流程信号。`start_level(level_id, override)` 会优先使用传入的 override 数据；`restart_level()` 会重新复制这份 override 或重新读取配置表，避免运行时修改污染下一次重开。`level_started` / `level_restarted` 信号会发出关卡数据副本，监听者修改参数字典不会污染 `current_level_data`。默认找不到关卡数据时仍允许以空字典启动，便于原型流程；正式项目可设置 `fail_on_missing_level_data = true`，缺失数据时拒绝更新当前关卡并输出错误。


## 纯代码行为树 (`GFBehaviorTree`)

**应用场景：** 当敌人、NPC 或自动化流程需要比状态机更灵活的优先级决策时，可以用代码组装轻量行为树。

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

var root := GFBehaviorTree.Selector.new([
	GFBehaviorTree.Sequence.new([check_hp, flee_act]),
	attack_act,
])

var runner := GFBehaviorTree.Runner.new(root)
runner.blackboard = {"hp": 100}

# 在 System 中每帧驱动它
runner.tick()
```

行为树节点状态包含 `FRESH`、`SUCCESS`、`FAILURE`、`RUNNING` 和 `ABORTED`。`Sequence` / `Selector` 会在子节点返回 `RUNNING` 时保留当前子节点索引，下次 `tick()` 从该位置继续；返回终态后会重置索引。除了最基础节点外，GF 还提供 `Parallel`、`RandomSelector`、`RandomSequence`、`Inverter`、`AlwaysSucceed`、`AlwaysFail`、`Probability`、`Cooldown`、`TimeLimit`、`Limit`、`Repeat`、`UntilSuccess` 和 `UntilFail`，但它们依然只是代码层控制流组合，不绑定编辑器树或业务类型。`RandomSelector`、`RandomSequence` 和 `Probability` 可在构造时传入 `RandomNumberGenerator`，也可从 `Runner.blackboard["rng"]` 读取随机源，方便固定种子测试、回放或模拟；不提供随机源时保持普通随机行为。

`GFBehaviorTree.Runner.get_debug_snapshot()` 会输出根节点状态、tick 次数、耗时和黑板键，`GFBehaviorTree.build_debug_snapshot(node)` 可对任意节点生成同类快照。需要分层黑板时，可以使用 `GFBehaviorTree.BlackboardScope` 在父级值上叠加局部覆盖，再把 `to_dictionary()` 结果交给既有节点。GF 仍不负责行为树资源化、可视化编辑、异步任务取消或黑板字段规范，这些应由项目工具或可选扩展按需提供。


## 任务与进度管理 (`GFQuestUtility`)

**应用场景：** 当你需要构建一个成就、任务及进度累加系统，且希望它基于解耦的数据事件框架（如每一次击杀发送一条轻量级事件）时。

**如何使用：**
```gdscript
var quest := Gf.get_utility(GFQuestUtility) as GFQuestUtility

# 开始一个任务，监听自定义进度事件，目标为 10 次
quest.start_quest(&"sample_progress", &"progress_event", 10)

# 在项目自己的规则逻辑中推进进度
Gf.send_simple_event(&"progress_event", 1)

# 获取进度或判断完成
var progress := quest.get_quest_progress(&"sample_progress")
var done := quest.is_quest_completed(&"sample_progress")

quest.define_quest(&"gated_progress", &"progress_event", 3, { "category": "optional" })
quest.accept_quest(&"gated_progress")
quest.add_completion_blocker(&"gated_progress", func(quest_id: StringName, report: Dictionary) -> Dictionary:
	return { "ok": _can_finish_quest(quest_id), "reason": "blocked" }
)
```

事件 payload 可以直接是数字，也可以是包含 `amount` 的字典；浮点数会四舍五入，无法解析时默认增加 `1`。默认情况下负数 amount 会被钳制为 `0`，避免异常事件让任务进度倒退；确实需要扣减进度时，可显式设置 `allow_negative_progress = true`。`quest_id` 和 `target_event` 不能为空。`get_quest_progress()` 返回 `0.0` 到 `1.0` 的比例，即使内部计数因负数事件暂时低于 0，也会按公开百分比范围钳制；`quest_progressed` 信号会额外给出当前值和目标值。`target_count <= 0` 的任务会在开始后立即完成。

`start_quest()` 仍是“一步开始监听”的兼容入口；需要先声明再接取时，可用 `define_quest()` / `accept_quest()`，并通过 `get_quest_status()`、`get_quests_by_status()`、`get_quest_report()` 和 `get_debug_snapshot()` 查询运行时状态。`add_acceptance_condition()` 可在接取前执行通用条件检查，返回 `false` 或 `{ "ok": false, "reason": "..." }` 时会发出 `quest_acceptance_blocked` 并保持 available；`add_completion_blocker()` 只决定能否从 active 进入 completed，不发奖励、不解锁关卡、不解释原因含义。`fail_quest()` 会把任务置为 `STATUS_FAILED` 并注销事件监听，`cancel_quest()` 也只更新任务状态。完成、失败或取消某事件上的最后一个 active 任务时，工具会注销对应 simple event 监听器，避免空任务列表继续接收事件。

复杂任务链可以用 `set_quest_parent()` 建立父子关系，再通过 `get_child_quests()` 和 `get_quest_tree_report()` 获取树形报告与聚合进度。父子关系只用于组织和调试，不自动完成父任务、不自动接取子任务，也不定义奖励、失败传播或章节解锁：

```gdscript
quest.define_quest(&"chapter_1", &"chapter_event", 1)
quest.define_quest(&"find_key", &"key_found", 1)
quest.set_quest_parent(&"find_key", &"chapter_1")

var tree_report := quest.get_quest_tree_report(&"chapter_1")
print(tree_report["aggregate_progress"])
```

需要保存任务状态时，项目层应把任务定义、父子关系、条件来源和进度数据放进自己的 Model 或存档结构。
