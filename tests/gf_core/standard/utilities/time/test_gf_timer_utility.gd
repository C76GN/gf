## 测试 GFTimerUtility 的时间缩放与暂停行为。
extends GutTest


var _arch: GFArchitecture
var _time_util: GFTimeUtility
var _timer_util: GFTimerUtility


func before_each() -> void:
	_arch = GFArchitecture.new()
	Gf._architecture = _arch

	_time_util = GFTimeUtility.new()
	await _arch.register_utility_instance(_time_util)

	_timer_util = GFTimerUtility.new()
	await _arch.register_utility_instance(_timer_util)

	await Gf.set_architecture(_arch)


func after_each() -> void:
	var arch: GFArchitecture = Gf.get_architecture()
	if arch != null:
		arch.dispose()
		await Gf.set_architecture(GFArchitecture.new())


func test_execute_after_uses_scaled_delta() -> void:
	var fired := {"count": 0}
	_time_util.time_scale = 0.5

	_timer_util.execute_after(1.0, func() -> void:
		fired["count"] += 1
	)

	_arch.tick(1.0)
	assert_eq(fired["count"], 0, "半速时间下，1 秒真实时间不应立刻消耗完 1 秒逻辑计时。")

	_arch.tick(1.0)
	assert_eq(fired["count"], 1, "累计 2 秒真实时间后，应恰好触发 1 秒逻辑计时。")


func test_execute_after_respects_pause() -> void:
	var fired := [false]

	_timer_util.execute_after(0.5, func() -> void:
		fired[0] = true
	)

	_time_util.is_paused = true
	_arch.tick(1.0)
	assert_false(fired[0], "暂停期间，定时器不应推进。")

	_time_util.is_paused = false
	_arch.tick(0.5)
	assert_true(fired[0], "恢复后，定时器应继续推进并触发回调。")


func test_execute_after_zero_delay_runs_immediately() -> void:
	var fired := {"count": 0}

	_timer_util.execute_after(0.0, func() -> void:
		fired["count"] += 1
	)

	assert_eq(fired["count"], 1, "0 秒延迟应立即执行回调。")
	assert_true(_timer_util._pending_timers.is_empty(), "立即执行不应加入待执行队列。")


func test_execute_after_rejects_invalid_callback() -> void:
	var handle := _timer_util.execute_after(1.0, Callable())

	assert_eq(handle, 0, "无效回调不应返回有效句柄。")
	assert_push_error("[GFTimerUtility] execute_after 失败：传入的 callback 无效。")
	assert_true(_timer_util._pending_timers.is_empty(), "无效回调不应加入待执行队列。")


func test_multiple_timers_fire_in_registration_order() -> void:
	var order := []

	_timer_util.execute_after(0.2, func() -> void:
		order.append("first")
	)
	_timer_util.execute_after(0.1, func() -> void:
		order.append("second")
	)

	_arch.tick(0.2)

	assert_eq(order, ["first", "second"], "同一 tick 中多个到期定时器应按注册顺序执行。")


func test_cancel_prevents_pending_timer_from_firing() -> void:
	var fired := [false]

	var handle := _timer_util.execute_after(0.5, func() -> void:
		fired[0] = true
	)

	assert_gt(handle, 0, "排队定时器应返回有效句柄。")
	assert_true(_timer_util.cancel(handle), "未触发的定时器应可取消。")
	assert_false(_timer_util.cancel(handle), "同一句柄取消一次后不应再次命中。")

	_arch.tick(0.5)

	assert_false(fired[0], "已取消的定时器不应触发。")


func test_dispose_clears_pending_timers() -> void:
	var fired := [false]

	_timer_util.execute_after(0.1, func() -> void:
		fired[0] = true
	)
	_timer_util.dispose()
	_timer_util.tick(0.2)

	assert_false(fired[0], "dispose 后残留定时器不应触发。")


func test_execute_repeating_runs_expected_count() -> void:
	var fired := {"count": 0}

	var handle := _timer_util.execute_repeating(0.1, func() -> void:
		fired["count"] += 1
	, 3)

	assert_gt(handle, 0, "重复定时器应返回有效句柄。")
	_arch.tick(0.1)
	_arch.tick(0.1)
	_arch.tick(0.1)
	_arch.tick(0.1)

	assert_eq(fired["count"], 3, "repeat_count 为 3 时应只触发三次。")
	assert_eq(int(_timer_util.get_debug_snapshot()["pending_count"]), 0, "有限重复完成后不应继续保留待执行任务。")


func test_owner_bound_timer_is_dropped_when_owner_is_released() -> void:
	var fired := [false]
	var timer_owner: RefCounted = RefCounted.new()

	_timer_util.execute_after_owned(timer_owner, 0.1, func() -> void:
		fired[0] = true
	)
	timer_owner = null
	_arch.tick(0.2)

	assert_false(fired[0], "owner 释放后绑定定时器不应触发。")
	assert_eq(int(_timer_util.get_debug_snapshot()["pending_count"]), 0, "释放 owner 后绑定任务应被清理。")


func test_cancel_owner_removes_owned_timers() -> void:
	var fired := {"count": 0}
	var timer_owner := RefCounted.new()

	_timer_util.execute_after_owned(timer_owner, 0.1, func() -> void:
		fired["count"] += 1
	)
	_timer_util.execute_repeating_owned(timer_owner, 0.1, func() -> void:
		fired["count"] += 1
	)
	var removed := _timer_util.cancel_owner(timer_owner)
	_arch.tick(0.2)

	assert_eq(removed, 2, "cancel_owner 应取消同一 owner 的全部任务。")
	assert_eq(fired["count"], 0, "被 cancel_owner 移除的任务不应触发。")


func test_cancel_repeating_timer_from_callback_stops_next_repeat() -> void:
	var fired := {"count": 0, "handle": 0}
	fired["handle"] = _timer_util.execute_repeating(0.1, func() -> void:
		fired["count"] += 1
		_timer_util.cancel(int(fired["handle"]))
	)

	_arch.tick(0.1)
	_arch.tick(0.1)

	assert_eq(fired["count"], 1, "回调内取消重复任务后不应再次触发。")
