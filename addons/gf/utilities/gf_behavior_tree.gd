## GFBehaviorTree: 轻量级、纯代码的行为树实现。
##
## 提供无需编辑器的、以代码方式构建 AI 或通用决策逻辑的轻量方案。
## 可以在任何 System 中通过 Runner 来驱动 tick()。核心节点包含
## Sequence、Selector、Parallel、Action、Condition 以及常用装饰节点。
class_name GFBehaviorTree


# --- 枚举 ---

## 行为树节点的执行状态。
enum Status {
	## 节点本次执行成功。
	SUCCESS = 0,
	## 节点本次执行失败。
	FAILURE = 1,
	## 节点仍在运行，需要后续 tick 继续推进。
	RUNNING = 2,
}

## Parallel 节点的完成策略。
enum ParallelPolicy {
	## 所有子节点成功才成功，任意子节点失败即失败。
	REQUIRE_ALL,
	## 任意子节点成功即成功，所有子节点失败才失败。
	REQUIRE_ONE,
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


	## 重置节点内部运行状态。
	func reset() -> void:
		pass


## 顺序节点 (AND 逻辑)。
##
## 依次执行子节点，只有全部成功才返回 SUCCESS。遇到 RUNNING 或 FAILURE 则中断并返回对应状态。
class Sequence extends BTNode:
	var _children: Array[BTNode]
	var _current_child_idx: int = 0

	func _init(children_nodes: Array[BTNode]) -> void:
		name = "Sequence"
		_children = children_nodes


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		while _current_child_idx < _children.size():
			var child := _children[_current_child_idx]
			if child == null:
				_current_child_idx += 1
				continue

			var status: int = child.tick(blackboard)
			if status != Status.SUCCESS:
				if status == Status.FAILURE:
					reset()
				return status
			_current_child_idx += 1

		reset()
		return Status.SUCCESS


	## 重置当前子节点索引与所有子节点状态。
	func reset() -> void:
		_current_child_idx = 0
		for child: BTNode in _children:
			if child != null:
				child.reset()


## 选择节点 (OR 逻辑)。
##
## 依次执行子节点，直到有一个子节点返回 SUCCESS 或 RUNNING，否则返回 FAILURE。
class Selector extends BTNode:
	var _children: Array[BTNode]
	var _current_child_idx: int = 0

	func _init(children_nodes: Array[BTNode]) -> void:
		name = "Selector"
		_children = children_nodes


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		while _current_child_idx < _children.size():
			var child := _children[_current_child_idx]
			if child == null:
				_current_child_idx += 1
				continue

			var status: int = child.tick(blackboard)
			if status != Status.FAILURE:
				if status == Status.SUCCESS:
					reset()
				return status
			_current_child_idx += 1

		reset()
		return Status.FAILURE


	## 重置当前子节点索引与所有子节点状态。
	func reset() -> void:
		_current_child_idx = 0
		for child: BTNode in _children:
			if child != null:
				child.reset()


## 并行节点。
##
## 每次 tick 推进全部子节点，并根据 ParallelPolicy 汇总状态。
class Parallel extends BTNode:
	var _children: Array[BTNode]
	var _child_statuses: Array[int] = []
	var policy: ParallelPolicy = ParallelPolicy.REQUIRE_ALL

	func _init(
		children_nodes: Array[BTNode],
		completion_policy: ParallelPolicy = ParallelPolicy.REQUIRE_ALL
	) -> void:
		name = "Parallel"
		_children = children_nodes
		policy = completion_policy


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _children.is_empty():
			return Status.SUCCESS if policy == ParallelPolicy.REQUIRE_ALL else Status.FAILURE

		_ensure_child_statuses()
		var active_count := 0
		var has_running := false
		var has_success := false
		var has_failure := false
		for index: int in range(_children.size()):
			var child := _children[index]
			if child == null:
				continue

			active_count += 1
			var status := _child_statuses[index]
			if status == Status.RUNNING:
				status = child.tick(blackboard)
				if status != Status.RUNNING:
					_child_statuses[index] = status

			has_success = has_success or status == Status.SUCCESS
			has_failure = has_failure or status == Status.FAILURE
			has_running = has_running or status == Status.RUNNING

		if active_count <= 0:
			reset()
			return Status.SUCCESS if policy == ParallelPolicy.REQUIRE_ALL else Status.FAILURE

		if policy == ParallelPolicy.REQUIRE_ONE:
			if has_success:
				reset()
				return Status.SUCCESS
			if has_running:
				return Status.RUNNING
			reset()
			return Status.FAILURE

		if has_failure:
			reset()
			return Status.FAILURE
		if has_running:
			return Status.RUNNING

		reset()
		return Status.SUCCESS


	## 重置所有子节点状态。
	func reset() -> void:
		_child_statuses.clear()
		for child: BTNode in _children:
			if child != null:
				child.reset()


