# 设置、UI、场景与表面查询

这些运行时工具覆盖设置应用、UI 栈、场景切换、节点树操作和表面材质查询等项目通用流程。

## 通用设置与显示应用 (`GFSettingsUtility` / `GFDisplaySettingsUtility`)

**应用场景：** 游戏设置页通常会混合窗口模式、分辨率、语言、音量、难度、辅助功能等数据。如果这些逻辑直接写进 UI 节点，后续存档、重置默认值、平台差异和测试都会变得困难。

`GFSettingsUtility` 只管理抽象设置定义和值，不知道它们会被哪个 UI 或引擎 API 使用。`GFDisplaySettingsUtility` 则把其中一部分通用设置应用到 Godot 的窗口、VSync、语言和音频总线层。

```gdscript
var settings := Gf.get_utility(GFSettingsUtility) as GFSettingsUtility

settings.register_setting(
	&"gameplay/difficulty",
	"normal",
	GFSettingDefinition.ValueType.STRING
)
settings.set_value(&"gameplay/difficulty", "hard")
settings.save_settings()
```

`GFSettingDefinition` 可以资源化描述稳定键、默认值、值类型、是否持久化和 UI 元数据。`set_value()` 会按定义做类型转换，`to_dict(true)` 只导出持久化设置；未注册定义的临时值也能读写，但不会获得默认值、类型钳制或元数据。持久化设置会保留 `Vector2`、`Vector2i`、`Color`、`StringName` 等常见 Godot 值；其他需要 JSON 类型标记的值会复用 `GFVariantJsonCodec`，因此超出 JSON 安全范围的 64 位整数也能精确往返。自动保存默认会按 `save_debounce_seconds` 做防抖，避免设置页拖动滑块时每次变化都落盘；需要一次性应用多个字段时，可用 `begin_batch()` / `end_batch()` 包裹，或手动 `queue_save()` 后在合适时机 `flush_pending_save()`。

需要把“低画质”“无障碍”“手柄方案”这类项目预设一次性应用到设置中时，可以使用 `apply_values()`。它会沿用已注册定义做类型转换，并把自动保存合并成一次；如果预设希望把缺失的键重置为默认值，必须显式传入 `scope`，避免误重置不属于该预设的其他设置：

```gdscript
var report := settings.apply_values({
	"audio/master": 0.75,
	"video/fullscreen": true,
}, {
	"reset_missing": true,
	"scope": PackedStringArray([
		"audio/master",
		"video/fullscreen",
		"video/vsync",
	]),
})

if not report["ok"]:
	print(report["issues"])
```

显示、语言和音频总线可通过应用器处理：

```gdscript
var display := Gf.get_utility(GFDisplaySettingsUtility) as GFDisplaySettingsUtility

display.set_fullscreen(true)
display.set_vsync_mode(DisplayServer.VSYNC_ENABLED)
display.set_locale("zh_CN")
display.register_audio_bus_volume("Master", 1.0)
display.set_audio_bus_volume("Master", 0.75)
```

设置界面可以使用 `GFControlValueAdapter` 和 `GFFormBinder` 读写常见 `Control` 值，避免每个设置页重复判断 `LineEdit`、`CheckBox`、`Slider`、`OptionButton` 等控件类型：

```gdscript
var binder := GFFormBinder.new()
binder.bind_field(&"player_name", %NameEdit)
binder.bind_field(&"fullscreen", %FullscreenCheck)
binder.bind_field(&"master_volume", %MasterVolumeSlider)

binder.write_values(settings.to_dict(false))
binder.field_changed.connect(func(key: StringName, value: Variant) -> void:
	settings.set_value(key, value)
)
```

`GFFormBinder.bind_field()` 会在重复绑定同一字段前清理旧连接，`unbind_field()` / `clear()` 也会断开由 `GFControlValueAdapter` 创建的值变化监听；需要自己管理连接生命周期时，可使用 `connect_value_changed_with_handles()` 和 `disconnect_value_changed_handles()`。

这组工具只提供设置定义、读写、持久化和应用边界；具体设置项命名、分组、显示文案和业务含义仍由项目层决定。


## 基于栈的 UI 管理系统 (`GFUIUtility`)

