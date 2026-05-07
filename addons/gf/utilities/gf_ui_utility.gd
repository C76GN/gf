## GFUIUtility: 栈式 UI 管理器。
##
## 负责多层级界面的入栈、出栈与异步加载，
## 适合 HUD、弹窗和顶层遮罩等需要分层管理的 UI 场景。
class_name GFUIUtility
extends GFUtility


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
	var asset_util := _get_asset_util()
	if asset_util == null:
		push_warning("[GFUIUtility] GFAssetUtility 未注册，回退为同步加载。")
		push_panel(path, layer, config_callback)
		return

	var on_loaded := func(res: Resource) -> void:
		if not _is_active:
			return

		var scene := res as PackedScene
		if scene == null:
			push_error("[GFUIUtility] 无法实例化面板场景：%s" % path)
			return

		var panel_instance: Node = scene.instantiate()
		if not _add_panel_instance(panel_instance, layer, config_callback) and is_instance_valid(panel_instance):
			panel_instance.queue_free()

	asset_util.load_async(path, on_loaded, "PackedScene")


## 同步压入一个面板场景。
## @param path: 面板场景路径。
## @param layer: 目标层级。
## @param config_callback: 实例化后、入栈前的可选配置回调。
## @return 成功时返回面板实例，失败时返回 `null`。
func push_panel(path: String, layer: Layer = Layer.POPUP, config_callback: Callable = Callable()) -> Node:
	var scene := load(path) as PackedScene
	if scene == null:
		push_error("[GFUIUtility] 无法加载面板场景：%s" % path)
		return null

	var panel_instance: Node = scene.instantiate()
	if not _add_panel_instance(panel_instance, layer, config_callback):
		if is_instance_valid(panel_instance):
			panel_instance.queue_free()
		return null

	return panel_instance


## 压入一个已实例化的面板节点。
## @param panel_instance: 面板实例。
## @param layer: 目标层级。
## @param config_callback: 入栈前的可选配置回调。
func push_panel_instance(
	panel_instance: Node,
	layer: Layer = Layer.POPUP,
	config_callback: Callable = Callable()
) -> void:
	if not is_instance_valid(panel_instance):
		push_error("[GFUIUtility] 传入的 panel_instance 无效。")
		return

	_add_panel_instance(panel_instance, layer, config_callback)


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

	if _auto_hide_under:
		_reveal_top_panel(layer)


## 清空指定层级的所有面板。
## @param layer: 目标层级。
func clear_layer(layer: Layer) -> void:
	_prune_layer_stack(layer)
	var stack: Array = _panel_stacks[layer]
	while not stack.is_empty():
		var panel: Node = stack.pop_back()
		if is_instance_valid(panel):
			panel.queue_free()


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


## 获取指定层级的 CanvasLayer。
## @param layer: 目标层级。
## @return 对应的 `CanvasLayer` 实例。
func get_layer_root(layer: Layer) -> CanvasLayer:
	return _layer_roots.get(layer) as CanvasLayer


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


func _add_panel_instance(panel: Node, layer: Layer, config_callback: Callable) -> bool:
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

	stack.push_back(panel)
	panel.tree_exited.connect(_on_panel_tree_exited.bind(panel, layer), CONNECT_ONE_SHOT)
	if panel.get_parent() != null and panel.get_parent() != canvas:
		panel.get_parent().remove_child(panel)
	if panel.get_parent() != canvas:
		canvas.add_child(panel)
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


func _get_asset_util() -> GFAssetUtility:
	var arch: Object = _get_architecture_or_null()
	if arch != null and arch.has_method("get_utility"):
		var util: Object = arch.get_utility(GFAssetUtility)
		if util != null:
			return util as GFAssetUtility

	return null


func _on_panel_tree_exited(panel: Node, layer: Layer) -> void:
	if not _panel_stacks.has(layer):
		return

	var stack: Array = _panel_stacks[layer]
	var was_top: bool = not stack.is_empty() and stack.back() == panel
	stack.erase(panel)
	if was_top and _auto_hide_under:
		_reveal_top_panel(layer)
