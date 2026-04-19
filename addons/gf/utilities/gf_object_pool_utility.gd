# addons/gf/utilities/gf_object_pool_utility.gd

## GFObjectPoolUtility: 节点对象池管理器。
##
## 继承自 GFUtility，管理 Node 对象的实例化与回收，
## 避免高频 instance/free 操作带来的内存碎片和性能抖动。
## 适合管理大量同类对象，如子弹、敌人单位、特效粒子、棋盘方块等。
## 内部使用 Node metadata 键 _gf_pool_active 跟踪节点使用状态，
## 因此兼容任意 Node 子类型（无需 CanvasItem/visible 支持）。
##
## 工作流程：
##   1. 调用 acquire(scene, parent) 从池中取出一个可用节点（或自动实例化）。
##   2. 对节点进行配置使用。
##   3. 对象生命周期结束后，调用 release(node, scene) 将其归还至池中。
class_name GFObjectPoolUtility
extends GFUtility


# --- 常量 ---

## 用于标记节点当前是否被激活使用的 metadata 键。
const _META_ACTIVE: StringName = &"_gf_pool_active"

## 用于保存节点进入池前的 process_mode。
const _META_ORIGINAL_PROCESS_MODE: StringName = &"_gf_pool_original_process_mode"

## 用于保存 CanvasItem 进入池前的 visible 状态。
const _META_ORIGINAL_VISIBLE: StringName = &"_gf_pool_original_visible"

## 用于保存节点进入池前的 disabled 属性。
const _META_ORIGINAL_DISABLED: StringName = &"_gf_pool_original_disabled"

## 节点可选实现：归还对象池前调用，用于清理 Tween、临时信号、运行时状态等。
const HOOK_ON_RELEASE: StringName = &"on_gf_pool_release"

## 节点可选实现：从对象池取出并恢复激活后调用，用于重置本次使用状态。
const HOOK_ON_ACQUIRE: StringName = &"on_gf_pool_acquire"


# --- 私有变量 ---

## 对象池全量字典。Key 为 PackedScene 资源，Value 为该场景产生的所有节点数组。
## 仅用于销毁时统一释放。
var _all_nodes: Dictionary = {}

## 可用对象池字典。Key 为 PackedScene 资源，Value 为当前可用的节点栈。
var _available_pools: Dictionary = {}


# --- Godot 生命周期方法 ---

## 第一阶段初始化：清空内部池字典。
func init() -> void:
	_all_nodes = {}
	_available_pools = {}


## 销毁阶段：释放所有池中的节点。
func dispose() -> void:
	for scene in _all_nodes:
		var pool: Array = _all_nodes[scene]
		for node in pool:
			if is_instance_valid(node):
				node.queue_free()
	_all_nodes.clear()
	_available_pools.clear()


# --- 公共方法 ---

## 从池中获取一个节点实例。若池为空则自动实例化并加入父节点。
## @param scene: 要实例化的 PackedScene 资源。
## @param parent: 新实例化的节点将被加入此父节点（释放节点不会改变父节点）。
## @return 可直接使用的节点实例。
func acquire(scene: PackedScene, parent: Node) -> Node:
	if not is_instance_valid(scene):
		push_error("[GFObjectPoolUtility] 传入了无效的 PackedScene。")
		return null

	if not _available_pools.has(scene):
		_available_pools[scene] = []
		_all_nodes[scene] = []

	var available_pool: Array = _available_pools[scene]

	while not available_pool.is_empty():
		var popped_item = available_pool.pop_back()
		
		if is_instance_valid(popped_item) and not popped_item.is_queued_for_deletion():
			var node: Node = popped_item as Node
			node.set_meta(_META_ACTIVE, true)
			_set_node_tree_active_state(node, true)
			
			if is_instance_valid(parent) and node.get_parent() != parent:
				if node.get_parent() != null:
					node.reparent(parent, false)
				else:
					parent.add_child(node)

			_call_node_tree_hook(node, HOOK_ON_ACQUIRE)
			return node

	var new_node: Node = scene.instantiate()
	new_node.set_meta(_META_ACTIVE, true)
	_prepare_node_tree(new_node)
	_set_node_tree_active_state(new_node, true)
	if is_instance_valid(parent):
		parent.add_child(new_node)

	_all_nodes[scene].push_back(new_node)
	_call_node_tree_hook(new_node, HOOK_ON_ACQUIRE)
	return new_node


