## 测试 GFDiagnosticsUtility 的快照与命令调度。
extends GutTest


## 验证诊断命令注册后可统一执行。
func test_diagnostics_command_executes() -> void:
	var diagnostics := GFDiagnosticsUtility.new()
	diagnostics.init()

	var result := diagnostics.execute_command(&"diagnostics.performance")

	assert_true(bool(result["ok"]), "内置性能诊断命令应执行成功。")
	assert_true((result["value"] as Dictionary).has("fps"), "性能快照应包含 fps。")
	assert_true(diagnostics.has_command(&"diagnostics.scene"), "Diagnostics 应注册只读场景树快照命令。")
	assert_true(diagnostics.has_command(&"diagnostics.signals"), "Diagnostics 应注册只读信号图快照命令。")


## 验证场景树快照只采集结构摘要并遵守深度限制。
func test_diagnostics_collects_read_only_scene_tree_snapshot() -> void:
	var root := Node.new()
	root.name = "Root"
	var child := Node.new()
	child.name = "Child"
	var grandchild := Node.new()
	grandchild.name = "Grandchild"
	root.add_child(child)
	child.add_child(grandchild)
	add_child_autofree(root)

	var diagnostics := GFDiagnosticsUtility.new()
	var snapshot := diagnostics.collect_scene_tree_snapshot(root, {
		"max_depth": 1,
		"max_nodes": 8,
		"include_groups": true,
	})
	var root_data := snapshot["root"] as Dictionary
	var children := root_data["children"] as Array
	var child_data := children[0] as Dictionary

	assert_true(bool(snapshot["available"]), "传入根节点时场景树快照应可用。")
	assert_eq(String(root_data["name"]), "Root", "快照应记录节点名称。")
	assert_eq(String(child_data["name"]), "Child", "快照应记录直接子节点。")
	assert_true(bool(child_data.get("depth_limit_reached", false)), "超过深度的子树应只标记截断，不继续展开。")
	assert_true(bool(snapshot["truncated"]), "达到深度限制时顶层快照应标记截断。")


## 验证诊断命令等级默认只允许观察类命令。
func test_diagnostics_command_tier_denies_control_by_default() -> void:
	var diagnostics := GFDiagnosticsUtility.new()
	diagnostics.register_command(
		&"runtime.pause",
		func(_args: Dictionary) -> Dictionary:
			return { "paused": true },
		"暂停运行时。",
		GFDiagnosticsUtility.CommandTier.CONTROL
	)

	var result := diagnostics.execute_command(&"runtime.pause")

	assert_false(bool(result["ok"]), "默认等级不应允许 CONTROL 命令。")
	assert_eq((result["metadata"] as Dictionary).get("tier_name"), "control", "失败结果应包含命令等级。")


## 验证诊断命令可要求 token 认证。
func test_diagnostics_command_requires_auth_token() -> void:
	var diagnostics := GFDiagnosticsUtility.new()
	diagnostics.set_auth_token("secret")
	diagnostics.register_command(&"diagnostics.test", func(_args: Dictionary) -> String:
		return "ok"
	)

	var rejected := diagnostics.execute_command(&"diagnostics.test")
	var accepted := diagnostics.execute_command(&"diagnostics.test", { "auth_token": "secret" })

	assert_false(bool(rejected["ok"]), "缺少 token 时命令应被拒绝。")
	assert_true(bool(accepted["ok"]), "提供正确 token 时命令应执行。")


func test_diagnostics_command_schema_validates_arguments_and_defaults() -> void:
	var diagnostics := GFDiagnosticsUtility.new()
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
					"required": true,
					"default": 3,
					"min": 1,
					"max": 5,
				},
			],
		}
	)

	var defaulted := diagnostics.execute_command(&"runtime.limit")
	var rejected := diagnostics.execute_command(&"runtime.limit", { "limit": 8 })

	assert_true(bool(defaulted["ok"]), "带默认值的必填参数缺省时应使用默认值。")
	assert_eq(((defaulted["value"] as Dictionary)["limit"]), 3, "命令回调应收到填充默认值后的参数。")
	assert_false(bool(rejected["ok"]), "超出 schema 范围的参数应被拒绝。")
	assert_true(String(rejected["error"]).contains("error"), "参数校验失败应返回校验摘要。")


