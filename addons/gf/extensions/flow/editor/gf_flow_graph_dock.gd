@tool

## GFFlowGraphDock: FlowGraph 图形化编辑与结构检查工作区页面。
##
## 为资源化流程图提供路径加载、GraphEdit 预览/连线、校验摘要、节点/连接清单
## 和通用自动布局，不提供业务节点库，也不解释项目自定义元数据。
## [br]
## @api public
## [br]
## @category editor_api
## [br]
## @since 3.17.0
class_name GFFlowGraphDock
extends Control


# --- 常量 ---

const _DEFAULT_LAYOUT_OPTIONS: Dictionary = {
	"x_spacing": 280.0,
	"y_spacing": 160.0,
}
const _DEFAULT_NODE_COLOR := Color(0.52, 0.68, 0.92)
const _EXECUTION_PORT_COLOR := Color(0.95, 0.78, 0.38)
const _SIDE_PANEL_MIN_WIDTH: float = 320.0
const _DETAIL_MIN_HEIGHT: float = 112.0
const _GF_EDITOR_WORKSPACE_UI_SCRIPT: Script = preload("res://addons/gf/kernel/editor/gf_editor_workspace_ui.gd")


# --- 私有变量 ---

var _graph: GFFlowGraph = null
var _graph_path: String = ""
var _last_view_model: Dictionary = {}
var _node_controls_by_id: Dictionary = {}
var _node_ids_by_control_name: Dictionary = {}
var _selected_node_id: StringName = &""
var _path_edit: LineEdit = null
var _summary_label: Label = null
var _empty_label: Label = null
var _content_split: HSplitContainer = null
var _graph_edit: GraphEdit = null
var _tree: Tree = null
var _details: TextEdit = null
var _file_dialog: FileDialog = null


# --- Godot 生命周期方法 ---

func _init() -> void:
	name = "GF Flow Tools"
	_GF_EDITOR_WORKSPACE_UI_SCRIPT.apply_page_root(self)
	_build_ui()
	refresh()


# --- 公共方法 ---

## 设置当前查看的 FlowGraph。
## [br]
## @api public
## [br]
## @param graph: 流程图资源。
## [br]
## @param path: 可选资源路径。
func set_graph(graph: GFFlowGraph, path: String = "") -> void:
	_graph = graph
	_graph_path = path if not path.is_empty() else (graph.resource_path if graph != null else "")
	if _path_edit != null:
		_path_edit.text = _graph_path
	refresh()


## 设置并加载当前 FlowGraph 资源路径。
## [br]
## @api public
## [br]
## @param path: `res://` 资源路径。
func set_graph_path(path: String) -> void:
	_graph_path = path.strip_edges()
	if _path_edit != null:
		_path_edit.text = _graph_path
	_load_graph_from_path()
	refresh()


## 刷新当前 FlowGraph 视图。
## [br]
## @api public
func refresh() -> void:
	_build_ui()
	if _graph == null and not _graph_path.is_empty():
		_load_graph_from_path()
	_render_graph()


## 获取最近一次 FlowGraph 视图模型。
## [br]
## @api public
## [br]
## @return 视图模型字典副本。
## [br]
## @schema return: Dictionary，由 GFFlowGraphEditorModel.build_view_model() 生成的视图模型副本。
func get_last_view_model() -> Dictionary:
	return _last_view_model.duplicate(true)


# --- 私有/辅助方法 ---

