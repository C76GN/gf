## 测试 GFConsoleUtility 的命令注册、执行与日志信号解绑行为。
extends GutTest


const GFConsoleCommandDefinitionBase = preload("res://addons/gf/utilities/gf_console_command_definition.gd")


var _console: GFConsoleUtility


func before_each() -> void:
	_console = GFConsoleUtility.new()
	_console.init()
	await get_tree().process_frame


func after_each() -> void:
	if _console != null:
		_console.dispose()
		_console = null

	if Gf._architecture != null:
		Gf._architecture.dispose()
		Gf._architecture = null

	await get_tree().process_frame


func test_register_command() -> void:
	var called := {"count": 0}
	var cb := func(_args: PackedStringArray) -> void:
		called["count"] += 1

	_console.register_command("test_cmd", cb, "测试指令。")
	assert_true(_console._commands.has("test_cmd"), "register_command 后应记录到 _commands。")


func test_builtin_help_registered() -> void:
	assert_true(_console._commands.has("help"), "init 后应注册内置 help 指令。")


func test_builtin_clear_registered() -> void:
	assert_true(_console._commands.has("clear"), "init 后应注册内置 clear 指令。")


func test_unregister_command() -> void:
	var cb := func(_args: PackedStringArray) -> void:
		pass

	_console.register_command("temp_cmd", cb, "临时指令。")
	assert_true(_console._commands.has("temp_cmd"), "注册后命令应存在。")

	_console.unregister_command("temp_cmd")
	assert_false(_console._commands.has("temp_cmd"), "注销后命令应被移除。")


func test_get_command_names_returns_sorted_names() -> void:
	var cb := func(_args: PackedStringArray) -> void:
		pass

	_console.register_command("zeta", cb, "Z。")
	_console.register_command("alpha", cb, "A。")
	var names := _console.get_command_names()

	assert_true(names.find("alpha") < names.find("zeta"), "命令名应按字典序返回。")


func test_suggest_commands_filters_by_prefix() -> void:
	var cb := func(_args: PackedStringArray) -> void:
		pass

	_console.register_command("teleport", cb, "传送。")
	_console.register_command("time_scale", cb, "时间。")
	_console.register_command("spawn", cb, "生成。")
	var suggestions := _console.suggest_commands("t")

	assert_true(suggestions.has("teleport"), "前缀匹配应返回 teleport。")
	assert_true(suggestions.has("time_scale"), "前缀匹配应返回 time_scale。")
	assert_false(suggestions.has("spawn"), "不匹配前缀的命令不应返回。")


func test_suggest_similar_commands_returns_likely_matches() -> void:
	var cb := func(_args: PackedStringArray) -> void:
		pass

	_console.register_command("teleport", cb, "传送。")
	_console.register_command("time_scale", cb, "时间。")
	var suggestions := _console.suggest_similar_commands("teleprt")

	assert_gt(suggestions.size(), 0, "拼写接近已注册命令时应返回候选。")
	assert_eq(suggestions[0], "teleport", "最接近的命令应排在第一位。")


func test_execute_command_calls_callback() -> void:
	var called := {"count": 0}
	var cb := func(_args: PackedStringArray) -> void:
		called["count"] += 1

	_console.register_command("inc", cb, "递增计数器。")
	var result: bool = _console.execute_command("inc")

	assert_true(result, "已注册指令执行后应返回 true。")
	assert_eq(called["count"], 1, "回调应被调用一次。")


func test_execute_command_passes_args() -> void:
	var captured_args := PackedStringArray()
	var cb := func(args: PackedStringArray) -> void:
		for a: String in args:
			captured_args.append(a)

	_console.register_command("echo", cb, "回显参数。")
	_console.execute_command("echo hello world")

	assert_eq(captured_args.size(), 2, "参数数量应为 2。")
	assert_eq(captured_args[0], "hello", "第一个参数应为 hello。")
	assert_eq(captured_args[1], "world", "第二个参数应为 world。")


