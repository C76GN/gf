## 测试声明式信号桥接资源。
extends GutTest


# --- 辅助子类 ---

class TestEmitter:
	extends Node

	signal changed(value: int, label: String)

	func emit_changed(value: int, label: String) -> void:
		changed.emit(value, label)


class WideEmitter:
	extends Node

	signal wide_changed(
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

	func emit_wide_changed() -> void:
		wide_changed.emit(1, 2, 3, 4, 5, 6, 7, 8, 9)


class TestListener:
	extends Node

	var received: Array = []

	func record(label: String, value: int, constant_value: String, context: Dictionary) -> void:
		received.append({
			"label": label,
			"value": value,
			"constant": constant_value,
			"context": context,
		})


class WideListener:
	extends Node

	var received: Array = []

	func record_wide(
		first: int,
		second: int,
		third: int,
		fourth: int,
		fifth: int,
		sixth: int,
		seventh: int,
		eighth: int,
		ninth: int
	) -> void:
		received = [first, second, third, fourth, fifth, sixth, seventh, eighth, ninth]


# --- 测试方法 ---

## 验证信号桥接可重排参数、追加常量和上下文。
func test_signal_bridge_maps_signal_arguments() -> void:
	var root := Node.new()
	add_child_autofree(root)

	var emitter := TestEmitter.new()
	emitter.name = "Emitter"
	root.add_child(emitter)

	var listener := TestListener.new()
	listener.name = "Listener"
	root.add_child(listener)

	var bridge := GFSignalBridge.new()
	bridge.source.source_path = root.get_path_to(emitter)
	bridge.source.signal_name = &"changed"
	bridge.target.target_path = root.get_path_to(listener)
	bridge.target.method_name = &"record"
	bridge.argument_indices = PackedInt32Array([1, 0])
	bridge.constant_args = ["fixed"]
	bridge.append_context = true

	var binding := bridge.connect_bridge(root)
	emitter.emit_changed(7, "hp")

	assert_true(binding != null and binding.is_active(), "桥接应创建有效运行绑定。")
	assert_eq(listener.received.size(), 1, "桥接目标应收到调用。")
	assert_eq(listener.received[0]["label"], "hp", "参数应支持重排。")
	assert_eq(listener.received[0]["value"], 7, "参数值应保持原始信号数据。")
	assert_eq(listener.received[0]["constant"], "fixed", "常量参数应追加到桥接参数后。")
	assert_eq(listener.received[0]["context"]["signal_args"], [7, "hp"], "上下文应包含原始信号参数。")


func test_signal_bridge_keeps_nine_signal_arguments() -> void:
	var root := Node.new()
	add_child_autofree(root)

	var emitter := WideEmitter.new()
	emitter.name = "Emitter"
	root.add_child(emitter)

	var listener := WideListener.new()
	listener.name = "Listener"
	root.add_child(listener)

	var bridge := GFSignalBridge.new()
	bridge.source.source_path = root.get_path_to(emitter)
	bridge.source.signal_name = &"wide_changed"
	bridge.target.target_path = root.get_path_to(listener)
	bridge.target.method_name = &"record_wide"

	var binding := bridge.connect_bridge(root)
	emitter.emit_wide_changed()

	assert_true(binding != null and binding.is_active(), "桥接应创建有效运行绑定。")
	assert_eq(listener.received, [1, 2, 3, 4, 5, 6, 7, 8, 9], "桥接应保留 9 个信号参数。")


## 验证信号桥接报告无效目标。
func test_signal_bridge_validation_reports_invalid_target() -> void:
	var root := Node.new()
	add_child_autofree(root)

	var emitter := TestEmitter.new()
	emitter.name = "Emitter"
	root.add_child(emitter)

	var listener := TestListener.new()
	listener.name = "Listener"
	root.add_child(listener)

	var bridge := GFSignalBridge.new()
	bridge.source.source_path = root.get_path_to(emitter)
	bridge.source.signal_name = &"changed"
	bridge.target.target_path = root.get_path_to(listener)
	bridge.target.method_name = &"missing"

	var report := bridge.get_validation_report(root)

	assert_false(report["ok"], "无效目标应产生校验错误。")
	assert_eq(report["issues"][0]["kind"], "invalid_callable_target", "校验报告应包含目标错误。")
	assert_eq(report["error_count"], 1, "校验报告应统计错误数量。")
	assert_eq(report["issue_count"], 1, "校验报告应统计问题总数。")
	assert_eq(report["issues"][0]["path"], "target", "校验问题应包含通用路径字段。")
