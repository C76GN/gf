## 测试 GFLevelUtility 的关卡读取、流程信号与运行时清理。
extends GutTest


const GF_LEVEL_UTILITY := preload("res://addons/gf/utilities/gf_level_utility.gd")


# --- 辅助类型 ---

class TestConfigProvider extends GFConfigProvider:
	var records: Dictionary = {}

	func get_record(table_name: StringName, id: Variant) -> Variant:
		return records.get(table_name, {}).get(id)


class TestCommand extends GFUndoableCommand:
	func execute() -> Variant:
		return null

	func undo() -> Variant:
		return null


# --- 私有变量 ---

var _arch: GFArchitecture
var _level: Object
var _config: TestConfigProvider
var _history: GFCommandHistoryUtility
var _actions: GFActionQueueSystem


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_arch = GFArchitecture.new()
	_level = GF_LEVEL_UTILITY.new()
	_config = TestConfigProvider.new()
	_history = GFCommandHistoryUtility.new()
	_actions = GFActionQueueSystem.new()

	_config.records = {
		&"levels": {
			1: {
				"name": "Level 1",
				"moves": 10,
			},
		},
	}

	await _arch.register_utility_instance(_config)
	await _arch.register_utility_instance(_history)
	await _arch.register_system_instance(_actions)
	await _arch.register_utility_instance(_level)
	await Gf.set_architecture(_arch)


func after_each() -> void:
	if _arch != null:
		_arch.dispose()
	_arch = null
	Gf._architecture = null


# --- 测试 ---

func test_start_level_loads_data_from_config_provider() -> void:
	var data: Dictionary = _level.start_level(1)

	assert_eq(data.get("name"), "Level 1", "start_level 应从配置工具读取关卡数据。")
	assert_eq(_level.current_level_id, 1, "当前关卡 ID 应更新。")
	assert_eq(_level.current_level_data.get("moves"), 10, "当前关卡数据应保存在工具中。")


func test_start_level_emits_signal() -> void:
	watch_signals(_level)

	_level.start_level(1)

	assert_signal_emitted(_level, "level_started", "开始关卡时应发出 level_started。")


func test_restart_level_clears_runtime_and_emits_signal() -> void:
	var command := TestCommand.new()
	_history.record(command)
	_level.start_level(1)
	watch_signals(_level)

	var data: Dictionary = _level.restart_level()

	assert_eq(data.get("name"), "Level 1", "restart_level 应返回当前关卡数据。")
	assert_eq(_history.undo_count, 0, "重开关卡应清理命令历史。")
	assert_signal_emitted(_level, "level_restarted", "重开关卡时应发出 level_restarted。")
	assert_signal_not_emitted(_level, "level_started", "重开关卡不应重复发出 level_started。")


func test_restart_level_reloads_clean_config_data() -> void:
	_level.start_level(1)
	_level.current_level_data["moves"] = 0

	var data: Dictionary = _level.restart_level()

	assert_eq(data.get("moves"), 10, "restart_level 应重新读取干净的关卡配置数据。")


func test_win_and_lose_current_level_emit_signals() -> void:
	_level.start_level(1)
	watch_signals(_level)

	_level.win_current_level()
	_level.lose_current_level()

	assert_signal_emitted(_level, "level_won", "胜利时应发出 level_won。")
	assert_signal_emitted(_level, "level_lost", "失败时应发出 level_lost。")
