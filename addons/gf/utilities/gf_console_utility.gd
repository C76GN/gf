## GFConsoleUtility: 运行时开发者控制台。
##
## 提供命令注册、解析与执行能力，并在初始化时构建覆盖全屏的调试 GUI。
## 默认通过快捷键呼出，同时会消费 `GFLogUtility` 的日志信号进行彩色输出。
class_name GFConsoleUtility
extends GFUtility


# --- 常量 ---

const GFConsoleCommandDefinitionBase = preload("res://addons/gf/utilities/gf_console_command_definition.gd")


# --- 公共变量 ---

## 呼出或隐藏控制台的快捷键；默认为 `KEY_F1`。
var toggle_key: Key = KEY_F1

## 控制台最多保留的输出行数，避免高频日志无限增长。
var max_output_lines: int = 1000:
	set(value):
		max_output_lines = maxi(value, 1)
		if is_instance_valid(_console_gui):
			_console_gui.max_output_lines = max_output_lines

## 控制台背景透明度，范围 0 到 1。
var background_alpha: float = 0.85:
	set(value):
		background_alpha = clampf(value, 0.0, 1.0)
		if is_instance_valid(_console_gui):
			_console_gui.background_alpha = background_alpha

## 是否使用可拖拽、可缩放的窗口模式。默认 false 保持全屏覆盖。
var windowed: bool = false:
	set(value):
		windowed = value
		if is_instance_valid(_console_gui):
			_console_gui.windowed = windowed

## 窗口模式初始尺寸相对视口比例。
var initial_window_size_ratio: Vector2 = Vector2(0.72, 0.55):
	set(value):
		initial_window_size_ratio = Vector2(
			clampf(value.x, 0.2, 1.0),
			clampf(value.y, 0.2, 1.0)
		)
		if is_instance_valid(_console_gui):
			_console_gui.initial_window_size_ratio = initial_window_size_ratio

## 窗口模式最小尺寸。
var minimum_window_size: Vector2 = Vector2(360.0, 220.0):
	set(value):
		minimum_window_size = Vector2(maxf(value.x, 120.0), maxf(value.y, 80.0))
		if is_instance_valid(_console_gui):
			_console_gui.minimum_window_size = minimum_window_size

## 是否把控制台放在较高 CanvasLayer 层级。
var keep_topmost: bool = true:
	set(value):
		keep_topmost = value
		if is_instance_valid(_console_gui):
			_console_gui.keep_topmost = keep_topmost

## 是否只在 debug 构建中创建控制台 GUI。
var debug_only: bool = false


# --- 私有变量 ---

## 已注册命令表。
var _commands: Dictionary = {}

## 控制台 GUI 实例。
var _console_gui: _GFConsoleGUI

## 当前已连接的日志工具。
var _connected_log_util: GFLogUtility = null


# --- Godot 生命周期方法 ---

func init() -> void:
	if debug_only and not OS.is_debug_build():
		return

	register_command("help", _cmd_help, "显示所有可用指令。")
	register_command("clear", _cmd_clear, "清空控制台输出。")

	_console_gui = _GFConsoleGUI.new()
	_console_gui.name = "GFConsoleOverlay"
	_console_gui.toggle_key = toggle_key
	_console_gui.max_output_lines = max_output_lines
	_console_gui.background_alpha = background_alpha
	_console_gui.windowed = windowed
	_console_gui.initial_window_size_ratio = initial_window_size_ratio
	_console_gui.minimum_window_size = minimum_window_size
	_console_gui.keep_topmost = keep_topmost
	_console_gui.command_name_provider = Callable(self, "get_command_names")
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
## @param metadata: 项目自定义元数据。
func register_command(cmd_name: String, callback: Callable, description: String, metadata: Dictionary = {}) -> void:
	_commands[cmd_name] = {
		"callback": callback,
		"description": description,
		"metadata": metadata.duplicate(true),
	}


