## GFQuestUtility: 轻量级任务进度监听系统。
##
## 基于 `simple event` 将业务事件映射为任务进度累积，
## 适合用于成就、收集与击杀类目标的低成本跟踪。
class_name GFQuestUtility
extends GFUtility


# --- 信号 ---

## 当任务开始监听时发出。
## @param quest_id: 任务 ID。
signal quest_started(quest_id: StringName)

## 当任务进入可接取状态时发出。
## @param quest_id: 任务 ID。
signal quest_available(quest_id: StringName)

## 当任务接取条件拒绝时发出。
## @param quest_id: 任务 ID。
## @param reason: 拒绝原因。
signal quest_acceptance_blocked(quest_id: StringName, reason: String)

## 当任务进度变化时发出。
## @param quest_id: 任务 ID。
## @param current: 当前进度。
## @param target: 目标进度。
signal quest_progressed(quest_id: StringName, current: int, target: int)

## 当任务完成时发出。
## @param quest_id: 完成的任务 ID。
signal quest_completed(quest_id: StringName)

## 当任务完成条件被阻塞器拒绝时发出。
## @param quest_id: 任务 ID。
## @param reason: 阻塞原因。
signal quest_completion_blocked(quest_id: StringName, reason: String)

## 当任务取消时发出。
## @param quest_id: 任务 ID。
signal quest_cancelled(quest_id: StringName)

## 当任务失败时发出。
## @param quest_id: 任务 ID。
signal quest_failed(quest_id: StringName)


# --- 常量 ---

const STATUS_AVAILABLE: StringName = &"available"
const STATUS_ACTIVE: StringName = &"active"
const STATUS_COMPLETED: StringName = &"completed"
const STATUS_CANCELLED: StringName = &"cancelled"
const STATUS_FAILED: StringName = &"failed"


# --- 公共变量 ---

## 是否允许事件传入负数进度。默认关闭，避免任务进度被异常 payload 反向扣减。
var allow_negative_progress: bool = false


# --- 私有变量 ---

## 任务表：`quest_id -> QuestData`。
var _quests: Dictionary = {}

## 事件到任务列表的映射：`event_id -> Array[StringName]`。
var _event_to_quests: Dictionary = {}

## 已注册的事件处理器：`event_id -> Callable`。
var _event_handlers: Dictionary = {}


# --- Godot 生命周期方法 ---

func init() -> void:
	_unregister_all_event_handlers()
	_quests.clear()
	_event_to_quests.clear()


func dispose() -> void:
	_unregister_all_event_handlers()
	_quests.clear()
	_event_to_quests.clear()


# --- 公共方法 ---

## 开始监听一个任务。
## @param quest_id: 任务 ID。
## @param target_event: 推进该任务的事件 ID。
## @param target_count: 完成任务所需的累计次数。
func start_quest(quest_id: StringName, target_event: StringName, target_count: int = 1) -> void:
	if quest_id == &"" or target_event == &"":
		push_error("[GFQuestUtility] quest_id 和 target_event 不能为空。")
		return

	if _quests.has(quest_id):
		push_warning("[GFQuestUtility] 任务已存在：%s" % quest_id)
		return

	var data := _create_quest_data(quest_id, target_event, target_count, {})
	data.status = STATUS_ACTIVE
	_quests[quest_id] = data

	quest_started.emit(quest_id)

	if target_count <= 0:
		quest_progressed.emit(quest_id, data.current_count, data.target_count)
		_try_complete_quest(data)
		return

	_attach_quest_to_event(data)


