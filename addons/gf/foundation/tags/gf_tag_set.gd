## GFTagSet: 通用标签集合资源。
##
## 只维护标签到层数的映射，不规定标签命名、业务含义或全局注册表。
class_name GFTagSet
extends Resource


# --- 导出变量 ---

## 标签层数字典。键建议使用 StringName，值为正整数层数。
@export var tag_counts: Dictionary = {}


# --- 公共方法 ---

## 清空并设置标签集合。
## @param source_tags: Array、PackedStringArray 或 Dictionary 标签数据。
## @return 当前标签集合。
func set_tags(source_tags: Variant) -> GFTagSet:
	clear()
	if source_tags is Dictionary:
		for tag_variant: Variant in (source_tags as Dictionary).keys():
			add_tag(StringName(tag_variant), int((source_tags as Dictionary)[tag_variant]))
	elif source_tags is PackedStringArray:
		for tag_text: String in source_tags:
			add_tag(StringName(tag_text))
	elif source_tags is Array:
		for tag_variant: Variant in source_tags:
			add_tag(StringName(tag_variant))
	return self


## 添加标签层数。
## @param tag: 标签名。
## @param count: 增加层数。
## @return 当前标签集合。
func add_tag(tag: StringName, count: int = 1) -> GFTagSet:
	if tag == &"" or count <= 0:
		return self

	tag_counts[tag] = int(tag_counts.get(tag, 0)) + count
	return self


## 移除标签层数。
## @param tag: 标签名。
## @param count: 移除层数；-1 表示完全移除。
## @return 当前标签集合。
func remove_tag(tag: StringName, count: int = 1) -> GFTagSet:
	if tag == &"" or not tag_counts.has(tag):
		return self
	if count == -1:
		tag_counts.erase(tag)
		return self
	if count <= 0:
		return self

	var updated_count := int(tag_counts.get(tag, 0)) - count
	if updated_count <= 0:
		tag_counts.erase(tag)
	else:
		tag_counts[tag] = updated_count
	return self


## 检查是否拥有指定标签且层数达到要求。
## @param tag: 标签名。
## @param minimum_count: 要求的最小层数。
## @param include_child_tags: 为 true 时，`state` 可匹配 `state.burning`。
## @return 满足要求返回 true。
func has_tag(tag: StringName, minimum_count: int = 1, include_child_tags: bool = false) -> bool:
	return get_tag_count(tag, include_child_tags) >= max(1, minimum_count)


## 获取标签层数。
## @param tag: 标签名。
## @param include_child_tags: 为 true 时合并子标签层数。
## @return 标签层数。
func get_tag_count(tag: StringName, include_child_tags: bool = false) -> int:
	if tag == &"":
		return 0
	if not include_child_tags:
		return int(tag_counts.get(tag, 0))

	var count := 0
	var prefix := "%s." % String(tag)
	for candidate_variant: Variant in tag_counts.keys():
		var candidate := StringName(candidate_variant)
		if candidate == tag or String(candidate).begins_with(prefix):
			count += int(tag_counts.get(candidate_variant, 0))
	return count


## 获取所有标签名。
## @return 排序后的标签名。
func get_tags() -> PackedStringArray:
	var result := PackedStringArray()
	for tag_variant: Variant in tag_counts.keys():
		if int(tag_counts.get(tag_variant, 0)) > 0:
			result.append(String(tag_variant))
	result.sort()
	return result


## 获取标签层数字典副本。
## @return 标签层数字典。
func get_tag_counts() -> Dictionary:
	return tag_counts.duplicate(true)


## 清空标签集合。
func clear() -> void:
	tag_counts.clear()


## 创建同内容拷贝。
## @return 新标签集合。
func duplicate_set() -> GFTagSet:
	var next_set := GFTagSet.new()
	next_set.tag_counts = tag_counts.duplicate(true)
	return next_set


## 导出为字典。
## @return 标签集合字典。
func to_dictionary() -> Dictionary:
	return {
		"tag_counts": tag_counts.duplicate(true),
	}


## 从字典创建标签集合。
## @param data: 标签集合字典。
## @return 新标签集合。
static func from_dictionary(data: Dictionary) -> GFTagSet:
	var next_set := GFTagSet.new()
	next_set.set_tags(data.get("tag_counts", data))
	return next_set
