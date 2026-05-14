extends GutTest


# --- 常量 ---

const GF_INPUT_MAPPING_DOCK := preload("res://addons/gf/standard/input/editor/gf_input_mapping_dock.gd")


# --- 测试方法 ---

func test_input_mapping_dock_uses_compact_empty_state() -> void:
	var dock: Variant = GF_INPUT_MAPPING_DOCK.new()

	dock.refresh()

	assert_true(dock._empty_label.visible, "未加载上下文时应显示空状态。")
	assert_false(dock._content_split.visible, "未加载上下文时不应留下空表格和详情面板。")
	assert_ne(dock._summary_label.text, dock._empty_label.text, "空状态顶部摘要和正文提示不应重复。")

	dock.free()


func test_input_mapping_dock_reports_context_bindings() -> void:
	var dock: Variant = GF_INPUT_MAPPING_DOCK.new()
	var context := _make_context(false)

	dock.set_input_context(context)
	var report: Dictionary = dock.get_last_report()

	assert_eq(int(report.get("mapping_count", 0)), 1, "Input 页面应统计上下文映射数量。")
	assert_eq(int(report.get("binding_count", 0)), 1, "Input 页面应统计绑定数量。")
	assert_eq(int(report.get("conflict_count", 0)), 0, "单个绑定不应产生冲突。")
	assert_true(bool(report.get("ok", false)), "结构健康的输入上下文应报告 ok。")

	dock.free()


func test_input_mapping_dock_reports_binding_conflicts() -> void:
	var dock: Variant = GF_INPUT_MAPPING_DOCK.new()
	var context := _make_context(true)

	dock.set_input_context(context)
	var report: Dictionary = dock.get_last_report()

	assert_eq(int(report.get("conflict_count", 0)), 1, "相同输入绑定到两个动作时应报告冲突。")
	assert_eq(int(report.get("warning_count", 0)), 1, "绑定冲突应作为 warning 进入统一问题列表。")
	assert_false(bool(report.get("ok", true)), "存在冲突时输入上下文报告不应为 ok。")

	dock.free()


# --- 私有/辅助方法 ---

func _make_context(with_conflict: bool) -> GFInputContext:
	var context := GFInputContext.new()
	context.context_id = &"gameplay"
	context.display_name = "Gameplay"
	context.mappings = [_make_mapping(&"jump")]
	if with_conflict:
		context.mappings.append(_make_mapping(&"confirm"))
	return context


func _make_mapping(action_id: StringName) -> GFInputMapping:
	var action := GFInputAction.new()
	action.action_id = action_id
	action.display_name = String(action_id).capitalize()

	var event := InputEventKey.new()
	event.keycode = KEY_SPACE
	event.physical_keycode = KEY_SPACE

	var binding := GFInputBinding.new()
	binding.input_event = event

	var mapping := GFInputMapping.new()
	mapping.action = action
	mapping.bindings = [binding]
	return mapping
