# tests/gf_core/test_gf_object_pool_utility.gd

## 测试 GFObjectPoolUtility 的 acquire、release、prewarm 及 get_available_count。
extends GutTest


# --- 私有变量 ---

var _pool: GFObjectPoolUtility
var _parent: Node
var _scene: PackedScene


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_pool = GFObjectPoolUtility.new()
	_pool.init()

	_parent = Node.new()
	add_child(_parent)

	_scene = _make_node_scene()


func after_each() -> void:
	_pool.dispose()
	_pool = null
	_parent.queue_free()
	_parent = null
	_scene = null


# --- 私有/辅助方法 ---

## 创建一个最简 PackedScene（仅包含一个根 Node），用于测试。
func _make_node_scene() -> PackedScene:
	var node := Node.new()
	var scene := PackedScene.new()
	scene.pack(node)
	node.free()
	return scene


# --- 测试：acquire ---

## 验证 acquire 返回有效节点并将其添加到父节点。
func test_acquire_returns_valid_node() -> void:
	var node: Node = _pool.acquire(_scene, _parent)

	assert_not_null(node, "acquire 应返回有效节点。")
	assert_true(is_instance_valid(node), "返回的节点应为有效实例。")


## 验证 acquire 后节点的 metadata 被标记为激活状态。
func test_acquire_node_is_active() -> void:
	var node: Node = _pool.acquire(_scene, _parent)
	var is_active: bool = node.get_meta(&"_gf_pool_active", false)
	assert_true(is_active, "acquire 返回的节点 metadata _gf_pool_active 应为 true。")


# --- 测试：release ---

## 验证 release 后节点的 metadata 被标记为未激活。
func test_release_marks_node_inactive() -> void:
	var node: Node = _pool.acquire(_scene, _parent)
	_pool.release(node, _scene)

	var is_active: bool = node.get_meta(&"_gf_pool_active", false)
	assert_false(is_active, "release 后节点 metadata _gf_pool_active 应为 false。")


## 验证 release 后再次 acquire 复用同一节点而不创建新实例。
func test_acquire_after_release_reuses_node() -> void:
	var node1: Node = _pool.acquire(_scene, _parent)
	_pool.release(node1, _scene)

	var node2: Node = _pool.acquire(_scene, _parent)

	assert_eq(node1, node2, "release 后再次 acquire 应复用同一节点。")


## 验证对有效池的连续 acquire/release 循环不产生额外实例。
func test_repeated_acquire_release_does_not_leak() -> void:
	var node: Node = _pool.acquire(_scene, _parent)
	_pool.release(node, _scene)

	var count_before: int = _parent.get_child_count()

	_pool.acquire(_scene, _parent)

	assert_eq(_parent.get_child_count(), count_before, "复用节点时父节点的子节点数不应增加。")


# --- 测试：prewarm ---

## 验证 prewarm 预先创建指定数量的节点并加入父节点。
func test_prewarm_creates_nodes_in_parent() -> void:
	_pool.prewarm(_scene, _parent, 3)

	assert_eq(_parent.get_child_count(), 3, "prewarm(3) 应在父节点下创建 3 个子节点。")


## 验证 prewarm 后可用节点数等于预热数量。
func test_prewarm_sets_available_count() -> void:
	_pool.prewarm(_scene, _parent, 5)

	assert_eq(_pool.get_available_count(_scene), 5, "prewarm(5) 后可用节点数应为 5。")


# --- 测试：get_available_count ---

## 验证初始时可用数量为 0。
func test_initial_available_count_is_zero() -> void:
	assert_eq(_pool.get_available_count(_scene), 0, "初始时可用节点数应为 0。")


## 验证 acquire 后可用数量减少，release 后恢复。
func test_available_count_changes_with_acquire_release() -> void:
	_pool.prewarm(_scene, _parent, 2)
	assert_eq(_pool.get_available_count(_scene), 2, "预热 2 个后可用数应为 2。")

	var node: Node = _pool.acquire(_scene, _parent)
	assert_eq(_pool.get_available_count(_scene), 1, "acquire 一个后可用数应为 1。")

	_pool.release(node, _scene)
	assert_eq(_pool.get_available_count(_scene), 2, "release 后可用数应恢复为 2。")


## 验证重复 release 同一个节点不会导致池内出现重复引用。
func test_double_release_is_ignored() -> void:
	var node: Node = _pool.acquire(_scene, _parent)
	
	_pool.release(node, _scene) # 第一下归还
	var count1 := _pool.get_available_count(_scene)
	
	_pool.release(node, _scene) # 第二下归还应当被忽略
	var count2 := _pool.get_available_count(_scene)
	
	assert_eq(count1, count2, "对同一个早已处于池中的节点重复 release，不应当增加可用节点计数。")

## 验证当对象池中含有被外部错误 queue_free 退出的游离旧节点时，acquire 不会崩溃。
func test_acquire_invalid_freed_instance_is_safe() -> void:
	var node: Node = _pool.acquire(_scene, _parent)
	_pool.release(node, _scene)
	
	# 模拟外部错误地连带释放了已经被还回池子的节点
	node.free()
	
	# 如果没有安全类型推断和防崩溃处理，下面这行就会报错
	var new_node: Node = _pool.acquire(_scene, _parent)
	
	assert_not_null(new_node, "池内存在非法实例时，acquire 应该平稳度过并返回一个新的有效实例。")
	assert_true(is_instance_valid(new_node), "新获得的 node 应该是有效的新实例。")
	assert_ne(new_node, node, "新实例不能是那个被强制 free 的原实例。")
