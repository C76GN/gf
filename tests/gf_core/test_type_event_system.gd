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


class SimpleReceiver:
	var payload: Variant = null

	func on_simple_event(p_payload: Variant) -> void:
		payload = p_payload


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


## 验证在回调内注销自身时，不会崩溃且逻辑正确。
func test_unregister_self_during_traversal() -> void:
	var state := {"count": 0, "cb_a": Callable()}
	var script_a: Script = TestEventA

	state.cb_a = func(_e: TestEventA) -> void:
		state.count += 1
		_system.unregister(script_a, state.cb_a)

	_system.register(script_a, state.cb_a)
	_system.send(TestEventA.new())
	_system.send(TestEventA.new())

	assert_eq(state.count, 1, "回调应该只执行一次，并在本次调用后注销自身。")


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


## 验证简单事件支持对象方法回调，并会走签名校验路径。
func test_send_simple_register_method_callback() -> void:
	var receiver := SimpleReceiver.new()
	var event_id: StringName = &"method_simple_event"

	_system.register_simple(event_id, Callable(receiver, "on_simple_event"))
	_system.send_simple(event_id, "ok")

	assert_eq(receiver.payload, "ok", "对象方法形式的简单事件回调应接收到 payload。")


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


## 验证简单事件回调注销自身时，不会崩溃且逻辑正确。
func test_send_simple_unregister_self_during_traversal() -> void:
	var state := {"count": 0, "cb_a": Callable()}
	var event_id: StringName = &"self_traversal_test"

	state.cb_a = func(_p: Variant) -> void:
		state.count += 1
		_system.unregister_simple(event_id, state.cb_a)

	_system.register_simple(event_id, state.cb_a)
	_system.send_simple(event_id)
	_system.send_simple(event_id)

	assert_eq(state.count, 1, "回调应该只执行一次，并在本次调用后注销自身。")


## 验证注销简单事件后不再触发。
func test_send_simple_unregister() -> void:
	var state := {"called": false}
	var event_id: StringName = &"remove_test"

	var cb: Callable = func(_p: Variant) -> void: state.called = true
	_system.register_simple(event_id, cb)
	_system.unregister_simple(event_id, cb)
	_system.send_simple(event_id)

	assert_false(state.called, "注销后简单事件回调不应被触发。")


## 验证嵌套简单事件期间注册的新回调不会在当前派发链中提前生效。
func test_send_simple_register_during_nested_dispatch_waits_for_outermost_flush() -> void:
	var state := {"order": [], "nested_sent": false, "late_cb": Callable()}
	var event_id: StringName = &"nested_simple_event"

	state.late_cb = func(_p: Variant) -> void:
		state.order.append("late")

	var cb_outer: Callable = func(_p: Variant) -> void:
		state.order.append("outer")
		if not state.nested_sent:
			state.nested_sent = true
			_system.register_simple(event_id, state.late_cb)
			_system.send_simple(event_id)

	var cb_existing: Callable = func(_p: Variant) -> void:
		state.order.append("existing")

	_system.register_simple(event_id, cb_outer)
	_system.register_simple(event_id, cb_existing)

	_system.send_simple(event_id)

	assert_eq(state.order, ["outer", "outer", "existing", "existing"], "嵌套简单事件期间新增回调应等最外层结束后才生效。")

	_system.send_simple(event_id)
	assert_eq(state.order.slice(4), ["outer", "existing", "late"], "下一次简单事件派发应包含之前新增的回调。")


## 验证同一轮简单事件中先注册再注销的回调不会在 flush 后残留。
func test_send_simple_register_then_unregister_during_dispatch_does_not_leave_listener() -> void:
	var state := {"count": 0, "late_cb": Callable()}
	var event_id: StringName = &"register_then_unregister_simple"

	state.late_cb = func(_p: Variant) -> void:
		state.count += 10

	var cb_outer: Callable = func(_p: Variant) -> void:
		state.count += 1
		_system.register_simple(event_id, state.late_cb)
		_system.unregister_simple(event_id, state.late_cb)

	_system.register_simple(event_id, cb_outer)
	_system.send_simple(event_id)
	_system.send_simple(event_id)

	assert_eq(state.count, 2, "同一轮派发中先注册再注销的简单事件回调不应残留到下一次派发。")


# --- 测试：拥有者绑定 ---

## 验证注销 owner 会同时移除类型事件和简单事件监听。
func test_unregister_owner_removes_type_and_simple_listeners() -> void:
	var listener_owner := RefCounted.new()
	var state := {"typed": 0, "simple": 0}
	var script_a: Script = TestEventA
	var event_id: StringName = &"owned_simple"

	_system.register(script_a, func(_e: TestEventA) -> void: state.typed += 1, 0, listener_owner)
	_system.register_simple(event_id, func(_p: Variant) -> void: state.simple += 1, listener_owner)

	_system.send(TestEventA.new())
	_system.send_simple(event_id)
	_system.unregister_owner(listener_owner)
	_system.send(TestEventA.new())
	_system.send_simple(event_id)

	assert_eq(state.typed, 1, "owner 注销后类型事件不应继续触发。")
	assert_eq(state.simple, 1, "owner 注销后简单事件不应继续触发。")


