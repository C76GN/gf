## GFVariantUtility: 通用 Variant、Dictionary 与数组转换辅助。
##
## 该类不依赖 GFArchitecture，适合在 Foundation、Utility 和 Extension 中复用
## 深拷贝、默认值合并以及 JSON 友好的 Vector/Color 转换逻辑。
class_name GFVariantUtility
extends RefCounted


# --- 公共方法 ---

## 深拷贝 Dictionary 或 Array；其他 Variant 原样返回。
## @param value: 待复制的值。
## @return 复制后的值。
static func duplicate_variant(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value


## 深拷贝集合值；语义同 duplicate_variant()，便于集合字段调用处表达意图。
## @param value: 待复制的值。
## @return 复制后的值。
static func duplicate_collection(value: Variant) -> Variant:
	return duplicate_variant(value)


## 将 defaults 中缺失的字段递归合并到 base。
## @param base: 会被原地补齐的目标字典。
## @param defaults: 默认值字典。
## @return 已补齐的 base 字典。
static func deep_merge_defaults(base: Dictionary, defaults: Dictionary) -> Dictionary:
	for key: Variant in defaults.keys():
		if not base.has(key):
			base[key] = duplicate_variant(defaults[key])
			continue
		if base[key] is Dictionary and defaults[key] is Dictionary:
			deep_merge_defaults(base[key], defaults[key])
	return base


## 将 Vector2 转成 JSON 友好的数组。
## @param value: 待转换的 Vector2。
## @return [x, y] 数组。
static func vector2_to_array(value: Vector2) -> Array[float]:
	return [value.x, value.y]


## 从数组读取 Vector2，失败时返回 fallback。
## @param value: 输入值。
## @param fallback: 转换失败时返回的值。
## @return Vector2 值。
static func array_to_vector2(value: Variant, fallback: Vector2 = Vector2.ZERO) -> Vector2:
	if not (value is Array):
		return fallback

	var array := value as Array
	if array.size() < 2:
		return fallback
	return Vector2(float(array[0]), float(array[1]))


## 将 Vector3 转成 JSON 友好的数组。
## @param value: 待转换的 Vector3。
## @return [x, y, z] 数组。
static func vector3_to_array(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


## 从数组读取 Vector3，失败时返回 fallback。
## @param value: 输入值。
## @param fallback: 转换失败时返回的值。
## @return Vector3 值。
static func array_to_vector3(value: Variant, fallback: Vector3 = Vector3.ZERO) -> Vector3:
	if not (value is Array):
		return fallback

	var array := value as Array
	if array.size() < 3:
		return fallback
	return Vector3(float(array[0]), float(array[1]), float(array[2]))


## 将 Color 转成 JSON 友好的数组。
## @param value: 待转换的 Color。
## @return [r, g, b, a] 数组。
static func color_to_array(value: Color) -> Array[float]:
	return [value.r, value.g, value.b, value.a]


## 从数组读取 Color，失败时返回 fallback。
## @param value: 输入值。
## @param fallback: 转换失败时返回的值。
## @return Color 值。
static func array_to_color(value: Variant, fallback: Color = Color.WHITE) -> Color:
	if not (value is Array):
		return fallback

	var array := value as Array
	if array.size() < 4:
		return fallback
	return Color(float(array[0]), float(array[1]), float(array[2]), float(array[3]))
