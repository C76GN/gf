# tests/gf_core/test_gf_console_utility.gd

## 测试 GFConsoleUtility 的指令注册、注销及字符串解析执行逻辑。
extends GutTest


# --- 私有变量 ---

var _console: GFConsoleUtility


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_console = GFConsoleUtility.new()
	_console.init()
	await get_tree().process_frame


func after_each() -> void:
	if _console != null:
		_console.dispose()
		_console = null
	
	await get_tree().process_frame


# --- 测试：指令注册 ---

## 验证 register_command 成功将指令存入内部字典。
func test_register_command() -> void:
	var called := {"count": 0}
	var cb := func(_args: PackedStringArray) -> void:
		called["count"] += 1

	_console.register_command("test_cmd", cb, "测试指令。")
	assert_true(_console._commands.has("test_cmd"), "注册后 _commands 中应包含 'test_cmd'。")


## 验证内置 help 指令在 init 后已注册。
func test_builtin_help_registered() -> void:
	assert_true(_console._commands.has("help"), "init 后应已注册内置 help 指令。")


## 验证内置 clear 指令在 init 后已注册。
func test_builtin_clear_registered() -> void:
	assert_true(_console._commands.has("clear"), "init 后应已注册内置 clear 指令。")


# --- 测试：指令注销 ---

## 验证 unregister_command 成功移除指令。
func test_unregister_command() -> void:
	var cb := func(_args: PackedStringArray) -> void:
		pass

	_console.register_command("temp_cmd", cb, "临时指令。")
	assert_true(_console._commands.has("temp_cmd"), "注册后应存在。")

	_console.unregister_command("temp_cmd")
	assert_false(_console._commands.has("temp_cmd"), "注销后 _commands 中不应包含 'temp_cmd'。")


# --- 测试：指令执行 ---

## 验证 execute_command 正确解析并调用回调。
func test_execute_command_calls_callback() -> void:
	var called := {"count": 0}
	var cb := func(_args: PackedStringArray) -> void:
		called["count"] += 1

	_console.register_command("inc", cb, "递增计数器。")
	var result: bool = _console.execute_command("inc")

	assert_true(result, "execute_command 对已注册指令应返回 true。")
	assert_eq(called["count"], 1, "回调应被调用一次。")


## 验证 execute_command 正确传递参数。
func test_execute_command_passes_args() -> void:
	var captured_args := PackedStringArray()
	var cb := func(args: PackedStringArray) -> void:
		for a: String in args:
			captured_args.append(a)

	_console.register_command("echo", cb, "回显参数。")
	_console.execute_command("echo hello world")

	assert_eq(captured_args.size(), 2, "应传递 2 个参数。")
	assert_eq(captured_args[0], "hello", "第一个参数应为 'hello'。")
	assert_eq(captured_args[1], "world", "第二个参数应为 'world'。")


## 验证未注册指令返回 false。
func test_execute_unknown_command_returns_false() -> void:
	var result: bool = _console.execute_command("nonexistent_cmd")
	assert_false(result, "未注册指令应返回 false。")


## 验证空字符串不会崩溃并返回 false。
func test_execute_empty_input_returns_false() -> void:
	var result: bool = _console.execute_command("")
	assert_false(result, "空输入应返回 false。")


## 验证纯空白字符串不会崩溃并返回 false。
func test_execute_whitespace_only_returns_false() -> void:
	var result: bool = _console.execute_command("   ")
	assert_false(result, "纯空白输入应返回 false。")
