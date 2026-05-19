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


func test_scan_resource_paths_respects_resource_limit() -> void:
	var directory := "user://gf_resource_table_scan"
	var first_path := directory.path_join("first.tres")
	var second_path := directory.path_join("second.tres")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	_write_empty_user_file(first_path)
	_write_empty_user_file(second_path)

	var paths := GFResourceTableEditor.scan_resource_paths(
		directory,
		PackedStringArray(["tres"]),
		{
			"max_resource_paths": 1,
		}
	)

	DirAccess.remove_absolute(ProjectSettings.globalize_path(first_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(second_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(directory))

	assert_eq(paths.size(), 1, "资源路径扫描应遵守 max_resource_paths 上限。")


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


func test_resource_table_search_filters_visible_rows_and_commits_visible_cell() -> void:
	var first := TableResource.new()
	first.label = "Alpha"
	first.amount = 1
	var second := TableResource.new()
	second.label = "Beta"
	second.amount = 2
	var editor := GFResourceTableEditor.new()
	add_child_autofree(editor)

	editor.load_resources([first, second], [{
		"name": &"label",
		"type": TYPE_STRING,
	}, {
		"name": &"amount",
		"type": TYPE_INT,
	}])
	editor.set_search_text("bet")
	var visible_rows := editor.get_visible_row_indices()

	assert_eq(visible_rows, PackedInt32Array([1]), "搜索应只显示匹配的原始资源行。")
	assert_true(editor.commit_visible_cell_value(0, &"amount", 5), "可见行提交应映射到原始资源。")
	assert_eq(second.amount, 5, "可见行提交应更新匹配资源。")


func test_resource_table_supports_sort_duplicate_move_and_remove() -> void:
	var first := TableResource.new()
	first.label = "First"
	first.amount = 2
	var second := TableResource.new()
	second.label = "Second"
	second.amount = 1
	var editor := GFResourceTableEditor.new()
	add_child_autofree(editor)
	watch_signals(editor)
	editor.load_resources([first, second], [{
		"name": &"amount",
		"type": TYPE_INT,
	}])

	editor.sort_by_property(&"amount")
	var sorted := editor.get_resources()
	var duplicated_resource := editor.duplicate_resource(0)
	assert_true(editor.move_resource(2, 1), "资源应可移动到指定位置。")
	var removed := editor.remove_resource(0)

	assert_same(sorted[0], second, "排序应按属性升序排列。")
	assert_not_null(duplicated_resource, "复制资源应返回新 Resource。")
	assert_eq((duplicated_resource as TableResource).amount, second.amount, "复制资源应保留字段值。")
	assert_same(removed, second, "移除应返回被移除的资源。")
	assert_signal_emitted(editor, "resources_reordered", "排序或移动后应发出重排信号。")
	assert_signal_emitted(editor, "resource_inserted", "复制资源后应发出插入信号。")
	assert_signal_emitted(editor, "resource_removed", "移除资源后应发出移除信号。")


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


func test_editor_value_field_rejects_json_with_wrong_container_type() -> void:
	var field := GFEditorValueField.new()
	add_child_autofree(field)
	watch_signals(field)

	field.configure({ "name": &"metadata", "type": TYPE_DICTIONARY }, { "safe": true })
	(field._editor as LineEdit).text = "[]"
	field._on_text_changed("[]")

	assert_eq(field.get_value(), { "safe": true }, "Dictionary 字段不应接受 Array JSON。")
	assert_signal_emitted(field, "value_parse_failed", "JSON 容器类型不匹配应发出失败信号。")
	assert_signal_not_emitted(field, "value_changed", "JSON 容器类型不匹配不应提交新值。")


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


# --- 私有/辅助方法 ---

func _write_empty_user_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file, "测试应能创建 user:// 临时文件。")
	if file == null:
		return
	file.store_string("")
	file.close()
