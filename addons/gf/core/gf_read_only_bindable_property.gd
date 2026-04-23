## GFReadOnlyBindableProperty: 只读响应式属性视图。
##
## 复用 `BindableProperty` 的读取、信号和生命周期绑定能力，
## 但阻止外部直接调用 `set_value()` 修改底层值。
class_name GFReadOnlyBindableProperty
extends BindableProperty


# --- Godot 生命周期方法 ---

## 构造函数。
## @param default_value: 属性的初始值。
func _init(default_value: Variant = null) -> void:
	super._init(default_value)


# --- 公共方法 ---

## 只读视图不允许外部直接写入值。
## @param _new_value: 调用方尝试写入的新值。
func set_value(_new_value: Variant) -> void:
	push_error("[GFReadOnlyBindableProperty] 当前属性为只读视图，请通过宿主对象修改其值。")


# --- 私有方法 ---

func _set_value_from_owner(new_value: Variant) -> void:
	super.set_value(new_value)
