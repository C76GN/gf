## 测试 GFUIRouterUtility 的路由注册、打开、替换与返回行为。
extends GutTest


# --- 常量 ---

const _PANEL_SCENE_PATH := "res://tests/gf_core/fixtures/scene_signal_audit_valid.tscn"


# --- 私有变量 ---

var _ui_utility: GFUIUtility
var _router: GFUIRouterUtility


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_ui_utility = GFUIUtility.new()
	_ui_utility.init()
	_router = GFUIRouterUtility.new()
	_router.init()
	_router.set_ui_utility(_ui_utility)
	await get_tree().process_frame


func after_each() -> void:
	if _router != null:
		_router.dispose()
		_router = null
	if _ui_utility != null:
		_ui_utility.dispose()
		_ui_utility = null
	await get_tree().process_frame


# --- 测试方法 ---

func test_push_route_records_history_and_options_metadata() -> void:
	var route := _make_route(&"settings", GFUIUtility.Layer.POPUP)
	route.metadata = { "section": "options" }
	assert_true(_router.register_route(route), "有效路由应可注册。")

	var panel := _router.push_route(&"settings", { "tab": "audio" })
	var options := _ui_utility.get_panel_options(panel)
	var metadata := options["metadata"] as Dictionary

	assert_not_null(panel, "push_route 应返回打开的面板。")
	assert_eq(_router.get_current_route_id(), &"settings", "当前路由应写入历史。")
	assert_eq(metadata["route_id"], &"settings", "面板选项应包含 route_id 元数据。")
	assert_eq((metadata["route_params"] as Dictionary)["tab"], "audio", "面板选项应包含路由参数。")
	assert_eq(metadata["section"], "options", "路由元数据应被透传。")


func test_back_pops_current_route() -> void:
	_router.register_route(_make_route(&"inventory", GFUIUtility.Layer.POPUP))
	_router.push_route(&"inventory")
	assert_eq(_ui_utility.get_stack_count(GFUIUtility.Layer.POPUP), 1, "打开路由后层级应有面板。")

	var handled := _router.back()

	assert_true(handled, "存在历史时 back 应成功。")
	assert_eq(_ui_utility.get_stack_count(GFUIUtility.Layer.POPUP), 0, "back 应弹出当前面板。")
	assert_eq(_router.get_current_route_id(), &"", "弹出后当前路由应为空。")


func test_replace_route_clears_same_layer_history() -> void:
	_router.register_route(_make_route(&"first", GFUIUtility.Layer.POPUP))
	_router.register_route(_make_route(&"second", GFUIUtility.Layer.POPUP))
	_router.push_route(&"first")
	_router.replace_route(&"second")

	var history := _router.get_route_history()

	assert_eq(history.size(), 1, "替换层级后同层历史应只保留新路由。")
	assert_eq(history[0]["route_id"], &"second", "替换后历史应指向新路由。")
	assert_eq(_ui_utility.get_stack_count(GFUIUtility.Layer.POPUP), 1, "替换层级后 UI 栈应只保留一个面板。")


func test_missing_route_emits_failure() -> void:
	watch_signals(_router)

	var panel := _router.push_route(&"missing")

	assert_null(panel, "缺失路由不应打开面板。")
	assert_signal_emitted(_router, "route_open_failed", "缺失路由应发出失败信号。")
	assert_push_warning("[GFUIRouterUtility] 路由打开失败：missing (missing_route)")


# --- 私有/辅助方法 ---

func _make_route(route_id: StringName, layer: int) -> GFUIRoute:
	var route := GFUIRoute.new()
	route.route_id = route_id
	route.scene_path = _PANEL_SCENE_PATH
	route.layer = layer
	return route
