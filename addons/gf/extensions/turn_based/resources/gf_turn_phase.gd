## GFTurnPhase: 通用回合阶段基类。
##
## 阶段只提供 _enter/_execute/_exit 生命周期和完成信号，
## 不绑定任何具体游戏流程。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.17.0
class_name GFTurnPhase
extends Resource


# --- 信号 ---

## 阶段完成时发出。
## [br]
## @api public
signal finished


# --- 导出变量 ---

## 阶段标识。
## [br]
## @api public
@export var phase_id: StringName = &""

## `_execute()` 返回后是否自动完成阶段。
## [br]
## @api public
@export var auto_finish: bool = true


# --- 公共变量 ---

## 当前阶段是否已经完成。
## [br]
## @api public
var is_finished: bool = false


# --- 公共方法 ---

## 标记阶段完成。
## [br]
## @api public
func finish() -> void:
	if is_finished:
		return
	is_finished = true
	finished.emit()


## 重置阶段运行状态。
## [br]
## @api public
func reset() -> void:
	is_finished = false


# --- 可重写钩子 / 虚方法 ---

## 进入阶段时由 GFTurnFlowSystem 调用。
## [br]
## @api protected
## [br]
## @param _context: 回合上下文。
func _enter(_context: GFTurnContext) -> void:
	pass


## 执行阶段逻辑时由 GFTurnFlowSystem 调用。
## [br]
## @api protected
## [br]
## @param _context: 回合上下文。
## [br]
## @return 可等待结果。
## [br]
## @schema return: Variant that is null or a Signal awaited before phase completion.
func _execute(_context: GFTurnContext) -> Variant:
	return null


## 退出阶段时由 GFTurnFlowSystem 调用。
## [br]
## @api protected
## [br]
## @param _context: 回合上下文。
func _exit(_context: GFTurnContext) -> void:
	pass
