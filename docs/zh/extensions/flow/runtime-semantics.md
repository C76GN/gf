# 运行时语义

运行器优先使用节点或上下文提供的后继列表。当节点没有默认后继、上下文也没有显式覆盖时，才会回退到 `connections`。如果节点需要明确停止，可调用 `context.set_next_nodes(PackedStringArray())`。

节点 `wait_for_result` 且 `execute()` 返回 Signal 时，`GFFlowRunner` 会安全等待发射源或节点离树，并使用 `with_signal_timeout(seconds, respect_time_scale)` 控制等待上限。默认超时同样跟随 `GFTimeUtility` 的暂停与 `time_scale`。Signal 可以带任意载荷参数，运行器只把发射本身视为等待完成。

等待期间调用 `cancel()` 后，运行器会停止在当前等待点，不再发送当前节点完成事件或推进后继节点。如果自定义节点在 `execute()` 内部自行 await 且永不返回，运行器无法替它取消这段内部逻辑，项目层应把等待对象作为 Signal 返回。

`GFFlowContext` 可注册条件查询处理器。`register_condition_handler(condition_id, handler)` 接收一个通用 `Callable`，`query_condition()` 会把返回值归一化为 `ok`、`value`、`reason` 和 `metadata`。这适合把“某个条件如何判断”留在项目层，同时让节点、导入器或编辑器工具使用同一套查询结果结构。

运行态默认写入 `GFFlowContext` 的节点状态表。节点可通过 `set_node_runtime_value(node_id, key, value)`、`get_node_runtime_value(node_id, key, default)` 和 `clear_node_runtime_state(node_id)` 保存跨 tick 进度；`serialize_runtime_state()` 和 `deserialize_runtime_state()` 可把这份上下文运行态随项目存档保存。

`GFFlowRunner.isolate_graph_runtime_state` 默认开启。运行同一个 `GFFlowGraph` 资源时，它会把图内节点运行态隔离到当前 context，再在运行结束后恢复资源原状态，避免多个 NPC、任务实例或测试共享同一资源时串状态。

需要从资源创建独立配置副本时，仍可使用 `instantiate_graph()`。
