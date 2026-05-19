# 调试、日志、诊断与控制台

这些工具为开发期观测、运行时日志、构建信息、支持报告、通知队列和控制台提供统一入口。

## 调试绘制命令缓冲 (`GFDebugDrawUtility`)

`GFDebugDrawUtility` 用于在开发期收集 2D/3D 调试绘制命令，例如路径、范围、碰撞盒、文本标注。它只维护命令、频道和生命周期，不规定具体 Overlay 或渲染节点：

```gdscript
var debug_draw := Gf.get_utility(GFDebugDrawUtility) as GFDebugDrawUtility
debug_draw.draw_line_2d(Vector2.ZERO, Vector2(64, 0), Color.RED, 0.2, &"path")
debug_draw.draw_box_3d(AABB(Vector3.ZERO, Vector3.ONE), Color.GREEN, 1.0, &"physics")

for item in debug_draw.get_items(&"path"):
	print(item)
```

项目可以按频道开关命令，再用自己的 `CanvasItem`、`Node3D` 或编辑器面板消费 `get_items()` 返回的数据。`enabled = false` 会让默认读取返回空数组，但不删除已有命令；`get_items(channel, true)` 可用于调试面板查看被禁用频道的数据。

生命周期规则：单条命令传入负数时使用 `default_lifetime_seconds`，默认值为 `0.0`，表示等待下一次 `tick()` 后清理；`default_lifetime_seconds < 0` 表示永久保留。`max_items` 可限制缓冲区规模，超过后会丢弃最旧命令。


## 调试覆盖层 (`GFDebugOverlayUtility`)

**应用场景：** 当你在运行游戏时觉得模型状态不对，但没有连上编辑器检查时。本工具会创建一个轻量 `CanvasLayer` 覆盖层，通过反射扫描当前架构内注册的 `GFModel`，并显示脚本变量的实时值；项目也可以主动注册少量运行时 watch，把不适合放进 Model 的临时观察值显示在同一个面板里。

它不是命令行控制台，也不执行指令；需要输入调试命令、查看日志输出时请使用后面的 `GFConsoleUtility`。覆盖层默认 `debug_only = true`，发布构建不会创建 GUI；如果项目确实需要在非 debug 构建中显示，必须显式关闭该选项，并自行确认数据脱敏和玩家可见性。覆盖层会直接反射显示脚本变量值，并显示项目注册的 watch 返回值，不做字段脱敏或白名单过滤；不要在生产构建、公开演示或包含账号/token/存档密钥等敏感字段的环境中默认注册或开启。

**如何使用：**
```gdscript
var debug := Gf.get_utility(GFDebugOverlayUtility) as GFDebugOverlayUtility

# 默认按 `~` 呼出/隐藏，可按项目需要更换快捷键和刷新间隔。
debug.set_toggle_key(KEY_QUOTELEFT)
debug.set_refresh_interval(0.25)

# 可选：主动推送当前值，适合项目层已有刷新点的指标。
debug.push_watch_value(&"fps", Engine.get_frames_per_second(), {
	"label": "FPS",
	"group": "Runtime",
})

# 可选：注册拉取式 provider，Overlay 刷新时读取当前值。
var scene_path_provider := func() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	return scene.scene_file_path

debug.watch_value(&"scene_path", scene_path_provider, {
	"label": "Scene",
	"group": "Runtime",
})
```

`watch_value()` 适合廉价、无副作用的当前状态读取；`push_watch_value()` 适合由项目循环或回调主动更新的值。注册了 `GFDiagnosticsUtility` 时，Overlay 默认也会显示 `overlay` 诊断监控预设，可用 `set_diagnostics_monitor_preset()` 切换预设，或把 `include_diagnostics_monitors` 设为 `false` 只显示手动 watch。Watch 只是一层调试显示通道，不保存历史、不做采样统计，也不规定业务字段；需要长期记录请接入 `GFLogUtility` / `GFDiagnosticsUtility` 或项目自己的分析系统。Overlay 所属 GUI 在 `dispose()` 时会立即从场景树移除，避免调试层在架构销毁同一帧继续残留。