**应用场景：** 当你需要管理复杂的全屏UI、弹窗、顶层提示，处理多层级（HUD、POPUP、TOP）入栈出栈，以及自动隐藏下层UI以实现全屏UI时。

**如何使用：**
```gdscript
var ui_util := Gf.get_utility(GFUIUtility) as GFUIUtility

# 异步推入一个面板到 POPUP 层（自动结合 GFAssetUtility 加载面板）
ui_util.push_panel_async("res://ui/settings_panel.tscn", GFUIUtility.Layer.POPUP)

# 或者同步加载并推入面板场景
ui_util.push_panel("res://ui/inventory_panel.tscn", GFUIUtility.Layer.POPUP)

# 已经实例化的面板则用 push_panel_instance()
var inventory_panel := preload("res://ui/inventory_panel.tscn").instantiate()
ui_util.push_panel_instance(inventory_panel, GFUIUtility.Layer.POPUP, func(panel: Node) -> void:
	panel.name = "InventoryPanel"
)

# 弹出栈顶面板
ui_util.pop_panel(GFUIUtility.Layer.POPUP)

# 替换当前 POPUP 流程，或回退到某个已打开面板
ui_util.replace_layer("res://ui/main_menu.tscn", GFUIUtility.Layer.POPUP)
ui_util.pop_to_panel(inventory_panel, GFUIUtility.Layer.POPUP)
```

`configure(false)` 可以关闭“压入新面板时自动隐藏同层旧顶层面板”的行为。`push_panel()`、`push_panel_async()`、`push_panel_instance()`、`replace_layer()`、`replace_layer_async()` 和 `replace_layer_instance()` 都支持可选 `config_callback`，会在入栈前拿到面板实例，适合设置初始 DTO 或绑定回调。需要给面板声明通用交互策略时，可使用对应的 `*_with_options()` 入口或对已打开面板调用 `set_panel_options()`：

```gdscript
ui_util.push_panel_instance_with_options(settings_panel, GFUIUtility.Layer.POPUP, {
	"modal": true,
	"dismiss_on_cancel": true,
	"focus_on_open": true,
	"restore_focus_on_close": true,
	"metadata": {
		"route": "settings",
	},
})

if ui_util.request_dismiss_top(-1, "cancel"):
	print("top panel dismissed")
```

`modal` / `PanelMode.MODAL` 只表达“项目层应该把它视为独占交互面板”，并提供取消关闭、打开抢焦点、关闭恢复焦点和 `keep_focus_inside_top_modal()` 这些通用辅助；它不创建遮罩、不播放动画、不拦截输入树，也不决定返回值或页面路由。项目可以监听 `panel_dismiss_requested` 决定音效、路由记录或额外确认。

需要一个通用“确认/选择”协议时，可以使用 `GFModalConfig`、`GFModalAction`、`GFModalResult` 和默认 `GFModalPanel`。它们只描述标题、正文、动作、结果状态、payload 和上下文，不解释奖励、购买、删除存档等业务含义；`GFUIUtility.open_modal()` 会把默认面板压入 UI 栈，并在 `resolved` 后关闭面板：

```gdscript
var action := GFModalAction.new()
action.action_id = &"confirm"
action.label = "Confirm"
action.result_status = GFModalResult.STATUS_CONFIRMED

var config := GFModalConfig.new()
config.title = "Confirm"
config.message = "Continue?"
config.actions = [action]

ui_util.open_modal(config, GFUIUtility.Layer.POPUP, { "source": "settings" }, func(result: GFModalResult) -> void:
	if result.status == GFModalResult.STATUS_CONFIRMED:
		print(result.context)
)
```

`pop_panel()`、`clear_layer()` 和替换层入口会先把旧面板从 UI 根节点移除，再按需释放实例，因此关闭后的面板会立即脱离 `GFUILayer_*`。默认 `pop_panel()` 会释放面板；`pop_panel(layer, false)` 只移除但不释放，适合项目层自己复用实例。如果面板被外部 `queue_free()`，工具会在 `tree_exited` 后从栈中移除并恢复下层面板。`push_panel_async()` 和 `replace_layer_async()` 会优先使用 `GFAssetUtility`，未注册时回退同步加载。每个 UI 层都有请求序号保护，`pop_panel()`、`clear_layer()`、替换层或释放工具后，迟到的异步加载回调会被忽略，不会把旧面板重新压回已经取消或清空的栈。同一层级同一路径的重复异步压栈请求会在资源返回前合并，避免按钮连点时叠出多层相同面板。

