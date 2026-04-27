## 测试 GFFixedDecimal 的构造、对齐、舍入和除法行为。
extends GutTest


const GF_FIXED_DECIMAL := preload("res://addons/gf/foundation/numeric/gf_fixed_decimal.gd")


func test_from_string_and_to_string_roundtrip() -> void:
	var value = GF_FIXED_DECIMAL.from_string("12.345", 3)

	assert_eq(value.to_decimal_string(), "12.345", "字符串构建后的定点数应保持原值。")
	assert_eq(value.decimal_places, 3, "小数位数应与构建参数一致。")


func test_add_aligns_decimal_places() -> void:
	var left = GF_FIXED_DECIMAL.from_string("1.2", 1)
	var right = GF_FIXED_DECIMAL.from_string("0.35", 2)
	var result := left.add(right)

	assert_eq(result.decimal_places, 2, "加法应自动对齐到更高的小数位。")
	assert_eq(result.to_decimal_string(), "1.55", "1.2 + 0.35 应得到 1.55。")


func test_rescaled_uses_rounding_mode() -> void:
	var value = GF_FIXED_DECIMAL.from_string("1.235", 3)
	var rounded = value.rescaled(2, GF_FIXED_DECIMAL.RoundingMode.HALF_UP)
	var truncated = value.rescaled(2, GF_FIXED_DECIMAL.RoundingMode.TRUNCATE)

	assert_eq(rounded.to_decimal_string(), "1.24", "HALF_UP 应将 1.235 收敛到 1.24。")
	assert_eq(truncated.to_decimal_string(), "1.23", "TRUNCATE 应直接截断额外小数位。")


func test_multiply_and_divide_keep_expected_scale() -> void:
	var price = GF_FIXED_DECIMAL.from_string("12.34", 2)
	var factor = GF_FIXED_DECIMAL.from_string("0.5", 1)
	var multiplied = price.multiply(factor, 2)
	var divided = GF_FIXED_DECIMAL.from_string("1", 0).divide(
		GF_FIXED_DECIMAL.from_string("3", 0),
		4,
		GF_FIXED_DECIMAL.RoundingMode.TRUNCATE
	)

	assert_eq(multiplied.to_decimal_string(), "6.17", "12.34 * 0.5 应得到 6.17。")
	assert_eq(divided.to_decimal_string(), "0.3333", "1 / 3 在 4 位小数截断下应得到 0.3333。")


func test_to_string_can_trim_trailing_zeroes() -> void:
	var value = GF_FIXED_DECIMAL.from_string("1234.500", 3)

	assert_eq(value.to_decimal_string(true), "1234.5", "trim_zeroes 应裁掉多余的尾部 0。")


func test_from_float_rejects_non_finite_values() -> void:
	var value = GF_FIXED_DECIMAL.from_float(INF, 2)

	assert_push_error("[GFFixedDecimal] from_float 收到非法浮点值。")
	assert_eq(value.to_decimal_string(), "0.00", "非法浮点值应被收敛为当前精度下的零。")


func test_decimal_places_are_clamped_to_safe_limit() -> void:
	var value = GF_FIXED_DECIMAL.from_int(1, 30)

	assert_push_error("[GFFixedDecimal] decimal_places 超出上限 18，已自动钳制。")
	assert_eq(value.decimal_places, GF_FIXED_DECIMAL.MAX_DECIMAL_PLACES, "过大的小数位应被钳制到安全上限。")


func test_from_string_rejects_malformed_decimal_text() -> void:
	var value = GF_FIXED_DECIMAL.from_string("1.2.3", 2)

	assert_push_error("[GFFixedDecimal] 无法解析数字字符串：1.2.3")
	assert_eq(value.to_decimal_string(), "0.00", "非法字符串应被收敛为当前精度下的零。")


func test_from_string_saturates_int64_boundary_overflow() -> void:
	var value = GF_FIXED_DECIMAL.from_string("9223372036854775808", 0)

	assert_push_error("[GFFixedDecimal] 数字超出可表示范围。")
	assert_eq(value.raw_value, 9_223_372_036_854_775_807, "超过 int64 正边界的字符串应被钳制。")


func test_add_overflow_saturates_without_wraparound() -> void:
	var left = GF_FIXED_DECIMAL.new(9_223_372_036_854_775_000, 0)
	var right = GF_FIXED_DECIMAL.new(1_000, 0)
	var result := left.add(right)

	assert_push_error("[GFFixedDecimal] add 结果超出可表示范围，已钳制。")
	assert_eq(result.raw_value, 9_223_372_036_854_775_807, "加法溢出不应回绕为负数。")
