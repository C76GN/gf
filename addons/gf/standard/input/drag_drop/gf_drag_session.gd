## GFDragSession: 通用拖拽会话数据。
##
## 描述一次拖拽从开始到释放的稳定上下文，不绑定具体 UI、背包、棋盘、
## 关卡编辑器或任何业务对象。项目可把任意 payload 放入会话，再由落点规则解释。
class_name GFDragSession
extends RefCounted


# --- 公共变量 ---

## 会话 ID，由 GFDragDropUtility 分配。
var session_id: int = -1

## 拖拽类型。落点可用它做通用接收过滤。
var drag_type: StringName = &""

## 项目自定义载荷。框架不解释该字段。
var payload: Variant = null

## 起始位置，通常是屏幕或画布坐标。
var start_position: Vector2 = Vector2.ZERO

## 当前指针位置。
var current_position: Vector2 = Vector2.ZERO

## 上一次位置。
var previous_position: Vector2 = Vector2.ZERO

## 项目自定义元数据。框架只负责复制和透传。
var metadata: Dictionary = {}


# --- 私有变量 ---

var _source_ref: WeakRef = null


# --- 公共方法 ---

## 初始化会话。
## @param new_session_id: 会话 ID。
## @param new_drag_type: 拖拽类型。
## @param new_payload: 项目自定义载荷。
## @param position: 起始位置。
## @param source: 可选来源对象。
## @param new_metadata: 项目自定义元数据。
func setup(
	new_session_id: int,
	new_drag_type: StringName,
	new_payload: Variant,
	position: Vector2,
	source: Object = null,
	new_metadata: Dictionary = {}
) -> void:
	session_id = new_session_id
	drag_type = new_drag_type
	payload = new_payload
	start_position = position
	current_position = position
	previous_position = position
	_source_ref = weakref(source) if is_instance_valid(source) else null
	metadata = new_metadata.duplicate(true)


## 更新当前拖拽位置。
## @param position: 新位置。
func update_position(position: Vector2) -> void:
	previous_position = current_position
	current_position = position


## 获取本次更新的位移。
## @return 当前和上一次位置的差值。
func get_delta() -> Vector2:
	return current_position - previous_position


## 获取来源对象。
## @return 来源仍有效时返回对象，否则返回 null。
func get_source() -> Object:
	if _source_ref == null:
		return null
	var source := _source_ref.get_ref()
	return source if is_instance_valid(source) else null


## 转换为调试字典。
## @return 会话快照。
func to_dictionary() -> Dictionary:
	var source := get_source()
	return {
		"session_id": session_id,
		"drag_type": drag_type,
		"start_position": start_position,
		"current_position": current_position,
		"previous_position": previous_position,
		"delta": get_delta(),
		"has_source": source != null,
		"metadata": metadata.duplicate(true),
	}

