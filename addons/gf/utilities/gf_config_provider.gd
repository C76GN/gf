## GFConfigProvider: 通用的静态导表数据适配器基类。
##
## 为了让框架无缝衔接不同项目的导表工具（JSON, CSV, Luban 等），提供统一的读取接口。
## 具体项目应该继承此基类，并实现其数据加载和查询逻辑。
class_name GFConfigProvider
extends GFUtility


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
