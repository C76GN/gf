## GFUIUtility: 栈式 UI 管理器。
##
## 负责多层级界面的入栈、出栈与异步加载，
## 适合 HUD、弹窗和顶层遮罩等需要分层管理的 UI 场景。
class_name GFUIUtility
extends GFUtility


# --- 信号 ---

## 面板成功进入 UI 栈后发出。
## @param panel: 面板实例。
## @param layer: 目标层级。
signal panel_opened(panel: Node, layer: int)

## 面板离开 UI 栈后发出。
## @param panel: 面板实例。
## @param layer: 原层级。
signal panel_closed(panel: Node, layer: int)

## 指定层级的栈顶面板变化后发出。
## @param layer: 发生变化的层级。
## @param top_panel: 新栈顶面板；层级为空时为 null。
signal navigation_changed(layer: int, top_panel: Node)

## 面板请求被取消或关闭时发出。
## @param panel: 请求关闭的面板。
## @param layer: 所在层级。
## @param reason: 关闭原因。
signal panel_dismiss_requested(panel: Node, layer: int, reason: String)


# --- 枚举 ---

## UI 层级，数值越大显示越靠前。
enum Layer {
	## 基础信息层，如主界面、血条 HUD 等。
	HUD = 0,
	## 弹窗层，如背包、设置菜单、对话框等。
	POPUP = 1,
	## 顶层，如全屏遮罩、断线重连提示等。
	TOP = 2,
}

## 面板交互模式。
enum PanelMode {
	## 普通面板。
	NORMAL,
	## Modal 面板，通常会独占当前交互焦点。
	MODAL,
}


# --- 私有变量 ---

## 各层级的 CanvasLayer 根节点。
var _layer_roots: Dictionary = {}

## 各层级的面板栈。
var _panel_stacks: Dictionary = {
	Layer.HUD: [],
	Layer.POPUP: [],
	Layer.TOP: [],
}

## 是否自动隐藏同层级下方的面板。
var _auto_hide_under: bool = true

## Utility 生命周期标记，防止异步回调落到已销毁实例上。
var _is_active: bool = false

## 面板实例 id 到策略选项的映射。
var _panel_options: Dictionary = {}

## 面板实例 id 到打开前焦点控件的映射。
var _previous_focus_by_panel_id: Dictionary = {}


# --- Godot 生命周期方法 ---

func init() -> void:
	_is_active = true
	_create_layers()


func dispose() -> void:
	_is_active = false
	for canvas: CanvasLayer in _layer_roots.values():
		if is_instance_valid(canvas):
			canvas.queue_free()
	_layer_roots.clear()

	for stack: Array in _panel_stacks.values():
		stack.clear()
	_panel_options.clear()
	_previous_focus_by_panel_id.clear()


# --- 公共方法 ---

## 配置 UI 管理器。
## @param auto_hide_under: 压入新面板时是否自动隐藏下层面板。
func configure(auto_hide_under: bool = true) -> void:
	_auto_hide_under = auto_hide_under


## 异步压入一个面板场景。
## @param path: 面板场景路径。
## @param layer: 目标层级。
## @param config_callback: 实例化后、入栈前的可选配置回调。
func push_panel_async(path: String, layer: Layer = Layer.POPUP, config_callback: Callable = Callable()) -> void:
	push_panel_async_with_options(path, layer, {}, config_callback)


## 异步压入一个带策略选项的面板场景。
## @param path: 面板场景路径。
## @param layer: 目标层级。
## @param options: 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。
## @param config_callback: 实例化后、入栈前的可选配置回调。
func push_panel_async_with_options(
	path: String,
	layer: Layer = Layer.POPUP,
	options: Dictionary = {},
	config_callback: Callable = Callable()
) -> void:
	var asset_util := _get_asset_util()
	if asset_util == null:
		push_warning("[GFUIUtility] GFAssetUtility 未注册，回退为同步加载。")
		push_panel_with_options(path, layer, options, config_callback)
		return

	var on_loaded := func(res: Resource) -> void:
		if not _is_active:
			return

		var scene := res as PackedScene
		if scene == null:
			push_error("[GFUIUtility] 无法实例化面板场景：%s" % path)
			return

		var panel_instance: Node = scene.instantiate()
		if not _add_panel_instance(panel_instance, layer, config_callback, options) and is_instance_valid(panel_instance):
			panel_instance.queue_free()

	asset_util.load_async(path, on_loaded, "PackedScene")


