## GFSignalBridgeBinding: 运行中的信号桥接连接。
##
## Binding 持有桥接资源、根节点和底层 GFSignalConnection，用于在运行时断开、
## 检查状态，并把原生信号参数转交给桥接规则。
class_name GFSignalBridgeBinding
extends RefCounted


# --- 公共变量 ---

## 桥接资源。
var bridge: GFSignalBridge = null

## 底层信号连接。
var connection: GFSignalConnection = null


# --- 私有变量 ---

var _root_ref: WeakRef = null


# --- 公共方法 ---

## 初始化绑定。
## @param new_bridge: 桥接资源。
## @param root: 路径解析根节点。
## @param new_connection: 底层连接。
func setup(new_bridge: GFSignalBridge, root: Node, new_connection: GFSignalConnection) -> void:
	bridge = new_bridge
	connection = new_connection
	_root_ref = weakref(root) if root != null else null


## 断开桥接。
func disconnect_bridge() -> void:
	if connection != null:
		connection.disconnect_signal()
	connection = null


## 当前绑定是否仍活跃。
## @return 活跃时返回 true。
func is_active() -> bool:
	return connection != null and connection.is_active() and _get_root() != null


# --- 私有/辅助方法 ---

func _invoke_from_signal(
	arg1: Variant = null,
	arg2: Variant = null,
	arg3: Variant = null,
	arg4: Variant = null,
	arg5: Variant = null,
	arg6: Variant = null,
	arg7: Variant = null,
	arg8: Variant = null
) -> void:
	var root := _get_root()
	if bridge == null or root == null:
		disconnect_bridge()
		return
	bridge.invoke(root, _collect_args(root, [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8]))


func _collect_args(root: Node, raw_args: Array) -> Array:
	if bridge == null or bridge.source == null:
		return _trim_trailing_null_args(raw_args)

	var argument_count := bridge.source.get_signal_argument_count(root)
	if argument_count >= 0:
		return raw_args.slice(0, mini(argument_count, raw_args.size()))
	return _trim_trailing_null_args(raw_args)


func _trim_trailing_null_args(raw_args: Array) -> Array:
	var result := raw_args.duplicate()
	while not result.is_empty() and result.back() == null:
		result.pop_back()
	return result


func _get_root() -> Node:
	if _root_ref == null:
		return null
	return _root_ref.get_ref() as Node
