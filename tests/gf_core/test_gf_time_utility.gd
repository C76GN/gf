## 测试 GFTimeUtility 的时间缩放、暂停和组级暂停功能。
extends GutTest


# --- 私有变量 ---

var _utility: GFTimeUtility


# --- 辅助类 ---

class DeltaRecorderSystem extends GFSystem:
	var last_delta: float = -1.0

	func tick(delta: float) -> void:
		last_delta = delta


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_utility = GFTimeUtility.new()
	_utility.init()


func after_each() -> void:
	_utility = null


# --- 测试：基本缩放 ---

## 验证默认缩放系数为 1.0，scaled_delta 等于原始 delta。
func test_default_scale_returns_raw_delta() -> void:
	var result: float = _utility.get_scaled_delta(0.016)
	assert_almost_eq(result, 0.016, 0.0001, "默认缩放系数应返回原始 delta。")


## 验证设置 time_scale = 0.5 后返回半速 delta。
func test_half_speed() -> void:
	_utility.time_scale = 0.5
	var result: float = _utility.get_scaled_delta(0.016)
	assert_almost_eq(result, 0.008, 0.0001, "0.5 缩放应返回一半的 delta。")


## 验证设置 time_scale = 2.0 后返回双倍 delta。
func test_double_speed() -> void:
	_utility.time_scale = 2.0
	var result: float = _utility.get_scaled_delta(0.016)
	assert_almost_eq(result, 0.032, 0.0001, "2.0 缩放应返回两倍的 delta。")


## 验证负缩放系数被钳制为 0.0。
func test_negative_scale_clamped_to_zero() -> void:
	_utility.time_scale = -1.0
	assert_almost_eq(_utility.time_scale, 0.0, 0.0001, "负缩放应被钳制为 0.0。")
	var result: float = _utility.get_scaled_delta(0.016)
	assert_almost_eq(result, 0.0, 0.0001, "钳制后 delta 应为 0.0。")


# --- 测试：暂停 ---

## 验证暂停时 get_scaled_delta 返回 0.0。
func test_paused_returns_zero() -> void:
	_utility.is_paused = true
	var result: float = _utility.get_scaled_delta(0.016)
	assert_almost_eq(result, 0.0, 0.0001, "暂停时应返回 0.0。")


## 验证取消暂停后恢复正常。
func test_unpause_restores_delta() -> void:
	_utility.is_paused = true
	_utility.is_paused = false
	var result: float = _utility.get_scaled_delta(0.016)
	assert_almost_eq(result, 0.016, 0.0001, "取消暂停后应恢复正常 delta。")


# --- 测试：组级暂停 ---

## 验证组暂停后 get_group_scaled_delta 返回 0.0。
func test_group_paused_returns_zero() -> void:
	_utility.set_group_paused(&"ui", true)
	var result: float = _utility.get_group_scaled_delta(&"ui", 0.016)
	assert_almost_eq(result, 0.0, 0.0001, "组暂停时应返回 0.0。")


## 验证未暂停的组返回正常 delta。
func test_unpaused_group_returns_scaled_delta() -> void:
	_utility.time_scale = 0.5
	_utility.set_group_paused(&"game", false)
	var result: float = _utility.get_group_scaled_delta(&"game", 0.016)
	assert_almost_eq(result, 0.008, 0.0001, "未暂停的组应返回缩放后的 delta。")


## 验证未注册的组默认不暂停。
func test_unknown_group_is_not_paused() -> void:
	assert_false(_utility.is_group_paused(&"unknown"), "未注册的组应默认不暂停。")


## 验证全局暂停时，组级 delta 也返回 0.0。
func test_global_pause_overrides_group() -> void:
	_utility.is_paused = true
	_utility.set_group_paused(&"game", false)
	var result: float = _utility.get_group_scaled_delta(&"game", 0.016)
	assert_almost_eq(result, 0.0, 0.0001, "全局暂停应覆盖组级设置。")


## 验证 remove_group 移除后查询返回 false。
func test_remove_group() -> void:
	_utility.set_group_paused(&"fx", true)
	_utility.remove_group(&"fx")
	assert_false(_utility.is_group_paused(&"fx"), "移除后应返回 false。")


## 验证 init 重置所有状态。
func test_init_resets_state() -> void:
	_utility.time_scale = 3.0
	_utility.is_paused = true
	_utility.set_group_paused(&"test", true)
	_utility.init()
	assert_almost_eq(_utility.time_scale, 1.0, 0.0001, "init 后缩放应重置为 1.0。")
	assert_false(_utility.is_paused, "init 后暂停应重置为 false。")
	assert_false(_utility.is_group_paused(&"test"), "init 后组暂停应被清除。")


## 验证模块可选择忽略 time_scale 但仍尊重暂停。
func test_architecture_module_can_ignore_time_scale() -> void:
	var arch := GFArchitecture.new()
	var time_utility := GFTimeUtility.new()
	var system := DeltaRecorderSystem.new()
	system.ignore_time_scale = true
	await arch.register_utility_instance(time_utility)
	await arch.register_system_instance(system)
	await arch.init()

	time_utility.time_scale = 0.25
	arch.tick(1.0)
	assert_almost_eq(system.last_delta, 1.0, 0.0001, "ignore_time_scale 的模块应接收原始 delta。")

	time_utility.is_paused = true
	arch.tick(1.0)
	assert_almost_eq(system.last_delta, 0.0, 0.0001, "未设置 ignore_pause 时仍应尊重全局暂停。")

	arch.dispose()
