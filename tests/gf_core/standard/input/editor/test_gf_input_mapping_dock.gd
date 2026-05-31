extends GutTest


# --- 测试方法 ---

func test_input_mapping_dock_uses_compact_empty_state() -> void:
	var dock: GFInputMappingDock = GFInputMappingDock.new()

	dock.refresh()

	assert_true(dock._empty_label.visible, "未加载上下文时应显示空状态。")
	assert_false(dock._content_split.visible, "未加载上下文时不应留下空表格和详情面板。")
	assert_ne(dock._summary_label.text, dock._empty_label.text, "空状态顶部摘要和正文提示不应重复。")

	dock.free()


func test_input_mapping_dock_reports_context_bindings() -> void:
	var dock: GFInputMappingDock = GFInputMappingDock.new()
	var context: GFInputContext = _make_context(false)

	dock.set_input_context(context)
	var report: Dictionary = dock.get_last_report()

	assert_eq(GFVariantData.get_option_int(report, "mapping_count"), 1, "Input 页面应统计上下文映射数量。")
	assert_eq(GFVariantData.get_option_int(report, "binding_count"), 1, "Input 页面应统计绑定数量。")
	assert_eq(GFVariantData.get_option_int(report, "conflict_count"), 0, "单个绑定不应产生冲突。")
	assert_true(GFVariantData.get_option_bool(report, "ok"), "结构健康的输入上下文应报告 ok。")
	assert_true(GFVariantData.get_option_bool(report, "healthy"), "没有 warning 或 error 时应报告 healthy。")

	dock.free()


func test_input_mapping_dock_reports_binding_conflicts() -> void:
	var dock: GFInputMappingDock = GFInputMappingDock.new()
	var context: GFInputContext = _make_context(true)

	dock.set_input_context(context)
	var report: Dictionary = dock.get_last_report()
	var issues: Array = GFVariantData.as_array(GFVariantData.get_option_value(report, "issues"))
	var issue: Dictionary = GFVariantData.as_dictionary(issues[0])

	assert_eq(GFVariantData.get_option_int(report, "conflict_count"), 1, "相同输入绑定到两个动作时应报告冲突。")
	assert_eq(GFVariantData.get_option_int(report, "warning_count"), 1, "绑定冲突应作为 warning 进入统一问题列表。")
	assert_eq(GFVariantData.get_option_int(report, "issue_count"), 1, "Input 页面报告应统计问题总数。")
	assert_true(GFVariantData.get_option_bool(report, "ok"), "只有 warning 时标准校验报告仍应 ok。")
	assert_false(GFVariantData.get_option_bool(report, "healthy", true), "存在冲突 warning 时不应报告 healthy。")
	assert_eq(GFVariantData.get_option_string(issue, "kind"), "binding_conflict")

	dock.free()


# --- 私有/辅助方法 ---

func _make_context(with_conflict: bool) -> GFInputContext:
	var context: GFInputContext = GFInputContext.new()
	context.context_id = &"gameplay"
	context.display_name = "Gameplay"
	var mappings: Array[GFInputMapping] = [_make_mapping(&"jump")]
	if with_conflict:
		mappings.append(_make_mapping(&"confirm"))
	context.mappings = mappings
	return context


func _make_mapping(action_id: StringName) -> GFInputMapping:
	var action: GFInputAction = GFInputAction.new()
	action.action_id = action_id
	action.display_name = String(action_id).capitalize()

	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_SPACE
	event.physical_keycode = KEY_SPACE

	var binding: GFInputBinding = GFInputBinding.new()
	binding.input_event = event

	var mapping: GFInputMapping = GFInputMapping.new()
	mapping.action = action
	var bindings: Array[GFInputBinding] = [binding]
	mapping.bindings = bindings
	return mapping
