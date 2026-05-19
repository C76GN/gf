## GFModalPanel: GF 默认通用 modal 面板。
##
## 该面板按 GFModalConfig 渲染标题、正文和动作按钮，并通过 resolved 信号返回 GFModalResult。
## 项目可以替换为自己的面板，只需复用同一配置和结果协议。
class_name GFModalPanel
extends Control


# --- 信号 ---

## modal 产生关闭结果后发出。
## @param result: 交互结果。
signal resolved(result: GFModalResult)

## 不关闭 modal 的动作被按下时发出。
## @param action_id: 动作 ID。
signal action_pressed(action_id: StringName)


# --- 私有变量 ---

var _config: GFModalConfig = null
var _context: Dictionary = {}
var _actions_by_id: Dictionary = {}
var _backdrop: ColorRect = null
var _panel: PanelContainer = null
var _title_label: Label = null
var _message_label: RichTextLabel = null
var _actions_box: HBoxContainer = null
var _built: bool = false
var _resolved: bool = false


# --- Godot 生命周期方法 ---

func _ready() -> void:
	_ensure_built()
	_render()


# --- 公共方法 ---

## 使用配置和上下文刷新面板。
## @param config: modal 配置；为空时使用默认配置。
## @param context: 调用上下文，会透传到 GFModalResult。
func configure(config: GFModalConfig, context: Dictionary = {}) -> void:
	_config = config.duplicate_config() if config != null else GFModalConfig.new()
	_context = context.duplicate(true)
	_resolved = false
	_render()


## 获取当前配置副本。
## @return modal 配置。
func get_config() -> GFModalConfig:
	return _config.duplicate_config() if _config != null else GFModalConfig.new()


## 获取调用上下文副本。
## @return 上下文字典。
func get_context() -> Dictionary:
	return _context.duplicate(true)


## 按动作 ID 解析 modal。
## @param action_id: 动作 ID。
## @return 找到动作并发出结果时返回 true。
func resolve_action(action_id: StringName) -> bool:
	if _resolved:
		return false

	var action := _actions_by_id.get(action_id) as GFModalAction
	if action == null:
		return false

	_resolved = true
	resolved.emit(action.make_result(_context))
	return true


## 按取消状态解析 modal。
## @return 成功发出结果时返回 true。
func resolve_cancel() -> bool:
	if _resolved:
		return false

	_resolved = true
	resolved.emit(GFModalResult.create(
		GFModalResult.STATUS_CANCELLED,
		&"cancel",
		null,
		_config.metadata if _config != null else {},
		_context
	))
	return true


# --- 私有/辅助方法 ---

func _ensure_built() -> void:
	if _built:
		return

	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	_backdrop = ColorRect.new()
	_backdrop.name = "Backdrop"
	_backdrop.color = Color(0.0, 0.0, 0.0, 0.45)
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_backdrop.gui_input.connect(_on_backdrop_gui_input)
	add_child(_backdrop)

	var center := CenterContainer.new()
	center.name = "Center"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.custom_minimum_size = Vector2(360.0, 0.0)
	center.add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_title_label)

	_message_label = RichTextLabel.new()
	_message_label.name = "Message"
	_message_label.bbcode_enabled = false
	_message_label.fit_content = true
	_message_label.scroll_active = false
	_message_label.selection_enabled = true
	_message_label.custom_minimum_size = Vector2(320.0, 0.0)
	box.add_child(_message_label)

	_actions_box = HBoxContainer.new()
	_actions_box.name = "Actions"
	_actions_box.alignment = BoxContainer.ALIGNMENT_END
	_actions_box.add_theme_constant_override("separation", 8)
	box.add_child(_actions_box)

	_built = true


func _render() -> void:
	if not is_inside_tree() and not _built:
		return
	_ensure_built()
	if _config == null:
		_config = GFModalConfig.new()

	_title_label.visible = not _config.title.is_empty()
	_title_label.text = _config.title
	_message_label.visible = not _config.message.is_empty()
	_message_label.text = _config.message

	for child: Node in _actions_box.get_children():
		_actions_box.remove_child(child)
		child.queue_free()
	_actions_by_id.clear()

	var first_focus_button: Button = null
	for action: GFModalAction in _config.get_actions_or_default():
		_actions_by_id[action.action_id] = action
		var button := _make_action_button(action)
		_actions_box.add_child(button)
		if first_focus_button == null or action.grab_focus:
			first_focus_button = button

	if _config.auto_focus and first_focus_button != null:
		call_deferred("_grab_focus_if_inside_tree", first_focus_button)


func _grab_focus_if_inside_tree(control: Control) -> void:
	if (
		is_instance_valid(control)
		and control.is_inside_tree()
		and control.visible
		and control.focus_mode != Control.FOCUS_NONE
		and not control.is_queued_for_deletion()
	):
		control.grab_focus()


func _make_action_button(action: GFModalAction) -> Button:
	var button := Button.new()
	button.text = action.label
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(_on_action_button_pressed.bind(action.action_id))
	return button


# --- 信号处理函数 ---

func _on_action_button_pressed(action_id: StringName) -> void:
	var action := _actions_by_id.get(action_id) as GFModalAction
	if action == null:
		return
	if not action.close_on_pressed:
		action_pressed.emit(action_id)
		return
	resolve_action(action_id)


func _on_backdrop_gui_input(event: InputEvent) -> void:
	if _config == null or not _config.dismiss_on_backdrop:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		resolve_cancel()
