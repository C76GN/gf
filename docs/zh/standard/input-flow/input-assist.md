# 输入映射与手感辅助

本页拆出输入动作、玩家设备、输入缓冲、连击窗口和操作辅助相关工具。
## 输入映射与手感辅助 (`GFInputMappingUtility` / `GFInputAssistUtility`)

`GFInputMappingUtility` 是推荐的输入主入口，负责把真实或虚拟输入转换成抽象动作状态。`GFInputAssistUtility` 是可选的手感辅助层，只负责动作意图缓冲和通用宽容窗口，不读取 `InputEvent`，也不处理重绑定或设备归属。

当项目需要把输入从具体按键抽象成可切换上下文和可重绑动作时，可以注册 `GFInputMappingUtility`。动作、绑定和上下文都由资源描述，框架只负责事件转动作状态，不规定移动、战斗、UI 导航或任何业务规则。

```gdscript
var jump_action := GFInputAction.new()
jump_action.action_id = &"jump"
jump_action.display_name = "Jump"

var jump_binding := GFInputBinding.new()
jump_binding.input_event = InputEventKey.new()
(jump_binding.input_event as InputEventKey).keycode = KEY_SPACE
(jump_binding.input_event as InputEventKey).physical_keycode = KEY_SPACE

var jump_mapping := GFInputMapping.new()
jump_mapping.action = jump_action
jump_mapping.bindings = [jump_binding]

var gameplay_context := GFInputContext.new()
gameplay_context.context_id = &"gameplay"
gameplay_context.mappings = [jump_mapping]

var input_map := Gf.get_utility(GFInputMappingUtility) as GFInputMappingUtility
input_map.enable_context(gameplay_context, 10)

if input_map.consume_action(&"jump"):
	print("jump requested")
```

运行时用代码组装 `GFInputAction` / `GFInputMapping` / `GFInputContext` 是合法的，适合原型、自动生成配置或测试；正式项目若希望策划可调、可复用和便于改键界面展示，通常把它们保存成 `.tres` 资源再由 Installer、System `ready()` 或场景入口启用。不要在 `GFSystem._init()` 里获取 Model/Utility 或启用上下文：构造阶段还没有完成架构注入，跨模块依赖应放在 `ready()`，纯内部默认值才放在 `init()` / `_init()`。

连续轴输入可以监听 `action_value_changed` 后写入项目自己的输入 Model，也可以在 System `tick()` 中调用 `get_action_vector()` / `get_action_value()` 轮询；两种方式都符合框架边界。跳跃、攻击、确认这类一次性意图更推荐使用 `consume_action()`、`action_started` 或触发器语义，避免把按下、按住和释放都混成普通 value change。二维移动可用一个 `AXIS_2D` 动作配四个方向绑定，再通过 `get_action_vector(&"move")` 读取；拆成 `move_x` / `move_y` 也可以，但后续死区、归一化和重绑展示通常会更分散。

如果项目还需要“提前输入仍能在短时间内执行”或“状态刚刚失效后仍保留一个宽容窗口”这类手感规则，再注册 `GFInputAssistUtility`。它的 API 会明确写出 `buffered` 和 `grace_window`，避免和 `GFInputMappingUtility.consume_action()` 的“消费本帧刚触发动作”混淆：

```gdscript
var input_map := Gf.get_utility(GFInputMappingUtility) as GFInputMappingUtility
var input_assist := Gf.get_utility(GFInputAssistUtility) as GFInputAssistUtility

if input_map.consume_action(&"jump"):
	input_assist.buffer_action(&"jump", 0.15)

if can_jump_now and input_assist.consume_buffered_action(&"jump"):
	perform_jump()

input_assist.start_grace_window(&"grounded", 0.1)
if input_assist.is_grace_window_active(&"grounded"):
	# 项目层自行决定这个窗口能放宽哪些动作。
	pass
```

本地多人项目可以传入 `player_index` 让动作缓冲和宽容窗口按玩家隔离；全局输入辅助则继续使用默认的 `-1`。

自动化测试、回放、AI 控制或项目自己的输入桥接可以使用 `GFVirtualInputSource` 写入抽象动作值，而不是伪造具体按键。虚拟源仍要求动作已经通过上下文注册，并会复用 `GFInputMappingUtility` 的动作值、触发器、全局/玩家级状态和一次性 started/completed 语义：

