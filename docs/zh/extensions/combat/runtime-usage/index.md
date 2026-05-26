# Combat 运行时示例与系统驱动

本组页面保留 Combat 扩展的运行时接入示例：监听战斗事件、定义 Buff 和技能、运行时调整 Buff，以及在需要时手动装配系统。

## 阅读入口

- [事件监听](event-listening.md)：监听 Combat payload 并对接项目日志、UI 或表现系统。
- [Buff 与技能示例](buff-skill-examples.md)：定义 Tick Buff、自动索敌技能和属性修饰器。
- [运行时 Buff 管理](runtime-buff-management.md)：查询、刷新、驱散、修改 Buff 以及手动目标校验边界。
- [系统驱动与装配](system-driver.md)：`GFCombatSystem` 的帧驱动职责和扩展 Installer 自动装配边界。

## 使用边界

这些示例展示 Combat 原语如何被项目调用。伤害公式、阵营规则、动画、输入、命中特效、技能 AI 和 PvE/PvP 规则仍由项目层决定。
