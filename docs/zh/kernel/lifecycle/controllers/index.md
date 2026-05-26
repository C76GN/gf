# Controller 初始化

本组页面说明 `GFController` 与 Godot 原生节点生命周期的边界。Controller 依附场景树运行，通过架构查询模型或系统，并把数据变化绑定到表现节点。

## 阅读入口

- [Ready 与上下文等待](ready-context.md)：Controller `_ready()`、`wait_for_context_ready()` 和数据绑定初始化。
- [宿主节点](host-node.md)：`host_node_path`、`get_host()`、`get_host_as()` 和 `owner` 边界。
- [原生物理节点桥接](native-physics-node.md)：角色、载具等 Godot 物理节点如何通过子 Controller 接入 GF。

## 使用边界

Controller 是场景树和架构之间的桥。它可以读取 Model、调用 System、监听事件和更新表现节点，但不应保存核心业务状态。
