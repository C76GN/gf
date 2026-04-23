## BindableProperty: 响应式数据绑定属性容器。
##
## 封装一个 Variant 值，当值发生变化时自动发出 value_changed 信号。
## 可用于 Controller 直接监听 Model 数据变化，无需通过事件总线中转。
class_name BindableProperty
extends RefCounted


# --- 信号 ---

## 当属性值被设置为不同的新值时发出。
## @param old_value: 变化前的旧值。
## @param new_value: 变化后的新值。
signal value_changed(old_value: Variant, new_value: Variant)


# --- 私有变量 ---

var _value: Variant
var _node_bindings: Array[Dictionary] = []


# --- Godot 生命周期方法 ---

## 构造函数。
## @param default_value: 属性的初始值，默认为 null。
func _init(default_value: Variant = null) -> void:
	_value = default_value


# --- 公共方法 ---

## 获取当前属性值。
## @return 当前存储的值。
func get_value() -> Variant:
	return _value


## 设置属性值。仅当新值与旧值不同时，才会更新并发出 value_changed 信号。
## @param new_value: 要设置的新值。
func set_value(new_value: Variant) -> void:
	if _value == new_value:
		return
	var old_value: Variant = _value
	_value = new_value
	value_changed.emit(old_value, new_value)


## 断开 value_changed 信号上的所有连接，用于 UI 节点销毁时手动清理绑定关系。
func unbind_all() -> void:
	for connection: Dictionary in value_changed.get_connections():
		value_changed.disconnect(connection["callable"])

	for binding: Dictionary in _node_bindings:
		var node_ref: WeakRef = binding.get("node_ref")
		var exit_callable: Callable = binding.get("exit_callable", Callable())
		var node := node_ref.get_ref() as Node if node_ref != null else null
		if is_instance_valid(node) and node.tree_exited.is_connected(exit_callable):
			node.tree_exited.disconnect(exit_callable)

	_node_bindings.clear()


## 绑定信号到一个 Node 的 Callable。当该 Node 退出场景树时，自动断开连接。
## @param node: 监听生命周期的节点。
## @param callable: 绑定的回调函数。
func bind_to(node: Node, callable: Callable) -> void:
	if not is_instance_valid(node):
		push_error("[BindableProperty] 尝试绑定到一个无效的 Node。")
		return
		
	if not callable.is_valid():
		push_error("[BindableProperty] 尝试绑定一个无效的 Callable。")
		return
		
	# 连接值变更信号
	if not value_changed.is_connected(callable):
		value_changed.connect(callable)

	if _find_node_binding_index(node, callable) != -1:
		return

	# 监听节点的 tree_exited 信号，实现自动注销
	var exit_callable := _on_node_exited.bind(node, callable)
	if not node.tree_exited.is_connected(exit_callable):
		node.tree_exited.connect(exit_callable, CONNECT_ONE_SHOT)

	_node_bindings.append({
		"node_ref": weakref(node),
		"callable": callable,
		"exit_callable": exit_callable,
	})


# --- 私有方法 ---


func _on_node_exited(node: Node, callable: Callable) -> void:
	_remove_node_binding(node, callable)
	if value_changed.is_connected(callable):
		value_changed.disconnect(callable)


func _find_node_binding_index(node: Node, callable: Callable) -> int:
	for i in range(_node_bindings.size() - 1, -1, -1):
		var binding: Dictionary = _node_bindings[i]
		var node_ref: WeakRef = binding.get("node_ref")
		var tracked_node := node_ref.get_ref() as Node if node_ref != null else null
		if not is_instance_valid(tracked_node):
			_node_bindings.remove_at(i)
			continue

		if tracked_node == node and binding.get("callable") == callable:
			return i

	return -1


func _remove_node_binding(node: Node, callable: Callable) -> void:
	var binding_index := _find_node_binding_index(node, callable)
	if binding_index != -1:
		_node_bindings.remove_at(binding_index)
