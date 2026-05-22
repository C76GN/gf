## GFTagSourceAdapter: 通用标签源适配器。
##
## 支持 GFTagSet、Array、PackedStringArray、Dictionary 以及具备 has_tag/get_tag_count/get_tags
## 方法的对象。它不维护全局标签表，也不规定标签语义。
## [br]
## @api public
## [br]
## @category runtime_service
## [br]
## @since 3.17.0
class_name GFTagSourceAdapter
extends RefCounted


# --- 公共方法 ---

## 检查标签源是否拥有指定标签。
## [br]
## @api public
## [br]
## @param source: 标签源。
## [br]
## @schema source: Variant tag source accepted by the adapter.
## [br]
## @param tag: 标签名。
## [br]
## @param minimum_count: 要求的最小层数。
## [br]
## @param include_child_tags: 为 true 时，`state` 可匹配 `state.burning`。
## [br]
## @return 满足要求返回 true。
static func source_has_tag(
	source: Variant,
	tag: StringName,
	minimum_count: int = 1,
	include_child_tags: bool = false
) -> bool:
	if tag == &"":
		return false

	var count := get_tag_count(source, tag, include_child_tags)
	if count >= max(1, minimum_count):
		return true
	if include_child_tags or minimum_count > 1:
		return false
	if source is Object:
		return _call_has_tag(source as Object, tag, minimum_count)
	return false


## 获取标签源中的标签层数。
## [br]
## @api public
## [br]
## @param source: 标签源。
## [br]
## @schema source: Variant tag source accepted by the adapter.
## [br]
## @param tag: 标签名。
## [br]
## @param include_child_tags: 为 true 时合并子标签层数。
## [br]
## @return 标签层数。
static func get_tag_count(source: Variant, tag: StringName, include_child_tags: bool = false) -> int:
	if source == null or tag == &"":
		return 0
	if source is GFTagSet:
		return (source as GFTagSet).get_tag_count(tag, include_child_tags)
	if source is Dictionary:
		return _get_dictionary_tag_count(source as Dictionary, tag, include_child_tags)
	if source is PackedStringArray or source is Array:
		return _get_array_tag_count(source, tag, include_child_tags)
	if source is Object:
		return _get_object_tag_count(source as Object, tag, include_child_tags)
	return 0


