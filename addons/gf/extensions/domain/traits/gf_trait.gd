## GFTrait: 通用被动特征数据。
##
## 用于描述“某个来源对某个目标键产生的数值或标记影响”。
## 它不限定属性、伤害、装备等业务语义。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFTrait
extends Resource


# --- 枚举 ---

## 数值合并方式。
## [br]
## @api public
enum CombineMode {
	## 与当前值相加。
	ADD,

	## 与当前值相乘。
	MULTIPLY,

	## 直接覆盖当前值。
	SET,

	## 取当前值与特征值中的较大值。
	MAX,

	## 取当前值与特征值中的较小值。
	MIN,
}


# --- 导出变量 ---

## 特征标识。
## [br]
## @api public
@export var trait_id: StringName = &""

## 目标键，例如属性名、规则名或项目自定义键。
## [br]
## @api public
@export var target_id: StringName = &""

## 可选分类，用于过滤不同规则域。
## [br]
## @api public
@export var category: StringName = &""

## 数值。
## [br]
## @api public
@export var value: float = 0.0

## 合并方式。
## [br]
## @api public
@export var combine_mode: CombineMode = CombineMode.ADD

## 排序优先级，值越小越先应用。
## [br]
## @api public
@export var priority: int = 0

## 自定义元数据。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary，项目自定义特征元数据；GF 不读取或改写其中字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 将当前特征应用到数值上。
## [br]
## @api public
## [br]
## @param current_value: 当前值。
## [br]
## @return 应用后的值。
func apply_number(current_value: float) -> float:
	match combine_mode:
		CombineMode.ADD:
			return current_value + value
		CombineMode.MULTIPLY:
			return current_value * value
		CombineMode.SET:
			return value
		CombineMode.MAX:
			return maxf(current_value, value)
		CombineMode.MIN:
			return minf(current_value, value)
	return current_value