## 注册资源化控制台命令。
## @param definition: 命令资源定义。
## @param callback: 指令回调，签名为 `func(args: PackedStringArray) -> void`。
func register_command_definition(definition: GFConsoleCommandDefinitionBase, callback: Callable) -> void:
	if definition == null or not callback.is_valid():
		return

	for cmd_name: String in definition.get_all_names():
		register_command(cmd_name, callback, definition.description, {
			"definition": definition,
			"primary_command_name": definition.command_name,
		})


## 注销控制台命令。
## @param cmd_name: 指令名称。
func unregister_command(cmd_name: String) -> void:
	_commands.erase(cmd_name)


## 获取当前已注册命令名称。
## @return 排序后的命令名称数组。
func get_command_names() -> PackedStringArray:
	var names := PackedStringArray()
	for cmd_name: String in _commands.keys():
		names.append(cmd_name)
	names.sort()
	return names


## 根据前缀获取命令补全候选。
## @param prefix: 命令名前缀。
## @return 排序后的候选命令名数组。
func suggest_commands(prefix: String) -> PackedStringArray:
	var suggestions := PackedStringArray()
	for cmd_name: String in get_command_names():
		if prefix.is_empty() or cmd_name.begins_with(prefix):
			suggestions.append(cmd_name)
	return suggestions