`panel_opened`、`panel_closed` 和 `navigation_changed` 适合把 UI 栈变化同步给焦点系统、音效、诊断面板或项目自己的路由层。`get_panel_stack()`、`get_stack_count()`、`is_panel_open()` 和 `get_debug_snapshot()` 只返回当前栈状态，不保存业务历史；如果项目只需要 route id 到面板场景的通用映射，可以在其上注册 `GFUIRouterUtility` 和 `GFUIRoute`：

```gdscript
var route := GFUIRoute.new()
route.route_id = &"settings"
route.scene_path = "res://ui/settings_panel.tscn"
route.layer = GFUIUtility.Layer.POPUP

var router := Gf.get_utility(GFUIRouterUtility) as GFUIRouterUtility
router.register_route(route)
router.push_route(&"settings", { "tab": "audio" })
router.back()
```

`GFUIRouterUtility` 只维护路由表、路由参数、面板打开选项和轻量历史；如果面板实现了 `set_route_params(params)` 或 `set_route_metadata(metadata)`，路由工具会在入栈前调用它们。`back()` 只会弹出当前 UI 栈顶正好是路由历史记录中的面板；如果项目直接通过 `GFUIUtility.push_panel()` 在同层压入了普通面板，应先由项目关闭该普通面板，再让路由返回，避免路由历史和实际 UI 栈互相踩踏。复杂页面恢复、返回值、转场动画、权限和业务导航状态仍应由项目自己的 Model/System 或 UI 节点处理。

每个层级都会创建独立 `CanvasLayer`：`HUD`、`POPUP`、`TOP` 数值越大显示越靠前。`GFUIUtility` 只负责层级根节点、栈顺序、自动隐藏、状态信号、实例加载和少量面板交互策略，不规定 UI 动画、视觉遮罩、输入绑定或面板间通信。

如果项目需要本地多人分屏、每玩家相机或简单的编辑器预览布局，可以使用 `GFViewportUtility`。它只创建和维护 `SubViewportContainer` / `SubViewport` 结构，并提供按索引挂载相机与后处理材质的 API，不接管玩家、镜头规则或场景生命周期：

```gdscript
var viewport_util := GFViewportUtility.new()
var viewports := viewport_util.setup_split_screen(%Root, 2, {
	"viewport_size": Vector2i(640, 360),
})
viewport_util.set_viewport_camera(0, $Camera2D)
```

默认情况下，`viewport_size` 会保持 SubViewport 的渲染尺寸，`viewport_resolution_scale` 会按比例缩放该尺寸；需要让 SubViewport 跟随容器大小时，可在 options 中传入 `"stretch": true`。`clear_split_screen()` 会立即把旧 `GridContainer` 和已挂载相机从当前树上移除，再按参数决定是否释放相机，便于同一帧重建布局或切换分屏配置。

同一个工具还提供少量不绑定输入来源的坐标辅助。`screen_to_world_ray_3d(camera, screen_position, length)` 可从 Camera3D 和 Viewport 坐标生成射线，`raycast_from_screen_3d()` 在此基础上执行物理射线检测，`world_to_screen_3d()` 做 3D 投影；2D 侧可用 `world_to_screen_2d(canvas_item, world_position)` 与 `screen_to_world_2d(canvas_item, screen_position)` 在 CanvasItem 世界坐标和屏幕坐标之间转换。这些方法不读取鼠标、不选择玩家、不决定命中对象含义，只提供稳定几何转换。

如果项目需要让按钮、计数器、局部标签或富文本在固定区域内自动选择字体大小，可以使用 `GFTextFitter`。它是纯静态辅助类，不需要注册到架构，也不会修改布局规则；默认只把计算出的字体尺寸写入目标控件的 theme override：

```gdscript
GFTextFitter.fit_label(%TitleLabel, {
	"min_font_size": 12,
	"max_font_size": 32,
	"available_size": Vector2(220, 48),
})

GFTextFitter.fit_rich_text_label(%CostText, {
	"fit_height": true,
})

GFTextFitter.fit_control(%ApplyButton, {
	"min_font_size": 10,
	"max_font_size": 28,
})
```

