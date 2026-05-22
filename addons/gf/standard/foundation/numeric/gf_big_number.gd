## GFBigNumber: 面向挂机/放置场景的近似大数值对象。
##
## 使用科学计数法的尾数 + 指数表示任意量级的数值，
## 适合做超出原生 int/float 直观显示范围后的比较、加减乘除与格式化输入。
## [br]
## @api public
## [br]
## @category value_object
## [br]
## @since 3.17.0
class_name GFBigNumber
extends RefCounted


# --- 常量 ---

# 归一化时判定为零的误差阈值。
const _NORMALIZATION_EPSILON: float = 0.000000000001

# 做加减法时，指数差超过该阈值则忽略较小项。
const _ADDITION_DROP_THRESHOLD: int = 18

# to_plain_string() 默认保留的小数位数。
const _DEFAULT_PLAIN_DECIMALS: int = 6

const _DECIMAL_STRING_FORMATTER: Script = preload("res://addons/gf/standard/foundation/formatting/gf_decimal_string_formatter.gd")


# --- 公共变量 ---

## 归一化后的尾数。非零时其绝对值始终落在 [1, 10) 区间内。
## [br]
## @api public
var mantissa: float = 0.0

## 以 10 为底的指数。
## [br]
## @api public
var exponent: int = 0


# --- Godot 生命周期方法 ---

func _init(p_mantissa: float = 0.0, p_exponent: int = 0) -> void:
	mantissa = p_mantissa
	exponent = p_exponent
	_normalize()


# --- 公共方法 ---

## 创建一个值为 0 的大数。
## [br]
## @api public
## [br]
## @return 零值实例。
static func zero() -> GFBigNumber:
	return GFBigNumber.new(0.0, 0)


## 创建一个值为 1 的大数。
## [br]
## @api public
## [br]
## @return 一值实例。
static func one() -> GFBigNumber:
	return GFBigNumber.new(1.0, 0)


## 从 int 构建大数。
## [br]
## @api public
## [br]
## @param value: 原始整数。
## [br]
## @return 归一化后的大数实例。
static func from_int(value: int) -> GFBigNumber:
	return GFBigNumber.new(float(value), 0)


## 从 float 构建大数。
## [br]
## @api public
## [br]
## @param value: 原始浮点数。
## [br]
## @return 归一化后的大数实例。
static func from_float(value: float) -> GFBigNumber:
	if is_nan(value) or is_inf(value):
		push_error("[GFBigNumber] from_float 收到非法浮点值。")
		return GFBigNumber.zero()

	return GFBigNumber.new(value, 0)


## 从字符串构建大数，支持普通写法与科学计数法。
## [br]
## @api public
## [br]
## @param value: 原始字符串，如 "12345"、"1.23e8"。
## [br]
## @return 解析后的大数实例。
static func from_string(value: String) -> GFBigNumber:
	var trimmed := value.strip_edges().replace("_", "").replace(",", "")
	if trimmed.is_empty():
		return GFBigNumber.zero()

	var exponent_offset: int = 0
	var scientific_index := maxi(trimmed.find("e"), trimmed.find("E"))
	if scientific_index != -1:
		var exponent_text := trimmed.substr(scientific_index + 1)
		trimmed = trimmed.substr(0, scientific_index)
		if exponent_text.is_valid_int():
			exponent_offset = exponent_text.to_int()
		else:
			push_error("[GFBigNumber] 无法解析科学计数法指数：%s" % value)
			return GFBigNumber.zero()

	var sign: float = 1.0
	if trimmed.begins_with("-"):
		sign = -1.0
		trimmed = trimmed.substr(1)
	elif trimmed.begins_with("+"):
		trimmed = trimmed.substr(1)

	var decimal_index := trimmed.find(".")
	var integer_part := trimmed
	var fractional_part := ""
	if decimal_index != -1:
		integer_part = trimmed.substr(0, decimal_index)
		fractional_part = trimmed.substr(decimal_index + 1)

	if not _DECIMAL_STRING_FORMATTER.is_valid_decimal_parts(integer_part, fractional_part, decimal_index != -1):
		push_error("[GFBigNumber] 无法解析数字字符串：%s" % value)
		return GFBigNumber.zero()

	var digits := integer_part + fractional_part
	var first_non_zero := -1
	for i in range(digits.length()):
		if digits.substr(i, 1) != "0":
			first_non_zero = i
			break

	if first_non_zero == -1:
		return GFBigNumber.zero()

	var significant_digits := digits.substr(first_non_zero)
	var mantissa_digits := significant_digits.substr(0, mini(16, significant_digits.length()))
	var mantissa_text := mantissa_digits.substr(0, 1)
	if mantissa_digits.length() > 1:
		mantissa_text += "." + mantissa_digits.substr(1)

	var mantissa_value := mantissa_text.to_float() * sign
	var normalized_exponent := integer_part.length() - first_non_zero - 1 + exponent_offset
	return GFBigNumber.new(mantissa_value, normalized_exponent)


