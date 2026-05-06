## 测试 GFSignalUtility 的安全连接、owner 清理和链式处理。
extends GutTest


# --- 常量 ---

const GFSignalUtilityBase = preload("res://addons/gf/utilities/gf_signal_utility.gd")


# --- 辅助子类 ---

class TestEmitter:
	extends RefCounted

	signal changed(value: int)
	signal optional_payload(value: Variant)

	func emit_changed(value: int) -> void:
		changed.emit(value)

	func emit_optional_payload(value: Variant) -> void:
		optional_payload.emit(value)


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


func test_connect_signal_preserves_declared_trailing_null_argument() -> void:
	var emitter := TestEmitter.new()
	var received: Array = []

	_utility.connect_signal(emitter.optional_payload, func(value: Variant) -> void:
		received.append(value)
	)
	emitter.emit_optional_payload(null)

	await get_tree().process_frame

	assert_eq(received, [null], "显式发出的 null 参数不应被当作占位默认值裁掉。")


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


func test_connect_once_does_not_mutate_existing_persistent_connection() -> void:
	var emitter := TestEmitter.new()
	var received: Array = []
	var callback := func(value: int) -> void:
		received.append(value)

	_utility.connect_signal(emitter.changed, callback)
	_utility.connect_once(emitter.changed, callback)

	emitter.emit_changed(1)
	emitter.emit_changed(2)
	await get_tree().process_frame

	assert_eq(received, [1, 1, 2], "同一回调的常驻连接和一次性连接应各自保持语义。")
	assert_eq(_utility.get_connection_count(), 1, "一次性连接移除后应保留常驻连接。")


func test_connect_signal_distinguishes_default_args() -> void:
	var emitter := TestEmitter.new()
	var received: Array = []
	var callback := func(prefix: String, value: int) -> void:
		received.append("%s:%s" % [prefix, value])

	_utility.connect_signal(emitter.changed, callback, null, ["a"])
	_utility.connect_signal(emitter.changed, callback, null, ["b"])
	emitter.emit_changed(5)

	await get_tree().process_frame

	assert_eq(received, ["a:5", "b:5"], "相同 Signal/回调但默认参数不同应保留为两个连接。")


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


func test_invalid_callback_is_not_tracked_as_connection() -> void:
	var emitter := TestEmitter.new()

	_utility.connect_signal(emitter.changed, Callable())

	assert_push_error("[GFSignalConnection] start 失败：callback 无效。")
	assert_eq(_utility.get_connection_count(), 0, "启动失败的连接不应残留在工具追踪列表中。")


func test_disconnect_signal_cancels_pending_delayed_callback() -> void:
	var emitter := TestEmitter.new()
	var received: Array = []
	var callback := func(value: int) -> void:
		received.append(value)

	var _connection: GFSignalConnection = _utility.connect_signal(emitter.changed, callback).delay(0.03)
	emitter.emit_changed(9)
	_utility.disconnect_signal(emitter.changed, callback)

	await get_tree().create_timer(0.06).timeout
	await get_tree().process_frame
	_connection = null

	assert_true(received.is_empty(), "延迟等待中的连接被断开后不应继续调用回调。")
	assert_eq(_utility.get_connection_count(), 0, "断开延迟连接后追踪计数应归零。")
