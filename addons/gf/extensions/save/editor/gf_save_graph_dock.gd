@tool

## GF SaveGraph 工作区页面。
##
## 查看当前场景中的 GFSaveScope/GFSaveSource 结构，执行健康检查并按需采集预览载荷。
extends Control


# --- 常量 ---

const GFSaveGraphUtilityBase = preload("res://addons/gf/extensions/save/graph/gf_save_graph_utility.gd")
const GFSaveScopeBase = preload("res://addons/gf/extensions/save/core/gf_save_scope.gd")
const GFSaveSourceBase = preload("res://addons/gf/extensions/save/core/gf_save_source.gd")
const _INSTANCE_GUARD: Script = preload("res://addons/gf/kernel/core/gf_instance_guard.gd")
const GFEditorWorkspaceUI = preload("res://addons/gf/kernel/editor/gf_editor_workspace_ui.gd")


# --- 私有变量 ---

var _root_ref: WeakRef = null
var _scopes: Array[Node] = []
var _utility: GFSaveGraphUtilityBase = null
var _last_scope_report: Dictionary = {}
var _last_payload: Dictionary = {}
var _last_payload_report: Dictionary = {}
var _scope_option: OptionButton = null
var _strict_payload_check: CheckBox = null
var _include_trace_check: CheckBox = null
var _select_button: Button = null
var _summary_label: Label = null
var _empty_label: Label = null
var _content_split: HSplitContainer = null
var _tree: Tree = null
var _tabs: TabContainer = null
var _details: TextEdit = null
var _payload_output: TextEdit = null


# --- Godot 生命周期方法 ---

func _init() -> void:
	name = "GF Save"
	GFEditorWorkspaceUI.apply_page_root(self)
	_utility = GFSaveGraphUtilityBase.new()
	_build_ui()
	call_deferred("refresh")


# --- 公共方法 ---

## 设置要扫描的场景根节点。
## @param root: 场景根节点。
func set_save_graph_source(root: Node) -> void:
	_root_ref = weakref(root) if root != null else null
	refresh(root)


## 刷新 SaveGraph 结构与健康报告。
## @param root: 可选场景根节点。
func refresh(root: Node = null) -> void:
	_build_ui()
	var source_root := root if root != null else _resolve_root()
	_scopes.clear()
	if source_root != null:
		_root_ref = weakref(source_root)
		_collect_scopes(source_root, _scopes)
	_populate_scope_options()
	_render_selected_scope()


## 获取最近一次 Scope 健康报告。
## @return 报告副本。
func get_last_scope_report() -> Dictionary:
	return _last_scope_report.duplicate(true)


## 获取最近一次预览载荷。
## @return 载荷副本。
func get_last_payload() -> Dictionary:
	return _last_payload.duplicate(true)


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

	toolbar.add_child(GFEditorWorkspaceUI.make_button("刷新", "扫描当前场景中的 GFSaveScope。", refresh))

	_scope_option = OptionButton.new()
	_scope_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scope_option.tooltip_text = "选择一个 GFSaveScope。"
	_scope_option.item_selected.connect(_on_scope_selected)
	toolbar.add_child(_scope_option)

	_strict_payload_check = CheckBox.new()
	_strict_payload_check.text = "严格载荷"
	_strict_payload_check.tooltip_text = "校验预览载荷时把缺失 Source/Scope 视为错误。"
	_strict_payload_check.toggled.connect(_on_option_toggled)
	toolbar.add_child(_strict_payload_check)

	_include_trace_check = CheckBox.new()
	_include_trace_check.text = "跟踪"
	_include_trace_check.tooltip_text = "采集预览载荷时包含 pipeline trace。"
	toolbar.add_child(_include_trace_check)

	_select_button = GFEditorWorkspaceUI.make_button("选中", "在编辑器场景树中选中当前 Scope。", _on_select_pressed)
	toolbar.add_child(_select_button)

	toolbar.add_child(GFEditorWorkspaceUI.make_button("预览载荷", "采集当前 Scope 的 SaveGraph 预览载荷。", _on_preview_payload_pressed))
	toolbar.add_child(GFEditorWorkspaceUI.make_button("复制报告", "复制当前 SaveGraph 报告 JSON。", _on_copy_report_pressed))

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
	_tree.set_column_title(2, "状态")
	_tree.set_column_title(3, "说明")
	_tree.set_column_expand(3, true)
	_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.item_selected.connect(_on_tree_item_selected)
	_content_split.add_child(_tree)

	_tabs = TabContainer.new()
	_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_split.add_child(_tabs)

	_details = GFEditorWorkspaceUI.make_details_output()
	_details.name = "详情"
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tabs.add_child(_details)

	_payload_output = GFEditorWorkspaceUI.make_details_output()
	_payload_output.name = "载荷"
	_payload_output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_payload_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tabs.add_child(_payload_output)


