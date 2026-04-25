## 测试 GFBigNumber 的解析、归一化、比较和基础算术。
extends GutTest


const GF_BIG_NUMBER := preload("res://addons/gf/foundation/numeric/gf_big_number.gd")


func test_from_string_normalizes_plain_number() -> void:
	var value = GF_BIG_NUMBER.from_string("123450000")

	assert_almost_eq(value.mantissa, 1.2345, 0.000001, "普通大整数字符串应被归一化到尾数。")
	assert_eq(value.exponent, 8, "123450000 应被解析为 1.2345e8。")


func test_from_string_rejects_malformed_decimal_text() -> void:
	var value = GF_BIG_NUMBER.from_string("12x.3")

	assert_push_error("[GFBigNumber] 无法解析数字字符串：12x.3")
	assert_true(value.is_zero(), "非法字符串应被收敛为零值。")


func test_add_combines_similar_exponents() -> void:
	var left = GF_BIG_NUMBER.from_string("1.5e6")
	var right = GF_BIG_NUMBER.from_string("2.25e6")
	var result := left.add(right)

	assert_almost_eq(result.mantissa, 3.75, 0.000001, "同量级加法应保留有效尾数。")
	assert_eq(result.exponent, 6, "同量级加法后指数应保持 6。")


func test_add_drops_negligible_value_when_gap_is_too_large() -> void:
	var huge = GF_BIG_NUMBER.from_string("1e30")
	var tiny = GF_BIG_NUMBER.from_string("1e5")
	var result := huge.add(tiny)

	assert_almost_eq(result.mantissa, 1.0, 0.000001, "指数差足够大时，较小项应被忽略。")
	assert_eq(result.exponent, 30, "指数差足够大时，应直接保留更大值。")


func test_multiply_and_divide_keep_normalized_form() -> void:
	var multiplied = GF_BIG_NUMBER.from_string("2.5e3").multiply(GF_BIG_NUMBER.from_string("4e2"))
	var divided = multiplied.divide(GF_BIG_NUMBER.from_string("2e2"))

	assert_almost_eq(multiplied.mantissa, 1.0, 0.000001, "乘法结果应保持归一化。")
	assert_eq(multiplied.exponent, 6, "2.5e3 * 4e2 应得到 1e6。")
	assert_almost_eq(divided.mantissa, 5.0, 0.000001, "除法结果应保持正确尾数。")
	assert_eq(divided.exponent, 3, "1e6 / 2e2 应得到 5e3。")


func test_compare_handles_sign_and_magnitude() -> void:
	var positive = GF_BIG_NUMBER.from_string("3e9")
	var smaller_positive = GF_BIG_NUMBER.from_string("2e9")
	var negative = GF_BIG_NUMBER.from_string("-1e2")

	assert_eq(positive.compare_to(smaller_positive), 1, "更大的正数应比较为 1。")
	assert_eq(smaller_positive.compare_to(positive), -1, "更小的正数应比较为 -1。")
	assert_eq(negative.compare_to(smaller_positive), -1, "负数应小于任意正数。")


func test_powi_supports_large_integer_growth() -> void:
	var value = GF_BIG_NUMBER.from_float(1.15).powi(1_000)

	assert_eq(value.exponent, 60, "1.15^1000 的数量级应稳定落在 1e60。")
	assert_almost_eq(value.mantissa, 4.987011, 0.000001, "大整数幂应保持可用的尾数精度。")


func test_powf_supports_fractional_exponents() -> void:
	var value = GF_BIG_NUMBER.from_int(50).powf(0.5)

	assert_almost_eq(value.to_float(), 7.0710678, 0.000001, "50 的平方根应约为 7.0710678。")
