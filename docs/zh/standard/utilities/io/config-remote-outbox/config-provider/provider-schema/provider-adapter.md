# Provider 适配器

`GFConfigProvider` 是抽象适配器，本身不存数据；默认实现会报错并返回 `null`。

```gdscript
class_name JSONConfigProvider
extends GFConfigProvider

var _configs: Dictionary = {}

func async_init() -> void:
	# 异步加载你的表...
	pass

func get_record(table_name: StringName, id: Variant) -> Variant:
	if _configs.has(table_name) and _configs[table_name].has(id):
		return _configs[table_name][id]
	return null

func get_table(table_name: StringName) -> Variant:
	return _configs.get(table_name)
```

返回类型保持 `Variant` 是为了兼容不同导表方案：可以返回 `Dictionary`、`Resource`、自定义记录对象，或整张表容器。

框架内调用方会按自己的需求解释返回值。例如 `GFLevelUtility` 会接受字典记录，或带 `to_dict()` 方法的记录对象。

建议子类在 `async_init()` 或 `init()` 阶段完成加载，并在 `get_record()` 中返回只读数据或副本，避免业务代码直接改坏导表缓存。

表名建议使用稳定 `StringName`，记录 ID 可保持项目导表原始类型。
