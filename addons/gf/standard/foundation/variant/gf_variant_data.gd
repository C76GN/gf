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


# --- 公共方法 ---

## 深拷贝 Dictionary 或 Array；其他 Variant 原样返回。
## [br]
## @api public
## [br]
## @param value: 待复制的值。
## [br]
## @schema value: Variant value to duplicate.
## [br]
## @param deep: 是否深拷贝集合或 Resource。
## [br]
## @param duplicate_resources: 是否复制 Resource；默认为 false 以保留引用语义。
## [br]
## @return 复制后的值。
## [br]
## @schema return: Variant duplicated value.
static func duplicate_variant(value: Variant, deep: bool = true, duplicate_resources: bool = false) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(deep)
	if value is Array:
		return (value as Array).duplicate(deep)
	if duplicate_resources and value is Resource:
		return (value as Resource).duplicate(deep)
	return value


## 深拷贝集合值；语义同 duplicate_variant()，便于集合字段调用处表达意图。
## [br]
## @api public
## [br]
## @param value: 待复制的值。
## [br]
## @schema value: Variant collection value to duplicate.
## [br]
## @param deep: 是否深拷贝集合。
## [br]
## @return 复制后的值。
## [br]
## @schema return: Variant duplicated collection value.
static func duplicate_collection(value: Variant, deep: bool = true) -> Variant:
	return duplicate_variant(value, deep)


## 将 Variant 归一为 Dictionary 副本。
## [br]
## @api public
## [br]
## @param value: 待读取的值。
## [br]
## @schema value: Variant value expected to be a Dictionary.
## [br]
## @param default_value: value 不是 Dictionary 时使用的默认值。
## [br]
## @schema default_value: Dictionary default copied when value is not a Dictionary.
## [br]
## @param deep: 是否深拷贝集合。
## [br]
## @return Dictionary 副本。
## [br]
## @schema return: Dictionary copied result.
static func to_dictionary(value: Variant, default_value: Dictionary = {}, deep: bool = true) -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(deep)
	return default_value.duplicate(deep)


## 复制元数据字典。
## [br]
## @api public
## [br]
## @param metadata: 待复制的元数据。
## [br]
## @schema metadata: Dictionary caller metadata.
## [br]
## @return 元数据副本。
## [br]
## @schema return: Dictionary duplicated metadata.
static func duplicate_metadata(metadata: Dictionary) -> Dictionary:
	return metadata.duplicate(true)


## 将 source 合并到 target。
## [br]
## @api public
## [br]
## @param target: 会被原地修改的目标字典。
## [br]
## @schema target: Dictionary target mutated in place.
## [br]
## @param source: 来源字典。
## [br]
## @schema source: Dictionary source values copied into target.
## [br]
## @param overwrite: 为 true 时覆盖已有字段。
## [br]
## @param recursive: 为 true 时递归合并嵌套 Dictionary。
## [br]
## @return 已合并的 target 字典。
## [br]
## @schema return: Dictionary merged target.
static func merge_dictionary(
	target: Dictionary,
	source: Dictionary,
	overwrite: bool = true,
	recursive: bool = true
) -> Dictionary:
	for key: Variant in source.keys():
		if (
			recursive
			and target.get(key, null) is Dictionary
			and source[key] is Dictionary
		):
			merge_dictionary(target[key] as Dictionary, source[key] as Dictionary, overwrite, recursive)
			continue
		if overwrite or not target.has(key):
			target[key] = duplicate_variant(source[key])
	return target


## 将 source 元数据合并到 target 元数据。
## [br]
## @api public
## [br]
## @param target: 会被原地修改的目标元数据。
## [br]
## @schema target: Dictionary metadata mutated in place.
## [br]
## @param source: 来源元数据。
## [br]
## @schema source: Dictionary metadata copied into target.
## [br]
## @param overwrite: 为 true 时覆盖已有字段。
## [br]
## @param recursive: 为 true 时递归合并嵌套 Dictionary。
## [br]
## @return 已合并的 target 元数据。
## [br]
## @schema return: Dictionary merged metadata.
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
## @schema base: Dictionary target mutated in place.
## [br]
## @param defaults: 默认值字典。
## [br]
## @schema defaults: Dictionary default values merged into base.
## [br]
## @return 已补齐的 base 字典。
## [br]
## @schema return: Dictionary merged base dictionary.
static func deep_merge_defaults(base: Dictionary, defaults: Dictionary) -> Dictionary:
	return merge_dictionary(base, defaults, false, true)


