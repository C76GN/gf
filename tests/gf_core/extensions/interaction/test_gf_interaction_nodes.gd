## 测试通用交互 Sensor/Receiver 节点。
extends GutTest


# --- 常量 ---

const GF_MESSAGE_DISPATCH_SUPPORT := preload("res://addons/gf/standard/common/gf_message_dispatch_support.gd")
const GFPointerInteraction3DBase := preload("res://addons/gf/extensions/interaction/nodes/gf_pointer_interaction_3d.gd")


# --- 辅助类 ---

class RecordingReceiver extends GFInteractionReceiver:
	var received_context: GFInteractionContext = null
	var validate_count: int = 0

	func _init() -> void:
		validation_callback = Callable(self, "_validate_interaction")

	func _validate_interaction(context: GFInteractionContext, _report: Dictionary) -> Dictionary:
		received_context = context
		validate_count += 1
		return {
			"ok": true,
			"metadata": {
				"validated": true,
			},
		}


class BusinessInteractionReceiver extends Node:
	var received_context: GFInteractionContext = null
	var received_id: StringName = &""

	func receive_interaction(context: GFInteractionContext, interaction_id: StringName = &"") -> Dictionary:
		received_context = context
		received_id = interaction_id
		return {
			"ok": true,
			"interaction_id": interaction_id,
			"receiver": self,
			"reason": "handled",
			"message": "",
			"metadata": {
				"business": true,
			},
		}


class RecordingDispatchHost extends RefCounted:
	var received_receiver: Object = null
	var received_payload: Variant = null
	var received_id: StringName = &""

	func send_to(receiver: Object, payload_override: Variant = null, id_override: StringName = &"") -> Dictionary:
		received_receiver = receiver
		received_payload = payload_override
		received_id = id_override
		return {
			"ok": true,
			"receiver": receiver,
			"interaction_id": id_override,
			"metadata": {},
		}


# --- 测试方法 ---

func test_sensor_send_to_receiver_builds_context_and_report() -> void:
	var sensor := GFInteractionSensor.new()
	var receiver := RecordingReceiver.new()
	add_child_autofree(sensor)
	add_child_autofree(receiver)
	sensor.interaction_id = &"use"
	sensor.group_name = &"nearby"
	sensor.payload = { "amount": 2 }

	var report := sensor.send_to(receiver)

	assert_true(bool(report["ok"]), "有效接收器应接受交互。")
	assert_same(receiver.received_context.sender, sensor, "默认 sender 应为 Sensor 自身。")
	assert_same(receiver.received_context.target, receiver, "上下文 target 应指向接收器。")
	assert_eq((receiver.received_context.payload as Dictionary)["amount"], 2, "payload 应写入上下文。")
	assert_eq(receiver.received_context.group_name, &"nearby", "group_name 应写入上下文。")
	assert_true(bool((report["metadata"] as Dictionary)["validated"]), "接收器校验结果应合并 metadata。")


func test_receiver_filters_interaction_ids() -> void:
	var receiver := GFInteractionReceiver.new()
	add_child_autofree(receiver)
	receiver.accepted_interaction_ids = [&"open"]

	var rejected := receiver.receive_interaction(GFInteractionContext.new(), &"use")
	var accepted := receiver.receive_interaction(GFInteractionContext.new(), &"open")

	assert_false(bool(rejected["ok"]), "不在 accepted_interaction_ids 内的交互应被拒绝。")
	assert_eq(rejected["reason"], "unaccepted_id")
	assert_true(bool(accepted["ok"]), "允许的交互 ID 应通过基础过滤。")


func test_receiver_path_forwards_interaction_to_business_receiver() -> void:
	var root := Node.new()
	var bridge := GFInteractionReceiver.new()
	var business_receiver := BusinessInteractionReceiver.new()
	add_child_autofree(root)
	root.add_child(bridge)
	root.add_child(business_receiver)
	bridge.name = "InteractionAreaBridge"
	business_receiver.name = "BusinessReceiver"
	bridge.receiver_path = NodePath("../BusinessReceiver")
	bridge.accepted_interaction_ids = [&"use"]
	watch_signals(bridge)

	var context := GFInteractionContext.new(null, bridge, { "item": "door" })
	var report := bridge.receive_interaction(context, &"use")

	assert_true(bool(report["ok"]), "通过本地过滤的交互应转发给业务接收器。")
	assert_same(business_receiver.received_context, context, "业务接收器应收到同一个交互上下文。")
	assert_same(context.target, business_receiver, "转发时上下文 target 应更新为业务接收器。")
	assert_eq(business_receiver.received_id, &"use", "交互 ID 应透传给业务接收器。")
	assert_same(report["receiver"], business_receiver, "最终报告应来自业务接收器。")
	assert_true(bool((report["metadata"] as Dictionary)["business"]), "业务接收器返回的报告应成为最终报告。")
	assert_signal_emitted(bridge, "interaction_received", "业务接收成功后桥接节点应发出接收信号。")


