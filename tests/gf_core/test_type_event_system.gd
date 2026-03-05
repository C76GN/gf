# tests/gf_core/test_type_event_system.gd

## 测试 TypeEventSystem 的注册、发送、注销及遍历中注销的边界情况。
extends GutTest


# --- 私有变量 ---

var _system: TypeEventSystem


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_system = TypeEventSystem.new()


func after_each() -> void:
	_system = null


# --- 辅助类型 ---

class TestEventA:
	var value: int = 0
	var is_consumed: bool = false


class TestEventB:
	pass


# --- 测试：类型事件 ---

## 验证注册后，send 能正确调用回调。
func test_register_and_send() -> void:
	var state := {"value": - 1}
	var script_a: Script = TestEventA
	_system.register(script_a, func(e: TestEventA) -> void: state.value = e.value)

	var evt := TestEventA.new()
	evt.value = 42
	_system.send(evt)

	assert_eq(state.value, 42, "回调应接收到事件并读取 value。")


## 验证 unregister 后，send 不再调用该回调。
func test_unregister() -> void:
	var state := {"count": 0}
	var script_a: Script = TestEventA
	var cb: Callable = func(_e: TestEventA) -> void: state.count += 1

	_system.register(script_a, cb)
	_system.unregister(script_a, cb)
	_system.send(TestEventA.new())

	assert_eq(state.count, 0, "注销后不应再被调用。")


## 验证在回调 A 内注销回调 B 时，回调 B 在本次 send 中不被执行（遍历中注销边界情况）。
func test_unregister_during_traversal() -> void:
	var state := {"order": [], "cb_b": Callable()}
	var script_a: Script = TestEventA

	var cb_a: Callable = func(_e: TestEventA) -> void:
		state.order.append("A")
		_system.unregister(script_a, state.cb_b)

	state.cb_b = func(_e: TestEventA) -> void:
		state.order.append("B")

	_system.register(script_a, cb_a)
	_system.register(script_a, state.cb_b)
	_system.send(TestEventA.new())

	assert_eq(state.order.size(), 1, "回调 B 被注销后不应在本次 send 中执行。")
	assert_eq(state.order[0], "A", "只有回调 A 应被执行。")


## 验证多个监听器都能收到事件。
func test_multiple_listeners() -> void:
	var state := {"count": 0}
	var script_a: Script = TestEventA
	_system.register(script_a, func(_e: TestEventA) -> void: state.count += 1)
	_system.register(script_a, func(_e: TestEventA) -> void: state.count += 1)
	_system.send(TestEventA.new())

	assert_eq(state.count, 2, "两个监听器都应被调用。")


## 验证 clear 后，send 不再触发任何回调。
func test_clear() -> void:
	var state := {"called": false}
	var script_a: Script = TestEventA
	_system.register(script_a, func(_e: TestEventA) -> void: state.called = true)
	_system.clear()
	_system.send(TestEventA.new())

	assert_false(state.called, "clear 后不应再触发回调。")


# --- 测试：简单事件 ---

## 验证简单事件注册与发送。
func test_send_simple_register_and_send() -> void:
	var state := {"payload": null}
	var event_id: StringName = &"test_event"

	_system.register_simple(event_id, func(p: Variant) -> void: state.payload = p)
	_system.send_simple(event_id, 99)

	assert_eq(state.payload, 99, "简单事件回调应接收到正确的 payload。")


## 验证简单事件在回调内注销另一回调时，被注销的回调不被执行。
func test_send_simple_unregister_during_traversal() -> void:
	var state := {"order": [], "cb_b": Callable()}
	var event_id: StringName = &"traversal_test"

	var cb_a: Callable = func(_p: Variant) -> void:
		state.order.append("A")
		_system.unregister_simple(event_id, state.cb_b)

	state.cb_b = func(_p: Variant) -> void:
		state.order.append("B")

	_system.register_simple(event_id, cb_a)
	_system.register_simple(event_id, state.cb_b)
	_system.send_simple(event_id)

	assert_eq(state.order.size(), 1, "简单事件：回调 B 被注销后不应在本次 send 中执行。")
	assert_eq(state.order[0], "A", "只有回调 A 应被执行。")