需要显示多行结构化内容时，可以用 `register_panel()` 或 `push_panel_text()` 注册 Overlay 面板。面板 provider 可以返回字符串、数组或字典，Overlay 会把它们格式化为只读文本；`include_recent_logs` 开启时还会附加最近日志面板。面板同样不做脱敏，适合开发期聚合 `GFDiagnosticsUtility` 快照、项目局部状态或自定义工具输出。


## 运行时调参注册表 (`GFRuntimeInspectorUtility`)

`GFRuntimeInspectorUtility` 提供显式 schema 驱动的运行时检查和调参入口。项目必须主动注册目标对象和 `GFRuntimeTunableProperty`，框架只负责读取、归一化、写入门禁、快照和可选 Overlay 面板，不会自动扫描所有节点、Model 或项目字段。

```gdscript
var inspector := Gf.get_utility(GFRuntimeInspectorUtility) as GFRuntimeInspectorUtility

var move_speed := GFRuntimeTunableProperty.new(
	&"move_speed",
	^"move_speed",
	GFRuntimeTunableProperty.ValueKind.FLOAT
).with_range(0.0, 1200.0, 10.0)

inspector.register_target(&"player", player_stats, [move_speed], {
	"label": "Player Stats",
	"group": "Combat",
})

inspector.set_property_value(&"player", &"move_speed", 480.0)
print(inspector.get_target_snapshot())
```

`GFRuntimeTunableProperty` 可声明 bool、int、float、String、StringName、Vector2、Vector3、Color 或任意值，也可以设置范围、可选值、只读、显示分组和自定义 getter/setter/validator。`GFRuntimeInspectorUtility.allow_writes` 可整体关闭写入，`debug_build_writes_only` 默认让非 debug 构建不能通过该工具写值。需要把调参快照放进调试覆盖层时，调用 `attach_to_debug_overlay()`；面向玩家的入口、远程运维工具或线上调试入口仍应由项目层做权限、白名单和脱敏。


## 信号诊断与运行时信号探针 (`GFSceneSignalAudit` / `GFSignalRuntimeProbe`)

编辑器侧的 `GFSceneSignalAudit.build_signal_graph()` / `index_signal_graph()` 可把当前节点树的信号、连接和节点索引整理为结构化数据；需要隐藏根节点外的目标时可传入 `include_external_targets = false`。信号图默认限制节点深度和节点数量，可通过 `max_node_depth` / `max_nodes` 调整，截断时报告会标记 `truncated`。`GFSignalGraphDock` 会把当前编辑场景渲染为 `GF Workspace > 信号诊断` 页面，默认查看场景文件中保存的信号连接并过滤编辑器外部目标，方便查看 source、signal、target 和 method。勾选“未连接信号”可以列出节点声明过但还没有连接目标的信号；勾选“追踪发射”后，面板会按连接页当前可见信号建立监听，优先追踪保存连接里的信号，避免 `draw` 这类高频内建信号刷屏。

如果要确认“信号有没有真的发射”，可以显式创建 `GFSignalRuntimeProbe` 监听一个节点或节点树。它会记录最近事件、发射时间、来源节点、信号名、参数和当前连接摘要；单个信号最多追踪 16 个参数，超过上限的极少数自定义信号应在项目层自行封装 payload。它只在项目主动 watch 后工作，不会默认全局接管所有信号：

```gdscript
var probe := GFSignalRuntimeProbe.new()
probe.max_events = 200
probe.signal_emitted.connect(func(event: Dictionary) -> void:
	print(event["source_node_path"], event["signal_name"], event["arguments"])
)

probe.watch_tree(get_tree().current_scene, {
	"recursive": true,
	"include_signals": PackedStringArray(["pressed", "timeout"]),
	"max_node_depth": 64,
	"max_nodes": 4096,
})
```

`GFSignalGraphDock` 的“发射记录”页也是基于这个探针，只有打开“追踪发射”后才会连接当前场景信号。它记录的是开启追踪之后发生的事件，不会回放旧信号；编辑器工作区也不会自动抓取独立运行的游戏进程。节点树监听默认带深度和数量上限，避免误选整个大型场景树时把所有信号都连上。不要在生产构建默认开启全场景探针；面对远程调试、玩家可见工具或包含敏感参数的信号时，应由项目层限制范围、脱敏和权限。


## 全局随机数种子管理器 (`GFSeedUtility`)

