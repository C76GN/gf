## GFFlowGraph: 资源化通用流程图。
##
## 只维护节点集合与起始节点，不规定具体编辑器表现或业务语义。
class_name GFFlowGraph
extends Resource


# --- 导出变量 ---

## 起始节点标识。
@export var start_node_id: StringName = &""

## 流程节点列表。
@export var nodes: Array[GFFlowNode] = []


# --- 公共方法 ---

## 设置或替换一个节点。
## @param node: 流程节点。
func set_node(node: GFFlowNode) -> void:
	if node == null or node.node_id == &"":
		return

	for index: int in range(nodes.size()):
		if nodes[index] != null and nodes[index].node_id == node.node_id:
			nodes[index] = node
			return
	nodes.append(node)


## 获取节点。
## @param node_id: 节点标识。
## @return 流程节点；不存在时返回 null。
func get_node(node_id: StringName) -> GFFlowNode:
	for node: GFFlowNode in nodes:
		if node != null and node.node_id == node_id:
			return node
	return null


## 检查节点是否存在。
## @param node_id: 节点标识。
## @return 存在返回 true。
func has_node(node_id: StringName) -> bool:
	return get_node(node_id) != null


## 移除节点。
## @param node_id: 节点标识。
func remove_node(node_id: StringName) -> void:
	for index: int in range(nodes.size() - 1, -1, -1):
		if nodes[index] != null and nodes[index].node_id == node_id:
			nodes.remove_at(index)
