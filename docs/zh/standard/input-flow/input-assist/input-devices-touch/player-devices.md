# 设备席位与玩家级输入

同一输入层提供本地设备席位映射与触屏输入。

```gdscript
var devices := Gf.get_utility(GFInputDeviceUtility) as GFInputDeviceUtility
devices.max_players = 4
devices.refresh_connected_devices()

for assignment in devices.get_assignments():
	print(assignment.player_index, assignment.device_type, assignment.device_id)
```

`GFInputDeviceAssignment` 只是“玩家席位 -> 设备”的资源化记录，字段包含 `player_index`、`device_type`、`device_id` 和项目自定义 `metadata`，不会绑定任何动作名。

键鼠通常使用设备 ID `0`，AI、虚拟触屏或自定义席位可以使用项目约定的 ID。

`GFInputDeviceUtility` 会把输入事件解析到玩家席位；`GFInputMappingUtility` 在存在该工具时会同步维护玩家级动作状态。

事件由 `GFInputMappingUtility` 处理后，System 或状态逻辑可以按已知玩家索引消费：

```gdscript
var player_index := devices.active_player_index
if input_map.consume_action_for_player(player_index, &"confirm"):
	print("player confirm: ", player_index)

var move := input_map.get_action_vector_for_player(player_index, &"move")
```

玩家级状态会保留具体输入来源。同一玩家的同一绑定如果同时来自多个来源，释放其中一个来源不会覆盖仍然按住的另一个来源。

全局状态与玩家状态因此保持一致的聚合语义。调用 `clear_player_input_state(player_index)` 会同时移除该玩家写入的玩家级状态和全局聚合贡献，适合玩家离开、设备断开或切换控制权时清理残留输入。