**应用场景：** 当你需要管理全局随机流以保证游戏的核心随机事件（如掉落、遇敌、甚至战斗回放）具有确定性和可观测性时。它支持恢复指定的随机序列状态，并且可以通过标签派生出完全独立的子随机发生器。

**如何使用：**
```gdscript
var seed_util := Gf.get_utility(GFSeedUtility) as GFSeedUtility

# 设置全局主种子
seed_util.set_global_seed(12345)

# 可以随时获取当前的主种子
var current_seed := seed_util.get_global_seed()

# 获取并保存当前主 RNG 的精确内部状态，为稍后的回放或状态恢复做准备
var current_state := seed_util.get_state()

# ...进行一系列随机操作...

# 恢复此前保存的状态，使得接下来的随机序列能完全复现
seed_util.set_state(current_state)

# 派生出一个专门用于某模块的子 RNG
var combat_rng := seed_util.get_branched_rng("combat_calculations")
print(combat_rng.randi())
```

`get_state()` / `set_state()` 只处理主 RNG 的内部状态；如果项目还使用了 `get_branched_rng()`，应使用 `get_full_state()` / `set_full_state()` 保存和恢复主种子、主 RNG 状态以及各标签的分支调用计数。`get_full_state()` 返回的是面向默认 JSON 存储的状态字典，当前 `state_schema_version` 为 `2`；`global_seed`、`rng_state` 和分支计数都使用十进制字符串保存，避免 Godot JSON 解析 64 位整数时丢失精度。项目层不要把这些字段改回裸数字，也不要把 `state_schema_version` 当作 GF 框架版本号。需要恢复单个整数 RNG 状态时使用 `set_state()`。`set_global_seed()` 会重置分支计数。作为 Utility 注册到架构时会正常初始化；测试或工具代码直接 `GFSeedUtility.new()` 调用公共方法时，也会懒初始化内部 RNG。

分支 RNG 的生成不会推进主 RNG 序列。同一主种子、同一主状态、同一标签和同一调用序号会得到相同的子随机序列，适合掉落表、AI 局部决策或回放中需要隔离随机流的模块。分支种子使用稳定 FNV-32 哈希，目标是玩法确定性和回放稳定，不适合作为安全随机、抽卡防作弊或服务端权威随机来源。


## 集中式日志系统 (`GFLogUtility`)

**应用场景：** 当项目需要统一分级日志、结构化上下文、本地日志文件、运行时控制台同步和诊断采集时，可以使用 `GFLogUtility`。

初始化时会在 `user://logs/` 下创建按日期时间命名的日志文件，并自动清理超出保留数量的旧日志。每条日志会同时生成结构化条目，进入内存环形缓存，写入本地文件，并通过 `log_emitted` / `log_entry_emitted` 广播给控制台、诊断面板或项目自定义采集器。

`GFLogUtility` 是标准库通用工具，不会因为脚本存在就自动注册到架构。项目需要日志时，应在项目 Installer 中显式装配；如果同一项目可能由不同 Installer 组合装配，先用 `get_local_utility()` 做保护，避免重复注册 warning：

```gdscript
func install(architecture: GFArchitecture) -> void:
	if architecture.get_local_utility(GFLogUtility) == null:
		await architecture.register_utility_instance(GFLogUtility.new())
```

