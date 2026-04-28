## 测试 GFSignalUtility 的安全连接、owner 清理和链式处理。
extends GutTest


# --- 常量 ---

const GFSignalUtilityBase = preload("res://addons/gf/utilities/gf_signal_utility.gd")


# --- 辅助子类 ---

class TestEmitter:
	extends Object

	signal changed(value: int)

	func emit_changed(value: int) -> void:
		changed.emit(value)


class TestOwner:
	extends RefCounted


# --- 私有变量 ---

var _utility: GFUtility


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_utility = GFSignalUtilityBase.new()


func after_each() -> void:
	if _utility != null:
		_utility.dispose()
	_utility = null


# --- 测试 ---

func test_connect_signal_invokes_callback_with_default_args() -> void:
	var emitter := TestEmitter.new()
	var received: Array = []

	_utility.connect_signal(
		emitter.changed,
		func(prefix: String, value: int) -> void:
			received.append("%s:%s" % [prefix, value]),
		null,
		["hp"]
	)
	emitter.emit_changed(7)

	await get_tree().process_frame

	assert_eq(received, ["hp:7"], "Signal 回调应收到默认参数和动态参数。")


func test_filter_map_delay_chain() -> void:
	var emitter := TestEmitter.new()
	var received: Array = []

	_utility.connect_signal(emitter.changed, func(value: int) -> void:
		received.append(value)
	).filter(func(value: int) -> bool:
		return value > 2
	).map(func(value: int) -> int:
		return value * 10
	).delay(0.001)

	emitter.emit_changed(1)
	emitter.emit_changed(3)

	await get_tree().create_timer(0.03).timeout

	assert_eq(received, [30], "链式 filter/map/delay 应按顺序处理参数。")


func test_debounce_keeps_last_emit() -> void:
	var emitter := TestEmitter.new()
	var received: Array = []

	_utility.connect_signal(emitter.changed, func(value: int) -> void:
		received.append(value)
	).debounce(0.02)

	emitter.emit_changed(1)
	await get_tree().create_timer(0.005).timeout
	emitter.emit_changed(2)
	await get_tree().create_timer(0.05).timeout

	assert_eq(received, [2], "防抖应只保留静默期后的最后一次触发。")


func test_connect_once_disconnects_after_first_emit() -> void:
	var emitter := TestEmitter.new()
	var count: Array = []

	_utility.connect_once(emitter.changed, func(value: int) -> void:
		count.append(value)
	)

	emitter.emit_changed(1)
	emitter.emit_changed(2)
	await get_tree().process_frame

	assert_eq(count, [1], "connect_once 应只触发一次。")
	assert_eq(_utility.get_connection_count(), 0, "一次性连接触发后应从工具追踪中移除。")


func test_disconnect_owner_removes_owned_connections() -> void:
	var emitter := TestEmitter.new()
	var listener_owner := TestOwner.new()
	var count: Array = []
	var callback := func(value: int) -> void:
		count.append(value)

	_utility.connect_signal(emitter.changed, callback, listener_owner)
	_utility.disconnect_owner(listener_owner)
	emitter.emit_changed(1)

	await get_tree().process_frame

	assert_true(count.is_empty(), "owner 清理后回调不应再触发。")
	assert_eq(_utility.get_connection_count(), 0, "owner 清理后连接计数应归零。")