## 定义一个可接取任务，但暂不开始监听事件。
## @param quest_id: 任务 ID。
## @param target_event: 推进该任务的事件 ID。
## @param target_count: 完成任务所需的累计次数。
## @param metadata: 任务元数据。框架不解释该字段。
func define_quest(
	quest_id: StringName,
	target_event: StringName,
	target_count: int = 1,
	metadata: Dictionary = {}
) -> void:
	if quest_id == &"":
		push_error("[GFQuestUtility] quest_id 不能为空。")
		return
	if _quests.has(quest_id):
		push_warning("[GFQuestUtility] 任务已存在：%s" % quest_id)
		return

	var data := _create_quest_data(quest_id, target_event, target_count, metadata)
	data.status = STATUS_AVAILABLE
	_quests[quest_id] = data
	quest_available.emit(quest_id)


## 接取一个已定义任务，并开始监听事件。
## @param quest_id: 任务 ID。
## @return 接取成功返回 true。
func accept_quest(quest_id: StringName) -> bool:
	var data := _quests.get(quest_id) as QuestData
	if data == null or data.status == STATUS_COMPLETED or data.status == STATUS_CANCELLED or data.status == STATUS_FAILED:
		return false
	if data.status == STATUS_ACTIVE:
		return true
	if data.event_id == &"":
		push_error("[GFQuestUtility] accept_quest 失败：target_event 为空。")
		return false
	var acceptance_result := _check_conditions(data.acceptance_conditions, data)
	if not bool(acceptance_result.get("ok", true)):
		quest_acceptance_blocked.emit(quest_id, String(acceptance_result.get("reason", "blocked")))
		return false

	data.status = STATUS_ACTIVE
	quest_started.emit(quest_id)
	if data.target_count <= 0:
		quest_progressed.emit(quest_id, data.current_count, data.target_count)
		_try_complete_quest(data)
	else:
		_attach_quest_to_event(data)
	return true


## 手动完成一个任务。
## @param quest_id: 任务 ID。
## @return 完成成功返回 true。
func complete_quest(quest_id: StringName) -> bool:
	var data := _quests.get(quest_id) as QuestData
	if data == null:
		return false
	return _try_complete_quest(data)


## 取消一个任务。
## @param quest_id: 任务 ID。
## @return 取消成功返回 true。
func cancel_quest(quest_id: StringName) -> bool:
	var data := _quests.get(quest_id) as QuestData
	if data == null or data.status == STATUS_COMPLETED or data.status == STATUS_CANCELLED or data.status == STATUS_FAILED:
		return false
	_detach_quest_from_event(data)
	data.status = STATUS_CANCELLED
	quest_cancelled.emit(quest_id)
	return true


## 标记任务失败。
## @param quest_id: 任务 ID。
## @param reason: 可选失败原因，会写入任务 metadata 的 last_failure_reason。
## @return 标记成功返回 true。
func fail_quest(quest_id: StringName, reason: String = "") -> bool:
	var data := _quests.get(quest_id) as QuestData
	if data == null or data.status == STATUS_COMPLETED or data.status == STATUS_CANCELLED or data.status == STATUS_FAILED:
		return false

	_detach_quest_from_event(data)
	data.status = STATUS_FAILED
	if not reason.is_empty():
		data.metadata["last_failure_reason"] = reason
	quest_failed.emit(quest_id)
	return true


## 添加接取条件。条件返回 false 或包含 ok=false 的 Dictionary 时阻止接取。
## @param quest_id: 任务 ID。
## @param condition: 条件回调。
func add_acceptance_condition(quest_id: StringName, condition: Callable) -> void:
	if not condition.is_valid():
		return
	var data := _quests.get(quest_id) as QuestData
	if data == null:
		return
	data.acceptance_conditions.append(condition)


## 清空任务接取条件。
## @param quest_id: 任务 ID。
func clear_acceptance_conditions(quest_id: StringName) -> void:
	var data := _quests.get(quest_id) as QuestData
	if data != null:
		data.acceptance_conditions.clear()


## 添加完成阻塞器。阻塞器返回 false 或包含 ok=false 的 Dictionary 时阻止完成。
## @param quest_id: 任务 ID。
## @param blocker: 阻塞器回调。
func add_completion_blocker(quest_id: StringName, blocker: Callable) -> void:
	if not blocker.is_valid():
		return
	var data := _quests.get(quest_id) as QuestData
	if data == null:
		return
	data.completion_blockers.append(blocker)


