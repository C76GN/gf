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
