## GFBehaviorTree: 轻量级、纯代码的行为树实现。
##
## 提供无需编辑器的、以代码方式构建 AI 或通用决策逻辑的轻量方案。
## 可以在任何 System 中通过 Runner 来驱动 tick()。核心节点包含
## Sequence、Selector、Parallel、Action、Condition 以及常用装饰节点。
class_name GFBehaviorTree


# --- 枚举 ---

## 行为树节点的执行状态。
enum Status {
	## 节点尚未被 tick。
	FRESH = -1,
	## 节点本次执行成功。
	SUCCESS = 0,
	## 节点本次执行失败。
	FAILURE = 1,
	## 节点仍在运行，需要后续 tick 继续推进。
	RUNNING = 2,
	## 节点被外部中止。
	ABORTED = 3,
}

## Parallel 节点的完成策略。
enum ParallelPolicy {
	## 所有子节点成功才成功，任意子节点失败即失败。
	REQUIRE_ALL,
	## 任意子节点成功即成功，所有子节点失败才失败。
	REQUIRE_ONE,
}


# --- 公共方法 ---

## 将状态枚举转换为稳定文本。
## @param status: 行为树状态。
## @return 状态文本。
static func status_to_string(status: int) -> StringName:
	match status:
		Status.FRESH:
			return &"fresh"
		Status.SUCCESS:
			return &"success"
		Status.FAILURE:
			return &"failure"
		Status.RUNNING:
			return &"running"
		Status.ABORTED:
			return &"aborted"
		_:
			return &"unknown"


## 获取节点调试快照。
## @param node: 行为树节点。
## @return 调试快照字典。
static func build_debug_snapshot(node: Variant) -> Dictionary:
	return node.get_debug_snapshot() if node != null else {}


# --- 内部类 ---

## 行为树所有节点的基类。
class BTNode extends RefCounted:
	## 节点名称，用于调试。
	var name: String = "BTNode"
	## 可选稳定节点标识。
	var node_id: StringName = &""
	## 最近一次 tick 状态。
	var last_status: int = Status.FRESH
	## 最近一次状态原因。
	var last_reason: StringName = &""
	## 累计 tick 次数。
	var tick_count: int = 0
	## 最近一次 tick 耗时，单位微秒。
	var last_tick_usec: int = 0
	## 调用方附加元数据。
	var metadata: Dictionary = {}

	## 执行该节点的逻辑。子类应重写此方法。
	## @param _blackboard: 运行时共享的数据字典。
	## @return 返回 Status 枚举。
	func tick(_blackboard: Dictionary) -> int:
		return _record_tick(Status.SUCCESS)


	## 重置节点内部运行状态。
	func reset() -> void:
		last_status = Status.FRESH
		last_reason = &""
		last_tick_usec = 0


	## 记录节点状态。
	## @param status: 新状态。
	## @param reason: 可选状态原因。
	## @param elapsed_usec: 可选耗时。
	## @return 原状态值，便于子类直接 return。
	func record_status(status: int, reason: StringName = &"", elapsed_usec: int = 0) -> int:
		last_status = status
		last_reason = reason
		last_tick_usec = maxi(elapsed_usec, 0)
		tick_count += 1
		return status


	## 获取调试快照。
	## @return 调试快照字典。
	func get_debug_snapshot() -> Dictionary:
		var children: Array[Dictionary] = []
		for child: BTNode in _get_debug_children():
			if child != null:
				children.append(child.get_debug_snapshot())
		return {
			"node_id": node_id,
			"name": name,
			"status": last_status,
			"status_text": GFBehaviorTree.status_to_string(last_status),
			"reason": last_reason,
			"tick_count": tick_count,
			"last_tick_usec": last_tick_usec,
			"child_count": children.size(),
			"children": children,
			"metadata": metadata.duplicate(true),
		}


	func _record_tick(status: int, reason: StringName = &"", started_usec: int = 0) -> int:
		var elapsed := Time.get_ticks_usec() - started_usec if started_usec > 0 else 0
		return record_status(status, reason, elapsed)


	func _get_debug_children() -> Array[BTNode]:
		return []