## 同步压入一个面板场景。
## @param path: 面板场景路径。
## @param layer: 目标层级。
## @param config_callback: 实例化后、入栈前的可选配置回调。
## @return 成功时返回面板实例，失败时返回 `null`。
func push_panel(path: String, layer: Layer = Layer.POPUP, config_callback: Callable = Callable()) -> Node:
	return push_panel_with_options(path, layer, {}, config_callback)


## 同步压入一个带策略选项的面板场景。
## @param path: 面板场景路径。
## @param layer: 目标层级。
## @param options: 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。
## @param config_callback: 实例化后、入栈前的可选配置回调。
## @return 成功时返回面板实例，失败时返回 `null`。
func push_panel_with_options(
	path: String,
	layer: Layer = Layer.POPUP,
	options: Dictionary = {},
	config_callback: Callable = Callable()
) -> Node:
	var scene := load(path) as PackedScene
	if scene == null:
		push_error("[GFUIUtility] 无法加载面板场景：%s" % path)
		return null

	var panel_instance: Node = scene.instantiate()
	if not _add_panel_instance(panel_instance, layer, config_callback, options):
		if is_instance_valid(panel_instance):
			panel_instance.queue_free()
		return null

	return panel_instance


## 同步替换指定层级的面板栈。
## @param path: 面板场景路径。
## @param layer: 目标层级。
## @param config_callback: 实例化后、入栈前的可选配置回调。
## @return 成功时返回面板实例，失败时返回 `null`。
func replace_layer(path: String, layer: Layer = Layer.POPUP, config_callback: Callable = Callable()) -> Node:
	return replace_layer_with_options(path, layer, {}, config_callback)


## 同步替换指定层级为带策略选项的面板。
## @param path: 面板场景路径。
## @param layer: 目标层级。
## @param options: 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。
## @param config_callback: 实例化后、入栈前的可选配置回调。
## @return 成功时返回面板实例，失败时返回 `null`。
func replace_layer_with_options(
	path: String,
	layer: Layer = Layer.POPUP,
	options: Dictionary = {},
	config_callback: Callable = Callable()
) -> Node:
	var scene := load(path) as PackedScene
	if scene == null:
		push_error("[GFUIUtility] 无法加载面板场景：%s" % path)
		return null

	var panel_instance: Node = scene.instantiate()
	clear_layer(layer)
	if not _add_panel_instance(panel_instance, layer, config_callback, options):
		if is_instance_valid(panel_instance):
			panel_instance.queue_free()
		return null

	return panel_instance


## 异步替换指定层级的面板栈。
## @param path: 面板场景路径。
## @param layer: 目标层级。
## @param config_callback: 实例化后、入栈前的可选配置回调。
func replace_layer_async(path: String, layer: Layer = Layer.POPUP, config_callback: Callable = Callable()) -> void:
	replace_layer_async_with_options(path, layer, {}, config_callback)


## 异步替换指定层级为带策略选项的面板。
## @param path: 面板场景路径。
## @param layer: 目标层级。
## @param options: 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。
## @param config_callback: 实例化后、入栈前的可选配置回调。
func replace_layer_async_with_options(
	path: String,
	layer: Layer = Layer.POPUP,
	options: Dictionary = {},
	config_callback: Callable = Callable()
) -> void:
	var asset_util := _get_asset_util()
	if asset_util == null:
		push_warning("[GFUIUtility] GFAssetUtility 未注册，回退为同步加载。")
		replace_layer_with_options(path, layer, options, config_callback)
		return

	var on_loaded := func(res: Resource) -> void:
		if not _is_active:
			return

		var scene := res as PackedScene
		if scene == null:
			push_error("[GFUIUtility] 无法实例化面板场景：%s" % path)
			return

		var panel_instance: Node = scene.instantiate()
		clear_layer(layer)
		if not _add_panel_instance(panel_instance, layer, config_callback, options) and is_instance_valid(panel_instance):
			panel_instance.queue_free()

	asset_util.load_async(path, on_loaded, "PackedScene")