func test_receiver_path_does_not_forward_rejected_interaction() -> void:
	var root := Node.new()
	var bridge := GFInteractionReceiver.new()
	var business_receiver := BusinessInteractionReceiver.new()
	add_child_autofree(root)
	root.add_child(bridge)
	root.add_child(business_receiver)
	business_receiver.name = "BusinessReceiver"
	bridge.receiver_path = NodePath("../BusinessReceiver")
	bridge.accepted_interaction_ids = [&"open"]

	var report := bridge.receive_interaction(GFInteractionContext.new(null, bridge), &"use")

	assert_false(bool(report["ok"]), "未通过本地 ID 过滤的交互不应转发。")
	assert_eq(report["reason"], "unaccepted_id")
	assert_null(business_receiver.received_context, "被本地拒绝时业务接收器不应收到上下文。")


func test_sensor_rejects_invalid_receiver() -> void:
	var sensor := GFInteractionSensor.new()
	var invalid_receiver := Node.new()
	add_child_autofree(sensor)
	add_child_autofree(invalid_receiver)

	var report := sensor.send_to(invalid_receiver)

	assert_false(bool(report["ok"]), "缺少 receive_interaction() 的对象应被拒绝。")
	assert_eq(report["reason"], "invalid_receiver")


func test_sensor_broadcast_to_group_sends_to_receivers() -> void:
	var sensor := GFInteractionSensor.new()
	var receiver_a := RecordingReceiver.new()
	var receiver_b := RecordingReceiver.new()
	add_child_autofree(sensor)
	add_child_autofree(receiver_a)
	add_child_autofree(receiver_b)
	sensor.group_name = &"targets"
	receiver_a.add_to_group("targets")
	receiver_b.add_to_group("targets")

	var reports := sensor.broadcast_to_group()

	assert_eq(reports.size(), 2, "广播应发送给分组中的所有接收器。")
	assert_eq(receiver_a.validate_count + receiver_b.validate_count, 2, "每个接收器都应收到一次交互。")


func test_sensor_collision_candidates_resolve_receiver_ancestors() -> void:
	var host := RecordingDispatchHost.new()
	var receiver := RecordingReceiver.new()
	var collider_child := Node.new()
	add_child_autofree(receiver)
	receiver.add_child(collider_child)

	var reports: Array[Dictionary] = []
	reports.assign(GF_MESSAGE_DISPATCH_SUPPORT._send_to_collision_candidates(
		host,
		[collider_child],
		0,
		{ "value": 3 },
		&"hit",
		&"receive_interaction"
	))

	assert_eq(reports.size(), 1, "碰撞候选应能向上解析到交互接收器。")
	assert_true(bool(reports[0]["ok"]), "解析到的接收器应交给发送宿主。")
	assert_same(host.received_receiver, receiver, "交互上下文 target 应使用解析后的接收器。")
	assert_eq(host.received_payload, { "value": 3 }, "payload 覆盖值应透传给发送宿主。")
	assert_eq(host.received_id, &"hit", "交互 ID 覆盖值应透传给发送宿主。")


func test_pointer_interaction_3d_sends_click_context_to_receiver() -> void:
	var root := Node3D.new()
	var body := StaticBody3D.new()
	var receiver := RecordingReceiver.new()
	var pointer := GFPointerInteraction3DBase.new()
	add_child_autofree(root)
	root.add_child(body)
	root.add_child(receiver)
	body.add_child(pointer)
	pointer.receiver_path = NodePath("../../RecordingReceiver")
	receiver.name = "RecordingReceiver"
	pointer.interaction_id = &"inspect"
	pointer.payload = { "kind": "object" }
	pointer.bind_collision_object(body)

	var press := _make_mouse_button(MOUSE_BUTTON_LEFT, true)
	var release := _make_mouse_button(MOUSE_BUTTON_LEFT, false)
	pointer._on_collision_input_event(null, press, Vector3(1.0, 2.0, 3.0), Vector3.UP, 0)
	pointer._on_collision_input_event(null, release, Vector3(1.0, 2.0, 3.0), Vector3.UP, 0)

	assert_not_null(receiver.received_context, "点击应发送交互上下文。")
	assert_same(receiver.received_context.target, receiver, "上下文 target 应为解析到的接收器。")
	assert_eq((receiver.received_context.payload as Dictionary)["kind"], "object", "基础 payload 应保留。")
	assert_eq((receiver.received_context.payload as Dictionary)["pointer_event"], &"clicked", "点击事件应写入 payload。")
	assert_eq((receiver.received_context.payload as Dictionary)["pointer_position"], Vector3(1.0, 2.0, 3.0), "点击位置应写入 payload。")


func test_pointer_interaction_3d_emits_hover_without_sending_by_default() -> void:
	var root := Node3D.new()
	var body := StaticBody3D.new()
	var receiver := RecordingReceiver.new()
	var pointer := GFPointerInteraction3DBase.new()
	var entered: Array[GFInteractionContext] = []
	add_child_autofree(root)
	root.add_child(body)
	root.add_child(receiver)
	body.add_child(pointer)
	pointer.receiver_path = NodePath("../../RecordingReceiver")
	receiver.name = "RecordingReceiver"
	pointer.pointer_entered.connect(func(context: GFInteractionContext) -> void:
		entered.append(context)
	)
	pointer.bind_collision_object(body)

	pointer._on_collision_mouse_entered()

	assert_eq(entered.size(), 1, "hover 进入应发出本地信号。")
	assert_null(receiver.received_context, "默认不应把 hover 自动发送给接收器。")


# --- 私有/辅助方法 ---

func _make_mouse_button(button_index: MouseButton, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button_index
	event.pressed = pressed
	return event
