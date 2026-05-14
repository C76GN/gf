@tool

## GF 输入映射工作区页面。
##
## 读取 GFInputContext 资源，展示动作、绑定与重绑定冲突诊断。
extends Control


# --- 常量 ---

const GFInputActionBase = preload("res://addons/gf/standard/input/mapping/gf_input_action.gd")
const GFInputBindingBase = preload("res://addons/gf/standard/input/mapping/gf_input_binding.gd")
const GFInputConflictAnalyzerBase = preload("res://addons/gf/standard/input/rebinding/gf_input_conflict_analyzer.gd")
const GFInputContextBase = preload("res://addons/gf/standard/input/mapping/gf_input_context.gd")
const GFInputFormatterBase = preload("res://addons/gf/standard/input/formatting/gf_input_formatter.gd")
const GFInputMappingBase = preload("res://addons/gf/standard/input/mapping/gf_input_mapping.gd")
const GFEditorWorkspaceUI = preload("res://addons/gf/kernel/editor/gf_editor_workspace_ui.gd")


# --- 私有变量 ---

var _context: GFInputContextBase = null
var _last_report: Dictionary = {}
var _path_edit: LineEdit = null
var _include_non_remappable_check: CheckBox = null
var _summary_label: Label = null
var _empty_label: Label = null
var _content_split: HSplitContainer = null
var _tree: Tree = null
var _details: TextEdit = null
var _file_dialog: FileDialog = null


# --- Godot 生命周期方法 ---

func _init() -> void:
	name = "GF Input Mapping"
	GFEditorWorkspaceUI.apply_page_root(self)
	_build_ui()
	call_deferred("refresh")


# --- 公共方法 ---

## 载入输入上下文资源。
## @param context: 输入上下文资源。
func set_input_context(context: GFInputContextBase) -> void:
	_context = context
	if _path_edit != null and context != null:
		_path_edit.text = context.resource_path
	refresh()


## 从资源路径载入输入上下文。
## @param path: 输入上下文资源路径。
## @return Godot 错误码。
func load_context_path(path: String) -> Error:
	var normalized_path := path.strip_edges()
	if normalized_path.is_empty():
		_render_empty("输入上下文路径为空。", "请填写 GFInputContext 资源路径后再加载。")
		return ERR_INVALID_PARAMETER

	var resource := ResourceLoader.load(normalized_path)
	var context := resource as GFInputContextBase
	if context == null:
		_context = null
		_last_report = {}
		_render_empty("输入上下文加载失败。", "资源不是 GFInputContext：%s" % normalized_path)
		return ERR_INVALID_DATA

	_context = context
	if _path_edit != null:
		_path_edit.text = normalized_path
	refresh()
	return OK


## 刷新当前上下文诊断。
func refresh() -> void:
	_build_ui()
	if _context == null:
		_last_report = {}
		_render_empty("未加载输入上下文。", "选择或填写 GFInputContext 资源后点击加载。")
		return

	_last_report = _build_report(_context)
	_render_context()


## 获取最近一次诊断报告。
## @return 诊断报告副本。
func get_last_report() -> Dictionary:
	return _last_report.duplicate(true)


# --- 私有/辅助方法 ---

func _build_ui() -> void:
	if _tree != null:
		return

	var root_box := VBoxContainer.new()
	root_box.clip_contents = true
	root_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(root_box)
	root_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var toolbar := GFEditorWorkspaceUI.make_toolbar()
	root_box.add_child(toolbar)

	_path_edit = LineEdit.new()
	_path_edit.placeholder_text = "res://path/to/input_context.tres"
	_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_path_edit.text_submitted.connect(_on_path_submitted)
	toolbar.add_child(_path_edit)

	toolbar.add_child(GFEditorWorkspaceUI.make_button("...", "选择输入上下文资源。", _on_browse_pressed))
	toolbar.add_child(GFEditorWorkspaceUI.make_button("加载", "载入当前路径中的输入上下文。", _on_load_pressed))
	toolbar.add_child(GFEditorWorkspaceUI.make_button("刷新", "重新分析当前输入上下文。", refresh))

	_include_non_remappable_check = CheckBox.new()
	_include_non_remappable_check.text = "包含不可重绑"
	_include_non_remappable_check.button_pressed = true
	_include_non_remappable_check.tooltip_text = "冲突分析是否包含不可重绑定的动作和绑定。"
	_include_non_remappable_check.toggled.connect(_on_option_toggled)
	toolbar.add_child(_include_non_remappable_check)

	toolbar.add_child(GFEditorWorkspaceUI.make_button("复制报告", "复制当前输入映射诊断 JSON。", _on_copy_pressed))

	_summary_label = GFEditorWorkspaceUI.make_summary_label()
	root_box.add_child(_summary_label)

	_empty_label = GFEditorWorkspaceUI.make_empty_label()
	root_box.add_child(_empty_label)

	_content_split = HSplitContainer.new()
	_content_split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_box.add_child(_content_split)

	_tree = Tree.new()
	_tree.columns = 4
	_tree.hide_root = true
	_tree.column_titles_visible = true
	_tree.set_column_title(0, "类型")
	_tree.set_column_title(1, "标识")
	_tree.set_column_title(2, "绑定")
	_tree.set_column_title(3, "说明")
	_tree.set_column_expand(3, true)
	_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.item_selected.connect(_on_tree_item_selected)
	_content_split.add_child(_tree)

	_details = GFEditorWorkspaceUI.make_details_output()
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_split.add_child(_details)

	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.file_selected.connect(_on_file_selected)
	add_child(_file_dialog)


