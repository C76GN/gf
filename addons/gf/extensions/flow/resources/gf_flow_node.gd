## GFFlowNode: 通用流程图节点基类。
##
## 节点只描述执行入口和默认后继节点。具体条件、命令、等待逻辑由项目继承实现。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFFlowNode
extends Resource


# --- 导出变量 ---

## 节点稳定标识。
## [br]
## @api public
@export var node_id: StringName = &""

## 节点显示名；为空时回退到 node_id。
## [br]
## @api public
@export var display_name: String = ""

## 节点分类，仅供编辑器、搜索或项目工具使用。
## [br]
## @api public
@export var category: StringName = &""

## 默认后继节点列表。
## [br]
## @api public
@export var next_node_ids: PackedStringArray = PackedStringArray()

## 返回 Signal 时是否等待。
## [br]
## @api public
@export var wait_for_result: bool = true

## 输入端口描述。仅用于编辑器、校验和项目层数据连接。
## [br]
## @api public
@export var input_ports: Array[GFFlowPort] = []

## 输出端口描述。仅用于编辑器、校验和项目层数据连接。
## [br]
## @api public
@export var output_ports: Array[GFFlowPort] = []

## 项目自定义元数据。框架不解释该字段。
## [br]
## @api public
## [br]
## @schema metadata: 项目自定义元数据 Dictionary；框架保留并复制该字段，但不解释其中键值。
@export var metadata: Dictionary = {}

## 编辑器中的节点位置。
## [br]
## @api public
@export var editor_position: Vector2 = Vector2.ZERO

## 编辑器中的节点尺寸；为 ZERO 时表示由编辑器自行决定。
## [br]
## @api public
@export var editor_size: Vector2 = Vector2.ZERO

## 编辑器中是否折叠显示。
## [br]
## @api public
@export var editor_collapsed: bool = false


# --- 公共变量 ---

## 节点运行态数据。默认不导出，项目可通过序列化接口自行存档或迁移。
## [br]
## @api public
## [br]
## @schema runtime_state: 项目自定义运行态 Dictionary；键和值由节点实现维护。
var runtime_state: Dictionary = {}


# --- 公共方法 ---

## 执行节点。
## [br]
## @api public
## [br]
## @param _context: 流程上下文。
## [br]
## @return: 可返回 null 或 Signal。
## [br]
## @schema return: null、Signal 或项目节点实现约定的结果值。
func execute(_context: GFFlowContext) -> Variant:
	return null


## 获取执行完成后的后继节点。
## [br]
## @api public
## [br]
## @param context: 流程上下文。
## [br]
## @return: 后继节点标识列表。
func get_next_nodes(context: GFFlowContext) -> PackedStringArray:
	if context != null and context.has_next_nodes_override():
		return context.next_node_ids.duplicate()
	return next_node_ids.duplicate()


## 获取节点显示名。
## [br]
## @api public
## [br]
## @return: 显示名。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if node_id != &"":
		return String(node_id)
	return "Flow Node"


## 获取输入端口。
## [br]
## @api public
## [br]
## @return: 输入端口数组。
func get_input_ports() -> Array[GFFlowPort]:
	return input_ports.duplicate()


## 获取输出端口。
## [br]
## @api public
## [br]
## @return: 输出端口数组。
func get_output_ports() -> Array[GFFlowPort]:
	return output_ports.duplicate()


## 按端口标识查找输入端口。
## [br]
## @api public
## [br]
## @param port_id: 端口标识。
## [br]
## @return: 输入端口；不存在时返回 null。
func get_input_port(port_id: StringName) -> GFFlowPort:
	return _find_port(input_ports, port_id)


## 按端口标识查找输出端口。
## [br]
## @api public
## [br]
## @param port_id: 端口标识。
## [br]
## @return: 输出端口；不存在时返回 null。
func get_output_port(port_id: StringName) -> GFFlowPort:
	return _find_port(output_ports, port_id)


