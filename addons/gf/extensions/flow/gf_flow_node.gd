## GFFlowNode: 通用流程图节点基类。
##
## 节点只描述执行入口和默认后继节点。具体条件、命令、等待逻辑由项目继承实现。
class_name GFFlowNode
extends Resource


# --- 导出变量 ---

## 节点稳定标识。
@export var node_id: StringName = &""

## 默认后继节点列表。
@export var next_node_ids: PackedStringArray = PackedStringArray()

## 返回 Signal 时是否等待。
@export var wait_for_result: bool = true


# --- 公共方法 ---

## 执行节点。
## @param _context: 流程上下文。
## @return 可返回 null 或 Signal。
func execute(_context: GFFlowContext) -> Variant:
	return null


## 获取执行完成后的后继节点。
## @param context: 流程上下文。
## @return 后继节点标识列表。
func get_next_nodes(context: GFFlowContext) -> PackedStringArray:
	if context != null and not context.next_node_ids.is_empty():
		return context.next_node_ids.duplicate()
	return next_node_ids.duplicate()
