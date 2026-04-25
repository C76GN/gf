## 测试 GFNumberFormatter 的完整显示、紧凑缩写与科学计数法行为。
extends GutTest


const GF_BIG_NUMBER := preload("res://addons/gf/foundation/numeric/gf_big_number.gd")
const GF_FIXED_DECIMAL := preload("res://addons/gf/foundation/numeric/gf_fixed_decimal.gd")
const GF_NUMBER_FORMATTER := preload("res://addons/gf/foundation/formatting/gf_number_formatter.gd")


func test_format_compact_supports_k_suffix() -> void:
	var text = GF_NUMBER_FORMATTER.format_compact(1_000, 0)

	assert_eq(text, "1k", "1000 在紧凑模式下应格式化为 1k。")


func test_format_compact_can_keep_fractional_precision() -> void:
	var text = GF_NUMBER_FORMATTER.format_compact(12_345, 3)

	assert_eq(text, "12.345k", "12345 在 3 位小数紧凑模式下应得到 12.345k。")


func test_format_scientific_supports_multiple_styles() -> void:
	var scientific = GF_NUMBER_FORMATTER.format_scientific(1_000_000, 0)
	var power_text = GF_NUMBER_FORMATTER.format_scientific(
		1_000_000,
		0,
		true,
		false,
		GF_NUMBER_FORMATTER.ScientificStyle.POWER_OF_TEN
	)

	assert_eq(scientific, "1e6", "科学计数法默认应输出 e 风格。")
	assert_eq(power_text, "1 x 10^6", "POWER_OF_TEN 风格应输出 x 10^n。")


func test_format_full_understands_fixed_decimal() -> void:
	var money = GF_FIXED_DECIMAL.from_string("1234.500", 3)
	var text = GF_NUMBER_FORMATTER.format_full(money, 3, true)

	assert_eq(text, "1234.5", "FULL 模式应能直接格式化定点小数。")


func test_format_full_respects_truncation_for_fixed_decimal() -> void:
	var value = GF_FIXED_DECIMAL.from_string("1.239", 3)
	var text = GF_NUMBER_FORMATTER.format_full(value, 2, false, false, true)

	assert_eq(text, "1.23", "FULL 模式格式化定点小数时应遵守 use_truncation。")


func test_format_auto_falls_back_to_scientific_for_huge_values() -> void:
	var huge = GF_BIG_NUMBER.from_string("1e60")
	var text = GF_NUMBER_FORMATTER.format_auto(huge, 0)

	assert_eq(text, "1e60", "超出紧凑后缀表的超大数应自动回退到科学计数法。")
