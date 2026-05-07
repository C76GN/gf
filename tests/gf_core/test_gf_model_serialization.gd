## 测试 GFModel 的 to_dict / from_dict 虚方法及 GFArchitecture 的全局状态收集/恢复。
extends GutTest


const SCORE_MODEL_FIXTURE_PATH := "res://tests/gf_core/fixtures/model_serialization/score_model_fixture.gd"
const SETTINGS_MODEL_FIXTURE_PATH := "res://tests/gf_core/fixtures/model_serialization/settings_model_fixture.gd"


# --- 辅助子类 ---

## 用于测试的 Model 实现。
class ScoreModel:
	extends GFModel

	var score: int = 0
	var level: int = 1

	func to_dict() -> Dictionary:
		return {"score": score, "level": level}

	func from_dict(data: Dictionary) -> void:
		score = data.get("score", 0)
		level = data.get("level", 1)


## 另一个用于测试的 Model 实现。
class SettingsModel:
	extends GFModel

	var volume: float = 1.0

	func to_dict() -> Dictionary:
		return {"volume": volume}

	func from_dict(data: Dictionary) -> void:
		volume = data.get("volume", 1.0)


class StableKeyModel:
	extends GFModel

	var value: int = 7

	func get_save_key() -> StringName:
		return &"stable_runtime_model"

	func to_dict() -> Dictionary:
		return { "value": value }

	func from_dict(data: Dictionary) -> void:
		value = data.get("value", 0)


# --- 私有/辅助方法 ---

func _create_score_model_fixture() -> Variant:
	return load(SCORE_MODEL_FIXTURE_PATH).new()


func _create_settings_model_fixture() -> Variant:
	return load(SETTINGS_MODEL_FIXTURE_PATH).new()


# --- 测试：单 Model 序列化 ---

## 验证基类默认 to_dict 返回空字典。
func test_base_model_to_dict_returns_empty() -> void:
	var base := GFModel.new()
	var result: Dictionary = base.to_dict()
	assert_eq(result.size(), 0, "基类 to_dict 应返回空字典。")


## 验证子类 to_dict / from_dict 往返正确。
func test_subclass_roundtrip() -> void:
	var model := ScoreModel.new()
	model.score = 999
	model.level = 5

	var data: Dictionary = model.to_dict()
	assert_eq(data.get("score"), 999)
	assert_eq(data.get("level"), 5)

	var restored := ScoreModel.new()
	restored.from_dict(data)
	assert_eq(restored.score, 999, "score 应正确恢复。")
	assert_eq(restored.level, 5, "level 应正确恢复。")


## 验证空字典 from_dict 使用默认值。
func test_from_dict_with_empty_data() -> void:
	var model := ScoreModel.new()
	model.score = 100
	model.from_dict({})
	assert_eq(model.score, 0, "空字典 from_dict 应使用 get 的默认值。")


# --- 测试：架构级状态收集/恢复 ---

## 验证 get_all_models_state 收集多个 Model 的状态。
func test_architecture_get_all_models_state() -> void:
	var arch := GFArchitecture.new()
	var score_model: Variant = _create_score_model_fixture()
	score_model.score = 42
	score_model.level = 3

	var settings_model: Variant = _create_settings_model_fixture()
	settings_model.volume = 0.5

	arch.register_model_instance(score_model)
	arch.register_model_instance(settings_model)

	var state: Dictionary = arch.get_all_models_state()
	assert_true(state.size() >= 2, "状态字典应至少包含 2 个 Model。")


## 验证缺少稳定标识的运行时脚本 Model 不会被写入快照。
func test_architecture_skips_model_without_stable_serialization_key() -> void:
	var arch := GFArchitecture.new()
	var runtime_script := GDScript.new()
	runtime_script.source_code = """extends GFModel


func to_dict() -> Dictionary:
	return { "value": 7 }
"""
	var reload_error := runtime_script.reload()
	assert_eq(reload_error, OK, "动态脚本应成功编译。")

	var runtime_model := runtime_script.new() as GFModel

	arch.register_model_instance(runtime_model)

	var state: Dictionary = arch.get_all_models_state()

	assert_eq(state.size(), 0, "缺少稳定标识的运行时 Model 不应进入快照。")
	assert_push_error("[GFArchitecture] 可序列化 Model 缺少稳定标识：请为脚本声明 class_name 或提供可用的资源路径。")