## 描述节点端口。
## [br]
## @api public
## [br]
## @return: 端口描述字典。
## [br]
## @schema return: 包含 inputs 和 outputs 字段的 Dictionary；每个字段为端口描述数组。
func describe_ports() -> Dictionary:
	return {
		"inputs": _describe_ports(input_ports),
		"outputs": _describe_ports(output_ports),
	}


## 描述节点编辑器元数据。
## [br]
## @api public
## [br]
## @return: 编辑器元数据字典。
## [br]
## @schema return: 包含 display_name、category、position、size 和 collapsed 字段的 Dictionary。
func describe_editor() -> Dictionary:
	return {
		"display_name": get_display_name(),
		"category": category,
		"position": editor_position,
		"size": editor_size,
		"collapsed": editor_collapsed,
	}


## 描述节点。
## [br]
## @api public
## [br]
## @return: 节点描述字典。
## [br]
## @schema return: 包含 node_id、display_name、category、next_node_ids、wait_for_result、ports、editor 和 metadata 字段的 Dictionary。
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


## 写入节点运行态值。
## [br]
## @api public
## [br]
## @param key: 键。
## [br]
## @param value: 值。
## [br]
## @schema value: 任意可写入 runtime_state 的项目值。
func set_runtime_value(key: StringName, value: Variant) -> void:
	if key == &"":
		return
	runtime_state[key] = value


## 读取节点运行态值。
## [br]
## @api public
## [br]
## @param key: 键。
## [br]
## @param default_value: 默认值。
## [br]
## @return: 运行态值或默认值。
## [br]
## @schema default_value: 缺失时返回的任意项目值。
## [br]
## @schema return: 找到的运行态值，或传入的 default_value。
func get_runtime_value(key: StringName, default_value: Variant = null) -> Variant:
	return GFVariantData.get_option_value(runtime_state, key, default_value)


## 清空节点运行态数据。
## [br]
## @api public
func clear_runtime_state() -> void:
	runtime_state.clear()


## 序列化节点运行态数据。
## [br]
## @api public
## [br]
## @return: 运行态数据副本。
## [br]
## @schema return: runtime_state 的深拷贝 Dictionary。
func serialize_runtime_state() -> Dictionary:
	return runtime_state.duplicate(true)


## 反序列化节点运行态数据。
## [br]
## @api public
## [br]
## @param data: 运行态数据。
## [br]
## @schema data: serialize_runtime_state() 返回的运行态 Dictionary。
func deserialize_runtime_state(data: Dictionary) -> void:
	runtime_state = data.duplicate(true)


# --- 私有/辅助方法 ---

func _find_port(ports: Array[GFFlowPort], port_id: StringName) -> GFFlowPort:
	for port: GFFlowPort in ports:
		if port != null and _get_port_id(port) == port_id:
			return port
	return null


func _describe_ports(ports: Array[GFFlowPort]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for port: GFFlowPort in ports:
		if port != null:
			result.append(_describe_port(port))
	return result


func _describe_port(port: GFFlowPort) -> Dictionary:
	var port_id: StringName = _get_port_id(port)
	return {
		"port_id": port_id,
		"display_name": _get_port_display_name(port, port_id),
		"direction": port.direction,
		"value_type": port.value_type,
		"allow_multiple": port.allow_multiple,
		"editor_color": port.editor_color,
		"type_hint": port.type_hint,
		"class_name_hint": port.class_name_hint,
		"semantic_tags": port.semantic_tags.duplicate(),
		"metadata": port.metadata.duplicate(true),
	}


func _get_port_id(port: GFFlowPort) -> StringName:
	if port == null:
		return &""
	if port.port_id != &"":
		return port.port_id
	if not port.resource_path.is_empty():
		return StringName(port.resource_path)
	return &""


func _get_port_display_name(port: GFFlowPort, port_id: StringName) -> String:
	if port == null:
		return "Flow Port"
	if not port.display_name.is_empty():
		return port.display_name
	if port_id != &"":
		return String(port_id)
	if not port.resource_path.is_empty():
		return port.resource_path.get_file().get_basename().capitalize()
	return "Flow Port"