**如何使用：**
```gdscript
var log_util := Gf.get_utility(GFLogUtility) as GFLogUtility
if log_util == null:
	return

# 各等级日志 —— 第一个参数是标签（推荐用类名或模块名），第二个是消息内容
log_util.debug("System", "系统初始化完毕。")
log_util.info("Network", "接通服务器。")
log_util.warn("Memory", "内存占用略高。")
log_util.error("Math", "除以了零。")

# 可选：附加结构化上下文
log_util.info("Scene", "场景加载完成。", {
	"path": "res://levels/test.tscn",
	"elapsed_ms": 18,
})

# 当日志太多时，可以动态静音某些不重要的标签，静音后不再打印与写入本地：
log_util.set_tag_muted("Network", true)

log_util.warn("Network", "延迟过高：%d ms。" % 150) # 这条将不会被打印或写入文件
log_util.error("AudioBus", "找不到总线: %s" % "Master")
log_util.fatal("Core", "不可恢复的致命错误！")

# 监听兼容日志信号（GFConsoleUtility 已自动监听）
log_util.log_emitted.connect(func(level: int, tag: String, msg: String) -> void:
	print("收到日志: [%d] %s - %s" % [level, tag, msg])
)

# 监听结构化日志条目
log_util.log_entry_emitted.connect(func(entry: Dictionary) -> void:
	print(entry["context"])
)

# 可选：调整最大日志文件保留数量（默认 10）
log_util.max_log_files = 20

# 可选：过滤低等级日志，并延迟构造高成本消息
log_util.min_level = GFLogUtility.LogLevel.WARN
var message_builder := func() -> String:
	return "节点数：%d" % 10000
var context_builder := func() -> Dictionary:
	return {"frame": Engine.get_process_frames()}
log_util.warn_lazy("PathFinding", message_builder, context_builder)

# 可选：给所有结构化日志附加一次运行的追踪 ID 和全局上下文
log_util.set_trace_id("session-20260509-001")
log_util.set_global_context({
	"scene": "battle",
	"profile": "debug",
})

# 可选：读取内存中的最近日志，适合调试面板或运行时控制台分页
for entry in log_util.get_recent_entries(50):
	print(entry["text"])
```

`GFLogSink` 是日志输出 sink 基类。项目可以继承它，把 `log_entry_emitted` 同形态的结构化条目写到 JSONL、本地诊断面板、编辑器工具或自定义运行时采集器。通过 `add_sink()` / `remove_sink()` / `clear_sinks()` 管理 sink 生命周期；日志工具会在 `init()` 后调用 sink 的 `init()`，在 `flush_sinks()` 或 `dispose()` 时转发刷新和关闭钩子。

需要本地结构化日志文件时，可以直接注册 `GFJsonLineLogSink`。默认路径为空时，它会根据当前 `.log` 文件派生同名 `.jsonl` 文件；每一行都是独立 JSON 对象，适合诊断工具、测试或离线分析读取：

```gdscript
var jsonl_sink := GFJsonLineLogSink.new()
jsonl_sink.omit_formatted_text = true
jsonl_sink.max_jsonl_files = 10
log_util.add_sink(jsonl_sink)
```

`GFJsonLineLogSink` 会把 `StringName`、`NodePath` 和非 JSON 原生值转换成稳定字符串，避免上下文里混入 Godot 对象后破坏 JSONL 文件。默认派生路径使用 `gf_log_*.jsonl`，并由 `max_jsonl_files` 单独控制保留数量；显式设置 `file_path` 时，文件命名和清理策略由项目层负责。

需要把日志交给远端服务、平台 SDK、编辑器桥接或测试采集器时，可以使用 `GFBatchedLogSink`。它只负责清洗、排队、按 `batch_size` 分批和触发 `sender_callback` / `batch_ready`，不内置任何 HTTP 端点、鉴权或服务端字段：

```gdscript
var batch_sink := GFBatchedLogSink.new()
batch_sink.batch_size = 20
batch_sink.sender_callback = func(payload: Dictionary) -> Dictionary:
	# 项目层自行发送 payload["logs"]。
	return { "ok": true }
log_util.add_sink(batch_sink)
```

低于 `min_level` 或被 `set_tag_muted()` 静音的日志不会打印、写入文件、进入内存缓存、写入 sink 或发出日志信号。`*_lazy()` 系列只有在日志实际会输出时才调用 `message_builder` 和可选 `context_builder`，适合构造成本高的调试文本与上下文。

文件默认按 `flush_interval_msec` 批量 flush，`flush_immediately = true` 或 `flush_interval_msec <= 0` 时每条日志立即 flush；`ERROR` / `FATAL` 会强制尽快写盘。内存缓存由 `max_memory_entries` 控制，超出后按环形缓冲覆盖最旧条目，并可通过 `get_dropped_memory_entry_count()` 观察丢弃数量。当前日志文件路径可通过 `get_log_file_path()` 读取，便于测试、诊断界面或导出工具定位文件。

