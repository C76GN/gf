## GFFormulaSet: 按键管理资源化公式的轻量集合。
##
## 适合把一组项目公式集中到配置资源里，再由 System 或 Utility
## 按 `StringName` 获取并计算。
class_name GFFormulaSet
extends Resource


# --- 导出变量 ---

## 公式表。Key 推荐为 StringName，Value 应为 GFFormula。
@export var formulas: Dictionary = {}


# --- 公共方法 ---

## 注册或替换一个公式。
## @param formula_id: 公式标识。
## @param formula: 公式资源。
func set_formula(formula_id: StringName, formula: GFFormula) -> void:
	if formula_id == &"":
		push_error("[GFFormulaSet] set_formula 失败：formula_id 为空。")
		return
	if formula == null:
		formulas.erase(formula_id)
		return
	formulas[formula_id] = formula


## 获取一个公式。
## @param formula_id: 公式标识。
## @return 公式资源；不存在时返回 null。
func get_formula(formula_id: StringName) -> GFFormula:
	return formulas.get(formula_id) as GFFormula


## 检查是否存在指定公式。
## @param formula_id: 公式标识。
## @return 存在时返回 true。
func has_formula(formula_id: StringName) -> bool:
	return formulas.has(formula_id) and formulas[formula_id] is GFFormula


## 计算指定公式。
## @param formula_id: 公式标识。
## @param parameter: 公式参数。
## @param fallback: 公式不存在时返回的结果。
## @return 公式结果或 fallback。
func calculate(formula_id: StringName, parameter: GFFormulaParameter = null, fallback: Variant = null) -> Variant:
	var formula := get_formula(formula_id)
	if formula == null:
		return fallback
	return formula.calculate(parameter)

