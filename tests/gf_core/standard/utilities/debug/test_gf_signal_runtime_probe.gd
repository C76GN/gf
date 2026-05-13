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


func test_signal_graph_dock_keeps_empty_runtime_page_compact() -> void:
	var dock: Variant = GF_SIGNAL_GRAPH_DOCK.new()
	dock._build_ui()
	dock._render_events()
	var root_box := dock.get_child(0) as Control

	assert_eq(dock.custom_minimum_size, Vector2.ZERO, "Signal Graph 不应设置自定义最小高度。")
	assert_eq(root_box.anchor_right, 1.0, "Signal Graph 内容应横向铺满父容器。")
	assert_eq(root_box.anchor_bottom, 1.0, "Signal Graph 内容应纵向跟随父容器。")
	assert_true(dock._event_empty_state_label.visible, "没有运行事件时应显示紧凑空态说明。")
	assert_false(dock._event_tree.visible, "没有运行事件时不应显示只有表头的空表格。")

	dock.free()


# --- 内部类 ---

class SignalSource extends Node:
	signal no_args
	signal value_changed(value)
	signal pair_changed(left, right)
