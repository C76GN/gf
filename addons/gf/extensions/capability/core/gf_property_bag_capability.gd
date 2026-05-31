## GFPropertyBagCapability: 轻量动态属性扩展能力。
##
## 适合为对象挂载少量运行时标签值、编辑器调试值或原型数据。
## 长期核心状态仍应放入 GFModel 或配置资源。
## [br]
## @api public
## [br]
## @category runtime_handle
## [br]
## @since 3.17.0
class_name GFPropertyBagCapability
extends GFCapability


# --- 信号 ---

## 当属性值发生变化时发出。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @param old_value: 旧属性值。
## [br]
## @schema old_value: 属性表中的任意项目值；属性之前不存在时为 null。
## [br]
## @param new_value: 新属性值。
## [br]
## @schema new_value: 属性表中的任意项目值。
signal property_changed(key: StringName, old_value: Variant, new_value: Variant)

## 当属性被移除时发出。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @param old_value: 被移除的旧属性值。
## [br]
## @schema old_value: 属性表中的任意项目值。
signal property_removed(key: StringName, old_value: Variant)


# --- 导出变量 ---

## 当前属性表。
## [br]
## @api public
## [br]
## @schema values: 动态属性 Dictionary；键通常为 StringName，值由项目决定。
@export var values: Dictionary = {}


# --- 公共方法 ---

## 设置属性值。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @param value: 要写入或修改的值。
## [br]
## @schema value: 要写入属性表的任意项目值。
func set_property_value(key: StringName, value: Variant) -> void:
	if key == &"":
		return

	var old_value: Variant = _get_value(key)
	if values.has(key) and old_value == value:
		return

	values[key] = value
	property_changed.emit(key, old_value, value)


## 获取属性值。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @param default_value: 缺失时返回的默认值。
## [br]
## @schema default_value: 属性缺失时返回的任意默认值。
## [br]
## @return: 属性值或默认值。
## [br]
## @schema return: 属性表中的项目值，或传入的 default_value。
func get_property_value(key: StringName, default_value: Variant = null) -> Variant:
	return _get_value(key, default_value)


## 检查属性是否存在。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @return: 存在返回 true。
func has_property_value(key: StringName) -> bool:
	return values.has(key)


## 移除属性。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @return: 移除成功返回 true。
func remove_property_value(key: StringName) -> bool:
	if not values.has(key):
		return false

	var old_value: Variant = values[key]
	var _erased: bool = values.erase(key)
	property_removed.emit(key, old_value)
	return true


## 清空全部属性。
## [br]
## @api public
func clear_properties() -> void:
	var keys: Array = values.keys()
	for key_variant: Variant in keys:
		var _remove_property_value_result_128: Variant = remove_property_value(GFVariantData.to_string_name(key_variant))


## 获取 int 属性。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @param default_value: 缺失或类型不匹配时返回的默认值。
## [br]
## @return: int 属性值或默认值。
func get_int(key: StringName, default_value: int = 0) -> int:
	var value: Variant = _get_value(key, default_value)
	if typeof(value) == TYPE_INT:
		return GFVariantData.to_int(value)
	return default_value


## 获取 float 属性。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @param default_value: 缺失或类型不匹配时返回的默认值。
## [br]
## @return: float 属性值或默认值。
func get_float(key: StringName, default_value: float = 0.0) -> float:
	var value: Variant = _get_value(key, default_value)
	if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
		return GFVariantData.to_float(value)
	return default_value


## 获取 bool 属性。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @param default_value: 缺失或类型不匹配时返回的默认值。
## [br]
## @return: bool 属性值或默认值。
func get_bool(key: StringName, default_value: bool = false) -> bool:
	var value: Variant = _get_value(key, default_value)
	if value is bool:
		return GFVariantData.to_bool(value)
	return default_value


## 获取 String 属性。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @param default_value: 缺失或类型不匹配时返回的默认值。
## [br]
## @return: String 属性值或默认值。
func get_string(key: StringName, default_value: String = "") -> String:
	var value: Variant = _get_value(key, default_value)
	if value is String:
		return GFVariantData.to_text(value)
	return default_value


## 获取 Vector2 属性。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @param default_value: 缺失或类型不匹配时返回的默认值。
## [br]
## @return: Vector2 属性值或默认值。
func get_vector2(key: StringName, default_value: Vector2 = Vector2.ZERO) -> Vector2:
	var value: Variant = _get_value(key, default_value)
	if value is Vector2:
		var vector: Vector2 = value
		return vector
	return default_value


## 获取 Color 属性。
## [br]
## @api public
## [br]
## @param key: 属性键。
## [br]
## @param default_value: 缺失或类型不匹配时返回的默认值。
## [br]
## @return: Color 属性值或默认值。
func get_color(key: StringName, default_value: Color = Color.WHITE) -> Color:
	var value: Variant = _get_value(key, default_value)
	if value is Color:
		var color: Color = value
		return color
	return default_value


# --- 私有/辅助方法 ---

func _get_value(key: StringName, default_value: Variant = null) -> Variant:
	return GFVariantData.get_option_value(values, key, default_value)
