## GFSignalSourceRef: 可资源化的信号来源引用。
##
## 该资源只描述相对于某个根节点的信号来源节点和信号名，不连接信号、
## 不解释信号含义，也不绑定任何业务流程。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFSignalSourceRef
extends Resource


# --- 导出变量 ---

## 信号来源节点路径。为空时使用传入的根节点。
## [br]
## @api public
@export var source_path: NodePath = NodePath("")

## 要读取的信号名。
## [br]
## @api public
@export var signal_name: StringName = &""

## 项目自定义元数据。框架不解释该字段。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary，关联到信号来源引用的项目侧元数据。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 解析信号来源对象。
## [br]
## @api public
## [br]
## @param root: 路径解析根节点。
## [br]
## @return 来源对象；无法解析时返回 null。
func resolve_source(root: Node) -> Object:
	if root == null:
		return null
	if source_path.is_empty():
		return root
	return root.get_node_or_null(source_path)


## 获取信号。
## [br]
## @api public
## [br]
## @param root: 路径解析根节点。
## [br]
## @return 有效信号；无法解析时返回空 Signal。
func get_signal(root: Node) -> Signal:
	var source: Object = resolve_source(root)
	if source == null or signal_name == &"":
		return Signal()
	if not source.has_signal(signal_name):
		return Signal()
	return Signal(source, signal_name)


## 检查信号来源是否有效。
## [br]
## @api public
## [br]
## @param root: 路径解析根节点。
## [br]
## @return 有效时返回 true。
func is_valid_for(root: Node) -> bool:
	return not get_signal(root).is_null()


## 获取信号参数数量。
## [br]
## @api public
## [br]
## @param root: 路径解析根节点。
## [br]
## @return 参数数量；无法确定时返回 -1。
func get_signal_argument_count(root: Node) -> int:
	var source: Object = resolve_source(root)
	if source == null or signal_name == &"":
		return -1

	for signal_info: Dictionary in source.get_signal_list():
		if GFVariantData.get_option_string_name(signal_info, "name") != signal_name:
			continue

		var args: Array = GFVariantData.get_option_array(signal_info, "args")
		return args.size()
	return -1


## 转换为调试字典。
## [br]
## @api public
## [br]
## @return 来源快照。
## [br]
## @schema return: Dictionary，包含 source_path、signal_name 和 metadata。
func to_dictionary() -> Dictionary:
	return {
		"source_path": source_path,
		"signal_name": signal_name,
		"metadata": metadata.duplicate(true),
	}
