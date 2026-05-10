## GFHitBoxState3D: 3D 命中区域状态组。
##
## 统一启停子树内的 GFHitBox3D、GFHurtBox3D 与 Area3D，不处理伤害、阵营或技能规则。
class_name GFHitBoxState3D
extends Node3D


# --- 信号 ---

## 状态应用后发出。
## @param active: 当前是否激活。
signal active_changed(active: bool)


# --- 导出变量 ---

## 当前状态是否激活。
@export var active: bool = true:
	set(value):
		if active == value:
			return
		active = value
		if is_inside_tree():
			apply_state()
			active_changed.emit(active)

## 是否在 _ready() 时应用当前状态。
@export var apply_on_ready: bool = true

## 是否递归管理子节点。
@export var recursive: bool = true

## 是否同步 GFHitBox3D/GFHurtBox3D 的 enabled 字段。
@export var manage_enabled: bool = true

## 是否同步 Area3D 的 monitoring 与 monitorable。
@export var manage_monitoring: bool = true

## 是否同步 Node3D.visible。
@export var manage_visibility: bool = false


# --- Godot 生命周期方法 ---

func _ready() -> void:
	if apply_on_ready:
		apply_state()


# --- 公共方法 ---

## 激活状态组。
func activate() -> void:
	set_active_state(true)


## 关闭状态组。
func deactivate() -> void:
	set_active_state(false)


## 设置状态组激活状态。
## @param value: 是否激活。
func set_active_state(value: bool) -> void:
	active = value
	if is_inside_tree():
		apply_state()
		active_changed.emit(active)


## 应用当前状态到所有受管理节点。
func apply_state() -> void:
	for node: Node in get_managed_nodes():
		_apply_to_node(node)


## 获取受管理节点列表。
## @return 节点列表。
func get_managed_nodes() -> Array[Node]:
	var result: Array[Node] = []
	_collect_managed_nodes(self, result)
	return result


# --- 私有/辅助方法 ---

func _collect_managed_nodes(parent: Node, result: Array[Node]) -> void:
	for child: Node in parent.get_children():
		if _is_managed_node(child):
			result.append(child)
		if recursive:
			_collect_managed_nodes(child, result)


func _is_managed_node(node: Node) -> bool:
	return node is GFHitBox3D or node is GFHurtBox3D or node is Area3D


func _apply_to_node(node: Node) -> void:
	if manage_enabled:
		if node is GFHitBox3D:
			(node as GFHitBox3D).enabled = active
		elif node is GFHurtBox3D:
			(node as GFHurtBox3D).enabled = active

	if manage_monitoring and node is Area3D:
		var area := node as Area3D
		area.monitoring = active
		area.monitorable = active

	if manage_visibility and node is Node3D:
		(node as Node3D).visible = active
