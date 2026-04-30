## 测试 BindableProperty 的值绑定、信号触发及 unbind_all 清理功能。
extends GutTest


# --- 私有变量 ---

var _prop: BindableProperty


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_prop = BindableProperty.new(0)


func after_each() -> void:
	_prop = null


# --- 测试：基本功能 ---

## 验证构造函数设置的初始值正确。
func test_initial_value() -> void:
	var prop_str := BindableProperty.new("hello")
	assert_eq(prop_str.get_value(), "hello", "初始值应为构造时传入的值。")


## 验证 get_value 返回当前存储的值。
func test_get_value() -> void:
	_prop.set_value(7)
	assert_eq(_prop.get_value(), 7, "get_value 应返回最新设置的值。")


## 验证 value 属性与 get_value()/set_value() 保持一致。
func test_value_property_gets_and_sets_value() -> void:
	_prop.value = 9

	assert_eq(_prop.value, 9, "value 属性应返回最新设置的值。")
	assert_eq(_prop.get_value(), 9, "value 属性写入应同步到底层值。")


# --- 测试：信号 ---

## 验证设置新值时 value_changed 信号被发出，并携带正确的 old_value 和 new_value。
func test_set_value_emits_signal() -> void:
	watch_signals(_prop)
	_prop.set_value(10)
	assert_signal_emitted_with_parameters(_prop, "value_changed", [0, 10])


## 验证设置相同值时不触发 value_changed 信号。
func test_set_same_value_no_signal() -> void:
	_prop.set_value(5)
	watch_signals(_prop)
	_prop.set_value(5)
	assert_signal_not_emitted(_prop, "value_changed", "设置相同值不应触发 value_changed 信号。")


## 验证信号的 old_value / new_value 参数准确。
func test_signal_parameters_are_correct() -> void:
	_prop.set_value(3)
	watch_signals(_prop)
	_prop.set_value(99)
	var params: Array = get_signal_parameters(_prop, "value_changed")
	assert_eq(params[0], 3, "old_value 应为变化前的值 3。")
	assert_eq(params[1], 99, "new_value 应为变化后的值 99。")


## 验证 force_emit 可在引用类型原地变更后主动广播。
func test_force_emit_broadcasts_current_value() -> void:
	var prop := BindableProperty.new({ "hp": 10 })
	watch_signals(prop)

	var value := prop.get_value() as Dictionary
	value["hp"] = 5
	prop.force_emit()

	assert_signal_emitted_with_parameters(prop, "value_changed", [value, value])


# --- 测试：unbind_all ---

## 验证 unbind_all 后，修改值不再调用已断开的回调。
func test_unbind_all() -> void:
	var state := {"count": 0}
	_prop.value_changed.connect(func(_o: Variant, _n: Variant) -> void: state.count += 1)

	_prop.set_value(1)
	assert_eq(state.count, 1, "断开前，修改值应触发回调。")

	_prop.unbind_all()
	_prop.set_value(2)
	assert_eq(state.count, 1, "unbind_all 后，修改值不应再触发已断开的回调。")


## 验证 unbind_all 断开多个连接。
func test_unbind_all_multiple_listeners() -> void:
	var state := {"total": 0}
	_prop.value_changed.connect(func(_o: Variant, _n: Variant) -> void: state.total += 1)
	_prop.value_changed.connect(func(_o: Variant, _n: Variant) -> void: state.total += 10)

	_prop.unbind_all()
	_prop.set_value(42)

	assert_eq(state.total, 0, "unbind_all 后所有连接都应断开，total 应保持为 0。")


## 验证 unbind_all 后可以重新绑定。
func test_rebind_after_unbind_all() -> void:
	var state := {"count": 0}
	_prop.value_changed.connect(func(_o: Variant, _n: Variant) -> void: state.count += 1)
	_prop.unbind_all()

	_prop.value_changed.connect(func(_o: Variant, _n: Variant) -> void: state.count += 100)
	_prop.set_value(5)

	assert_eq(state.count, 100, "unbind_all 后重新绑定的回调应正常工作。")


## 验证 unbind_all 会同时清理 bind_to 附加的 tree_exited 监听。
func test_unbind_all_removes_tree_exited_helper_connections() -> void:
	var node := Node.new()
	add_child_autofree(node)

	_prop.bind_to(node, func(_o: Variant, _n: Variant) -> void: pass)
	assert_eq(node.tree_exited.get_connections().size(), 1, "bind_to 后应注册一个 tree_exited 自动解绑监听。")

	_prop.unbind_all()
	assert_eq(node.tree_exited.get_connections().size(), 0, "unbind_all 后不应残留 tree_exited 自动解绑监听。")


## 验证 unbind 只移除指定节点与回调，不影响其他监听者。
func test_unbind_removes_single_node_binding_only() -> void:
	var first_count := {"value": 0}
	var second_count := {"value": 0}
	var first_node := Node.new()
	var second_node := Node.new()
	var first_callback := func(_o: Variant, _n: Variant) -> void:
		first_count.value += 1
	var second_callback := func(_o: Variant, _n: Variant) -> void:
		second_count.value += 1
	add_child_autofree(first_node)
	add_child_autofree(second_node)

	_prop.bind_to(first_node, first_callback)
	_prop.bind_to(second_node, second_callback)
	_prop.unbind(first_node, first_callback)
	_prop.set_value(1)

	assert_eq(first_count.value, 0, "被 unbind 的回调不应再触发。")
	assert_eq(second_count.value, 1, "其他节点绑定不应受影响。")
	assert_eq(first_node.tree_exited.get_connections().size(), 0, "指定节点的 tree_exited 辅助连接应被清理。")


# --- 测试：bind_to (Task 4) ---

## 验证 bind_to 能在节点销毁时自动解绑。
func test_bind_to_auto_unbinds_on_tree_exited() -> void:
	var state := {"count": 0}
	var node := Node.new()
	add_child_autofree(node)
	
	_prop.bind_to(node, func(_o, _n): state.count += 1)
	
	_prop.set_value(1)
	assert_eq(state.count, 1, "解绑前应触发一次。")
	
	# 模拟节点退出场景树
	remove_child(node)
	node.emit_signal("tree_exited")
	
	_prop.set_value(2)
	assert_eq(state.count, 1, "节点退出树后，不应再触发回调（已自动解绑）。")
	
	node.free()


## 验证同一 Callable 绑定到多个节点时，一个节点退出不会误断开仍存活的绑定。
func test_bind_to_same_callable_survives_until_last_bound_node_exits() -> void:
	var state := {"count": 0}
	var first_node := Node.new()
	var second_node := Node.new()
	var callback := func(_o: Variant, _n: Variant) -> void:
		state.count += 1
	add_child_autofree(first_node)
	add_child_autofree(second_node)

	_prop.bind_to(first_node, callback)
	_prop.bind_to(second_node, callback)
	_prop.set_value(1)

	remove_child(first_node)
	first_node.tree_exited.emit()
	_prop.set_value(2)

	remove_child(second_node)
	second_node.tree_exited.emit()
	_prop.set_value(3)

	assert_eq(state.count, 2, "同一回调仍有存活节点绑定时应保持连接，最后一个节点退出后才断开。")

	first_node.free()
	second_node.free()