`fit_control()` 会按常见 Godot 控件推导文本、主题字体名和内容边距，支持 `Button`、`LineEdit`、`TextEdit`、`Label` 和 `RichTextLabel`；无法识别的自定义控件可以通过 `options.text`、`font_name`、`font_size_name` 和 `content_insets` 显式提供信息。需要随控件 resize 或语言变化自动刷新时，把 `GFTextAutoFit` 挂到目标控件下，或用 `target_path` 指向目标 Control。`GFTextFitter` / `GFTextAutoFit` 只处理通用文本尺寸适配；换行策略、截断、省略号、本地化长词拆分和具体 UI 视觉仍应由项目自己的控件或主题决定。

如果项目需要把玩家输入、配置文本、调试日志或本地化片段安全写入 `RichTextLabel`，可以使用 `GFRichTextFormatter`。它是纯静态辅助类，不注册架构、不加载资源，也不规定文本来源或图标集：

```gdscript
var bbcode := GFRichTextFormatter.to_bbcode("Hello {{name}} :confirm:", {
	"markup": GFRichTextFormatter.MARKUP_PLAIN,
	"variables": {
		"name": player_name,
	},
	"token_resolver": func(token: String) -> String:
		return "[img]res://ui/icons/%s.png[/img]" % token,
})
%RichTextLabel.text = bbcode
```

`MARKUP_PLAIN` 会转义所有 BBCode 控制字符；`MARKUP_MARKDOWN` 只转换粗体、斜体、删除线、行内 code、链接和图片这组常见子集，其余文本仍会转义；`MARKUP_BBCODE` 则保留项目已经构造好的 BBCode。`replace_variables()` 默认转义变量值，适合用户文本、本地化参数和外部数据；`replace_tokens()` 默认允许 resolver 返回 `[img]...[/img]` 这类项目生成的 BBCode，但只会处理由字母、数字、下划线、短横线和点组成的安全 token。复杂排版、逐字播放、语言分词、图标资源存在性检查和 UI 交互仍应留在项目层。

### 通用节点树操作 (`GFNodeTreeOps`)

`GFNodeTreeOps` 是纯静态节点树操作集合，不需要注册到 `GFArchitecture`。它适合编辑器工具、运行时装配、能力容器、对象池或场景工厂中复用一些容易写散的操作：安全添加子节点并设置 `owner`、重挂节点、替换子节点、按类型向上/向下查找、收集节点树、递归设置 owner 和释放直接子节点。`free_children()` 会先把直接子节点从父节点移除，再调用 `queue_free()`，因此调用后父节点同帧就不再持有旧子节点。

```gdscript
var capability := HitboxCapability.new()
GFNodeTreeOps.add_child_with_owner(container, capability, get_tree().current_scene)

var camera := GFNodeTreeOps.find_first_child_of_type(root, Camera3D, true) as Camera3D
var all_controls := GFNodeTreeOps.collect_node_tree(root, Control)
```

类型过滤可以传脚本类型、原生类或类名字符串；字符串形式会同时检查原生 `is_class()`、GDScript `class_name` 和脚本资源路径。这个工具只处理通用 Node 结构，不判断节点是否“应该”属于某种业务容器。需要注册能力、同步存档、创建 UI 栈或切换场景时，仍应使用对应的 `GFCapabilityUtility`、`GFSaveGraphUtility`、`GFUIUtility` 或 `GFSceneUtility`。


## 场景与流程切换管理器 (`GFSceneUtility`)

**应用场景：** 当项目需要切换主场景、播放 Loading 过渡、后台预加载资源，并在切换时清理旧场景专用系统时，可以使用 `GFSceneUtility`。

**如何使用：**
```gdscript
var scene_util := Gf.get_utility(GFSceneUtility) as GFSceneUtility

# 标记 BattleSystem 为瞬态，它会在切场景时自动从架构中被注销/销毁
scene_util.mark_transient(BattleSystem)

# 开始带 Loading 过渡的异步切换
scene_util.load_scene_async("res://levels/level_2.tscn", "res://ui/loading_screen.tscn")
```

如果项目希望把切换参数做成资源，可使用 `GFSceneTransitionConfig`：

