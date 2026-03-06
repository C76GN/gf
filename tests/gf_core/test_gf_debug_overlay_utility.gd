# tests/gf_core/test_gf_debug_overlay_utility.gd
extends GutTest


var _debug: GFDebugOverlayUtility


class DebugTestModel extends GFModel:
	var health: int = 100
	var player_name: String = "TestPlayer"


func before_each() -> void:
	var arch := GFArchitecture.new()
	Gf._architecture = arch
	_debug = GFDebugOverlayUtility.new()
	Gf.register_utility(_debug)
	await Gf.set_architecture(arch)
	await get_tree().process_frame


func test_overlay_creation_and_toggle() -> void:
	assert_not_null(_debug._overlay_gui, "Overlay UI 应该被创建。")
	var gui := _debug._overlay_gui
	
	assert_false(gui.visible, "默认应该隐藏。")
	
	# 模拟按键
	var event := InputEventKey.new()
	event.keycode = KEY_QUOTELEFT
	event.pressed = true
	get_tree().root.push_input(event)
	
	assert_true(gui.visible, "按键触发后应该显示。")


func test_process_model() -> void:
	Gf.register_model(DebugTestModel.new())
	var gui := _debug._overlay_gui
	gui.visible = true
	
	# 手动触发帧逻辑
	gui._process(0.1)
	
	var label_text := gui._label.text
	assert_true("health" in label_text, "Overlay 应输出 Model 中的变量名。")
	assert_true("100" in label_text, "Overlay 应输出变量的值。")
	assert_true("TestPlayer" in label_text, "Overlay 应输出字符串变量的值。")


func after_each() -> void:
	var arch := Gf.get_architecture()
	if arch != null:
		arch.dispose()
		await Gf.set_architecture(GFArchitecture.new())
	await get_tree().process_frame
