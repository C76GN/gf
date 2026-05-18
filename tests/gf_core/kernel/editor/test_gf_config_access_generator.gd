extends GutTest


# --- 常量 ---

const GF_CONFIG_ACCESS_GENERATOR_BASE := preload("res://addons/gf/kernel/editor/gf_config_access_generator.gd")


# --- 测试用例 ---

func test_build_source_generates_config_accessors() -> void:
	var schema := ConfigSchemaStub.new(&"item_data")
	var generator: Variant = GF_CONFIG_ACCESS_GENERATOR_BASE.new()

	var source: String = generator.build_source([schema])

	assert_true(source.contains("class_name GFConfigAccess"), "应生成默认访问器类。")
	assert_true(source.contains("const ITEM_DATA: StringName = &\"item_data\""), "应生成表名常量。")
	assert_true(source.contains("static func get_item_data_record(id: Variant, provider: Variant = null) -> Variant:"), "应生成记录读取方法。")
	assert_true(source.contains("return resolved_provider.get_record(ITEM_DATA, id)"), "记录读取方法应委托给 provider。")
	assert_true(source.contains("static func get_item_data_table(provider: Variant = null) -> Variant:"), "应生成整表读取方法。")


func test_build_source_sanitizes_invalid_table_names() -> void:
	var schema := ConfigSchemaStub.new(&"123 item-data")
	var generator: Variant = GF_CONFIG_ACCESS_GENERATOR_BASE.new()

	var source: String = generator.build_source([schema], "MyConfigAccess", "null")

	assert_true(source.contains("class_name MyConfigAccess"), "应允许自定义访问器类名。")
	assert_true(source.contains("const TABLE_123_ITEM_DATA: StringName = &\"123 item-data\""), "非法标识符字符应转为有效常量名。")
	assert_true(source.contains("static func get_table_123_item_data_record"), "数字开头表名应生成安全方法前缀。")
	assert_true(source.contains("\treturn null"), "应允许自定义 provider_accessor。")


func test_build_source_accepts_dictionary_schemas() -> void:
	var generator: Variant = GF_CONFIG_ACCESS_GENERATOR_BASE.new()

	var source: String = generator.build_source([{ "table_name": "enemy_data" }])

	assert_true(source.contains("const ENEMY_DATA: StringName = &\"enemy_data\""), "字典 schema 应可提供表名。")


func test_build_source_reads_schema_properties_without_calling_methods() -> void:
	var schema := MethodTrapConfigSchemaStub.new(&"item_data")
	var generator: Variant = GF_CONFIG_ACCESS_GENERATOR_BASE.new()

	var source: String = generator.build_source([schema])

	assert_true(source.contains("const ITEM_DATA: StringName = &\"item_data\""), "对象 schema 应通过导出属性提供表名。")
	assert_false(schema.get_table_key_called, "编辑器生成器不应调用 schema 方法，避免 placeholder 报错。")


func test_build_source_accepts_object_table_key_property() -> void:
	var schema := TableKeyConfigSchemaStub.new(&"enemy_data")
	var generator: Variant = GF_CONFIG_ACCESS_GENERATOR_BASE.new()

	var source: String = generator.build_source([schema])

	assert_true(source.contains("const ENEMY_DATA: StringName = &\"enemy_data\""), "对象 schema 应支持 table_key 属性。")


func test_build_source_supports_gdscript_generation_options() -> void:
	var schema := ConfigSchemaStub.new(&"item_data")
	schema.metadata = { "comment": "道具配置表。" }
	var generator: Variant = GF_CONFIG_ACCESS_GENERATOR_BASE.new()

	var source: String = generator.build_source([schema], "MyConfigAccess", "null", {
		"method_name_style": "camel",
		"constant_prefix": "cfg",
		"record_method_pattern": "fetch_{table}",
		"table_method_pattern": "all_{table}",
	})

	assert_true(source.contains("const CFG_ITEM_DATA: StringName = &\"item_data\""), "常量前缀应按选项生成。")
	assert_true(source.contains("## 道具配置表。"), "schema metadata 注释应写入生成源码。")
	assert_true(source.contains("static func fetch_itemData(id: Variant, provider: Variant = null) -> Variant:"), "记录方法应按 GDScript 命名选项生成。")
	assert_true(source.contains("static func all_itemData(provider: Variant = null) -> Variant:"), "整表方法应按自定义模板生成。")


# --- 内部类 ---

class ConfigSchemaStub:
	var table_name: StringName = &""
	var metadata: Dictionary = {}

	func _init(p_table_name: StringName) -> void:
		table_name = p_table_name

	func get_table_key() -> StringName:
		return table_name


class MethodTrapConfigSchemaStub:
	var table_name: StringName = &""
	var metadata: Dictionary = {}
	var get_table_key_called: bool = false

	func _init(p_table_name: StringName) -> void:
		table_name = p_table_name

	func get_table_key() -> StringName:
		get_table_key_called = true
		return &"method_table"


class TableKeyConfigSchemaStub:
	var table_key: StringName = &""
	var metadata: Dictionary = {}

	func _init(p_table_key: StringName) -> void:
		table_key = p_table_key
