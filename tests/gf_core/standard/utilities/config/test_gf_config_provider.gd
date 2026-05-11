## 测试 GFConfigProvider 基类的默认行为。
extends GutTest


# --- Godot 生命周期方法 ---

func before_each() -> void:
	pass


func after_each() -> void:
	pass


# --- 测试 ---

## 验证调用基类的 get_record 会报错并返回 null。
func test_get_record_default() -> void:
	var provider := GFConfigProvider.new()
	var result: Variant = provider.get_record(&"ItemTable", 1)
	assert_null(result, "基类 get_record 默认应返回 null")
	assert_push_error("[GFConfigProvider] 子类必须实现 get_record() 方法。")


## 验证调用基类的 get_table 会报错并返回 null。
func test_get_table_default() -> void:
	var provider := GFConfigProvider.new()
	var result: Variant = provider.get_table(&"ItemTable")
	assert_null(result, "基类 get_table 默认应返回 null")
	assert_push_error("[GFConfigProvider] 子类必须实现 get_table() 方法。")