## 压入一个已实例化的面板节点。
## @param panel_instance: 面板实例。
## @param layer: 目标层级。
## @param config_callback: 入栈前的可选配置回调。
func push_panel_instance(
	panel_instance: Node,
	layer: Layer = Layer.POPUP,
	config_callback: Callable = Callable()
) -> void:
	push_panel_instance_with_options(panel_instance, layer, {}, config_callback)


## 压入一个已实例化且带策略选项的面板节点。
## @param panel_instance: 面板实例。
## @param layer: 目标层级。
## @param options: 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。
## @param config_callback: 入栈前的可选配置回调。
func push_panel_instance_with_options(
	panel_instance: Node,
	layer: Layer = Layer.POPUP,
	options: Dictionary = {},
	config_callback: Callable = Callable()
) -> void:
	if not is_instance_valid(panel_instance):
		push_error("[GFUIUtility] 传入的 panel_instance 无效。")
		return

	_add_panel_instance(panel_instance, layer, config_callback, options)


## 用已实例化面板替换指定层级的面板栈。
## @param panel_instance: 面板实例。
## @param layer: 目标层级。
## @param config_callback: 入栈前的可选配置回调。
func replace_layer_instance(
	panel_instance: Node,
	layer: Layer = Layer.POPUP,
	config_callback: Callable = Callable()
) -> void:
	replace_layer_instance_with_options(panel_instance, layer, {}, config_callback)


## 用已实例化且带策略选项的面板替换指定层级的面板栈。
## @param panel_instance: 面板实例。
## @param layer: 目标层级。
## @param options: 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。
## @param config_callback: 入栈前的可选配置回调。
func replace_layer_instance_with_options(
	panel_instance: Node,
	layer: Layer = Layer.POPUP,
	options: Dictionary = {},
	config_callback: Callable = Callable()
) -> void:
	if not is_instance_valid(panel_instance):
		push_error("[GFUIUtility] 传入的 panel_instance 无效。")
		return

	clear_layer(layer)
	push_panel_instance_with_options(panel_instance, layer, options, config_callback)


## 打开一个 GF 默认 modal 面板。
## @param config: modal 配置；为空时使用默认配置。
## @param layer: 目标层级。
## @param context: 调用上下文，会透传到 GFModalResult。
## @param result_callback: 可选结果回调，签名建议为 func(result: GFModalResult)。
## @return 打开的 modal 面板。
func open_modal(
	config: GFModalConfig,
	layer: Layer = Layer.POPUP,
	context: Dictionary = {},
	result_callback: Callable = Callable()
) -> GFModalPanel:
	var modal_config := config.duplicate_config() if config != null else GFModalConfig.new()
	var panel := GFModalPanel.new()
	panel.configure(modal_config, context)
	panel.resolved.connect(_on_modal_resolved.bind(panel, layer, result_callback), CONNECT_ONE_SHOT)
	push_panel_instance_with_options(panel, layer, {
		"mode": PanelMode.MODAL,
		"dismiss_on_cancel": modal_config.dismiss_on_cancel,
		"focus_on_open": modal_config.auto_focus,
		"restore_focus_on_close": modal_config.restore_focus_on_close,
		"metadata": modal_config.metadata,
	})
	return panel


