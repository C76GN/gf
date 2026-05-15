## GFDragDropUtility: 通用拖拽会话与落点匹配工具。
##
## 该工具只管理拖拽生命周期、落点注册、命中排序和结果包装。
## 它不读取输入、不移动节点、不保存业务历史，也不规定具体 UI 或玩法语义。
class_name GFDragDropUtility
extends GFUtility


# --- 信号 ---

## 拖拽开始时发出。
## @param session_id: 会话 ID。
## @param drag_type: 拖拽类型。
signal drag_started(session_id: int, drag_type: StringName)

## 拖拽位置更新时发出。
## @param session_id: 会话 ID。
## @param position: 当前位置。
## @param delta: 本次位移。
signal drag_moved(session_id: int, position: Vector2, delta: Vector2)

## 拖拽成功释放到落点时发出。
## @param session_id: 会话 ID。
## @param zone_id: 落点 ID。
## @param result: 落点返回结果。
signal drag_dropped(session_id: int, zone_id: StringName, result: Dictionary)

## 拖拽释放被拒绝时发出。
## @param session_id: 会话 ID。
## @param reason: 拒绝原因。
signal drag_drop_rejected(session_id: int, reason: StringName)

## 拖拽取消时发出。
## @param session_id: 会话 ID。
signal drag_cancelled(session_id: int)

## 落点注册后发出。
## @param zone_id: 落点 ID。
signal drop_zone_registered(zone_id: StringName)

## 落点注销后发出。
## @param zone_id: 落点 ID。
signal drop_zone_unregistered(zone_id: StringName)


# --- 私有变量 ---

var _session_serial: int = 0
var _sessions: Dictionary = {}
var _zones: Dictionary = {}


# --- GF 生命周期方法 ---

func dispose() -> void:
	clear_sessions()
	clear_zones()


# --- 公共方法 ---

## 注册落点。
## @param zone: 落点规则。
## @return 注册成功返回 true。
func register_zone(zone: GFDropZone) -> bool:
	if zone == null or zone.zone_id == &"":
		return false
	_zones[zone.zone_id] = zone
	drop_zone_registered.emit(zone.zone_id)
	return true


## 注册矩形落点。
## @param zone_id: 落点 ID。
## @param rect: 全局矩形区域。
## @param accepted_types: 可接收类型；为空表示不限制。
## @param options: 可选参数，支持 priority、enabled、metadata、can_accept、drop。
## @return 注册成功时返回落点，否则返回 null。
func register_rect_zone(
	zone_id: StringName,
	rect: Rect2,
	accepted_types: PackedStringArray = PackedStringArray(),
	options: Dictionary = {}
) -> GFDropZone:
	var zone := GFDropZone.from_rect(zone_id, rect, accepted_types, options)
	return zone if register_zone(zone) else null


## 注册 Control 全局矩形落点。
## @param zone_id: 落点 ID。
## @param control: 用于读取 get_global_rect() 的 Control。
## @param accepted_types: 可接收类型；为空表示不限制。
## @param options: 可选参数，支持 priority、enabled、metadata、can_accept、drop。
## @return 注册成功时返回落点，否则返回 null。
func register_control_zone(
	zone_id: StringName,
	control: Control,
	accepted_types: PackedStringArray = PackedStringArray(),
	options: Dictionary = {}
) -> GFDropZone:
	var zone := GFDropZone.from_control(zone_id, control, accepted_types, options)
	return zone if register_zone(zone) else null


## 注销落点。
## @param zone_id: 落点 ID。
## @return 找到并移除时返回 true。
func unregister_zone(zone_id: StringName) -> bool:
	if not _zones.has(zone_id):
		return false
	_zones.erase(zone_id)
	drop_zone_unregistered.emit(zone_id)
	return true


## 获取落点。
## @param zone_id: 落点 ID。
## @return 落点；不存在时返回 null。
func get_zone(zone_id: StringName) -> GFDropZone:
	return _zones.get(zone_id, null) as GFDropZone


## 清空落点。
func clear_zones() -> void:
	for zone_id: StringName in _zones.keys():
		drop_zone_unregistered.emit(zone_id)
	_zones.clear()


## 开始拖拽。
## @param drag_type: 拖拽类型。
## @param payload: 项目自定义载荷。
## @param position: 起始位置。
## @param source: 可选来源对象。
## @param metadata: 项目自定义元数据。
## @return 会话 ID；失败时返回 -1。
func start_drag(
	drag_type: StringName,
	payload: Variant,
	position: Vector2,
	source: Object = null,
	metadata: Dictionary = {}
) -> int:
	if drag_type == &"":
		return -1

	_session_serial += 1
	var session := GFDragSession.new()
	session.setup(_session_serial, drag_type, payload, position, source, metadata)
	_sessions[session.session_id] = session
	drag_started.emit(session.session_id, drag_type)
	return session.session_id


