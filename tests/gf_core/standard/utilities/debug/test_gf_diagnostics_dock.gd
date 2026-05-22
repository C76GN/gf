extends GutTest


# --- 常量 ---

const GF_DIAGNOSTICS_DOCK := preload("res://addons/gf/standard/utilities/debug/editor/gf_diagnostics_dock.gd")


# --- 测试方法 ---

func test_diagnostics_dock_collects_runtime_snapshot() -> void:
	var dock: Variant = GF_DIAGNOSTICS_DOCK.new()

	dock.collect_snapshot()
	var snapshot: Dictionary = dock.get_last_snapshot()
	var dock_snapshot: Dictionary = dock.get_debug_snapshot()

	assert_false(snapshot.is_empty(), "Diagnostics 页面应能采集快照。")
	assert_true(snapshot.has("performance"), "诊断快照应包含性能分区。")
	assert_true(snapshot.has("monitors"), "诊断快照应包含监控分区。")
	assert_gt(int((snapshot.get("monitors", {}) as Dictionary).get("monitor_count", 0)), 0, "诊断快照应采集内置监控项。")
	assert_false(String(dock_snapshot.get("details_text", "")).is_empty(), "Diagnostics 页面右侧应默认展示快照内容。")

	dock.free()
