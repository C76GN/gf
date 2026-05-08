## 测试通用交互 Sensor/Receiver 节点。
extends GutTest


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
