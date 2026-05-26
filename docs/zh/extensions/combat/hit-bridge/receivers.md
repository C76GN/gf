# 接收器与业务目标

如果 HurtBox 只是碰撞桥接节点，而真正的业务目标在角色、能力或状态机节点上，可以设置 `GFHurtBox2D.receiver_path` / `GFHurtBox3D.receiver_path`。

HurtBox 会先执行自身的启用状态、命中 ID 过滤和 `validation_callback`；若 `context.target` 为空或仍指向该 HurtBox，会在通过后改为业务目标。

业务目标实现了 `receive_hit(context)` 时会被调用，可以返回 `Dictionary` 覆盖报告、返回 `bool` 决定通过或拒绝，也可以只做副作用不返回值；未实现 `receive_hit()` 时只作为 target 使用，HurtBox 仍会沿用自身的接收报告并发出 `hit_received`。

`receiver_path` 只改变业务接收目标，不会把 `hit_validating`、`hit_received` 或 `hit_rejected` 迁移到业务节点；这些信号仍由 HurtBox 发出，业务节点如需对外广播可在自己的 `receive_hit()` 中再发项目自定义信号。

这样场景可以保持 `Character -> HurtBox/Area` 的结构，而不用把扣血、格挡或能力逻辑写进 HurtBox 脚本。

`GFHitBox2D` / `GFHitBox3D` 和 `GFHurtBox2D` / `GFHurtBox3D` 的 `enabled` 变化时会发出 `enabled_changed(enabled)`。它只报告框架命中收发开关，项目可以用它同步调试可见性、调试面板或外部状态；如果需要统一管理一组区域的 `enabled`、`monitoring` / `monitorable` 和 `visible`，优先使用 [重叠广播与状态组](overlap-state.md)。
