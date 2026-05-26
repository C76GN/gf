# Controller 与 Utility

## Controller

类型：`GFController`

Controller 是架构和 Godot 场景树之间的桥。它接收输入或 Godot 回调，读取 Model，调用 System，并把事件、绑定变化或查询结果同步到 UI、动画和场景对象。

规则：

- 继承自 `GFController`，本身是 Node。
- 可通过 `host_node_path`、`get_host()`、`get_host_as()` 或 `host` 访问宿主节点，默认宿主为父节点。
- 不保存核心业务状态。
- 应能随场景销毁而安全释放。

## Utility

类型：`GFUtility`

Utility 提供与核心业务规则无关的通用运行时服务，例如时间缩放、存档读写、对象池、日志、异步资源加载和项目设置。

规则：

- 适合持有运行时状态，或需要被容器统一初始化、更新、释放的通用服务。
- 可被 Model、System、Controller 或其他 Utility 调用。
- 不应写入具体玩法规则。