## 将节点归还到对象池，隐藏它以待下次复用。
## @param node: 要归还的节点实例（必须由此工具创建）。
## @param scene: 该节点所属的 PackedScene 资源，用于匹配正确的池。
func release(node: Node, scene: PackedScene) -> void:
	if not is_instance_valid(node):
		return

	if node.has_meta(_META_ACTIVE) and not node.get_meta(_META_ACTIVE):
		return

	_call_node_tree_hook(node, HOOK_ON_RELEASE)
	node.set_meta(_META_ACTIVE, false)
	_set_node_tree_active_state(node, false)

	if not _available_pools.has(scene):
		_available_pools[scene] = []
		_all_nodes[scene] = []

	var available_pool: Array = _available_pools[scene]
	available_pool.push_back(node)


## 预热对象池，预先实例化指定数量的节点以避免首次使用时的卡顿。
## @param scene: 要预热的 PackedScene 资源。
## @param parent: 预热节点将加入此父节点。
## @param count: 预热的数量。
func prewarm(scene: PackedScene, parent: Node, count: int) -> void:
	if not _available_pools.has(scene):
		_available_pools[scene] = []
		_all_nodes[scene] = []

	for i in range(count):
		var node: Node = scene.instantiate()
		node.set_meta(_META_ACTIVE, false)
		_prepare_node_tree(node)
		_set_node_tree_active_state(node, false)
		if is_instance_valid(parent):
			parent.add_child(node)

		_all_nodes[scene].push_back(node)
		_available_pools[scene].push_back(node)


## 获取指定场景当前池中可用（未使用）的节点数量。
## @param scene: 要查询的 PackedScene 资源。
## @return 池中可用节点数量。
func get_available_count(scene: PackedScene) -> int:
	if not _available_pools.has(scene):
		return 0

	var count: int = 0
	for item in _available_pools[scene]:
		if is_instance_valid(item) and not item.is_queued_for_deletion():
			count += 1
	return count


# --- 私有/辅助方法 ---

func _prepare_node_tree(node: Node) -> void:
	_prepare_node_for_pool(node)
	for child: Node in node.get_children():
		_prepare_node_tree(child)


func _prepare_node_for_pool(node: Node) -> void:
	if not node.has_meta(_META_ORIGINAL_PROCESS_MODE):
		node.set_meta(_META_ORIGINAL_PROCESS_MODE, node.process_mode)
		
	if node is CanvasItem and not node.has_meta(_META_ORIGINAL_VISIBLE):
		node.set_meta(_META_ORIGINAL_VISIBLE, (node as CanvasItem).visible)
		
	if "disabled" in node and not node.has_meta(_META_ORIGINAL_DISABLED):
		node.set_meta(_META_ORIGINAL_DISABLED, node.get("disabled"))


func _set_node_tree_active_state(node: Node, active: bool) -> void:
	_set_node_active_state(node, active)
	for child: Node in node.get_children():
		_set_node_tree_active_state(child, active)


func _set_node_active_state(node: Node, active: bool) -> void:
	_prepare_node_for_pool(node)
	
	if active:
		node.process_mode = node.get_meta(_META_ORIGINAL_PROCESS_MODE)
		if node is CanvasItem:
			(node as CanvasItem).visible = node.get_meta(_META_ORIGINAL_VISIBLE)
		if "disabled" in node:
			node.set("disabled", node.get_meta(_META_ORIGINAL_DISABLED))
	else:
		node.process_mode = Node.PROCESS_MODE_DISABLED
		if node is CanvasItem:
			(node as CanvasItem).visible = false
		if "disabled" in node:
			node.set("disabled", true)


func _call_node_tree_hook(node: Node, hook_name: StringName) -> void:
	_call_node_hook(node, hook_name)
	for child: Node in node.get_children():
		_call_node_tree_hook(child, hook_name)


func _call_node_hook(node: Node, hook_name: StringName) -> void:
	if node.has_method(hook_name):
		node.call(hook_name)
