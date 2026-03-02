# gf/utilities/gf_object_pool_utility.gd

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


# --- 私有变量 ---

## 对象池字典。Key 为 PackedScene 资源，Value 为对应的节点池数组。
var _pools: Dictionary = {}


# --- Godot 生命周期方法 ---

## 第一阶段初始化：清空内部池字典。
func init() -> void:
	_pools = {}


## 销毁阶段：释放所有池中的节点。
func dispose() -> void:
	for scene in _pools:
		var pool: Array = _pools[scene]
		for node in pool:
			if is_instance_valid(node):
				node.queue_free()
	_pools.clear()


# --- 公共方法 ---

## 从池中获取一个节点实例。若池为空则自动实例化并加入父节点。
## @param scene: 要实例化的 PackedScene 资源。
## @param parent: 新实例化的节点将被加入此父节点（释放节点不会改变父节点）。
## @return 可直接使用的节点实例。
func acquire(scene: PackedScene, parent: Node) -> Node:
	if not is_instance_valid(scene):
		push_error("[GFObjectPoolUtility] 传入了无效的 PackedScene。")
		return null

	if not _pools.has(scene):
		_pools[scene] = []

	var pool: Array = _pools[scene]

	for node in pool:
		if is_instance_valid(node) and not node.get_meta(_META_ACTIVE, false):
			node.set_meta(_META_ACTIVE, true)
			return node

	var new_node: Node = scene.instantiate()
	new_node.set_meta(_META_ACTIVE, true)
	if is_instance_valid(parent):
		parent.add_child(new_node)

	return new_node


## 将节点归还到对象池，隐藏它以待下次复用。
## @param node: 要归还的节点实例（必须由此工具创建）。
## @param scene: 该节点所属的 PackedScene 资源，用于匹配正确的池。
func release(node: Node, scene: PackedScene) -> void:
	if not is_instance_valid(node):
		return

	node.set_meta(_META_ACTIVE, false)

	if not _pools.has(scene):
		_pools[scene] = []

	var pool: Array = _pools[scene]
	if not pool.has(node):
		pool.push_back(node)


## 预热对象池，预先实例化指定数量的节点以避免首次使用时的卡顿。
## @param scene: 要预热的 PackedScene 资源。
## @param parent: 预热节点将加入此父节点。
## @param count: 预热的数量。
func prewarm(scene: PackedScene, parent: Node, count: int) -> void:
	for i in range(count):
		var node: Node = scene.instantiate()
		node.set_meta(_META_ACTIVE, false)
		if is_instance_valid(parent):
			parent.add_child(node)

		if not _pools.has(scene):
			_pools[scene] = []

		_pools[scene].push_back(node)


## 获取指定场景当前池中可用（未使用）的节点数量。
## @param scene: 要查询的 PackedScene 资源。
## @return 池中可用节点数量。
func get_available_count(scene: PackedScene) -> int:
	if not _pools.has(scene):
		return 0

	var count: int = 0
	for node in _pools[scene]:
		if is_instance_valid(node) and not node.get_meta(_META_ACTIVE, false):
			count += 1
	return count