```gdscript
var input_map := Gf.get_utility(GFInputMappingUtility) as GFInputMappingUtility
var ai_input := input_map.create_virtual_source(&"ai_agent", 0)

ai_input.press(&"confirm")
ai_input.set_axis_2d(&"move", Vector2.RIGHT)
ai_input.release(&"confirm")
```

虚拟源只表达“某个抽象动作现在有什么值”，不代表真实设备、不参与重绑定冲突分析，也不决定玩家加入、角色控制权或回放文件格式。需要清理一整段注入时，可调用 `clear_all()` 或 `GFInputMappingUtility.clear_virtual_source(source_id)`。

需要把抽象动作序列保存下来再回放时，可用 `GFInputRecording` 记录 action id、时间、值、玩家索引和元数据，再交给 `GFInputPlayback` 按时间写入 `GFVirtualInputSource`：

```gdscript
var recording := GFInputRecording.new()
recording.add_event(&"jump", true, 0.0)
recording.add_event(&"jump", false, 0.12)

var playback := GFInputPlayback.new()
playback.start(recording, input_map.create_virtual_source(&"replay", 0))
playback.tick(delta)
```

录制回放只处理 GF 抽象动作值，不模拟真实按键、鼠标或手柄事件；因此它适合自动化测试、教程演示、复现 bug、AI 接管或项目自定义输入桥接。`respect_recorded_player_index` 可让事件自带的玩家索引生效；是否保存到文件、如何压缩、是否作为回放录像公开给玩家，仍由项目层决定。

运行时改键通过 `GFInputRemapConfig` 保存覆盖项。默认绑定仍留在上下文资源中，配置只记录用户或项目层修改过的部分：

```gdscript
var remap := GFInputRemapConfig.new()
input_map.set_remap_config(remap)
input_map.set_binding_override(&"gameplay", &"jump", 0, new_input_event)
var saved_remap := remap.to_dict()
var restored_remap := GFInputRemapConfig.from_dict(saved_remap)
```

如果项目需要多套可命名的键位配置，可以用 `GFInputProfileBank` 保存多个 `GFInputRemapConfig`。Bank 只管理 profile id 与重映射资源，不规定账号、玩家编号、存档槽位或设置界面结构：

```gdscript
var profiles := GFInputProfileBank.new()
profiles.set_profile(&"keyboard", input_map.get_remap_config(true))
profiles.ensure_profile(&"gamepad")
profiles.set_active_profile(&"gamepad")

input_map.set_remap_config(profiles.get_active_profile())
```

`GFInputRemapConfig.to_dict()` 会把覆盖的 `InputEvent` 与显式解绑记录转换为可写入配置或存档的字典，`from_dict()` 可恢复，`duplicate_config()` 会用同一套持久化格式做深拷贝；默认绑定仍来自上下文资源，不会被复制进重映射配置。`GFInputDetector` 可放进改键界面中检测下一次输入；`GFInputFormatter` 提供轻量文本格式化，便于设置界面展示当前绑定。Joypad 默认会通过 `GFInputDeviceTextProvider` 输出抽象方位文本，例如 Button South、Left Stick X，也可通过 options 或注册自定义 `GFInputTextProvider` 替换为平台图标、图标字体或本地化文本；需要 RichTextLabel 图标输出时，可继承 `GFInputIconProvider` 把输入事件映射为项目自己的 `Texture2D` 或 BBCode，`input_event_as_rich_text()` 会优先使用图标 provider，再回退到文本。`GFInputIconAtlasProvider` 是内置的可配置图标 provider：它把按键、鼠标、手柄按钮和手柄轴归一化成 `key:k`、`mouse:left`、`joy_button:south`、`joy_axis:left_x_positive` 这类通用键，再通过显式路径、纹理映射或 `{root}/{style}/{platform}/{icon}.png` 模板解析图标。`GFInputConflictAnalyzer` 可在保存重绑定前检查同一上下文或跨上下文的有效输入冲突，也可以通过 `build_rebind_report()` 一次性获取有效绑定条目和冲突列表。它只读取资源和重映射配置，不接管运行时输入逻辑。

