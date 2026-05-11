## GFNodeStateMachineConfig: 节点状态机可复用配置资源。
##
## 适合把初始状态、历史容量和栈深度等通用运行策略做成资源复用。
class_name GFNodeStateMachineConfig
extends Resource


# --- 导出变量 ---

## 内部状态组初始状态名。
@export var initial_state: StringName = &""

## 内部状态组初始状态参数。
@export var initial_args: Dictionary = {}

## 每个状态组保留的历史状态名数量。
@export_range(1, 256, 1) var history_max_size: int = 32:
	set(value):
		history_max_size = maxi(value, 1)

## push_state 可叠加的最大栈深度。
@export_range(1, 64, 1) var max_stack_depth: int = 8:
	set(value):
		max_stack_depth = maxi(value, 1)