## 弹出指定层级的顶部面板。
## @param layer: 目标层级。
## @param do_free: 是否在弹出后释放面板。
func pop_panel(layer: Layer = Layer.POPUP, do_free: bool = true) -> void:
	_prune_layer_stack(layer)
	var stack: Array = _panel_stacks[layer]
	if stack.is_empty():
		return

	var top_panel: Node = stack.pop_back()
	if is_instance_valid(top_panel):
		if do_free:
			top_panel.queue_free()
		elif top_panel.get_parent() != null:
			top_panel.get_parent().remove_child(top_panel)
		_handle_panel_closed(top_panel)
		panel_closed.emit(top_panel, layer)

	if _auto_hide_under:
		_reveal_top_panel(layer)
	_emit_navigation_changed(layer)


## 弹出面板直到指定面板成为栈顶。
## @param panel: 目标面板实例。
## @param layer: 目标层级。
## @param do_free: 是否释放被弹出的面板。
## @return 找到目标面板并完成回退时返回 true。
func pop_to_panel(panel: Node, layer: Layer = Layer.POPUP, do_free: bool = true) -> bool:
	if not is_instance_valid(panel):
		return false

	_prune_layer_stack(layer)
	var stack: Array = _panel_stacks[layer]
	if not stack.has(panel):
		return false

	while get_top_panel(layer) != panel:
		pop_panel(layer, do_free)
	return true


## 清空指定层级的所有面板。
## @param layer: 目标层级。
func clear_layer(layer: Layer) -> void:
	_prune_layer_stack(layer)
	var stack: Array = _panel_stacks[layer]
	while not stack.is_empty():
		var panel: Node = stack.pop_back()
		if is_instance_valid(panel):
			_handle_panel_closed(panel)
			panel_closed.emit(panel, layer)
			panel.queue_free()
	_emit_navigation_changed(layer)


## 清空所有层级的所有面板。
func clear_all() -> void:
	for layer_idx: int in _panel_stacks.keys():
		clear_layer(layer_idx as Layer)


## 获取指定层级的顶部面板。
## @param layer: 目标层级。
## @return 栈顶面板；为空时返回 `null`。
func get_top_panel(layer: Layer = Layer.POPUP) -> Node:
	_prune_layer_stack(layer)
	var stack: Array = _panel_stacks[layer]
	if stack.is_empty():
		return null

	return stack.back()


## 获取指定层级当前面板栈的副本。
## @param layer: 目标层级。
## @return 从底到顶排列的面板列表。
func get_panel_stack(layer: Layer = Layer.POPUP) -> Array[Node]:
	_prune_layer_stack(layer)
	var result: Array[Node] = []
	var stack: Array = _panel_stacks[layer]
	for panel: Node in stack:
		if is_instance_valid(panel):
			result.append(panel)
	return result


## 获取指定层级当前面板数量。
## @param layer: 目标层级。
## @return 面板数量。
func get_stack_count(layer: Layer = Layer.POPUP) -> int:
	return get_panel_stack(layer).size()


## 检查面板是否已进入 UI 栈。
## @param panel: 面板实例。
## @param layer: 指定层级；小于 0 时检查所有层级。
## @return 面板已打开时返回 true。
func is_panel_open(panel: Node, layer: int = -1) -> bool:
	if not is_instance_valid(panel):
		return false

	_prune_all_layer_stacks()
	if layer >= 0:
		return _panel_stacks.has(layer) and (_panel_stacks[layer] as Array).has(panel)

	return _is_panel_in_any_stack(panel)


## 获取 UI 管理器诊断快照。
## @return 包含各层级栈数量和栈顶名称的字典。
func get_debug_snapshot() -> Dictionary:
	var layers: Dictionary = {}
	for layer_idx: int in _panel_stacks.keys():
		_prune_layer_stack(layer_idx as Layer)
		var top_panel := get_top_panel(layer_idx as Layer)
		layers[layer_idx] = {
			"count": (_panel_stacks[layer_idx] as Array).size(),
			"top_panel": top_panel.name if top_panel != null else "",
			"top_modal": is_panel_modal(top_panel) if top_panel != null else false,
		}
	return {
		"active": _is_active,
		"auto_hide_under": _auto_hide_under,
		"layers": layers,
	}