## 验证派发中注销 owner 会阻止同一 owner 后续监听在本轮继续执行。
func test_unregister_owner_during_dispatch_skips_later_owned_callbacks() -> void:
	var listener_owner := RefCounted.new()
	var state := {"order": []}
	var script_a: Script = TestEventA

	_system.register(script_a, func(_e: TestEventA) -> void:
		state.order.append("first")
		_system.unregister_owner(listener_owner)
	, 10, listener_owner)
	_system.register(script_a, func(_e: TestEventA) -> void:
		state.order.append("second")
	, 0, listener_owner)

	_system.send(TestEventA.new())
	_system.send(TestEventA.new())

	assert_eq(state.order, ["first"], "派发中注销 owner 后，同 owner 后续回调和下一轮回调都不应执行。")


## 验证派发中注销 owner 后重新注册的新回调会在下一轮生效。
func test_unregister_owner_then_register_same_owner_during_dispatch_keeps_new_listener() -> void:
	var listener_owner := RefCounted.new()
	var state := {"order": [], "replacement": Callable()}
	var script_a: Script = TestEventA

	state.replacement = func(_e: TestEventA) -> void:
		state.order.append("replacement")

	_system.register(script_a, func(_e: TestEventA) -> void:
		state.order.append("old")
		_system.unregister_owner(listener_owner)
		_system.register(script_a, state.replacement, 0, listener_owner)
	, 10, listener_owner)

	_system.send(TestEventA.new())
	_system.send(TestEventA.new())

	assert_eq(state.order, ["old", "replacement"], "同一 owner 重新注册的新监听应在下一轮派发生效。")


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


# --- 测试：遍历中注册 (Task 6) ---

## 验证在回调内注册新事件，不会破坏当前遍历且能在下次生效。
func test_register_during_traversal() -> void:
	var state := {"count": 0}
	var script_a: Script = TestEventA

	var cb_inner: Callable = func(_e: TestEventA) -> void:
		state.count += 10

	var cb_outer: Callable = func(_e: TestEventA) -> void:
		state.count += 1
		_system.register(script_a, cb_inner)

	_system.register(script_a, cb_outer)

	# 第一次发送：触发 outer，注册 inner
	_system.send(TestEventA.new())
	assert_eq(state.count, 1, "第一次发送应只触发 outer，inner 暂存。")

	# 第二次发送：触发 outer 和 inner
	_system.send(TestEventA.new())
	assert_eq(state.count, 12, "第二次发送应触发 outer(1) 和 inner(10)。")


## 验证嵌套发送期间注册的新回调不会在内层或当前外层派发中提前生效。
func test_register_during_nested_dispatch_waits_for_outermost_flush() -> void:
	var state := {"order": [], "nested_sent": false, "late_cb": Callable()}
	var script_a: Script = TestEventA

	state.late_cb = func(_e: TestEventA) -> void:
		state.order.append("late")

	var cb_outer: Callable = func(_e: TestEventA) -> void:
		state.order.append("outer")
		if not state.nested_sent:
			state.nested_sent = true
			_system.register(script_a, state.late_cb)
			_system.send(TestEventA.new())

	var cb_existing: Callable = func(_e: TestEventA) -> void:
		state.order.append("existing")

	_system.register(script_a, cb_outer)
	_system.register(script_a, cb_existing)

	_system.send(TestEventA.new())

	assert_eq(state.order, ["outer", "outer", "existing", "existing"], "嵌套派发期间新增回调应等最外层结束后才生效。")

	_system.send(TestEventA.new())
	assert_eq(state.order.slice(4), ["outer", "existing", "late"], "下一次派发应包含之前新增的回调。")


## 验证同一轮类型事件中先注册再注销的回调不会在 flush 后残留。
func test_register_then_unregister_during_dispatch_does_not_leave_listener() -> void:
	var state := {"count": 0, "late_cb": Callable()}
	var script_a: Script = TestEventA

	state.late_cb = func(_e: TestEventA) -> void:
		state.count += 10

	var cb_outer: Callable = func(_e: TestEventA) -> void:
		state.count += 1
		_system.register(script_a, state.late_cb)
		_system.unregister(script_a, state.late_cb)

	_system.register(script_a, cb_outer)
	_system.send(TestEventA.new())
	_system.send(TestEventA.new())

	assert_eq(state.count, 2, "同一轮派发中先注册再注销的类型事件回调不应残留到下一次派发。")
