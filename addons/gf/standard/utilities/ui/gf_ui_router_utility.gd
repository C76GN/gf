## GFUIRouterUtility: 基于路由 ID 的 UI 导航工具。
##
## 作为 GFUIUtility 之上的轻量路由层，负责把稳定 route_id 映射到面板场景、
## 打开参数、层级和历史记录，不接管具体页面业务或动画表现。
class_name GFUIRouterUtility
extends GFUtility


# --- 信号 ---

## 路由打开请求发出时触发。
## @param route_id: 路由标识。
## @param operation: 打开操作。
## @param params: 路由参数。
signal route_open_requested(route_id: StringName, operation: Operation, params: Dictionary)

## 路由面板成功打开后触发。
## @param route_id: 路由标识。
## @param panel: 面板实例。
## @param operation: 打开操作。
signal route_opened(route_id: StringName, panel: Node, operation: Operation)

## 路由打开失败时触发。
## @param route_id: 路由标识。
## @param reason: 失败原因。
signal route_open_failed(route_id: StringName, reason: String)

## 路由返回完成时触发。
## @param route_id: 被弹出的路由标识。
## @param layer: 所在层级。
signal route_back_completed(route_id: StringName, layer: int)


# --- 枚举 ---

## 路由打开操作。
enum Operation {
	## 压入当前层级栈顶。
	PUSH,
	## 替换当前层级栈。
	REPLACE,
}


# --- 常量 ---

const _INSTANCE_GUARD: Script = preload("res://addons/gf/kernel/core/gf_instance_guard.gd")


# --- 公共变量 ---

## 路由历史最大保留数量。小于等于 0 表示不保留历史。
var max_history: int = 64


# --- 私有变量 ---

var _routes: Dictionary = {}
var _ui_utility_ref: WeakRef = null
var _history: Array[Dictionary] = []


# --- Godot 生命周期方法 ---

func init() -> void:
	_routes.clear()
	_ui_utility_ref = null
	_history.clear()


func dispose() -> void:
	_routes.clear()
	_ui_utility_ref = null
	_history.clear()


# --- 公共方法 ---

## 配置路由表和可选 UI 工具实例。
## @param routes: 路由资源列表。
## @param ui_utility: 可选 GFUIUtility；为空时从当前架构查找。
func configure(routes: Array[GFUIRoute] = [], ui_utility: GFUIUtility = null) -> void:
	_routes.clear()
	for route: GFUIRoute in routes:
		register_route(route)
	set_ui_utility(ui_utility)


## 设置路由使用的 UI 栈工具。
## @param ui_utility: UI 栈工具实例。
func set_ui_utility(ui_utility: GFUIUtility) -> void:
	_ui_utility_ref = weakref(ui_utility) if ui_utility != null else null


## 注册一个路由。
## @param route: 路由资源。
## @return 注册成功返回 true。
func register_route(route: GFUIRoute) -> bool:
	if route == null or not route.is_valid_route():
		return false

	_routes[route.get_route_id()] = route
	return true


## 批量注册路由。
## @param routes: 路由资源列表。
func register_routes(routes: Array[GFUIRoute]) -> void:
	for route: GFUIRoute in routes:
		register_route(route)


## 注销路由。
## @param route_id: 路由标识。
func unregister_route(route_id: StringName) -> void:
	_routes.erase(route_id)


## 清空路由表。
func clear_routes() -> void:
	_routes.clear()


## 获取路由资源。
## @param route_id: 路由标识。
## @return 路由资源；不存在时返回 null。
func get_route(route_id: StringName) -> GFUIRoute:
	return _routes.get(route_id) as GFUIRoute


## 检查路由是否已注册。
## @param route_id: 路由标识。
## @return 已注册返回 true。
func has_route(route_id: StringName) -> bool:
	return get_route(route_id) != null


## 获取所有路由标识。
## @return 路由标识列表。
func get_route_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for key: Variant in _routes.keys():
		ids.append(String(key))
	ids.sort()
	return ids


## 压入一个路由面板。
## @param route_id: 路由标识。
## @param params: 路由参数。
## @param option_overrides: 面板选项覆盖。
## @param config_callback: 面板实例化后、入栈前的额外配置回调。
## @return 成功时返回面板实例。
func push_route(
	route_id: StringName,
	params: Dictionary = {},
	option_overrides: Dictionary = {},
	config_callback: Callable = Callable()
) -> Node:
	return _open_route(route_id, Operation.PUSH, params, option_overrides, config_callback)


## 替换路由所在层级。
## @param route_id: 路由标识。
## @param params: 路由参数。
## @param option_overrides: 面板选项覆盖。
## @param config_callback: 面板实例化后、入栈前的额外配置回调。
## @return 成功时返回面板实例。
func replace_route(
	route_id: StringName,
	params: Dictionary = {},
	option_overrides: Dictionary = {},
	config_callback: Callable = Callable()
) -> Node:
	return _open_route(route_id, Operation.REPLACE, params, option_overrides, config_callback)


