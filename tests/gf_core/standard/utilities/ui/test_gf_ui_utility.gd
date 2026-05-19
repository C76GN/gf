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


func test_dispose_detaches_layer_roots_immediately() -> void:
	var popup_layer := _ui_utility.get_layer_root(GFUIUtility.Layer.POPUP)

	_ui_utility.dispose()
	_ui_utility = null

	assert_null(popup_layer.get_parent(), "dispose 应立即从 SceneTree.root 移除 UI 层级。")

	await get_tree().process_frame
	assert_false(is_instance_valid(popup_layer), "下一帧 UI 层级应完成释放。")


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


func test_pop_panel_detaches_freed_panel_immediately() -> void:
	var panel := Control.new()
	var popup_layer := _ui_utility.get_layer_root(GFUIUtility.Layer.POPUP)
	_ui_utility.push_panel_instance(panel, GFUIUtility.Layer.POPUP)

	_ui_utility.pop_panel(GFUIUtility.Layer.POPUP)

	assert_null(panel.get_parent(), "弹出并释放面板时，应立即从 UI 层级移除。")
	assert_eq(popup_layer.get_child_count(), 0, "弹出后 POPUP CanvasLayer 不应继续持有旧面板。")
	assert_null(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), "弹出后栈顶应为空。")

	await get_tree().process_frame
	assert_false(is_instance_valid(panel), "弹出并释放面板后，下一帧实例应被释放。")


func test_pop_panel_without_free_detaches_and_keeps_instance() -> void:
	var panel := Control.new()
	var popup_layer := _ui_utility.get_layer_root(GFUIUtility.Layer.POPUP)
	_ui_utility.push_panel_instance(panel, GFUIUtility.Layer.POPUP)

	_ui_utility.pop_panel(GFUIUtility.Layer.POPUP, false)

	assert_null(panel.get_parent(), "弹出但不释放时，也应立即从 UI 层级移除。")
	assert_eq(popup_layer.get_child_count(), 0, "弹出但不释放后 POPUP CanvasLayer 不应继续持有旧面板。")
	assert_true(is_instance_valid(panel), "do_free 为 false 时，面板实例应交还给调用方复用。")

	panel.free()


func test_panel_signals_and_stack_snapshot() -> void:
	var panel1 := Control.new()
	panel1.name = "PanelOne"
	var panel2 := Control.new()
	panel2.name = "PanelTwo"
	var opened: Array = []
	var closed: Array = []
	var navigation_tops: Array = []
	_ui_utility.panel_opened.connect(func(panel: Node, _layer: int) -> void:
		opened.append(panel)
	)
	_ui_utility.panel_closed.connect(func(panel: Node, _layer: int) -> void:
		closed.append(panel)
	)
	_ui_utility.navigation_changed.connect(func(_layer: int, top_panel: Node) -> void:
		navigation_tops.append(top_panel)
	)

	_ui_utility.push_panel_instance(panel1, GFUIUtility.Layer.POPUP)
	_ui_utility.push_panel_instance(panel2, GFUIUtility.Layer.POPUP)
	var stack := _ui_utility.get_panel_stack(GFUIUtility.Layer.POPUP)

	assert_eq(opened, [panel1, panel2], "面板入栈应按顺序发出打开信号。")
	assert_eq(stack, [panel1, panel2], "get_panel_stack 应按从底到顶返回副本。")
	assert_eq(_ui_utility.get_stack_count(GFUIUtility.Layer.POPUP), 2, "栈数量应可查询。")
	assert_true(_ui_utility.is_panel_open(panel1), "已入栈面板应报告为打开。")

	_ui_utility.pop_panel(GFUIUtility.Layer.POPUP)

	assert_eq(closed, [panel2], "弹出面板应发出关闭信号。")
	assert_eq(navigation_tops.back(), panel1, "弹出后导航信号应报告新的栈顶。")