## 从任意支持的 Variant 构建大数。
## [br]
## @api public
## [br]
## @param value: 支持 int/float/String/GFBigNumber/GFFixedDecimal。
## [br]
## @schema value: Variant numeric value accepted by GFBigNumber.
## [br]
## @return 对应的大数实例。
static func from_variant(value: Variant) -> GFBigNumber:
	if value is GFBigNumber:
		return (value as GFBigNumber).clone()

	if _is_fixed_decimal(value):
		return GFBigNumber.from_string(value.to_decimal_string(false))

	match typeof(value):
		TYPE_INT:
			return GFBigNumber.from_int(value)
		TYPE_FLOAT:
			return GFBigNumber.from_float(value)
		TYPE_STRING:
			return GFBigNumber.from_string(value)
		_:
			push_error("[GFBigNumber] from_variant 收到不支持的值类型。")
			return GFBigNumber.zero()


## 克隆当前大数。
## [br]
## @api public
## [br]
## @return 内容相同的新实例。
func clone() -> GFBigNumber:
	return GFBigNumber.new(mantissa, exponent)


## 当前值是否为零。
## [br]
## @api public
## [br]
## @return 为零时返回 true。
func is_zero() -> bool:
	return absf(mantissa) <= _NORMALIZATION_EPSILON


## 当前值是否为负数。
## [br]
## @api public
## [br]
## @return 为负时返回 true。
func is_negative() -> bool:
	return mantissa < 0.0


## 获取绝对值。
## [br]
## @api public
## [br]
## @return 新的大数实例。
func abs_value() -> GFBigNumber:
	return GFBigNumber.new(absf(mantissa), exponent)


## 获取相反数。
## [br]
## @api public
## [br]
## @return 新的大数实例。
func negated() -> GFBigNumber:
	return GFBigNumber.new(-mantissa, exponent)


## 比较当前值与另一个大数。
## [br]
## @api public
## [br]
## @param other: 另一个大数实例。
## [br]
## @return 当前值大于 other 返回 1，小于返回 -1，相等返回 0。
func compare_to(other: GFBigNumber) -> int:
	if other == null:
		return 1

	if is_zero() and other.is_zero():
		return 0

	var self_sign := _get_sign(mantissa)
	var other_sign := _get_sign(other.mantissa)
	if self_sign != other_sign:
		return 1 if self_sign > other_sign else -1

	if exponent != other.exponent:
		if self_sign > 0:
			return 1 if exponent > other.exponent else -1
		return -1 if exponent > other.exponent else 1

	if is_equal_approx(mantissa, other.mantissa):
		return 0

	return 1 if mantissa > other.mantissa else -1


## 与另一个大数相加。
## [br]
## @api public
## [br]
## @param other: 另一个大数实例。
## [br]
## @return 相加结果。
func add(other: GFBigNumber) -> GFBigNumber:
	if other == null or other.is_zero():
		return clone()

	if is_zero():
		return other.clone()

	var exponent_diff := exponent - other.exponent
	if exponent_diff >= _ADDITION_DROP_THRESHOLD:
		return clone()

	if exponent_diff <= -_ADDITION_DROP_THRESHOLD:
		return other.clone()

	if exponent_diff >= 0:
		return GFBigNumber.new(
			mantissa + other.mantissa / pow(10.0, exponent_diff),
			exponent
		)

	return GFBigNumber.new(
		mantissa / pow(10.0, -exponent_diff) + other.mantissa,
		other.exponent
	)


## 与另一个大数相减。
## [br]
## @api public
## [br]
## @param other: 另一个大数实例。
## [br]
## @return 相减结果。
func subtract(other: GFBigNumber) -> GFBigNumber:
	if other == null:
		return clone()

	return add(other.negated())


## 与另一个大数相乘。
## [br]
## @api public
## [br]
## @param other: 另一个大数实例。
## [br]
## @return 相乘结果。
func multiply(other: GFBigNumber) -> GFBigNumber:
	if other == null:
		return clone()

	if is_zero() or other.is_zero():
		return GFBigNumber.zero()

	return GFBigNumber.new(mantissa * other.mantissa, exponent + other.exponent)


## 与另一个大数相除。
## [br]
## @api public
## [br]
## @param other: 另一个大数实例。
## [br]
## @return 相除结果。
func divide(other: GFBigNumber) -> GFBigNumber:
	if other == null or other.is_zero():
		push_error("[GFBigNumber] 尝试除以空值或零值。")
		return GFBigNumber.zero()

	if is_zero():
		return GFBigNumber.zero()

	return GFBigNumber.new(mantissa / other.mantissa, exponent - other.exponent)