func _resolve_root() -> Node:
	if _root_ref != null:
		var root: Node = _INSTANCE_GUARD._get_live_node_from_ref(_root_ref)
		if root != null:
			return root

	if Engine.is_editor_hint():
		var edited_root := EditorInterface.get_edited_scene_root()
		if edited_root != null:
			return edited_root

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.current_scene if tree.current_scene != null else tree.root


func _collect_scopes(node: Node, result: Array[Node]) -> void:
	if node is GFSaveScopeBase:
		result.append(node)

	for child: Node in node.get_children():
		_collect_scopes(child, result)


func _populate_scope_options() -> void:
	if _scope_option == null:
		return

	var previous_index := _scope_option.selected
	_scope_option.clear()
	for index: int in range(_scopes.size()):
		var scope := _scopes[index]
		_scope_option.add_item(_get_node_path_text(scope), index)
		_scope_option.set_item_metadata(index, index)

	if _scopes.is_empty():
		_scope_option.add_item("未找到 GFSaveScope", 0)
		_scope_option.disabled = true
		_select_button.disabled = true
	else:
		_scope_option.disabled = false
		_select_button.disabled = false
		_scope_option.select(clampi(previous_index, 0, _scopes.size() - 1))


func _render_selected_scope() -> void:
	if _tree == null:
		return

	_tree.clear()
	_details.text = ""
	_payload_output.text = ""
	_last_payload = {}
	_last_payload_report = {}
	if _scopes.is_empty():
		_last_scope_report = {}
		_render_empty(
			"未找到 GFSaveScope。",
			"当前场景没有 GFSaveScope。打开或添加保存作用域后点击刷新。"
		)
		return

	var scope := _get_selected_scope()
	if scope == null:
		_last_scope_report = {}
		_render_empty("选择无效。", "当前 GFSaveScope 选择无效，请刷新后重试。")
		return

	_last_scope_report = _utility.inspect_scope(scope)
	_render_report(scope)


func _render_report(scope: GFSaveScopeBase) -> void:
	_empty_label.visible = false
	_content_split.visible = true
	_tree.visible = true
	_payload_output.text = "点击“预览载荷”采集当前 GFSaveScope 的 SaveGraph payload。"
	_summary_label.text = "%s\n下一步：%s" % [
		String(_last_scope_report.get("summary", "")),
		String(_last_scope_report.get("next_action", "")),
	]
	_summary_label.modulate = GFEditorWorkspaceUI.get_report_color(_last_scope_report)
	_details.text = _safe_json(_last_scope_report)

	var root_item := _tree.create_item()
	var root_scope_entry := _get_root_scope_entry()
	var scope_item := _tree.create_item(root_item)
	scope_item.set_text(0, "Root")
	scope_item.set_text(1, String(root_scope_entry.get("key", "")))
	scope_item.set_text(2, _get_save_load_state(
		bool(root_scope_entry.get("can_save", false)),
		bool(root_scope_entry.get("can_load", false))
	))
	scope_item.set_text(3, String(root_scope_entry.get("path", _get_node_path_text(scope))))
	scope_item.set_metadata(0, root_scope_entry.duplicate(true))

	for scope_variant: Variant in _last_scope_report.get("scopes", []):
		var scope_entry := scope_variant as Dictionary
		if scope_entry != null:
			_add_scope_item(root_item, scope_entry)

	for source_variant: Variant in _last_scope_report.get("sources", []):
		var source_entry := source_variant as Dictionary
		if source_entry != null:
			_add_source_item(root_item, source_entry)

	for issue_variant: Variant in _last_scope_report.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue != null:
			_add_issue_item(root_item, issue)


func _add_scope_item(parent: TreeItem, scope_entry: Dictionary) -> void:
	var item := _tree.create_item(parent)
	item.set_text(0, "Scope")
	item.set_text(1, String(scope_entry.get("key", "")))
	item.set_text(2, _get_save_load_state(bool(scope_entry.get("can_save", false)), bool(scope_entry.get("can_load", false))))
	item.set_text(3, String(scope_entry.get("path", "")))
	item.set_metadata(0, scope_entry.duplicate(true))


func _add_source_item(parent: TreeItem, source_entry: Dictionary) -> void:
	var serializer_ids := source_entry.get("serializer_ids", PackedStringArray()) as PackedStringArray
	var serializer_text := ", ".join(serializer_ids) if serializer_ids != null and not serializer_ids.is_empty() else "无 serializer"
	var item := _tree.create_item(parent)
	item.set_text(0, "Source")
	item.set_text(1, String(source_entry.get("key", "")))
	item.set_text(2, _get_save_load_state(bool(source_entry.get("can_save", false)), bool(source_entry.get("can_load", false))))
	item.set_text(3, "%s -> %s · %s" % [
		String(source_entry.get("path", "")),
		String(source_entry.get("target_path", "")),
		serializer_text,
	])
	item.set_metadata(0, _sanitize_for_display(source_entry))


