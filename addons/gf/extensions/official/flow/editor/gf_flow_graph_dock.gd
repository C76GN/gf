@tool

## GFFlowGraphDock: FlowGraph 结构检查与布局工作区页面。
##
## 为资源化流程图提供路径加载、校验摘要、节点/连接清单和通用自动布局，
## 不提供业务节点库，也不解释项目自定义元数据。
class_name GFFlowGraphDock
extends Control


# --- 常量 ---

const DEFAULT_LAYOUT_OPTIONS: Dictionary = {
	"x_spacing": 280.0,
	"y_spacing": 160.0,
}
const GF_FLOW_GRAPH_BASE := preload("res://addons/gf/extensions/official/flow/resources/gf_flow_graph.gd")
const GF_FLOW_GRAPH_EDITOR_MODEL_BASE := preload("res://addons/gf/extensions/official/flow/editor/gf_flow_graph_editor_model.gd")


# --- 私有变量 ---

var _graph: GFFlowGraph = null
var _graph_path: String = ""
var _last_view_model: Dictionary = {}
var _path_edit: LineEdit = null
var _summary_label: Label = null
var _empty_label: Label = null
var _tree: Tree = null
var _details: TextEdit = null
var _file_dialog: FileDialog = null


# --- Godot 生命周期方法 ---

func _init() -> void:
	name = "GF Flow Tools"
	clip_contents = true
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_ui()


# --- 公共方法 ---

## 设置当前查看的 FlowGraph。
## @param graph: 流程图资源。
## @param path: 可选资源路径。
func set_graph(graph: GFFlowGraph, path: String = "") -> void:
	_graph = graph
	_graph_path = path if not path.is_empty() else (graph.resource_path if graph != null else "")
	if _path_edit != null:
		_path_edit.text = _graph_path
	refresh()


## 设置并加载当前 FlowGraph 资源路径。
## @param path: `res://` 资源路径。
func set_graph_path(path: String) -> void:
	_graph_path = path.strip_edges()
	if _path_edit != null:
		_path_edit.text = _graph_path
	_load_graph_from_path()
	refresh()


## 刷新当前 FlowGraph 视图。
func refresh() -> void:
	_build_ui()
	if _graph == null and not _graph_path.is_empty():
		_load_graph_from_path()
	_render_graph()


## 获取最近一次 FlowGraph 视图模型。
## @return 视图模型字典副本。
func get_last_view_model() -> Dictionary:
	return _last_view_model.duplicate(true)


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

	var toolbar := HBoxContainer.new()
	toolbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_box.add_child(toolbar)

	_path_edit = LineEdit.new()
	_path_edit.placeholder_text = "res://path/to/flow_graph.tres"
	_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_path_edit.text_submitted.connect(_on_path_submitted)
	toolbar.add_child(_path_edit)

	var browse_button := Button.new()
	browse_button.text = "..."
	browse_button.tooltip_text = "选择 FlowGraph 资源。"
	browse_button.pressed.connect(_on_browse_pressed)
	toolbar.add_child(browse_button)

	var refresh_button := Button.new()
	refresh_button.text = "刷新"
	refresh_button.tooltip_text = "重新加载并校验当前 FlowGraph。"
	refresh_button.pressed.connect(_on_refresh_pressed)
	toolbar.add_child(refresh_button)

	var layout_button := Button.new()
	layout_button.text = "自动布局"
	layout_button.tooltip_text = "按通用分层布局写入节点 editor_position。"
	layout_button.pressed.connect(_on_auto_layout_pressed)
	toolbar.add_child(layout_button)

	var save_button := Button.new()
	save_button.text = "保存"
	save_button.tooltip_text = "保存当前 FlowGraph 资源。"
	save_button.pressed.connect(_on_save_pressed)
	toolbar.add_child(save_button)

	_summary_label = Label.new()
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_box.add_child(_summary_label)

	_empty_label = Label.new()
	_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_box.add_child(_empty_label)

	_tree = Tree.new()
	_tree.columns = 4
	_tree.hide_root = true
	_tree.column_titles_visible = true
	_tree.set_column_title(0, "类型")
	_tree.set_column_title(1, "标识")
	_tree.set_column_title(2, "连接/分类")
	_tree.set_column_title(3, "说明")
	_tree.set_column_expand(3, true)
	_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.item_selected.connect(_on_item_selected)
	root_box.add_child(_tree)

	_details = TextEdit.new()
	_details.editable = false
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_details.custom_minimum_size = Vector2(0.0, 72.0)
	root_box.add_child(_details)

	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.filters = PackedStringArray(["*.tres, *.res ; Godot Resources"])
	_file_dialog.file_selected.connect(_on_file_selected)
	add_child(_file_dialog)


func _load_graph_from_path() -> void:
	if _graph_path.is_empty() or not ResourceLoader.exists(_graph_path):
		_graph = null
		return

	var resource := load(_graph_path) as Resource
	_graph = resource as GF_FLOW_GRAPH_BASE
	if _graph != null and _graph.resource_path.is_empty():
		_graph.resource_path = _graph_path


