## GFConfigTableIndexDefinition: 导表索引声明。
##
## 描述一组字段如何组成查询键或唯一键，不绑定任何具体业务表。
class_name GFConfigTableIndexDefinition
extends Resource


# --- 导出变量 ---

## 索引稳定标识。为空时会根据字段名生成。
@export var index_id: StringName = &""

## 参与索引的字段名，顺序会影响复合键。
@export var field_names: PackedStringArray = PackedStringArray()

## 为 true 时校验表数据中该复合键唯一。
@export var unique: bool = false

## 是否允许索引键中出现 null 值。
@export var allow_null_values: bool = true

## 可选元数据，供导入器、编辑器或项目层扩展使用。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取稳定索引标识。
## @return 索引标识。
func get_index_id() -> StringName:
	if index_id != &"":
		return index_id
	return StringName("+".join(field_names))


## 检查索引声明是否有效。
## @return 有效返回 true。
func is_valid_definition() -> bool:
	return not field_names.is_empty() and get_index_id() != &""


## 根据记录构建索引键。
## @param record: 记录数据。
## @return 索引键；字段缺失或 null 不允许时返回空字符串。
func make_key(record: Dictionary) -> String:
	var parts := PackedStringArray()
	for field_name: String in field_names:
		var key := StringName(field_name)
		if not record.has(key):
			return ""
		var value: Variant = record[key]
		if value == null and not allow_null_values:
			return ""
		parts.append("%d:%s" % [typeof(value), var_to_str(value)])
	return "|".join(parts)


## 创建同内容拷贝。
## @return 新索引声明。
func duplicate_index() -> GFConfigTableIndexDefinition:
	var index := GFConfigTableIndexDefinition.new()
	index.index_id = index_id
	index.field_names = field_names.duplicate()
	index.unique = unique
	index.allow_null_values = allow_null_values
	index.metadata = metadata.duplicate(true)
	return index


## 导出索引声明摘要。
## @return 索引声明字典。
func describe() -> Dictionary:
	return {
		"index_id": get_index_id(),
		"field_names": field_names.duplicate(),
		"unique": unique,
		"allow_null_values": allow_null_values,
		"metadata": metadata.duplicate(true),
	}