```gdscript
var transition := GFSceneTransitionConfig.new()
transition.target_scene_path = "res://levels/level_2.tscn"
transition.loading_scene_path = "res://ui/loading_screen.tscn"
transition.preload_before_change = true
transition.cache_loaded_scene = true
transition.params = { "spawn_point": "gate_a" }
transition.minimum_duration_seconds = 0.35

scene_util.load_scene_with_transition(transition)
```

如果项目需要在关卡入口、地图预览或传送门附近提前准备场景资源，可以使用预加载缓存。缓存是 LRU 上限控制，`max_preloaded_scene_resources = 0` 时会清空并禁用缓存。

```gdscript
scene_util.max_preloaded_scene_resources = 4
scene_util.preload_scene("res://levels/level_3.tscn")
scene_util.preload_scene("res://levels/hub.tscn", true) # 固定缓存，不参与 LRU 淘汰

scene_util.scene_preload_completed.connect(func(path: String, _scene: PackedScene) -> void:
	if path == "res://levels/level_3.tscn":
		scene_util.load_scene_async(path)
)

scene_util.begin_background_scene_load("res://levels/level_4.tscn", { "spawn_point": "gate_b" })
scene_util.activate_background_scene("res://levels/level_4.tscn", "res://ui/loading_screen.tscn")

var snapshot := scene_util.get_scene_cache_debug_snapshot()
print(snapshot["preload_cache"]["paths"])
```

如果相邻场景关系比较稳定，可以把预加载规则做成 `GFScenePreloadMap` 资源。每个 `GFScenePreloadEntry` 描述一个场景路径、相邻场景路径和是否固定缓存；`GFSceneUtility` 只按图谱计算预加载计划，不解释“关卡”“传送门”或“菜单流”的业务含义。

```gdscript
var preload_map := GFScenePreloadMap.new()
var hub_entry := GFScenePreloadEntry.new()
hub_entry.scene_path = "res://levels/hub.tscn"
hub_entry.adjacent_scene_paths = PackedStringArray([
	"res://levels/forest.tscn",
	"res://levels/cave.tscn",
])
preload_map.entries = [hub_entry]
preload_map.fixed_scene_paths = PackedStringArray(["res://ui/loading_screen.tscn"])

scene_util.configure_scene_preload_map(preload_map, 1, true)
scene_util.preload_scene_map_for("res://levels/hub.tscn")
```

`get_scene_preload_map_plan(path, radius, include_fixed)` 只返回计划，适合调试 UI 或测试断言；`preload_scene_map_for()` 会把固定路径以 fixed cache 发起预加载，把相邻路径放入临时 LRU 缓存。`scene_preload_map_radius = -1` 表示使用图谱自身的 `default_radius`；`auto_preload_map_neighbors_on_switch = true` 时，成功切换到目标场景后会自动按当前路径预加载相邻场景。图谱的 `validate_map({ "check_exists": true })` 可检查空路径、重复条目、自引用和缺失资源。图谱适合表达可复用资源关系；如果预加载依赖玩家进度、动态服务器配置或复杂权重，应由项目层先计算候选路径，再交给 `preload_scenes()` 或 `preload_scene_map_for()`。

切换参数可直接传给 `load_scene_async(path, loading_scene_path, params, minimum_duration_seconds)`，也可以写在 `GFSceneTransitionConfig.params` 中。`begin_background_scene_load(path, params, fixed)` 会复用预加载缓存并记录稍后激活时使用的参数；`activate_background_scene(path, loading_scene_path, minimum_duration_seconds)` 只激活已经预加载或正在预加载的场景，不会把任意缺失资源变成隐式切换请求。切换成功后，`get_current_scene_params()` 返回当前场景参数副本，适合场景入口脚本读取出生点、入口来源、过场配置或项目自定义 DTO。`minimum_duration_seconds` 只控制 loading scene 至少停留多久，避免缓存命中时过渡 UI 一闪而过；它不替代目标场景自己的初始化等待。

