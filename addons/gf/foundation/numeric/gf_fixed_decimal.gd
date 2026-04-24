## GFFixedDecimal: 基于整数缩放的定点小数值对象。
##
## 适合处理货币、税率、经营数值等对“累计误差”敏感、
## 但又不需要无限精度十进制库的场景。
class_name GFFixedDecimal
extends RefCounted


# --- 枚举 ---

## 缩放或除法时使用的舍入策略。
enum RoundingMode {
	## 四舍五入，0.5 始终朝绝对值更大的方向进位。
	HALF_UP,
	## 银行家舍入，0.5 时向最近的偶数靠拢。
	HALF_EVEN,
	## 向负无穷方向取整。
	FLOOR,
	## 向正无穷方向取整。
	CEIL,
	## 直接截断，朝 0 逼近。
	TRUNCATE,
}


# --- 公共变量 ---

## 实际保存的整数值。
var raw_value: int = 0

## 小数位数。
var decimal_places: int = 2


# --- Godot 生命周期方法 ---

func _init(p_raw_value: int = 0, p_decimal_places: int = 2) -> void:
	raw_value = p_raw_value
	decimal_places = maxi(p_decimal_places, 0)


# --- 公共方法 ---

## 从 int 构建定点数。
## @param value: 原始整数。
## @param p_decimal_places: 目标小数位。
## @return 定点数实例。
static func from_int(value: int, p_decimal_places: int = 2) -> GFFixedDecimal:
	var places := maxi(p_decimal_places, 0)
	return GFFixedDecimal.new(value * _pow10_int(places), places)


## 从 float 构建定点数。
## @param value: 原始浮点数。
## @param p_decimal_places: 目标小数位。
## @param rounding_mode: 舍入策略。
## @return 定点数实例。
static func from_float(
	value: float,
	p_decimal_places: int = 2,
	rounding_mode: RoundingMode = RoundingMode.HALF_UP
) -> GFFixedDecimal:
	var places := maxi(p_decimal_places, 0)
	var scaled_value := value * _pow10_float(places)
	var rounded := _round_scaled_float(scaled_value, rounding_mode)
	return GFFixedDecimal.new(rounded, places)


## 从字符串构建定点数。
## @param value: 普通十进制字符串。
## @param p_decimal_places: 目标小数位。
## @param rounding_mode: 舍入策略。
## @return 定点数实例。
static func from_string(
	value: String,
	p_decimal_places: int = 2,
	rounding_mode: RoundingMode = RoundingMode.HALF_UP
) -> GFFixedDecimal:
	var places := maxi(p_decimal_places, 0)
	var trimmed := value.strip_edges().replace("_", "").replace(",", "")
	if trimmed.is_empty():
		return GFFixedDecimal.new(0, places)

	if trimmed.find("e") != -1 or trimmed.find("E") != -1:
		return GFFixedDecimal.from_float(trimmed.to_float(), places, rounding_mode)

	var sign := 1
	if trimmed.begins_with("-"):
		sign = -1
		trimmed = trimmed.substr(1)
	elif trimmed.begins_with("+"):
		trimmed = trimmed.substr(1)

	var decimal_index := trimmed.find(".")
	var integer_part := trimmed
	var fractional_part := ""
	if decimal_index != -1:
		integer_part = trimmed.substr(0, decimal_index)
		fractional_part = trimmed.substr(decimal_index + 1)

	if integer_part.is_empty():
		integer_part = "0"

	var digits := integer_part + fractional_part
	if digits.is_empty():
		digits = "0"

	var parsed_raw := digits.to_int() * sign
	var parsed_places := fractional_part.length()
	return GFFixedDecimal.new(parsed_raw, parsed_places).rescaled(places, rounding_mode)


## 克隆当前定点数。
## @return 内容相同的新实例。
func clone() -> GFFixedDecimal:
	return GFFixedDecimal.new(raw_value, decimal_places)


## 当前值是否为零。
## @return 为零时返回 true。
func is_zero() -> bool:
	return raw_value == 0


## 获取绝对值。
## @return 新的定点数实例。
func abs_value() -> GFFixedDecimal:
	return GFFixedDecimal.new(int(abs(raw_value)), decimal_places)


