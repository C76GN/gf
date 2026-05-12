extends GutTest


# --- 常量 ---

const GF_SOURCE_BUILDER_BASE := preload("res://addons/gf/kernel/editor/gf_source_builder.gd")


# --- 测试用例 ---

func test_empty_builder_builds_empty_source() -> void:
	var builder: Variant = GF_SOURCE_BUILDER_BASE.new()

	assert_eq(builder.build(), "", "空 SourceBuilder 不应生成孤立换行。")


func test_builder_formats_docs_sections_and_indentation() -> void:
	var builder: Variant = GF_SOURCE_BUILDER_BASE.new()

	builder.doc("Example: generated source.")
	builder.doc()
	builder.section("公共方法")
	builder.line("static func run() -> void:")
	builder.indent()
	builder.line("if true:")
	builder.indent()
	builder.line("return")
	builder.dedent(2)
	var source: String = builder.build()

	assert_eq(
		source,
		"## Example: generated source.\n##\n# --- 公共方法 ---\n\nstatic func run() -> void:\n\tif true:\n\t\treturn\n",
		"SourceBuilder 应稳定生成文档注释、section、空行和 tab 缩进。"
	)


func test_builder_clear_resets_source_and_indent() -> void:
	var builder: Variant = GF_SOURCE_BUILDER_BASE.new()

	builder.line("func old() -> void:").indent().line("pass").clear()
	var source: String = builder.line("func fresh() -> void:").indent().line("pass").build()

	assert_eq(source, "func fresh() -> void:\n\tpass\n", "clear() 应清空旧内容并重置缩进。")
