## GFFlowPort: 流程节点端口描述。
##
## 端口只描述节点对外暴露的输入/输出能力，供编辑器、校验器或项目层
## 构建可视化流程使用；运行时如何解释端口数据仍由具体节点决定。
class_name GFFlowPort
extends Resource


# --- 枚举 ---

## 端口方向。
enum Direction {
	## 输入端口。
	INPUT,
	## 输出端口。
	OUTPUT,
}

## 端口值类型提示。
enum ValueType {
	## 任意值。
	ANY,
	## 布尔。
	BOOL,
	## 数值。
	NUMBER,
	## 字符串。
	STRING,
	## Vector2。
	VECTOR2,
	## Vector3。
	VECTOR3,
	## Dictionary。
	DICTIONARY,
	## Array。
	ARRAY,
	## Object 或 Resource。
	OBJECT,
}


# --- 导出变量 ---

## 端口稳定标识。
@export var port_id: StringName = &""

## 显示名称。
@export var display_name: String = ""

## 端口方向。
@export var direction: Direction = Direction.OUTPUT

## 值类型提示。
@export var value_type: ValueType = ValueType.ANY

## 是否允许多条连接。
@export var allow_multiple: bool = false

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取端口标识。
## @return 端口标识。
func get_port_id() -> StringName:
	if port_id != &"":
		return port_id
	if not resource_path.is_empty():
		return StringName(resource_path)
	return &""


## 获取显示名称。
## @return 显示名称。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if port_id != &"":
		return String(port_id)
	if not resource_path.is_empty():
		return resource_path.get_file().get_basename().capitalize()
	return "Flow Port"


## 描述端口。
## @return 端口描述字典。
func describe() -> Dictionary:
	return {
		"port_id": get_port_id(),
		"display_name": get_display_name(),
		"direction": direction,
		"value_type": value_type,
		"allow_multiple": allow_multiple,
		"metadata": metadata.duplicate(true),
	}