结构化上下文会经过 `sanitize_log_value()` 清洗，过深嵌套、超长字符串和非 JSON 原生对象会被转换为可写入日志的稳定值，避免调试数据意外破坏日志 sink。`trace_id` 是每次运行的轻量关联字段；项目可以显式设置，也可以使用默认生成值。`crash_marker_enabled` 开启时，日志工具会在初始化时检查上一次运行是否留下未清理标记，并通过 `previous_crash_detected` 发出报告；这只用于提示“上次可能异常退出”，不替项目判断崩溃原因、上传策略或恢复流程。

### 构建信息快照 (`GFBuildInfoUtility`)

`GFBuildInfo` 是轻量 Resource，包含项目名、项目版本、GF 版本、构建号、提交号、分支、标签、提交数量、dirty 标记、构建时间、Godot 版本、平台和自定义 `metadata`。`GFBuildInfo.collect()` 会从 `ProjectSettings` 与 `addons/gf/plugin.cfg` 采集当前环境；项目发布流水线可以写入 `gf/build/id`、`gf/build/commit_hash`、`gf/build/branch`、`gf/build/tag`、`gf/build/commit_count`、`gf/build/is_dirty`、`gf/build/time_utc` 与 `gf/build/metadata`，运行时再统一读取。需要在导出前从本地 Git 工作区写入这些字段时，可在编辑器脚本或 CI 脚本中调用 `GFBuildInfo.write_git_metadata_to_project_settings(work_dir, extra_metadata, save_settings)`。启用 GF 插件后，`GFBuildInfoExportPlugin` 会注册可选导出入口；把 `gf/build/export/write_git_metadata` 设为 `true` 后，导出开始时会写入 Git 元数据，默认在导出结束后恢复旧 ProjectSettings，避免开发期配置被导出流程污染。

```gdscript
var build_info := GFBuildInfo.collect()
print(build_info.to_dict())

var build_info_utility := GFBuildInfoUtility.new()
build_info_utility.set_build_info(build_info)
print(build_info_utility.get_summary())
```

注册 `GFBuildInfoUtility` 后，`GFDiagnosticsUtility` 的 `build` 字段和 `tools.build_info` 快照会优先使用该工具中的稳定副本；未注册时诊断快照仍会采集一份当前环境信息。构建信息只描述版本和发行上下文，不负责热更新、兼容性判断或存档迁移策略。

`GFDiagnosticsUtility` 可在运行时聚合架构生命周期、事件系统、性能监视器、日志缓存、常见工具快照和外部贡献的诊断分区，并提供可注册的诊断命令入口：

```gdscript
var diagnostics := Gf.get_utility(GFDiagnosticsUtility) as GFDiagnosticsUtility
var snapshot := diagnostics.collect_snapshot({
	"recent_log_count": 10,
})
var performance := diagnostics.execute_command(&"diagnostics.performance")
var tools := diagnostics.execute_command(&"diagnostics.tools")
```

需要在运行时查看当前场景结构时，可显式采集只读场景树快照。它只记录节点名、类型、路径、可选脚本路径和子节点摘要，不读取任意属性、不调用业务方法，也不修改节点：

```gdscript
var scene := diagnostics.execute_command(&"diagnostics.scene", {
	"max_depth": 3,
	"max_nodes": 128,
	"include_groups": true,
})

var snapshot_with_scene := diagnostics.collect_snapshot({
	"include_scene_tree": true,
	"scene_tree_options": {
		"max_depth": 2,
	},
})
```

需要把诊断命令暴露给编辑器面板、远程开发工具或项目自定义控制台时，可以为命令声明参数 schema，并按命令启停。Schema 只做通用类型、必填、默认值、枚举值和数值范围校验，不负责业务权限；真正的入口权限仍由项目层决定：

```gdscript
diagnostics.register_command(
	&"runtime.limit",
	func(args: Dictionary) -> Dictionary:
		return { "limit": args["limit"] },
	"读取限制值。",
	GFDiagnosticsUtility.CommandTier.OBSERVE,
	{
		"parameters": [
			{
				"name": "limit",
				"type": "int",
				"default": 3,
				"min": 1,
				"max": 10,
			},
		],
	}
)

diagnostics.set_command_enabled(&"runtime.limit", false)
```

`execute_command_json_safe()` 会把命令结果通过 `GFVariantJsonCodec` 转成 JSON 友好结构，适合写入文件、支持报告或调试面板数据源。默认 `execute_command()` 仍返回原始 Variant，方便本地工具保留 `Vector3`、`Color`、`NodePath` 等 Godot 类型。