```gdscript
var icons := GFInputIconAtlasProvider.new()
icons.root_path = "res://ui/input_icons"
icons.style = &"line"
icons.platform = &"generic"
icons.set_icon_path(&"key:space", "res://ui/input_icons/line/generic/key_space.png")

GFInputFormatter.add_icon_provider(icons)
var rich_text := GFInputFormatter.input_event_as_rich_text(jump_binding.input_event)
```

图标 provider 不附带任何图片资源，也不规定平台品牌、按钮文案或美术风格。项目可以用 `icon_paths` 精确映射少量按钮，也可以用路径模板批量组织素材；`split_key_modifiers` 会把 Ctrl/Shift/Alt/Meta 组合键拆成多个图标，便于设置界面显示。

动作值可通过 `GFInputModifier` 组合处理，例如死区、缩放、归一化和范围映射；动作活跃可通过 `GFInputTrigger` 延迟判断，例如按下、释放、短按、长按、周期脉冲、组合动作和动作序列。修饰器可以挂在 Binding 或 Mapping 上，触发器挂在 Mapping 上，运行时仍只暴露抽象动作状态，不把移动、攻击或 UI 选择规则写进输入层。同一 `action_id` 出现在多个已启用上下文时，动作定义、Mapping 级修饰器和触发器按实际处理顺序采用第一个定义；也就是高优先级上下文会覆盖低优先级上下文的动作语义，低优先级上下文不会反向改写这些定义。

内置修饰器各自只处理通用数值变换：`GFInputDeadzoneModifier` 处理摇杆死区并可重映射剩余范围，`GFInputScaleModifier` 调节或反转轴分量，`GFInputNormalizeModifier` 限制二维/三维向量长度，`GFInputMapRangeModifier` 把输入范围线性映射到目标范围。内置触发器各自只处理通用动作时序：`GFInputPressedTrigger` 只在按下瞬间触发，`GFInputReleasedTrigger` 只在释放瞬间触发，`GFInputTapTrigger` 识别短按，`GFInputHoldTrigger` 识别长按，`GFInputPulseTrigger` 在持续输入时周期触发，`GFInputChordTrigger` 要求另一个动作同时活跃，`GFInputSequenceTrigger` 要求动作按顺序完成。组合键和动作序列都基于抽象 action id，不绑定具体键位。

简单序列可继续使用 `GFInputSequenceTrigger.required_action_ids`。需要多条可替代路径、单步最大间隔、按住时间或释放完成条件时，使用 `GFInputSequenceBranch` 和 `GFInputSequenceStep` 描述资源化序列：

```gdscript
var step := GFInputSequenceStep.new()
step.action_id = &"charge"
step.min_hold_seconds = 0.2
step.trigger_on_release = true

var branch := GFInputSequenceBranch.new()
branch.steps = [step]

var trigger := GFInputSequenceTrigger.new()
trigger.branches = [branch]
```

`GFInputMappingUtility` 会同步记录动作的 just-started、just-completed 和最近一次完成前的持续时间，供释放型触发器或项目层读取。全局查询使用 `was_action_just_completed(action_id)` / `get_last_completed_duration(action_id)`；本地多人使用对应的 `*_for_player()` 接口。一次性状态会保留到至少经过一次 GF System tick 的观察窗口后再清理：普通输入事件可在同帧 System 中消费，长按、短按或序列触发器在 Utility tick 中生成的动作可在下一次 System tick 中消费。持续时间只描述抽象动作状态，不包含具体按键、技能窗口或业务判定。

`GFInputAction.ValueType` 支持 `BOOL`、`AXIS_1D`、`AXIS_2D` 与 `AXIS_3D`。`GFInputBinding.ValueTarget.AUTO` 会按动作值类型自动产出贡献值，但二维/三维动作默认写入 X 分量；摇杆 Y、右摇杆、Z 轴或按钮方向应使用显式 `AXIS_2D_*` / `AXIS_3D_*` 目标。`get_action_vector()` / `get_action_vector_for_player()` 返回 `Vector2`；需要三维输入时使用 `get_action_vector3()` 或 `get_action_vector3_for_player()`。

同一输入层也提供本地设备席位映射与触屏输入：

```gdscript
var devices := Gf.get_utility(GFInputDeviceUtility) as GFInputDeviceUtility
devices.max_players = 4
devices.refresh_connected_devices()

for assignment in devices.get_assignments():
	print(assignment.player_index, assignment.device_type, assignment.device_id)
```