func test_register_command_definition_registers_aliases() -> void:
	var definition := GFConsoleCommandDefinitionBase.new()
	definition.command_name = "primary"
	definition.aliases = PackedStringArray(["alias"])
	var called := { "count": 0 }
	var cb := func(_args: PackedStringArray) -> void:
		called["count"] += 1

	_console.register_command_definition(definition, cb)
	var result := _console.execute_command("alias")

	assert_true(result, "资源化命令别名应可执行。")
	assert_eq(called["count"], 1, "别名应调用同一回调。")


func test_execute_unknown_command_returns_false() -> void:
	var result: bool = _console.execute_command("nonexistent_cmd")
	assert_false(result, "未知指令应返回 false。")


func test_execute_empty_input_returns_false() -> void:
	var result: bool = _console.execute_command("")
	assert_false(result, "空字符串输入应返回 false。")


func test_execute_whitespace_only_returns_false() -> void:
	var result: bool = _console.execute_command("   ")
	assert_false(result, "纯空白输入应返回 false。")


func test_console_output_keeps_max_lines() -> void:
	_console.max_output_lines = 2
	_console._console_gui.append_text("line-1")
	_console._console_gui.append_text("line-2")
	_console._console_gui.append_text("line-3")
	_console._console_gui.flush_output()

	assert_eq(_console._console_gui._output_lines.size(), 2, "控制台输出应按上限裁剪。")
	assert_eq(_console._console_gui._output_lines[0], "line-2", "控制台应丢弃最旧输出。")
	assert_eq(_console._console_gui._output_lines[1], "line-3", "控制台应保留最新输出。")


func test_console_output_batches_until_flush() -> void:
	_console._console_gui.append_text("batched")

	assert_eq(_console._console_gui._output_lines.size(), 0, "批量刷新前不应立即重绘输出。")

	_console._console_gui.flush_output()

	assert_eq(_console._console_gui._output_lines.size(), 1, "flush 后应写入待输出行。")
	assert_eq(_console._console_gui._output_lines[0], "batched", "flush 后应保留待输出内容。")


func test_console_background_alpha_updates_gui() -> void:
	_console.background_alpha = 0.42

	assert_almost_eq(_console.background_alpha, 0.42, 0.001, "控制台透明度配置应保存在工具上。")
	assert_almost_eq(_console._console_gui.background_alpha, 0.42, 0.001, "控制台透明度配置应同步到 GUI。")
	assert_almost_eq(_console._console_gui._panel_style.bg_color.a, 0.42, 0.001, "GUI 背景样式应立即应用透明度。")


func test_console_background_alpha_is_clamped() -> void:
	_console.background_alpha = 2.0

	assert_almost_eq(_console.background_alpha, 1.0, 0.001, "透明度上限应被钳制为 1。")
	assert_almost_eq(_console._console_gui._panel_style.bg_color.a, 1.0, 0.001, "GUI 样式透明度也应应用钳制结果。")


func test_console_windowed_mode_uses_panel_layout_and_resize_handle() -> void:
	_console.windowed = true

	assert_true(_console._console_gui.windowed, "窗口模式配置应同步到 GUI。")
	assert_true(_console._console_gui._resize_handle.visible, "窗口模式应显示缩放手柄。")
	assert_gt(_console._console_gui._panel.size.x, 0.0, "窗口模式应给面板设置有效宽度。")
	assert_gt(_console._console_gui._panel.size.y, 0.0, "窗口模式应给面板设置有效高度。")


func test_console_keep_topmost_updates_layer() -> void:
	_console.keep_topmost = false
	assert_eq(_console._console_gui.layer, 1, "关闭 keep_topmost 后应使用普通层级。")

	_console.keep_topmost = true
	assert_eq(_console._console_gui.layer, 150, "开启 keep_topmost 后应使用高层级。")


func test_dispose_disconnects_log_signal() -> void:
	var arch := GFArchitecture.new()
	var log_util := GFLogUtility.new()
	var console := GFConsoleUtility.new()

	arch.register_utility_instance(log_util)
	arch.register_utility_instance(console)
	await Gf.set_architecture(arch)

	var log_callable := Callable(console, "_on_log_emitted")
	assert_true(log_util.log_emitted.is_connected(log_callable), "ready 后控制台应连接日志信号。")

	arch.unregister_utility(console.get_script() as Script)
	assert_false(log_util.log_emitted.is_connected(log_callable), "dispose 后应断开日志信号，避免悬挂监听。")
