# 虚拟输入与录制回放

自动化测试、回放、AI 控制或项目自己的输入桥接可以使用 `GFVirtualInputSource` 写入抽象动作值，而不是伪造具体按键。虚拟源仍要求动作已经通过上下文注册，并会复用 `GFInputMappingUtility` 的动作值、触发器、全局/玩家级状态和一次性 started/completed 语义。

```gdscript
var input_map := Gf.get_utility(GFInputMappingUtility) as GFInputMappingUtility
var ai_input := input_map.create_virtual_source(&"ai_agent", 0)

ai_input.press(&"confirm")
ai_input.set_axis_2d(&"move", Vector2.RIGHT)
ai_input.release(&"confirm")
```

虚拟源只表达“某个抽象动作现在有什么值”，不代表真实设备、不参与重绑定冲突分析，也不决定玩家加入、角色控制权或回放文件格式。需要清理一整段注入时，可调用 `clear_all()` 或 `GFInputMappingUtility.clear_virtual_source(source_id)`。

## 录制回放

需要把抽象动作序列保存下来再回放时，可用 `GFInputRecording` 记录 action id、时间、值、玩家索引和元数据，再交给 `GFInputPlayback` 按时间写入 `GFVirtualInputSource`。

```gdscript
var recording := GFInputRecording.new()
recording.add_event(&"jump", true, 0.0)
recording.add_event(&"jump", false, 0.12)

var playback := GFInputPlayback.new()
playback.start(recording, input_map.create_virtual_source(&"replay", 0))
playback.tick(delta)
```

录制回放只处理 GF 抽象动作值，不模拟真实按键、鼠标或手柄事件；因此它适合自动化测试、教程演示、复现 bug、AI 接管或项目自定义输入桥接。`respect_recorded_player_index` 可让事件自带的玩家索引生效；是否保存到文件、如何压缩、是否作为回放录像公开给玩家，仍由项目层决定。
