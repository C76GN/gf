## GFConfigProvider: 通用的静态导表数据适配器基类。
##
## 为了让框架无缝衔接不同项目的导表工具（JSON, CSV, Luban 等），提供统一的读取接口。
## 具体项目应该继承此基类，并实现其数据加载和查询逻辑。
class_name GFConfigProvider
extends GFUtility


# --- 私有变量 ---

var _schemas: Dictionary = {}


# --- 公共方法 ---

## 根据表名和 ID 获取单条记录。
## @param _table_name: 表名。
## @param _id: 记录的唯一标识符。
## @return 返回对应的记录数据，默认返回 null 并报错。
func get_record(_table_name: StringName, _id: Variant) -> Variant:
	push_error("[GFConfigProvider] 子类必须实现 get_record() 方法。")
	return null


## 根据表名获取整张表的数据。
## @param _table_name: 表名。
## @return 返回整张表的数据，默认返回 null 并报错。
func get_table(_table_name: StringName) -> Variant:
	push_error("[GFConfigProvider] 子类必须实现 get_table() 方法。")
	return null


## 注册导表结构声明。
## @param schema: 表结构声明。
## @return 注册成功返回 true。
func register_schema(schema: GFConfigTableSchema) -> bool:
	if schema == null or schema.get_table_key() == &"":
		push_error("[GFConfigProvider] register_schema 失败：schema 为空或 table_name 为空。")
		return false

	_schemas[schema.get_table_key()] = schema.duplicate_schema()
	return true


## 注销导表结构声明。
## @param table_name: 表名。
func unregister_schema(table_name: StringName) -> void:
	_schemas.erase(table_name)


## 检查是否注册了导表结构声明。
## @param table_name: 表名。
## @return 已注册返回 true。
func has_schema(table_name: StringName) -> bool:
	return _schemas.has(table_name)


## 获取导表结构声明。
## @param table_name: 表名。
## @return 已注册时返回 schema，否则返回 null。
func get_schema(table_name: StringName) -> GFConfigTableSchema:
	return _schemas.get(table_name) as GFConfigTableSchema


## 获取已注册的导表结构标识。
## @return 表名列表。
func get_schema_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for table_name: StringName in _schemas.keys():
		result.append(String(table_name))
	result.sort()
	return result


## 使用已注册 schema 校验单条记录。
## @param table_name: 表名。
## @param record: 记录字典。
## @param row_key: 可选行标识。
## @return 校验报告字典。
func validate_record(table_name: StringName, record: Dictionary, row_key: Variant = null) -> Dictionary:
	var schema := get_schema(table_name)
	if schema == null:
		return _make_missing_schema_report(table_name)
	return schema.validate_record(record, row_key)


## 使用已注册 schema 校验整张表。
## @param table_name: 表名。
## @param table_data: 可选表数据；为 null 时调用 get_table()。
## @return 校验报告字典。
func validate_table(table_name: StringName, table_data: Variant = null) -> Dictionary:
	var schema := get_schema(table_name)
	if schema == null:
		return _make_missing_schema_report(table_name)

	var data: Variant = table_data
	if data == null:
		data = get_table(table_name)
	return schema.validate_table(data)


## 使用已注册 schema 转换单条记录。
## @param table_name: 表名。
## @param record: 记录字典。
## @return 转换后的新记录；缺少 schema 时返回记录拷贝。
func coerce_record(table_name: StringName, record: Dictionary) -> Dictionary:
	var schema := get_schema(table_name)
	if schema == null:
		return record.duplicate(true)
	return schema.coerce_record(record)


# --- 私有/辅助方法 ---

func _make_missing_schema_report(table_name: StringName) -> Dictionary:
	return {
		"ok": false,
		"table_name": table_name,
		"row_count": 0,
		"error_count": 1,
		"warning_count": 0,
		"issues": [{
			"severity": "error",
			"code": "missing_schema",
			"table_name": table_name,
			"row_key": null,
			"field": &"",
			"message": "未注册导表结构声明：%s。" % String(table_name),
		}],
	}