## 获取相反数。
## @return 新的定点数实例。
func negated() -> GFFixedDecimal:
	return GFFixedDecimal.new(-raw_value, decimal_places)


## 重设小数位数。
## @param target_decimal_places: 目标小数位数。
## @param rounding_mode: 降位时的舍入策略。
## @return 重设后的定点数实例。
func rescaled(
	target_decimal_places: int,
	rounding_mode: RoundingMode = RoundingMode.HALF_UP
) -> GFFixedDecimal:
	var target_places := maxi(target_decimal_places, 0)
	if target_places == decimal_places:
		return clone()

	return GFFixedDecimal.new(
		_rescale_raw(raw_value, decimal_places, target_places, rounding_mode),
		target_places
	)


## 与另一个定点数比较大小。
## @param other: 另一个定点数。
## @return 大于返回 1，小于返回 -1，相等返回 0。
func compare_to(other: GFFixedDecimal) -> int:
	if other == null:
		return 1

	var target_places := maxi(decimal_places, other.decimal_places)
	var self_raw := _align_raw_for_compare(target_places)
	var other_raw := other._align_raw_for_compare(target_places)

	if self_raw == other_raw:
		return 0

	return 1 if self_raw > other_raw else -1


## 与另一个定点数相加。
## @param other: 另一个定点数。
## @return 相加结果。
func add(other: GFFixedDecimal) -> GFFixedDecimal:
	if other == null:
		return clone()

	var target_places := maxi(decimal_places, other.decimal_places)
	var left_raw := _align_raw_for_compare(target_places)
	var right_raw := other._align_raw_for_compare(target_places)
	return GFFixedDecimal.new(left_raw + right_raw, target_places)


## 与另一个定点数相减。
## @param other: 另一个定点数。
## @return 相减结果。
func subtract(other: GFFixedDecimal) -> GFFixedDecimal:
	if other == null:
		return clone()

	return add(other.negated())


## 与另一个定点数相乘。
## @param other: 另一个定点数。
## @param target_decimal_places: 结果小数位；传 -1 时取两者较大值。
## @param rounding_mode: 结果降位时的舍入策略。
## @return 相乘结果。
func multiply(
	other: GFFixedDecimal,
	target_decimal_places: int = -1,
	rounding_mode: RoundingMode = RoundingMode.HALF_UP
) -> GFFixedDecimal:
	if other == null:
		return clone()

	var product_raw := raw_value * other.raw_value
	var product_places := decimal_places + other.decimal_places
	var result_places := target_decimal_places
	if result_places < 0:
		result_places = maxi(decimal_places, other.decimal_places)

	return GFFixedDecimal.new(product_raw, product_places).rescaled(result_places, rounding_mode)


## 与另一个定点数相除。
## @param other: 另一个定点数。
## @param target_decimal_places: 结果小数位；传 -1 时取两者较大值。
## @param rounding_mode: 除法舍入策略。
## @return 相除结果。
func divide(
	other: GFFixedDecimal,
	target_decimal_places: int = -1,
	rounding_mode: RoundingMode = RoundingMode.HALF_UP
) -> GFFixedDecimal:
	if other == null or other.raw_value == 0:
		push_error("[GFFixedDecimal] 尝试除以空值或零值。")
		return GFFixedDecimal.new(0, maxi(target_decimal_places, decimal_places))

	var result_places := target_decimal_places
	if result_places < 0:
		result_places = maxi(decimal_places, other.decimal_places)

	var shift := result_places + other.decimal_places - decimal_places
	var numerator := raw_value
	var denominator := other.raw_value
	if shift >= 0:
		numerator *= _pow10_int(shift)
	else:
		denominator *= _pow10_int(-shift)

	var divided_raw := _divide_with_rounding(numerator, denominator, rounding_mode)
	return GFFixedDecimal.new(divided_raw, result_places)


## 转换为 float。
## @return 浮点值。
func to_float() -> float:
	return float(raw_value) / _pow10_float(decimal_places)


## 转换为 GFBigNumber。
## @return 对应的大数值对象。
func to_big_number() -> Object:
	var big_number_script := load("res://addons/gf/foundation/numeric/gf_big_number.gd") as Script
	return big_number_script.from_string(to_decimal_string(false))