func test_modal_panel_options_and_cancel_dismiss() -> void:
	var panel := Control.new()
	var dismissed: Array = []
	_ui_utility.panel_dismiss_requested.connect(func(requested_panel: Node, layer: int, reason: String) -> void:
		dismissed.append([requested_panel, layer, reason])
	)

	_ui_utility.push_panel_instance_with_options(panel, GFUIUtility.Layer.POPUP, {
		"modal": true,
		"metadata": {
			"kind": "settings",
		},
	})
	assert_true(_ui_utility.has_modal_open(GFUIUtility.Layer.POPUP), "modal 面板入栈后应可查询。")

	var handled := _ui_utility.request_dismiss_top(GFUIUtility.Layer.POPUP, "cancel")

	assert_true(handled, "默认 modal 面板应允许取消关闭。")
	assert_eq(dismissed, [[panel, GFUIUtility.Layer.POPUP, "cancel"]], "取消请求应发出信号。")
	assert_null(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), "取消关闭后栈顶应为空。")


func test_modal_can_refuse_cancel_dismiss() -> void:
	var panel := Control.new()

	_ui_utility.push_panel_instance_with_options(panel, GFUIUtility.Layer.POPUP, {
		"modal": true,
		"dismiss_on_cancel": false,
	})
	var handled := _ui_utility.request_dismiss_top(GFUIUtility.Layer.POPUP, "cancel")

	assert_false(handled, "禁止取消关闭的 modal 不应被 request_dismiss_top 弹出。")
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel, "拒绝取消后面板应仍在栈顶。")


func test_open_modal_returns_result_and_closes_panel() -> void:
	var confirm := GFModalAction.new()
	confirm.action_id = &"confirm"
	confirm.label = "Confirm"
	confirm.result_status = GFModalResult.STATUS_CONFIRMED
	confirm.payload = { "value": 3 }

	var config := GFModalConfig.new()
	config.title = "Title"
	config.message = "Message"
	config.actions = [confirm]

	var received := { "result": null }
	var panel := _ui_utility.open_modal(config, GFUIUtility.Layer.POPUP, {
		"source": "test",
	}, func(callback_result: GFModalResult) -> void:
		received["result"] = callback_result
	)

	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel, "open_modal 应把默认面板压入 UI 栈。")
	assert_true(panel.resolve_action(&"confirm"), "按动作解析应成功。")

	var received_result := received["result"] as GFModalResult
	assert_not_null(received_result, "结果回调应收到 GFModalResult。")
	assert_eq(received_result.status, GFModalResult.STATUS_CONFIRMED, "结果状态应来自动作配置。")
	assert_eq(received_result.action_id, &"confirm", "结果应记录动作 ID。")
	assert_eq((received_result.payload as Dictionary)["value"], 3, "结果应保留动作载荷。")
	assert_eq((received_result.context as Dictionary)["source"], "test", "结果应保留打开时上下文。")
	assert_null(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), "modal 解析后应从栈中关闭。")


func test_resolved_hidden_modal_detaches_immediately() -> void:
	var confirm := GFModalAction.new()
	confirm.action_id = &"confirm"
	confirm.label = "Confirm"
	confirm.result_status = GFModalResult.STATUS_CONFIRMED

	var config := GFModalConfig.new()
	config.actions = [confirm]
	var panel := _ui_utility.open_modal(config, GFUIUtility.Layer.POPUP)
	var overlay := Control.new()
	_ui_utility.push_panel_instance(overlay, GFUIUtility.Layer.POPUP)

	assert_true(panel.resolve_action(&"confirm"), "被上层面板遮住的 modal 仍应能解析结果。")
	assert_null(panel.get_parent(), "非栈顶 modal 解析后也应立即脱离 UI 层级。")
	assert_false(_ui_utility.is_panel_open(panel, GFUIUtility.Layer.POPUP), "解析后的非栈顶 modal 应从栈中移除。")
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), overlay, "移除非栈顶 modal 不应影响当前栈顶。")

	await get_tree().process_frame
	assert_false(is_instance_valid(panel), "解析后的非栈顶 modal 下一帧应被释放。")


