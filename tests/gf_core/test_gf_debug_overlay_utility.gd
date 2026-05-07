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


func test_dispose_detaches_overlay_callbacks_before_queue_free() -> void:
	var gui := _debug._overlay_gui
	gui.visible = true

	_debug.dispose()

	assert_false(gui.visible, "dispose 应先隐藏 overlay，避免释放期间继续刷新。")
	assert_false(gui.is_processing(), "dispose 应停止 overlay 的 process。")
	assert_false(gui.is_processing_input(), "dispose 应停止 overlay 的 input process。")
	assert_false(gui.architecture_provider.is_valid(), "dispose 应清空架构回调。")
	assert_false(gui.watch_snapshot_provider.is_valid(), "dispose 应清空 watch 回调。")


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


func test_push_watch_value_is_rendered_without_models() -> void:
	assert_true(_debug.push_watch_value(&"fps", 60, {
		"label": "FPS",
		"group": "Runtime",
	}), "有效 watch 值应该能注册。")
	var gui := _debug._overlay_gui
	gui.visible = true

	gui._process(0.1)

	var label_text := gui._label.text
	assert_true("Watches: Runtime" in label_text, "Overlay 应输出 watch 分组。")
	assert_true("FPS" in label_text, "Overlay 应输出 watch 标签。")
	assert_true("60" in label_text, "Overlay 应输出 watch 值。")
	assert_false("No GFModels registered." in label_text, "已有 watch 时不应只显示无模型提示。")


func test_watch_text_escapes_bbcode_control_characters() -> void:
	assert_true(_debug.push_watch_value(&"tagged", "[b]42[/b]", {
		"label": "[Label]",
		"group": "[Group]",
	}), "带 BBCode 控制字符的 watch 应该能注册。")
	var gui := _debug._overlay_gui
	gui.visible = true

	gui._process(0.1)

	var label_text := gui._label.text
	assert_true("[lb]Group[rb]" in label_text, "Overlay 应转义 watch 分组中的 BBCode 控制字符。")
	assert_true("[lb]Label[rb]" in label_text, "Overlay 应转义 watch 标签中的 BBCode 控制字符。")
	assert_true("[lb]b[rb]42[lb]/b[rb]" in label_text, "Overlay 应转义 watch 值中的 BBCode 控制字符。")


func test_watch_value_provider_updates_snapshot() -> void:
	var state := { "value": 1 }
	assert_true(_debug.watch_value(&"counter", func() -> int:
		return int(state["value"])
	), "有效 provider 应该能注册。")

	var snapshot := _debug.get_watch_snapshot()
	assert_eq(snapshot.size(), 1, "应该返回一个 watch 快照。")
	assert_eq(snapshot[0]["value"], 1, "快照应读取 provider 的当前值。")

	state["value"] = 2
	snapshot = _debug.get_watch_snapshot()
	assert_eq(snapshot[0]["value"], 2, "provider watch 应在读取快照时更新。")


func test_watch_visibility_and_removal() -> void:
	assert_true(_debug.push_watch_value(&"hidden", "secret", {
		"label": "Hidden",
		"visible": false,
	}), "隐藏 watch 仍应该能注册。")

	assert_true(_debug.has_watch(&"hidden"), "隐藏 watch 应该存在于注册表中。")
	assert_eq(_debug.get_watch_snapshot().size(), 0, "默认快照不应返回隐藏 watch。")
	assert_eq(_debug.get_watch_snapshot(true).size(), 1, "显式 include_hidden 时应返回隐藏 watch。")

	_debug.remove_watch(&"hidden")
	assert_false(_debug.has_watch(&"hidden"), "remove_watch 应移除 watch。")


func test_invalid_watch_registration_is_rejected() -> void:
	assert_false(_debug.push_watch_value(&"", 1), "空 id 的 push watch 应被拒绝。")
	assert_false(_debug.watch_value(&"invalid", Callable()), "无效 provider 应被拒绝。")
	assert_false(_debug.has_watch(&"invalid"), "被拒绝的 watch 不应进入注册表。")


func after_each() -> void:
	var arch: GFArchitecture = Gf.get_architecture()
	if arch != null:
		arch.dispose()
		await Gf.set_architecture(GFArchitecture.new())
	await get_tree().process_frame