`load_scene_async()` 可以在 `_ready()`、初始化完成回调、按钮回调或普通系统逻辑中调用。GF 会把 loading scene、缓存命中的目标场景和失败恢复都调度到安全帧执行，避免 Godot 在父节点仍处于添加/移除子节点阶段时报 `remove_child()` 时序错误。因此即使命中预加载缓存，也不要依赖调用栈内立即完成场景切换；需要观察完成结果时监听 `scene_load_completed` / `scene_switch_completed`。在 headless 运行环境中，活动场景加载会自动改用同步资源解析作为降级路径，但仍沿用同一套 loading 状态、缓存写入、完成信号和安全切场流程，便于命令行启动链路和 CI 验证复用项目的标准场景路由。

`GFSceneUtility` 会在成功切换后记录上一场景路径和参数，可通过 `get_scene_history()`、`pop_scene_history()`、`clear_scene_history()` 和 `load_previous_scene()` 实现通用返回上一个场景流程。历史只保存路径与参数，不保存节点实例或项目运行状态；需要恢复关卡内实体、UI 或玩家数据时仍应使用项目自己的 Model/存档结构。

`mark_transient()` 可标记随场景切换清理的 `GFModel`、`GFSystem` 或 `GFUtility` 脚本类型；清理时会调用架构对应的注销流程，不适合标记跨场景长期服务。`get_scene_resource_state()` 可区分未加载、预加载中、已缓存和当前加载，`get_scene_resource_info()` 会额外返回固定缓存、预加载进度和文件大小信息。预加载请求可用 `cancel_scene_preload()` 或 `cancel_all_scene_preloads()` 标记取消；和 `GFAssetUtility.cancel()` 一样，它只取消 GF 侧完成信号和缓存写入，不保证中止 Godot 已发起的资源线程。已缓存的场景可用 `remove_preloaded_scene()` 或 `clear_preloaded_scenes()` 手动释放；固定缓存可通过 `move_preloaded_scene_to_fixed()` / `move_preloaded_scene_to_temporary()` 在长期保留和 LRU 管理之间切换。

切换期间如果注册了 `GFTimeUtility`，工具会暂时设置全局暂停，并在成功或失败后恢复旧暂停状态。带 loading scene 的失败恢复依赖上一场景的 `scene_file_path`；如果当前场景没有资源路径，工具会跳过 loading scene，避免失败后无法切回。Loading scene 可以选择实现 `fade_in()`、`fade_out()`、`set_progress(progress)` / `update_progress(progress)` 或 `show_error(message)`，GF 会在切入、进度变化、失败和退出前按约定调用；这些方法只是协议钩子，不规定 UI 样式、文案或动画。GF 只管理场景资源生命周期、切换、进度信号和瞬态模块清理；具体加载界面表现、场景内初始化和关卡解锁规则仍属于项目层。


## 3D 表面材质查询 (`GFSurfaceUtility`)

**应用场景：** 当 RayCast3D 命中了 `ConcavePolygonShape3D` 或由 Mesh 生成的碰撞面，你拿到的是 face index，但脚步声、弹孔、命中特效等通常想按 Mesh surface 或材质分发。

```gdscript
var surfaces := Gf.get_utility(GFSurfaceUtility) as GFSurfaceUtility
var face_index := ray_cast.get_collision_face_index()
var collider := ray_cast.get_collider()

var material := surfaces.get_active_material(collider, face_index)
var surface_index := surfaces.get_surface_index(collider, face_index)
```

`GFSurfaceUtility` 会尝试从命中的 `MeshInstance3D`、父节点、子节点或相邻节点解析 Mesh，并缓存每个 surface 的 face 数量。它只完成 face 到 surface/material 的映射，不内置“泥地”“金属”“水面”等业务标签。

`get_base_material()` 返回 Mesh surface 上的基础材质，`get_surface_override_material()` 返回 `MeshInstance3D` 的 surface override，`get_active_material()` 返回 Godot 最终用于渲染的 active material。缓存以 Mesh RID 为键；默认 `cache_mode` 为 `AUTOMATIC`，会按 `auto_cache_size` 做自动裁剪。需要避免首次命中时计算 surface 面数，可在加载阶段调用 `cache_mesh_surface(mesh_or_mesh_instance)` 预热；需要完全手动管理时可切到 `MANUAL`，需要排查动态 Mesh 变化时可切到 `DISABLED`。运行时替换 Mesh 或动态修改 surface 结构后，可调用 `erase_cached_mesh()` 或 `clear_cache()` 重新计算。
