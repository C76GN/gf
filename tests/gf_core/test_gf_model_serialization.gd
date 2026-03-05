# tests/gf_core/test_gf_model_serialization.gd

## 测试 GFModel 的 to_dict / from_dict 虚方法及 GFArchitecture 的全局状态收集/恢复。
extends GutTest


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
	var score_model := ScoreModel.new()
	score_model.score = 42
	score_model.level = 3

	var settings_model := SettingsModel.new()
	settings_model.volume = 0.5

	arch.register_model_instance(score_model)
	arch.register_model_instance(settings_model)

	var state: Dictionary = arch.get_all_models_state()
	assert_true(state.size() >= 2, "状态字典应至少包含 2 个 Model。")


## 验证 restore_all_models_state 恢复多个 Model 的数据。
func test_architecture_restore_all_models_state() -> void:
	var arch := GFArchitecture.new()
	var score_model := ScoreModel.new()
	var settings_model := SettingsModel.new()

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
