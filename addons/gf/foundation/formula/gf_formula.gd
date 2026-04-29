## GFFormula: 资源化公式基类。
##
## 公式是纯计算策略，不持有运行时生命周期。
## 项目可继承并重写 `calculate()`，也可通过 `calculate_float()`、
## `calculate_int()` 和 `calculate_bool()` 获得稳定的类型兜底。
class_name GFFormula
extends Resource


# --- 导出变量 ---

## 当子类没有返回有效数值时使用的兜底结果。
@export var fallback_value: Variant = 0.0


# --- 公共方法 ---

## 执行公式计算。
## @param _parameter: 公式参数容器。
## @return 公式结果。子类应重写该方法。
func calculate(_parameter: GFFormulaParameter = null) -> Variant:
	return fallback_value


## 以 float 形式执行公式。
## @param parameter: 公式参数容器。
## @param fallback: 结果无法转为数字时使用的兜底值。
## @return float 结果。
func calculate_float(parameter: GFFormulaParameter = null, fallback: float = 0.0) -> float:
	var result := calculate(parameter)
	if typeof(result) == TYPE_INT or typeof(result) == TYPE_FLOAT:
		return float(result)
	if typeof(result) == TYPE_BOOL:
		return 1.0 if result else 0.0
	if typeof(result) == TYPE_STRING or typeof(result) == TYPE_STRING_NAME:
		return String(result).to_float()
	return fallback


## 以 int 形式执行公式。
## @param parameter: 公式参数容器。
## @param fallback: 结果无法转为数字时使用的兜底值。
## @return int 结果。
func calculate_int(parameter: GFFormulaParameter = null, fallback: int = 0) -> int:
	return int(round(calculate_float(parameter, float(fallback))))


## 以 bool 形式执行公式。
## @param parameter: 公式参数容器。
## @param fallback: 结果无法转为布尔语义时使用的兜底值。
## @return bool 结果。
func calculate_bool(parameter: GFFormulaParameter = null, fallback: bool = false) -> bool:
	var result := calculate(parameter)
	if typeof(result) == TYPE_BOOL:
		return bool(result)
	if typeof(result) == TYPE_INT or typeof(result) == TYPE_FLOAT:
		return float(result) != 0.0
	if typeof(result) == TYPE_STRING or typeof(result) == TYPE_STRING_NAME:
		var text := String(result).to_lower()
		if text == "true" or text == "yes" or text == "1":
			return true
		if text == "false" or text == "no" or text == "0":
			return false
	return fallback

