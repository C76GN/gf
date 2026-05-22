## GFSequenceStep: 可资源化的序列步骤基类。
##
## 子类重写 `execute()` 返回 `Signal` 时，`GFCommandSequence`
## 默认会等待该信号完成；也可以关闭 `wait_for_result` 让步骤异步旁路。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.17.0
class_name GFSequenceStep
extends Resource


# --- 导出变量 ---

## 步骤标识，便于调试和序列编辑器显示。
## [br]
## @api public
@export var step_id: StringName = &""

## 是否等待 `execute()` 返回的 Signal。
## [br]
## @api public
@export var wait_for_result: bool = true


# --- 公共方法 ---

## 执行步骤。
## [br]
## @api public
## [br]
## @param _context: 序列上下文。
## [br]
## @return 可返回 null 或 Signal。
## [br]
## @schema return: Variant, null or Signal.
func execute(_context: GFSequenceContext) -> Variant:
	return null


## 请求取消步骤。
## [br]
## @api public
## [br]
## @param _context: 序列上下文。
func cancel(_context: GFSequenceContext) -> void:
	pass
