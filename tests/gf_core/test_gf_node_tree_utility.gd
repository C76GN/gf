## 测试 GFNodeTreeUtility 的通用节点树操作。
extends GutTest


class CustomNode extends Node:
	pass


func test_add_child_with_owner_sets_scene_owner() -> void:
	var root := Node.new()
	add_child_autofree(root)
	var child := Node.new()

	var added := GFNodeTreeUtility.add_child_with_owner(root, child)

	assert_true(added, "应能添加无父节点的子节点。")
	assert_eq(child.get_parent(), root, "子节点应挂到目标父节点。")
	assert_eq(child.owner, root, "未提供 owner 时应使用父节点作为 owner。")


func test_reparent_node_moves_child_and_updates_owner() -> void:
	var first_parent := Node.new()
	var second_parent := Node.new()
	add_child_autofree(first_parent)
	add_child_autofree(second_parent)
	var child := Node.new()
	first_parent.add_child(child)

	var moved := GFNodeTreeUtility.reparent_node(child, second_parent)

	assert_true(moved, "应能把节点移动到新父节点。")
	assert_eq(child.get_parent(), second_parent, "子节点应移动到新父节点。")
	assert_eq(child.owner, second_parent, "重挂后应更新 owner。")


func test_replace_child_preserves_index() -> void:
	var parent := Node.new()
	add_child_autofree(parent)
	var first := Node.new()
	var old_child := Node.new()
	var last := Node.new()
	var replacement := Node.new()
	parent.add_child(first)
	parent.add_child(old_child)
	parent.add_child(last)

	var replaced := GFNodeTreeUtility.replace_child(parent, old_child, replacement)

	assert_true(replaced, "应能替换父节点下的子节点。")
	assert_eq(replacement.get_parent(), parent, "新节点应挂到父节点下。")
	assert_eq(replacement.get_index(), 1, "新节点应占用旧节点的位置。")
	assert_null(old_child.get_parent(), "旧节点应从父节点移除。")
	old_child.free()


func test_find_and_collect_nodes_by_type() -> void:
	var root := Node.new()
	add_child_autofree(root)
	var branch := Node.new()
	var custom := CustomNode.new()
	root.add_child(branch)
	branch.add_child(custom)

	assert_eq(
		GFNodeTreeUtility.find_first_child_of_type(root, CustomNode, true),
		custom,
		"递归查找应返回第一个匹配脚本类型的子节点。"
	)
	assert_eq(
		GFNodeTreeUtility.find_first_parent_of_type(custom, "Node"),
		branch,
		"向上查找应支持原生类名。"
	)

	var collected := GFNodeTreeUtility.collect_node_tree(root, CustomNode)
	assert_eq(collected, [custom], "收集节点树时应按类型过滤。")


func test_free_children_queues_direct_children() -> void:
	var parent := Node.new()
	add_child_autofree(parent)
	parent.add_child(Node.new())
	parent.add_child(Node.new())

	var count := GFNodeTreeUtility.free_children(parent)

	assert_eq(count, 2, "应返回进入释放队列的子节点数量。")