`GFInputDeviceAssignment` 只是“玩家席位 -> 设备”的资源化记录，字段包含 `player_index`、`device_type`、`device_id` 和项目自定义 `metadata`，不会绑定任何动作名。键鼠通常使用设备 ID `0`，AI、虚拟触屏或自定义席位可以使用项目约定的 ID。

`GFInputDeviceUtility` 会把输入事件解析到玩家席位；`GFInputMappingUtility` 在存在该工具时会同步维护玩家级动作状态：

```gdscript
var player_index := devices.handle_input_event(event)
if input_map.consume_action_for_player(player_index, &"confirm"):
	print("player confirm: ", player_index)

var move := input_map.get_action_vector_for_player(player_index, &"move")
```

玩家级状态会保留具体输入来源，同一玩家的同一绑定如果同时来自多个来源，释放其中一个来源不会覆盖仍然按住的另一个来源。全局状态与玩家状态因此保持一致的聚合语义。

当 UI 需要跟随最近活跃设备切换提示文本或图标时，可以监听 `GFInputDeviceUtility.active_device_changed`，或用 `get_active_assignment()` / `get_active_device_name()` 读取当前设备。该信号只表达“哪个玩家席位的哪个设备最近产生了有效输入”，不绑定任何图标包、平台品牌、按钮命名或 UI 样式；项目可以继续通过 `GFInputFormatter`、`GFInputIconProvider` 或自己的界面层决定最终展示。

如果项目只需要“最后按下方向优先”的通用规则，而不想把这套逻辑塞进完整输入映射里，可以直接使用 `GFInputDirectionHistory`。它只记录动作 ID 与方向的按下顺序，不读取 `InputMap`，适合网格移动、菜单导航或其他需要方向仲裁的场景：

```gdscript
var history := GFInputDirectionHistory.new()
history.press_action(&"move_left", Vector2i.LEFT)
history.press_action(&"move_up", Vector2i.UP)
print(history.get_current_direction()) # Vector2i.UP
```

未登记的手柄可按配置自动分配到空玩家席位，手柄轴自动分配带有阈值过滤，避免摇杆漂移噪声抢占席位。已登记手柄切换 `active_player_index` 时使用独立的 `active_player_axis_threshold`，避免轻微漂移反复切换活跃玩家。手动 `set_assignment()` 会受 `max_players` 约束，并会把同一物理设备从旧玩家席位移到新玩家席位；需要多个 AI 虚拟席位时可继续使用 `DeviceType.AI` 与负数设备 ID。全局动作查询继续可用；本地多人项目应优先使用 `*_for_player()` 接口。

本地多人大厅可以显式配置 join 输入模板，再把匹配事件交给 `handle_join_input_event()`。该接口只发出“某个设备请求加入”的通用信号，不决定队伍、角色、出生点或 UI 流程：

```gdscript
devices.configure_default_join_events(true, true)
devices.player_join_requested.connect(func(player_index: int, assignment: GFInputDeviceAssignment, _event: InputEvent) -> void:
	print("join requested: ", player_index, assignment.device_type)
)

func _input(event: InputEvent) -> void:
	devices.handle_join_input_event(event)
```

需要手柄反馈时，可以通过玩家席位转发震动请求，而不是在业务代码里散落 device id 查询：

```gdscript
devices.start_vibration_for_player(player_index, 0.2, 0.8, 0.15)
devices.stop_vibration_for_player(player_index)
```

`GFInputBinding` 的触屏事件默认表示“任意触摸”，适合简单确认或由 `GFTouchButton` / `GFTouchJoystick` 承担区域判断的场景；需要区分多指触点时可启用 `match_touch_index`，让 `InputEventScreenTouch.index` 参与匹配。`GFTouchJoystick` 是一个可直接放进场景树的 `Node2D`。它会发出 `direction_changed(direction)`，也可以把方向映射到项目自己的 InputMap 动作名。相对模式适合移动端虚拟摇杆，`emit_joypad_motion` 可把触屏输入桥接为虚拟手柄轴事件。`GFTouchButton` 则提供通用触屏按钮，并同样支持 InputMap 动作或虚拟手柄按钮事件。

