## 测试 GFInputUtility 的输入缓冲和土狼时间功能。
extends GutTest


# --- 私有变量 ---

var _utility: GFInputUtility


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_utility = GFInputUtility.new()
	_utility.init()


func after_each() -> void:
	_utility = null


# --- 测试：输入缓冲 ---

## 验证缓冲后可成功消费。
func test_buffer_and_consume() -> void:
	_utility.buffer_action(&"jump", 0.15)
	assert_true(_utility.consume_action(&"jump"), "缓冲后应可消费。")


## 验证消费后再次消费返回 false。
func test_consume_clears_buffer() -> void:
	_utility.buffer_action(&"jump", 0.15)
	_utility.consume_action(&"jump")
	assert_false(_utility.consume_action(&"jump"), "消费后不应再次消费成功。")


## 验证缓冲过期后消费返回 false。
func test_buffer_expires_after_duration() -> void:
	_utility.buffer_action(&"attack", 0.1)
	_utility.tick(0.05)
	assert_true(_utility.has_buffered_action(&"attack"), "未过期时仍应有缓冲。")
	_utility.tick(0.06)
	assert_false(_utility.has_buffered_action(&"attack"), "过期后缓冲应被清除。")
	assert_false(_utility.consume_action(&"attack"), "过期后消费应返回 false。")


## 验证未缓冲的动作消费返回 false。
func test_consume_unbuffered_returns_false() -> void:
	assert_false(_utility.consume_action(&"dash"), "未缓冲的动作消费应返回 false。")


## 验证重复缓冲取最大持续时间。
func test_buffer_refresh_takes_max() -> void:
	_utility.buffer_action(&"jump", 0.05)
	_utility.buffer_action(&"jump", 0.2)
	_utility.tick(0.1)
	assert_true(_utility.has_buffered_action(&"jump"), "刷新后应使用更长的持续时间。")


## 验证非正数缓冲时长不会形成可消费输入。
func test_non_positive_buffer_duration_is_not_consumable() -> void:
	_utility.buffer_action(&"jump", 0.0)
	_utility.buffer_action(&"dash", -1.0)

	assert_false(_utility.has_buffered_action(&"jump"), "0 秒缓冲不应活跃。")
	assert_false(_utility.consume_action(&"jump"), "0 秒缓冲不应可消费。")
	assert_false(_utility.has_buffered_action(&"dash"), "负数缓冲不应活跃。")
	assert_false(_utility.consume_action(&"dash"), "负数缓冲不应可消费。")


## 验证多个不同动作可并行缓冲。
func test_multiple_actions_parallel() -> void:
	_utility.buffer_action(&"jump", 0.2)
	_utility.buffer_action(&"dash", 0.1)
	assert_true(_utility.has_buffered_action(&"jump"), "jump 应有缓冲。")
	assert_true(_utility.has_buffered_action(&"dash"), "dash 应有缓冲。")


# --- 测试：土狼时间 ---

## 验证土狼时间窗口内查询返回 true。
func test_coyote_active_within_window() -> void:
	_utility.start_coyote(&"ground", 0.1)
	_utility.tick(0.05)
	assert_true(_utility.is_coyote_active(&"ground"), "窗口内应返回 true。")


## 验证土狼时间窗口过期后返回 false。
func test_coyote_expires_after_window() -> void:
	_utility.start_coyote(&"ground", 0.1)
	_utility.tick(0.11)
	assert_false(_utility.is_coyote_active(&"ground"), "过期后应返回 false。")


## 验证手动取消土狼时间。
func test_cancel_coyote() -> void:
	_utility.start_coyote(&"wall", 1.0)
	_utility.cancel_coyote(&"wall")
	assert_false(_utility.is_coyote_active(&"wall"), "取消后应返回 false。")


## 验证未启动的标签查询返回 false。
func test_inactive_coyote_returns_false() -> void:
	assert_false(_utility.is_coyote_active(&"air"), "未启动的标签应返回 false。")


## 验证 clear_all 清除所有状态。
func test_clear_all() -> void:
	_utility.buffer_action(&"jump", 1.0)
	_utility.start_coyote(&"ground", 1.0)
	_utility.clear_all()
	assert_false(_utility.has_buffered_action(&"jump"), "clear 后缓冲应被清除。")
	assert_false(_utility.is_coyote_active(&"ground"), "clear 后土狼时间应被清除。")


## 验证负数 delta 不会反向延长缓冲或土狼时间。
func test_negative_tick_does_not_extend_timers() -> void:
	_utility.buffer_action(&"jump", 0.1)
	_utility.start_coyote(&"ground", 0.1)

	_utility.tick(-1.0)
	_utility.tick(0.11)

	assert_false(_utility.has_buffered_action(&"jump"), "负 delta 不应延长输入缓冲。")
	assert_false(_utility.is_coyote_active(&"ground"), "负 delta 不应延长土狼时间。")