func test_diagnostics_command_can_be_disabled_and_exported_json_safe() -> void:
	var diagnostics := GFDiagnosticsUtility.new()
	diagnostics.register_command(&"runtime.vector", func(_args: Dictionary) -> Dictionary:
		return { "position": Vector3(1.0, 2.0, 3.0) }
	)

	var disabled_ok := diagnostics.set_command_enabled(&"runtime.vector", false)
	var disabled := diagnostics.execute_command(&"runtime.vector")
	diagnostics.set_command_enabled(&"runtime.vector", true)
	var json_safe := diagnostics.execute_command_json_safe(&"runtime.vector")
	var value := json_safe["value"] as Dictionary
	var position := value["position"] as Dictionary

	assert_true(disabled_ok, "已注册命令应可被禁用。")
	assert_false(bool(disabled["ok"]), "禁用命令不应执行回调。")
	assert_true(position.has(GFVariantJsonCodec.JSON_MARKER_KEY), "JSON-safe 命令结果应编码 Godot Variant。")


## 验证诊断快照可读取架构生命周期状态。
func test_diagnostics_collects_architecture_snapshot() -> void:
	var arch := GFArchitecture.new()
	var diagnostics := GFDiagnosticsUtility.new()
	await arch.register_utility_instance(diagnostics)
	await arch.init()

	var snapshot := diagnostics.collect_snapshot({
		"include_recent_logs": false,
	})
	var architecture := snapshot["architecture"] as Dictionary

	assert_true(architecture.has("utilities"), "架构快照应包含 Utility 状态。")

	arch.dispose()


## 验证诊断快照会聚合已注册工具的 get_debug_snapshot。
func test_diagnostics_collects_tool_debug_snapshots() -> void:
	var arch := GFArchitecture.new()
	var diagnostics := GFDiagnosticsUtility.new()
	var timer := GFTimerUtility.new()
	var download := GFDownloadUtility.new()
	var action_queue := GFActionQueueSystem.new()
	await arch.register_utility_instance(timer)
	await arch.register_utility_instance(download)
	await arch.register_utility_instance(diagnostics)
	await arch.register_system_instance(action_queue)
	await arch.init()

	timer.execute_after(1.0, func() -> void:
		pass
	)
	var snapshot := diagnostics.collect_snapshot({
		"include_recent_logs": false,
	})
	var tools := snapshot["tools"] as Dictionary
	var timer_snapshot := tools[&"timer"] as Dictionary

	assert_true(tools.has(&"timer"), "工具快照应包含 TimerUtility。")
	assert_true(tools.has(&"download"), "工具快照应包含 DownloadUtility。")
	assert_true(tools.has(&"action_queue"), "工具快照应包含 ActionQueueSystem。")
	assert_eq(int(timer_snapshot["pending_count"]), 1, "Timer 快照应保留工具自身诊断数据。")

	arch.dispose()


## 验证诊断快照会使用已注册的构建信息工具。
func test_diagnostics_collects_build_info_snapshot() -> void:
	var arch := GFArchitecture.new()
	var diagnostics := GFDiagnosticsUtility.new()
	var build_info_utility := GFBuildInfoUtility.new()
	await arch.register_utility_instance(build_info_utility)
	await arch.register_utility_instance(diagnostics)
	await arch.init()
	var build_info := GFBuildInfo.new()
	build_info.project_name = "GF Test"
	build_info.build_id = "diagnostics-build"
	build_info_utility.set_build_info(build_info)

	var snapshot := diagnostics.collect_snapshot({
		"include_recent_logs": false,
	})
	var build := snapshot["build"] as Dictionary
	var tools := snapshot["tools"] as Dictionary

	assert_eq(build["build_id"], "diagnostics-build", "诊断快照应使用 BuildInfoUtility 的稳定副本。")
	assert_true(tools.has(&"build_info"), "工具快照应包含 BuildInfoUtility。")

	arch.dispose()


