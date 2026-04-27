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

## 当任务进度变化时发出。
## @param quest_id: 任务 ID。
## @param current: 当前进度。
## @param target: 目标进度。
signal quest_progressed(quest_id: StringName, current: int, target: int)

## 当任务完成时发出。
## @param quest_id: 完成的任务 ID。
signal quest_completed(quest_id: StringName)


# --- 内部类 ---

class QuestData extends RefCounted:
	var quest_id: StringName
	var event_id: StringName
	var target_count: int = 1
	var current_count: int = 0
	var is_completed: bool = false


# --- 私有变量 ---

## 任务表：`quest_id -> QuestData`。
var _quests: Dictionary = {}

## 事件到任务列表的映射：`event_id -> Array[StringName]`。
var _event_to_quests: Dictionary = {}

## 已注册的事件处理器：`event_id -> Callable`。
var _event_handlers: Dictionary = {}


# --- Godot 生命周期方法 ---

func init() -> void:
	_quests.clear()
	_event_to_quests.clear()
	_event_handlers.clear()


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
	if _quests.has(quest_id):
		push_warning("[GFQuestUtility] 任务已存在：%s" % quest_id)
		return

	var data := QuestData.new()
	data.quest_id = quest_id
	data.event_id = target_event
	data.target_count = target_count
	_quests[quest_id] = data

	if not _event_to_quests.has(target_event):
		_event_to_quests[target_event] = [] as Array[StringName]
		_register_event_handler(target_event)

	var list: Array = _event_to_quests[target_event]
	if not list.has(quest_id):
		list.append(quest_id)

	quest_started.emit(quest_id)


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

		return float(q.current_count) / float(q.target_count)

	return 0.0


# --- 私有/辅助方法 ---

func _on_quest_event_triggered(payload: Variant, event_id: StringName) -> void:
	if not _event_to_quests.has(event_id):
		return

	var amount: int = 1
	if payload is Dictionary and payload.has("amount"):
		amount = int(payload["amount"])
	elif payload is int or payload is float:
		amount = int(payload)

	var list: Array = _event_to_quests[event_id]
	for quest_id: StringName in list:
		var q := _quests.get(quest_id) as QuestData
		if q == null or q.is_completed:
			continue

		q.current_count += amount
		if q.current_count >= q.target_count:
			q.current_count = q.target_count
			q.is_completed = true
			quest_progressed.emit(quest_id, q.current_count, q.target_count)
			quest_completed.emit(quest_id)
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


func _unregister_all_event_handlers() -> void:
	var arch := _get_arch()
	if arch != null and arch.has_method("unregister_simple_event"):
		for event_id: StringName in _event_handlers:
			var event_handler := _event_handlers[event_id] as Callable
			arch.unregister_simple_event(event_id, event_handler)

	_event_handlers.clear()


func _get_arch() -> Object:
	if Gf.has_method("has_architecture") and Gf.has_architecture():
		return Gf.get_architecture()

	return null