## 行为树黑板作用域。
##
## 支持父级回退和局部覆盖，可在项目层按需转换为 Dictionary 传给既有节点。
class BlackboardScope extends RefCounted:
	## 当前作用域值。
	var values: Dictionary = {}
	## 可选父级作用域。
	var parent: BlackboardScope = null

	func _init(initial_values: Dictionary = {}, parent_scope: BlackboardScope = null) -> void:
		values = initial_values.duplicate(true)
		parent = parent_scope


	## 设置作用域值。
	## @param key: 值标识。
	## @param value: 值。
	func set_value(key: StringName, value: Variant) -> void:
		values[key] = value


	## 获取作用域值。
	## @param key: 值标识。
	## @param default_value: 缺失时返回的默认值。
	## @return 作用域值。
	func get_value(key: StringName, default_value: Variant = null) -> Variant:
		if values.has(key):
			return values[key]
		if parent != null:
			return parent.get_value(key, default_value)
		return default_value


	## 检查作用域值是否存在。
	## @param key: 值标识。
	## @return 存在返回 true。
	func has_value(key: StringName) -> bool:
		return values.has(key) or (parent != null and parent.has_value(key))


	## 转换为合并后的字典。
	## @return 黑板字典。
	func to_dictionary() -> Dictionary:
		var result := parent.to_dictionary() if parent != null else {}
		for key: Variant in values.keys():
			result[key] = values[key]
		return result


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
		super.reset()


	func _get_debug_children() -> Array[BTNode]:
		return _children


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
		super.reset()


	func _get_debug_children() -> Array[BTNode]:
		return _children


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
		super.reset()


	func _ensure_child_statuses() -> void:
		if _child_statuses.size() == _children.size():
			return
		_child_statuses.clear()
		for _index: int in range(_children.size()):
			_child_statuses.append(Status.RUNNING)


	func _get_debug_children() -> Array[BTNode]:
		return _children


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
		super.reset()


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


	func _get_debug_children() -> Array[BTNode]:
		return _children


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
		super.reset()


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


	func _get_debug_children() -> Array[BTNode]:
		return _children


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
		var started := Time.get_ticks_usec()
		if _action_func.is_valid():
			return _record_tick(_action_func.call(blackboard) as int, &"", started)
		return _record_tick(Status.FAILURE, &"invalid_action", started)


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
		var started := Time.get_ticks_usec()
		if _condition_func.is_valid() and _condition_func.call(blackboard) == true:
			return _record_tick(Status.SUCCESS, &"", started)
		return _record_tick(Status.FAILURE, &"condition_false", started)


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
		super.reset()


	func _get_debug_children() -> Array[BTNode]:
		var result: Array[BTNode] = []
		if _child != null:
			result.append(_child)
		return result


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


## 概率装饰节点。
##
## 每轮按 probability 判定是否允许子节点执行，未命中时返回 FAILURE。
class Probability extends Decorator:
	## 执行概率，范围 0.0 到 1.0。
	var probability: float = 1.0
	## 可选随机源；为空时优先使用 blackboard["rng"]。
	var rng: RandomNumberGenerator = null

	func _init(child_node: BTNode, chance: float = 1.0, random_source: RandomNumberGenerator = null) -> void:
		super(child_node)
		name = "Probability"
		probability = clampf(chance, 0.0, 1.0)
		rng = random_source


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _child == null:
			return Status.FAILURE
		var active_rng := _resolve_rng(blackboard)
		var roll := active_rng.randf() if active_rng != null else randf()
		if roll > probability:
			return Status.FAILURE
		return _child.tick(blackboard)


	func _resolve_rng(blackboard: Dictionary) -> RandomNumberGenerator:
		if rng != null:
			return rng
		var blackboard_rng: Variant = blackboard.get("rng", null)
		return blackboard_rng if blackboard_rng is RandomNumberGenerator else null


## 冷却装饰节点。
##
## 子节点结束后进入冷却期，冷却未结束时返回 FAILURE。
class Cooldown extends Decorator:
	## 冷却秒数。
	var cooldown_seconds: float = 0.0
	var _last_finish_msec: int = -1

	func _init(child_node: BTNode, seconds: float = 0.0) -> void:
		super(child_node)
		name = "Cooldown"
		cooldown_seconds = maxf(seconds, 0.0)


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _child == null:
			return Status.FAILURE
		var now := _resolve_time_msec(blackboard)
		if _last_finish_msec >= 0 and now - _last_finish_msec < roundi(cooldown_seconds * 1000.0):
			return Status.FAILURE
		var status := _child.tick(blackboard)
		if status != Status.RUNNING:
			_last_finish_msec = now
		return status


	## 重置冷却状态。
	func reset() -> void:
		_last_finish_msec = -1
		super.reset()


	func _resolve_time_msec(blackboard: Dictionary) -> int:
		return int(blackboard.get("time_msec", Time.get_ticks_msec()))


## 时间限制装饰节点。
##
## 子节点 RUNNING 持续超过限制时返回 FAILURE 并重置子节点。
class TimeLimit extends Decorator:
	## 最大运行秒数。
	var limit_seconds: float = 1.0
	var _started_msec: int = -1

	func _init(child_node: BTNode, seconds: float = 1.0) -> void:
		super(child_node)
		name = "TimeLimit"
		limit_seconds = maxf(seconds, 0.0)


	## 推进运行时逻辑。
	## @param blackboard: 行为树本次 tick 使用的黑板数据。
	## @return 返回 Status 枚举。
	func tick(blackboard: Dictionary) -> int:
		if _child == null:
			return Status.FAILURE
		var now := int(blackboard.get("time_msec", Time.get_ticks_msec()))
		if _started_msec < 0:
			_started_msec = now
		if now - _started_msec > roundi(limit_seconds * 1000.0):
			reset()
			return Status.FAILURE
		var status := _child.tick(blackboard)
		if status != Status.RUNNING:
			reset()
		return status


	## 重置计时状态。
	func reset() -> void:
		_started_msec = -1
		super.reset()


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
		var started := Time.get_ticks_usec()
		var status := _root_node.tick(blackboard)
		_root_node.record_status(status, &"", Time.get_ticks_usec() - started)
		return status


	## 重置整棵行为树的运行状态。
	func reset() -> void:
		if _root_node != null:
			_root_node.reset()


	## 获取运行器调试快照。
	## @return 调试快照字典。
	func get_debug_snapshot() -> Dictionary:
		return {
			"root": _root_node.get_debug_snapshot() if _root_node != null else {},
			"blackboard_keys": _get_blackboard_keys(),
		}


	func _get_blackboard_keys() -> PackedStringArray:
		var result := PackedStringArray()
		for key: Variant in blackboard.keys():
			result.append(String(key))
		result.sort()
		return result
