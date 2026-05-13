## 测试通用编辑器 Command、Action 与 Tool 协议。
extends GutTest


# --- 常量 ---

const GFEditorActionDefinitionBase = preload("res://addons/gf/kernel/editor/gf_editor_action_definition.gd")
const GFEditorCommandBase = preload("res://addons/gf/kernel/editor/gf_editor_command.gd")
const GFEditorPickOperationBase = preload("res://addons/gf/kernel/editor/gf_editor_pick_operation.gd")
const GFEditorToolBase = preload("res://addons/gf/kernel/editor/gf_editor_tool.gd")
const GFEditorToolContextBase = preload("res://addons/gf/kernel/editor/gf_editor_tool_context.gd")
const GFEditorToolOptionBase = preload("res://addons/gf/kernel/editor/gf_editor_tool_option.gd")
const GFEditorToolOptionSchemaBase = preload("res://addons/gf/kernel/editor/gf_editor_tool_option_schema.gd")


# --- 测试 ---

func test_editor_command_executes_and_reverts() -> void:
	var state := { "value": 0 }
	var command := CounterCommand.new()
	command.target = state
	command.delta = 3
	command.command_name = "Increase Value"

	assert_eq(command.execute(), OK, "命令应能直接执行。")
	assert_eq(state["value"], 3, "执行后应写入目标状态。")
	assert_true(command.is_executed(), "执行成功后应记录状态。")

	assert_eq(command.revert(), OK, "命令应能撤销。")
	assert_eq(state["value"], 0, "撤销后应恢复目标状态。")


func test_editor_action_creates_and_invokes_command() -> void:
	var state := { "value": 0 }
	var action: GFEditorActionDefinitionBase = GFEditorActionDefinitionBase.new()
	action.action_id = &"increase"
	action.label = "Increase"
	action.command_factory = func(context: Dictionary) -> GFEditorCommandBase:
		var command := CounterCommand.new()
		command.target = context["state"] as Dictionary
		command.delta = 2
		return command

	assert_true(action.is_available({ "state": state }), "有效工厂应让动作可用。")
	assert_eq(action.invoke({ "state": state }), OK, "动作应能执行命令。")
	assert_eq(state["value"], 2, "动作执行后应影响目标状态。")


func test_editor_tool_lifecycle_and_input_forwarding() -> void:
	var tool := RecordingTool.new()
	var context: GFEditorToolContextBase = GFEditorToolContextBase.new()

	assert_true(tool.can_handle(context), "默认工具应能处理有效上下文。")
	tool.activate(context)
	assert_true(tool.is_active(), "activate 后工具应进入激活状态。")

	var consumed := tool.gui_input(InputEventAction.new())
	assert_true(consumed, "激活工具应能转发输入。")
	assert_eq(tool.input_count, 1, "输入次数应被工具记录。")

	tool.deactivate()
	assert_false(tool.is_active(), "deactivate 后工具应离开激活状态。")


func test_editor_tool_option_schema_normalizes_values() -> void:
	var schema := GFEditorToolOptionSchemaBase.new()
	var radius := GFEditorToolOptionBase.new()
	radius.option_id = &"radius"
	radius.value_type = GFEditorToolOptionBase.ValueType.INT
	radius.min_value = 1.0
	radius.max_value = 10.0
	radius.default_value = 3
	schema.add_option(radius)

	var tool := RecordingTool.new()
	tool.set_option_schema(schema)

	assert_eq(tool.get_tool_option(&"radius"), 3, "设置 schema 后应写入默认工具选项。")
	assert_true(tool.set_tool_option(&"radius", 99), "已声明选项应可设置。")
	assert_eq(tool.get_tool_option(&"radius"), 10, "工具选项应按声明裁剪。")


func test_editor_pick_operation_tracks_preview_and_apply_result() -> void:
	var tool := RecordingTool.new()
	var context: GFEditorToolContextBase = GFEditorToolContextBase.new()
	var operation := RecordingPickOperation.new()
	tool.activate(context)

	assert_true(tool.begin_pick_operation(operation), "激活工具应能开始拾取操作。")
	assert_eq(tool.pick({ "position": Vector2(1.0, 2.0) }), GFEditorPickOperationBase.State.READY, "输入有效数据后拾取应进入 ready。")

	var snapshot := tool.get_debug_snapshot()
	var pick_snapshot := snapshot["pick_operation"] as Dictionary
	var result := tool.apply_pick_operation()

	assert_eq((pick_snapshot["preview"] as Dictionary)["position"], Vector2(1.0, 2.0), "拾取预览应进入工具快照。")
	assert_true(bool(result["ok"]), "ready 状态应可应用。")
	assert_eq((result["result"] as Dictionary)["position"], Vector2(1.0, 2.0), "应用结果应包含拾取结果。")


# --- 内部类 ---

class CounterCommand extends GFEditorCommandBase:
	var target: Dictionary = {}
	var delta: int = 1


	func _do_it() -> Error:
		target["value"] = int(target.get("value", 0)) + delta
		return OK


	func _undo_it() -> Error:
		target["value"] = int(target.get("value", 0)) - delta
		return OK


class RecordingTool extends GFEditorToolBase:
	var input_count: int = 0


	func _handle_gui_input(_event: InputEvent) -> bool:
		input_count += 1
		return true


class RecordingPickOperation extends GFEditorPickOperationBase:
	func _on_pick(input_data: Dictionary) -> Dictionary:
		return {
			"preview": input_data.duplicate(true),
			"result": input_data.duplicate(true),
			"ready": input_data.has("position"),
		}
