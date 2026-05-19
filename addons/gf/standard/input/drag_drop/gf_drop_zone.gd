## GFDropZone: 通用拖拽落点规则。
##
## 落点只描述“某个位置是否命中、某个会话是否可接收、接收时如何返回结果”。
## 它不移动节点、不修改业务数据，也不规定任何具体 UI 或玩法语义。
class_name GFDropZone
extends RefCounted


# --- 常量 ---

const _INSTANCE_GUARD: Script = preload("res://addons/gf/kernel/core/gf_instance_guard.gd")


# --- 公共变量 ---

## 落点 ID。
var zone_id: StringName = &""

## 可接收的拖拽类型。为空表示不限制类型。
var accepted_types: PackedStringArray = PackedStringArray()

## 匹配优先级。数值越大越优先。
var priority: int = 0

## 是否启用。
var enabled: bool = true

## 命中检测回调，签名为 func(position: Variant, session: GFDragSession) -> bool。
var contains_callable: Callable = Callable()

## 可接收检测回调，签名为 func(session: GFDragSession, zone: GFDropZone) -> bool。
var can_accept_callable: Callable = Callable()

## 接收回调，签名为 func(session: GFDragSession, zone: GFDropZone, position: Variant) -> Variant。
var drop_callable: Callable = Callable()

## 项目自定义元数据。框架不解释该字段。
var metadata: Dictionary = {}


# --- 公共方法 ---

## 检查落点是否包含位置。
## @param position: 位置，通常是屏幕或画布坐标。
## @param session: 当前拖拽会话。
## @return 命中时返回 true。
func contains(position: Variant, session: GFDragSession) -> bool:
	if not enabled:
		return false
	if contains_callable.is_valid():
		return bool(contains_callable.call(position, session))
	return false


## 检查落点是否接收会话。
## @param session: 当前拖拽会话。
## @return 可接收时返回 true。
func can_accept(session: GFDragSession) -> bool:
	if not enabled or session == null:
		return false
	if not _accepts_type(session.drag_type):
		return false
	if can_accept_callable.is_valid():
		return bool(can_accept_callable.call(session, self))
	return true


## 执行落点接收回调。
## @param session: 当前拖拽会话。
## @param position: 释放位置。
## @return 回调返回值；未设置回调时返回成功字典。
func drop(session: GFDragSession, position: Variant) -> Variant:
	if drop_callable.is_valid():
		return drop_callable.call(session, self, position)
	return {
		"ok": true,
		"zone_id": zone_id,
	}


## 转换为调试字典。
## @return 落点快照。
func to_dictionary() -> Dictionary:
	return {
		"zone_id": zone_id,
		"accepted_types": accepted_types,
		"priority": priority,
		"enabled": enabled,
		"has_contains_callable": contains_callable.is_valid(),
		"has_can_accept_callable": can_accept_callable.is_valid(),
		"has_drop_callable": drop_callable.is_valid(),
		"metadata": metadata.duplicate(true),
	}


## 创建矩形落点。
## @param new_zone_id: 落点 ID。
## @param rect: 全局矩形区域。
## @param new_accepted_types: 可接收类型；为空表示不限制。
## @param options: 可选参数，支持 priority、enabled、metadata、can_accept、drop。
## @return 新落点。
static func from_rect(
	new_zone_id: StringName,
	rect: Rect2,
	new_accepted_types: PackedStringArray = PackedStringArray(),
	options: Dictionary = {}
) -> GFDropZone:
	var zone := GFDropZone.new()
	zone.zone_id = new_zone_id
	zone.accepted_types = new_accepted_types
	zone.priority = int(options.get("priority", 0))
	zone.enabled = bool(options.get("enabled", true))
	zone.metadata = (options.get("metadata", {}) as Dictionary).duplicate(true)
	zone.can_accept_callable = options.get("can_accept", Callable()) as Callable
	zone.drop_callable = options.get("drop", Callable()) as Callable
	zone.contains_callable = func(position: Variant, _session: GFDragSession) -> bool:
		if typeof(position) != TYPE_VECTOR2:
			return false
		return rect.has_point(position)
	return zone


## 创建 Control 全局矩形落点。
## @param new_zone_id: 落点 ID。
## @param control: 用于读取 get_global_rect() 的 Control。
## @param new_accepted_types: 可接收类型；为空表示不限制。
## @param options: 可选参数，支持 priority、enabled、metadata、can_accept、drop。
## @return 新落点。
static func from_control(
	new_zone_id: StringName,
	control: Control,
	new_accepted_types: PackedStringArray = PackedStringArray(),
	options: Dictionary = {}
) -> GFDropZone:
	var zone := GFDropZone.new()
	zone.zone_id = new_zone_id
	zone.accepted_types = new_accepted_types
	zone.priority = int(options.get("priority", 0))
	zone.enabled = bool(options.get("enabled", true))
	zone.metadata = (options.get("metadata", {}) as Dictionary).duplicate(true)
	zone.can_accept_callable = options.get("can_accept", Callable()) as Callable
	zone.drop_callable = options.get("drop", Callable()) as Callable
	var control_ref := weakref(control) if is_instance_valid(control) else null
	zone.contains_callable = func(position: Variant, _session: GFDragSession) -> bool:
		if typeof(position) != TYPE_VECTOR2 or control_ref == null:
			return false
		var current: Control = _INSTANCE_GUARD._get_live_control_from_ref(control_ref)
		if current == null:
			return false
		return current.get_global_rect().has_point(position)
	return zone


# --- 私有/辅助方法 ---

func _accepts_type(drag_type: StringName) -> bool:
	if accepted_types.is_empty():
		return true
	return accepted_types.has(String(drag_type))
