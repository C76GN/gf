@tool

## GF Node State Machine Inspector: 在 Inspector 中辅助配置节点状态机。
extends EditorInspectorPlugin


# --- 常量 ---

const GF_NODE_STATE_BASE := preload("res://addons/gf/extensions/state_machine/gf_node_state.gd")
const GF_NODE_STATE_MACHINE_BASE := preload("res://addons/gf/extensions/state_machine/gf_node_state_machine.gd")


# --- 公共方法 ---

func _can_handle(object: Object) -> bool:
	return object is GF_NODE_STATE_MACHINE_BASE


func _parse_begin(object: Object) -> void:
	var target := object as Node
	if target == null:
		return

	var root := VBoxContainer.new()
	root.name = "GFNodeStateMachineInspector"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_custom_control(root)

	var header := Label.new()
	header.text = "GF Node State Machine"
	header.modulate = Color(0.4, 0.8, 1.0)
	root.add_child(header)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(row)

	var label := Label.new()
	label.text = "初始状态"
	label.custom_minimum_size = Vector2(86, 0)
	row.add_child(label)

	var option := OptionButton.new()
	option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option.tooltip_text = "从直接子 GFNodeState 中选择内部状态组初始状态"
	row.add_child(option)
	_populate_initial_state_options(option, target)
	option.item_selected.connect(_on_initial_state_selected.bind(option, target), CONNECT_DEFERRED)


# --- 私有/辅助方法 ---

func _populate_initial_state_options(option: OptionButton, target: Node) -> void:
	option.clear()

	var current_initial_state := _get_initial_state(target)
	option.add_item("未设置", 0)
	option.set_item_metadata(0, &"")
	option.select(0)

	var states := _collect_direct_states(target)
	for i: int in range(states.size()):
		var state_name := states[i]
		option.add_item(String(state_name), i + 1)
		option.set_item_metadata(i + 1, state_name)
		if state_name == current_initial_state:
			option.select(i + 1)

	if current_initial_state != &"" and not states.has(current_initial_state):
		var index := option.get_item_count()
		option.add_item("%s（未找到）" % current_initial_state, index)
		option.set_item_metadata(index, current_initial_state)
		option.select(index)


func _collect_direct_states(target: Node) -> Array[StringName]:
	var result: Array[StringName] = []
	for child: Node in target.get_children():
		if child is GF_NODE_STATE_BASE:
			result.append(child.call("get_state_name") as StringName)
	result.sort()
	return result


func _get_initial_state(target: Node) -> StringName:
	var config := target.get("config") as Resource
	if config != null and "initial_state" in config:
		return config.get("initial_state") as StringName
	return target.get("initial_state") as StringName


func _set_initial_state(target: Node, state_name: StringName) -> void:
	var property_owner: Object = target
	var property_name: StringName = &"initial_state"
	var config := target.get("config") as Resource
	if config != null and "initial_state" in config:
		property_owner = config

	var old_value := property_owner.get(property_name) as StringName
	if old_value == state_name:
		return

	var undo_redo := EditorInterface.get_editor_undo_redo()
	undo_redo.create_action("设置 GF 初始状态")
	undo_redo.add_do_property(property_owner, property_name, state_name)
	undo_redo.add_undo_property(property_owner, property_name, old_value)
	undo_redo.commit_action()


# --- 信号处理函数 ---

func _on_initial_state_selected(index: int, option: OptionButton, target: Node) -> void:
	if not is_instance_valid(target):
		return

	var state_name := option.get_item_metadata(index) as StringName
	_set_initial_state(target, state_name)
