## GFConfigLocalizationKeyValidationRule: 文本 key 校验规则。
##
## 用于检查配置字段中的本地化 key 是否存在于显式 key 列表、字典或 Godot 翻译表中。
class_name GFConfigLocalizationKeyValidationRule
extends GFConfigValidationRule


# --- 导出变量 ---

## 空字符串是否直接视为通过。
@export var allow_empty: bool = true

## 显式允许的文本 key。
@export var known_keys: PackedStringArray = PackedStringArray()

## 可选文本字典。只检查 key 是否存在，不解释 value。
@export var text_map: Dictionary = {}

## 是否尝试通过 TranslationServer 判断 key。
@export var use_translation_server: bool = true


# --- 公共方法 ---

## 导出规则摘要。
## @return 规则摘要字典。
func describe() -> Dictionary:
	var result := super.describe()
	result["allow_empty"] = allow_empty
	result["known_keys"] = known_keys.duplicate()
	result["text_map"] = text_map.duplicate(true)
	result["use_translation_server"] = use_translation_server
	return result


# --- 可重写钩子 ---

func _get_default_rule_id() -> StringName:
	return &"localization_key"


func _validate_value(value: Variant, context: Dictionary, report: Dictionary) -> void:
	if typeof(value) != TYPE_STRING and typeof(value) != TYPE_STRING_NAME:
		_add_issue(report, context, "localization_key_invalid_type", "文本 key 校验只支持 String 或 StringName。")
		return

	var key := String(value).strip_edges()
	if key.is_empty() and allow_empty:
		return
	if _has_explicit_key_source() and _explicit_key_exists(key):
		return
	if use_translation_server and TranslationServer.translate(StringName(key)) != key:
		return
	if not _has_explicit_key_source() and not use_translation_server:
		_add_issue(report, context, "localization_key_source_missing", "文本 key 校验缺少 key 来源。")
		return
	_add_issue(report, context, "localization_key_missing", "文本 key 不存在：%s。" % key)


# --- 私有/辅助方法 ---

func _has_explicit_key_source() -> bool:
	return not known_keys.is_empty() or not text_map.is_empty()


func _explicit_key_exists(key: String) -> bool:
	if known_keys.has(key):
		return true
	if text_map.has(key):
		return true
	return text_map.has(StringName(key))