## 根据字符串相似度获取可能的命令名，用于未知命令诊断。
## @param cmd_name: 用户输入的命令名。
## @param limit: 最多返回的候选数量。
## @param threshold: 最低相似度，范围 0 到 1。
## @return 按相似度降序排列的候选命令名。
func suggest_similar_commands(cmd_name: String, limit: int = 3, threshold: float = 0.5) -> PackedStringArray:
	if cmd_name.is_empty() or _commands.is_empty() or limit <= 0:
		return PackedStringArray()

	var scored: Array = []
	for registered_name: String in _commands.keys():
		var score := cmd_name.similarity(registered_name)
		if score >= threshold:
			scored.append([score, registered_name])
	scored.sort_custom(func(a: Array, b: Array) -> bool:
		return float(a[0]) > float(b[0])
	)

	var suggestions := PackedStringArray()
	var result_count := mini(limit, scored.size())
	for index: int in range(result_count):
		suggestions.append(String(scored[index][1]))
	return suggestions


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
			var similar_commands := suggest_similar_commands(cmd_name)
			if similar_commands.is_empty():
				_console_gui.append_text("[color=red]未知指令：%s。输入 'help' 查看帮助。[/color]" % cmd_name)
			else:
				_console_gui.append_text(
					"[color=red]未知指令：%s。你是不是想输入：%s？[/color]" % [
						cmd_name,
						", ".join(similar_commands),
					]
				)
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


	# --- 常量 ---

	const _DEFAULT_LAYER: int = 1
	const _TOPMOST_LAYER: int = 150
	const _WINDOW_MARGIN: float = 16.0
	const _RESIZE_HANDLE_SIZE: float = 18.0


	# --- 公共变量 ---

	var toggle_key: Key
	var command_name_provider: Callable

	var max_output_lines: int = 1000:
		set(value):
			max_output_lines = maxi(value, 1)
			_trim_output_lines()
			if is_instance_valid(_output):
				_render_output()

	var background_alpha: float = 0.85:
		set(value):
			background_alpha = clampf(value, 0.0, 1.0)
			_apply_background_alpha()

	var windowed: bool = false:
		set(value):
			windowed = value
			_layout_console()

	var initial_window_size_ratio: Vector2 = Vector2(0.72, 0.55):
		set(value):
			initial_window_size_ratio = Vector2(
				clampf(value.x, 0.2, 1.0),
				clampf(value.y, 0.2, 1.0)
			)
			_window_layout_initialized = false
			_layout_console()

	var minimum_window_size: Vector2 = Vector2(360.0, 220.0):
		set(value):
			minimum_window_size = Vector2(maxf(value.x, 120.0), maxf(value.y, 80.0))
			_layout_console()

	var keep_topmost: bool = true:
		set(value):
			keep_topmost = value
			_apply_layer()


	# --- 私有变量 ---

	var _panel: PanelContainer
	var _panel_style: StyleBoxFlat
	var _output: RichTextLabel
	var _input_field: LineEdit
	var _filter_input: LineEdit
	var _resize_handle: Panel
	var _ignored_tags: PackedStringArray = PackedStringArray()
	var _output_lines: PackedStringArray = PackedStringArray()
	var _pending_lines: PackedStringArray = PackedStringArray()
	var _flush_queued: bool = false
	var _command_history: PackedStringArray = PackedStringArray()
	var _history_index: int = -1
	var _window_layout_initialized: bool = false
	var _dragging: bool = false
	var _resizing: bool = false
	var _drag_offset: Vector2 = Vector2.ZERO
	var _resize_origin_mouse: Vector2 = Vector2.ZERO
	var _resize_origin_size: Vector2 = Vector2.ZERO


	# --- Godot 生命周期方法 ---

	func _init() -> void:
		_apply_layer()
		visible = false
		process_mode = Node.PROCESS_MODE_ALWAYS

		_panel = PanelContainer.new()
		_panel.name = "Panel"
		_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		add_child(_panel)

		_panel_style = StyleBoxFlat.new()
		_panel_style.bg_color = Color(0.05, 0.05, 0.1, background_alpha)
		_panel.add_theme_stylebox_override("panel", _panel_style)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		_panel.add_child(margin)

		var vbox := VBoxContainer.new()
		margin.add_child(vbox)

		var header_hbox := HBoxContainer.new()
		vbox.add_child(header_hbox)

		var header := Label.new()
		header.text = "[ GF Developer Console ]"
		header.modulate = Color(0.4, 0.8, 1.0)
		header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header.mouse_filter = Control.MOUSE_FILTER_STOP
		header.gui_input.connect(_on_header_gui_input)
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

		_resize_handle = Panel.new()
		_resize_handle.mouse_filter = Control.MOUSE_FILTER_STOP
		_resize_handle.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
		_resize_handle.visible = false
		_resize_handle.gui_input.connect(_on_resize_handle_gui_input)
		var resize_style := StyleBoxFlat.new()
		resize_style.bg_color = Color(0.4, 0.8, 1.0, 0.45)
		_resize_handle.add_theme_stylebox_override("panel", resize_style)
		add_child(_resize_handle)

		_layout_console()


	func _ready() -> void:
		_apply_layer()
		_apply_background_alpha()
		_layout_console()


	func _input(event: InputEvent) -> void:
		if visible and (_dragging or _resizing):
			_update_window_interaction(event)
			get_viewport().set_input_as_handled()
			return

		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == toggle_key:
				visible = not visible
				if visible:
					_layout_console()
					_input_field.call_deferred("grab_focus")
				get_viewport().set_input_as_handled()
			elif visible and _input_field.has_focus() and event.keycode == KEY_UP:
				_show_previous_history()
				get_viewport().set_input_as_handled()
			elif visible and _input_field.has_focus() and event.keycode == KEY_DOWN:
				_show_next_history()
				get_viewport().set_input_as_handled()
			elif visible and _input_field.has_focus() and event.keycode == KEY_TAB:
				_apply_command_completion()
				get_viewport().set_input_as_handled()


	# --- 公共方法 ---

## 向控制台输出追加一行文本。
## @param bbcode_line: 要追加的一行 BBCode 文本。
	func append_text(bbcode_line: String) -> void:
		_pending_lines.append(bbcode_line)
		_queue_flush()


