## GFConsoleUtility: 运行时开发者控制台。
##
## 提供命令注册、解析与执行能力，并在初始化时构建覆盖全屏的调试 GUI。
## 默认通过快捷键呼出，同时会消费 `GFLogUtility` 的日志信号进行彩色输出。
class_name GFConsoleUtility
extends GFUtility


# --- 公共变量 ---

## 呼出或隐藏控制台的快捷键；默认为 `KEY_F1`。
var toggle_key: Key = KEY_F1


# --- 私有变量 ---

## 已注册命令表。
var _commands: Dictionary = {}

## 控制台 GUI 实例。
var _console_gui: _GFConsoleGUI

## 当前已连接的日志工具。
var _connected_log_util: GFLogUtility = null


# --- Godot 生命周期方法 ---

func init() -> void:
	register_command("help", _cmd_help, "显示所有可用指令。")
	register_command("clear", _cmd_clear, "清空控制台输出。")

	_console_gui = _GFConsoleGUI.new()
	_console_gui.name = "GFConsoleOverlay"
	_console_gui.toggle_key = toggle_key
	_console_gui.command_submitted.connect(_on_command_submitted)

	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.root.call_deferred("add_child", _console_gui)


func ready() -> void:
	var log_util := get_utility(GFLogUtility) as GFLogUtility
	if log_util == null or not log_util.has_signal("log_emitted"):
		return

	if _connected_log_util != null and _connected_log_util != log_util:
		if _connected_log_util.log_emitted.is_connected(_on_log_emitted):
			_connected_log_util.log_emitted.disconnect(_on_log_emitted)

	if not log_util.log_emitted.is_connected(_on_log_emitted):
		log_util.log_emitted.connect(_on_log_emitted)

	_connected_log_util = log_util


func dispose() -> void:
	if _connected_log_util != null and _connected_log_util.log_emitted.is_connected(_on_log_emitted):
		_connected_log_util.log_emitted.disconnect(_on_log_emitted)

	_connected_log_util = null

	if is_instance_valid(_console_gui):
		_console_gui.queue_free()

	_console_gui = null


# --- 公共方法 ---

## 注册控制台命令。
## @param cmd_name: 指令名称。
## @param callback: 指令回调，签名为 `func(args: PackedStringArray) -> void`。
## @param description: 指令说明文本。
func register_command(cmd_name: String, callback: Callable, description: String) -> void:
	_commands[cmd_name] = {
		"callback": callback,
		"description": description,
	}


## 注销控制台命令。
## @param cmd_name: 指令名称。
func unregister_command(cmd_name: String) -> void:
	_commands.erase(cmd_name)


## 解析并执行一条原始输入。
## @param raw_input: 用户输入的完整字符串。
## @return 找到并成功执行命令时返回 `true`。
func execute_command(raw_input: String) -> bool:
	var trimmed := raw_input.strip_edges()
	if trimmed.is_empty():
		return false

	var parts := trimmed.split(" ", false)
	var cmd_name: String = parts[0]
	var args := PackedStringArray()
	for i in range(1, parts.size()):
		args.append(parts[i])

	if not _commands.has(cmd_name):
		if is_instance_valid(_console_gui):
			_console_gui.append_text("[color=red]未知指令：%s。输入 'help' 查看帮助。[/color]" % cmd_name)
		return false

	var entry: Dictionary = _commands[cmd_name]
	var cb: Callable = entry["callback"]
	cb.call(args)
	return true


# --- 私有/辅助方法 ---

func _cmd_help(_args: PackedStringArray) -> void:
	if not is_instance_valid(_console_gui):
		return

	_console_gui.append_text("[color=cyan]--- 可用指令 ---[/color]")
	for cmd_name: String in _commands:
		var entry: Dictionary = _commands[cmd_name]
		var desc: String = entry["description"]
		_console_gui.append_text("  [color=white]%s[/color] - %s" % [cmd_name, desc])
	_console_gui.append_text("[color=cyan]----------------[/color]")