诊断快照的 `tools` 字段会聚合已注册模块公开的 `get_debug_snapshot()`，标准库内置读取 `GFBuildInfoUtility`、`GFAssetUtility`、`GFTimerUtility`、`GFRemoteCacheUtility`、`GFDownloadUtility` 和 `GFObjectPoolUtility`。GF 内置扩展或项目模块如果也想进入诊断快照，应主动调用 `register_tool_snapshot_provider()`、`register_snapshot_section_provider()`、`register_monitor()` 或 `register_command()` 贡献数据；例如 ActionQueue 扩展贡献 `tools.action_queue` 监控和 `tools.action_queue` 快照，Network 扩展贡献 `network` 快照分区。`GFDiagnosticsUtility` 不硬编码任何 GF 内置扩展 ID、路径或类型，因此扩展禁用或删除时不会影响标准库加载。这些快照只表达版本、队列、缓存、pending 数量和运行状态，不解释项目业务含义。编辑器侧的 `GFSceneSignalAudit.build_signal_graph()` / `index_signal_graph()` 可把运行中节点树的信号、连接、节点索引整理为结构化数据；需要隐藏根节点外的目标时可传入 `include_external_targets = false`。`GFSignalGraphDock` 则把当前编辑场景渲染为 `GF Workspace > 信号诊断` 页面，默认查看保存连接并过滤编辑器外部目标，方便查看 source、signal、target 和 method。快照默认可包含构建信息、最近日志、外部贡献分区、URL 派生的缓存状态、工具路径和项目自定义 monitor 输出；如果要暴露给远程调试、玩家可访问控制台或线上 GM 工具，应在项目层做脱敏、白名单过滤和权限控制。

`collect_signal_graph_snapshot()` 与内置命令 `diagnostics.signals` 会对当前场景根或传入根节点生成只读信号图；`collect_snapshot({ "include_signal_graph": true })` 可把它合并进完整诊断快照。它不会连接、断开或触发信号，只读取节点、信号和连接摘要。

诊断监控项适合给 Overlay、编辑器面板或远程调试工具提供稳定采样入口。内置预设包括 `minimal`、`performance`、`architecture`、`tools` 与 `overlay`；`GF Workspace > Diagnostics` 页面可直接采集这些预设、通用性能数据、工具快照和可选场景树摘要，便于开发期只读排查。项目也可以注册自己的轻量 provider，并按预设导出 JSON、文本或 CSV：

```gdscript
var enemy_count_provider := func() -> int:
	return enemies.size()

diagnostics.register_monitor(&"runtime.enemy_count", enemy_count_provider, {
	"label": "Enemies",
	"group": "Runtime",
})
diagnostics.register_monitor_preset(&"runtime", PackedStringArray(["runtime.enemy_count"]))
diagnostics.register_tool_snapshot_provider(&"runtime", func() -> Dictionary:
	return { "enemy_count": enemies.size() }
)

var monitor_snapshot := diagnostics.collect_monitor_preset(&"runtime")
var text := diagnostics.export_monitor_snapshot(monitor_snapshot, &"text")
```

诊断命令可设置风险等级与认证要求。默认只允许观察类命令；如果项目要把控制类命令桥接到远程调试或编辑器工具，应显式提高 `max_command_tier` 并按需要启用 token。`DANGER` 等级即使在等级范围内，也需要额外设置 `allow_danger_commands = true` 才会执行：

```gdscript
diagnostics.set_auth_token("dev-token")
diagnostics.max_command_tier = GFDiagnosticsUtility.CommandTier.CONTROL
diagnostics.register_command(
	&"runtime.pause",
	Callable(self, "_diagnostics_pause"),
	"暂停运行时。",
	GFDiagnosticsUtility.CommandTier.CONTROL
)
```

### 支持报告 (`GFSupportReportUtility`)

`GFSupportReportUtility` 用于把用户描述、项目元数据、构建信息、运行时信息、`GFDiagnosticsUtility` 快照、日志缓存和项目自定义分区聚合成一个普通字典。它可以导出 JSON、写入本地文件，也可以通过项目传入的 `Callable` 提交给任意自有流程；GF 不内置上传地址、工单系统或玩家反馈 UI。

