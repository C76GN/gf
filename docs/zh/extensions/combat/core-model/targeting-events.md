# 目标选择与事件

Combat 的目标选择和事件 payload 只描述通用运行时流程。目标是否合法、是否可命中、是否触发伤害或表现反馈由项目层决定。

## 目标选择管线

`GFSkillTargetingUtility` 处理 `GFSkillTargetingRule` 定义的自动索敌管线。`GFSkill` 可内置使用这套管线；若需手动调用，应通过 `Gf.get_utility(GFSkillTargetingUtility)` 获取。

管线流程：

1. 空间收集：基于形状和半径筛选候选对象。
2. 标签过滤：检查 `GFTagComponent`，支持必须拥有和禁止拥有标签。
3. 动态排序：支持基于距离或动态属性名进行最高/最低排序。
4. 数量截取：严格限制返回的目标数量。

通过创建 `GFSkillTargetingRule` 资源文件，可以在不修改代码的情况下调整索敌逻辑。管线只处理通用候选、标签、排序和截取，不解释阵营、视野、障碍、仇恨或技能业务规则。

## 战斗事件

`GFCombatSystem` 在处理 Buff 时会通过 `GFArchitecture` 发送强类型事件，便于业务层通过订阅 payload 实现引爆、致死拦截、日志、UI 或表现联动。

常见 payload：

- `GFBuffAppliedPayload`：新 Buff 被成功应用。
- `GFBuffRefreshedPayload`：已有 Buff 持续时间或层数被刷新。
- `GFBuffRemovedPayload`：Buff 耗尽或被强制移除。

事件只报告 Combat 层状态变化，不负责项目的伤害结算、任务进度、特效播放或网络同步。
