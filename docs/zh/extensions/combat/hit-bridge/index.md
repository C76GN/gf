# Combat 命中桥接与碰撞窗口

Combat 的场景树桥接节点负责把 HitBox、HurtBox、HitScan、碰撞形状配置和状态组转成通用命中上下文。它们只负责收发命中上下文，不负责伤害、阵营、无敌帧或表现反馈。

## 阅读入口

- [命中协议与基础接入](protocol-basic.md)：`GFCombatHitContext`、HitBox / HurtBox / HitScan 和 2D/3D 基础发送接收。
- [接收器与业务目标](receivers.md)：`receiver_path`、`receive_hit(context)`、接收报告和信号边界。
- [碰撞形状配置](shape-configs.md)：`GFHitCollisionShapeConfig2D/3D`、单形状和多形状切换。
- [重叠广播与状态组](overlap-state.md)：`broadcast_overlaps()`、`sender_path`、过滤回调和 `GFHitBoxState2D/3D`。

## 使用边界

`GFCombatHitContext` 中的 `payload`、`magnitude`、`tags` 和 `metadata` 都保持通用。项目可以把它们解释为伤害、治疗、打断、交互、碰撞反馈或任何自定义命中语义；框架不会默认扣血、创建特效或判断阵营。