	func _ensure_child_statuses() -> void:
		if _child_statuses.size() == _children.size():
			return
		_child_statuses.clear()
		for _index: int in range(_children.size()):
			_child_statuses.append(Status.RUNNING)


## 随机选择节点。
##
## 与 Selector 语义一致，但每轮从随机顺序尝试子节点。
class RandomSelector extends BTNode:
	## 可选随机源；为空时优先使用 blackboard["rng"]，否则退回全局随机。
	var rng: RandomNumberGenerator = null

	var _children: Array[BTNode]
	var _active_order: Array[BTNode] = []
	var _current_child_idx: int = 0

	func _init(children_nodes: Array[BTNode], random_source: RandomNumberGenerator = null) -> void:
		name = "RandomSelector"
		_children = children_nodes
		rng = random_source


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _active_order.is_empty():
			_active_order = _make_random_order(blackboard)

		while _current_child_idx < _active_order.size():
			var child := _active_order[_current_child_idx]
			if child == null:
				_current_child_idx += 1
				continue

			var status: int = child.tick(blackboard)
			if status != Status.FAILURE:
				if status == Status.SUCCESS:
					reset()
				return status
			_current_child_idx += 1

		reset()
		return Status.FAILURE


	## 重置当前随机轮次与子节点状态。
	func reset() -> void:
		_active_order.clear()
		_current_child_idx = 0
		for child: BTNode in _children:
			if child != null:
				child.reset()


	func _make_random_order(blackboard: Dictionary) -> Array[BTNode]:
		var result: Array[BTNode] = []
		result.append_array(_children)
		var active_rng := _resolve_rng(blackboard)
		if active_rng == null:
			result.shuffle()
		else:
			_shuffle_with_rng(result, active_rng)
		return result


	func _resolve_rng(blackboard: Dictionary) -> RandomNumberGenerator:
		if rng != null:
			return rng

		var blackboard_rng: Variant = blackboard.get("rng", null)
		return blackboard_rng if blackboard_rng is RandomNumberGenerator else null


	func _shuffle_with_rng(nodes: Array[BTNode], random_source: RandomNumberGenerator) -> void:
		for index: int in range(nodes.size() - 1, 0, -1):
			var swap_index := random_source.randi_range(0, index)
			var temp := nodes[index]
			nodes[index] = nodes[swap_index]
			nodes[swap_index] = temp


## 随机顺序节点。
##
## 与 Sequence 语义一致，但每轮从随机顺序尝试子节点。
class RandomSequence extends BTNode:
	## 可选随机源；为空时优先使用 blackboard["rng"]，否则退回全局随机。
	var rng: RandomNumberGenerator = null

	var _children: Array[BTNode]
	var _active_order: Array[BTNode] = []
	var _current_child_idx: int = 0

	func _init(children_nodes: Array[BTNode], random_source: RandomNumberGenerator = null) -> void:
		name = "RandomSequence"
		_children = children_nodes
		rng = random_source


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _active_order.is_empty():
			_active_order = _make_random_order(blackboard)

		while _current_child_idx < _active_order.size():
			var child := _active_order[_current_child_idx]
			if child == null:
				_current_child_idx += 1
				continue

			var status: int = child.tick(blackboard)
			if status != Status.SUCCESS:
				if status == Status.FAILURE:
					reset()
				return status
			_current_child_idx += 1

		reset()
		return Status.SUCCESS


	## 重置当前随机轮次与子节点状态。
	func reset() -> void:
		_active_order.clear()
		_current_child_idx = 0
		for child: BTNode in _children:
			if child != null:
				child.reset()


	func _make_random_order(blackboard: Dictionary) -> Array[BTNode]:
		var result: Array[BTNode] = []
		result.append_array(_children)
		var active_rng := _resolve_rng(blackboard)
		if active_rng == null:
			result.shuffle()
		else:
			_shuffle_with_rng(result, active_rng)
		return result


	func _resolve_rng(blackboard: Dictionary) -> RandomNumberGenerator:
		if rng != null:
			return rng

		var blackboard_rng: Variant = blackboard.get("rng", null)
		return blackboard_rng if blackboard_rng is RandomNumberGenerator else null


	func _shuffle_with_rng(nodes: Array[BTNode], random_source: RandomNumberGenerator) -> void:
		for index: int in range(nodes.size() - 1, 0, -1):
			var swap_index := random_source.randi_range(0, index)
			var temp := nodes[index]
			nodes[index] = nodes[swap_index]
			nodes[swap_index] = temp


## 动作节点 (叶子节点)。
##
## 包装一个回调函数执行具体指令。回调需返回 Status 类型。
class Action extends BTNode:
	var _action_func: Callable

	func _init(action_func: Callable) -> void:
		name = "Action"
		_action_func = action_func


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _action_func.is_valid():
			return _action_func.call(blackboard) as int
		return Status.FAILURE


## 条件检查节点 (叶子节点)。
##
## 包装一个返回布尔值的回调。true 为 SUCCESS，false 为 FAILURE。
class Condition extends BTNode:
	var _condition_func: Callable

	func _init(condition_func: Callable) -> void:
		name = "Condition"
		_condition_func = condition_func


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _condition_func.is_valid() and _condition_func.call(blackboard) == true:
			return Status.SUCCESS
		return Status.FAILURE


## 单子节点装饰器基类。
class Decorator extends BTNode:
	var _child: BTNode

