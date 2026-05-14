## GFPointerInteraction3D: 将 3D 指针事件桥接为 GFInteractionContext。
##
## 监听 CollisionObject3D 的 hover、鼠标按钮与滚轮事件，构建通用交互上下文。
## 节点只传递位置、法线、按钮、标签和元数据，不解释点击对象的业务含义。
class_name GFPointerInteraction3D
extends Node


# --- 信号 ---

## 指针进入绑定的 3D 碰撞对象。
## @param context: 交互上下文。
signal pointer_entered(context: GFInteractionContext)

## 指针离开绑定的 3D 碰撞对象。
## @param context: 交互上下文。
signal pointer_exited(context: GFInteractionContext)

## 指针按钮按下。
## @param context: 交互上下文。
## @param event: 原始输入事件。
signal pointer_pressed(context: GFInteractionContext, event: InputEventMouseButton)

## 指针按钮释放。
## @param context: 交互上下文。
## @param event: 原始输入事件。
signal pointer_released(context: GFInteractionContext, event: InputEventMouseButton)

## 指针完成一次点击。
## @param context: 交互上下文。
## @param event: 原始输入事件。
signal pointer_clicked(context: GFInteractionContext, event: InputEventMouseButton)

## 指针滚轮事件。
## @param context: 交互上下文。
## @param event: 原始输入事件。
signal pointer_wheel(context: GFInteractionContext, event: InputEventMouseButton)

## 已向接收器发送交互。
## @param context: 交互上下文。
## @param receiver: 接收对象。
## @param report: 结果报告。
signal pointer_interaction_sent(context: GFInteractionContext, receiver: Object, report: Dictionary)


# --- 常量 ---

const _MESSAGE_DISPATCH_SUPPORT: Script = preload("res://addons/gf/standard/common/gf_message_dispatch_support.gd")


# --- 导出变量 ---

## 是否启用指针桥接。
@export var enabled: bool = true

## 默认交互 ID。
@export var interaction_id: StringName = &""

## 默认交互分组。
@export var group_name: StringName = &""

## 默认 payload；发送时会深拷贝并附加 pointer_* 字段。
@export var payload: Dictionary = {}

## 指针标签。框架不解释标签含义。
@export var tags: PackedStringArray = PackedStringArray()

## 自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}

## 可选 3D 碰撞对象路径；为空时优先使用父节点。
@export_node_path("CollisionObject3D") var collision_object_path: NodePath = NodePath("")

## 可选交互接收器路径；为空时从碰撞对象向父级解析 receive_interaction()。
@export_node_path("Node") var receiver_path: NodePath = NodePath("")

## 可选发送者路径；为空时使用当前节点。
@export_node_path("Node") var sender_path: NodePath = NodePath("")

## 是否在点击完成时发送交互。
@export var send_on_clicked: bool = true

## 是否在按钮按下时发送交互。
@export var send_on_pressed: bool = false

## 是否在按钮释放时发送交互。
@export var send_on_released: bool = false

## 是否在滚轮事件时发送交互。
@export var send_on_wheel: bool = false

## 是否在 hover 进入和离开时发送交互。
@export var send_on_hover: bool = false

## 绑定碰撞对象时是否确保 input_ray_pickable 为 true。
@export var ensure_input_ray_pickable: bool = true

## hover 时是否临时切换鼠标光标。
@export var change_cursor_on_hover: bool = false

## hover 时使用的鼠标光标。
@export var cursor_shape: Input.CursorShape = Input.CURSOR_ARROW


# --- 私有变量 ---

var _collision_object_ref: WeakRef = null
var _is_hovered: bool = false
var _pressed_button: int = 0
var _pressed_shape_idx: int = -1


# --- Godot 生命周期方法 ---

func _ready() -> void:
	bind_collision_object(_resolve_collision_object())


func _exit_tree() -> void:
	_disconnect_collision_object()


# --- 公共方法 ---

