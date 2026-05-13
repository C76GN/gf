@tool

## GFSignalGraphDock: 当前场景信号连接与运行事件查看面板。
##
## 基于 GFSceneSignalAudit 渲染编辑器中保存的信号连接，并可显式开启
## GFSignalRuntimeProbe 观察当前场景信号发射。面板只读，不修改场景。
class_name GFSignalGraphDock
extends Control


# --- 常量 ---

const _MAX_EVENT_COUNT: int = 300
const _MAX_DISPLAY_ARGUMENT_LENGTH: int = 120
const GFSignalRuntimeProbeBase = preload("res://addons/gf/standard/utilities/debug/gf_signal_runtime_probe.gd")


# --- 私有变量 ---

var _root_ref: WeakRef = null
var _last_graph: Dictionary = {}
var _last_events: Array[Dictionary] = []
var _probe: GFSignalRuntimeProbeBase = null
var _persistent_only_check: CheckBox = null
var _include_empty_check: CheckBox = null
var _live_check: CheckBox = null
var _details_toggle: CheckBox = null
var _filter_edit: LineEdit = null
var _summary_label: Label = null
var _hint_label: Label = null
var _empty_state_label: Label = null
var _event_empty_state_label: Label = null
var _tabs: TabContainer = null
var _tree: Tree = null
var _event_tree: Tree = null
var _clear_events_button: Button = null
var _details: TextEdit = null


# --- Godot 生命周期方法 ---

func _ready() -> void:
	name = "GF Signal Graph"
	_build_ui()
	call_deferred("_refresh_deferred")


func _exit_tree() -> void:
	_stop_live_probe()


# --- 公共方法 ---

## 设置要查看的根节点。
## @param root: 根节点；为空时刷新时会尝试使用当前编辑场景根节点。
func set_graph_source(root: Node) -> void:
	_root_ref = weakref(root) if root != null else null
	refresh(root)


## 刷新信号图。
## @param root: 可选根节点；为空时使用 set_graph_source() 或当前编辑场景根节点。
func refresh(root: Node = null) -> void:
	_build_ui()
	var target_root := root if root != null else _resolve_root()
	if target_root == null:
		_last_graph = {
			"ok": false,
			"message": "没有可用的场景根节点。",
		}
		_render_graph()
		_restart_live_probe_if_enabled()
		return

	_root_ref = weakref(target_root)
	_last_graph = GFSceneSignalAudit.build_signal_graph(target_root, {
		"persistent_only": _persistent_only_check.button_pressed,
		"include_empty_signals": _include_empty_check.button_pressed,
		"include_external_targets": false,
	})
	_render_graph()
	_restart_live_probe_if_enabled()


## 获取最近一次信号图快照。
## @return 信号图字典副本。
func get_last_graph() -> Dictionary:
	return _last_graph.duplicate(true)


## 获取最近运行事件。
## @return 运行事件副本。
func get_recent_events() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event: Dictionary in _last_events:
		result.append(event.duplicate(true))
	return result


# --- 私有/辅助方法 ---

func _build_ui() -> void:
	if _tree != null:
		return

	clip_contents = true
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var root_box := VBoxContainer.new()
	root_box.clip_contents = true
	root_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(root_box)
	root_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var toolbar := HBoxContainer.new()
	root_box.add_child(toolbar)

	var refresh_button := Button.new()
	refresh_button.text = "刷新"
	refresh_button.pressed.connect(refresh)
	toolbar.add_child(refresh_button)

	_persistent_only_check = CheckBox.new()
	_persistent_only_check.text = "持久连接"
	_persistent_only_check.button_pressed = true
	_persistent_only_check.toggled.connect(_on_option_toggled)
	toolbar.add_child(_persistent_only_check)

	_include_empty_check = CheckBox.new()
	_include_empty_check.text = "空信号"
	_include_empty_check.toggled.connect(_on_option_toggled)
	toolbar.add_child(_include_empty_check)

	_live_check = CheckBox.new()
	_live_check.text = "实时追踪"
	_live_check.toggled.connect(_on_live_toggled)
	toolbar.add_child(_live_check)

	_clear_events_button = Button.new()
	_clear_events_button.text = "清空事件"
	_clear_events_button.disabled = true
	_clear_events_button.pressed.connect(_on_clear_events_pressed)
	toolbar.add_child(_clear_events_button)

	_filter_edit = LineEdit.new()
	_filter_edit.placeholder_text = "筛选节点、信号或方法"
	_filter_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_filter_edit.text_changed.connect(_on_filter_text_changed)
	toolbar.add_child(_filter_edit)

	_details_toggle = CheckBox.new()
	_details_toggle.text = "详情"
	_details_toggle.toggled.connect(_on_details_toggled)
	toolbar.add_child(_details_toggle)

	_summary_label = Label.new()
	_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_box.add_child(_summary_label)

	_hint_label = Label.new()
	_hint_label.text = "连接=场景中保存的信号连接；运行事件=开启“实时追踪”后的实际发射。只读。"
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root_box.add_child(_hint_label)

	_tabs = TabContainer.new()
	_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_box.add_child(_tabs)

	var connection_page := VBoxContainer.new()
	connection_page.name = "连接"
	connection_page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	connection_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tabs.add_child(connection_page)

	_empty_state_label = Label.new()
	_empty_state_label.text = "打开一个场景，或在场景树中选中节点后点击刷新。"
	_empty_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_empty_state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_empty_state_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_empty_state_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_empty_state_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	connection_page.add_child(_empty_state_label)

	_tree = _make_tree(["来源", "信号", "目标", "方法"])
	_tree.item_selected.connect(_on_tree_item_selected)
	connection_page.add_child(_tree)

	var event_page := VBoxContainer.new()
	event_page.name = "运行事件"
	event_page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	event_page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tabs.add_child(event_page)

	_event_empty_state_label = Label.new()
	_event_empty_state_label.text = "开启“实时追踪”后，这里会显示当前场景实际发射的信号。"
	_event_empty_state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_event_empty_state_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_event_empty_state_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	event_page.add_child(_event_empty_state_label)

	_event_tree = _make_tree(["时间", "来源", "信号", "参数"])
	_event_tree.item_selected.connect(_on_event_tree_item_selected)
	event_page.add_child(_event_tree)

	_details = TextEdit.new()
	_details.editable = false
	_details.visible = false
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	root_box.add_child(_details)