func _add_issue_item(parent: TreeItem, issue: Dictionary) -> void:
	var item := _tree.create_item(parent)
	item.set_text(0, String(issue.get("severity", "")))
	item.set_text(1, String(issue.get("kind", "")))
	item.set_text(2, String(issue.get("key", "")))
	item.set_text(3, String(issue.get("message", "")))
	item.set_metadata(0, issue.duplicate(true))


func _render_empty(message: String, hint: String = "") -> void:
	if _tree != null:
		_tree.clear()
		_tree.visible = false
	if _content_split != null:
		_content_split.visible = false
	if _details != null:
		_details.text = hint if not hint.is_empty() else message
	if _payload_output != null:
		_payload_output.text = ""
	if _empty_label != null:
		_empty_label.text = hint if not hint.is_empty() else message
		_empty_label.visible = true
	GFEditorWorkspaceUI.set_status(_summary_label, message, GFEditorWorkspaceUI.INFO_TEXT_COLOR)


func _get_root_scope_entry() -> Dictionary:
	for scope_variant: Variant in _last_scope_report.get("scopes", []):
		var scope_entry := scope_variant as Dictionary
		if scope_entry != null:
			return scope_entry
	return {}


func _get_selected_scope() -> GFSaveScopeBase:
	if _scope_option == null or _scopes.is_empty():
		return null
	var index := _scope_option.selected
	if index < 0 or index >= _scopes.size():
		return null
	var scope := _scopes[index] as GFSaveScopeBase
	return scope if is_instance_valid(scope) else null


func _preview_payload() -> void:
	var scope := _get_selected_scope()
	if scope == null:
		_render_empty("选择无效。", "当前 GFSaveScope 选择无效，请刷新后重试。")
		return

	_last_payload = _utility.gather_scope(scope, {
		"include_pipeline_trace": _include_trace_check != null and _include_trace_check.button_pressed,
	})
	if _last_payload.is_empty():
		_payload_output.text = ""
		GFEditorWorkspaceUI.set_status(_summary_label, "预览载荷为空。", GFEditorWorkspaceUI.WARNING_TEXT_COLOR)
		return

	_last_payload_report = _utility.validate_payload_for_scope(
		scope,
		_last_payload,
		_strict_payload_check != null and _strict_payload_check.button_pressed
	)
	_payload_output.text = _safe_json({
		"payload": _last_payload,
		"payload_report": _last_payload_report,
	})
	_tabs.current_tab = 1
	GFEditorWorkspaceUI.set_status(
		_summary_label,
		"%s\nPayload：%s" % [
			String(_last_scope_report.get("summary", "")),
			String(_last_payload_report.get("summary", "")),
		],
		GFEditorWorkspaceUI.get_report_color(_last_payload_report)
	)


func _get_save_load_state(can_save: bool, can_load: bool) -> String:
	if can_save and can_load:
		return "保存/加载"
	if can_save:
		return "保存"
	if can_load:
		return "加载"
	return "禁用"


func _get_node_path_text(node: Node) -> String:
	if node == null:
		return ""
	if node.is_inside_tree():
		return String(node.get_path())
	return String(node.name)


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
	if value is Object:
		return str(value)
	return value


# --- 信号处理函数 ---

func _on_scope_selected(_index: int) -> void:
	_render_selected_scope()


func _on_option_toggled(_pressed: bool) -> void:
	if not _last_payload.is_empty():
		_preview_payload()


func _on_select_pressed() -> void:
	if not Engine.is_editor_hint():
		return

	var scope := _get_selected_scope()
	if scope == null:
		return

	var selection := EditorInterface.get_selection()
	if selection == null:
		return
	selection.clear()
	selection.add_node(scope)


func _on_preview_payload_pressed() -> void:
	_preview_payload()


func _on_copy_report_pressed() -> void:
	var report := {
		"scope_report": _last_scope_report,
		"payload_report": _last_payload_report,
	}
	if not _last_payload.is_empty():
		report["payload"] = _last_payload
	DisplayServer.clipboard_set(_safe_json(report))
	GFEditorWorkspaceUI.set_status(_summary_label, "已复制 SaveGraph 报告。", GFEditorWorkspaceUI.OK_TEXT_COLOR)


func _on_tree_item_selected() -> void:
	var item := _tree.get_selected()
	if item == null:
		return
	_details.text = _safe_json(item.get_metadata(0))
	_tabs.current_tab = 0