func _build_report(context: GFInputContextBase) -> Dictionary:
	var include_non_remappable := (
		_include_non_remappable_check == null
		or _include_non_remappable_check.button_pressed
	)
	var report := GFInputConflictAnalyzerBase.build_rebind_report(
		[context],
		null,
		false,
		include_non_remappable
	)
	var issues: Array[Dictionary] = []
	_collect_structure_issues(context, issues)
	for conflict_variant: Variant in report.get("conflicts", []):
		var conflict := conflict_variant as Dictionary
		if conflict == null:
			continue
		issues.append({
			"severity": "warning",
			"kind": "binding_conflict",
			"path": "%s/%s" % [
				String(conflict.get("context_id", "")),
				String(conflict.get("action_id", "")),
			],
			"message": "输入绑定冲突：%s" % String(conflict.get("event_text", "")),
			"metadata": _sanitize_for_display(conflict),
		})

	var error_count := _count_issues(issues, "error")
	var warning_count := _count_issues(issues, "warning")
	report["ok"] = error_count == 0 and warning_count == 0
	report["context_id"] = context.get_context_id()
	report["context_name"] = context.get_display_name()
	report["mapping_count"] = context.mappings.size()
	report["binding_count"] = _count_bindings(context)
	report["error_count"] = error_count
	report["warning_count"] = warning_count
	report["issues"] = issues
	report["summary"] = "动作：%d  绑定：%d  冲突：%d  问题：%d" % [
		context.mappings.size(),
		int(report.get("item_count", 0)),
		int(report.get("conflict_count", 0)),
		issues.size(),
	]
	report["next_action"] = _make_next_action(error_count, warning_count)
	return report


func _collect_structure_issues(context: GFInputContextBase, issues: Array[Dictionary]) -> void:
	if context.get_context_id() == &"":
		issues.append(_make_issue("warning", "empty_context_id", "", "输入上下文缺少稳定 context_id。"))

	for mapping_index: int in range(context.mappings.size()):
		var mapping := context.mappings[mapping_index]
		var mapping_path := "mappings/%d" % mapping_index
		if mapping == null:
			issues.append(_make_issue("error", "null_mapping", mapping_path, "映射为空。"))
			continue
		if mapping.action == null:
			issues.append(_make_issue("error", "missing_action", mapping_path, "映射缺少 GFInputAction。"))
		elif mapping.get_action_id() == &"":
			issues.append(_make_issue("warning", "empty_action_id", mapping_path, "动作缺少稳定 action_id。"))
		if mapping.bindings.is_empty():
			issues.append(_make_issue("warning", "empty_bindings", mapping_path, "动作没有任何输入绑定。"))

		for binding_index: int in range(mapping.bindings.size()):
			var binding := mapping.bindings[binding_index]
			var binding_path := "%s/bindings/%d" % [mapping_path, binding_index]
			if binding == null:
				issues.append(_make_issue("error", "null_binding", binding_path, "绑定为空。"))
				continue
			if binding.input_event == null:
				issues.append(_make_issue("warning", "empty_input_event", binding_path, "绑定没有输入事件。"))


