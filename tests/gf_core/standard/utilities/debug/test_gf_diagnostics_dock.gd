extends GutTest


# --- 测试方法 ---

func test_diagnostics_dock_collects_runtime_snapshot() -> void:
	var dock: GFDiagnosticsDock = GFDiagnosticsDock.new()

	dock.collect_snapshot()
	var snapshot: Dictionary = dock.get_last_snapshot()
	var dock_snapshot: Dictionary = dock.get_debug_snapshot()
	var monitors: Dictionary = GFVariantData.as_dictionary(
		GFVariantData.get_option_value(snapshot, "monitors")
	)

	assert_false(snapshot.is_empty(), "Diagnostics 页面应能采集快照。")
	assert_true(snapshot.has("performance"), "诊断快照应包含性能分区。")
	assert_true(snapshot.has("monitors"), "诊断快照应包含监控分区。")
	assert_gt(GFVariantData.get_option_int(monitors, "monitor_count"), 0, "诊断快照应采集内置监控项。")
	assert_false(GFVariantData.get_option_string(dock_snapshot, "details_text").is_empty(), "Diagnostics 页面右侧应默认展示快照内容。")

	dock.free()
