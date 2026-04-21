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
	var arch := Gf.get_architecture()
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
