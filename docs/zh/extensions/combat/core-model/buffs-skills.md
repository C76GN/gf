# Buff 与技能

`GFBuff` 和 `GFSkill` 是 Combat 运行时流程的核心对象。它们只提供生命周期、冷却、条件和通用执行协议，不定义具体伤害、治疗、动画或输入来源。

## Buff

`GFBuff` 是状态效果基类，负责管理生命周期和效果应用。

能力：

- 生命周期：支持 `duration` 和 `on_tick(delta)`。
- 效果携带：Buff 可以携带多个 `GFModifier` 和 tags，在应用时自动挂载至宿主。
- 刷新语义：同 ID Buff 默认通过已有实例的 `refresh_from(new_buff)` 刷新持续时间并按 `max_stacks` 增加层数，不自动替换新 Buff 的 tags、modifiers 或 max_stacks。
- 可配置策略：`stack_mode` 可选择只刷新、叠层或忽略重复添加；`duration_refresh_policy` 可选择保持、重置、追加或保留更长剩余时间。
- 周期 Tick：`tick_interval_seconds <= 0` 时保持每帧调用 `on_tick(delta)`；大于 0 时按固定间隔触发。

`max_periodic_ticks_per_update` 会限制单次卡顿后的补偿 tick 数，避免大量 Buff 在一帧内无上限追赶。`on_tick(delta)` 只在 Buff 存活帧调用，过期帧不会额外补一次 tick。`remove_on_expire = false` 时，持续时间耗尽后不会要求 `GFCombatSystem` 移除该 Buff，项目可自行决定何时清理或复用。

需要替换强度、合并配置或触发项目事件时，继承 Buff 并覆写 `refresh_from()`。

## 技能

`GFSkill` 提供技能的基础框架。

能力：

- 冷却管理：内置冷却计时逻辑。
- 条件检查：支持 `require_tags` 和 `ignore_tags`。
- 自动化索敌：可集成 `GFSkillTargetingRule` 实现管线化自动索敌。
- 执行结果：`execute()` 返回是否真正施放成功。

需要在子类中拒绝施放或等待项目校验时，重写 `_try_execute(targets) -> bool`。只有返回 `true`，技能才会进入冷却。