	func _init(child_node: BTNode = null) -> void:
		_child = child_node


	## 设置被装饰的子节点。
	## @param child_node: 子节点。
	## @return 当前装饰器。
	func set_child(child_node: BTNode) -> Decorator:
		_child = child_node
		return self


	## 重置子节点状态。
	func reset() -> void:
		if _child != null:
			_child.reset()


## 反转装饰节点。
##
## 翻转子节点的成功与失败状态。RUNNING 状态保持不变。
class Inverter extends Decorator:
	func _init(child_node: BTNode) -> void:
		super(child_node)
		name = "Inverter"


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _child == null:
			return Status.FAILURE
		var status: int = _child.tick(blackboard)
		if status == Status.SUCCESS:
			_child.reset()
			return Status.FAILURE
		if status == Status.FAILURE:
			_child.reset()
			return Status.SUCCESS
		return status


## 总是成功装饰节点。
##
## 子节点运行中时保持 RUNNING，子节点结束时统一返回 SUCCESS。
class AlwaysSucceed extends Decorator:
	func _init(child_node: BTNode) -> void:
		super(child_node)
		name = "AlwaysSucceed"


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _child == null:
			return Status.SUCCESS
		var status: int = _child.tick(blackboard)
		if status == Status.RUNNING:
			return Status.RUNNING
		_child.reset()
		return Status.SUCCESS


## 总是失败装饰节点。
##
## 子节点运行中时保持 RUNNING，子节点结束时统一返回 FAILURE。
class AlwaysFail extends Decorator:
	func _init(child_node: BTNode) -> void:
		super(child_node)
		name = "AlwaysFail"


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _child == null:
			return Status.FAILURE
		var status: int = _child.tick(blackboard)
		if status == Status.RUNNING:
			return Status.RUNNING
		_child.reset()
		return Status.FAILURE


## 次数限制装饰节点。
##
## 子节点最多被 tick 指定次数；超过次数后返回 FAILURE。
class Limit extends Decorator:
	var max_ticks: int = 1
	var _tick_count: int = 0

	func _init(child_node: BTNode, tick_limit: int = 1) -> void:
		super(child_node)
		name = "Limit"
		max_ticks = maxi(tick_limit, 0)


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _child == null or max_ticks <= 0:
			return Status.FAILURE
		if _tick_count >= max_ticks:
			return Status.FAILURE

		_tick_count += 1
		return _child.tick(blackboard)


	## 重置调用计数与子节点状态。
	func reset() -> void:
		_tick_count = 0
		super.reset()


## 重复装饰节点。
##
## 子节点成功后重复执行，达到 repeat_count 后返回 SUCCESS；repeat_count 为 0 表示无限重复。
class Repeat extends Decorator:
	var repeat_count: int = 1
	var _success_count: int = 0

	func _init(child_node: BTNode, count: int = 1) -> void:
		super(child_node)
		name = "Repeat"
		repeat_count = maxi(count, 0)


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _child == null:
			return Status.FAILURE

		var status: int = _child.tick(blackboard)
		if status == Status.RUNNING:
			return Status.RUNNING
		if status == Status.FAILURE:
			reset()
			return Status.FAILURE

		_success_count += 1
		_child.reset()
		if repeat_count > 0 and _success_count >= repeat_count:
			reset()
			return Status.SUCCESS
		return Status.RUNNING


	## 重置重复计数与子节点状态。
	func reset() -> void:
		_success_count = 0
		super.reset()


## 直到成功装饰节点。
##
## 子节点失败时继续返回 RUNNING，直到子节点成功。
class UntilSuccess extends Decorator:
	func _init(child_node: BTNode) -> void:
		super(child_node)
		name = "UntilSuccess"


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _child == null:
			return Status.FAILURE
		var status: int = _child.tick(blackboard)
		if status == Status.SUCCESS:
			reset()
			return Status.SUCCESS
		return Status.RUNNING


## 直到失败装饰节点。
##
## 子节点成功时继续返回 RUNNING，直到子节点失败。
class UntilFail extends Decorator:
	func _init(child_node: BTNode) -> void:
		super(child_node)
		name = "UntilFail"


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _child == null:
			return Status.FAILURE
		var status: int = _child.tick(blackboard)
		if status == Status.FAILURE:
			reset()
			return Status.SUCCESS
		return Status.RUNNING


## 行为树的执行入口容器。
class Runner extends RefCounted:
	## 运行时共享黑板。
	var blackboard: Dictionary = {}

	var _root_node: BTNode

	func _init(root: BTNode) -> void:
		_root_node = root


	## 驱动行为树运行逻辑。
	## 通常在 GFSystem 的 tick 中被调用。
	## @return 返回根节点 Status 枚举。
	func tick() -> int:
		if _root_node == null:
			return Status.FAILURE
		return _root_node.tick(blackboard)


	## 重置整棵行为树的运行状态。
	func reset() -> void:
		if _root_node != null:
			_root_node.reset()