func _make_tree(titles: Array[String]) -> Tree:
	var tree := Tree.new()
	tree.columns = titles.size()
	tree.hide_root = true
	tree.column_titles_visible = true
	for i: int in range(titles.size()):
		tree.set_column_title(i, titles[i])
		tree.set_column_expand(i, i != 1)
	tree.set_column_custom_minimum_width(1, 130)
	tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return tree


func _resolve_root() -> Node:
	if _root_ref != null:
		var existing := _root_ref.get_ref() as Node
		if existing != null:
			return existing

	if Engine.is_editor_hint():
		var edited_root := EditorInterface.get_edited_scene_root()
		if edited_root != null:
			return edited_root
		return _resolve_selected_scene_node()

	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.current_scene if tree.current_scene != null else tree.root


func _render_graph() -> void:
	if _tree == null:
		return

	_tree.clear()
	if not bool(_last_graph.get("ok", false)):
		_summary_label.text = String(_last_graph.get("message", "Signal graph unavailable."))
		_tree.visible = false
		_empty_state_label.visible = true
		_empty_state_label.text = "打开一个场景，或在场景树中选中节点后点击刷新。"
		_details.text = _summary_label.text
		_render_events()
		return

	var connection_total := int(_last_graph.get("connection_count", 0))
	var signal_total := int(_last_graph.get("signal_count", 0))
	_summary_label.text = "Nodes: %d  Signals: %d  Connections: %d  Runtime Events: %d" % [
		int(_last_graph.get("node_count", 0)),
		signal_total,
		connection_total,
		_last_events.size(),
	]
	_details.text = "选中一条连接、信号或运行事件后查看详情。"

	if connection_total == 0 and signal_total == 0:
		_tree.visible = false
		_empty_state_label.visible = true
		_empty_state_label.text = "当前场景没有可显示的持久信号连接。连接节点信号后点击刷新；或勾选“空信号”查看节点声明的信号。"
		_render_events()
		return

	var root_item := _tree.create_item()
	var visible_count := 0
	for connection_variant: Variant in _last_graph.get("connections", []):
		var connection := connection_variant as Dictionary
		if connection == null or not _matches_filter(connection):
			continue
		var item := _tree.create_item(root_item)
		item.set_text(0, String(connection.get("source_node_path", "")))
		item.set_text(1, String(connection.get("signal_name", "")))
		item.set_text(2, String(connection.get("target_node_path", "")))
		item.set_text(3, String(connection.get("method_name", "")))
		item.set_metadata(0, connection.duplicate(true))
		visible_count += 1

	if connection_total == 0:
		for signal_variant: Variant in _last_graph.get("signals", []):
			var signal_entry := signal_variant as Dictionary
			if signal_entry == null or not _matches_filter(signal_entry):
				continue
			var signal_item := _tree.create_item(root_item)
			signal_item.set_text(0, String(signal_entry.get("node_path", "")))
			signal_item.set_text(1, String(signal_entry.get("signal_name", "")))
			signal_item.set_text(2, "-")
			signal_item.set_text(3, "-")
			signal_item.set_metadata(0, signal_entry.duplicate(true))
			visible_count += 1

	_tree.visible = visible_count > 0
	_empty_state_label.visible = visible_count == 0
	if visible_count == 0:
		_empty_state_label.text = "没有匹配当前筛选条件的信号连接。"
	_render_events()


