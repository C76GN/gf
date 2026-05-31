## GFHitBoxState2D: 2D 命中区域状态组。
##
## 统一启停子树内的 GFHitBox2D、GFHurtBox2D 与 Area2D，不处理伤害、阵营或技能规则。
## [br]
## @api public
## [br]
## @category runtime_handle
## [br]
## @since 3.17.0
class_name GFHitBoxState2D
extends Node2D


# --- 信号 ---

## 状态应用后发出。
## [br]
## @api public
## [br]
## @param active: 当前是否激活。
signal active_changed(active: bool)


# --- 导出变量 ---

## 当前状态是否激活。
## [br]
## @api public
@export var active: bool = true:
	set(value):
		if active == value:
			return
		active = value
		if is_inside_tree():
			apply_state()
			active_changed.emit(active)

## 是否在 _ready() 时应用当前状态。
## [br]
## @api public
@export var apply_on_ready: bool = true

## 是否递归管理子节点。
## [br]
## @api public
@export var recursive: bool = true

## 是否同步 GFHitBox2D/GFHurtBox2D 的 enabled 字段。
## [br]
## @api public
@export var manage_enabled: bool = true

## 是否同步 Area2D 的 monitoring 与 monitorable。
## [br]
## @api public
@export var manage_monitoring: bool = true

## 是否同步 CanvasItem.visible。
## [br]
## @api public
@export var manage_visibility: bool = false


# --- Godot 生命周期方法 ---

func _ready() -> void:
	if apply_on_ready:
		apply_state()


# --- 公共方法 ---

## 激活状态组。
## [br]
## @api public
func activate() -> void:
	set_active_state(true)


## 关闭状态组。
## [br]
## @api public
func deactivate() -> void:
	set_active_state(false)


## 设置状态组激活状态。
## [br]
## @api public
## [br]
## @param value: 是否激活。
func set_active_state(value: bool) -> void:
	active = value
	if is_inside_tree():
		apply_state()
		active_changed.emit(active)


## 应用当前状态到所有受管理节点。
## [br]
## @api public
func apply_state() -> void:
	for node: Node in get_managed_nodes():
		_apply_to_node(node)


## 获取受管理节点列表。
## [br]
## @api public
## [br]
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
	return node is GFHitBox2D or node is GFHurtBox2D or node is Area2D


func _apply_to_node(node: Node) -> void:
	if manage_enabled:
		if node is GFHitBox2D:
			var hit_box: GFHitBox2D = node
			hit_box.enabled = active
		elif node is GFHurtBox2D:
			var hurt_box: GFHurtBox2D = node
			hurt_box.enabled = active

	if manage_monitoring and node is Area2D:
		var area: Area2D = node
		area.monitoring = active
		area.monitorable = active

	if manage_visibility and node is CanvasItem:
		var canvas_item: CanvasItem = node
		canvas_item.visible = active