## 验证注销简单事件后不再触发。
func test_send_simple_unregister() -> void:
	var state := {"called": false}
	var event_id: StringName = &"remove_test"

	var cb: Callable = func(_p: Variant) -> void: state.called = true
	_system.register_simple(event_id, cb)
	_system.unregister_simple(event_id, cb)
	_system.send_simple(event_id)

	assert_false(state.called, "注销后简单事件回调不应被触发。")


# --- 测试：优先级排序 ---

## 验证高优先级回调先于低优先级执行。
func test_priority_high_executes_first() -> void:
	var state := {"order": []}
	var script_a: Script = TestEventA
	_system.register(script_a, func(_e: TestEventA) -> void: state.order.append("low"), 0)
	_system.register(script_a, func(_e: TestEventA) -> void: state.order.append("high"), 10)
	_system.send(TestEventA.new())

	assert_eq(state.order.size(), 2, "两个回调都应被调用。")
	assert_eq(state.order[0], "high", "高优先级应先执行。")
	assert_eq(state.order[1], "low", "低优先级应后执行。")


## 验证相同优先级保持注册顺序。
func test_same_priority_keeps_registration_order() -> void:
	var state := {"order": []}
	var script_a: Script = TestEventA
	_system.register(script_a, func(_e: TestEventA) -> void: state.order.append("first"), 5)
	_system.register(script_a, func(_e: TestEventA) -> void: state.order.append("second"), 5)
	_system.send(TestEventA.new())

	assert_eq(state.order[0], "first", "同优先级应按注册顺序执行。")
	assert_eq(state.order[1], "second", "同优先级应按注册顺序执行。")


# --- 测试：事件消费拦截 ---

## 验证高优先级设置 is_consumed 后，低优先级不被执行。
func test_consumed_event_stops_propagation() -> void:
	var state := {"order": []}
	var script_a: Script = TestEventA

	_system.register(script_a, func(e: TestEventA) -> void:
		state.order.append("high")
		e.is_consumed = true
	, 10)

	_system.register(script_a, func(_e: TestEventA) -> void:
		state.order.append("low")
	, 0)

	var evt := TestEventA.new()
	_system.send(evt)

	assert_eq(state.order.size(), 1, "消费后应只有高优先级被调用。")
	assert_eq(state.order[0], "high", "只有高优先级回调应执行。")
	assert_true(evt.is_consumed, "事件应被标记为已消费。")


## 验证未设置 is_consumed 时所有优先级正常触发。
func test_unconsumed_event_propagates_to_all() -> void:
	var state := {"count": 0}
	var script_a: Script = TestEventA
	_system.register(script_a, func(_e: TestEventA) -> void: state.count += 1, 10)
	_system.register(script_a, func(_e: TestEventA) -> void: state.count += 1, 5)
	_system.register(script_a, func(_e: TestEventA) -> void: state.count += 1, 0)
	_system.send(TestEventA.new())

	assert_eq(state.count, 3, "未消费时所有优先级回调都应被调用。")


## 验证三级优先级中，中间级消费后最低级不执行。
func test_mid_priority_consumes() -> void:
	var state := {"order": []}
	var script_a: Script = TestEventA

	_system.register(script_a, func(_e: TestEventA) -> void:
		state.order.append("high")
	, 10)

	_system.register(script_a, func(e: TestEventA) -> void:
		state.order.append("mid")
		e.is_consumed = true
	, 5)

	_system.register(script_a, func(_e: TestEventA) -> void:
		state.order.append("low")
	, 0)

	_system.send(TestEventA.new())

	assert_eq(state.order.size(), 2, "中间级消费后应只有高和中被调用。")
	assert_eq(state.order[0], "high", "高优先级应先执行。")
	assert_eq(state.order[1], "mid", "中优先级应第二执行。")
