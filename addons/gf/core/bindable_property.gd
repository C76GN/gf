# addons/gf/core/bindable_property.gd

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
