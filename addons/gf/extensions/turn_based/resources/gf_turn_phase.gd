## GFTurnPhase: 通用回合阶段基类。
##
## 阶段只提供 enter/execute/exit 生命周期和完成信号，
## 不绑定任何具体游戏流程。
class_name GFTurnPhase
extends Resource


# --- 信号 ---

## 阶段完成时发出。
signal finished


# --- 导出变量 ---

## 阶段标识。
@export var phase_id: StringName = &""

## `execute()` 返回后是否自动完成阶段。
@export var auto_finish: bool = true


# --- 公共变量 ---

## 当前阶段是否已经完成。
var is_finished: bool = false


# --- 公共方法 ---

## 进入阶段。
## @param _context: 回合上下文。
func enter(_context: GFTurnContext) -> void:
	pass


## 执行阶段逻辑。
## @param _context: 回合上下文。
## @return 可返回 null 或 Signal。
func execute(_context: GFTurnContext) -> Variant:
	return null


## 退出阶段。
## @param _context: 回合上下文。
func exit(_context: GFTurnContext) -> void:
	pass


## 标记阶段完成。
func finish() -> void:
	if is_finished:
		return
	is_finished = true
	finished.emit()


## 重置阶段运行状态。
func reset() -> void:
	is_finished = false