## 获取指定层级的 CanvasLayer。
## @param layer: 目标层级。
## @return 对应的 `CanvasLayer` 实例。
func get_layer_root(layer: Layer) -> CanvasLayer:
	return _layer_roots.get(layer) as CanvasLayer


## 设置已打开面板的策略选项。
## @param panel: 面板实例。
## @param options: 面板策略，支持 mode、modal、dismiss_on_cancel、focus_on_open、restore_focus_on_close、metadata。
func set_panel_options(panel: Node, options: Dictionary) -> void:
	if not is_instance_valid(panel):
		return
	_panel_options[panel.get_instance_id()] = _normalize_panel_options(options)


## 获取面板策略选项。
## @param panel: 面板实例。
## @return 策略选项副本。
func get_panel_options(panel: Node) -> Dictionary:
	if not is_instance_valid(panel):
		return {}
	return (_panel_options.get(panel.get_instance_id(), {}) as Dictionary).duplicate(true)


## 判断面板是否按 modal 策略管理。
## @param panel: 面板实例。
## @return 是 modal 面板时返回 true。
func is_panel_modal(panel: Node) -> bool:
	if not is_instance_valid(panel):
		return false
	var options := _panel_options.get(panel.get_instance_id(), {}) as Dictionary
	if options == null:
		return false
	return int(options.get("mode", PanelMode.NORMAL)) == PanelMode.MODAL


## 检查是否存在打开的 modal 面板。
## @param layer: 指定层级；小于 0 时检查所有层级。
## @return 存在 modal 面板时返回 true。
func has_modal_open(layer: int = -1) -> bool:
	if layer >= 0:
		return _count_modals_in_layer(layer as Layer) > 0

	for layer_idx: int in _panel_stacks.keys():
		if _count_modals_in_layer(layer_idx as Layer) > 0:
			return true
	return false


## 获取打开的 modal 面板数量。
## @param layer: 指定层级；小于 0 时统计所有层级。
## @return modal 面板数量。
func get_modal_count(layer: int = -1) -> int:
	if layer >= 0:
		return _count_modals_in_layer(layer as Layer)

	var count := 0
	for layer_idx: int in _panel_stacks.keys():
		count += _count_modals_in_layer(layer_idx as Layer)
	return count


## 按顶层优先顺序处理取消请求。
## @param layer: 指定层级；小于 0 时从最高层级开始查找。
## @param reason: 关闭原因。
## @return 找到可取消面板并处理时返回 true。
func request_dismiss_top(layer: int = -1, reason: String = "cancel") -> bool:
	if layer >= 0:
		return _request_dismiss_layer(layer as Layer, reason)

	var layer_values := Layer.values()
	layer_values.sort()
	for index: int in range(layer_values.size() - 1, -1, -1):
		if _request_dismiss_layer(layer_values[index] as Layer, reason):
			return true
	return false


## 尝试把焦点保持在指定层级栈顶 modal 面板内。
## @param layer: 目标层级。
## @return 发生焦点修正时返回 true。
func keep_focus_inside_top_modal(layer: Layer = Layer.POPUP) -> bool:
	var top_panel := get_top_panel(layer)
	if not is_panel_modal(top_panel):
		return false
	var viewport := top_panel.get_viewport()
	if viewport == null:
		return false
	var focused := viewport.gui_get_focus_owner()
	if focused != null and _is_descendant_of(focused, top_panel):
		return false
	return _focus_first_control(top_panel)


# --- 私有/辅助方法 ---

func _create_layers() -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		push_error("[GFUIUtility] 无法获取 SceneTree。")
		return

	var root := scene_tree.root
	for layer_idx: int in Layer.values():
		var canvas := CanvasLayer.new()
		canvas.layer = 50 + layer_idx * 10
		canvas.name = "GFUILayer_" + str(Layer.keys()[layer_idx])
		root.call_deferred("add_child", canvas)
		_layer_roots[layer_idx] = canvas


