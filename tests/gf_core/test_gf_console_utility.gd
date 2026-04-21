## 测试 GFConsoleUtility 的命令注册、执行与日志信号解绑行为。
extends GutTest


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


func test_execute_unknown_command_returns_false() -> void:
	var result: bool = _console.execute_command("nonexistent_cmd")
	assert_false(result, "未知指令应返回 false。")


func test_execute_empty_input_returns_false() -> void:
	var result: bool = _console.execute_command("")
	assert_false(result, "空字符串输入应返回 false。")


func test_execute_whitespace_only_returns_false() -> void:
	var result: bool = _console.execute_command("   ")
	assert_false(result, "纯空白输入应返回 false。")


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
