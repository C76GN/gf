extends GutTest


# --- 常量 ---

const GF_ASYNC_WAIT_SUPPORT = preload("res://addons/gf/standard/common/gf_async_wait_support.gd")


# --- 测试方法 ---

func test_await_signal_payload_safely_keeps_nine_signal_arguments() -> void:
	var emitter: WideSignalEmitter = WideSignalEmitter.new()
	add_child_autofree(emitter)

	emitter.call_deferred("emit_payload_ready")
	var result: Dictionary = await GF_ASYNC_WAIT_SUPPORT.await_signal_payload_safely(
		emitter.payload_ready,
		Callable(),
		null,
		1.0,
		false
	)

	assert_true(GFVariantData.get_option_bool(result, "completed"), "信号发出后等待应完成。")
	assert_eq(GFVariantData.get_option_array(result, "args"), [1, 2, 3, 4, 5, 6, 7, 8, 9], "Signal payload 应保留 9 个参数。")


# --- 内部类 ---

class WideSignalEmitter:
	extends Node

	signal payload_ready(
		first: int,
		second: int,
		third: int,
		fourth: int,
		fifth: int,
		sixth: int,
		seventh: int,
		eighth: int,
		ninth: int
	)

	func emit_payload_ready() -> void:
		payload_ready.emit(1, 2, 3, 4, 5, 6, 7, 8, 9)
