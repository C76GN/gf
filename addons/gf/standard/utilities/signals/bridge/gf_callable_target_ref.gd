## GFCallableTargetRef: 可资源化的 Callable 目标引用。
##
## 该资源只描述相对于某个根节点的目标节点、方法名和默认参数。
## 它不决定调用时机，也不解释方法的业务含义。
class_name GFCallableTargetRef
extends Resource


# --- 导出变量 ---

## 目标节点路径。为空时使用传入的根节点。
@export var target_path: NodePath = NodePath("")

## 要调用的方法名。
@export var method_name: StringName = &""

## 每次调用时追加到末尾的默认参数。
@export var default_args: Array = []

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 解析调用目标。
## @param root: 路径解析根节点。
## @return 目标对象；无法解析时返回 null。
func resolve_target(root: Node) -> Object:
	if root == null:
		return null
	if target_path.is_empty():
		return root
	return root.get_node_or_null(target_path)


## 创建目标 Callable。
## @param root: 路径解析根节点。
## @return 有效 Callable；无法解析时返回空 Callable。
func get_callable(root: Node) -> Callable:
	var target := resolve_target(root)
	if target == null or method_name == &"":
		return Callable()
	if not target.has_method(method_name):
		return Callable()
	return Callable(target, method_name)


## 检查调用目标是否有效。
## @param root: 路径解析根节点。
## @return 有效时返回 true。
func is_valid_for(root: Node) -> bool:
	return get_callable(root).is_valid()


## 调用目标方法。
## @param root: 路径解析根节点。
## @param args: 动态参数。
## @return 结构化调用结果。
func call_with_args(root: Node, args: Array = []) -> Dictionary:
	var callable := get_callable(root)
	if not callable.is_valid():
		return {
			"ok": false,
			"reason": &"invalid_callable_target",
			"value": null,
		}

	var call_args := args.duplicate()
	call_args.append_array(default_args)
	return {
		"ok": true,
		"reason": &"ok",
		"value": callable.callv(call_args),
	}


## 转换为调试字典。
## @return 目标快照。
func to_dictionary() -> Dictionary:
	return {
		"target_path": target_path,
		"method_name": method_name,
		"default_args": default_args.duplicate(true),
		"metadata": metadata.duplicate(true),
	}