func _add_panel_instance(
	panel: Node,
	layer: Layer,
	config_callback: Callable,
	options: Dictionary = {}
) -> bool:
	if not _is_active:
		push_warning("[GFUIUtility] 当前 UI 管理器已销毁，忽略面板入栈。")
		return false

	var canvas := _layer_roots.get(layer) as CanvasLayer
	if not is_instance_valid(canvas):
		push_error("[GFUIUtility] 目标层级的 CanvasLayer 不可用。")
		return false

	_prune_all_layer_stacks()
	if _is_panel_in_any_stack(panel):
		push_warning("[GFUIUtility] 面板实例已在 UI 栈中，忽略重复入栈。")
		return false

	_prune_layer_stack(layer)
	var stack: Array = _panel_stacks[layer]
	var normalized_options := _normalize_panel_options(options)
	var hidden_panel: CanvasItem = null
	if _auto_hide_under and not stack.is_empty():
		var old_top: Node = stack.back()
		if is_instance_valid(old_top) and old_top is CanvasItem:
			hidden_panel = old_top as CanvasItem
			hidden_panel.visible = false

	if config_callback.is_valid():
		config_callback.call(panel)
		if not is_instance_valid(panel):
			_restore_hidden_panel(hidden_panel)
			push_warning("[GFUIUtility] config_callback 销毁了面板实例，本次入栈已取消。")
			return false

	_capture_previous_focus(panel, normalized_options)
	stack.push_back(panel)
	_panel_options[panel.get_instance_id()] = normalized_options
	panel.tree_exited.connect(_on_panel_tree_exited.bind(panel, layer), CONNECT_ONE_SHOT)
	if panel.get_parent() != null and panel.get_parent() != canvas:
		panel.get_parent().remove_child(panel)
	if panel.get_parent() != canvas:
		canvas.add_child(panel)
	_apply_open_focus_policy(panel, normalized_options)
	panel_opened.emit(panel, layer)
	_emit_navigation_changed(layer)
	return true


func _prune_all_layer_stacks() -> void:
	for layer_idx: int in _panel_stacks.keys():
		_prune_layer_stack(layer_idx as Layer)


func _prune_layer_stack(layer: Layer) -> void:
	var stack: Array = _panel_stacks[layer]
	var removed_top := false
	for index: int in range(stack.size() - 1, -1, -1):
		var panel := stack[index] as Node
		if not is_instance_valid(panel) or panel.is_queued_for_deletion():
			if index == stack.size() - 1:
				removed_top = true
			stack.remove_at(index)
	if removed_top and _auto_hide_under:
		_reveal_top_panel(layer)


func _is_panel_in_any_stack(panel: Node) -> bool:
	for stack: Array in _panel_stacks.values():
		if stack.has(panel):
			return true
	return false


func _reveal_top_panel(layer: Layer) -> void:
	var stack: Array = _panel_stacks[layer]
	if stack.is_empty():
		return

	var next_panel := stack.back() as Node
	if is_instance_valid(next_panel) and next_panel is CanvasItem:
		(next_panel as CanvasItem).visible = true


func _restore_hidden_panel(panel: CanvasItem) -> void:
	if is_instance_valid(panel):
		panel.visible = true


func _emit_navigation_changed(layer: Layer) -> void:
	navigation_changed.emit(layer, get_top_panel(layer))


func _request_dismiss_layer(layer: Layer, reason: String) -> bool:
	var top_panel := get_top_panel(layer)
	if top_panel == null:
		return false

	panel_dismiss_requested.emit(top_panel, layer, reason)
	var options := get_panel_options(top_panel)
	if not bool(options.get("dismiss_on_cancel", false)):
		return false

	if top_panel.has_method("resolve_cancel"):
		top_panel.call("resolve_cancel")
		return true

	pop_panel(layer)
	return true


func _count_modals_in_layer(layer: Layer) -> int:
	_prune_layer_stack(layer)
	var count := 0
	for panel: Node in _panel_stacks[layer]:
		if is_panel_modal(panel):
			count += 1
	return count


