@tool

## GFEditorPickOperation: 编辑器工具的分阶段拾取操作协议。
##
## 用于描述 pick、preview、ready、apply 和 cancel 这类持续交互流程。
class_name GFEditorPickOperation
extends RefCounted


# --- 枚举 ---

## 拾取操作状态。
enum State {
	## 尚未开始。
	IDLE,
	## 正在拾取。
	PICKING,
	## 已准备好应用。
	READY,
	## 已应用。
	APPLIED,
	## 已取消。
	CANCELLED,
}


# --- 常量 ---

const GFEditorToolContextBase = preload("res://addons/gf/kernel/editor/gf_editor_tool_context.gd")


# --- 公共变量 ---

## 操作稳定标识。
var operation_id: StringName = &""

## 操作显示名称。
var label: String = ""

## 调用方附加元数据。
var metadata: Dictionary = {}


# --- 私有变量 ---

var _state: State = State.IDLE
var _context: GFEditorToolContextBase = null
var _preview: Dictionary = {}
var _result: Dictionary = {}


# --- 公共方法 ---

## 开始拾取操作。
## @param context: 编辑器工具上下文。
## @return 成功开始返回 true。
func begin(context: GFEditorToolContextBase) -> bool:
	if context == null or _state == State.PICKING or _state == State.READY:
		return false
	_context = context
	_state = State.PICKING
	_preview.clear()
	_result.clear()
	_on_begin(context)
	return true


## 输入一次拾取数据。
## @param input_data: 调用方传入的通用拾取数据。
## @return 操作状态。
func pick(input_data: Dictionary) -> State:
	if _state != State.PICKING and _state != State.READY:
		return _state

	var response := _on_pick(input_data)
	if response.has("preview") and response["preview"] is Dictionary:
		_preview = (response["preview"] as Dictionary).duplicate(true)
	if response.has("result") and response["result"] is Dictionary:
		_result = (response["result"] as Dictionary).duplicate(true)

	var ready := bool(response.get("ready", _on_can_apply()))
	_state = State.READY if ready else State.PICKING
	return _state


## 检查当前操作是否可应用。
## @return 可应用返回 true。
func can_apply() -> bool:
	return _state == State.READY and _on_can_apply()


## 应用拾取结果。
## @return 应用结果字典。
func apply() -> Dictionary:
	if not can_apply():
		return {
			"ok": false,
			"reason": &"not_ready",
		}
	var result := _on_apply(_context, _result.duplicate(true))
	_state = State.APPLIED
	return result


## 取消拾取操作。
func cancel() -> void:
	if _state == State.APPLIED or _state == State.CANCELLED:
		return
	_on_cancel(_context)
	_state = State.CANCELLED


## 获取当前状态。
## @return 当前操作状态。
func get_state() -> State:
	return _state


## 获取预览数据副本。
## @return 预览数据。
func get_preview() -> Dictionary:
	return _preview.duplicate(true)


## 获取拾取结果副本。
## @return 拾取结果。
func get_result() -> Dictionary:
	return _result.duplicate(true)


## 获取调试快照。
## @return 调试快照字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"operation_id": operation_id,
		"label": label,
		"state": _state,
		"preview": _preview.duplicate(true),
		"result": _result.duplicate(true),
		"metadata": metadata.duplicate(true),
	}


# --- 虚方法（由子类重写） ---

func _on_begin(_context: GFEditorToolContextBase) -> void:
	pass


func _on_pick(_input_data: Dictionary) -> Dictionary:
	return {}


func _on_can_apply() -> bool:
	return not _result.is_empty()


func _on_apply(_context: GFEditorToolContextBase, result: Dictionary) -> Dictionary:
	return {
		"ok": true,
		"result": result,
	}


func _on_cancel(_context: GFEditorToolContextBase) -> void:
	pass