func test_modal_panel_rerender_detaches_old_action_buttons_immediately() -> void:
	var first_action := GFModalAction.new()
	first_action.action_id = &"first"
	first_action.label = "First"
	var second_action := GFModalAction.new()
	second_action.action_id = &"second"
	second_action.label = "Second"
	var first_config := GFModalConfig.new()
	first_config.actions = [first_action, second_action]

	var panel := GFModalPanel.new()
	add_child_autofree(panel)
	await get_tree().process_frame
	panel.configure(first_config)
	var old_buttons := panel._actions_box.get_children()

	var next_action := GFModalAction.new()
	next_action.action_id = &"next"
	next_action.label = "Next"
	var next_config := GFModalConfig.new()
	next_config.actions = [next_action]

	panel.configure(next_config)

	assert_eq(panel._actions_box.get_child_count(), 1, "重新渲染 modal 动作时应立即移除旧按钮。")
	for button: Node in old_buttons:
		assert_null(button.get_parent(), "旧动作按钮应立即脱离 actions 容器。")


func test_request_dismiss_top_resolves_modal_cancel() -> void:
	var config := GFModalConfig.new()
	config.dismiss_on_cancel = true
	var received := { "status": &"" }
	_ui_utility.open_modal(config, GFUIUtility.Layer.POPUP, {}, func(result: GFModalResult) -> void:
		received["status"] = result.status
	)

	var handled := _ui_utility.request_dismiss_top(GFUIUtility.Layer.POPUP, "cancel")

	assert_true(handled, "可取消 modal 应响应 request_dismiss_top。")
	assert_eq(received["status"], GFModalResult.STATUS_CANCELLED, "取消请求应产生 cancelled 结果。")
	assert_null(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), "取消后 modal 应关闭。")


func test_keep_focus_inside_top_modal() -> void:
	var outside := Button.new()
	var panel := Control.new()
	var inside := Button.new()
	outside.focus_mode = Control.FOCUS_ALL
	inside.focus_mode = Control.FOCUS_ALL
	add_child(outside)
	panel.add_child(inside)

	_ui_utility.push_panel_instance_with_options(panel, GFUIUtility.Layer.POPUP, {
		"modal": true,
		"focus_on_open": false,
	})
	outside.grab_focus()
	var corrected := _ui_utility.keep_focus_inside_top_modal(GFUIUtility.Layer.POPUP)

	assert_true(corrected, "焦点落在 modal 外部时应能被拉回 modal 内部。")
	assert_eq(get_viewport().gui_get_focus_owner(), inside, "焦点应移动到 modal 内第一个可聚焦控件。")

	outside.queue_free()


func test_replace_layer_instance_clears_old_stack() -> void:
	var panel1 := Control.new()
	var panel2 := Control.new()
	var replacement := Control.new()

	_ui_utility.push_panel_instance(panel1, GFUIUtility.Layer.POPUP)
	_ui_utility.push_panel_instance(panel2, GFUIUtility.Layer.POPUP)
	_ui_utility.replace_layer_instance(replacement, GFUIUtility.Layer.POPUP)

	assert_eq(_ui_utility.get_stack_count(GFUIUtility.Layer.POPUP), 1, "替换层级后应只保留新面板。")
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), replacement, "替换层级后栈顶应为新面板。")
	assert_null(panel1.get_parent(), "替换层级后旧底层面板应立即脱离 UI 层级。")
	assert_null(panel2.get_parent(), "替换层级后旧顶层面板应立即脱离 UI 层级。")
	assert_eq(replacement.get_parent(), _ui_utility.get_layer_root(GFUIUtility.Layer.POPUP), "替换后层级下应只挂载新面板。")


func test_pop_to_panel_returns_to_existing_panel() -> void:
	var panel1 := Control.new()
	var panel2 := Control.new()
	var panel3 := Control.new()

	_ui_utility.push_panel_instance(panel1, GFUIUtility.Layer.POPUP)
	_ui_utility.push_panel_instance(panel2, GFUIUtility.Layer.POPUP)
	_ui_utility.push_panel_instance(panel3, GFUIUtility.Layer.POPUP)

	var did_pop := _ui_utility.pop_to_panel(panel1, GFUIUtility.Layer.POPUP)

	assert_true(did_pop, "目标面板存在时应成功回退。")
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel1, "回退后目标面板应成为栈顶。")
	assert_eq(_ui_utility.get_stack_count(GFUIUtility.Layer.POPUP), 1, "目标面板上方的面板都应被弹出。")


