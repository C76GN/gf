## GFAutoload: GF AutoLoad 运行时解析辅助。
##
## 用于避免框架脚本在首次导入、AutoLoad 尚未注册时直接引用全局 Gf 标识符。
class_name GFAutoload
extends RefCounted


# --- 常量 ---

## GF Framework 注册到场景树根节点下的 AutoLoad 名称。
const AUTOLOAD_NAME: StringName = &"Gf"


# --- 公共方法 ---

## 获取 Gf AutoLoad 节点；未注册或场景树不可用时返回 null。
## @return Gf AutoLoad 节点。
static func get_singleton_or_null() -> Node:
	var main_loop := Engine.get_main_loop()
	if main_loop == null or not (main_loop is SceneTree):
		return null

	var scene_tree := main_loop as SceneTree
	if scene_tree.root == null:
		return null

	return scene_tree.root.get_node_or_null(NodePath(String(AUTOLOAD_NAME))) as Node


## 检查全局 Gf 是否已经持有架构实例。
## @return 架构存在时返回 true。
static func has_architecture() -> bool:
	var singleton := get_singleton_or_null()
	if singleton == null or not singleton.has_method("has_architecture"):
		return false
	return bool(singleton.call("has_architecture"))


## 获取全局架构；AutoLoad 不可用或架构未初始化时返回 null。
## @return 当前全局架构实例。
static func get_architecture_or_null() -> GFArchitecture:
	var singleton := get_singleton_or_null()
	if singleton == null:
		return null
	if not singleton.has_method("has_architecture") or not singleton.has_method("get_architecture"):
		return null
	if not bool(singleton.call("has_architecture")):
		return null
	return singleton.call("get_architecture") as GFArchitecture


## 获取全局架构；不可用时输出明确错误。
## @return 当前全局架构实例。
static func get_architecture() -> GFArchitecture:
	var architecture := get_architecture_or_null()
	if architecture == null:
		push_error("[GFAutoload] Gf AutoLoad 未就绪或架构尚未初始化，请先启用 GF 插件并注册架构。")
	return architecture
