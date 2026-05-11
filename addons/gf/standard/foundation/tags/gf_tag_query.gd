## GFTagQuery: 通用标签查询资源。
##
## 使用 all/any/none 三组标签描述条件，可直接匹配标签集合、标签组件或普通数据。
class_name GFTagQuery
extends Resource


# --- 常量 ---

const _GF_TAG_SOURCE_ADAPTER_SCRIPT: Script = preload("res://addons/gf/standard/foundation/tags/gf_tag_source_adapter.gd")


# --- 导出变量 ---

## 必须全部存在的标签。
@export var all_tags: Array[StringName] = []

## 至少存在一个的标签；为空时跳过该条件。
@export var any_tags: Array[StringName] = []

## 不允许存在的标签。
@export var none_tags: Array[StringName] = []

## 是否启用层级匹配。例如查询 `state` 时可匹配 `state.burning`。
@export var include_child_tags: bool = false


# --- 公共方法 ---

## 检查查询是否为空。
## @return 无任何条件时返回 true。
func is_empty() -> bool:
	return all_tags.is_empty() and any_tags.is_empty() and none_tags.is_empty()


## 匹配标签源。
## @param source: 标签源。
## @return 满足查询返回 true。
func matches(source: Variant) -> bool:
	var report := get_match_report(source)
	return bool(report.get("ok", false))


## 获取匹配报告。
## @param source: 标签源。
## @return 包含 ok、missing_all、missing_any、blocked_tags 的报告。
func get_match_report(source: Variant) -> Dictionary:
	var missing_all: Array[StringName] = []
	for tag: StringName in all_tags:
		if not _GF_TAG_SOURCE_ADAPTER_SCRIPT.source_has_tag(source, tag, 1, include_child_tags):
			missing_all.append(tag)

	var missing_any: Array[StringName] = []
	if not any_tags.is_empty():
		for tag: StringName in any_tags:
			if not _GF_TAG_SOURCE_ADAPTER_SCRIPT.source_has_tag(source, tag, 1, include_child_tags):
				missing_any.append(tag)
		if missing_any.size() < any_tags.size():
			missing_any.clear()

	var blocked_tags: Array[StringName] = []
	for tag: StringName in none_tags:
		if _GF_TAG_SOURCE_ADAPTER_SCRIPT.source_has_tag(source, tag, 1, include_child_tags):
			blocked_tags.append(tag)

	return {
		"ok": missing_all.is_empty() and missing_any.is_empty() and blocked_tags.is_empty(),
		"missing_all": missing_all,
		"missing_any": missing_any,
		"blocked_tags": blocked_tags,
		"include_child_tags": include_child_tags,
	}


## 配置查询条件。
## @param required_all: 必须全部存在的标签。
## @param required_any: 至少存在一个的标签。
## @param rejected_none: 不允许存在的标签。
## @param hierarchical: 是否启用层级匹配。
## @return 当前查询。
func configure(
	required_all: Array[StringName] = [],
	required_any: Array[StringName] = [],
	rejected_none: Array[StringName] = [],
	hierarchical: bool = false
) -> GFTagQuery:
	all_tags = required_all.duplicate()
	any_tags = required_any.duplicate()
	none_tags = rejected_none.duplicate()
	include_child_tags = hierarchical
	return self


## 创建同内容拷贝。
## @return 新查询。
func duplicate_query() -> GFTagQuery:
	var query := GFTagQuery.new()
	query.configure(all_tags, any_tags, none_tags, include_child_tags)
	return query


## 导出为字典。
## @return 查询字典。
func to_dictionary() -> Dictionary:
	return {
		"all_tags": all_tags.duplicate(),
		"any_tags": any_tags.duplicate(),
		"none_tags": none_tags.duplicate(),
		"include_child_tags": include_child_tags,
	}


## 从字典创建查询。
## @param data: 查询字典。
## @return 新查询。
static func from_dictionary(data: Dictionary) -> GFTagQuery:
	var query := GFTagQuery.new()
	query.all_tags = _to_string_name_array(data.get("all_tags", []))
	query.any_tags = _to_string_name_array(data.get("any_tags", []))
	query.none_tags = _to_string_name_array(data.get("none_tags", []))
	query.include_child_tags = bool(data.get("include_child_tags", false))
	return query


# --- 私有/辅助方法 ---

static func _to_string_name_array(values: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if values is PackedStringArray:
		for value: String in values:
			result.append(StringName(value))
	elif values is Array:
		for value: Variant in values:
			result.append(StringName(value))
	return result