func _build_ui() -> void:
	if _graph_edit != null:
		return

	var root_box := VBoxContainer.new()
	root_box.clip_contents = true
	root_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(root_box)
	root_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var toolbar: HBoxContainer = _GF_EDITOR_WORKSPACE_UI_SCRIPT.make_toolbar()
	root_box.add_child(toolbar)

	_path_edit = LineEdit.new()
	_path_edit.placeholder_text = "res://path/to/flow_graph.tres"
	_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_path_edit.text_submitted.connect(_on_path_submitted)
	toolbar.add_child(_path_edit)

	toolbar.add_child(_GF_EDITOR_WORKSPACE_UI_SCRIPT.make_button("...", "选择 FlowGraph 资源。", _on_browse_pressed))
	toolbar.add_child(_GF_EDITOR_WORKSPACE_UI_SCRIPT.make_button("刷新", "重新加载并校验当前 FlowGraph。", _on_refresh_pressed))
	toolbar.add_child(_GF_EDITOR_WORKSPACE_UI_SCRIPT.make_button("自动布局", "按通用分层布局写入节点 editor_position。", _on_auto_layout_pressed))
	toolbar.add_child(_GF_EDITOR_WORKSPACE_UI_SCRIPT.make_button("保存", "保存当前 FlowGraph 资源。", _on_save_pressed))

	_summary_label = _GF_EDITOR_WORKSPACE_UI_SCRIPT.make_summary_label()
	root_box.add_child(_summary_label)

	_empty_label = _GF_EDITOR_WORKSPACE_UI_SCRIPT.make_empty_label()
	root_box.add_child(_empty_label)

	_content_split = HSplitContainer.new()
	_content_split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_box.add_child(_content_split)

	_graph_edit = GraphEdit.new()
	_graph_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_graph_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_connect_graph_edit_signal("connection_request", _on_connection_request)
	_connect_graph_edit_signal("disconnection_request", _on_disconnection_request)
	_connect_graph_edit_signal("delete_nodes_request", _on_delete_nodes_request)
	_connect_graph_edit_signal("node_selected", _on_node_selected)
	_connect_graph_edit_signal("end_node_move", _on_end_node_move)
	_content_split.add_child(_graph_edit)

	var side_panel := VBoxContainer.new()
	side_panel.custom_minimum_size = Vector2(_SIDE_PANEL_MIN_WIDTH, 0.0)
	side_panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	side_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_split.add_child(side_panel)

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
	side_panel.add_child(_tree)

	_details = _GF_EDITOR_WORKSPACE_UI_SCRIPT.make_details_output(_DETAIL_MIN_HEIGHT)
	side_panel.add_child(_details)

	_file_dialog = FileDialog.new()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.filters = PackedStringArray(["*.tres, *.res ; Godot Resources"])
	_file_dialog.file_selected.connect(_on_file_selected)
	add_child(_file_dialog)


func _connect_graph_edit_signal(signal_name: StringName, handler: Callable) -> void:
	if _graph_edit != null and _graph_edit.has_signal(signal_name):
		_graph_edit.connect(signal_name, handler)


func _load_graph_from_path() -> void:
	if _graph_path.is_empty() or not ResourceLoader.exists(_graph_path):
		_graph = null
		return

	var resource := load(_graph_path) as Resource
	_graph = resource as GFFlowGraph
	if _graph != null and _graph.resource_path.is_empty():
		_graph.resource_path = _graph_path


func _render_graph() -> void:
	if _tree == null:
		return

	_tree.clear()
	_details.text = ""
	_clear_graph_canvas()
	if _graph == null:
		_last_view_model = {}
		_GF_EDITOR_WORKSPACE_UI_SCRIPT.set_status(_summary_label, "未加载 FlowGraph。")
		_empty_label.text = "输入或选择一个 GFFlowGraph 资源路径后点击刷新。"
		_empty_label.visible = true
		_tree.visible = false
		_content_split.visible = false
		return

	var editor_model := GFFlowGraphEditorModel.new()
	_last_view_model = editor_model.build_view_model(_graph)
	var validation := _last_view_model.get("validation", {}) as Dictionary
	_summary_label.text = "%s\n节点：%d  连接：%d  下一步：%s" % [
		String(validation.get("summary", "")),
		int(_last_view_model.get("node_count", 0)),
		int(_last_view_model.get("connection_count", 0)),
		String(validation.get("next_action", "")),
	]
	_summary_label.modulate = _GF_EDITOR_WORKSPACE_UI_SCRIPT.get_report_color(validation)
	_content_split.visible = true
	_graph_edit.visible = true
	_render_graph_canvas(_last_view_model)
	_render_entries(_last_view_model)


func _render_graph_canvas(view_model: Dictionary) -> void:
	var nodes := view_model.get("nodes", []) as Array
	if nodes == null:
		return

	for index: int in range(nodes.size()):
		var node := nodes[index] as Dictionary
		if node == null:
			continue
		var graph_node := _make_graph_node(node, index)
		_graph_edit.add_child(graph_node)
		var node_id := StringName(node.get("node_id", &""))
		_node_controls_by_id[node_id] = graph_node
		_node_ids_by_control_name[StringName(graph_node.name)] = node_id

	var connections := view_model.get("connections", []) as Array
	if connections == null:
		return
	for connection_variant: Variant in connections:
		var connection := connection_variant as Dictionary
		if connection != null and bool(connection.get("valid", false)):
			_connect_graph_edit_nodes(connection)