## 获取标签源中的标签名。
## [br]
## @api public
## [br]
## @param source: 标签源。
## [br]
## @schema source: Variant tag source accepted by the adapter.
## [br]
## @return 排序后的标签名。
static func get_tags(source: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	if source == null:
		return result
	if source is GFTagSet:
		return (source as GFTagSet).get_tags()
	if source is Dictionary:
		var data := _resolve_dictionary_tag_data(source as Dictionary)
		for tag_variant: Variant in data.keys():
			if int(data.get(tag_variant, 0)) > 0:
				result.append(String(tag_variant))
	elif source is PackedStringArray:
		result = source
	elif source is Array:
		for tag_variant: Variant in source:
			result.append(String(tag_variant))
	elif source is Object:
		result = _get_object_tags(source as Object)

	result.sort()
	return result


## 检查标签源是否包含所有标签。
## [br]
## @api public
## [br]
## @param source: 标签源。
## [br]
## @schema source: Variant tag source accepted by the adapter.
## [br]
## @param tags: 需要全部满足的标签。
## [br]
## @param include_child_tags: 是否启用层级匹配。
## [br]
## @return 全部满足返回 true。
static func matches_all(source: Variant, tags: Array[StringName], include_child_tags: bool = false) -> bool:
	for tag: StringName in tags:
		if not source_has_tag(source, tag, 1, include_child_tags):
			return false
	return true


## 检查标签源是否包含任意标签。
## [br]
## @api public
## [br]
## @param source: 标签源。
## [br]
## @schema source: Variant tag source accepted by the adapter.
## [br]
## @param tags: 需要满足任意一个的标签；空数组返回 true。
## [br]
## @param include_child_tags: 是否启用层级匹配。
## [br]
## @return 满足任意标签返回 true。
static func matches_any(source: Variant, tags: Array[StringName], include_child_tags: bool = false) -> bool:
	if tags.is_empty():
		return true
	for tag: StringName in tags:
		if source_has_tag(source, tag, 1, include_child_tags):
			return true
	return false


## 检查标签源是否不包含任何禁止标签。
## [br]
## @api public
## [br]
## @param source: 标签源。
## [br]
## @schema source: Variant tag source accepted by the adapter.
## [br]
## @param tags: 禁止出现的标签。
## [br]
## @param include_child_tags: 是否启用层级匹配。
## [br]
## @return 未命中禁止标签返回 true。
static func matches_none(source: Variant, tags: Array[StringName], include_child_tags: bool = false) -> bool:
	for tag: StringName in tags:
		if source_has_tag(source, tag, 1, include_child_tags):
			return false
	return true


# --- 私有/辅助方法 ---

static func _get_dictionary_tag_count(data: Dictionary, tag: StringName, include_child_tags: bool) -> int:
	var tag_data := _resolve_dictionary_tag_data(data)
	if not include_child_tags:
		return int(tag_data.get(tag, tag_data.get(String(tag), 0)))

	var count := 0
	var prefix := "%s." % String(tag)
	for candidate_variant: Variant in tag_data.keys():
		var candidate_text := String(candidate_variant)
		if candidate_text == String(tag) or candidate_text.begins_with(prefix):
			count += int(tag_data.get(candidate_variant, 0))
	return count


static func _resolve_dictionary_tag_data(data: Dictionary) -> Dictionary:
	if data.has("tag_counts") and data["tag_counts"] is Dictionary:
		return data["tag_counts"] as Dictionary
	if data.has(&"tag_counts") and data[&"tag_counts"] is Dictionary:
		return data[&"tag_counts"] as Dictionary
	if data.has("tags") and not (data["tags"] is Dictionary):
		return _array_to_counts(data["tags"])
	if data.has(&"tags") and not (data[&"tags"] is Dictionary):
		return _array_to_counts(data[&"tags"])
	if data.has("tags") and data["tags"] is Dictionary:
		return data["tags"] as Dictionary
	if data.has(&"tags") and data[&"tags"] is Dictionary:
		return data[&"tags"] as Dictionary
	return data


static func _get_array_tag_count(source: Variant, tag: StringName, include_child_tags: bool) -> int:
	var count := 0
	var prefix := "%s." % String(tag)
	var values := PackedStringArray()
	if source is PackedStringArray:
		values = source
	elif source is Array:
		for tag_variant: Variant in source:
			values.append(String(tag_variant))

	for candidate_text: String in values:
		if candidate_text == String(tag) or (include_child_tags and candidate_text.begins_with(prefix)):
			count += 1
	return count


static func _array_to_counts(source: Variant) -> Dictionary:
	var result: Dictionary = {}
	if source is PackedStringArray:
		for tag_text: String in source:
			var tag := StringName(tag_text)
			result[tag] = int(result.get(tag, 0)) + 1
	elif source is Array:
		for tag_variant: Variant in source:
			var tag := StringName(tag_variant)
			result[tag] = int(result.get(tag, 0)) + 1
	return result


static func _get_object_tag_count(source: Object, tag: StringName, include_child_tags: bool) -> int:
	var exact_count := 0
	if source.has_method("get_tag_count"):
		exact_count = int(source.call("get_tag_count", tag))
	if not include_child_tags:
		return exact_count

	var count := exact_count
	var prefix := "%s." % String(tag)
	for candidate_text: String in _get_object_tags(source):
		if candidate_text == String(tag):
			continue
		if candidate_text.begins_with(prefix):
			count += int(source.call("get_tag_count", StringName(candidate_text))) if source.has_method("get_tag_count") else 1
	return count


static func _get_object_tags(source: Object) -> PackedStringArray:
	if not source.has_method("get_tags"):
		return PackedStringArray()

	var raw_tags: Variant = source.call("get_tags")
	if raw_tags is PackedStringArray:
		return raw_tags
	var result := PackedStringArray()
	if raw_tags is Array:
		for tag_variant: Variant in raw_tags:
			result.append(String(tag_variant))
	return result


static func _call_has_tag(source: Object, tag: StringName, minimum_count: int) -> bool:
	if not source.has_method("has_tag"):
		return false

	for method: Dictionary in source.get_method_list():
		if String(method.get("name", "")) != "has_tag":
			continue
		var args := method.get("args", []) as Array
		if args != null and args.size() >= 2:
			return bool(source.call("has_tag", tag, minimum_count))
		return bool(source.call("has_tag", tag))
	return bool(source.call("has_tag", tag))