func test_architecture_prefers_model_save_key_for_serialization() -> void:
	var arch := GFArchitecture.new()
	var model := StableKeyModel.new()
	model.value = 12

	arch.register_model_instance(model)
	var state := arch.get_all_models_state()

	model.value = 0
	arch.restore_all_models_state({
		"stable_runtime_model": { "value": 42 },
	})

	assert_true(state.has("stable_runtime_model"), "Model.get_save_key() 应优先作为架构级快照键。")
	assert_eq(state["stable_runtime_model"]["value"], 12, "快照应写入自定义存档键下。")
	assert_eq(model.value, 42, "恢复时也应使用自定义存档键。")


## 验证 restore_all_models_state 恢复多个 Model 的数据。
func test_architecture_restore_all_models_state() -> void:
	var arch := GFArchitecture.new()
	var score_model: Variant = _create_score_model_fixture()
	var settings_model: Variant = _create_settings_model_fixture()

	arch.register_model_instance(score_model)
	arch.register_model_instance(settings_model)

	score_model.score = 100
	score_model.level = 10
	settings_model.volume = 0.3

	var state: Dictionary = arch.get_all_models_state()

	score_model.score = 0
	score_model.level = 1
	settings_model.volume = 1.0

	arch.restore_all_models_state(state)

	assert_eq(score_model.score, 100, "score 应恢复为 100。")
	assert_eq(score_model.level, 10, "level 应恢复为 10。")
	assert_almost_eq(settings_model.volume, 0.3, 0.001, "volume 应恢复为 0.3。")


## 验证全局快照中的 models 字段类型错误时安全跳过。
func test_restore_global_snapshot_skips_non_dictionary_models_data() -> void:
	var arch := GFArchitecture.new()
	var score_model: Variant = _create_score_model_fixture()
	score_model.score = 55
	arch.register_model_instance(score_model)

	arch.restore_global_snapshot({ "models": [] })

	assert_eq(score_model.score, 55, "models 不是 Dictionary 时不应修改已注册 Model。")
	assert_push_warning("[GFArchitecture] restore_global_snapshot：models 必须是 Dictionary，已跳过 Model 恢复。")


## 验证 get_global_snapshot 包含 Model 与 CommandHistory 数据，及 restore_global_snapshot 正确恢复。
func test_architecture_global_snapshot_preserves_redo_history() -> void:
	var arch := GFArchitecture.new()
	var history_util := GFCommandHistoryUtility.new()
	history_util.init()
	await arch.register_utility_instance(history_util)

	var cmd1 := GFUndoableCommand.new()
	var cmd2 := GFUndoableCommand.new()
	history_util.record(cmd1)
	history_util.record(cmd2)
	history_util.undo_last()

	var snapshot := arch.get_global_snapshot()
	history_util.clear()

	var builder: Callable = func(_data: Dictionary) -> GFUndoableCommand:
		return GFUndoableCommand.new()

	arch.restore_global_snapshot(snapshot, builder)

	assert_eq(history_util.undo_count, 1, "全局快照恢复后应保留 undo 栈。")
	assert_eq(history_util.redo_count, 1, "全局快照恢复后应保留 redo 栈。")


func test_architecture_global_snapshot() -> void:
	var arch := GFArchitecture.new()
	var score_model: Variant = _create_score_model_fixture()
	score_model.score = 99
	arch.register_model_instance(score_model)
	
	var history_util := GFCommandHistoryUtility.new()
	history_util.init()
	arch.register_utility_instance(history_util)
	
	# 构造一个虚假的序列化历史数据（不依赖具体的 command 类）
	# 在真实场景下，这就代表了一个历史记录
	var fake_history_data: Array = [{"snapshot": 1}]
	# 模拟工具内有一些记录
	history_util._undo_stack.append(GFUndoableCommand.new())
	
	var global_snap: Dictionary = arch.get_global_snapshot()
	
	assert_true(global_snap.has("models"), "全局快照必须包含 models。")
	assert_true(global_snap.has("command_history"), "如果注册了命令历史工具，全局快照必须包含 command_history。")
	
	# 修改模型状态
	score_model.score = 0
	
	# 设置一个不做任何事的 builder 以防止报错，并验证历史恢复是否被触达
	var mock_builder: Callable = func(data: Dictionary) -> GFUndoableCommand:
		var cmd := GFUndoableCommand.new()
		cmd.set_snapshot(data.get("snapshot"))
		return cmd
		
	# 由于历史重做会在 restore 时调用 clear，我们要改写一下
	# 或者不改，依靠 deserialize_history 的能力即可
	global_snap["command_history"] = fake_history_data
		
	arch.restore_global_snapshot(global_snap, mock_builder)
	
	assert_eq(score_model.score, 99, "模型状态应通过全局快照恢复。")
	assert_eq(history_util.undo_count, 1, "历史栈记录数量应通过全局快照及 builder 恢复。")
