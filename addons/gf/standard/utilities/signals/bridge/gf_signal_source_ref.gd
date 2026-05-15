## GFSignalSourceRef: 可资源化的信号来源引用。
##
## 该资源只描述相对于某个根节点的信号来源节点和信号名，不连接信号、
## 不解释信号含义，也不绑定任何业务流程。
class_name GFSignalSourceRef
extends Resource


# --- 导出变量 ---

## 信号来源节点路径。为空时使用传入的根节点。
@export var source_path: NodePath = NodePath("")

## 要读取的信号名。
@export var signal_name: StringName = &""

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 解析信号来源对象。
## @param root: 路径解析根节点。
## @return 来源对象；无法解析时返回 null。
func resolve_source(root: Node) -> Object:
	if root == null:
		return null
	if source_path.is_empty():
		return root
	return root.get_node_or_null(source_path)


## 获取信号。
## @param root: 路径解析根节点。
## @return 有效信号；无法解析时返回空 Signal。
func get_signal(root: Node) -> Signal:
	var source := resolve_source(root)
	if source == null or signal_name == &"":
		return Signal()
	if not source.has_signal(signal_name):
		return Signal()
	return Signal(source, signal_name)


## 检查信号来源是否有效。
## @param root: 路径解析根节点。
## @return 有效时返回 true。
func is_valid_for(root: Node) -> bool:
	return not get_signal(root).is_null()


## 获取信号参数数量。
## @param root: 路径解析根节点。
## @return 参数数量；无法确定时返回 -1。
func get_signal_argument_count(root: Node) -> int:
	var source := resolve_source(root)
	if source == null or signal_name == &"":
		return -1

	for signal_info: Dictionary in source.get_signal_list():
		if StringName(signal_info.get("name", &"")) != signal_name:
			continue

		var args: Array = signal_info.get("args", [])
		return args.size()
	return -1


## 转换为调试字典。
## @return 来源快照。
func to_dictionary() -> Dictionary:
	return {
		"source_path": source_path,
		"signal_name": signal_name,
		"metadata": metadata.duplicate(true),
	}
