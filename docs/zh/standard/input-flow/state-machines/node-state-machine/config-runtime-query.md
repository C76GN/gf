# 配置资源与运行时查询

状态机提供 `GFNodeStateMachineConfig` 资源，用于复用内部组初始状态、初始参数、历史容量与最大栈深度。

运行时可通过这些方法查询状态机状态：

- `get_current_state()`
- `get_current_group_state()`
- `get_current_state_name()`
- `get_state_history()`
- `get_stack_depth()`
- `is_in_state()`

状态脚本内部可用 `get_host()` 或 `host` 获取状态机所在宿主节点。

`GFNodeStateMachine` 的状态组、状态切换和状态事件信号使用 `GFNodeStateGroup` / `GFNodeState` 参数，监听者可以直接访问状态 API，不需要先把 `Node` 再转型。