## 清空任务完成阻塞器。
## @param quest_id: 任务 ID。
func clear_completion_blockers(quest_id: StringName) -> void:
	var data := _quests.get(quest_id) as QuestData
	if data != null:
		data.completion_blockers.clear()


## 设置任务父级关系。
## @param quest_id: 子任务 ID。
## @param parent_quest_id: 父任务 ID。
## @return 设置成功返回 true。
func set_quest_parent(quest_id: StringName, parent_quest_id: StringName) -> bool:
	if quest_id == &"" or parent_quest_id == &"" or quest_id == parent_quest_id:
		return false
	var data := _quests.get(quest_id) as QuestData
	var parent := _quests.get(parent_quest_id) as QuestData
	if data == null or parent == null:
		return false
	if _is_descendant_quest(quest_id, parent_quest_id):
		return false

	_detach_quest_parent(data)
	data.parent_id = parent_quest_id
	if not parent.child_ids.has(String(quest_id)):
		parent.child_ids.append(String(quest_id))
	parent.child_ids.sort()
	return true


## 清除任务父级关系。
## @param quest_id: 任务 ID。
func clear_quest_parent(quest_id: StringName) -> void:
	var data := _quests.get(quest_id) as QuestData
	if data != null:
		_detach_quest_parent(data)


## 获取任务的直接子任务 ID。
## @param quest_id: 任务 ID。
## @return 子任务 ID 列表。
func get_child_quests(quest_id: StringName) -> PackedStringArray:
	var data := _quests.get(quest_id) as QuestData
	return data.child_ids.duplicate() if data != null else PackedStringArray()


## 获取任务树报告。
## @param root_quest_id: 根任务 ID。
## @return 树形报告；任务不存在时返回空字典。
func get_quest_tree_report(root_quest_id: StringName) -> Dictionary:
	var root_data := _quests.get(root_quest_id) as QuestData
	if root_data == null:
		return {}
	return _build_quest_tree_report(root_data)


## 手动触发一次任务事件。
## @param event_id: 事件 ID。
## @param amount: 本次增加的进度值。
func emit_quest_event(event_id: StringName, amount: int = 1) -> void:
	var arch := _get_arch()
	if arch != null and arch.has_method("send_simple_event"):
		arch.send_simple_event(event_id, amount)
	else:
		_on_quest_event_triggered(amount, event_id)


## 查询任务是否已经完成。
## @param quest_id: 任务 ID。
## @return 已完成时返回 `true`。
func is_quest_completed(quest_id: StringName) -> bool:
	if _quests.has(quest_id):
		var q := _quests[quest_id] as QuestData
		return q.is_completed

	return false


## 获取任务进度百分比。
## @param quest_id: 任务 ID。
## @return 范围在 `0.0` 到 `1.0` 之间的进度值。
func get_quest_progress(quest_id: StringName) -> float:
	if _quests.has(quest_id):
		var q := _quests[quest_id] as QuestData
		if q.target_count <= 0:
			return 1.0

		return clampf(float(q.current_count) / float(q.target_count), 0.0, 1.0)

	return 0.0


## 获取任务状态。
## @param quest_id: 任务 ID。
## @return 状态文本。
func get_quest_status(quest_id: StringName) -> StringName:
	var data := _quests.get(quest_id) as QuestData
	return data.status if data != null else &""


## 获取指定状态的任务 ID。
## @param status: 任务状态。
## @return 任务 ID 列表。
func get_quests_by_status(status: StringName) -> PackedStringArray:
	var result := PackedStringArray()
	for quest_id: StringName in _quests.keys():
		var data := _quests[quest_id] as QuestData
		if data != null and data.status == status:
			result.append(String(quest_id))
	result.sort()
	return result


