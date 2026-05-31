## GFVariantData: 通用 Variant 数据复制与默认值合并。
##
## 提供不依赖 GFArchitecture 的集合复制、Resource 可选复制和默认值递归补齐。
## JSON 兼容编码由 GFVariantJsonCodec 负责。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFVariantData
extends RefCounted

const _GF_VARIANT_ACCESS_SCRIPT = preload("res://addons/gf/kernel/core/gf_variant_access.gd")


# --- 公共方法 ---

## 深拷贝 Dictionary 或 Array；其他 Variant 原样返回。
## [br]
## @api public
## [br]
## @param value: 待复制的值。
## [br]
## @schema value: 待复制的 Variant 值。
## [br]
## @param deep: 是否深拷贝集合或 Resource。
## [br]
## @param duplicate_resources: 是否复制 Resource；默认为 false 以保留引用语义。
## [br]
## @return 复制后的值。
## [br]
## @schema return: 复制后的 Variant 值。
static func duplicate_variant(value: Variant, deep: bool = true, duplicate_resources: bool = false) -> Variant:
	return _GF_VARIANT_ACCESS_SCRIPT.duplicate_variant(value, deep, duplicate_resources)


## 深拷贝集合值；语义同 duplicate_variant()，便于集合字段调用处表达意图。
## [br]
## @api public
## [br]
## @param value: 待复制的值。
## [br]
## @schema value: 待复制的 Variant 集合值。
## [br]
## @param deep: 是否深拷贝集合。
## [br]
## @return 复制后的值。
## [br]
## @schema return: 复制后的 Variant 集合值。
static func duplicate_collection(value: Variant, deep: bool = true) -> Variant:
	return _GF_VARIANT_ACCESS_SCRIPT.duplicate_collection(value, deep)


## 将 Variant 归一为 Dictionary 副本。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望为 Dictionary 的 Variant 值。
## [br]
## @param default_value: value 不是 Dictionary 时使用的默认值。
## [br]
## @schema default_value: value 不是 Dictionary 时复制的默认 Dictionary。
## [br]
## @param deep: 是否深拷贝集合。
## [br]
## @return Dictionary 副本。
## [br]
## @schema return: 复制后的 Dictionary 结果。
static func to_dictionary(value: Variant, default_value: Dictionary = {}, deep: bool = true) -> Dictionary:
	return _GF_VARIANT_ACCESS_SCRIPT.to_dictionary(value, default_value, deep)


## 将 Variant 收窄为 Dictionary 引用；value 不是 Dictionary 时返回 default_value 引用。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望为 Dictionary 的 Variant 值。
## [br]
## @param default_value: value 不是 Dictionary 时使用的默认值；不是 Dictionary 时忽略。
## [br]
## @schema default_value: 为 Dictionary 时按引用返回的 Variant 兜底值。
## [br]
## @return Dictionary 引用。
## [br]
## @schema return: 收窄后的 Dictionary 结果。
static func as_dictionary(value: Variant, default_value: Variant = null) -> Dictionary:
	return _GF_VARIANT_ACCESS_SCRIPT.as_dictionary(value, default_value)


## 将 Variant 归一为 Array 副本。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望为 Array 的 Variant 值。
## [br]
## @param default_value: value 不是 Array 时使用的默认值。
## [br]
## @schema default_value: value 不是 Array 时复制的默认 Array。
## [br]
## @param deep: 是否深拷贝集合。
## [br]
## @return Array 副本。
## [br]
## @schema return: 复制后的 Array 结果。
static func to_array(value: Variant, default_value: Array = [], deep: bool = true) -> Array:
	return _GF_VARIANT_ACCESS_SCRIPT.to_array(value, default_value, deep)


## 将 Variant 收窄为 Array 引用；value 不是 Array 时返回 default_value 引用。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望为 Array 的 Variant 值。
## [br]
## @param default_value: value 不是 Array 时使用的默认值；不是 Array 时忽略。
## [br]
## @schema default_value: 为 Array 时按引用返回的 Variant 兜底值。
## [br]
## @return Array 引用。
## [br]
## @schema return: 收窄后的 Array 结果。
static func as_array(value: Variant, default_value: Variant = null) -> Array:
	return _GF_VARIANT_ACCESS_SCRIPT.as_array(value, default_value)


## 将 Variant 安全归一为 bool。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望可表示 bool 的 Variant 值。
## [br]
## @param default_value: 无法安全归一时返回的默认值。
## [br]
## @return bool 值。
static func to_bool(value: Variant, default_value: bool = false) -> bool:
	return _GF_VARIANT_ACCESS_SCRIPT.to_bool(value, default_value)


## 将 Variant 安全归一为 int。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望可表示 int 的 Variant 值。
## [br]
## @param default_value: 无法安全归一时返回的默认值。
## [br]
## @return int 值。
static func to_int(value: Variant, default_value: int = 0) -> int:
	return _GF_VARIANT_ACCESS_SCRIPT.to_int(value, default_value)