## 更新拖拽位置。
## @param session_id: 会话 ID。
## @param position: 当前位置。
## @return 更新成功返回 true。
func update_drag(session_id: int, position: Vector2) -> bool:
	var session := get_session(session_id)
	if session == null:
		return false
	session.update_position(position)
	drag_moved.emit(session_id, position, session.get_delta())
	return true


## 将拖拽释放到当前位置匹配到的最佳落点。
## @param session_id: 会话 ID。
## @param position: 释放位置。
## @return 结构化结果字典。
func drop(session_id: int, position: Vector2) -> Dictionary:
	var session := get_session(session_id)
	if session == null:
		return _make_result(false, session_id, &"", &"missing_session")

	session.update_position(position)
	var zone := get_best_drop_zone(session_id, position)
	if zone == null:
		drag_drop_rejected.emit(session_id, &"no_drop_zone")
		return _make_result(false, session_id, &"", &"no_drop_zone")

	var raw_result: Variant = zone.drop(session, position)
	var result := _normalize_drop_result(raw_result, session_id, zone.zone_id)
	if not bool(result.get("ok", false)):
		drag_drop_rejected.emit(session_id, StringName(result.get("reason", &"drop_rejected")))
		return result

	_sessions.erase(session_id)
	drag_dropped.emit(session_id, zone.zone_id, result)
	return result


## 取消拖拽。
## @param session_id: 会话 ID。
## @return 找到并取消时返回 true。
func cancel_drag(session_id: int) -> bool:
	if not _sessions.has(session_id):
		return false
	_sessions.erase(session_id)
	drag_cancelled.emit(session_id)
	return true


## 获取会话。
## @param session_id: 会话 ID。
## @return 会话；不存在时返回 null。
func get_session(session_id: int) -> GFDragSession:
	return _sessions.get(session_id, null) as GFDragSession


## 检查会话是否存在。
## @param session_id: 会话 ID。
## @return 存在时返回 true。
func has_active_session(session_id: int) -> bool:
	return _sessions.has(session_id)


## 获取当前位置命中的落点候选。
## @param session_id: 会话 ID。
## @param position: 要检查的位置。
## @param only_accepting: 为 true 时只返回当前可接收会话的落点。
## @return 按优先级排序的落点列表。
func get_drop_candidates(
	session_id: int,
	position: Vector2,
	only_accepting: bool = true
) -> Array[GFDropZone]:
	var session := get_session(session_id)
	if session == null:
		return []

	var result: Array[GFDropZone] = []
	for zone_variant: Variant in _zones.values():
		var zone := zone_variant as GFDropZone
		if zone == null:
			continue
		if not zone.contains(position, session):
			continue
		if only_accepting and not zone.can_accept(session):
			continue
		result.append(zone)
	result.sort_custom(_sort_zones)
	return result


## 获取当前位置最佳落点。
## @param session_id: 会话 ID。
## @param position: 要检查的位置。
## @return 最佳落点；没有可用落点时返回 null。
func get_best_drop_zone(session_id: int, position: Vector2) -> GFDropZone:
	var candidates := get_drop_candidates(session_id, position, true)
	if candidates.is_empty():
		return null
	return candidates[0]


## 清空拖拽会话。
func clear_sessions() -> void:
	for session_id: int in _sessions.keys():
		drag_cancelled.emit(session_id)
	_sessions.clear()


## 获取调试快照。
## @return 当前拖拽与落点状态。
func get_debug_snapshot() -> Dictionary:
	var sessions: Array[Dictionary] = []
	for session_variant: Variant in _sessions.values():
		var session := session_variant as GFDragSession
		if session != null:
			sessions.append(session.to_dictionary())

	var zones: Array[Dictionary] = []
	for zone_variant: Variant in _zones.values():
		var zone := zone_variant as GFDropZone
		if zone != null:
			zones.append(zone.to_dictionary())

	return {
		"active_session_count": _sessions.size(),
		"zone_count": _zones.size(),
		"sessions": sessions,
		"zones": zones,
	}


# --- 私有/辅助方法 ---

func _sort_zones(left: GFDropZone, right: GFDropZone) -> bool:
	if left.priority != right.priority:
		return left.priority > right.priority
	return String(left.zone_id) < String(right.zone_id)


func _normalize_drop_result(raw_result: Variant, session_id: int, zone_id: StringName) -> Dictionary:
	if raw_result is Dictionary:
		var result := (raw_result as Dictionary).duplicate(true)
		if not result.has("ok"):
			result["ok"] = true
		result["session_id"] = session_id
		result["zone_id"] = zone_id
		if not bool(result.get("ok", false)) and not result.has("reason"):
			result["reason"] = &"drop_rejected"
		return result

	var ok := bool(raw_result) if raw_result is bool else true
	var result := {
		"ok": ok,
		"session_id": session_id,
		"zone_id": zone_id,
		"value": raw_result,
	}
	if not ok:
		result["reason"] = &"drop_rejected"
	return result


func _make_result(ok: bool, session_id: int, zone_id: StringName, reason: StringName) -> Dictionary:
	return {
		"ok": ok,
		"session_id": session_id,
		"zone_id": zone_id,
		"reason": reason,
	}
