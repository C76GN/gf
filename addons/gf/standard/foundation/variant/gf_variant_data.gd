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
	for key: Variant in defaults.keys():
		if not base.has(key):
			base[key] = duplicate_variant(defaults[key])
			continue
		if base[key] is Dictionary and defaults[key] is Dictionary:
			deep_merge_defaults(base[key], defaults[key])
	return base