## 向控制台输出追加多行文本。
## @param bbcode_lines: 要追加的 BBCode 文本行列表。
	func append_lines(bbcode_lines: PackedStringArray) -> void:
		for bbcode_line: String in bbcode_lines:
			_pending_lines.append(bbcode_line)
		_queue_flush()


	func clear_output() -> void:
		_output_lines.clear()
		_pending_lines.clear()
		_flush_queued = false
		_output.clear()


	func flush_output() -> void:
		_flush_pending_lines()


## 检查日志标签是否被忽略。
## @param tag: 日志标签。
	func is_tag_ignored(tag: String) -> bool:
		if _ignored_tags.is_empty():
			return false

		return _ignored_tags.has(tag)


	# --- 私有/辅助方法 ---

	func _apply_layer() -> void:
		layer = _TOPMOST_LAYER if keep_topmost else _DEFAULT_LAYER


	func _apply_background_alpha() -> void:
		if _panel_style == null:
			return

		var color := _panel_style.bg_color
		color.a = background_alpha
		_panel_style.bg_color = color


	func _layout_console() -> void:
		if not is_instance_valid(_panel):
			return

		if not windowed:
			_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			_panel.position = Vector2.ZERO
			_window_layout_initialized = false
			if is_instance_valid(_resize_handle):
				_resize_handle.visible = false
			return

		_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		if not _window_layout_initialized:
			var viewport_size := _get_viewport_size()
			var target_size := Vector2(
				viewport_size.x * initial_window_size_ratio.x,
				viewport_size.y * initial_window_size_ratio.y
			)
			_panel.position = Vector2(_WINDOW_MARGIN, _WINDOW_MARGIN)
			_panel.size = _get_clamped_window_size(target_size)
			_window_layout_initialized = true
		else:
			_panel.size = _get_clamped_window_size(_panel.size)

		_clamp_panel_rect()
		_sync_resize_handle()


	func _get_viewport_size() -> Vector2:
		var viewport := get_viewport()
		if viewport == null:
			return Vector2.ZERO

		var viewport_rect := viewport.get_visible_rect()
		return Vector2(viewport_rect.size.x, viewport_rect.size.y)


	func _get_clamped_window_size(requested_size: Vector2) -> Vector2:
		var viewport_size := _get_viewport_size()
		if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
			return minimum_window_size

		var max_size := Vector2(
			maxf(1.0, viewport_size.x - _WINDOW_MARGIN * 2.0),
			maxf(1.0, viewport_size.y - _WINDOW_MARGIN * 2.0)
		)
		var min_size := Vector2(
			minf(minimum_window_size.x, max_size.x),
			minf(minimum_window_size.y, max_size.y)
		)
		return Vector2(
			clampf(requested_size.x, min_size.x, max_size.x),
			clampf(requested_size.y, min_size.y, max_size.y)
		)


	func _clamp_panel_rect() -> void:
		if not is_instance_valid(_panel):
			return

		_panel.size = _get_clamped_window_size(_panel.size)
		var viewport_size := _get_viewport_size()
		var max_position := viewport_size - _panel.size - Vector2(_WINDOW_MARGIN, _WINDOW_MARGIN)
		var safe_max_position := Vector2(
			maxf(_WINDOW_MARGIN, max_position.x),
			maxf(_WINDOW_MARGIN, max_position.y)
		)
		_panel.position = Vector2(
			clampf(_panel.position.x, _WINDOW_MARGIN, safe_max_position.x),
			clampf(_panel.position.y, _WINDOW_MARGIN, safe_max_position.y)
		)


	func _sync_resize_handle() -> void:
		if not is_instance_valid(_resize_handle) or not is_instance_valid(_panel):
			return

		_resize_handle.visible = windowed
		_resize_handle.position = _panel.position + _panel.size - Vector2(_RESIZE_HANDLE_SIZE, _RESIZE_HANDLE_SIZE)
		_resize_handle.size = Vector2(_RESIZE_HANDLE_SIZE, _RESIZE_HANDLE_SIZE)


	func _update_window_interaction(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_dragging = false
			_resizing = false
			return

		if not (event is InputEventMouseMotion):
			return

		var mouse_position := get_viewport().get_mouse_position()
		if _dragging:
			_panel.position = mouse_position - _drag_offset
			_clamp_panel_rect()
			_sync_resize_handle()
		elif _resizing:
			_panel.size = _resize_origin_size + mouse_position - _resize_origin_mouse
			_clamp_panel_rect()
			_sync_resize_handle()


	func _queue_flush() -> void:
		if _flush_queued:
			return

		_flush_queued = true
		call_deferred("_flush_pending_lines")


	func _flush_pending_lines() -> void:
		_flush_queued = false
		if _pending_lines.is_empty():
			return

		for line: String in _pending_lines:
			_output_lines.append(line)
		_pending_lines.clear()
		_trim_output_lines()
		_render_output()


	func _trim_output_lines() -> void:
		var max_lines := maxi(max_output_lines, 1)
		while _output_lines.size() > max_lines:
			_output_lines.remove_at(0)


	func _render_output() -> void:
		_output.clear()
		if _output_lines.is_empty():
			return

		_output.append_text("\n".join(_output_lines) + "\n")


	func _show_previous_history() -> void:
		if _command_history.is_empty():
			return
		if _history_index < 0:
			_history_index = _command_history.size() - 1
		else:
			_history_index = maxi(_history_index - 1, 0)
		_set_input_text(_command_history[_history_index])


	func _show_next_history() -> void:
		if _command_history.is_empty() or _history_index < 0:
			return
		_history_index += 1
		if _history_index >= _command_history.size():
			_history_index = -1
			_set_input_text("")
			return
		_set_input_text(_command_history[_history_index])


	func _apply_command_completion() -> void:
		if not command_name_provider.is_valid():
			return

		var text := _input_field.text
		var parts := text.split(" ", false)
		var prefix := parts[0] if parts.size() > 0 else text
		var names_variant: Variant = command_name_provider.call()
		var names := PackedStringArray()
		if names_variant is PackedStringArray:
			names = names_variant
		elif names_variant is Array:
			for name_variant: Variant in names_variant:
				names.append(String(name_variant))

		var matches := PackedStringArray()
		for cmd_name: String in names:
			if cmd_name.begins_with(prefix):
				matches.append(cmd_name)
		if matches.size() == 1:
			_set_input_text(matches[0] + " ")
		elif matches.size() > 1:
			append_text("[color=cyan]%s[/color]" % ", ".join(matches))


	func _set_input_text(text: String) -> void:
		_input_field.text = text
		_input_field.caret_column = text.length()


	# --- 信号处理函数 ---

	func _on_input_submitted(text: String) -> void:
		if text.strip_edges().is_empty():
			return

		_command_history.append(text)
		_history_index = -1
		command_submitted.emit(text)
		_input_field.clear()


	func _on_filter_changed(text: String) -> void:
		if text.is_empty():
			_ignored_tags.clear()
		else:
			_ignored_tags = text.replace(" ", "").split(",", false)


	func _on_header_gui_input(event: InputEvent) -> void:
		if not windowed or not is_instance_valid(_panel):
			return

		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_resizing = false
			if _dragging:
				_drag_offset = get_viewport().get_mouse_position() - _panel.position
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseMotion and _dragging:
			_update_window_interaction(event)
			get_viewport().set_input_as_handled()


	func _on_resize_handle_gui_input(event: InputEvent) -> void:
		if not windowed or not is_instance_valid(_panel):
			return

		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			_resizing = event.pressed
			_dragging = false
			if _resizing:
				_resize_origin_mouse = get_viewport().get_mouse_position()
				_resize_origin_size = _panel.size
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseMotion and _resizing:
			_update_window_interaction(event)
			get_viewport().set_input_as_handled()
