## GFBindableProperty: 响应式数据绑定属性容器。
##
## 封装一个 Variant 值，当值发生变化时自动发出 value_changed 信号。
## 可用于 Controller 直接监听 Model 数据变化，无需通过事件总线中转。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.17.0
class_name GFBindableProperty
extends RefCounted


# --- 信号 ---

## 当属性值被设置为不同的新值时发出。
## [br]
## @api public
## [br]
## @param old_value: 变化前的旧值。
## [br]
## @param new_value: 变化后的新值。
## [br]
## @schema old_value {
##   "type": "Variant",
##   "description": "变化前的旧值。"
## }
## [br]
## @schema new_value {
##   "type": "Variant",
##   "description": "变化后的新值。"
## }
signal value_changed(old_value: Variant, new_value: Variant)


# --- 常量 ---

const _INSTANCE_GUARD: Script = preload("res://addons/gf/kernel/core/gf_instance_guard.gd")


# --- 公共变量 ---

## 当前属性值。设置该属性等价于调用 `set_value()`。
## [br]
## @api public
## [br]
## @schema value {
##   "type": "Variant",
##   "description": "当前属性值。"
## }
var value: Variant:
	get:
		return get_value()
	set(new_value):
		set_value(new_value)


# --- 私有变量 ---

var _value: Variant
var _node_bindings: Array[Dictionary] = []
var _owned_value_connections: Array[Callable] = []


# --- Godot 生命周期方法 ---

## 构造函数。
## [br]
## @api public
## [br]
## @param default_value: 属性的初始值，默认为 null。
## [br]
## @schema default_value {
##   "type": "Variant",
##   "description": "属性的初始值。"
## }
func _init(default_value: Variant = null) -> void:
	_value = default_value


# --- 公共方法 ---

## 获取当前属性值。
## [br]
## @api public
## [br]
## @return 当前存储的值。
## [br]
## @schema return {
##   "type": "Variant",
##   "description": "当前存储的值。"
## }
func get_value() -> Variant:
	return _value


## 设置属性值。仅当新值与旧值不同时，才会更新并发出 value_changed 信号。
## [br]
## @api public
## [br]
## @param new_value: 要设置的新值。
## [br]
## @schema new_value {
##   "type": "Variant",
##   "description": "要设置的新值。"
## }
func set_value(new_value: Variant) -> void:
	if _value == new_value:
		return
	var old_value: Variant = _value
	_value = new_value
	value_changed.emit(old_value, new_value)


## 订阅属性变化，并返回取消订阅函数。
## [br]
## @api public
## [br]
## @since 3.20.0
## [br]
## @param callback: 变化回调，签名应为 func(old_value: Variant, new_value: Variant)。
## [br]
## @param emit_current: 是否立即以当前值调用一次回调；为 true 时 old_value 和 new_value 都是当前值。
## [br]
## @return 可调用的取消订阅函数；callback 无效时返回空 Callable。
func subscribe(callback: Callable, emit_current: bool = false) -> Callable:
	if not callback.is_valid():
		push_error("[GFBindableProperty] subscribe 失败：callback 无效。")
		return Callable()
	if not value_changed.is_connected(callback):
		value_changed.connect(callback)
	if emit_current:
		callback.call(_value, _value)
	return _make_unsubscribe_callable(callback)


## 强制发出 value_changed 信号。
## 适合在 Array、Dictionary 或 Object 发生原地变更后，由业务层显式通知监听者。
## [br]
## @api public
func force_emit() -> void:
	value_changed.emit(_value, _value)


## 通过回调修改当前值并强制广播。
## [br]
## @api public
## [br]
## @param mutator: 修改当前值的回调。
## [br]
## @return 回调有效时返回 true。
func mutate(mutator: Callable) -> bool:
	if not mutator.is_valid():
		return false
	mutator.call(_value)
	force_emit()
	return true


## 向当前 Array 追加一个元素。
## [br]
## @api public
## [br]
## @param item: 要追加的元素。
## [br]
## @return 成功返回 true。
## [br]
## @schema item {
##   "type": "Variant",
##   "description": "要追加的元素。"
## }
func append_to_array(item: Variant) -> bool:
	if not (_value is Array):
		return false
	var array_value := _value as Array
	array_value.append(item)
	force_emit()
	return true