## 将 Variant 安全归一为 float。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望可表示 float 的 Variant 值。
## [br]
## @param default_value: 无法安全归一时返回的默认值。
## [br]
## @return float 值。
static func to_float(value: Variant, default_value: float = 0.0) -> float:
	return _GF_VARIANT_ACCESS_SCRIPT.to_float(value, default_value)


## 将 Variant 归一为 String。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望可表示文本的 Variant 值。
## [br]
## @param default_value: value 为 null 时返回的默认值。
## [br]
## @return String 值。
static func to_text(value: Variant, default_value: String = "") -> String:
	return _GF_VARIANT_ACCESS_SCRIPT.to_text(value, default_value)


## 将 Variant 归一为 StringName。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望可表示 StringName 的 Variant 值。
## [br]
## @param default_value: value 为 null 时返回的默认值。
## [br]
## @return StringName 值。
static func to_string_name(value: Variant, default_value: StringName = &"") -> StringName:
	return _GF_VARIANT_ACCESS_SCRIPT.to_string_name(value, default_value)


## 将 Variant 归一为 Vector2。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望可表示 Vector2 的 Variant 值。
## [br]
## @param default_value: 无法安全归一时返回的默认值。
## [br]
## @return Vector2 值。
static func to_vector2(value: Variant, default_value: Vector2 = Vector2.ZERO) -> Vector2:
	return _GF_VARIANT_ACCESS_SCRIPT.to_vector2(value, default_value)


## 将 Variant 归一为 Vector3。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望可表示 Vector3 的 Variant 值。
## [br]
## @param default_value: 无法安全归一时返回的默认值。
## [br]
## @return Vector3 值。
static func to_vector3(value: Variant, default_value: Vector3 = Vector3.ZERO) -> Vector3:
	return _GF_VARIANT_ACCESS_SCRIPT.to_vector3(value, default_value)


## 将 Variant 归一为 String 数组副本。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望可表示 String 值集合的 Variant。
## [br]
## @param default_value: 无法安全归一时返回的默认数组。
## [br]
## @schema default_value: value 无法收窄时复制的默认 Array[String]。
## [br]
## @return String 数组副本。
## [br]
## @schema return: 收窄后的 Array[String] 结果。
static func to_string_array(value: Variant, default_value: Array[String] = []) -> Array[String]:
	return _GF_VARIANT_ACCESS_SCRIPT.to_string_array(value, default_value)


## 将 Variant 归一为 StringName 数组副本。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望可表示 StringName 值集合的 Variant。
## [br]
## @param default_value: 无法安全归一时返回的默认数组。
## [br]
## @schema default_value: value 无法收窄时复制的默认 Array[StringName]。
## [br]
## @return StringName 数组副本。
## [br]
## @schema return: 收窄后的 Array[StringName] 结果。
static func to_string_name_array(value: Variant, default_value: Array[StringName] = []) -> Array[StringName]:
	return _GF_VARIANT_ACCESS_SCRIPT.to_string_name_array(value, default_value)


## 将 Variant 归一为 int 数组副本。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: 期望可表示 int 值集合的 Variant。
## [br]
## @param default_value: 无法安全归一时返回的默认数组。
## [br]
## @schema default_value: value 无法收窄时复制的默认 Array[int]。
## [br]
## @return int 数组副本。
## [br]
## @schema return: 收窄后的 Array[int] 结果。
static func to_int_array(value: Variant, default_value: Array[int] = []) -> Array[int]:
	return _GF_VARIANT_ACCESS_SCRIPT.to_int_array(value, default_value)


## 复制元数据字典。
## [br]
## @api public
## [br]
## @param metadata: 待复制的元数据。
## [br]
## @schema metadata: 调用方元数据 Dictionary。
## [br]
## @return 元数据副本。
## [br]
## @schema return: 复制后的元数据 Dictionary。
static func duplicate_metadata(metadata: Dictionary) -> Dictionary:
	return metadata.duplicate(true)


## 将 source 合并到 target。
## `String` 与 `StringName` 等价键会复用 target 中已有字段，避免重复键。
## [br]
## @api public
## [br]
## @param target: 会被原地修改的目标字典。
## [br]
## @schema target: 会被原地修改的目标 Dictionary。
## [br]
## @param source: 来源字典。
## [br]
## @schema source: 会复制到目标中的来源 Dictionary 值。
## [br]
## @param overwrite: 为 true 时覆盖已有字段。
## [br]
## @param recursive: 为 true 时递归合并嵌套 Dictionary。
## [br]
## @return 已合并的 target 字典。
## [br]
## @schema return: 合并后的目标 Dictionary。
static func merge_dictionary(
	target: Dictionary,
	source: Dictionary,
	overwrite: bool = true,
	recursive: bool = true
) -> Dictionary:
	return _GF_VARIANT_ACCESS_SCRIPT.merge_dictionary(target, source, overwrite, recursive)


