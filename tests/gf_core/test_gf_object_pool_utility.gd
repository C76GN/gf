## 测试 GFObjectPoolUtility 的 acquire、release、prewarm 及 get_available_count。
extends GutTest


# --- 私有变量 ---

var _pool: GFObjectPoolUtility
var _parent: Node
var _scene: PackedScene


# --- 辅助类型 ---

class HookedNode extends Node:
	var acquire_count: int = 0
	var release_count: int = 0

	func on_gf_pool_acquire() -> void:
		acquire_count += 1

	func on_gf_pool_release() -> void:
		release_count += 1


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


## 创建一个 Control PackedScene，用于验证可见性和 process_mode 回收状态。
func _make_control_scene() -> PackedScene:
	var control := Control.new()
	var scene := PackedScene.new()
	scene.pack(control)
	control.free()
	return scene


## 创建一个带对象池 hook 的 PackedScene。
func _make_hooked_scene() -> PackedScene:
	var node := HookedNode.new()
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


## 验证 release 后 CanvasItem 会被隐藏并暂停处理，acquire 时恢复。
func test_release_disables_visible_node_and_acquire_restores_it() -> void:
	var control_scene := _make_control_scene()
	var node := _pool.acquire(control_scene, _parent) as Control

	assert_true(node.visible, "acquire 后 Control 应保持可见。")
	assert_eq(node.process_mode, Node.PROCESS_MODE_INHERIT, "acquire 后应保持原 process_mode。")

	_pool.release(node, control_scene)

	assert_false(node.visible, "release 后 Control 应被隐藏。")
	assert_eq(node.process_mode, Node.PROCESS_MODE_DISABLED, "release 后节点应停止处理。")

	var reused := _pool.acquire(control_scene, _parent) as Control

	assert_eq(reused, node, "再次 acquire 应复用同一 Control。")
	assert_true(reused.visible, "复用后 Control 应恢复可见。")
	assert_eq(reused.process_mode, Node.PROCESS_MODE_INHERIT, "复用后应恢复原 process_mode。")


## 验证 release 后再次 acquire 复用同一节点而不创建新实例。
func test_acquire_after_release_reuses_node() -> void:
	var node1: Node = _pool.acquire(_scene, _parent)
	_pool.release(node1, _scene)

	var node2: Node = _pool.acquire(_scene, _parent)

	assert_eq(node1, node2, "release 后再次 acquire 应复用同一节点。")


## 验证节点可通过 on_gf_pool_acquire/release hook 清理和重置自身状态。
func test_acquire_release_calls_node_hooks() -> void:
	var hooked_scene := _make_hooked_scene()
	var node := _pool.acquire(hooked_scene, _parent) as HookedNode

	assert_eq(node.acquire_count, 1, "首次 acquire 应调用 on_gf_pool_acquire。")
	assert_eq(node.release_count, 0, "未 release 前不应调用 release hook。")

	_pool.release(node, hooked_scene)
	assert_eq(node.release_count, 1, "release 应调用 on_gf_pool_release。")

	var reused := _pool.acquire(hooked_scene, _parent) as HookedNode
	assert_eq(reused, node, "hook 测试应复用同一节点。")
	assert_eq(reused.acquire_count, 2, "复用 acquire 应再次调用 on_gf_pool_acquire。")


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


func test_prewarm_rejects_invalid_scene() -> void:
	_pool.prewarm(null, _parent, 1)

	assert_push_error("[GFObjectPoolUtility] 传入了无效的 PackedScene。")
	assert_eq(_parent.get_child_count(), 0, "无效 PackedScene 不应创建任何节点。")


func test_prewarm_async_batches_nodes() -> void:
	await _pool.prewarm_async(_scene, _parent, 3, 1)

	assert_eq(_parent.get_child_count(), 3, "prewarm_async 应完成指定数量的预热。")
	assert_eq(_pool.get_available_count(_scene), 3, "prewarm_async 后可用节点数应正确。")


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
func test_release_wrong_scene_returns_to_original_pool() -> void:
	var other_scene := _make_node_scene()
	var node: Node = _pool.acquire(_scene, _parent)

	_pool.release(node, other_scene)

	assert_eq(_pool.get_available_count(_scene), 1, "传错 scene 时，节点仍应回收到原始所属池。")
	assert_eq(_pool.get_available_count(other_scene), 0, "传错 scene 不应污染其他对象池。")
	assert_push_warning("[GFObjectPoolUtility] release 收到不匹配的 PackedScene，已回退到节点原始所属池。")


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
	assert_eq((_pool._all_nodes[_scene] as Array).size(), 1, "清理无效实例后，全量池中不应继续保留死对象引用。")