## 获取任务报告。
## @param quest_id: 任务 ID。
## @return 任务报告字典。
func get_quest_report(quest_id: StringName) -> Dictionary:
	var data := _quests.get(quest_id) as QuestData
	if data == null:
		return {}
	return data.to_dict()


## 获取任务系统调试快照。
## @return 调试快照字典。
func get_debug_snapshot() -> Dictionary:
	var reports: Dictionary = {}
	for quest_id: StringName in _quests.keys():
		var data := _quests[quest_id] as QuestData
		if data != null:
			reports[String(quest_id)] = data.to_dict()
	return {
		"quest_count": _quests.size(),
		"event_count": _event_to_quests.size(),
		"quests": reports,
	}


# --- 私有/辅助方法 ---

func _on_quest_event_triggered(payload: Variant, event_id: StringName) -> void:
	if not _event_to_quests.has(event_id):
		return

	var amount := _payload_to_amount(payload)
	if not allow_negative_progress:
		amount = maxi(amount, 0)

	var list: Array = (_event_to_quests[event_id] as Array).duplicate()
	for quest_id: StringName in list:
		var q := _quests.get(quest_id) as QuestData
		if q == null or q.status != STATUS_ACTIVE or q.is_completed:
			continue

		q.current_count += amount
		if q.current_count >= q.target_count:
			q.current_count = q.target_count
			quest_progressed.emit(quest_id, q.current_count, q.target_count)
			_try_complete_quest(q)
		else:
			quest_progressed.emit(quest_id, q.current_count, q.target_count)


func _register_event_handler(event_id: StringName) -> void:
	var arch := _get_arch()
	if arch == null or not arch.has_method("register_simple_event"):
		return

	var event_handler: Callable = Callable(self, "_on_quest_event_triggered").bind(event_id)
	_event_handlers[event_id] = event_handler
	if arch.has_method("register_simple_event_owned"):
		arch.register_simple_event_owned(self, event_id, event_handler)
	else:
		arch.register_simple_event(event_id, event_handler)


func _unregister_event_handler(event_id: StringName) -> void:
	if not _event_handlers.has(event_id):
		return

	var arch := _get_arch()
	if arch != null and arch.has_method("unregister_simple_event"):
		var event_handler := _event_handlers[event_id] as Callable
		arch.unregister_simple_event(event_id, event_handler)
	_event_handlers.erase(event_id)


func _unregister_all_event_handlers() -> void:
	var arch := _get_arch()
	if arch != null and arch.has_method("unregister_simple_event"):
		for event_id: StringName in _event_handlers:
			var event_handler := _event_handlers[event_id] as Callable
			arch.unregister_simple_event(event_id, event_handler)

	_event_handlers.clear()


func _get_arch() -> Object:
	return _get_architecture_or_null()


func _payload_to_amount(payload: Variant) -> int:
	var current_payload := payload
	var depth: int = 0
	while current_payload is Dictionary and current_payload.has("amount"):
		depth += 1
		if depth > 16:
			push_error("[GFQuestUtility] payload.amount 嵌套过深，已回退为默认进度 1。")
			return 1
		current_payload = current_payload["amount"]

	if current_payload is int:
		return current_payload
	if current_payload is float:
		return roundi(current_payload)

	return 1


func _create_quest_data(
	quest_id: StringName,
	target_event: StringName,
	target_count: int,
	metadata: Dictionary
) -> QuestData:
	var data := QuestData.new()
	data.quest_id = quest_id
	data.event_id = target_event
	data.target_count = target_count
	data.metadata = metadata.duplicate(true)
	return data


func _attach_quest_to_event(data: QuestData) -> void:
	if data == null or data.event_id == &"":
		return
	if not _event_to_quests.has(data.event_id):
		_event_to_quests[data.event_id] = [] as Array[StringName]
		_register_event_handler(data.event_id)

	var list: Array = _event_to_quests[data.event_id]
	if not list.has(data.quest_id):
		list.append(data.quest_id)