func test_push_panel_instance_rejects_duplicate_instance() -> void:
	var panel := Control.new()

	_ui_utility.push_panel_instance(panel, GFUIUtility.Layer.POPUP)
	_ui_utility.push_panel_instance(panel, GFUIUtility.Layer.POPUP)

	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel, "重复压入后栈顶仍应是原面板。")
	assert_eq((_ui_utility._panel_stacks[GFUIUtility.Layer.POPUP] as Array).size(), 1, "同一面板实例不应重复进入栈。")
	assert_push_warning("[GFUIUtility] 面板实例已在 UI 栈中，忽略重复入栈。")


func test_push_panel_instance_reparents_external_node() -> void:
	var external_parent := Node.new()
	add_child(external_parent)
	var panel := Control.new()
	external_parent.add_child(panel)

	_ui_utility.push_panel_instance(panel, GFUIUtility.Layer.POPUP)

	assert_eq(panel.get_parent(), _ui_utility.get_layer_root(GFUIUtility.Layer.POPUP), "已挂载面板应迁移到目标 CanvasLayer。")
	assert_false(external_parent.get_children().has(panel), "迁移后原父节点不应继续持有面板。")

	external_parent.queue_free()


func test_push_panel_instance_applies_config_callback() -> void:
	var panel := Control.new()

	_ui_utility.push_panel_instance(panel, GFUIUtility.Layer.POPUP, func(instance: Node) -> void:
		instance.name = "ConfiguredPanel"
	)

	assert_eq(panel.name, "ConfiguredPanel", "已实例化面板入栈前应执行配置回调。")
	assert_eq(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), panel, "配置后的面板应正常入栈。")


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
	assert_null(p1.get_parent(), "清空层级应立即移除旧面板。")
	assert_null(p2.get_parent(), "清空层级应立即移除所有旧面板。")
	assert_eq(_ui_utility.get_layer_root(GFUIUtility.Layer.TOP).get_child_count(), 0, "清空层级后 CanvasLayer 不应继续持有旧面板。")

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


func test_push_panel_async_ignores_late_callback_after_layer_clear() -> void:
	_arch = GFArchitecture.new()
	var asset_util := ManualAssetUtility.new()
	_arch.register_utility_instance(asset_util)
	await Gf.set_architecture(_arch)

	var scene := _make_control_scene()
	_ui_utility.push_panel_async("res://tests/pending_async_panel.tscn", GFUIUtility.Layer.POPUP)
	_ui_utility.clear_layer(GFUIUtility.Layer.POPUP)

	asset_util.resolve("res://tests/pending_async_panel.tscn", scene)
	await get_tree().process_frame

	assert_null(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), "清空层级后的迟到异步回调不应重新压入旧面板。")


func test_push_panel_async_ignores_late_callback_after_pop_cancel() -> void:
	_arch = GFArchitecture.new()
	var asset_util := ManualAssetUtility.new()
	_arch.register_utility_instance(asset_util)
	await Gf.set_architecture(_arch)

	var scene := _make_control_scene()
	_ui_utility.push_panel_async("res://tests/pending_async_panel.tscn", GFUIUtility.Layer.POPUP)
	_ui_utility.pop_panel(GFUIUtility.Layer.POPUP)

	asset_util.resolve("res://tests/pending_async_panel.tscn", scene)
	await get_tree().process_frame

	assert_null(_ui_utility.get_top_panel(GFUIUtility.Layer.POPUP), "pop 取消后的迟到异步回调不应重新压入旧面板。")


func test_duplicate_pending_push_panel_async_is_coalesced() -> void:
	_arch = GFArchitecture.new()
	var asset_util := ManualAssetUtility.new()
	_arch.register_utility_instance(asset_util)
	await Gf.set_architecture(_arch)

	var scene := _make_control_scene()
	_ui_utility.push_panel_async("res://tests/pending_async_panel.tscn", GFUIUtility.Layer.POPUP)
	_ui_utility.push_panel_async("res://tests/pending_async_panel.tscn", GFUIUtility.Layer.POPUP)

	asset_util.resolve("res://tests/pending_async_panel.tscn", scene)
	await get_tree().process_frame

	assert_eq(_ui_utility.get_stack_count(GFUIUtility.Layer.POPUP), 1, "同层同路径的重复异步 push 应只创建一个面板。")


func _make_control_scene() -> PackedScene:
	var control := Control.new()
	var scene := PackedScene.new()
	scene.pack(control)
	control.free()
	return scene