```gdscript
var reports := Gf.get_utility(GFSupportReportUtility) as GFSupportReportUtility
reports.register_section(&"save_slot", func(_options: Dictionary) -> Dictionary:
	return {
		"slot_id": current_slot_id,
		"checkpoint": current_checkpoint_id,
	}
)

var report := reports.build_report("设置界面打开后无法返回", {
	"metadata": {
		"screen": "settings",
	},
	"tags": ["ui", "runtime"],
	"include_diagnostics": true,
	"scene_options": {
		"max_depth": 64,
		"max_nodes": 10000,
	},
	"attachments": {
		"local_log": {
			"text": recent_log_text,
			"filename": "recent_log.txt",
			"mime_type": "text/plain",
		},
	},
	"max_attachment_bytes": 512 * 1024,
})
reports.save_report(report, "user://support/report_latest.json")
var markdown_summary := reports.export_report_markdown(report, {
	"title": "Support Report",
})
```

场景快照只记录当前场景名称、路径和节点数量，节点数量统计默认限制深度与节点数；被截断时 `scene.node_count_truncated` 为 `true`。附件可通过 `attachments` 传入文本、字节或带 `text` / `bytes` / `path` 字段的字典，`collect_attachments()` 与 `add_attachment_to_report()` 会统一写出 `ok`、`filename`、`mime_type`、`size_bytes`、`encoding`、`data` 和 `metadata`。`include_screenshot` 可把当前 Viewport 截图作为普通附件加入报告，`screenshot_path` 可额外把截图写到本地路径；默认 `default_max_attachment_bytes` 会限制单个附件大小，避免支持报告在玩家入口无限膨胀。`export_report_json()` 适合自动化传输和持久化；`export_report_markdown()` 适合把同一份报告摘要贴进 Issue、PR、客服工单或测试记录，它只输出附件摘要，不内联附件正文或二进制内容。

如果需要上传或进入项目自己的客服/反馈管线，使用 `submit_report(report, transport, options)`。`transport` 会收到报告字典副本和提交选项；它可以写文件、排队、发 HTTP 请求或交给平台 SDK，但这些实现都留在项目层。提交返回值会归一化为 `ok`、`value`、`error`、`metadata` 和 `submitted_at_unix`，便于 UI 或日志统一处理。面对玩家可见入口时，应在项目层过滤敏感字段、限制附件大小，并决定是否允许 `include_screenshot`。

### 通用通知队列 (`GFNotificationUtility`)

`GFNotificationUtility` 提供通知数据队列、去重、时长推进和生命周期信号，不内置 Toast/HUD 样式。项目可以监听 `notification_started` 渲染自己的 UI，也可以把它接到日志、编辑器面板或测试流程：

```gdscript
var notifications := Gf.get_utility(GFNotificationUtility) as GFNotificationUtility
notifications.notification_started.connect(func(notification: Dictionary) -> void:
	show_toast(notification["title"], notification["message"])
)

notifications.push_notification("配置已保存", "设置", GFNotificationUtility.Level.SUCCESS)
```

`push_notification()` 可通过 `options` 设置 `duration_seconds`、去重 `key`、项目自定义 `metadata`、`priority`、`sticky` 和 `actions`；返回值是通知 ID，被重复抑制时会返回已有通知 ID。显式传入 `key` 时只按 key 去重；没有 key 时才按消息文本去重，因此不同业务上下文可以显示相同正文。`max_queue_size = 0` 表示只保留当前通知，不保留等待队列；等待队列会按优先级排序，容量不足时优先丢弃低优先级通知。`sticky = true` 的通知不会因时长自动结束，适合需要玩家确认或等待外部事件的提示。

`pause_active()` / `resume_active()` 可暂停当前通知的时长推进，`invoke_active_action(action_id)` 会广播 `notification_action_invoked`，并在 action 配置 `dismiss = true` 时关闭当前通知。通知系统只维护数据、优先级、暂停和动作意图；按钮样式、焦点、快捷键、Toast 动画和多端适配仍由项目 UI 层决定。


## 运行时开发者控制台 (`GFConsoleUtility`)

**应用场景：** 当你需要在运行中的游戏里快速执行调试指令、查看实时日志输出，而不想来回切换编辑器或依赖外部终端时。

