# 命令、查询与规则

`GFCommand`、`GFQuery` 和 `GFRule` 为跨模块读写动作、派生查询和可配置规则提供稳定表达方式。

如果把所有读写流程都直接堆到同一个 `GFSystem` 中，核心系统会很快变得难以拆分和测试。例如 `BattleSystem` 同时负责开始战斗、技能结算、伤害衰减和撤退流程时，职责边界就会变得模糊。

## 阅读入口

- [GFCommand 写操作](commands.md)：封装最小写操作单元，并通过架构发送执行。
- [GFQuery 读操作](queries.md)：封装跨模块读取、派生数据和表现层查询。
- [GFRule 资源化规则对象](rules.md)：把可配置策略从 `System` 中抽离成 Resource。
- [工厂注入](factory-injection.md)：通过架构工厂创建带注入的 Command / Query。

## 使用边界

- 需要改变 Model 状态或触发副作用：使用 `GFCommand`。
- 需要组合多个模块读取派生数据：使用 `GFQuery`。
- 需要把可配置策略放进资源：使用 `GFRule`。
- 需要顺序等待、失败策略或可选回滚：使用 `GFCommandSequence`、Flow 或项目层 System 编排。