## 向当前 Array 追加多个元素。
## [br]
## @api public
## [br]
## @param items: 要追加的元素列表。
## [br]
## @return 成功返回 true。
## [br]
## @schema items {
##   "type": "Array",
##   "description": "要追加的元素列表。"
## }
func append_array(items: Array) -> bool:
	if not (_value is Array):
		return false
	var array_value := _value as Array
	array_value.append_array(items)
	force_emit()
	return true


## 从当前 Array 删除一个元素。
## [br]
## @api public
## [br]
## @param item: 要删除的元素。
## [br]
## @return 成功返回 true。
## [br]
## @schema item {
##   "type": "Variant",
##   "description": "要删除的元素。"
## }
func erase_from_array(item: Variant) -> bool:
	if not (_value is Array):
		return false
	var array_value := _value as Array
	if not array_value.has(item):
		return false
	array_value.erase(item)
	force_emit()
	return true


## 设置当前 Dictionary 的一个键值。
## [br]
## @api public
## [br]
## @param key: 键。
## [br]
## @param new_value: 新值。
## [br]
## @return 成功返回 true。
## [br]
## @schema key {
##   "type": "Variant",
##   "description": "Dictionary 键。"
## }
## [br]
## @schema new_value {
##   "type": "Variant",
##   "description": "Dictionary 新值。"
## }
func set_dictionary_value(key: Variant, new_value: Variant) -> bool:
	if not (_value is Dictionary):
		return false
	var dictionary_value := _value as Dictionary
	dictionary_value[key] = new_value
	force_emit()
	return true


## 从当前 Dictionary 删除一个键。
## [br]
## @api public
## [br]
## @param key: 键。
## [br]
## @return 成功返回 true。
## [br]
## @schema key {
##   "type": "Variant",
##   "description": "Dictionary 键。"
## }
func erase_dictionary_key(key: Variant) -> bool:
	if not (_value is Dictionary):
		return false
	var dictionary_value := _value as Dictionary
	if not dictionary_value.has(key):
		return false
	dictionary_value.erase(key)
	force_emit()
	return true


## 清空当前 Array 或 Dictionary。
## [br]
## @api public
## [br]
## @return 成功返回 true。
func clear_collection() -> bool:
	if _value is Array:
		var array_value := _value as Array
		if array_value.is_empty():
			return false
		array_value.clear()
		force_emit()
		return true
	if _value is Dictionary:
		var dictionary_value := _value as Dictionary
		if dictionary_value.is_empty():
			return false
		dictionary_value.clear()
		force_emit()
		return true
	return false


## 断开指定 Node 与 Callable 的绑定关系。
## [br]
## @api public
## [br]
## @param node: 绑定生命周期的节点；已失效对象会触发失效绑定清理。
## [br]
## @param callable: 要解绑的回调函数。
## [br]
## @schema node {
##   "type": "Variant",
##   "description": "绑定生命周期的 Node；已失效对象会触发失效绑定清理。"
## }
func unbind(node: Variant, callable: Callable) -> void:
	if not callable.is_valid():
		return

	if is_instance_valid(node) and node is Node:
		_disconnect_node_binding(node as Node, callable)
	else:
		_prune_invalid_node_bindings()
	_release_value_connection_if_unbound(callable)


## 断开所有由 bind_to() 创建的 Node 生命周期绑定。
## [br]
## @api public
func unbind_all() -> void:
	unbind_all_node_bindings()


## 断开所有由 bind_to() 创建的 Node 生命周期绑定。
## [br]
## @api public
func unbind_all_node_bindings() -> void:
	for binding: Dictionary in _node_bindings:
		var node_ref: WeakRef = binding.get("node_ref")
		var exit_callable: Callable = binding.get("exit_callable", Callable())
		var node: Node = _INSTANCE_GUARD._get_live_node_from_ref(node_ref)
		if is_instance_valid(node) and node.tree_exited.is_connected(exit_callable):
			node.tree_exited.disconnect(exit_callable)

	_node_bindings.clear()
	for callable: Callable in _owned_value_connections:
		if callable.is_valid() and value_changed.is_connected(callable):
			value_changed.disconnect(callable)
	_owned_value_connections.clear()


## 断开 value_changed 信号上的所有订阅者，并清理 bind_to() 创建的 Node 生命周期绑定。
## [br]
## @api public
func disconnect_all_subscribers() -> void:
	for connection: Dictionary in value_changed.get_connections():
		value_changed.disconnect(connection["callable"])

	for binding: Dictionary in _node_bindings:
		var node_ref: WeakRef = binding.get("node_ref")
		var exit_callable: Callable = binding.get("exit_callable", Callable())
		var node: Node = _INSTANCE_GUARD._get_live_node_from_ref(node_ref)
		if is_instance_valid(node) and node.tree_exited.is_connected(exit_callable):
			node.tree_exited.disconnect(exit_callable)

	_node_bindings.clear()
	_owned_value_connections.clear()