按下 **F1**（可配置）即可呼出半透明控制台，默认保持全屏覆盖；也可以启用窗口模式，让控制台以可拖拽、可缩放面板呈现。控制台内置 `help`（列出所有指令）、`clear`（清空输出）、`scene.tree`（只读场景树摘要）和 `scene.node`（只读节点摘要）。支持自定义指令注册，同时自动接收 `GFLogUtility` 的日志信号并着色显示（Error/Fatal 红色、Warn 黄色、Debug 青色）。

控制台默认 `debug_only = true`，发布构建不会创建 GUI；如果项目确实需要在非 debug 构建中使用，必须显式关闭该选项，并自行确认命令白名单、输入入口和玩家可见性。控制台内部会批量刷新输出，并通过 `max_output_lines` 限制保留行数、通过 `max_history_size` 限制历史命令数量，避免高频日志或长时间运行造成无限增长。日志 tag、message、命令回显和帮助文本会在写入 RichTextLabel 前转义 BBCode，避免日志内容污染控制台 UI。界面内置日志标签过滤输入框，支持 `Tab` 补全命令、上下方向键切换输入历史；未知命令也可通过 `suggest_similar_commands()` 给出相似候选，便于调试控制台在输入错误时提示可用命令。

项目也可以用 `GFConsoleCommandDefinition` 资源化命令名、别名、描述和元数据，再通过 `register_command_definition()` 绑定执行回调。控制台命令回调只接收 `PackedStringArray` 参数；参数解析支持引号和反斜杠转义，例如 `give_item "red potion" 3` 会把 `"red potion"` 作为一个参数。命令元数据可设置 `tier` 为 `GFConsoleUtility.CommandTier`，控制台会用 `max_command_tier` 拦截超出等级的命令；`DANGER` 命令默认还需要传入 `--confirm`，确认参数不会转交业务回调。需要认证 token、远程调试入口或更完整的审计记录时，仍建议把命令注册到 `GFDiagnosticsUtility`，再由控制台或其他调试 UI 调用诊断命令。

**如何使用：**
```gdscript
var console := Gf.get_utility(GFConsoleUtility) as GFConsoleUtility

# 注册自定义指令 —— 回调签名: func(args: PackedStringArray) -> void
console.register_command("tp", Callable(self, "_console_tp"), "传送玩家到指定坐标。用法: tp <x> <y>")

var definition := GFConsoleCommandDefinition.new()
definition.command_name = "reload"
definition.aliases = PackedStringArray(["rl"])
definition.description = "重新加载当前调试数据。"
console.register_command_definition(definition, func(_args: PackedStringArray) -> void:
	reload_debug_data()
)

# 注销指令
console.unregister_command("tp")

# 也可以在代码中直接执行指令
console.execute_command("help")
console.execute_command("scene.tree 3 80")
console.execute_command("scene.node Player")

# 可选：更换呼出快捷键（默认 F1）
console.toggle_key = KEY_F2

# 可选：限制控制台输出行数（默认 1000）
console.max_output_lines = 500
console.max_history_size = 100

# 可选：危险命令需要元数据标记和显式确认
console.max_command_tier = GFConsoleUtility.CommandTier.DANGER
console.register_command("wipe_save", Callable(self, "_wipe_save"), "删除测试存档。", {
	"tier": GFConsoleUtility.CommandTier.DANGER,
})
console.execute_command("wipe_save --confirm")

# 可选：窗口模式与显示配置
console.windowed = true
console.background_alpha = 0.8
console.initial_window_size_ratio = Vector2(0.7, 0.55)
console.minimum_window_size = Vector2(420, 260)
console.keep_topmost = true
console.debug_only = true
```

`windowed = false` 是兼容默认值，适合只在需要时全屏覆盖查看日志。`windowed = true` 更适合边运行边观察状态或执行调试命令；拖拽区域位于标题文本，右下角手柄用于缩放。`debug_only = true` 会在非 debug 构建中跳过 GUI 创建，适合把控制台注册代码留在通用启动流程里，但仍由项目发布策略决定是否注册调试命令。控制台 GUI 在 `dispose()` 时会立即脱离场景树，并断开日志信号，避免关闭架构后同一帧仍留下调试输入层。