## 异步压入一个路由面板。
## @param route_id: 路由标识。
## @param params: 路由参数。
## @param option_overrides: 面板选项覆盖。
## @param config_callback: 面板实例化后、入栈前的额外配置回调。
func push_route_async(
	route_id: StringName,
	params: Dictionary = {},
	option_overrides: Dictionary = {},
	config_callback: Callable = Callable()
) -> void:
	_open_route_async(route_id, Operation.PUSH, params, option_overrides, config_callback)


## 异步替换路由所在层级。
## @param route_id: 路由标识。
## @param params: 路由参数。
## @param option_overrides: 面板选项覆盖。
## @param config_callback: 面板实例化后、入栈前的额外配置回调。
func replace_route_async(
	route_id: StringName,
	params: Dictionary = {},
	option_overrides: Dictionary = {},
	config_callback: Callable = Callable()
) -> void:
	_open_route_async(route_id, Operation.REPLACE, params, option_overrides, config_callback)


## 返回上一层路由。
## @param layer: 指定层级；小于 0 时使用最近的历史记录。
## @param do_free: 是否释放被弹出的面板。
## @return 成功返回 true。
func back(layer: int = -1, do_free: bool = true) -> bool:
	_prune_history()
	var history_index := _find_top_history_index(layer)
	if history_index < 0:
		return false

	var entry := _history[history_index]
	var ui_utility := _get_ui_utility()
	if ui_utility == null:
		return false

	var route_id := StringName(entry.get("route_id", &""))
	var route_layer := int(entry.get("layer", GFUIUtility.Layer.POPUP))
	var route_panel := _get_history_panel(entry)
	if route_panel == null or ui_utility.get_top_panel(route_layer as GFUIUtility.Layer) != route_panel:
		push_warning("[GFUIRouterUtility] back 失败：路由面板不是当前 UI 栈顶。")
		return false

	ui_utility.pop_panel(route_layer as GFUIUtility.Layer, do_free)
	_history.remove_at(history_index)
	_prune_history()
	route_back_completed.emit(route_id, route_layer)
	return true


## 获取当前路由标识。
## @param layer: 指定层级；小于 0 时返回最近路由。
## @return 当前路由标识；没有时返回空 StringName。
func get_current_route_id(layer: int = -1) -> StringName:
	_prune_history()
	var history_index := _find_top_history_index(layer)
	if history_index < 0:
		return &""
	return StringName(_history[history_index].get("route_id", &""))


## 获取路由历史副本。
## @return 从旧到新的历史条目。
func get_route_history() -> Array[Dictionary]:
	_prune_history()
	var result: Array[Dictionary] = []
	for entry: Dictionary in _history:
		result.append(_make_public_history_entry(entry))
	return result


## 清空路由历史，不影响已打开面板。
func clear_history() -> void:
	_history.clear()


## 获取路由诊断快照。
## @return 诊断快照。
func get_debug_snapshot() -> Dictionary:
	_prune_history()
	return {
		"route_count": _routes.size(),
		"history_count": _history.size(),
		"current_route_id": String(get_current_route_id()),
		"has_ui_utility": _get_ui_utility() != null,
	}


# --- 私有/辅助方法 ---

func _open_route(
	route_id: StringName,
	operation: Operation,
	params: Dictionary,
	option_overrides: Dictionary,
	config_callback: Callable
) -> Node:
	var route := _resolve_route_or_fail(route_id)
	if route == null:
		return null

	var ui_utility := _get_ui_utility()
	if ui_utility == null:
		_fail_route(route_id, "missing_ui_utility")
		return null

	route_open_requested.emit(route_id, operation, params.duplicate(true))
	var options := route.build_options(params, option_overrides)
	var wrapped_callback := _make_route_config_callback(route, params, config_callback, operation)
	var panel: Node = null
	if operation == Operation.REPLACE:
		_remove_history_for_layer(route.layer)
		panel = ui_utility.replace_layer_with_options(
			route.scene_path,
			route.layer as GFUIUtility.Layer,
			options,
			wrapped_callback
		)
	else:
		panel = ui_utility.push_panel_with_options(
			route.scene_path,
			route.layer as GFUIUtility.Layer,
			options,
			wrapped_callback
		)

	if panel == null:
		_fail_route(route_id, "panel_open_failed")
		return null

	_record_route_open(route, panel, params, operation)
	return panel


