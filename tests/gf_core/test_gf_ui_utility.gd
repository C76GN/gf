# tests/gf_core/test_gf_ui_utility.gd
extends GutTest


var _ui_utility: GFUIUtility


func before_each() -> void:
	_ui_utility = GFUIUtility.new()
	_ui_utility.init()
	# 等待一帧让 call_deferred 加载的 CanvasLayer 挂载到树上
	await get_tree().process_frame


func after_each() -> void:
	if _ui_utility != null:
		_ui_utility.dispose()
		_ui_utility = null
	await get_tree().process_frame


func test_layer_creation() -> void:
	var hud_layer := _ui_utility.get_layer_root(GFUIUtility.Layer.HUD)
	var popup_layer := _ui_utility.get_layer_root(GFUIUtility.Layer.POPUP)
	
	assert_not_null(hud_layer, "HUD 层应正确创建。")
	assert_not_null(popup_layer, "POPUP 层应正确创建。")
	assert_eq(hud_layer.get_parent(), get_tree().root, "CanvasLayer 应挂载到 SceneTree root 上。")
	assert_eq(hud_layer.layer, 50, "HUD 层的基础 layer 应为 50。")
	assert_eq(popup_layer.layer, 60, "POPUP 层的基础 layer 应为 60。")


func test_push_and_pop_panel_instance() -> void:
	var panel1 := Control.new()
	var panel2 := Control.new()
	
	# Push panel 1
	_ui_utility.push_panel_instance(panel1, GFUIUtility.Layer.POPUP)
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel1, "压入 panel1 后栈顶应为 panel1。")
	assert_eq(panel1.get_parent(), _ui_utility.get_layer_root(GFUIUtility.Layer.POPUP), "panel1 应添加为对应 CanvasLayer 的子节点。")
	
	# Push panel 2
	_ui_utility.push_panel_instance(panel2, GFUIUtility.Layer.POPUP)
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel2, "压入 panel2 后栈顶应为 panel2。")
	assert_false(panel1.visible, "auto_hide_under 开启时，压入新面板应隐藏下方面板。")
	assert_true(panel2.visible, "栈顶面板应当可见。")
	
	# Pop panel 2 (no free to avoid test crash on asserts if needed later, though do_free=true tests memory)
	_ui_utility.pop_panel(GFUIUtility.Layer.POPUP, false)
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel1, "弹出 panel2 后栈顶应恢复为 panel1。")
	assert_true(panel1.visible, "弹出后，下方面板可见性应恢复。")


func test_clear_layer() -> void:
	var p1 := Control.new()
	var p2 := Control.new()
	
	_ui_utility.push_panel_instance(p1, GFUIUtility.Layer.TOP)
	_ui_utility.push_panel_instance(p2, GFUIUtility.Layer.TOP)
	
	_ui_utility.clear_layer(GFUIUtility.Layer.TOP)
	
	assert_null(_ui_utility.get_top_panel(GFUIUtility.Layer.TOP), "清空层后该层不应有栈顶面板。")
	
	# Wait for queue_free
	await get_tree().process_frame
	assert_false(is_instance_valid(p1), "调用 clear 且由于配置出栈自动 queue_free 后，原面板应被销毁。")
	assert_false(is_instance_valid(p2), "原面板 2 也应被销毁。")
