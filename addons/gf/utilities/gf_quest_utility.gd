# addons/gf/utilities/gf_quest_utility.gd
class_name GFQuestUtility
extends GFUtility


## GFQuestUtility: 轻量级任务进度监听系统。
##
## 提供一个基于事件驱动的极简机制，用于监听框架内部的轻量级事件并累加任务进度。


# --- 信号 ---

signal quest_started(quest_id: StringName)
signal quest_progressed(quest_id: StringName, current: int, target: int)
signal quest_completed(quest_id: StringName)


# --- 内部数据结构 ---

class QuestData extends RefCounted:
	var quest_id: StringName
	var event_id: StringName
	var target_count: int = 1
	var current_count: int = 0
	var is_completed: bool = false


# --- 私有变量 ---

var _quests: Dictionary = {} # quest_id -> QuestData
var _event_to_quests: Dictionary = {} # event_id -> Array[quest_id]


# --- Godot 生命周期方法 ---

func init() -> void:
	_quests.clear()
	_event_to_quests.clear()


func dispose() -> void:
	_quests.clear()
	
	var arch := _get_arch()
	if arch != null:
		# 这里没有详细取消注册每个事件，因为架构销毁时会清空所有事件
		pass
	_event_to_quests.clear()


# --- 公共方法 ---

## 添加并开始一个任务监听。
## @param quest_id: 唯一任务标识。
## @param target_event: 该任务监听的轻量事件 ID (配合 Gf.send_simple_event 使用)。
## @param target_count: 达成目标需要触发的次数。
func start_quest(quest_id: StringName, target_event: StringName, target_count: int = 1) -> void:
	if _quests.has(quest_id):
		push_warning("[GFQuestUtility] 任务已存在：" + str(quest_id))
		return
		
	var data := QuestData.new()
	data.quest_id = quest_id
	data.event_id = target_event
	data.target_count = target_count
	
	_quests[quest_id] = data
	
	# 如果该事件还没有被注册过相关的监听器，则向主架构注册监听
	if not _event_to_quests.has(target_event):
		_event_to_quests[target_event] = [] as Array[StringName]
		
		var arch := _get_arch()
		if arch != null and arch.has_method("register_simple_event"):
			# bind 会把 target_event 附加到回调参数的末尾
			var callable: Callable = Callable(self , "_on_quest_event_triggered").bind(target_event)
			arch.register_simple_event(target_event, callable)
			
	var list: Array = _event_to_quests[target_event]
	if not list.has(quest_id):
		list.append(quest_id)
		
	quest_started.emit(quest_id)


## 手动触发带有指定增量的新任务事件。
## 注意：开发中更推荐其他业务逻辑解耦调用 Gf.send_simple_event("event_id", 增量数值) 来推进。
## @param event_id: 任务监听的目标事件 ID。
## @param amount: 进度增加量。
func emit_quest_event(event_id: StringName, amount: int = 1) -> void:
	var arch := _get_arch()
	if arch != null and arch.has_method("send_simple_event"):
		arch.send_simple_event(event_id, amount)
	else:
		_on_quest_event_triggered(amount, event_id)


## 检查任务是否完成。
## @param quest_id: 任务 ID。
func is_quest_completed(quest_id: StringName) -> bool:
	if _quests.has(quest_id):
		var q := _quests[quest_id] as QuestData
		return q.is_completed
	return false


## 获取任务进度的百分比 (0.0 - 1.0)。
## @param quest_id: 任务 ID。
func get_quest_progress(quest_id: StringName) -> float:
	if _quests.has(quest_id):
		var q := _quests[quest_id] as QuestData
		if q.target_count <= 0:
			return 1.0
		return float(q.current_count) / float(q.target_count)
	return 0.0


# --- 私有回调方法 ---

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


func _get_arch() -> Object:
	if Gf.has_method("has_architecture") and Gf.has_architecture():
		return Gf.get_architecture()
	return null