func _make_graph_node(node_entry: Dictionary, index: int) -> GraphNode:
	var graph_node := GraphNode.new()
	var node_id := StringName(node_entry.get("node_id", &""))
	var display_name := String(node_entry.get("display_name", ""))
	graph_node.name = "FlowNode%d" % index
	graph_node.title = "%s  [%s]" % [display_name, String(node_id)]
	graph_node.position_offset = node_entry.get("position", Vector2.ZERO) as Vector2
	graph_node.custom_minimum_size = node_entry.get("size", Vector2(220.0, 120.0)) as Vector2
	graph_node.set_meta("node_id", node_id)
	_add_execution_slot(graph_node)
	_add_data_port_slots(graph_node, node_entry)
	return graph_node


func _add_execution_slot(graph_node: GraphNode) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_make_slot_label("in", HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(_make_slot_label("flow", HORIZONTAL_ALIGNMENT_RIGHT))
	graph_node.add_child(row)
	graph_node.set_slot(0, true, 0, _EXECUTION_PORT_COLOR, true, 0, _EXECUTION_PORT_COLOR)


func _add_data_port_slots(graph_node: GraphNode, node_entry: Dictionary) -> void:
	var input_ports := node_entry.get("input_ports", []) as Array
	var output_ports := node_entry.get("output_ports", []) as Array
	if input_ports == null:
		input_ports = []
	if output_ports == null:
		output_ports = []

	var row_count := maxi(input_ports.size(), output_ports.size())
	for index: int in range(row_count):
		var input_entry := input_ports[index] as Dictionary if index < input_ports.size() else {}
		var output_entry := output_ports[index] as Dictionary if index < output_ports.size() else {}
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(_make_slot_label(_get_port_label(input_entry), HORIZONTAL_ALIGNMENT_LEFT))
		row.add_child(_make_slot_label(_get_port_label(output_entry), HORIZONTAL_ALIGNMENT_RIGHT))
		graph_node.add_child(row)
		graph_node.set_slot(
			index + 1,
			not input_entry.is_empty(),
			0,
			_get_port_color(input_entry),
			not output_entry.is_empty(),
			0,
			_get_port_color(output_entry)
		)


func _make_slot_label(text: String, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


func _get_port_label(port_entry: Dictionary) -> String:
	if port_entry == null or port_entry.is_empty():
		return ""
	var display_name := String(port_entry.get("display_name", ""))
	if not display_name.is_empty():
		return display_name
	return String(port_entry.get("port_id", ""))


func _get_port_color(port_entry: Dictionary) -> Color:
	if port_entry == null or port_entry.is_empty():
		return _DEFAULT_NODE_COLOR
	var color := port_entry.get("editor_color", Color.TRANSPARENT) as Color
	if color.a > 0.0:
		return color
	return _DEFAULT_NODE_COLOR


func _connect_graph_edit_nodes(connection: Dictionary) -> void:
	var from_node_id := StringName(connection.get("from_node_id", &""))
	var to_node_id := StringName(connection.get("to_node_id", &""))
	var from_node := _node_controls_by_id.get(from_node_id) as GraphNode
	var to_node := _node_controls_by_id.get(to_node_id) as GraphNode
	if from_node == null or to_node == null:
		return

	var from_slot := int(connection.get("from_graph_slot_index", connection.get("from_port_index", 0)))
	var to_slot := int(connection.get("to_graph_slot_index", connection.get("to_port_index", 0)))
	if from_slot < 0 or to_slot < 0:
		return
	_graph_edit.call("connect_node", from_node.name, from_slot, to_node.name, to_slot)


func _clear_graph_canvas() -> void:
	_node_controls_by_id.clear()
	_node_ids_by_control_name.clear()
	_selected_node_id = &""
	if _graph_edit == null:
		return

	if _graph_edit.has_method("clear_connections"):
		_graph_edit.call("clear_connections")
	for child: Node in _graph_edit.get_children():
		if child is GraphNode:
			_graph_edit.remove_child(child)
			child.queue_free()


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


func _save_graph() -> Error:
	if _graph == null:
		return ERR_UNCONFIGURED

	_apply_canvas_layout_to_graph()
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


func _apply_canvas_layout_to_graph() -> void:
	if _graph == null:
		return

	for node_id_variant: Variant in _node_controls_by_id.keys():
		var node_id := StringName(node_id_variant)
		var graph_node := _node_controls_by_id[node_id] as GraphNode
		if graph_node != null:
			_graph.set_node_editor_position(node_id, graph_node.position_offset)


func _get_node_id_for_control(control_name: StringName) -> StringName:
	return StringName(_node_ids_by_control_name.get(control_name, &""))


func _get_port_lookup_for_slot(node_id: StringName, ports_key: String, slot_index: int) -> Dictionary:
	if slot_index <= 0:
		return {
			"ok": true,
			"port_id": &"",
		}

	var node_entry := _get_node_entry(node_id)
	var ports := node_entry.get(ports_key, []) as Array
	if ports == null:
		return _make_port_lookup(false)

	for port_variant: Variant in ports:
		var port := port_variant as Dictionary
		if port != null and int(port.get("graph_slot_index", -1)) == slot_index:
			return {
				"ok": true,
				"port_id": StringName(port.get("port_id", &"")),
			}
	return _make_port_lookup(false)


func _make_port_lookup(ok: bool) -> Dictionary:
	return {
		"ok": ok,
		"port_id": &"",
	}


func _get_node_entry(node_id: StringName) -> Dictionary:
	var lookup := _last_view_model.get("node_lookup", {}) as Dictionary
	if lookup != null and lookup.has(node_id):
		return lookup[node_id] as Dictionary
	return {}


func _show_details(value: Variant) -> void:
	_details.text = _safe_json(value)


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

	var editor_model := GFFlowGraphEditorModel.new()
	var report := editor_model.auto_layout(_graph, _DEFAULT_LAYOUT_OPTIONS)
	refresh()
	_show_details(report)


func _on_save_pressed() -> void:
	var error := _save_graph()
	_details.text = "保存结果：%s" % error_string(error)


func _on_connection_request(
	from_control_name: StringName,
	from_port_index: int,
	to_control_name: StringName,
	to_port_index: int
) -> void:
	if _graph == null:
		return

	var from_node_id := _get_node_id_for_control(from_control_name)
	var to_node_id := _get_node_id_for_control(to_control_name)
	var from_lookup := _get_port_lookup_for_slot(from_node_id, "output_ports", from_port_index)
	var to_lookup := _get_port_lookup_for_slot(to_node_id, "input_ports", to_port_index)
	if not bool(from_lookup.get("ok", false)) or not bool(to_lookup.get("ok", false)):
		_show_details({
			"ok": false,
			"error": "missing_port_for_slot",
			"from_slot": from_port_index,
			"to_slot": to_port_index,
		})
		return

	var added := _graph.add_connection(
		from_node_id,
		StringName(from_lookup.get("port_id", &"")),
		to_node_id,
		StringName(to_lookup.get("port_id", &""))
	)
	var report := {
		"ok": added,
		"action": "add_connection",
		"from_node_id": from_node_id,
		"to_node_id": to_node_id,
	}
	refresh()
	_show_details(report)


func _on_disconnection_request(
	from_control_name: StringName,
	from_port_index: int,
	to_control_name: StringName,
	to_port_index: int
) -> void:
	if _graph == null:
		return

	var from_node_id := _get_node_id_for_control(from_control_name)
	var to_node_id := _get_node_id_for_control(to_control_name)
	var from_lookup := _get_port_lookup_for_slot(from_node_id, "output_ports", from_port_index)
	var to_lookup := _get_port_lookup_for_slot(to_node_id, "input_ports", to_port_index)
	var removed := false
	if bool(from_lookup.get("ok", false)) and bool(to_lookup.get("ok", false)):
		removed = _graph.remove_connection(
			from_node_id,
			StringName(from_lookup.get("port_id", &"")),
			to_node_id,
			StringName(to_lookup.get("port_id", &""))
		)
	var report := {
		"ok": removed,
		"action": "remove_connection",
		"from_node_id": from_node_id,
		"to_node_id": to_node_id,
	}
	refresh()
	_show_details(report)


func _on_delete_nodes_request(control_names: Array) -> void:
	if _graph == null:
		return

	var node_ids := PackedStringArray()
	for control_name_variant: Variant in control_names:
		var node_id := _get_node_id_for_control(StringName(control_name_variant))
		if node_id != &"":
			node_ids.append(String(node_id))
	if node_ids.is_empty() and _selected_node_id != &"":
		node_ids.append(String(_selected_node_id))

	var editor_model := GFFlowGraphEditorModel.new()
	var report := editor_model.remove_nodes(_graph, node_ids)
	refresh()
	_show_details(report)


func _on_node_selected(node: Node) -> void:
	if node == null:
		return

	_selected_node_id = StringName(node.get_meta("node_id", &""))
	var node_entry := _get_node_entry(_selected_node_id)
	if not node_entry.is_empty():
		_show_details(node_entry)


func _on_end_node_move() -> void:
	_apply_canvas_layout_to_graph()
	refresh()


func _on_item_selected() -> void:
	var item := _tree.get_selected()
	if item == null:
		return

	var metadata := item.get_metadata(0)
	if metadata is Dictionary:
		_show_details(metadata)
