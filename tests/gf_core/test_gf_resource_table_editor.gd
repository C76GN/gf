## 测试通用资源表格编辑器的列提取与单元格提交。
extends GutTest


# --- 辅助类型 ---

class TableResource:
	extends Resource

	@export var label: String = ""
	@export var amount: int = 0


# --- 测试 ---

func test_build_export_columns_reads_resource_exports() -> void:
	var resource := TableResource.new()
	var columns := GFResourceTableEditor.build_export_columns(resource)
	var names := PackedStringArray()
	for column: Dictionary in columns:
		names.append(str(column.get("name", "")))

	assert_true(names.has("label"), "导出列应包含 String export。")
	assert_true(names.has("amount"), "导出列应包含 int export。")


func test_commit_cell_value_updates_resource_and_emits_signal() -> void:
	var resource := TableResource.new()
	resource.label = "old"
	var editor := GFResourceTableEditor.new()
	add_child_autofree(editor)
	watch_signals(editor)

	editor.load_resources([resource], [{
		"name": &"label",
		"type": TYPE_STRING,
	}])
	var committed := editor.commit_cell_value(0, &"label", "new")

	assert_true(committed, "有效单元格应提交成功。")
	assert_eq(resource.label, "new", "提交后 Resource 属性应更新。")
	assert_signal_emitted(editor, "cell_value_committed", "提交后应发出变更信号。")


func test_editor_value_field_keeps_value_when_json_is_invalid() -> void:
	var field := GFEditorValueField.new()
	add_child_autofree(field)
	watch_signals(field)

	field.configure({ "name": &"metadata", "type": TYPE_DICTIONARY }, { "safe": true })
	(field._editor as LineEdit).text = "{bad"
	field._on_text_changed("{bad")

	assert_eq(field.get_value(), { "safe": true }, "JSON 解析失败时应保留旧值。")
	assert_signal_emitted(field, "value_parse_failed", "JSON 解析失败应发出失败信号。")
	assert_signal_not_emitted(field, "value_changed", "JSON 解析失败不应提交新值。")


func test_resource_table_can_auto_save_committed_resource() -> void:
	var resource := GFConfigTableColumn.new()
	resource.field_name = &"old"
	var path := "user://gf_resource_table_auto_save.tres"
	assert_eq(ResourceSaver.save(resource, path), OK, "测试资源应能先保存到 user://。")

	var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as GFConfigTableColumn
	var editor := GFResourceTableEditor.new()
	add_child_autofree(editor)
	editor.auto_save_committed_resources = true
	editor.load_resources([loaded], [{
		"name": &"field_name",
		"type": TYPE_STRING_NAME,
	}])

	assert_true(editor.commit_cell_value(0, &"field_name", &"new"), "有效单元格应提交成功。")
	var reloaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as GFConfigTableColumn
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	assert_eq(reloaded.field_name, &"new", "启用自动保存后提交值应写回资源文件。")