func _normalize_panel_options(options: Dictionary) -> Dictionary:
	var metadata_variant: Variant = options.get("metadata", {})
	var is_modal := bool(options.get("modal", false))
	var mode := int(options.get("mode", PanelMode.MODAL if is_modal else PanelMode.NORMAL))
	mode = clampi(mode, PanelMode.NORMAL, PanelMode.MODAL)
	return {
		"mode": mode,
		"dismiss_on_cancel": bool(options.get("dismiss_on_cancel", mode == PanelMode.MODAL)),
		"focus_on_open": bool(options.get("focus_on_open", mode == PanelMode.MODAL)),
		"restore_focus_on_close": bool(options.get("restore_focus_on_close", mode == PanelMode.MODAL)),
		"metadata": (metadata_variant as Dictionary).duplicate(true) if metadata_variant is Dictionary else {},
	}


func _capture_previous_focus(panel: Node, options: Dictionary) -> void:
	if not bool(options.get("restore_focus_on_close", false)):
		return
	var viewport := panel.get_viewport()
	if viewport == null:
		return
	var focused := viewport.gui_get_focus_owner()
	if focused != null:
		_previous_focus_by_panel_id[panel.get_instance_id()] = weakref(focused)


func _apply_open_focus_policy(panel: Node, options: Dictionary) -> void:
	if bool(options.get("focus_on_open", false)):
		_focus_first_control(panel)


func _handle_panel_closed(panel: Node) -> void:
	var panel_id := panel.get_instance_id()
	var options := _panel_options.get(panel_id, {}) as Dictionary
	if options != null and bool(options.get("restore_focus_on_close", false)):
		_restore_previous_focus(panel_id)
	_panel_options.erase(panel_id)
	_previous_focus_by_panel_id.erase(panel_id)


func _restore_previous_focus(panel_id: int) -> void:
	var previous_ref := _previous_focus_by_panel_id.get(panel_id) as WeakRef
	if previous_ref == null:
		return
	var previous := previous_ref.get_ref() as Control
	if is_instance_valid(previous) and previous.is_inside_tree():
		previous.grab_focus()


func _focus_first_control(root: Node) -> bool:
	if root is Control:
		var control := root as Control
		if _can_focus_control(control):
			control.grab_focus()
			return true

	for child: Node in root.get_children():
		if _focus_first_control(child):
			return true
	return false


func _can_focus_control(control: Control) -> bool:
	return (
		is_instance_valid(control)
		and control.visible
		and control.focus_mode != Control.FOCUS_NONE
		and not control.is_queued_for_deletion()
	)


func _is_descendant_of(node: Node, ancestor: Node) -> bool:
	var current := node
	while current != null:
		if current == ancestor:
			return true
		current = current.get_parent()
	return false


func _get_asset_util() -> GFAssetUtility:
	var arch: Object = _get_architecture_or_null()
	if arch != null and arch.has_method("get_utility"):
		var util: Object = arch.get_utility(GFAssetUtility)
		if util != null:
			return util as GFAssetUtility

	return null


func _on_modal_resolved(result: GFModalResult, panel: Node, layer: Layer, result_callback: Callable) -> void:
	if is_panel_open(panel, layer):
		if get_top_panel(layer) == panel:
			pop_panel(layer)
		elif is_instance_valid(panel):
			panel.queue_free()

	if result_callback.is_valid():
		result_callback.call(result)


func _on_panel_tree_exited(panel: Node, layer: Layer) -> void:
	if not _panel_stacks.has(layer):
		return

	var stack: Array = _panel_stacks[layer]
	var was_open := stack.has(panel)
	if not was_open:
		return

	var was_top: bool = not stack.is_empty() and stack.back() == panel
	stack.erase(panel)
	_handle_panel_closed(panel)
	panel_closed.emit(panel, layer)
	if was_top and _auto_hide_under:
		_reveal_top_panel(layer)
	_emit_navigation_changed(layer)
