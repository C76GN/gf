## 测试 GFUIUtility 的层级管理与异步生命周期保护。
extends GutTest


var _ui_utility: GFUIUtility
var _arch: GFArchitecture = null


class ManualAssetUtility extends GFAssetUtility:
	var _callbacks: Dictionary = {}

	func load_async(path: String, on_loaded: Callable, _type_hint: String = "") -> void:
		if not _callbacks.has(path):
			_callbacks[path] = [] as Array[Callable]
		var list: Array = _callbacks[path]
		list.append(on_loaded)

	func resolve(path: String, resource: Resource) -> void:
		if not _callbacks.has(path):
			return

		var callbacks: Array = _callbacks[path]
		_callbacks.erase(path)
		for callback: Callable in callbacks:
			callback.call(resource)


func before_each() -> void:
	_ui_utility = GFUIUtility.new()
	_ui_utility.init()
	await get_tree().process_frame


func after_each() -> void:
	if _ui_utility != null:
		_ui_utility.dispose()
		_ui_utility = null

	if _arch != null:
		_arch.dispose()
		_arch = null

	Gf._architecture = null
	await get_tree().process_frame


func test_layer_creation() -> void:
	var hud_layer := _ui_utility.get_layer_root(GFUIUtility.Layer.HUD)
	var popup_layer := _ui_utility.get_layer_root(GFUIUtility.Layer.POPUP)

	assert_not_null(hud_layer, "HUD 层应正确创建。")
	assert_not_null(popup_layer, "POPUP 层应正确创建。")
	assert_eq(hud_layer.get_parent(), get_tree().root, "CanvasLayer 应挂载到 SceneTree.root。")
	assert_eq(hud_layer.layer, 50, "HUD 层的基础 layer 应为 50。")
	assert_eq(popup_layer.layer, 60, "POPUP 层的基础 layer 应为 60。")


func test_push_and_pop_panel_instance() -> void:
	var panel1 := Control.new()
	var panel2 := Control.new()

	_ui_utility.push_panel_instance(panel1, GFUIUtility.Layer.POPUP)
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel1, "压入 panel1 后栈顶应为 panel1。")
	assert_eq(panel1.get_parent(), _ui_utility.get_layer_root(GFUIUtility.Layer.POPUP), "panel1 应添加到对应的 CanvasLayer 下。")

	_ui_utility.push_panel_instance(panel2, GFUIUtility.Layer.POPUP)
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel2, "压入 panel2 后栈顶应为 panel2。")
	assert_false(panel1.visible, "auto_hide_under 开启时，下层面板应自动隐藏。")
	assert_true(panel2.visible, "新压入的面板应保持可见。")

	_ui_utility.pop_panel(GFUIUtility.Layer.POPUP, true)
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel1, "弹出 panel2 后栈顶应恢复为 panel1。")
	assert_true(panel1.visible, "弹出顶层后，下层面板应重新可见。")


func test_external_free_of_top_panel_prunes_stack_and_reveals_under_panel() -> void:
	var panel1 := Control.new()
	var panel2 := Control.new()

	_ui_utility.push_panel_instance(panel1, GFUIUtility.Layer.POPUP)
	_ui_utility.push_panel_instance(panel2, GFUIUtility.Layer.POPUP)
	assert_false(panel1.visible, "顶层面板存在时，下层面板应隐藏。")

	panel2.queue_free()
	await get_tree().process_frame

	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel1, "外部释放顶层面板后，栈顶应回到下层面板。")
	assert_true(panel1.visible, "外部释放顶层面板后，下层面板应重新可见。")


func test_config_callback_destroying_panel_restores_hidden_panel() -> void:
	var panel1 := Control.new()
	var panel2 := Control.new()

	_ui_utility.push_panel_instance(panel1, GFUIUtility.Layer.POPUP)
	var added := _ui_utility._add_panel_instance(
		panel2,
		GFUIUtility.Layer.POPUP,
		func(panel: Node) -> void:
			panel.free()
	)

	assert_false(added, "config_callback 销毁面板时，本次入栈应取消。")
	assert_push_warning("[GFUIUtility] config_callback 销毁了面板实例，本次入栈已取消。")
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel1, "取消入栈后栈顶应保持原面板。")
	assert_true(panel1.visible, "取消入栈后原本被隐藏的面板应恢复可见。")


func test_clear_layer() -> void:
	var p1 := Control.new()
	var p2 := Control.new()

	_ui_utility.push_panel_instance(p1, GFUIUtility.Layer.TOP)
	_ui_utility.push_panel_instance(p2, GFUIUtility.Layer.TOP)

	_ui_utility.clear_layer(GFUIUtility.Layer.TOP)
	assert_null(_ui_utility.get_top_panel(GFUIUtility.Layer.TOP), "清空层后不应再有顶部面板。")

	await get_tree().process_frame
	assert_false(is_instance_valid(p1), "clear_layer 后原面板应被 queue_free。")
	assert_false(is_instance_valid(p2), "clear_layer 后所有面板都应被释放。")


func test_push_panel_async_ignores_late_callback_after_dispose() -> void:
	_arch = GFArchitecture.new()
	var asset_util := ManualAssetUtility.new()
	_arch.register_utility_instance(asset_util)
	await Gf.set_architecture(_arch)

	var scene := _make_control_scene()
	_ui_utility.push_panel_async("res://tests/pending_async_panel.tscn", GFUIUtility.Layer.POPUP)
	_ui_utility.dispose()

	asset_util.resolve("res://tests/pending_async_panel.tscn", scene)
	await get_tree().process_frame

	assert_null(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), "销毁后的异步回调不应再把面板压入栈。")


func _make_control_scene() -> PackedScene:
	var control := Control.new()
	var scene := PackedScene.new()
	scene.pack(control)
	control.free()
	return scene