## 将当前大数提升到整数次幂。
## [br]
## @api public
## [br]
## @param power: 幂指数。
## [br]
## @return 幂运算结果。
func powi(power: int) -> GFBigNumber:
	return powf(float(power))


## 将当前大数提升到浮点次幂。
## [br]
## @api public
## [br]
## @param power: 幂指数。
## [br]
## @return 幂运算结果。
func powf(power: float) -> GFBigNumber:
	if is_nan(power) or is_inf(power):
		push_error("[GFBigNumber] powf 收到非法指数。")
		return GFBigNumber.zero()

	if is_zero():
		if power < 0.0:
			push_error("[GFBigNumber] 零值不能提升到负幂。")
			return GFBigNumber.zero()

		if is_equal_approx(power, 0.0):
			return GFBigNumber.one()

		return GFBigNumber.zero()

	var integer_power := round(power)
	var is_integer_power := is_equal_approx(power, integer_power)
	if is_negative() and not is_integer_power:
		push_error("[GFBigNumber] 负数不能执行非整数次幂。")
		return GFBigNumber.zero()

	var sign_multiplier: float = 1.0
	if is_negative() and int(integer_power) % 2 != 0:
		sign_multiplier = -1.0

	var abs_mantissa := absf(mantissa)
	var power_log10 := (log(abs_mantissa) / log(10.0) + float(exponent)) * power
	var power_exponent := int(floor(power_log10))
	var power_mantissa := pow(10.0, power_log10 - power_exponent) * sign_multiplier
	return GFBigNumber.new(power_mantissa, power_exponent)


## 将当前值转换为 float。
## [br]
## @api public
## [br]
## @return 可表达时返回浮点值，超出范围时返回 +/-INF。
func to_float() -> float:
	if is_zero():
		return 0.0

	return mantissa * pow(10.0, exponent)


## 在量级适中时输出普通十进制字符串，过大时会回退到科学计数法。
## [br]
## @api public
## [br]
## @param decimal_places: 小数位数。
## [br]
## @param trim_zeroes: 是否裁掉尾部 0。
## [br]
## @return 普通字符串表示。
func to_plain_string(decimal_places: int = _DEFAULT_PLAIN_DECIMALS, trim_zeroes: bool = true) -> String:
	if is_zero():
		return "0"

	if exponent > 15 or exponent < -decimal_places - 1:
		return to_scientific_string(decimal_places, trim_zeroes)

	return _DECIMAL_STRING_FORMATTER.format_decimal_value(to_float(), decimal_places, trim_zeroes, false)


## 输出科学计数法字符串。
## [br]
## @api public
## [br]
## @param decimal_places: 小数位数。
## [br]
## @param trim_zeroes: 是否裁掉尾部 0。
## [br]
## @param use_truncation: 是否使用截断而不是四舍五入。
## [br]
## @return 科学计数法字符串。
func to_scientific_string(
	decimal_places: int = 2,
	trim_zeroes: bool = true,
	use_truncation: bool = false
) -> String:
	if is_zero():
		return "0"

	var output_mantissa := mantissa
	var output_exponent := exponent
	var mantissa_text: String = _DECIMAL_STRING_FORMATTER.format_decimal_value(output_mantissa, decimal_places, trim_zeroes, use_truncation)
	if absf(mantissa_text.to_float()) >= 10.0:
		output_mantissa /= 10.0
		output_exponent += 1
		mantissa_text = _DECIMAL_STRING_FORMATTER.format_decimal_value(output_mantissa, decimal_places, trim_zeroes, use_truncation)

	return "%se%d" % [mantissa_text, output_exponent]


# --- 私有/辅助方法 ---

func _normalize() -> void:
	if absf(mantissa) <= _NORMALIZATION_EPSILON:
		mantissa = 0.0
		exponent = 0
		return

	var abs_mantissa := absf(mantissa)
	var shift := int(floor(log(abs_mantissa) / log(10.0)))
	mantissa /= pow(10.0, shift)
	exponent += shift

	while absf(mantissa) >= 10.0:
		mantissa /= 10.0
		exponent += 1

	while absf(mantissa) < 1.0 and absf(mantissa) > _NORMALIZATION_EPSILON:
		mantissa *= 10.0
		exponent -= 1

	if absf(mantissa) <= _NORMALIZATION_EPSILON:
		mantissa = 0.0
		exponent = 0


static func _get_sign(value: float) -> int:
	if value > 0.0:
		return 1

	if value < 0.0:
		return -1

	return 0


static func _is_fixed_decimal(value: Variant) -> bool:
	if not is_instance_valid(value):
		return false

	var script := value.get_script() as Script
	if script == null:
		return false

	return script.resource_path == "res://addons/gf/standard/foundation/numeric/gf_fixed_decimal.gd"
