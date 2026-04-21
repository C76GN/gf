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
		
	# 监听节点的 tree_exited 信号，实现自动注销
	if not node.tree_exited.is_connected(_on_node_exited.bind(node, callable)):
		node.tree_exited.connect(_on_node_exited.bind(node, callable), CONNECT_ONE_SHOT)


func _on_node_exited(node: Node, callable: Callable) -> void:
	if value_changed.is_connected(callable):
		value_changed.disconnect(callable)
