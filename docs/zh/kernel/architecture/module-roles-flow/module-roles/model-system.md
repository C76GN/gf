# Model 与 System

## Model

类型：`GFModel`

Model 保存项目核心数据状态，例如玩家金币、角色属性、背包数据或任务状态。

它应提供必要的状态修改入口、快照恢复和数据校验边界。

规则：

- 不直接引用或操作 System、Controller 或场景节点。
- 不承载复杂跨模块业务流程。
- 可提供 `to_dict()` / `from_dict()` 这类序列化接口以支持存档。

## System

类型：`GFSystem`

System 是纯代码业务流程中心，负责监听事件、处理命令和查询、协调 Model、调用 Utility，并在需要时通过 `tick()` / `physics_tick()` 参与帧驱动逻辑。

规则：

- 继承自 `GFSystem`，不继承 `Node`。
- 可以读取和修改 Model。
- 可以调用 Utility。
- 不直接持有 Controller 或具体场景节点引用。
