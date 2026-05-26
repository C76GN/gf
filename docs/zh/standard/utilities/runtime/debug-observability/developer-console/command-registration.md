# 命令注册与参数解析

项目可以注册自定义指令。命令回调签名固定为 `func(args: PackedStringArray) -> void`。

```gdscript
var console := Gf.get_utility(GFConsoleUtility) as GFConsoleUtility

console.register_command("tp", Callable(self, "_console_tp"), "传送玩家到指定坐标。用法: tp <x> <y>")
```

也可以用 `GFConsoleCommandDefinition` 资源化命令名、别名、描述和元数据，再通过 `register_command_definition()` 绑定执行回调。

```gdscript
var definition := GFConsoleCommandDefinition.new()
definition.command_name = "reload"
definition.aliases = PackedStringArray(["rl"])
definition.description = "重新加载当前调试数据。"
console.register_command_definition(definition, func(_args: PackedStringArray) -> void:
	reload_debug_data()
)
```

常用操作：

```gdscript
console.unregister_command("tp")
console.execute_command("help")
console.execute_command("scene.tree 3 80")
console.execute_command("scene.node Player")
```

参数解析支持引号和反斜杠转义。例如 `give_item "red potion" 3` 会把 `"red potion"` 作为一个参数。