## 绑定 3D 碰撞对象。
## @param collision_object: 要监听的碰撞对象。
func bind_collision_object(collision_object: CollisionObject3D) -> void:
	_disconnect_collision_object()
	if collision_object == null:
		return

	_collision_object_ref = weakref(collision_object)
	if ensure_input_ray_pickable:
		collision_object.input_ray_pickable = true
	if not collision_object.mouse_entered.is_connected(_on_collision_mouse_entered):
		collision_object.mouse_entered.connect(_on_collision_mouse_entered)
	if not collision_object.mouse_exited.is_connected(_on_collision_mouse_exited):
		collision_object.mouse_exited.connect(_on_collision_mouse_exited)
	if not collision_object.input_event.is_connected(_on_collision_input_event):
		collision_object.input_event.connect(_on_collision_input_event)


## 获取当前绑定的 3D 碰撞对象。
## @return 碰撞对象；不存在时返回 null。
func get_collision_object() -> CollisionObject3D:
	if _collision_object_ref == null:
		return null
	return _collision_object_ref.get_ref() as CollisionObject3D


## 构建指针交互上下文。
## @param pointer_event: 指针事件标识。
## @param pointer_data: 指针事件数据。
## @param receiver: 可选接收对象；为空时自动解析。
## @return 交互上下文。
func build_context(
	pointer_event: StringName,
	pointer_data: Dictionary = {},
	receiver: Object = null
) -> GFInteractionContext:
	var effective_receiver := receiver if receiver != null else _resolve_receiver()
	var context_payload := payload.duplicate(true)
	context_payload["pointer_event"] = pointer_event
	context_payload["pointer_tags"] = tags.duplicate()
	context_payload["pointer_metadata"] = metadata.duplicate(true)
	for key: Variant in pointer_data.keys():
		context_payload[key] = GFVariantData.duplicate_variant(pointer_data[key])

	return GFInteractionContext.new(_resolve_sender(), effective_receiver, context_payload, group_name)


## 发送一次指针交互。
## @param pointer_event: 指针事件标识。
## @param pointer_data: 指针事件数据。
## @param interaction_id_override: 可选交互 ID 覆盖。
## @return 统一结果报告。
func send_pointer_interaction(
	pointer_event: StringName,
	pointer_data: Dictionary = {},
	interaction_id_override: StringName = &""
) -> Dictionary:
	var receiver := _resolve_receiver()
	var context := build_context(pointer_event, pointer_data, receiver)
	var effective_interaction_id := interaction_id_override if interaction_id_override != &"" else interaction_id
	var report: Dictionary = _MESSAGE_DISPATCH_SUPPORT._dispatch_to_receiver(
		enabled,
		metadata,
		receiver,
		&"receive_interaction",
		[context, effective_interaction_id],
		"interaction_id",
		effective_interaction_id,
		"Pointer interaction bridge is disabled.",
		"Pointer interaction receiver is null.",
		"Receiver does not expose receive_interaction().",
		"Receiver returned an invalid interaction report."
	) as Dictionary
	pointer_interaction_sent.emit(context, receiver, report)
	return report


# --- 私有/辅助方法 ---

func _resolve_collision_object() -> CollisionObject3D:
	if collision_object_path != NodePath(""):
		var node := get_node_or_null(collision_object_path)
		if node is CollisionObject3D:
			return node as CollisionObject3D
	return get_parent() as CollisionObject3D


func _disconnect_collision_object() -> void:
	var collision_object := get_collision_object()
	if collision_object == null:
		_collision_object_ref = null
		return
	if collision_object.mouse_entered.is_connected(_on_collision_mouse_entered):
		collision_object.mouse_entered.disconnect(_on_collision_mouse_entered)
	if collision_object.mouse_exited.is_connected(_on_collision_mouse_exited):
		collision_object.mouse_exited.disconnect(_on_collision_mouse_exited)
	if collision_object.input_event.is_connected(_on_collision_input_event):
		collision_object.input_event.disconnect(_on_collision_input_event)
	_collision_object_ref = null


func _resolve_receiver() -> Object:
	if receiver_path != NodePath(""):
		var receiver := get_node_or_null(receiver_path)
		if receiver != null:
			return receiver
	return _MESSAGE_DISPATCH_SUPPORT._resolve_receiver(get_collision_object(), &"receive_interaction")


func _resolve_sender() -> Object:
	if sender_path != NodePath(""):
		var sender := get_node_or_null(sender_path)
		if sender != null:
			return sender
	return self


