## GFReadOnlyBindableProperty: 只读响应式属性视图。
##
## 复用 `GFBindableProperty` 的读取、信号和生命周期绑定能力，
## 但阻止外部直接调用 `set_value()` 修改底层值。
class_name GFReadOnlyBindableProperty
extends GFBindableProperty


# --- 常量 ---

const _READ_ONLY_ERROR: String = "[GFReadOnlyBindableProperty] 当前属性为只读视图，请通过宿主对象修改其值。"


# --- Godot 生命周期方法 ---

## 构造函数。
## @param default_value: 属性的初始值。
func _init(default_value: Variant = null) -> void:
	super._init(default_value)


# --- 公共方法 ---

## 只读视图不允许外部直接写入值。
## @param _new_value: 调用方尝试写入的新值。
func set_value(_new_value: Variant) -> void:
	push_error(_READ_ONLY_ERROR)


## 只读视图不允许外部原地修改值。
## @param _mutator: 调用方尝试执行的修改回调。
## @return 始终返回 false。
func mutate(_mutator: Callable) -> bool:
	push_error(_READ_ONLY_ERROR)
	return false


## 只读视图不允许外部向数组追加元素。
## @param _item: 调用方尝试追加的元素。
## @return 始终返回 false。
func append_to_array(_item: Variant) -> bool:
	push_error(_READ_ONLY_ERROR)
	return false


## 只读视图不允许外部向数组追加元素列表。
## @param _items: 调用方尝试追加的元素列表。
## @return 始终返回 false。
func append_array(_items: Array) -> bool:
	push_error(_READ_ONLY_ERROR)
	return false


## 只读视图不允许外部从数组删除元素。
## @param _item: 调用方尝试删除的元素。
## @return 始终返回 false。
func erase_from_array(_item: Variant) -> bool:
	push_error(_READ_ONLY_ERROR)
	return false


## 只读视图不允许外部设置字典键值。
## @param _key: 调用方尝试设置的键。
## @param _new_value: 调用方尝试设置的新值。
## @return 始终返回 false。
func set_dictionary_value(_key: Variant, _new_value: Variant) -> bool:
	push_error(_READ_ONLY_ERROR)
	return false


## 只读视图不允许外部删除字典键。
## @param _key: 调用方尝试删除的键。
## @return 始终返回 false。
func erase_dictionary_key(_key: Variant) -> bool:
	push_error(_READ_ONLY_ERROR)
	return false


## 只读视图不允许外部清空集合。
## @return 始终返回 false。
func clear_collection() -> bool:
	push_error(_READ_ONLY_ERROR)
	return false


# --- 私有/辅助方法 ---

func _set_value_from_owner(new_value: Variant) -> void:
	super.set_value(new_value)