## 验证诊断监控注册表可采样、预设和导出。
func test_diagnostics_monitor_registry_collects_custom_monitor() -> void:
	var diagnostics := GFDiagnosticsUtility.new()
	diagnostics.init()
	var provider := func() -> int:
		return 7

	assert_true(diagnostics.register_monitor(&"test.value", provider, {
		"label": "Value",
		"group": "Tests",
	}), "有效监控项应注册成功。")
	assert_true(diagnostics.register_monitor_preset(&"test", PackedStringArray(["test.value"])), "监控预设应注册成功。")

	var snapshot := diagnostics.collect_monitor_snapshot(PackedStringArray(["test.value"]))
	var monitors := snapshot["monitors"] as Dictionary
	var sample := monitors[&"test.value"] as Dictionary
	var preset_snapshot := diagnostics.collect_monitor_preset(&"test")
	var exported_text := diagnostics.export_monitor_snapshot(preset_snapshot, &"text")

	assert_eq(sample["value"], 7, "监控快照应包含 provider 返回值。")
	assert_eq(preset_snapshot["preset_id"], &"test", "预设快照应记录预设 id。")
	assert_true("Value" in exported_text, "文本导出应包含监控标签。")


func test_diagnostics_collects_external_snapshot_providers() -> void:
	var diagnostics := GFDiagnosticsUtility.new()
	diagnostics.init()

	assert_true(diagnostics.register_snapshot_section_provider(&"runtime", func() -> Dictionary:
		return { "enemy_count": 3 }
	), "外部快照分区 provider 应注册成功。")
	assert_true(diagnostics.register_tool_snapshot_provider(&"runtime_tool", func() -> Dictionary:
		return { "pending": 2 }
	), "外部工具快照 provider 应注册成功。")
	diagnostics.register_monitor(&"runtime.pending", func() -> int:
		return 2
	)
	assert_true(diagnostics.add_monitor_to_preset(&"tools", &"runtime.pending"), "外部监控项应可加入内置 tools 预设。")

	var snapshot := diagnostics.collect_snapshot({
		"include_recent_logs": false,
	})
	var runtime := snapshot["runtime"] as Dictionary
	var tools := snapshot["tools"] as Dictionary
	var tool_monitors := diagnostics.collect_monitor_preset(&"tools")["monitors"] as Dictionary

	assert_eq(int(runtime.get("enemy_count", 0)), 3, "外部快照分区应进入 collect_snapshot 顶层字段。")
	assert_eq(int((tools[&"runtime_tool"] as Dictionary).get("pending", 0)), 2, "外部工具快照应进入 tools 字段。")
	assert_true(tool_monitors.has(&"runtime.pending"), "追加到 tools 预设的外部监控项应可采样。")


## 验证内置工具监控预设可采样。
func test_diagnostics_builtin_tools_monitor_preset() -> void:
	var arch := GFArchitecture.new()
	var diagnostics := GFDiagnosticsUtility.new()
	var timer := GFTimerUtility.new()
	await arch.register_utility_instance(timer)
	await arch.register_utility_instance(diagnostics)
	await arch.init()

	var snapshot := diagnostics.collect_monitor_preset(&"tools")
	var monitors := snapshot["monitors"] as Dictionary

	assert_true(diagnostics.has_monitor_preset(&"tools"), "Diagnostics 应注册 tools 监控预设。")
	assert_true(monitors.has(&"tools.timer"), "tools 预设应包含 Timer 监控项。")

	arch.dispose()


func test_diagnostics_collects_signal_graph_snapshot() -> void:
	var root := Node.new()
	root.name = "Root"
	var emitter := SignalEmitter.new()
	emitter.name = "Emitter"
	root.add_child(emitter)
	emitter.ping.connect(func() -> void:
		pass
	)
	add_child_autofree(root)

	var diagnostics := GFDiagnosticsUtility.new()
	var graph := diagnostics.collect_signal_graph_snapshot(root, { "include_index": true })
	var index := graph["index"] as Dictionary
	var ping_connection_count := 0
	for connection_variant: Variant in graph.get("connections", []):
		var connection := connection_variant as Dictionary
		if connection == null:
			continue
		if (
			String(connection.get("source_node_path", "")) == "Emitter"
			and String(connection.get("signal_name", "")) == "ping"
		):
			ping_connection_count += 1

	assert_true(bool(graph["ok"]), "传入根节点时信号图应可用。")
	assert_eq(ping_connection_count, 1, "运行时连接应进入信号图。")
	assert_true(index.has("outgoing"), "include_index 应附加按节点索引。")


# --- 内部类 ---

class SignalEmitter:
	extends Node

	signal ping
