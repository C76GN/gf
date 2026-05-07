## GFBehaviorTree: 轻量级、纯代码的行为树极简实现。
##
## 提供无需编辑器的、以代码方式构建 AI 逻辑的轻量级方案。
## 可以在任何 System 中通过 Runner 来驱动 tick()。核心节点包含
## Sequence、Selector、Action、Condition 等。
class_name GFBehaviorTree


# --- 枚举 ---

## 行为树节点的执行状态
enum Status {
	SUCCESS = 0,
	FAILURE = 1,
	RUNNING = 2
}


# --- 内部类 ---

## 行为树所有节点的基类。
class BTNode extends RefCounted:
	## 节点名称，用于调试。
	var name: String = "BTNode"
	
	## 执行该节点的逻辑。子类应重写此方法。
	## @param _blackboard: 运行时共享的数据字典。
	## @return 返回 Status 枚举。
	func tick(_blackboard: Dictionary) -> int:
		return Status.SUCCESS


## 顺序节点 (AND 逻辑)。
## 依次执行子节点，只有全部成功才返回 SUCCESS。遇到 RUNNING 或 FAILURE 则中断并返回对应状态。
class Sequence extends BTNode:
	var _children: Array[BTNode]
	var _current_child_idx: int = 0
	
	func _init(children_nodes: Array[BTNode]) -> void:
		name = "Sequence"
		_children = children_nodes
		
## 推进运行时逻辑。
## @param blackboard: 行为树本次 tick 使用的黑板数据。
	func tick(blackboard: Dictionary) -> int:
		while _current_child_idx < _children.size():
			var status: int = _children[_current_child_idx].tick(blackboard)
			if status != Status.SUCCESS:
				if status == Status.FAILURE:
					_current_child_idx = 0
				return status
			_current_child_idx += 1
		_current_child_idx = 0
		return Status.SUCCESS


## 选择节点 (OR 逻辑)。
## 依次执行子节点，直到有一个子节点返回 SUCCESS 或 RUNNING，否则返回 FAILURE。
class Selector extends BTNode:
	var _children: Array[BTNode]
	var _current_child_idx: int = 0
	
	func _init(children_nodes: Array[BTNode]) -> void:
		name = "Selector"
		_children = children_nodes
		
## 推进运行时逻辑。
## @param blackboard: 行为树本次 tick 使用的黑板数据。
	func tick(blackboard: Dictionary) -> int:
		while _current_child_idx < _children.size():
			var status: int = _children[_current_child_idx].tick(blackboard)
			if status != Status.FAILURE:
				if status == Status.SUCCESS:
					_current_child_idx = 0
				return status
			_current_child_idx += 1
		_current_child_idx = 0
		return Status.FAILURE


## 动作节点 (叶子节点)。
## 包装一个回调函数执行具体指令。回调需返回 Status 类型。
class Action extends BTNode:
	var _action_func: Callable
	
	func _init(action_func: Callable) -> void:
		name = "Action"
		_action_func = action_func
		
## 推进运行时逻辑。
## @param blackboard: 行为树本次 tick 使用的黑板数据。
	func tick(blackboard: Dictionary) -> int:
		if _action_func.is_valid():
			return _action_func.call(blackboard) as int
		return Status.FAILURE


## 条件检查节点 (叶子节点)。
## 包装一个返回布尔值的回调。true 为 SUCCESS，false 为 FAILURE。
class Condition extends BTNode:
	var _condition_func: Callable
	
	func _init(condition_func: Callable) -> void:
		name = "Condition"
		_condition_func = condition_func
		
## 推进运行时逻辑。
## @param blackboard: 行为树本次 tick 使用的黑板数据。
	func tick(blackboard: Dictionary) -> int:
		if _condition_func.is_valid():
			if _condition_func.call(blackboard) == true:
				return Status.SUCCESS
		return Status.FAILURE


## 反转装饰节点。
## 翻转子节点的成功与失败状态。RUNNING 状态保持不变。
class Inverter extends BTNode:
	var _child: BTNode
	
	func _init(child_node: BTNode) -> void:
		name = "Inverter"
		_child = child_node
		
## 推进运行时逻辑。
## @param blackboard: 行为树本次 tick 使用的黑板数据。
	func tick(blackboard: Dictionary) -> int:
		if _child == null:
			return Status.FAILURE
		var status: int = _child.tick(blackboard)
		if status == Status.SUCCESS:
			return Status.FAILURE
		if status == Status.FAILURE:
			return Status.SUCCESS
		return status


## 行为树的执行入口容器。
class Runner extends RefCounted:
	var blackboard: Dictionary = {}
	var _root_node: BTNode
	
	## 初始化 Runner。
	## @param root: 行为树的根节点。
	func _init(root: BTNode) -> void:
		_root_node = root
		
	## 驱动行为树运行逻辑。
	## 通常在 GFSystem 的 tick 中被调用。
	func tick() -> int:
		if _root_node == null:
			return Status.FAILURE
		return _root_node.tick(blackboard)
