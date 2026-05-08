extends GutTest


# --- 常量 ---

const GF_CONFIG_ACCESS_GENERATOR_BASE := preload("res://addons/gf/editor/gf_config_access_generator.gd")


# --- 测试用例 ---

func test_build_source_generates_config_accessors() -> void:
	var schema := GFConfigTableSchema.new()
	schema.table_name = &"item_data"
	var generator: Variant = GF_CONFIG_ACCESS_GENERATOR_BASE.new()

	var source: String = generator.build_source([schema])

	assert_true(source.contains("class_name GFConfigAccess"), "应生成默认访问器类。")
	assert_true(source.contains("const ITEM_DATA: StringName = &\"item_data\""), "应生成表名常量。")
	assert_true(source.contains("static func get_item_data_record(id: Variant, provider: GFConfigProvider = null) -> Variant:"), "应生成记录读取方法。")
	assert_true(source.contains("return resolved_provider.get_record(ITEM_DATA, id)"), "记录读取方法应委托给 GFConfigProvider。")
	assert_true(source.contains("static func get_item_data_table(provider: GFConfigProvider = null) -> Variant:"), "应生成整表读取方法。")


func test_build_source_sanitizes_invalid_table_names() -> void:
	var schema := GFConfigTableSchema.new()
	schema.table_name = &"123 item-data"
	var generator: Variant = GF_CONFIG_ACCESS_GENERATOR_BASE.new()

	var source: String = generator.build_source([schema], "MyConfigAccess", "null")

	assert_true(source.contains("class_name MyConfigAccess"), "应允许自定义访问器类名。")
	assert_true(source.contains("const TABLE_123_ITEM_DATA: StringName = &\"123 item-data\""), "非法标识符字符应转为有效常量名。")
	assert_true(source.contains("static func get_table_123_item_data_record"), "数字开头表名应生成安全方法前缀。")
	assert_true(source.contains("\treturn null"), "应允许自定义 provider_accessor。")
