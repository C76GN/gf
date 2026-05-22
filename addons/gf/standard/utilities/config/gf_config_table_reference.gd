## GFConfigTableReference: 导表跨表引用声明。
##
## 描述当前记录的一组字段如何指向另一张表的一组字段。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFConfigTableReference
extends Resource


# --- 导出变量 ---

## 引用稳定标识。为空时会根据来源字段和目标表生成。
## [br]
## @api public
@export var reference_id: StringName = &""

## 当前表中参与引用的字段名。
## [br]
## @api public
@export var source_fields: PackedStringArray = PackedStringArray()

## 目标表名。
## [br]
## @api public
@export var target_table_name: StringName = &""

## 目标表中参与匹配的字段名。为空时由目标 schema 的 id_field 补齐。
## [br]
## @api public
@export var target_fields: PackedStringArray = PackedStringArray()

## 为 true 时，非空引用必须能在目标表中找到。
## [br]
## @api public
@export var required: bool = true

## 是否允许来源字段值为 null。
## [br]
## @api public
@export var allow_null_values: bool = true

## 可选元数据，供导入器、编辑器或项目层扩展使用。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary，保存导入器、编辑器或项目层附加到当前引用的元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取稳定引用标识。
## [br]
## @api public
## [br]
## @return 引用标识。
func get_reference_id() -> StringName:
	if reference_id != &"":
		return reference_id
	return StringName("%s->%s" % ["+".join(source_fields), String(target_table_name)])


## 检查引用声明是否有效。
## [br]
## @api public
## [br]
## @return 有效返回 true。
func is_valid_definition() -> bool:
	return not source_fields.is_empty() and target_table_name != &""


## 获取目标字段名。
## [br]
## @api public
## [br]
## @param target_schema: 可选目标 schema。
## [br]
## @return 目标字段列表。
func get_target_fields(target_schema: GFConfigTableSchema = null) -> PackedStringArray:
	if not target_fields.is_empty():
		return target_fields.duplicate()
	var result := PackedStringArray()
	if target_schema != null and target_schema.id_field != &"":
		result.append(String(target_schema.id_field))
	return result


## 根据来源记录构建引用键。
## [br]
## @api public
## [br]
## @param record: 来源记录。
## [br]
## @return 引用键；字段缺失或 null 不允许时返回空字符串。
## [br]
## @schema record: Dictionary，用于构建引用键的来源配置记录。
func make_source_key(record: Dictionary) -> String:
	return _make_key(record, source_fields)


## 根据目标记录构建引用键。
## [br]
## @api public
## [br]
## @param record: 目标记录。
## [br]
## @param target_schema: 可选目标 schema。
## [br]
## @return 引用键；字段缺失或 null 不允许时返回空字符串。
## [br]
## @schema record: Dictionary，用于构建引用键的目标配置记录。
func make_target_key(record: Dictionary, target_schema: GFConfigTableSchema = null) -> String:
	return _make_key(record, get_target_fields(target_schema))


## 创建同内容拷贝。
## [br]
## @api public
## [br]
## @return 新引用声明。
func duplicate_reference() -> GFConfigTableReference:
	var reference := GFConfigTableReference.new()
	reference.reference_id = reference_id
	reference.source_fields = source_fields.duplicate()
	reference.target_table_name = target_table_name
	reference.target_fields = target_fields.duplicate()
	reference.required = required
	reference.allow_null_values = allow_null_values
	reference.metadata = metadata.duplicate(true)
	return reference


## 导出引用声明摘要。
## [br]
## @api public
## [br]
## @return 引用声明字典。
## [br]
## @schema return: Dictionary，包含 reference_id、source_fields、target_table_name、target_fields、required、allow_null_values 和 metadata。
func describe() -> Dictionary:
	return {
		"reference_id": get_reference_id(),
		"source_fields": source_fields.duplicate(),
		"target_table_name": target_table_name,
		"target_fields": target_fields.duplicate(),
		"required": required,
		"allow_null_values": allow_null_values,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _make_key(record: Dictionary, fields: PackedStringArray) -> String:
	if fields.is_empty():
		return ""
	var parts := PackedStringArray()
	for field_name: String in fields:
		var key := StringName(field_name)
		if not record.has(key):
			return ""
		var value: Variant = record[key]
		if value == null and not allow_null_values:
			return ""
		parts.append("%d:%s" % [typeof(value), var_to_str(value)])
	return "|".join(parts)