func _render_context() -> void:
	if _tree == null:
		return

	_tree.clear()
	_details.text = _safe_json(_last_report)
	_empty_label.visible = false
	_content_split.visible = true
	_tree.visible = true
	_summary_label.text = "%s\n下一步：%s" % [
		String(_last_report.get("summary", "")),
		String(_last_report.get("next_action", "")),
	]
	_summary_label.modulate = GFEditorWorkspaceUI.get_report_color(_last_report)

	var root_item := _tree.create_item()
	var context_item := _tree.create_item(root_item)
	context_item.set_text(0, "上下文")
	context_item.set_text(1, String(_context.get_context_id()))
	context_item.set_text(2, "%d mappings" % _context.mappings.size())
	context_item.set_text(3, _context.get_display_name())
	context_item.set_metadata(0, _make_context_details(_context))

	for mapping_index: int in range(_context.mappings.size()):
		var mapping := _context.mappings[mapping_index]
		if mapping == null:
			_add_issue_item(root_item, _make_issue("error", "null_mapping", "mappings/%d" % mapping_index, "映射为空。"))
			continue
		var mapping_item := _tree.create_item(root_item)
		mapping_item.set_text(0, "动作")
		mapping_item.set_text(1, String(mapping.get_action_id()))
		mapping_item.set_text(2, GFInputFormatterBase.mapping_as_text(mapping, _context.get_context_id()))
		mapping_item.set_text(3, "%s · %s" % [
			mapping.get_display_name(),
			_get_value_type_name(mapping.action.value_type) if mapping.action != null else "missing action",
		])
		mapping_item.set_metadata(0, _make_mapping_details(mapping, mapping_index))
		_add_binding_items(mapping_item, mapping)

	for issue: Dictionary in _last_report.get("issues", []):
		_add_issue_item(root_item, issue)


func _add_binding_items(parent: TreeItem, mapping: GFInputMappingBase) -> void:
	for binding_index: int in range(mapping.bindings.size()):
		var binding := mapping.bindings[binding_index]
		if binding == null:
			continue
		var item := _tree.create_item(parent)
		item.set_text(0, "绑定")
		item.set_text(1, "%d" % binding_index)
		item.set_text(2, GFInputFormatterBase.binding_as_text(binding))
		item.set_text(3, "%s · deadzone %.2f · scale %.2f" % [
			_get_value_target_name(binding.value_target),
			binding.deadzone,
			binding.scale,
		])
		item.set_metadata(0, _make_binding_details(binding, binding_index))


func _add_issue_item(parent: TreeItem, issue: Dictionary) -> void:
	var item := _tree.create_item(parent)
	item.set_text(0, String(issue.get("severity", "")))
	item.set_text(1, String(issue.get("kind", "")))
	item.set_text(2, String(issue.get("path", "")))
	item.set_text(3, String(issue.get("message", "")))
	item.set_metadata(0, issue.duplicate(true))


func _render_empty(status: String, hint: String = "") -> void:
	if _tree != null:
		_tree.clear()
		_tree.visible = false
	if _content_split != null:
		_content_split.visible = false
	if _details != null:
		_details.text = hint if not hint.is_empty() else status
	if _empty_label != null:
		_empty_label.text = hint if not hint.is_empty() else status
		_empty_label.visible = true
	_set_status(status, GFEditorWorkspaceUI.INFO_TEXT_COLOR)


func _make_context_details(context: GFInputContextBase) -> Dictionary:
	return {
		"context_id": context.get_context_id(),
		"display_name": context.get_display_name(),
		"resource_path": context.resource_path,
		"mapping_count": context.mappings.size(),
	}


func _make_mapping_details(mapping: GFInputMappingBase, mapping_index: int) -> Dictionary:
	return {
		"index": mapping_index,
		"action_id": mapping.get_action_id(),
		"display_name": mapping.get_display_name(),
		"display_category": mapping.get_display_category(),
		"value_type": _get_value_type_name(mapping.action.value_type) if mapping.action != null else "",
		"binding_count": mapping.bindings.size(),
		"modifier_count": mapping.modifiers.size(),
		"trigger_count": mapping.triggers.size(),
	}


func _make_binding_details(binding: GFInputBindingBase, binding_index: int) -> Dictionary:
	return {
		"index": binding_index,
		"text": GFInputFormatterBase.binding_as_text(binding),
		"input_event": GFInputFormatterBase.input_event_as_text(binding.input_event),
		"value_target": _get_value_target_name(binding.value_target),
		"deadzone": binding.deadzone,
		"scale": binding.scale,
		"match_device": binding.match_device,
		"match_touch_index": binding.match_touch_index,
		"remappable": binding.remappable,
		"modifier_count": binding.modifiers.size(),
	}


func _make_issue(severity: String, kind: String, path: String, message: String) -> Dictionary:
	return {
		"severity": severity,
		"kind": kind,
		"path": path,
		"message": message,
	}