func _open_route_async(
	route_id: StringName,
	operation: Operation,
	params: Dictionary,
	option_overrides: Dictionary,
	config_callback: Callable
) -> void:
	var route := _resolve_route_or_fail(route_id)
	if route == null:
		return

	var ui_utility := _get_ui_utility()
	if ui_utility == null:
		_fail_route(route_id, "missing_ui_utility")
		return

	route_open_requested.emit(route_id, operation, params.duplicate(true))
	var options := route.build_options(params, option_overrides)
	var wrapped_callback := _make_route_config_callback(route, params, config_callback, operation)
	if operation == Operation.REPLACE:
		_remove_history_for_layer(route.layer)
		ui_utility.replace_layer_async_with_options(
			route.scene_path,
			route.layer as GFUIUtility.Layer,
			options,
			wrapped_callback
		)
	else:
		ui_utility.push_panel_async_with_options(
			route.scene_path,
			route.layer as GFUIUtility.Layer,
			options,
			wrapped_callback
		)


func _resolve_route_or_fail(route_id: StringName) -> GFUIRoute:
	var route := get_route(route_id)
	if route == null:
		_fail_route(route_id, "missing_route")
		return null
	if not route.is_valid_route():
		_fail_route(route_id, "invalid_route")
		return null
	return route


func _fail_route(route_id: StringName, reason: String) -> void:
	route_open_failed.emit(route_id, reason)
	push_warning("[GFUIRouterUtility] 路由打开失败：%s (%s)" % [String(route_id), reason])


func _make_route_config_callback(
	route: GFUIRoute,
	params: Dictionary,
	config_callback: Callable,
	operation: Operation
) -> Callable:
	return func(panel: Node) -> void:
		_apply_route_params(panel, route, params)
		if config_callback.is_valid():
			config_callback.call(panel)
		if is_instance_valid(panel):
			call_deferred("_record_async_open_if_needed", route, panel, params.duplicate(true), operation)


func _apply_route_params(panel: Node, route: GFUIRoute, params: Dictionary) -> void:
	if not is_instance_valid(panel):
		return
	if panel.has_method("set_route_params"):
		panel.call("set_route_params", params.duplicate(true))
	if panel.has_method("set_route_metadata"):
		panel.call("set_route_metadata", route.metadata.duplicate(true))


func _record_async_open_if_needed(
	route: GFUIRoute,
	panel: Node,
	params: Dictionary,
	operation: Operation
) -> void:
	if route == null or not is_instance_valid(panel):
		return
	var ui_utility := _get_ui_utility()
	if ui_utility == null or not ui_utility.is_panel_open(panel, route.layer):
		return
	if _history_has_panel(panel):
		return
	_record_route_open(route, panel, params, operation)


func _record_route_open(
	route: GFUIRoute,
	panel: Node,
	params: Dictionary,
	operation: Operation
) -> void:
	if max_history <= 0:
		route_opened.emit(route.get_route_id(), panel, operation)
		return

	_prune_history()
	_history.append({
		"route_id": route.get_route_id(),
		"layer": route.layer,
		"panel_ref": weakref(panel),
		"params": params.duplicate(true),
		"metadata": route.metadata.duplicate(true),
	})
	while _history.size() > max_history:
		_history.remove_at(0)
	route_opened.emit(route.get_route_id(), panel, operation)


func _prune_history() -> void:
	var ui_utility := _get_ui_utility()
	for index: int in range(_history.size() - 1, -1, -1):
		var entry := _history[index]
		var panel := _get_history_panel(entry)
		var layer := int(entry.get("layer", GFUIUtility.Layer.POPUP))
		if panel == null or (ui_utility != null and not ui_utility.is_panel_open(panel, layer)):
			_history.remove_at(index)


func _find_top_history_index(layer: int = -1) -> int:
	for index: int in range(_history.size() - 1, -1, -1):
		if layer < 0 or int(_history[index].get("layer", -1)) == layer:
			return index
	return -1


func _remove_history_for_layer(layer: int) -> void:
	for index: int in range(_history.size() - 1, -1, -1):
		if int(_history[index].get("layer", -1)) == layer:
			_history.remove_at(index)


func _history_has_panel(panel: Node) -> bool:
	for entry: Dictionary in _history:
		if _get_history_panel(entry) == panel:
			return true
	return false


func _get_history_panel(entry: Dictionary) -> Node:
	var panel_ref := entry.get("panel_ref") as WeakRef
	if panel_ref == null:
		return null
	return _INSTANCE_GUARD._get_live_node_from_ref(panel_ref)


func _make_public_history_entry(entry: Dictionary) -> Dictionary:
	return {
		"route_id": entry.get("route_id", &""),
		"layer": int(entry.get("layer", GFUIUtility.Layer.POPUP)),
		"panel": _get_history_panel(entry),
		"params": (entry.get("params", {}) as Dictionary).duplicate(true),
		"metadata": (entry.get("metadata", {}) as Dictionary).duplicate(true),
	}


func _get_ui_utility() -> GFUIUtility:
	if _ui_utility_ref != null:
		var ui_utility := _ui_utility_ref.get_ref() as GFUIUtility
		if ui_utility != null:
			return ui_utility

	var architecture := _get_architecture_or_null()
	if architecture == null:
		return null
	return architecture.get_utility(GFUIUtility) as GFUIUtility
