## 测试 GFSignalRuntimeProbe 的运行时信号追踪能力。
extends GutTest


# --- 常量 ---

const GFSignalRuntimeProbeBase = preload("res://addons/gf/standard/utilities/debug/gf_signal_runtime_probe.gd")
const GF_SIGNAL_GRAPH_DOCK := preload("res://addons/gf/standard/utilities/debug/editor/gf_signal_graph_dock.gd")


# --- 测试 ---

func test_probe_records_watched_signal_emissions() -> void:
	var source := SignalSource.new()
	source.name = "Source"
	var probe: GFSignalRuntimeProbeBase = GFSignalRuntimeProbeBase.new()

	var report := probe.watch_node(source, {
		"include_signals": [&"no_args", &"value_changed", &"pair_changed"],
	})
	source.no_args.emit()
	source.value_changed.emit(42)
	source.pair_changed.emit("left", true)

	var events := probe.get_events()

	assert_true(bool(report["ok"]), "监听指定信号应成功。")
	assert_eq(int(report["watched_count"]), 3, "应监听三个指定信号。")
	assert_eq(events.size(), 3, "三次发射都应被记录。")
	assert_eq(String(events[0]["signal_name"]), "no_args", "零参数信号应被记录。")
	assert_eq((events[1]["arguments"] as Array)[0], 42, "单参数信号应记录参数。")
	assert_eq((events[2]["arguments"] as Array)[1], true, "多参数信号应记录全部参数。")

	probe.unwatch_all()
	source.free()


func test_probe_records_wide_signal_payload() -> void:
	var source := SignalSource.new()
	var probe: GFSignalRuntimeProbeBase = GFSignalRuntimeProbeBase.new()

	var report := probe.watch_node(source, {
		"include_signals": [&"wide_payload"],
	})
	source.wide_payload.emit(0, 1, 2, 3, 4, 5, 6, 7, 8)

	var events := probe.get_events()
	var arguments := events[0]["arguments"] as Array

	assert_true(bool(report["ok"]), "9 参数信号应能被运行时探针监听。")
	assert_eq(events.size(), 1, "9 参数信号发射应被记录。")
	assert_eq(arguments.size(), 9, "运行时探针应保留 9 参数 payload。")
	assert_eq(arguments[8], 8, "运行时探针应保留第 9 个参数。")

	probe.unwatch_all()
	source.free()


func test_probe_respects_event_limit_and_unwatch() -> void:
	var source := SignalSource.new()
	var probe: GFSignalRuntimeProbeBase = GFSignalRuntimeProbeBase.new()
	probe.max_events = 1
	probe.watch_node(source, {
		"include_signals": [&"value_changed"],
	})

	source.value_changed.emit(1)
	source.value_changed.emit(2)
	assert_eq(probe.get_events().size(), 1, "事件数量应受 max_events 限制。")

	assert_eq(probe.unwatch_node(source), 1, "unwatch_node 应断开已监听信号。")
	source.value_changed.emit(3)
	assert_eq(probe.get_events().size(), 1, "断开后不应继续记录。")

	source.free()


func test_watch_tree_reports_node_limit() -> void:
	var root := Node.new()
	var first_child := SignalSource.new()
	var second_child := SignalSource.new()
	root.add_child(first_child)
	root.add_child(second_child)
	var probe: GFSignalRuntimeProbeBase = GFSignalRuntimeProbeBase.new()

	var report := probe.watch_tree(root, {
		"include_signals": [&"value_changed"],
		"max_nodes": 1,
	})

	assert_false(bool(report["ok"]), "节点树监听被截断时报告应标记失败。")
	assert_true((report["errors"] as Array).has("max_nodes_reached:1"), "报告应包含 max_nodes 截断原因。")
	assert_eq(probe.get_watch_count(), 0, "达到节点上限时只收集根节点，根节点无业务信号不应产生监听。")

	probe.unwatch_all()
	root.free()


func test_signal_graph_dock_keeps_empty_runtime_page_compact() -> void:
	var dock: Variant = GF_SIGNAL_GRAPH_DOCK.new()
	var snapshot: Dictionary = dock.get_debug_snapshot()
	var ui := snapshot["ui"] as Dictionary

	assert_eq(dock.custom_minimum_size, Vector2.ZERO, "Signal Diagnostics 不应设置自定义最小高度。")
	assert_eq(float(ui["root_anchor_right"]), 1.0, "Signal Diagnostics 内容应横向铺满父容器。")
	assert_eq(float(ui["root_anchor_bottom"]), 1.0, "Signal Diagnostics 内容应纵向跟随父容器。")
	assert_true(bool(ui["event_empty_visible"]), "没有发射记录时应显示紧凑空态说明。")
	assert_false(bool(ui["event_tree_visible"]), "没有发射记录时不应显示只有表头的空表格。")
	assert_eq(String(ui["persistent_only_text"]), "保存连接", "连接过滤选项应使用面向用户的直观命名。")
	assert_eq(String(ui["include_empty_text"]), "未连接信号", "信号过滤选项应说明它显示未连接的信号。")
	assert_eq(String(ui["live_text"]), "追踪发射", "发射记录开关应说明它记录信号发射。")
	assert_true(
		String(ui["event_empty_text"]).contains("追踪发射"),
		"发射记录空态应说明如何开始记录信号发射。"
	)

	dock.free()


func test_signal_graph_dock_tracks_saved_connection_signals_without_unconnected_noise() -> void:
	var source := SignalSource.new()
	source.name = "Source"
	add_child(source)
	source.no_args.connect(source._on_no_args, CONNECT_PERSIST)
	var dock: Variant = GF_SIGNAL_GRAPH_DOCK.new()
	add_child(dock)
	dock.set_graph_source(source)

	dock.set_live_tracking_enabled(true)
	source.value_changed.emit(7)
	source.no_args.emit()

	var events: Array[Dictionary] = dock.get_recent_events()

	assert_eq(events.size(), 1, "追踪发射默认应只记录保存连接中的信号，避免 draw 等未连接噪音。")
	assert_eq(String(events[0]["signal_name"]), "no_args", "保存连接里的信号应被记录。")

	dock.queue_free()
	source.queue_free()
	await get_tree().process_frame


# --- 内部类 ---

class SignalSource extends Node:
	signal no_args
	signal value_changed(value)
	signal pair_changed(left, right)
	signal wide_payload(a, b, c, d, e, f, g, h, i)

	func _on_no_args() -> void:
		pass