## 绑定信号到一个 Node 的 Callable。当该 Node 退出场景树时，自动断开连接。
## [br]
## @api public
## [br]
## @param node: 监听生命周期的节点。
## [br]
## @param callable: 绑定的回调函数。
func bind_to(node: Node, callable: Callable) -> void:
	if not is_instance_valid(node):
		push_error("[GFBindableProperty] 尝试绑定到一个无效的 Node。")
		return

	if not callable.is_valid():
		push_error("[GFBindableProperty] 尝试绑定一个无效的 Callable。")
		return

	if _find_node_binding_index(node, callable) != -1:
		return

	if not value_changed.is_connected(callable):
		value_changed.connect(callable)
		_track_owned_value_connection(callable)

	var exit_callable := _on_node_exited.bind(node, callable)
	if not node.tree_exited.is_connected(exit_callable):
		node.tree_exited.connect(exit_callable, CONNECT_ONE_SHOT)

	_node_bindings.append({
		"node_ref": weakref(node),
		"callable": callable,
		"exit_callable": exit_callable,
	})


# --- 私有/辅助方法 ---


func _on_node_exited(node: Node, callable: Callable) -> void:
	_disconnect_node_binding(node, callable)
	_release_value_connection_if_unbound(callable)


func _make_unsubscribe_callable(callback: Callable) -> Callable:
	var property_ref := weakref(self)
	return func() -> void:
		var property := property_ref.get_ref() as GFBindableProperty
		if property == null or not callback.is_valid():
			return
		if property.value_changed.is_connected(callback):
			property.value_changed.disconnect(callback)


func _find_node_binding_index(node: Node, callable: Callable) -> int:
	_prune_invalid_node_bindings()
	for i: int in range(_node_bindings.size()):
		var binding: Dictionary = _node_bindings[i]
		var node_ref: WeakRef = binding.get("node_ref")
		var tracked_node: Node = _INSTANCE_GUARD._get_live_node_from_ref(node_ref)
		if tracked_node == node and binding.get("callable") == callable:
			return i

	return -1


func _disconnect_node_binding(node: Node, callable: Callable) -> void:
	var binding_index := _find_node_binding_index(node, callable)
	if binding_index == -1:
		return

	var binding: Dictionary = _node_bindings[binding_index]
	var exit_callable: Callable = binding.get("exit_callable", Callable())
	if is_instance_valid(node) and exit_callable.is_valid() and node.tree_exited.is_connected(exit_callable):
		node.tree_exited.disconnect(exit_callable)
	_node_bindings.remove_at(binding_index)


func _has_node_binding_for_callable(callable: Callable, prune_invalid: bool = true) -> bool:
	if prune_invalid:
		_prune_invalid_node_bindings()

	for binding: Dictionary in _node_bindings:
		if binding.get("callable") == callable:
			return true

	return false


func _prune_invalid_node_bindings() -> void:
	var pruned_callables: Array[Callable] = []
	for i in range(_node_bindings.size() - 1, -1, -1):
		var binding: Dictionary = _node_bindings[i]
		var node_ref: WeakRef = binding.get("node_ref")
		var tracked_node: Node = _INSTANCE_GUARD._get_live_node_from_ref(node_ref)
		if not is_instance_valid(tracked_node):
			var pruned_callable: Callable = binding.get("callable", Callable())
			if pruned_callable.is_valid() and not pruned_callables.has(pruned_callable):
				pruned_callables.append(pruned_callable)
			_node_bindings.remove_at(i)

	for pruned_callable: Callable in pruned_callables:
		_release_value_connection_if_unbound(pruned_callable, false)


func _track_owned_value_connection(callable: Callable) -> void:
	if callable.is_valid() and not _owned_value_connections.has(callable):
		_owned_value_connections.append(callable)


func _release_value_connection_if_unbound(callable: Callable, prune_invalid: bool = true) -> void:
	if not callable.is_valid():
		return
	if _has_node_binding_for_callable(callable, prune_invalid):
		return
	if not _owned_value_connections.has(callable):
		return

	_owned_value_connections.erase(callable)
	if value_changed.is_connected(callable):
		value_changed.disconnect(callable)
