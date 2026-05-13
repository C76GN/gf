@tool

## GFEditorTool: 持续式编辑器交互工具基类。
##
## 用于封装需要激活、停用、接收输入并最终产生命令的编辑器工具。
## 基类只定义生命周期协议，具体绘制和资源修改由子类实现。
class_name GFEditorTool
extends RefCounted


# --- 常量 ---

const GFEditorToolContextBase = preload("res://addons/gf/kernel/editor/gf_editor_tool_context.gd")
const GFEditorPickOperationBase = preload("res://addons/gf/kernel/editor/gf_editor_pick_operation.gd")
const GFEditorToolOptionSchemaBase = preload("res://addons/gf/kernel/editor/gf_editor_tool_option_schema.gd")


# --- 公共变量 ---

## 工具稳定标识。
var tool_id: StringName = &""

## 工具显示名称。
var label: String = ""

## 工具提示文本。
var tooltip: String = ""

## 工具排序权重。
var priority: int = 0

## 调用方附加元数据。
var metadata: Dictionary = {}

## 可选工具选项声明。
var option_schema: GFEditorToolOptionSchemaBase = null


# --- 私有变量 ---

var _active: bool = false
var _context: GFEditorToolContextBase = null
var _option_values: Dictionary = {}
var _pick_operation: GFEditorPickOperationBase = null


# --- 公共方法 ---

## 激活工具。
## @param context: 编辑器工具上下文。
func activate(context: GFEditorToolContextBase) -> void:
	if _active:
		return
	_context = context
	_active = true
	_on_activated(context)


## 停用工具。
func deactivate() -> void:
	if not _active:
		return
	_on_deactivated(_context)
	_context = null
	_active = false


## 工具是否处于激活状态。
func is_active() -> bool:
	return _active


## 获取当前上下文。
func get_context() -> GFEditorToolContextBase:
	return _context


## 设置工具选项声明。
## @param schema: 工具选项声明。
## @param reset_values: 是否重置当前选项值。
func set_option_schema(schema: GFEditorToolOptionSchemaBase, reset_values: bool = true) -> void:
	option_schema = schema.duplicate_schema() if schema != null else null
	if reset_values:
		_option_values = option_schema.get_default_values() if option_schema != null else {}


## 设置工具选项值。
## @param option_id: 选项标识。
## @param value: 选项值。
## @return 设置成功返回 true。
func set_tool_option(option_id: StringName, value: Variant) -> bool:
	if option_schema == null or not option_schema.has_option(option_id):
		return false
	var option := option_schema.get_option(option_id)
	_option_values[option_id] = option.normalize_value(value)
	return true


## 获取工具选项值。
## @param option_id: 选项标识。
## @param default_value: 缺失时返回的默认值。
## @return 选项值。
func get_tool_option(option_id: StringName, default_value: Variant = null) -> Variant:
	if _option_values.has(option_id):
		return _duplicate_variant(_option_values[option_id])
	return default_value


## 获取工具选项快照。
## @return 选项值副本。
func get_tool_options() -> Dictionary:
	return _option_values.duplicate(true)


## 清空工具选项值。
func clear_tool_options() -> void:
	_option_values.clear()


## 工具是否可以处理当前上下文。
## @param context: 编辑器工具上下文。
func can_handle(context: GFEditorToolContextBase) -> bool:
	return context != null


## 开始分阶段拾取操作。
## @param operation: 拾取操作。
## @return 成功开始返回 true。
func begin_pick_operation(operation: GFEditorPickOperationBase) -> bool:
	if not _active or operation == null:
		return false
	if _pick_operation != null:
		_pick_operation.cancel()
	_pick_operation = operation
	return _pick_operation.begin(_context)


## 向当前拾取操作输入数据。
## @param input_data: 通用拾取数据。
## @return 当前拾取状态；没有操作时返回 IDLE。
func pick(input_data: Dictionary) -> int:
	if _pick_operation == null:
		return GFEditorPickOperationBase.State.IDLE
	return _pick_operation.pick(input_data)


## 应用当前拾取操作。
## @return 应用结果字典。
func apply_pick_operation() -> Dictionary:
	if _pick_operation == null:
		return {
			"ok": false,
			"reason": &"missing_operation",
		}
	var result := _pick_operation.apply()
	if bool(result.get("ok", false)):
		_pick_operation = null
	return result


## 取消当前拾取操作。
func cancel_pick_operation() -> void:
	if _pick_operation == null:
		return
	_pick_operation.cancel()
	_pick_operation = null


## 获取当前拾取操作。
## @return 拾取操作；不存在时返回 null。
func get_pick_operation() -> GFEditorPickOperationBase:
	return _pick_operation


## 向工具转发输入事件。
## @param event: 输入事件。
## @return true 表示事件已被工具消费。
func gui_input(event: InputEvent) -> bool:
	if not _active:
		return false
	return _handle_gui_input(event)


## 请求工具绘制调试或交互辅助。
## @param viewport: 绘制目标视口。
func draw_tool(viewport: Viewport) -> void:
	if not _active:
		return
	_draw_tool(viewport)


## 获取工具快照。
## @return 调试信息字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"tool_id": String(tool_id),
		"label": label,
		"tooltip": tooltip,
		"priority": priority,
		"active": _active,
		"options": _option_values.duplicate(true),
		"pick_operation": _pick_operation.get_debug_snapshot() if _pick_operation != null else {},
		"metadata": metadata.duplicate(true),
	}


# --- 虚方法（由子类重写） ---

func _on_activated(_context: GFEditorToolContextBase) -> void:
	pass


func _on_deactivated(_context: GFEditorToolContextBase) -> void:
	pass


func _handle_gui_input(_event: InputEvent) -> bool:
	return false


func _draw_tool(_viewport: Viewport) -> void:
	pass


# --- 私有/辅助方法 ---

func _duplicate_variant(value: Variant) -> Variant:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	if value is Array:
		return (value as Array).duplicate(true)
	return value
