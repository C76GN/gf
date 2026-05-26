# 宿主节点

如果 Controller 是某个场景节点的输入、动画或物理桥接层，推荐让它作为宿主节点的子节点，并通过 `get_host()` / `host` 获取宿主。

默认 `host_node_path` 指向父节点。当 Controller 放在更深的子树下时，可在 Inspector 中把 `host_node_path` 改为目标节点路径。

不要把 `owner` 当作运行时宿主引用使用。`owner` 表示编辑器场景所有权，不等价于父节点，也不等价于当前 Controller 的控制目标。

如果宿主没有自定义脚本，也可以直接使用原生类型：

```gdscript
var body := get_host() as CharacterBody2D
```

需要强类型宿主时，优先使用 `get_host_as()`：

```gdscript
@onready var actor := get_host_as(ActorBody) as ActorBody
```