func _make_pointer_data(
	event_name: StringName,
	camera: Camera3D = null,
	input_event: InputEvent = null,
	position: Vector3 = Vector3.ZERO,
	normal: Vector3 = Vector3.ZERO,
	shape_idx: int = -1
) -> Dictionary:
	var collision_object := get_collision_object()
	return {
		"pointer_event": event_name,
		"pointer_position": position,
		"pointer_normal": normal,
		"pointer_shape_idx": shape_idx,
		"pointer_camera": camera,
		"pointer_input_event": input_event,
		"pointer_collision_path": collision_object.get_path() if collision_object != null and collision_object.is_inside_tree() else NodePath(""),
	}


func _make_mouse_button_data(
	event_name: StringName,
	camera: Camera3D,
	event: InputEventMouseButton,
	position: Vector3,
	normal: Vector3,
	shape_idx: int
) -> Dictionary:
	var data := _make_pointer_data(event_name, camera, event, position, normal, shape_idx)
	data["pointer_button_index"] = event.button_index
	data["pointer_pressed"] = event.pressed
	data["pointer_factor"] = event.factor
	return data


func _emit_or_send_hover(event_name: StringName) -> void:
	var context := build_context(event_name, _make_pointer_data(event_name))
	if event_name == &"entered":
		pointer_entered.emit(context)
	else:
		pointer_exited.emit(context)
	if send_on_hover:
		send_pointer_interaction(event_name, _make_pointer_data(event_name))


func _emit_or_send_button_event(
	event_name: StringName,
	camera: Camera3D,
	event: InputEventMouseButton,
	position: Vector3,
	normal: Vector3,
	shape_idx: int,
	should_send: bool
) -> GFInteractionContext:
	var data := _make_mouse_button_data(event_name, camera, event, position, normal, shape_idx)
	var context := build_context(event_name, data)
	match event_name:
		&"pressed":
			pointer_pressed.emit(context, event)
		&"released":
			pointer_released.emit(context, event)
		&"clicked":
			pointer_clicked.emit(context, event)
		&"wheel":
			pointer_wheel.emit(context, event)
	if should_send:
		send_pointer_interaction(event_name, data)
	return context


func _is_wheel_button(button_index: int) -> bool:
	return button_index == MOUSE_BUTTON_WHEEL_UP or button_index == MOUSE_BUTTON_WHEEL_DOWN or button_index == MOUSE_BUTTON_WHEEL_LEFT or button_index == MOUSE_BUTTON_WHEEL_RIGHT


func _set_hover_cursor(active: bool) -> void:
	if not change_cursor_on_hover:
		return
	Input.set_default_cursor_shape(cursor_shape if active else Input.CURSOR_ARROW)


# --- 信号处理函数 ---

func _on_collision_mouse_entered() -> void:
	if not enabled:
		return
	_is_hovered = true
	_set_hover_cursor(true)
	_emit_or_send_hover(&"entered")


func _on_collision_mouse_exited() -> void:
	if not enabled:
		return
	_is_hovered = false
	_pressed_button = 0
	_pressed_shape_idx = -1
	_set_hover_cursor(false)
	_emit_or_send_hover(&"exited")


func _on_collision_input_event(
	camera: Camera3D,
	event: InputEvent,
	position: Vector3,
	normal: Vector3,
	shape_idx: int
) -> void:
	if not enabled or not (event is InputEventMouseButton):
		return

	var mouse_event := event as InputEventMouseButton
	if _is_wheel_button(mouse_event.button_index):
		if mouse_event.pressed:
			_emit_or_send_button_event(&"wheel", camera, mouse_event, position, normal, shape_idx, send_on_wheel)
		return

	if mouse_event.pressed:
		_pressed_button = mouse_event.button_index
		_pressed_shape_idx = shape_idx
		_emit_or_send_button_event(&"pressed", camera, mouse_event, position, normal, shape_idx, send_on_pressed)
		return

	var was_matching_press := _pressed_button == mouse_event.button_index and _pressed_shape_idx == shape_idx
	_pressed_button = 0
	_pressed_shape_idx = -1
	_emit_or_send_button_event(&"released", camera, mouse_event, position, normal, shape_idx, send_on_released)
	if was_matching_press:
		_emit_or_send_button_event(&"clicked", camera, mouse_event, position, normal, shape_idx, send_on_clicked)