## 读取 options 字典中的原始值，支持 String 与 StringName 键互查。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: Dictionary options payload.
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant option key.
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @schema default_value: Variant default value.
## [br]
## @return 读取到的值或默认值。
## [br]
## @schema return: Variant option value or default.
static func get_option_value(options: Dictionary, key: Variant, default_value: Variant = null) -> Variant:
	return _get_key_value(options, key, default_value)


## 读取 bool 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: Dictionary options payload.
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant option key.
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return bool 值。
static func get_option_bool(options: Dictionary, key: Variant, default_value: bool = false) -> bool:
	var value: Variant = _get_key_value(options, key, default_value)
	if value == null:
		return default_value
	if value is String or value is StringName:
		var text := String(value).strip_edges().to_lower()
		if text == "false" or text == "0" or text == "no" or text == "off":
			return false
		if text == "true" or text == "1" or text == "yes" or text == "on":
			return true
	return bool(value)


## 读取 int 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: Dictionary options payload.
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant option key.
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return int 值。
static func get_option_int(options: Dictionary, key: Variant, default_value: int = 0) -> int:
	var value: Variant = _get_key_value(options, key, default_value)
	return default_value if value == null else int(value)


## 读取 float 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: Dictionary options payload.
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant option key.
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return float 值。
static func get_option_float(options: Dictionary, key: Variant, default_value: float = 0.0) -> float:
	var value: Variant = _get_key_value(options, key, default_value)
	return default_value if value == null else float(value)


## 读取 String 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: Dictionary options payload.
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant option key.
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return String 值。
static func get_option_string(options: Dictionary, key: Variant, default_value: String = "") -> String:
	var value: Variant = _get_key_value(options, key, default_value)
	return default_value if value == null else String(value)


## 读取 StringName 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: Dictionary options payload.
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant option key.
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return StringName 值。
static func get_option_string_name(options: Dictionary, key: Variant, default_value: StringName = &"") -> StringName:
	var value: Variant = _get_key_value(options, key, default_value)
	return default_value if value == null else StringName(String(value))


## 读取 Dictionary 选项副本。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: Dictionary options payload.
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant option key.
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @schema default_value: Dictionary default copied when option is not a Dictionary.
## [br]
## @return Dictionary 副本。
## [br]
## @schema return: Dictionary option value.
static func get_option_dictionary(options: Dictionary, key: Variant, default_value: Dictionary = {}) -> Dictionary:
	return to_dictionary(_get_key_value(options, key, default_value), default_value)


## 读取 Array 选项副本。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: Dictionary options payload.
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant option key.
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @schema default_value: Array default copied when option is not an Array.
## [br]
## @return Array 副本。
## [br]
## @schema return: Array option value.
static func get_option_array(options: Dictionary, key: Variant, default_value: Array = []) -> Array:
	var value: Variant = _get_key_value(options, key, default_value)
	if value is Array:
		return (value as Array).duplicate(true)
	return default_value.duplicate(true)


## 读取 PackedStringArray 选项。
## [br]
## @api public
## [br]
## @param options: 可选项字典。
## [br]
## @schema options: Dictionary options payload.
## [br]
## @param key: 字段名，可传 String 或 StringName。
## [br]
## @schema key: Variant option key.
## [br]
## @param default_value: 缺少字段时返回的默认值。
## [br]
## @return PackedStringArray 值。
static func get_option_packed_string_array(
	options: Dictionary,
	key: Variant,
	default_value: PackedStringArray = PackedStringArray()
) -> PackedStringArray:
	var value: Variant = _get_key_value(options, key, default_value)
	if value is PackedStringArray:
		return (value as PackedStringArray).duplicate()
	var result := PackedStringArray()
	if value is Array:
		for item: Variant in value as Array:
			result.append(String(item))
	elif value is String or value is StringName:
		var text := String(value)
		if not text.is_empty():
			result.append(text)
	else:
		result = default_value.duplicate()
	return result


# --- 私有/辅助方法 ---

static func _get_key_value(data: Dictionary, key: Variant, default_value: Variant = null) -> Variant:
	if data.has(key):
		return data[key]
	if key is StringName:
		var text_key := String(key)
		if data.has(text_key):
			return data[text_key]
	elif key is String:
		var name_key := StringName(key)
		if data.has(name_key):
			return data[name_key]
	return default_value
