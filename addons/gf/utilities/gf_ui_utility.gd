# addons/gf/utilities/gf_ui_utility.gd
class_name GFUIUtility
extends GFUtility


## GFUIUtility: 栈式 UI 管理器。
##
## 管理多层级（如 HUD、POPUP、TOP）的界面压栈与出栈。
## 支持通过 GFAssetUtility 异步加载 UI 预制体，或直接同步加载。


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

## 各层级的 UI 节点栈。
var _panel_stacks: Dictionary = {
	Layer.HUD: [],
	Layer.POPUP: [],
	Layer.TOP: [],
}

## 是否自动隐藏同层级下层的面板（实现全屏界面的栈式覆盖）。
var _auto_hide_under: bool = true


# --- Godot 生命周期方法 ---

func init() -> void:
	_create_layers()


func dispose() -> void:
	for canvas: CanvasLayer in _layer_roots.values():
		if is_instance_valid(canvas):
			canvas.queue_free()
	_layer_roots.clear()
	for stack: Array in _panel_stacks.values():
		stack.clear()


# --- 公共方法 ---

## 配置管理器。
## @param auto_hide_under: 压入新面板时，是否自动隐藏同层级下方的面板。
func configure(auto_hide_under: bool = true) -> void:
	_auto_hide_under = auto_hide_under


## 异步弹出面板。尝试通过 GFAssetUtility 加载。
## @param path: 面板的场景路径。
## @param layer: 目标层级。
## @param config_callback: 可选回调，在 instantiate 之后且 add_child 之前调用，签名为 func(panel: Node) -> void。
func push_panel_async(path: String, layer: Layer = Layer.POPUP, config_callback: Callable = Callable()) -> void:
	var asset_util := _get_asset_util()
	if asset_util == null:
		push_warning("[GFUIUtility] GFAssetUtility 未注册或未获取到，回退到同步加载。")
		push_panel(path, layer, config_callback)
		return
		
	var on_loaded := func(res: Resource) -> void:
		var scene := res as PackedScene
		if scene != null:
			var panel_instance: Node = scene.instantiate()
			_add_panel_instance(panel_instance, layer, config_callback)
		else:
			push_error("[GFUIUtility] 无法实例化面板场景：%s" % path)
			
	asset_util.load_async(path, on_loaded)


## 同步弹出面板。建议仅用于小型面板或已预加载的面板。
## @param path: 面板的场景路径。
## @param layer: 目标层级。
## @param config_callback: 可选回调，在 instantiate 之后且 add_child 之前调用，签名为 func(panel: Node) -> void。
## @return 实例化的面板节点。
func push_panel(path: String, layer: Layer = Layer.POPUP, config_callback: Callable = Callable()) -> Node:
	var scene := load(path) as PackedScene
	if scene == null:
		push_error("[GFUIUtility] 无法加载面板场景：%s" % path)
		return null
	var panel_instance: Node = scene.instantiate()
	_add_panel_instance(panel_instance, layer, config_callback)
	return panel_instance


## 手动推入一个已实例化的面板节点。
## @param panel_instance: 预先实例化的节点。
## @param layer: 目标层级。
func push_panel_instance(panel_instance: Node, layer: Layer = Layer.POPUP) -> void:
	if not is_instance_valid(panel_instance):
		push_error("[GFUIUtility] 传入的面板实例无效。")
		return
	_add_panel_instance(panel_instance, layer, Callable())


## 弹出指定层级的顶层面板。
## @param layer: 要弹出的层级，默认为 POPUP 层。
## @param do_free: 是否在弹出后自动 free 该节点。
func pop_panel(layer: Layer = Layer.POPUP, do_free: bool = true) -> void:
	var stack: Array = _panel_stacks[layer]
	if stack.is_empty():
		return
		
	var top_panel: Node = stack.pop_back()
	if is_instance_valid(top_panel):
		if do_free:
			top_panel.queue_free()
		elif top_panel.get_parent() != null:
			top_panel.get_parent().remove_child(top_panel)
			
	if _auto_hide_under and not stack.is_empty():
		var next_panel: Node = stack.back()
		if is_instance_valid(next_panel) and next_panel is CanvasItem:
			next_panel.visible = true


## 清除指定层级的所有面板。
## @param layer: 目标层级。
func clear_layer(layer: Layer) -> void:
	var stack: Array = _panel_stacks[layer]
	while not stack.is_empty():
		var panel: Node = stack.pop_back()
		if is_instance_valid(panel):
			panel.queue_free()


## 清除所有层级的所有面板。
func clear_all() -> void:
	for layer_idx: int in _panel_stacks.keys():
		clear_layer(layer_idx as Layer)


## 获取当前指定层级的顶层面板。
## @param layer: 目标层级。
## @return 顶层面板节点，如果没有则返回 null。
func get_top_panel(layer: Layer = Layer.POPUP) -> Node:
	var stack: Array = _panel_stacks[layer]
	if stack.is_empty():
		return null
	return stack.back()


## 获取指定层级的 CanvasLayer 根节点。可用于自定义配置，如调整 layer 值。
## @param layer: 目标层级。
## @return 对应的 CanvasLayer 节点。
func get_layer_root(layer: Layer) -> CanvasLayer:
	return _layer_roots.get(layer) as CanvasLayer


# --- 私有/辅助方法 ---

func _create_layers() -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		push_error("[GFUIUtility] 无法获取 SceneTree，可能不在游戏运行环境中。")
		return
		
	var root := scene_tree.root
	for layer_idx: int in Layer.values():
		var canvas := CanvasLayer.new()
		canvas.layer = 50 + layer_idx * 10
		canvas.name = "GFUILayer_" + str(Layer.keys()[layer_idx])
		root.call_deferred("add_child", canvas)
		_layer_roots[layer_idx] = canvas


func _add_panel_instance(panel: Node, layer: Layer, config_callback: Callable) -> void:
	var stack: Array = _panel_stacks[layer]
	
	if _auto_hide_under and not stack.is_empty():
		var old_top: Node = stack.back()
		if is_instance_valid(old_top) and old_top is CanvasItem:
			old_top.visible = false
			
	if config_callback.is_valid():
		config_callback.call(panel)
		
	stack.push_back(panel)
	
	var canvas := _layer_roots[layer] as CanvasLayer
	if is_instance_valid(canvas):
		canvas.add_child(panel)


func _get_asset_util() -> GFAssetUtility:
	if Engine.has_singleton("Gf"):
		var gf := Engine.get_singleton("Gf")
		if gf.has_method("get_architecture"):
			var arch: Object = gf.get_architecture()
			if arch != null and arch.has_method("get_utility"):
				var util: Object = arch.get_utility(GFAssetUtility)
				if util != null:
					return util as GFAssetUtility
	return null
