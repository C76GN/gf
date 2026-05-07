@tool

## GF Flow Graph Inspector: 在 Inspector 中辅助检查资源化流程图。
extends EditorInspectorPlugin


# --- 常量 ---

const GF_FLOW_GRAPH_BASE := preload("res://addons/gf/extensions/flow/gf_flow_graph.gd")


# --- Godot 回调方法 ---

func _can_handle(object: Object) -> bool:
	return object is GF_FLOW_GRAPH_BASE


func _parse_begin(object: Object) -> void:
	var graph := object as GF_FLOW_GRAPH_BASE
	if graph == null:
		return

	var root := VBoxContainer.new()
	root.name = "GFFlowGraphInspector"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_custom_control(root)

	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(header)

	var title := Label.new()
	title.text = "GF Flow Graph"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var validate_button := Button.new()
	validate_button.text = "校验"
	validate_button.tooltip_text = "校验流程图节点、端口与连接"
	header.add_child(validate_button)

	var start_row := HBoxContainer.new()
	start_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(start_row)

	var start_label := Label.new()
	start_label.text = "起始节点"
	start_label.custom_minimum_size = Vector2(72.0, 0.0)
	start_row.add_child(start_label)

	var start_option := OptionButton.new()
	start_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_option.tooltip_text = "从当前流程图节点中选择 start_node_id"
	start_row.add_child(start_option)
	_populate_start_options(start_option, graph)
	start_option.item_selected.connect(_on_start_node_selected.bind(start_option, graph), CONNECT_DEFERRED)

	var summary_label := Label.new()
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(summary_label)
	_update_summary(summary_label, graph)
	validate_button.pressed.connect(_on_validate_pressed.bind(summary_label, graph), CONNECT_DEFERRED)


# --- 私有/辅助方法 ---

func _populate_start_options(option: OptionButton, graph: Resource) -> void:
	option.clear()
	option.add_item("未设置", 0)
	option.set_item_metadata(0, &"")
	option.select(0)

	var nodes := graph.get("nodes") as Array
	if nodes == null:
		return

	var entries: Array[Dictionary] = []
	for node_variant: Variant in nodes:
		var node := node_variant as Resource
		if node == null:
			continue
		var node_id := node.get("node_id") as StringName
		if node_id == &"":
			continue
		var display_name := String(node.call("get_display_name")) if node.has_method("get_display_name") else String(node_id)
		entries.append({
			"node_id": node_id,
			"display_name": display_name,
		})

	entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return String(left["display_name"]) < String(right["display_name"])
	)

	var current_start := graph.get("start_node_id") as StringName
	for index: int in range(entries.size()):
		var entry := entries[index]
		option.add_item(String(entry["display_name"]), index + 1)
		option.set_item_metadata(index + 1, entry["node_id"])
		if entry["node_id"] == current_start:
			option.select(index + 1)


func _set_start_node(graph: Resource, node_id: StringName) -> void:
	var old_value := graph.get("start_node_id") as StringName
	if old_value == node_id:
		return

	var undo_redo := EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("设置 GF FlowGraph 起始节点")
	undo_redo.add_do_property(graph, "start_node_id", node_id)
	undo_redo.add_undo_property(graph, "start_node_id", old_value)
	undo_redo.commit_action()


func _update_summary(label: Label, graph: Resource) -> void:
	if label == null or graph == null or not graph.has_method("build_editor_report"):
		return

	var report := graph.call("build_editor_report") as Dictionary
	var validation := report.get("validation", {}) as Dictionary
	label.text = "%s\nNext: %s" % [
		String(report.get("summary", "")),
		String(report.get("next_action", "")),
	]
	if int(validation.get("error_count", 0)) > 0:
		label.modulate = Color(1.0, 0.45, 0.35)
	elif int(validation.get("warning_count", 0)) > 0:
		label.modulate = Color(1.0, 0.75, 0.25)
	else:
		label.modulate = Color(0.55, 0.9, 0.65)


# --- 信号处理函数 ---

func _on_validate_pressed(summary_label: Label, graph: Resource) -> void:
	_update_summary(summary_label, graph)


func _on_start_node_selected(index: int, option: OptionButton, graph: Resource) -> void:
	if graph == null:
		return

	var node_id := option.get_item_metadata(index) as StringName
	_set_start_node(graph, node_id)

