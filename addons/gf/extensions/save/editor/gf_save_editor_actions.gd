@tool

## GFSaveEditorActions: Save 扩展编辑器菜单动作。
extends RefCounted


# --- 常量 ---

const MENU_ACTION_VALIDATE_SAVE_GRAPH: StringName = &"validate_save_graph"
const DIAGNOSTIC_DIALOG_MIN_SIZE: Vector2 = Vector2(720.0, 460.0)
const GF_SAVE_GRAPH_UTILITY_BASE := preload("res://addons/gf/extensions/save/graph/gf_save_graph_utility.gd")
const GF_SAVE_SCOPE_BASE := preload("res://addons/gf/extensions/save/core/gf_save_scope.gd")
const _SCRIPT_TYPE_INSPECTOR: Script = preload("res://addons/gf/kernel/core/gf_script_type_inspector.gd")


# --- 私有变量 ---

var _diagnostic_dialog: AcceptDialog
var _diagnostic_output: TextEdit


# --- 公共方法 ---

## 获取 Save 扩展贡献的 GF 工具菜单项。
## @return 菜单项记录列表。
func get_menu_entries() -> Array[Dictionary]:
	return [
		{
			"id": MENU_ACTION_VALIDATE_SAVE_GRAPH,
			"label": "校验当前场景 SaveGraph",
			"section": "诊断",
		},
	]


## 执行 Save 扩展菜单动作。
## @param action_id: 菜单动作 ID。
func handle_menu_action(action_id: StringName) -> void:
	match action_id:
		MENU_ACTION_VALIDATE_SAVE_GRAPH:
			_validate_current_scene_save_graph()


## 清理菜单动作持有的 UI。
func cleanup() -> void:
	_cleanup_diagnostic_dialog()


# --- 私有/辅助方法 ---

func _validate_current_scene_save_graph() -> void:
	var scene_root := EditorInterface.get_edited_scene_root()
	if scene_root == null:
		_show_diagnostic_dialog("GF SaveGraph Health", "当前没有正在编辑的场景。")
		return

	var scopes: Array[Node] = []
	_collect_save_scopes(scene_root, scopes)
	if scopes.is_empty():
		_show_diagnostic_dialog("GF SaveGraph Health", "当前场景未找到 GFSaveScope。")
		return

	var utility := GF_SAVE_GRAPH_UTILITY_BASE.new()
	var lines := PackedStringArray()
	lines.append("Scene: %s" % scene_root.scene_file_path)
	lines.append("Scope count: %d" % scopes.size())
	lines.append("")
	for scope: Node in scopes:
		var report: Dictionary = utility.inspect_scope(scope)
		lines.append("[%s] %s" % [String(scope.get_path()), String(report.get("summary", ""))])
		lines.append("Next: %s" % String(report.get("next_action", "")))
		for issue_variant: Variant in report.get("issues", []):
			var issue := issue_variant as Dictionary
			if issue == null:
				continue
			lines.append("- %s %s %s: %s" % [
				String(issue.get("severity", "")),
				String(issue.get("kind", "")),
				String(issue.get("path", "")),
				String(issue.get("message", "")),
			])
		lines.append("")

	_show_diagnostic_dialog("GF SaveGraph Health", "\n".join(lines))


func _collect_save_scopes(node: Node, result: Array[Node]) -> void:
	var node_script := node.get_script() as Script
	if _SCRIPT_TYPE_INSPECTOR.script_extends_or_equals(node_script, GF_SAVE_SCOPE_BASE):
		result.append(node)

	for child: Node in node.get_children():
		_collect_save_scopes(child, result)


func _show_diagnostic_dialog(title: String, text: String) -> void:
	if not is_instance_valid(_diagnostic_dialog):
		_diagnostic_dialog = AcceptDialog.new()
		var dialog_min_size := Vector2i(
			int(DIAGNOSTIC_DIALOG_MIN_SIZE.x),
			int(DIAGNOSTIC_DIALOG_MIN_SIZE.y)
		)
		_diagnostic_dialog.min_size = dialog_min_size
		_diagnostic_output = TextEdit.new()
		_diagnostic_output.editable = false
		_diagnostic_output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_diagnostic_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_diagnostic_dialog.add_child(_diagnostic_output)
		EditorInterface.get_base_control().add_child(_diagnostic_dialog)

	_diagnostic_dialog.title = title
	if is_instance_valid(_diagnostic_output):
		_diagnostic_output.text = text
	_diagnostic_dialog.popup_centered(Vector2i(
		int(DIAGNOSTIC_DIALOG_MIN_SIZE.x),
		int(DIAGNOSTIC_DIALOG_MIN_SIZE.y)
	))


func _cleanup_diagnostic_dialog() -> void:
	if is_instance_valid(_diagnostic_dialog):
		_diagnostic_dialog.queue_free()
	_diagnostic_dialog = null
	_diagnostic_output = null
