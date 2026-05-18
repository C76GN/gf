extends GutTest


# --- 常量 ---

const GF_SAVE_GRAPH_DOCK := preload("res://addons/gf/extensions/save/editor/gf_save_graph_dock.gd")


# --- 辅助类 ---

class MethodTrapSaveScope extends GFSaveScope:
	var get_scope_key_called: bool = false
	var can_save_scope_called: bool = false
	var can_load_scope_called: bool = false
	var describe_scope_called: bool = false

	func get_scope_key() -> StringName:
		get_scope_key_called = true
		return &"method_scope"

	func can_save_scope(_context: Dictionary = {}) -> bool:
		can_save_scope_called = true
		return false

	func can_load_scope(_context: Dictionary = {}) -> bool:
		can_load_scope_called = true
		return false

	func describe_scope() -> Dictionary:
		describe_scope_called = true
		return { "scope_key": &"method_scope" }


# --- 测试方法 ---

func test_save_graph_dock_uses_compact_empty_state() -> void:
	var dock: Variant = GF_SAVE_GRAPH_DOCK.new()
	var root := Node.new()

	dock.set_save_graph_source(root)

	assert_true(dock._empty_label.visible, "没有 GFSaveScope 时应显示空状态。")
	assert_false(dock._content_split.visible, "没有 GFSaveScope 时不应留下空表格和详情面板。")
	assert_ne(dock._summary_label.text, dock._empty_label.text, "空状态标题和说明不应重复。")

	dock.free()
	root.free()


func test_save_graph_dock_refresh_does_not_call_scope_methods() -> void:
	var dock: Variant = GF_SAVE_GRAPH_DOCK.new()
	var root := Node.new()
	var scope := MethodTrapSaveScope.new()
	scope.name = "TrapScope"
	scope.scope_key = &"export_scope"
	root.add_child(scope)

	dock.set_save_graph_source(root)
	var report: Dictionary = dock.get_last_scope_report()

	assert_eq(String(report.get("scope_key", "")), "export_scope", "Save 页面应读取导出的 scope_key。")
	assert_false(scope.get_scope_key_called, "刷新 Save 页面不应调用 Scope 方法，避免 placeholder 报错。")
	assert_false(scope.can_save_scope_called, "刷新 Save 页面不应调用 Scope 保存判断方法。")
	assert_false(scope.can_load_scope_called, "刷新 Save 页面不应调用 Scope 加载判断方法。")
	assert_false(scope.describe_scope_called, "刷新 Save 页面不应调用 Scope 描述方法。")

	dock.free()
	root.free()


func test_save_graph_dock_reports_scope_structure_and_preview_payload() -> void:
	var dock: Variant = GF_SAVE_GRAPH_DOCK.new()
	var root := Node.new()
	var scope := GFSaveScope.new()
	var source := GFSaveSource.new()
	scope.name = "SaveScope"
	scope.scope_key = &"root"
	source.name = "StateSource"
	source.source_key = &"state"
	scope.add_child(source)
	root.add_child(scope)

	dock.set_save_graph_source(root)
	var report: Dictionary = dock.get_last_scope_report()

	assert_eq(int(report.get("scope_count", 0)), 1, "Save 页面应统计 Scope 数量。")
	assert_eq(int(report.get("source_count", 0)), 1, "Save 页面应统计 Source 数量。")
	assert_true(bool(report.get("ok", false)), "结构健康的 SaveGraph 应报告 ok。")

	dock._on_preview_payload_pressed()
	var payload: Dictionary = dock.get_last_payload()

	assert_eq(String(payload.get("format", "")), GFSaveGraphUtility.FORMAT_ID, "Save 页面应能采集预览 payload。")
	assert_true((payload.get("sources", {}) as Dictionary).has("state"), "预览 payload 应包含 Source 数据入口。")

	dock.free()
	root.free()