## 转换为普通字符串。
## @param trim_zeroes: 是否裁掉尾部 0。
## @return 十进制字符串。
func to_decimal_string(trim_zeroes: bool = false) -> String:
	if decimal_places == 0:
		return str(raw_value)

	var sign_text := ""
	var abs_raw := raw_value
	if raw_value < 0:
		sign_text = "-"
		abs_raw = -raw_value

	var scale := _pow10_int(decimal_places)
	var integer_part := int(abs_raw / scale)
	var fractional_part := abs_raw % scale
	var fractional_text := _left_pad(str(fractional_part), decimal_places, "0")
	if trim_zeroes:
		while fractional_text.ends_with("0"):
			fractional_text = fractional_text.left(fractional_text.length() - 1)

	if fractional_text.is_empty():
		return sign_text + str(integer_part)

	return sign_text + str(integer_part) + "." + fractional_text


# --- 私有/辅助方法 ---

func _align_raw_for_compare(target_decimal_places: int) -> int:
	if target_decimal_places <= decimal_places:
		return raw_value

	return raw_value * _pow10_int(target_decimal_places - decimal_places)


static func _rescale_raw(
	value: int,
	from_places: int,
	to_places: int,
	rounding_mode: RoundingMode
) -> int:
	if to_places == from_places:
		return value

	if to_places > from_places:
		return value * _pow10_int(to_places - from_places)

	var divisor := _pow10_int(from_places - to_places)
	return _divide_with_rounding(value, divisor, rounding_mode)


static func _divide_with_rounding(
	numerator: int,
	denominator: int,
	rounding_mode: RoundingMode
) -> int:
	if denominator == 0:
		push_error("[GFFixedDecimal] 尝试进行零除。")
		return 0

	var negative := (numerator < 0) != (denominator < 0)
	var abs_numerator := int(abs(numerator))
	var abs_denominator := int(abs(denominator))
	var quotient := int(abs_numerator / abs_denominator)
	var remainder := abs_numerator % abs_denominator
	var adjusted := quotient

	match rounding_mode:
		RoundingMode.HALF_UP:
			if remainder * 2 >= abs_denominator:
				adjusted += 1
		RoundingMode.HALF_EVEN:
			var doubled_remainder := remainder * 2
			if doubled_remainder > abs_denominator:
				adjusted += 1
			elif doubled_remainder == abs_denominator and quotient % 2 != 0:
				adjusted += 1
		RoundingMode.FLOOR:
			if negative and remainder != 0:
				adjusted += 1
		RoundingMode.CEIL:
			if not negative and remainder != 0:
				adjusted += 1
		RoundingMode.TRUNCATE:
			pass

	return -adjusted if negative else adjusted


static func _round_scaled_float(value: float, rounding_mode: RoundingMode) -> int:
	match rounding_mode:
		RoundingMode.FLOOR:
			return int(floor(value))
		RoundingMode.CEIL:
			return int(ceil(value))
		RoundingMode.TRUNCATE:
			if value >= 0.0:
				return int(floor(value))
			return int(ceil(value))
		RoundingMode.HALF_UP:
			if value >= 0.0:
				return int(floor(value + 0.5))
			return int(ceil(value - 0.5))
		RoundingMode.HALF_EVEN:
			var sign := 1
			var abs_value: float = value
			if value < 0.0:
				sign = -1
				abs_value = -value

			var integer_part: float = floor(abs_value)
			var fraction: float = abs_value - integer_part
			var rounded := int(integer_part)
			if fraction > 0.5:
				rounded += 1
			elif is_equal_approx(fraction, 0.5) and rounded % 2 != 0:
				rounded += 1

			return rounded * sign

	return int(round(value))


static func _pow10_int(power: int) -> int:
	var result := 1
	for _i in range(power):
		result *= 10
	return result


static func _pow10_float(power: int) -> float:
	return pow(10.0, power)


static func _left_pad(text: String, width: int, fill_char: String) -> String:
	var result := text
	while result.length() < width:
		result = fill_char + result
	return result