func _detach_quest_from_event(data: QuestData) -> void:
	if data == null or data.event_id == &"" or not _event_to_quests.has(data.event_id):
		return
	var list: Array = _event_to_quests[data.event_id]
	list.erase(data.quest_id)
	if list.is_empty():
		_event_to_quests.erase(data.event_id)
		_unregister_event_handler(data.event_id)


func _try_complete_quest(data: QuestData) -> bool:
	if data == null or data.is_completed or data.status == STATUS_CANCELLED or data.status == STATUS_FAILED:
		return false

	var blocker_result := _check_conditions(data.completion_blockers, data)
	if not bool(blocker_result.get("ok", true)):
		quest_completion_blocked.emit(data.quest_id, String(blocker_result.get("reason", "blocked")))
		return false

	_detach_quest_from_event(data)
	data.is_completed = true
	data.status = STATUS_COMPLETED
	quest_completed.emit(data.quest_id)
	return true


func _check_conditions(conditions: Array[Callable], data: QuestData) -> Dictionary:
	for condition: Callable in conditions:
		if not condition.is_valid():
			continue
		var result: Variant = condition.call(data.quest_id, data.to_dict())
		if result is Dictionary:
			if not bool((result as Dictionary).get("ok", false)):
				return {
					"ok": false,
					"reason": String((result as Dictionary).get("reason", "blocked")),
				}
		elif result == false:
			return {
				"ok": false,
				"reason": "blocked",
			}
	return {
		"ok": true,
		"reason": "",
	}


func _detach_quest_parent(data: QuestData) -> void:
	if data == null or data.parent_id == &"":
		return
	var parent := _quests.get(data.parent_id) as QuestData
	if parent != null:
		var index := parent.child_ids.find(String(data.quest_id))
		if index >= 0:
			parent.child_ids.remove_at(index)
	data.parent_id = &""


func _is_descendant_quest(root_quest_id: StringName, expected_descendant_id: StringName) -> bool:
	var root := _quests.get(root_quest_id) as QuestData
	if root == null:
		return false
	for child_id_text: String in root.child_ids:
		var child_id := StringName(child_id_text)
		if child_id == expected_descendant_id or _is_descendant_quest(child_id, expected_descendant_id):
			return true
	return false


func _build_quest_tree_report(data: QuestData) -> Dictionary:
	var children: Array[Dictionary] = []
	var total_count := 1
	var completed_count := 1 if data.status == STATUS_COMPLETED else 0
	for child_id_text: String in data.child_ids:
		var child := _quests.get(StringName(child_id_text)) as QuestData
		if child == null:
			continue
		var child_report := _build_quest_tree_report(child)
		children.append(child_report)
		total_count += int(child_report.get("total_count", 0))
		completed_count += int(child_report.get("completed_count", 0))

	var report := data.to_dict()
	report["children"] = children
	report["total_count"] = total_count
	report["completed_count"] = completed_count
	report["aggregate_progress"] = float(completed_count) / float(total_count) if total_count > 0 else 0.0
	return report


# --- 内部类 ---

class QuestData extends RefCounted:
	var quest_id: StringName
	var event_id: StringName
	var target_count: int = 1
	var current_count: int = 0
	var is_completed: bool = false
	var status: StringName = &"available"
	var parent_id: StringName = &""
	var child_ids: PackedStringArray = PackedStringArray()
	var metadata: Dictionary = {}
	var acceptance_conditions: Array[Callable] = []
	var completion_blockers: Array[Callable] = []

	func to_dict() -> Dictionary:
		return {
			"quest_id": String(quest_id),
			"event_id": String(event_id),
			"target_count": target_count,
			"current_count": current_count,
			"is_completed": is_completed,
			"status": String(status),
			"parent_id": String(parent_id),
			"child_ids": child_ids.duplicate(),
			"metadata": metadata.duplicate(true),
			"acceptance_condition_count": acceptance_conditions.size(),
			"completion_blocker_count": completion_blockers.size(),
		}
