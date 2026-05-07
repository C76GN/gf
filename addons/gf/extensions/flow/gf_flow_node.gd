## GFFlowNode: 通用流程图节点基类。
##
## 节点只描述执行入口和默认后继节点。具体条件、命令、等待逻辑由项目继承实现。
class_name GFFlowNode
extends Resource


# --- 常量 ---

const GFFlowPortBase = preload("res://addons/gf/extensions/flow/gf_flow_port.gd")


# --- 导出变量 ---

## 节点稳定标识。
@export var node_id: StringName = &""

## 节点显示名；为空时回退到 node_id。
@export var display_name: String = ""

## 节点分类，仅供编辑器、搜索或项目工具使用。
@export var category: StringName = &""

## 默认后继节点列表。
@export var next_node_ids: PackedStringArray = PackedStringArray()

## 返回 Signal 时是否等待。
@export var wait_for_result: bool = true

## 输入端口描述。仅用于编辑器、校验和项目层数据连接。
@export var input_ports: Array[GFFlowPortBase] = []

## 输出端口描述。仅用于编辑器、校验和项目层数据连接。
@export var output_ports: Array[GFFlowPortBase] = []

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}

## 编辑器中的节点位置。
@export var editor_position: Vector2 = Vector2.ZERO

## 编辑器中的节点尺寸；为 ZERO 时表示由编辑器自行决定。
@export var editor_size: Vector2 = Vector2.ZERO

## 编辑器中是否折叠显示。
@export var editor_collapsed: bool = false


# --- 公共方法 ---

## 执行节点。
## @param _context: 流程上下文。
## @return 可返回 null 或 Signal。
func execute(_context: GFFlowContext) -> Variant:
	return null


## 获取执行完成后的后继节点。
## @param context: 流程上下文。
## @return 后继节点标识列表。
func get_next_nodes(context: GFFlowContext) -> PackedStringArray:
	if context != null and context.has_next_nodes_override():
		return context.next_node_ids.duplicate()
	return next_node_ids.duplicate()


## 获取节点显示名。
## @return 显示名。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if node_id != &"":
		return String(node_id)
	return "Flow Node"


## 获取输入端口。
## @return 输入端口数组。
func get_input_ports() -> Array[GFFlowPortBase]:
	return input_ports.duplicate()


## 获取输出端口。
## @return 输出端口数组。
func get_output_ports() -> Array[GFFlowPortBase]:
	return output_ports.duplicate()


## 按端口标识查找输入端口。
## @param port_id: 端口标识。
## @return 输入端口；不存在时返回 null。
func get_input_port(port_id: StringName) -> GFFlowPortBase:
	return _find_port(input_ports, port_id)


## 按端口标识查找输出端口。
## @param port_id: 端口标识。
## @return 输出端口；不存在时返回 null。
func get_output_port(port_id: StringName) -> GFFlowPortBase:
	return _find_port(output_ports, port_id)


## 描述节点端口。
## @return 端口描述字典。
func describe_ports() -> Dictionary:
	return {
		"inputs": _describe_ports(input_ports),
		"outputs": _describe_ports(output_ports),
	}


## 描述节点编辑器元数据。
## @return 编辑器元数据字典。
func describe_editor() -> Dictionary:
	return {
		"display_name": get_display_name(),
		"category": category,
		"position": editor_position,
		"size": editor_size,
		"collapsed": editor_collapsed,
	}


## 描述节点。
## @return 节点描述字典。
func describe_node() -> Dictionary:
	return {
		"node_id": node_id,
		"display_name": get_display_name(),
		"category": category,
		"next_node_ids": next_node_ids.duplicate(),
		"wait_for_result": wait_for_result,
		"ports": describe_ports(),
		"editor": describe_editor(),
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _find_port(ports: Array[GFFlowPortBase], port_id: StringName) -> GFFlowPortBase:
	for port: GFFlowPortBase in ports:
		if port != null and port.get_port_id() == port_id:
			return port
	return null


func _describe_ports(ports: Array[GFFlowPortBase]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for port: GFFlowPortBase in ports:
		if port != null:
			result.append(port.describe())
	return result