func _cmd_clear(_args: PackedStringArray) -> void:
	if is_instance_valid(_console_gui):
		_console_gui.clear_output()


func _on_command_submitted(raw_input: String) -> void:
	if is_instance_valid(_console_gui):
		_console_gui.append_text("[color=gray]> %s[/color]" % raw_input)

	execute_command(raw_input)


func _on_log_emitted(level: int, tag: String, message: String) -> void:
	if not is_instance_valid(_console_gui):
		return

	if _console_gui.is_tag_ignored(tag):
		return

	var color: String
	match level:
		0:
			color = "cyan"
		2:
			color = "yellow"
		3, 4:
			color = "red"
		_:
			color = "white"

	var level_names: PackedStringArray = PackedStringArray(["DEBUG", "INFO", "WARN", "ERROR", "FATAL"])
	var level_str: String = level_names[level] if level < level_names.size() else "UNKNOWN"
	_console_gui.append_text("[color=%s][%s][%s] %s[/color]" % [color, level_str, tag, message])


# --- 内部类 ---

class _GFConsoleGUI extends CanvasLayer:
	# --- 信号 ---

	signal command_submitted(raw_input: String)


	# --- 公共变量 ---

	var toggle_key: Key


	# --- 私有变量 ---

	var _output: RichTextLabel
	var _input_field: LineEdit
	var _filter_input: LineEdit
	var _ignored_tags: PackedStringArray = PackedStringArray()


	# --- Godot 生命周期方法 ---

	func _init() -> void:
		layer = 150
		visible = false
		process_mode = Node.PROCESS_MODE_ALWAYS

		var panel := PanelContainer.new()
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.05, 0.05, 0.1, 0.85)
		panel.add_theme_stylebox_override("panel", style)
		add_child(panel)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		panel.add_child(margin)

		var vbox := VBoxContainer.new()
		margin.add_child(vbox)

		var header_hbox := HBoxContainer.new()
		vbox.add_child(header_hbox)

		var header := Label.new()
		header.text = "[ GF Developer Console ]"
		header.modulate = Color(0.4, 0.8, 1.0)
		header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header_hbox.add_child(header)

		var filter_label := Label.new()
		filter_label.text = "过滤标签: "
		filter_label.modulate = Color(0.8, 0.8, 0.8)
		header_hbox.add_child(filter_label)

		_filter_input = LineEdit.new()
		_filter_input.placeholder_text = "逗号分隔 (如 sys,net)"
		_filter_input.custom_minimum_size = Vector2(200, 0)
		_filter_input.text_changed.connect(_on_filter_changed)
		header_hbox.add_child(_filter_input)

		_output = RichTextLabel.new()
		_output.bbcode_enabled = true
		_output.scroll_following = true
		_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_output.selection_enabled = true
		vbox.add_child(_output)

		_input_field = LineEdit.new()
		_input_field.placeholder_text = "输入指令..."
		_input_field.clear_button_enabled = true
		_input_field.text_submitted.connect(_on_input_submitted)
		vbox.add_child(_input_field)


	func _input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == toggle_key:
				visible = not visible
				if visible:
					_input_field.call_deferred("grab_focus")
				get_viewport().set_input_as_handled()


	# --- 公共方法 ---

	func append_text(bbcode_line: String) -> void:
		_output.append_text(bbcode_line + "\n")


	func clear_output() -> void:
		_output.clear()


	func is_tag_ignored(tag: String) -> bool:
		if _ignored_tags.is_empty():
			return false

		return _ignored_tags.has(tag)


	# --- 信号处理函数 ---

	func _on_input_submitted(text: String) -> void:
		if text.strip_edges().is_empty():
			return

		command_submitted.emit(text)
		_input_field.clear()


	func _on_filter_changed(text: String) -> void:
		if text.is_empty():
			_ignored_tags.clear()
		else:
			_ignored_tags = text.replace(" ", "").split(",", false)
