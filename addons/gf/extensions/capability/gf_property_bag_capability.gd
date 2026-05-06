## GFPropertyBagCapability: 轻量动态属性包能力。
##
## 适合为对象挂载少量运行时标签值、编辑器调试值或原型数据。
## 长期核心状态仍应放入 GFModel 或配置资源。
class_name GFPropertyBagCapability
extends GFCapability


# --- 信号 ---

## 当属性值发生变化时发出。
signal property_changed(key: StringName, old_value: Variant, new_value: Variant)

## 当属性被移除时发出。
signal property_removed(key: StringName, old_value: Variant)


# --- 导出变量 ---

## 当前属性表。
@export var values: Dictionary = {}


# --- 公共方法 ---

## 设置属性值。
## @param key: 属性键。
## @param value: 要写入或修改的值。
func set_property_value(key: StringName, value: Variant) -> void:
	if key == &"":
		return

	var old_value: Variant = values.get(key)
	if values.has(key) and old_value == value:
		return

	values[key] = value
	property_changed.emit(key, old_value, value)


## 获取属性值。
## @param key: 属性键。
## @param default_value: 缺失或类型不匹配时返回的默认值。
func get_property_value(key: StringName, default_value: Variant = null) -> Variant:
	return values.get(key, default_value)


## 检查属性是否存在。
## @param key: 属性键。
func has_property_value(key: StringName) -> bool:
	return values.has(key)


## 移除属性。
## @param key: 属性键。
func remove_property_value(key: StringName) -> bool:
	if not values.has(key):
		return false

	var old_value: Variant = values[key]
	values.erase(key)
	property_removed.emit(key, old_value)
	return true


## 清空全部属性。
func clear_properties() -> void:
	var keys := values.keys()
	for key_variant: Variant in keys:
		remove_property_value(StringName(key_variant))


## 获取 int 属性。
## @param key: 属性键。
## @param default_value: 缺失或类型不匹配时返回的默认值。
func get_int(key: StringName, default_value: int = 0) -> int:
	return int(values.get(key, default_value))


## 获取 float 属性。
## @param key: 属性键。
## @param default_value: 缺失或类型不匹配时返回的默认值。
func get_float(key: StringName, default_value: float = 0.0) -> float:
	return float(values.get(key, default_value))


## 获取 bool 属性。
## @param key: 属性键。
## @param default_value: 缺失或类型不匹配时返回的默认值。
func get_bool(key: StringName, default_value: bool = false) -> bool:
	return bool(values.get(key, default_value))


## 获取 String 属性。
## @param key: 属性键。
## @param default_value: 缺失或类型不匹配时返回的默认值。
func get_string(key: StringName, default_value: String = "") -> String:
	return String(values.get(key, default_value))


## 获取 Vector2 属性。
## @param key: 属性键。
## @param default_value: 缺失或类型不匹配时返回的默认值。
func get_vector2(key: StringName, default_value: Vector2 = Vector2.ZERO) -> Vector2:
	var value: Variant = values.get(key, default_value)
	if value is Vector2:
		return value as Vector2
	return default_value


## 获取 Color 属性。
## @param key: 属性键。
## @param default_value: 缺失或类型不匹配时返回的默认值。
func get_color(key: StringName, default_value: Color = Color.WHITE) -> Color:
	var value: Variant = values.get(key, default_value)
	if value is Color:
		return value as Color
	return default_value