func _render_graph() -> void:
	if _tree == null:
		return

	_tree.clear()
	_details.text = ""
	if _graph == null:
		_last_view_model = {}
		_summary_label.text = "未加载 FlowGraph。"
		_summary_label.modulate = Color(0.8, 0.8, 0.8)
		_empty_label.text = "输入或选择一个 GFFlowGraph 资源路径后点击刷新。"
		_empty_label.visible = true
		_tree.visible = false
		return

	var editor_model: GFFlowGraphEditorModel = GF_FLOW_GRAPH_EDITOR_MODEL_BASE.new()
	_last_view_model = editor_model.build_view_model(_graph)
	var validation := _last_view_model.get("validation", {}) as Dictionary
	_summary_label.text = "%s\nNodes: %d  Connections: %d  Next: %s" % [
		String(validation.get("summary", "")),
		int(_last_view_model.get("node_count", 0)),
		int(_last_view_model.get("connection_count", 0)),
		String(validation.get("next_action", "")),
	]
	_summary_label.modulate = _get_report_color(validation)
	_render_entries(_last_view_model)


func _render_entries(view_model: Dictionary) -> void:
	var root_item := _tree.create_item()
	var visible_count := 0
	for node_variant: Variant in view_model.get("nodes", []):
		var node := node_variant as Dictionary
		if node == null:
			continue
		var item := _tree.create_item(root_item)
		item.set_text(0, "节点")
		item.set_text(1, String(node.get("node_id", "")))
		item.set_text(2, String(node.get("category", "")))
		item.set_text(3, "%s  @ %s" % [String(node.get("display_name", "")), str(node.get("position", Vector2.ZERO))])
		item.set_metadata(0, node.duplicate(true))
		visible_count += 1

	for connection_variant: Variant in view_model.get("connections", []):
		var connection := connection_variant as Dictionary
		if connection == null:
			continue
		var item := _tree.create_item(root_item)
		item.set_text(0, "连接")
		item.set_text(1, "%s -> %s" % [String(connection.get("from_node_id", "")), String(connection.get("to_node_id", ""))])
		item.set_text(2, "%s -> %s" % [String(connection.get("from_port_id", "")), String(connection.get("to_port_id", ""))])
		item.set_text(3, "valid=%s" % str(connection.get("valid", false)))
		item.set_metadata(0, connection.duplicate(true))
		visible_count += 1

	var validation := view_model.get("validation", {}) as Dictionary
	for issue_variant: Variant in validation.get("issues", []):
		var issue := issue_variant as Dictionary
		if issue == null:
			continue
		var item := _tree.create_item(root_item)
		item.set_text(0, String(issue.get("severity", "")))
		item.set_text(1, String(issue.get("kind", "")))
		item.set_text(2, String(issue.get("key", "")))
		item.set_text(3, String(issue.get("message", "")))
		item.set_metadata(0, issue.duplicate(true))
		visible_count += 1

	_tree.visible = visible_count > 0
	_empty_label.visible = visible_count == 0
	_empty_label.text = "当前 FlowGraph 没有节点、连接或校验问题。" if visible_count == 0 else ""


func _get_report_color(report: Dictionary) -> Color:
	if int(report.get("error_count", 0)) > 0:
		return Color(1.0, 0.45, 0.35)
	if int(report.get("warning_count", 0)) > 0:
		return Color(1.0, 0.78, 0.35)
	return Color(0.45, 0.9, 0.55)


func _save_graph() -> Error:
	if _graph == null:
		return ERR_UNCONFIGURED

	var output_path := _graph_path
	if output_path.is_empty():
		output_path = _graph.resource_path
	if output_path.is_empty():
		return ERR_FILE_BAD_PATH

	var error := ResourceSaver.save(_graph, output_path)
	if error == OK and Engine.is_editor_hint():
		var filesystem := EditorInterface.get_resource_filesystem()
		if filesystem != null:
			filesystem.scan()
	return error


func _safe_json(value: Variant) -> String:
	return JSON.stringify(value, "\t")


# --- 信号处理函数 ---

func _on_path_submitted(path: String) -> void:
	set_graph_path(path)


func _on_browse_pressed() -> void:
	if is_instance_valid(_file_dialog):
		_file_dialog.popup_centered_ratio(0.6)


func _on_file_selected(path: String) -> void:
	set_graph_path(path)


func _on_refresh_pressed() -> void:
	_graph_path = _path_edit.text.strip_edges() if _path_edit != null else _graph_path
	_load_graph_from_path()
	refresh()


func _on_auto_layout_pressed() -> void:
	if _graph == null:
		return

	var editor_model: GFFlowGraphEditorModel = GF_FLOW_GRAPH_EDITOR_MODEL_BASE.new()
	var report := editor_model.auto_layout(_graph, DEFAULT_LAYOUT_OPTIONS)
	_details.text = _safe_json(report)
	refresh()


func _on_save_pressed() -> void:
	var error := _save_graph()
	_details.text = "保存结果：%s" % error_string(error)


func _on_item_selected() -> void:
	var item := _tree.get_selected()
	if item == null:
		return

	var metadata := item.get_metadata(0)
	if metadata is Dictionary:
		_details.text = _safe_json(metadata)