## 将 source 元数据合并到 target 元数据。
## [br]
## @api public
## [br]
## @param target: 会被原地修改的目标元数据。
## [br]
## @schema target: 会被原地修改的元数据 Dictionary。
## [br]
## @param source: 来源元数据。
## [br]
## @schema source: 会复制到目标中的元数据 Dictionary。
## [br]
## @param overwrite: 为 true 时覆盖已有字段。
## [br]
## @param recursive: 为 true 时递归合并嵌套 Dictionary。
## [br]
## @return 已合并的 target 元数据。
## [br]
## @schema return: 合并后的元数据 Dictionary。
static func merge_metadata(
	target: Dictionary,
	source: Dictionary,
	overwrite: bool = true,
	recursive: bool = true
) -> Dictionary:
	return merge_dictionary(target, source, overwrite, recursive)


## 将 defaults 中缺失的字段递归合并到 base。
## [br]
## @api public
## [br]
## @param base: 会被原地补齐的目标字典。
## [br]
## @schema base: 会被原地修改的目标 Dictionary。
## [br]
## @param defaults: 默认值字典。
## [br]
## @schema defaults: 会合并到 base 中的默认 Dictionary 值。
## [br]
## @return 已补齐的 base 字典。
## [br]
## @schema return: 合并后的 base Dictionary。
static func deep_merge_defaults(base: Dictionary, defaults: Dictionary) -> Dictionary:
	return merge_dictionary(base, defaults, false, true)


## 读取 options 字典中的原始值，支持 String 与 StringName 键互查。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @schema default_value: Variant 默认值。
## [br]
## @return 读取到的值或默认值。
## [br]
## @schema return: Variant 选项值或默认值。
static func get_option_value(options: Dictionary, key: Variant, default_value: Variant = null) -> Variant:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_value(options, key, default_value)


## 读取 bool 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return bool 值。
static func get_option_bool(options: Dictionary, key: Variant, default_value: bool = false) -> bool:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_bool(options, key, default_value)


## 读取 int 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return int 值。
static func get_option_int(options: Dictionary, key: Variant, default_value: int = 0) -> int:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_int(options, key, default_value)


## 读取 float 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return float 值。
static func get_option_float(options: Dictionary, key: Variant, default_value: float = 0.0) -> float:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_float(options, key, default_value)


## 读取 String 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return String 值。
static func get_option_string(options: Dictionary, key: Variant, default_value: String = "") -> String:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_string(options, key, default_value)


## 读取 StringName 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return StringName 值。
static func get_option_string_name(options: Dictionary, key: Variant, default_value: StringName = &"") -> StringName:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_string_name(options, key, default_value)


## 读取 Vector2 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return Vector2 值。
static func get_option_vector2(options: Dictionary, key: Variant, default_value: Vector2 = Vector2.ZERO) -> Vector2:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_vector2(options, key, default_value)


## 读取 Vector3 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return Vector3 值。
static func get_option_vector3(options: Dictionary, key: Variant, default_value: Vector3 = Vector3.ZERO) -> Vector3:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_vector3(options, key, default_value)


## 读取 Dictionary 选项副本。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @schema default_value: 选项不是 Dictionary 时复制的默认 Dictionary。
## [br]
## @return Dictionary 副本。
## [br]
## @schema return: Dictionary 选项值。
static func get_option_dictionary(options: Dictionary, key: Variant, default_value: Dictionary = {}) -> Dictionary:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_dictionary(options, key, default_value)


## 读取 Array 选项副本。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @schema default_value: 选项不是 Array 时复制的默认 Array。
## [br]
## @return Array 副本。
## [br]
## @schema return: Array 选项值。
static func get_option_array(options: Dictionary, key: Variant, default_value: Array = []) -> Array:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_array(options, key, default_value)


## 读取 String 数组选项副本。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认数组。
## [br]
## @schema default_value: 选项无法收窄时复制的默认 Array[String]。
## [br]
## @return String 数组副本。
## [br]
## @schema return: Array[String] 选项值。
static func get_option_string_array(
	options: Dictionary,
	key: Variant,
	default_value: Array[String] = []
) -> Array[String]:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_string_array(options, key, default_value)


## 读取 StringName 数组选项副本。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认数组。
## [br]
## @schema default_value: 选项无法收窄时复制的默认 Array[StringName]。
## [br]
## @return StringName 数组副本。
## [br]
## @schema return: Array[StringName] 选项值。
static func get_option_string_name_array(
	options: Dictionary,
	key: Variant,
	default_value: Array[StringName] = []
) -> Array[StringName]:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_string_name_array(options, key, default_value)


## 读取 int 数组选项副本。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认数组。
## [br]
## @schema default_value: 选项无法收窄时复制的默认 Array[int]。
## [br]
## @return int 数组副本。
## [br]
## @schema return: Array[int] 选项值。
static func get_option_int_array(
	options: Dictionary,
	key: Variant,
	default_value: Array[int] = []
) -> Array[int]:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_int_array(options, key, default_value)


## 读取 PackedStringArray 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: 选项载荷 Dictionary。
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant 选项键。
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return PackedStringArray 值。
static func get_option_packed_string_array(
	options: Dictionary,
	key: Variant,
	default_value: PackedStringArray = PackedStringArray()
) -> PackedStringArray:
	return _GF_VARIANT_ACCESS_SCRIPT.get_option_packed_string_array(options, key, default_value)
