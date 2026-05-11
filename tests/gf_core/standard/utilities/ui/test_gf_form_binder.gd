## 测试 GFControlValueAdapter 与 GFFormBinder 的通用 Control 值读写。
extends GutTest


# --- 私有变量 ---

var _controls: Array[Control] = []


# --- Godot 生命周期方法 ---

func after_each() -> void:
	for control: Control in _controls:
		if is_instance_valid(control):
			control.free()
	_controls.clear()


# --- 测试方法 ---

func test_option_button_uses_selected_index_not_button_pressed() -> void:
	var option := OptionButton.new()
	_track_control(option)
	option.add_item("Low")
	option.add_item("High")

	assert_true(GFControlValueAdapter.set_value(option, 1), "OptionButton 应支持写入 selected。")
	assert_eq(GFControlValueAdapter.get_value(option), 1, "OptionButton 应读取 selected 索引。")


func test_form_binder_reads_and_writes_common_controls() -> void:
	var binder := GFFormBinder.new()
	var name_edit := LineEdit.new()
	var enabled_check := CheckBox.new()
	_track_control(name_edit)
	_track_control(enabled_check)

	binder.bind_field(&"name", name_edit)
	binder.bind_field(&"enabled", enabled_check)
	binder.write_values({
		"name": "Player",
		"enabled": true,
	})

	var values := binder.read_values()

	assert_eq(values.get(&"name"), "Player", "表单绑定应读取 LineEdit 文本。")
	assert_eq(values.get(&"enabled"), true, "表单绑定应读取 BaseButton 状态。")


func test_form_binder_emits_field_changed_from_control_signal() -> void:
	var binder := GFFormBinder.new()
	var name_edit := LineEdit.new()
	_track_control(name_edit)
	binder.bind_field(&"name", name_edit)
	watch_signals(binder)

	name_edit.text = "Changed"
	name_edit.text_changed.emit("Changed")

	assert_signal_emitted_with_parameters(binder, "field_changed", [&"name", "Changed"])


# --- 私有/辅助方法 ---

func _track_control(control: Control) -> void:
	_controls.append(control)
