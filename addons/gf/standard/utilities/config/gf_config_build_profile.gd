## GFConfigBuildProfile: 配置表构建过滤配置。
##
## 用 groups 与 tags 描述一组通用过滤条件，可用于导出前裁剪 schema 或记录。
## 具体分组名称由项目决定，GF 不内置 client、server 或 editor 语义。
class_name GFConfigBuildProfile
extends Resource


# --- 导出变量 ---

## Profile 稳定标识。
@export var profile_id: StringName = &""

## 为空时不限制包含分组；非空时 metadata 至少命中一个分组才通过。
@export var include_groups: PackedStringArray = PackedStringArray()

## 命中任意排除分组时过滤。
@export var exclude_groups: PackedStringArray = PackedStringArray()

## 为空时不限制包含标签；非空时 metadata 至少命中一个标签才通过。
@export var include_tags: PackedStringArray = PackedStringArray()

## 命中任意排除标签时过滤。
@export var exclude_tags: PackedStringArray = PackedStringArray()

## metadata 缺少 groups/tags 时是否默认保留。
@export var default_include: bool = true

## 记录中存放元数据的字段名。
@export var record_metadata_field: StringName = &"_metadata"

## metadata 中表示分组的键。
@export var groups_key: StringName = &"groups"

## metadata 中表示标签的键。
@export var tags_key: StringName = &"tags"

## 可选元数据，供项目工具扩展使用。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 判断一份 metadata 是否通过当前 Profile。
## @param source_metadata: 待检查元数据。
## @return 通过时返回 true。
func allows_metadata(source_metadata: Dictionary) -> bool:
	var groups := _to_packed_string_array(source_metadata.get(groups_key, PackedStringArray()))
	var tags := _to_packed_string_array(source_metadata.get(tags_key, PackedStringArray()))
	if groups.is_empty() and tags.is_empty():
		return default_include
	if _intersects(groups, exclude_groups) or _intersects(tags, exclude_tags):
		return false
	if not include_groups.is_empty() and not _intersects(groups, include_groups):
		return false
	if not include_tags.is_empty() and not _intersects(tags, include_tags):
		return false
	return true


## 过滤 schema，返回 schema 副本。
## @param schema: 原 schema。
## @return 过滤后的 schema；schema 为空时返回 null。
func filter_schema(schema: GFConfigTableSchema) -> GFConfigTableSchema:
	if schema == null:
		return null

	var result := schema.duplicate_schema()
	result.columns = _filter_columns(result.columns)
	result.indexes = _filter_indexes(result.indexes, result.get_column_names())
	result.references = _filter_references(result.references, result.get_column_names())
	return result


## 过滤表记录。
## @param table_data: Array[Dictionary] 或 Dictionary 表。
## @return 与输入同形状的过滤结果；输入无效时返回原值副本。
func filter_records(table_data: Variant) -> Variant:
	if table_data is Array:
		var rows: Array[Dictionary] = []
		for row_variant: Variant in table_data as Array:
			if not (row_variant is Dictionary):
				continue
			var row := (row_variant as Dictionary).duplicate(true)
			if allows_metadata(_get_record_metadata(row)):
				rows.append(row)
		return rows
	if table_data is Dictionary:
		var result: Dictionary = {}
		var table := table_data as Dictionary
		for key: Variant in table.keys():
			var row_variant: Variant = table[key]
			if not (row_variant is Dictionary):
				continue
			var row := (row_variant as Dictionary).duplicate(true)
			if allows_metadata(_get_record_metadata(row)):
				result[key] = row
		return result
	return GFVariantData.duplicate_variant(table_data)


## 创建同内容拷贝。
## @return 新 Profile。
func duplicate_profile() -> GFConfigBuildProfile:
	return duplicate(true) as GFConfigBuildProfile


## 导出 Profile 摘要。
## @return Profile 摘要字典。
func describe() -> Dictionary:
	return {
		"profile_id": profile_id,
		"include_groups": include_groups.duplicate(),
		"exclude_groups": exclude_groups.duplicate(),
		"include_tags": include_tags.duplicate(),
		"exclude_tags": exclude_tags.duplicate(),
		"default_include": default_include,
		"record_metadata_field": record_metadata_field,
		"groups_key": groups_key,
		"tags_key": tags_key,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _filter_columns(columns: Array[GFConfigTableColumn]) -> Array[GFConfigTableColumn]:
	var result: Array[GFConfigTableColumn] = []
	for column: GFConfigTableColumn in columns:
		if column != null and allows_metadata(column.metadata):
			result.append(column)
	return result


func _filter_indexes(
	indexes: Array[GFConfigTableIndexDefinition],
	column_names: PackedStringArray
) -> Array[GFConfigTableIndexDefinition]:
	var result: Array[GFConfigTableIndexDefinition] = []
	for index: GFConfigTableIndexDefinition in indexes:
		if index == null:
			continue
		if not index.metadata.is_empty() and not allows_metadata(index.metadata):
			continue
		if _all_fields_exist(index.field_names, column_names):
			result.append(index)
	return result


func _filter_references(
	references: Array[GFConfigTableReference],
	column_names: PackedStringArray
) -> Array[GFConfigTableReference]:
	var result: Array[GFConfigTableReference] = []
	for reference: GFConfigTableReference in references:
		if reference == null:
			continue
		if not reference.metadata.is_empty() and not allows_metadata(reference.metadata):
			continue
		if _all_fields_exist(reference.source_fields, column_names):
			result.append(reference)
	return result


func _all_fields_exist(fields: PackedStringArray, column_names: PackedStringArray) -> bool:
	for field_name: String in fields:
		if not column_names.has(field_name):
			return false
	return true


func _get_record_metadata(record: Dictionary) -> Dictionary:
	var value: Variant = record.get(record_metadata_field, {})
	return (value as Dictionary) if value is Dictionary else {}


func _intersects(left: PackedStringArray, right: PackedStringArray) -> bool:
	for item: String in left:
		if right.has(item):
			return true
	return false


func _to_packed_string_array(value: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	if value is PackedStringArray:
		return (value as PackedStringArray).duplicate()
	if value is Array:
		for item: Variant in value:
			result.append(String(item))
	elif typeof(value) == TYPE_STRING or typeof(value) == TYPE_STRING_NAME:
		result.append(String(value))
	return result