func _render_events() -> void:
	if _event_tree == null:
		return

	_event_tree.clear()
	_clear_events_button.disabled = _last_events.is_empty()
	var root_item := _event_tree.create_item()
	var visible_count := 0
	for i: int in range(_last_events.size() - 1, -1, -1):
		var event := _last_events[i]
		if not _matches_filter(event):
			continue
		var item := _event_tree.create_item(root_item)
		item.set_text(0, str(event.get("timestamp_msec", 0)))
		item.set_text(1, String(event.get("source_node_path", "")))
		item.set_text(2, String(event.get("signal_name", "")))
		item.set_text(3, _format_arguments(event.get("arguments", [])))
		item.set_metadata(0, event.duplicate(true))
		visible_count += 1

	_event_tree.visible = visible_count > 0
	_event_empty_state_label.visible = visible_count == 0
	if visible_count == 0:
		_event_empty_state_label.text = "没有匹配当前筛选条件的运行事件。" if not _last_events.is_empty() else "开启“实时追踪”后，这里会显示当前场景实际发射的信号。"


func _resolve_selected_scene_node() -> Node:
	if not Engine.is_editor_hint():
		return null

	var selection := EditorInterface.get_selection()
	if selection == null:
		return null

	var selected_nodes := selection.get_selected_nodes()
	if selected_nodes.is_empty():
		return null

	var node := selected_nodes[0] as Node
	if node == null:
		return null
	while node.owner != null:
		node = node.owner
	return node


func _restart_live_probe_if_enabled() -> void:
	if _live_check == null or not _live_check.button_pressed:
		return
	_start_live_probe()


func _start_live_probe() -> void:
	_stop_live_probe()
	var target_root := _resolve_root()
	if target_root == null:
		return

	_probe = GFSignalRuntimeProbeBase.new()
	_probe.max_events = _MAX_EVENT_COUNT
	_probe.signal_emitted.connect(_on_probe_signal_emitted)
	_probe.watch_tree(target_root, {
		"recursive": true,
		"include_internal": false,
		"max_argument_count": 8,
	})


func _stop_live_probe() -> void:
	if _probe == null:
		return
	if _probe.signal_emitted.is_connected(_on_probe_signal_emitted):
		_probe.signal_emitted.disconnect(_on_probe_signal_emitted)
	_probe.unwatch_all()
	_probe = null


func _matches_filter(entry: Dictionary) -> bool:
	if _filter_edit == null or _filter_edit.text.strip_edges().is_empty():
		return true

	var needle := _filter_edit.text.strip_edges().to_lower()
	for value: Variant in entry.values():
		if str(value).to_lower().contains(needle):
			return true
	return false


func _format_arguments(arguments: Variant) -> String:
	if not arguments is Array:
		return ""

	var parts := PackedStringArray()
	for argument: Variant in arguments:
		var text := str(argument)
		if text.length() > _MAX_DISPLAY_ARGUMENT_LENGTH:
			text = text.substr(0, _MAX_DISPLAY_ARGUMENT_LENGTH) + "..."
		parts.append(text)
	return ", ".join(parts)


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
		var string_array: Array[String] = []
		for item: String in value:
			string_array.append(item)
		return string_array
	if value is Object:
		return str(value)
	return value


func _refresh_deferred() -> void:
	refresh()


# --- 信号处理函数 ---

func _on_option_toggled(_pressed: bool) -> void:
	refresh()


func _on_live_toggled(pressed: bool) -> void:
	if pressed:
		_start_live_probe()
	else:
		_stop_live_probe()
	_render_events()


func _on_clear_events_pressed() -> void:
	_last_events.clear()
	if _probe != null:
		_probe.clear_events()
	_render_graph()


func _on_filter_text_changed(_text: String) -> void:
	_render_graph()


func _on_details_toggled(pressed: bool) -> void:
	_details.visible = pressed


func _on_tree_item_selected() -> void:
	var item := _tree.get_selected()
	if item == null:
		return

	var metadata := item.get_metadata(0)
	if metadata is Dictionary:
		_details.text = _safe_json(metadata)


func _on_event_tree_item_selected() -> void:
	var item := _event_tree.get_selected()
	if item == null:
		return

	var metadata := item.get_metadata(0)
	if metadata is Dictionary:
		_details.text = _safe_json(metadata)


func _on_probe_signal_emitted(event: Dictionary) -> void:
	_last_events.append(event.duplicate(true))
	while _last_events.size() > _MAX_EVENT_COUNT:
		_last_events.pop_front()
	_render_graph()