func _make_next_action(error_count: int, warning_count: int) -> String:
	if error_count > 0:
		return "先修复缺失动作、空映射或空绑定。"
	if warning_count > 0:
		return "检查冲突、空绑定和缺少稳定标识的配置。"
	return "当前输入上下文结构健康。"


func _count_bindings(context: GFInputContextBase) -> int:
	var count := 0
	for mapping: GFInputMappingBase in context.mappings:
		if mapping != null:
			count += mapping.bindings.size()
	return count


func _count_issues(issues: Array[Dictionary], severity: String) -> int:
	var count := 0
	for issue: Dictionary in issues:
		if String(issue.get("severity", "")) == severity:
			count += 1
	return count


func _set_status(message: String, color: Color) -> void:
	GFEditorWorkspaceUI.set_status(_summary_label, message, color)


func _get_value_type_name(value_type: int) -> String:
	match value_type:
		GFInputActionBase.ValueType.AXIS_1D:
			return "axis_1d"
		GFInputActionBase.ValueType.AXIS_2D:
			return "axis_2d"
		GFInputActionBase.ValueType.AXIS_3D:
			return "axis_3d"
		_:
			return "bool"


func _get_value_target_name(value_target: int) -> String:
	match value_target:
		GFInputBindingBase.ValueTarget.BOOL:
			return "bool"
		GFInputBindingBase.ValueTarget.AXIS_1D_POSITIVE:
			return "axis_1d_positive"
		GFInputBindingBase.ValueTarget.AXIS_1D_NEGATIVE:
			return "axis_1d_negative"
		GFInputBindingBase.ValueTarget.AXIS_2D_X_POSITIVE:
			return "axis_2d_x_positive"
		GFInputBindingBase.ValueTarget.AXIS_2D_X_NEGATIVE:
			return "axis_2d_x_negative"
		GFInputBindingBase.ValueTarget.AXIS_2D_Y_POSITIVE:
			return "axis_2d_y_positive"
		GFInputBindingBase.ValueTarget.AXIS_2D_Y_NEGATIVE:
			return "axis_2d_y_negative"
		GFInputBindingBase.ValueTarget.AXIS_3D_X_POSITIVE:
			return "axis_3d_x_positive"
		GFInputBindingBase.ValueTarget.AXIS_3D_X_NEGATIVE:
			return "axis_3d_x_negative"
		GFInputBindingBase.ValueTarget.AXIS_3D_Y_POSITIVE:
			return "axis_3d_y_positive"
		GFInputBindingBase.ValueTarget.AXIS_3D_Y_NEGATIVE:
			return "axis_3d_y_negative"
		GFInputBindingBase.ValueTarget.AXIS_3D_Z_POSITIVE:
			return "axis_3d_z_positive"
		GFInputBindingBase.ValueTarget.AXIS_3D_Z_NEGATIVE:
			return "axis_3d_z_negative"
		_:
			return "auto"


func _safe_json(value: Variant) -> String:
	return JSON.stringify(_sanitize_for_display(value), "\t")


func _sanitize_for_display(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		for key: Variant in value.keys():
			result[str(key)] = _sanitize_for_display(value[key])
		return result
	if value is Array:
		var array_result: Array = []
		for item: Variant in value:
			array_result.append(_sanitize_for_display(item))
		return array_result
	if value is PackedStringArray:
		var strings: Array[String] = []
		for item: String in value:
			strings.append(item)
		return strings
	if value is InputEvent:
		return GFInputFormatterBase.input_event_as_text(value)
	if value is Object:
		return str(value)
	return value


# --- 信号处理函数 ---

func _on_path_submitted(path: String) -> void:
	load_context_path(path)


func _on_browse_pressed() -> void:
	if is_instance_valid(_file_dialog):
		_file_dialog.popup_centered_ratio(0.6)


func _on_file_selected(path: String) -> void:
	if _path_edit != null:
		_path_edit.text = path
	load_context_path(path)


func _on_load_pressed() -> void:
	if _path_edit == null:
		return
	load_context_path(_path_edit.text)


func _on_option_toggled(_pressed: bool) -> void:
	refresh()


func _on_tree_item_selected() -> void:
	var item := _tree.get_selected()
	if item == null:
		return
	_details.text = _safe_json(item.get_metadata(0))


func _on_copy_pressed() -> void:
	if _last_report.is_empty():
		return
	DisplayServer.clipboard_set(_safe_json(_last_report))
	_set_status("已复制输入映射诊断报告。", GFEditorWorkspaceUI.OK_TEXT_COLOR)
