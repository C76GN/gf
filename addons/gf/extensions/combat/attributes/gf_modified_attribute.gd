## GFModifiedAttribute: 带修饰器公式的响应式属性。
## 
## 持有基础值并管理多个修饰器 (GFModifier)。
## 内部使用公式 (Base + BaseAdd) * (1.0 + PercentAdd) + FinalAdd 进行自动重算。
## 对外通过只读的 current_value 暴露响应式结果，方便 UI 绑定。
## [br]
## @api public
## [br]
## @category runtime_handle
## [br]
## @since 3.17.0
class_name GFModifiedAttribute
extends RefCounted


# --- 常量 ---

const _READ_ONLY_BINDABLE_PROPERTY_SCRIPT: Script = preload("res://addons/gf/kernel/core/gf_read_only_bindable_property.gd")


# --- 公共变量 ---

## 属性的只读响应式当前值。
## [br]
## @api public
var current_value: GFBindableProperty:
	get:
		return _current_value_view


# --- 私有变量 ---

var _current_value_view: GFBindableProperty
var _base_value: float = 0.0
var _modifiers: Array[GFModifier] = []


# --- Godot 生命周期方法 ---

func _init(p_base_value: float = 0.0) -> void:
	_base_value = p_base_value
	_current_value_view = _READ_ONLY_BINDABLE_PROPERTY_SCRIPT.new(_base_value)
	_recalculate()


# --- 公共方法 ---

## 设置基础值。
## [br]
## @api public
## [br]
## @param p_value: 新的基础值。
func set_base_value(p_value: float) -> void:
	if _base_value == p_value:
		return
	_base_value = p_value
	_recalculate()


## 获取基础值。
## [br]
## @api public
## [br]
## @return: 当前基础值。
func get_base_value() -> float:
	return _base_value


## 添加修饰器。
## [br]
## @api public
## [br]
## @param p_modifier: 修饰器实例。
func add_modifier(p_modifier: GFModifier) -> void:
	if p_modifier == null:
		return

	_modifiers.append(p_modifier)
	_recalculate()


## 移除修饰器。
## [br]
## @api public
## [br]
## @param p_modifier: 要移除的修饰器实例。
func remove_modifier(p_modifier: GFModifier) -> void:
	if p_modifier == null:
		return

	_modifiers.erase(p_modifier)
	_recalculate()


## 根据 source_id 移除所有匹配的修饰器。
## [br]
## @api public
## [br]
## @param p_source_id: 来源标识。
func remove_modifiers_by_source(p_source_id: StringName) -> void:
	var to_remove: Array[GFModifier] = []
	for modifier in _modifiers:
		if modifier.source_id == p_source_id:
			to_remove.append(modifier)
	
	if to_remove.is_empty():
		return
		
	for modifier in to_remove:
		_modifiers.erase(modifier)
	_recalculate()


## 强制执行一次属性重算。
## 当外部直接修改了 Modifier 的数值时，可手动调用此方法触发 UI 更新。
## [br]
## @api public
func force_recalculate() -> void:
	_recalculate()


# --- 私有/辅助方法 ---

# 执行公式重算：(Base + BaseAdd) * (1.0 + PercentAdd) + FinalAdd
func _recalculate() -> void:
	var base_add: float = 0.0
	var percent_add: float = 0.0
	var final_add: float = 0.0
	
	for mod: GFModifier in _modifiers:
		if mod == null:
			continue

		match mod.type:
			GFModifier.Type.BASE_ADD:
				base_add += mod.value
			GFModifier.Type.PERCENT_ADD:
				percent_add += mod.value
			GFModifier.Type.FINAL_ADD:
				final_add += mod.value
				
	var final_value: float = (_base_value + base_add) * (1.0 + percent_add) + final_add
	_current_value_view.call("_set_value_from_owner", final_value)
