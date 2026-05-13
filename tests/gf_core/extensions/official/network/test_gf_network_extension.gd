## 测试 GF 网络抽象的消息编码、后端桥接与限流器。
extends GutTest


# --- 常量 ---

const GFNetworkBackendBase = preload("res://addons/gf/extensions/official/network/backends/gf_network_backend.gd")
const GFNetworkChannelBase = preload("res://addons/gf/extensions/official/network/session/gf_network_channel.gd")
const GFENetNetworkBackendBase = preload("res://addons/gf/extensions/official/network/backends/gf_enet_network_backend.gd")
const GFWebSocketNetworkBackendBase = preload("res://addons/gf/extensions/official/network/backends/gf_websocket_network_backend.gd")
const GFNetworkMessageBase = preload("res://addons/gf/extensions/official/network/messages/gf_network_message.gd")
const GFNetworkMessageValidatorBase = preload("res://addons/gf/extensions/official/network/messages/gf_network_message_validator.gd")
const GFNetworkRateLimiterBase = preload("res://addons/gf/extensions/official/network/session/gf_network_rate_limiter.gd")
const GFNetworkReconnectPolicyBase = preload("res://addons/gf/extensions/official/network/session/gf_network_reconnect_policy.gd")
const GFNetworkSerializerBase = preload("res://addons/gf/extensions/official/network/serialization/gf_network_serializer.gd")
const GFNetworkFieldSerializerBase = preload("res://addons/gf/extensions/official/network/serialization/gf_network_field_serializer.gd")
const GFNetworkSnapshotSchemaBase = preload("res://addons/gf/extensions/official/network/snapshot/gf_network_snapshot_schema.gd")
const GFNetworkUtilityBase = preload("res://addons/gf/extensions/official/network/runtime/gf_network_utility.gd")
const GFFixedTickClockBase = preload("res://addons/gf/extensions/official/network/simulation/gf_fixed_tick_clock.gd")
const GFNetworkHistoryBufferBase = preload("res://addons/gf/extensions/official/network/snapshot/gf_network_history_buffer.gd")
const GFNetworkSnapshotBase = preload("res://addons/gf/extensions/official/network/snapshot/gf_network_snapshot.gd")


# --- 辅助类 ---

class FakeBackend extends GFNetworkBackend:
	var sent_peer_id: int = 0
	var sent_bytes: PackedByteArray = PackedByteArray()
	var sent_options: Dictionary = {}

	func send_bytes(peer_id: int, bytes: PackedByteArray, options: Dictionary = {}) -> Error:
		sent_peer_id = peer_id
		sent_bytes = bytes
		sent_options = options.duplicate(true)
		return OK

	func host(_options: Dictionary = {}) -> Error:
		return OK

	func connect_to_endpoint(_endpoint: String, _options: Dictionary = {}) -> Error:
		return OK


class EagerConnectedBackend extends FakeBackend:
	func host(_options: Dictionary = {}) -> Error:
		connected.emit()
		return OK


# --- 测试方法 ---

## 验证消息序列化可保留通用元信息与载荷。
func test_network_serializer_round_trips_message() -> void:
	var serializer := GFNetworkSerializerBase.new()
	var message := GFNetworkMessageBase.new(&"state", { "hp": 10 }, 7, 12, 3, &"state_channel")

	var decoded := serializer.deserialize_message(serializer.serialize_message(message))

	assert_not_null(decoded, "解码结果不应为空。")
	assert_eq(decoded.message_type, &"state", "消息类型应保留。")
	assert_eq(decoded.sequence, 7, "sequence 应保留。")
	assert_eq(decoded.tick, 12, "tick 应保留。")
	assert_eq(decoded.sender_id, 3, "sender_id 应保留。")
	assert_eq(decoded.channel_id, &"state_channel", "channel_id 应保留。")
	assert_eq(decoded.payload.get("hp", 0), 10, "payload 应保留。")


func test_network_json_serializer_can_use_typed_variant_codec() -> void:
	var serializer := GFNetworkSerializerBase.new()
	serializer.format = GFNetworkSerializerBase.Format.JSON
	serializer.use_typed_json_codec = true
	var message := GFNetworkMessageBase.new(&"state", {
		"position": Vector2(1.0, 2.0),
		"tags": PackedStringArray(["a", "b"]),
	})

	var decoded := serializer.deserialize_message(serializer.serialize_message(message))

	assert_not_null(decoded, "类型化 JSON 解码结果不应为空。")
	assert_eq(decoded.payload.get("position"), Vector2(1.0, 2.0), "类型化 JSON 应保留 Vector2。")
	assert_eq(decoded.payload.get("tags"), PackedStringArray(["a", "b"]), "类型化 JSON 应保留 PackedStringArray。")


func test_reconnect_policy_uses_delay_sequence_and_attempt_limit() -> void:
	var policy := GFNetworkReconnectPolicyBase.new()
	policy.delays_msec = [10, 20]
	policy.max_attempts = 3

	assert_eq(policy.get_next_delay_msec(), 10)
	assert_eq(policy.get_next_delay_msec(), 20)
	assert_eq(policy.get_next_delay_msec(), 20, "超过序列长度后应复用最后一个延迟。")
	assert_eq(policy.get_next_delay_msec(), -1, "达到最大尝试次数后应拒绝继续。")

	policy.record_success()
	assert_eq(policy.get_attempt_count(), 0, "连接成功后应重置尝试次数。")


func test_reconnect_policy_jitter_respects_seeded_rng_state() -> void:
	var policy := GFNetworkReconnectPolicyBase.new()
	var expected_rng := RandomNumberGenerator.new()
	policy.delays_msec = [100]
	policy.jitter_ratio = 0.5
	policy._rng.seed = 12345
	expected_rng.seed = 12345

	var expected := maxi(int(roundf(100.0 + expected_rng.randf_range(-50.0, 50.0))), 0)

	assert_eq(policy.get_next_delay_msec(), expected, "jitter 不应在每次计算时重新 randomize 覆盖已设定 RNG 状态。")


## 验证 NetworkUtility 会通过后端发送并解码后端收到的消息。
func test_network_utility_bridges_backend_messages() -> void:
	var utility := GFNetworkUtilityBase.new()
	var backend := FakeBackend.new()
	utility.set_backend(backend)
	var received: Array[GFNetworkMessage] = []
	utility.message_received.connect(func(_peer_id: int, received_message: GFNetworkMessage) -> void:
		received.append(received_message)
	)

	var outgoing_message := GFNetworkMessageBase.new(&"ping", { "value": 1 })
	var error := utility.send_message(4, outgoing_message)
	backend.message_received.emit(4, backend.sent_bytes)

	assert_eq(error, OK, "发送消息应成功。")
	assert_eq(backend.sent_peer_id, 4, "后端应收到目标 peer。")
	assert_eq(received.size(), 1, "后端消息应被解码并广播。")
	assert_eq(received[0].message_type, &"ping", "解码后的消息类型应正确。")


## 验证令牌桶限流器按时间恢复令牌。
func test_network_rate_limiter_refills_tokens() -> void:
	var limiter := GFNetworkRateLimiterBase.new(1.0, 2.0)

	assert_true(limiter.consume(), "初始令牌应允许一次消费。")
	assert_false(limiter.consume(), "令牌耗尽后应拒绝消费。")
	limiter.tick(0.5)

	assert_true(limiter.consume(), "恢复足够令牌后应允许消费。")


## 验证网络频道会合并发送选项并进入调试快照。
func test_network_channel_controls_send_options() -> void:
	var utility := GFNetworkUtilityBase.new()
	var backend := FakeBackend.new()
	utility.set_backend(backend)
	var channel := GFNetworkChannelBase.new()
	channel.channel_id = &"state"
	channel.transfer_channel = 2
	channel.reliable = false
	utility.register_channel(channel)

	var error := utility.send_message_on_channel(3, GFNetworkMessageBase.new(&"state", {}), &"state")
	var snapshot := utility.get_debug_snapshot()

	assert_eq(error, OK, "通道发送应成功。")
	assert_eq(backend.sent_options.get("channel"), 2, "通道编号应写入后端发送选项。")
	assert_false(bool(backend.sent_options.get("reliable", true)), "通道可靠性应写入后端发送选项。")
	assert_eq((snapshot["channels"] as Array).size(), 1, "调试快照应包含已注册通道。")


## 验证按通道发送会写入消息通道元信息，且不修改原始消息 payload。
func test_send_message_on_channel_serializes_channel_id_metadata() -> void:
	var utility := GFNetworkUtilityBase.new()
	var backend := FakeBackend.new()
	utility.set_backend(backend)
	var channel := GFNetworkChannelBase.new()
	channel.channel_id = &"state"
	utility.register_channel(channel)
	var message := GFNetworkMessageBase.new(&"state_delta", { "value": 1 })

	var error := utility.send_message_on_channel(3, message, &"state")
	var decoded := utility.serializer.deserialize_message(backend.sent_bytes)

	assert_eq(error, OK, "通道发送应成功。")
	assert_eq(decoded.channel_id, &"state", "发送副本应包含逻辑通道。")
	assert_false(message.payload.has("channel_id"), "通道元信息不应污染业务 payload。")


## 验证入站消息会按 message_type 匹配通道包体上限。
func test_network_utility_rejects_inbound_packet_over_channel_limit() -> void:
	var utility := GFNetworkUtilityBase.new()
	var backend := FakeBackend.new()
	utility.set_backend(backend)
	var channel := GFNetworkChannelBase.new()
	channel.channel_id = &"state"
	channel.max_packet_size = 8
	utility.register_channel(channel)
	watch_signals(utility)

	var bytes := utility.serializer.serialize_message(GFNetworkMessageBase.new(&"state", { "payload": "too large" }))
	backend.message_received.emit(1, bytes)

	assert_signal_emitted(utility, "message_rejected", "超过通道上限的入站消息应被拒绝。")
	assert_signal_not_emitted(utility, "message_received", "被拒绝的入站消息不应继续广播。")


## 验证入站消息可按 channel_id 元信息匹配通道包体上限。
func test_network_utility_rejects_inbound_packet_over_channel_id_limit() -> void:
	var utility := GFNetworkUtilityBase.new()
	var backend := FakeBackend.new()
	utility.set_backend(backend)
	var channel := GFNetworkChannelBase.new()
	channel.channel_id = &"state"
	channel.max_packet_size = 8
	utility.register_channel(channel)
	watch_signals(utility)

	var bytes := utility.serializer.serialize_message(GFNetworkMessageBase.new(&"state_delta", { "payload": "too large" }, 0, 0, -1, &"state"))
	backend.message_received.emit(1, bytes)

	assert_signal_emitted(utility, "message_rejected", "超过通道上限的入站消息应被拒绝。")
	assert_signal_not_emitted(utility, "message_received", "被拒绝的入站消息不应继续广播。")


## 验证入站通道匹配不再读取业务 payload.channel_id。
func test_network_utility_does_not_resolve_channel_from_payload_field() -> void:
	var utility := GFNetworkUtilityBase.new()
	var backend := FakeBackend.new()
	utility.set_backend(backend)
	var channel := GFNetworkChannelBase.new()
	channel.channel_id = &"state"
	channel.max_packet_size = 8
	utility.register_channel(channel)
	watch_signals(utility)

	var message := GFNetworkMessageBase.new(
		&"state_delta",
		{ "channel_id": "state", "payload": "too large" }
	)
	var bytes := utility.serializer.serialize_message(message)
	backend.message_received.emit(1, bytes)

	assert_signal_not_emitted(utility, "message_rejected", "业务 payload.channel_id 不应触发通道级包体限制。")
	assert_signal_emitted(utility, "message_received", "未携带通道元信息的消息应按普通消息广播。")


## 验证 ENet endpoint 解析支持带括号 IPv6 和 options.port。
func test_enet_endpoint_parser_supports_ipv6_forms() -> void:
	var backend := GFENetNetworkBackendBase.new()

	var bracketed := backend._parse_endpoint("[::1]:9000", {})
	var option_port := backend._parse_endpoint("2001:db8::1", { "port": 9001 })

	assert_eq(bracketed.get("address"), "::1", "带括号 IPv6 应去掉括号。")
	assert_eq(int(bracketed.get("port")), 9000, "带括号 IPv6 应解析端口。")
	assert_eq(option_port.get("address"), "2001:db8::1", "未带端口的 IPv6 应保持完整地址。")
	assert_eq(int(option_port.get("port")), 9001, "IPv6 可通过 options.port 指定端口。")


func test_websocket_backend_rejects_missing_port() -> void:
	var backend := GFWebSocketNetworkBackendBase.new()

	assert_eq(backend.host({}), ERR_INVALID_PARAMETER, "WebSocket 主机必须显式提供端口。")


func test_websocket_backend_round_trips_bytes() -> void:
	var server := GFWebSocketNetworkBackendBase.new()
	var client := GFWebSocketNetworkBackendBase.new()
	var port := 0
	var host_error: Error = ERR_UNAVAILABLE
	for offset: int in range(20):
		port = 19300 + offset
		host_error = server.host({
			"port": port,
			"bind_address": "127.0.0.1",
		})
		if host_error == OK:
			break
	assert_eq(host_error, OK, "测试应能启动本地 WebSocket 主机。")
	if host_error != OK:
		return

	var server_peer_ids: Array[int] = []
	var server_messages: Array[PackedByteArray] = []
	server.peer_connected.connect(func(peer_id: int) -> void:
		server_peer_ids.append(peer_id)
	)
	server.message_received.connect(func(_peer_id: int, packet_bytes: PackedByteArray) -> void:
		server_messages.append(packet_bytes)
	)

	var connect_error := client.connect_to_endpoint("ws://127.0.0.1:%d" % port)
	assert_eq(connect_error, OK, "客户端应能开始连接本地 WebSocket 主机。")

	for _step: int in range(120):
		server.poll(0.016)
		client.poll(0.016)
		if not server_peer_ids.is_empty():
			break
		await get_tree().process_frame

	assert_gt(server_peer_ids.size(), 0, "服务器应收到 WebSocket peer 连接。")
	if server_peer_ids.is_empty():
		server.disconnect_backend()
		client.disconnect_backend()
		return

	var bytes := PackedByteArray([1, 2, 3, 4])
	var send_error := client.send_bytes(GFWebSocketNetworkBackendBase.SERVER_PEER_ID, bytes)
	assert_eq(send_error, OK, "客户端应能发送二进制包。")

	for _step: int in range(120):
		server.poll(0.016)
		client.poll(0.016)
		if not server_messages.is_empty():
			break
		await get_tree().process_frame

	assert_gt(server_messages.size(), 0, "服务器应收到客户端发送的原始 bytes。")
	if server_messages.is_empty():
		server.disconnect_backend()
		client.disconnect_backend()
		return
	assert_eq(server_messages[0], bytes, "服务器应收到客户端发送的原始 bytes。")
	server.disconnect_backend()
	client.disconnect_backend()


## 验证消息校验器会拒绝不合规消息。
func test_network_message_validator_rejects_invalid_message() -> void:
	var validator := GFNetworkMessageValidatorBase.new()

	var report := validator.validate_message(GFNetworkMessageBase.new(&"", {}))

	assert_false(bool(report["ok"]), "默认校验器不应允许空消息类型。")
	assert_true((report["errors"] as PackedStringArray).has("empty_message_type"), "校验报告应包含 empty_message_type。")


## 验证消息校验器默认启用全局包体上限。
func test_network_message_validator_rejects_large_packet_by_default() -> void:
	var validator := GFNetworkMessageValidatorBase.new()
	var bytes := PackedByteArray()
	bytes.resize(GFNetworkMessageValidatorBase.DEFAULT_MAX_PACKET_SIZE + 1)

	var report := validator.validate_bytes(bytes)
	var snapshot := validator.get_debug_snapshot()

	assert_eq(int(snapshot["max_packet_size"]), GFNetworkMessageValidatorBase.DEFAULT_MAX_PACKET_SIZE, "2.0 默认应启用全局包体上限。")
	assert_false(bool(report["ok"]), "超过默认全局上限的包体应被拒绝。")
	assert_true((report["errors"] as PackedStringArray).has("packet_too_large"), "校验报告应包含 packet_too_large。")


## 验证项目可显式关闭全局包体上限。
func test_network_message_validator_can_disable_global_packet_limit() -> void:
	var validator := GFNetworkMessageValidatorBase.new()
	validator.max_packet_size = 0
	var bytes := PackedByteArray()
	bytes.resize(GFNetworkMessageValidatorBase.DEFAULT_MAX_PACKET_SIZE + 1)

	var report := validator.validate_bytes(bytes)

	assert_true(bool(report["ok"]), "显式设置 0 后应允许项目自定义大包策略。")


## 验证 NetworkUtility 会维护通用会话状态。
func test_network_utility_tracks_session_state() -> void:
	var utility := GFNetworkUtilityBase.new()
	utility.set_backend(FakeBackend.new())

	var host_error := utility.host({ "port": 9000, "max_clients": 8 })
	var host_snapshot := utility.get_debug_snapshot()
	utility.disconnect_network()
	utility.connect_to_endpoint("127.0.0.1:9000")
	var client_snapshot := utility.get_debug_snapshot()

	assert_eq(host_error, OK, "主机会话启动应成功。")
	assert_eq((host_snapshot["session"] as Dictionary).get("mode_name"), "host", "主机会话应记录 host 模式。")
	assert_eq((host_snapshot["session"] as Dictionary).get("max_peers"), 8, "主机会话应记录最大连接数。")
	assert_eq((client_snapshot["session"] as Dictionary).get("mode_name"), "client", "客户端连接应记录 client 模式。")


## 验证后端在 host() 内立即报告 connected 时，会话已经带有主机 peer 信息且不会重复派发。
func test_network_utility_host_session_is_ready_before_eager_backend_connected() -> void:
	var utility := GFNetworkUtilityBase.new()
	utility.set_backend(EagerConnectedBackend.new())
	var connected_peer_ids: Array[int] = []
	utility.session.session_connected.connect(func(local_peer_id: int) -> void:
		connected_peer_ids.append(local_peer_id)
	)

	var error := utility.host({ "port": 9000, "local_peer_id": 9 })

	assert_eq(error, OK, "主机会话启动应成功。")
	assert_eq(connected_peer_ids, [9], "后端立即 connected 不应造成 session_connected 重复或使用默认 peer。")
	assert_eq(utility.session.local_peer_id, 9, "会话应保留配置的本地 peer。")


## 验证网络工具与可选 ENet 后端提供调试快照。
func test_network_debug_snapshots_are_available() -> void:
	var utility := GFNetworkUtilityBase.new()
	utility.set_backend(FakeBackend.new())

	var utility_snapshot := utility.get_debug_snapshot()
	var enet_snapshot := GFENetNetworkBackendBase.new().get_debug_snapshot()

	assert_true(bool(utility_snapshot["backend_configured"]), "设置后端后快照应标记已配置。")
	assert_eq(enet_snapshot["connection_status_name"], "disconnected", "未连接 ENet 后端应报告 disconnected。")
	assert_eq(int(enet_snapshot["max_packets_per_poll"]), 64, "ENet 快照应包含每帧收包预算。")


## 验证 Network 扩展会从扩展侧向 Diagnostics 贡献网络快照。
func test_network_utility_contributes_diagnostics_snapshot() -> void:
	var arch := GFArchitecture.new()
	var diagnostics := GFDiagnosticsUtility.new()
	var utility := GFNetworkUtilityBase.new()
	utility.set_backend(FakeBackend.new())
	await arch.register_utility_instance(diagnostics)
	await arch.register_utility_instance(utility)
	await arch.init()

	var snapshot := diagnostics.collect_snapshot({
		"include_recent_logs": false,
	})
	var network := snapshot["network"] as Dictionary

	assert_true(network.has("backend_configured"), "Network 扩展应通过通用注册入口贡献 network 快照。")
	assert_true(bool(network["backend_configured"]), "贡献的 network 快照应来自当前 NetworkUtility。")

	arch.dispose()


## 验证固定 tick 时钟按预算推进并保留插值 alpha。
func test_fixed_tick_clock_advances_with_budget() -> void:
	var clock := GFFixedTickClockBase.new(10.0)
	clock.max_steps_per_update = 2
	var started_ticks: Array[int] = []
	var finished_ticks: Array[int] = []
	var exhausted_reports: Array[Dictionary] = []
	clock.tick_started.connect(func(tick: int, _tick_seconds: float) -> void:
		started_ticks.append(tick)
	)
	clock.tick_finished.connect(func(tick: int, _tick_seconds: float) -> void:
		finished_ticks.append(tick)
	)
	clock.tick_budget_exhausted.connect(func(available_steps: int, processed_steps: int, remaining_seconds: float) -> void:
		exhausted_reports.append({
			"available_steps": available_steps,
			"processed_steps": processed_steps,
			"remaining_seconds": remaining_seconds,
		})
	)

	var steps := clock.advance(0.35)

	assert_eq(steps, 2, "单次推进应受最大步数限制。")
	assert_eq(clock.current_tick, 2, "当前 tick 应推进两步。")
	assert_eq(started_ticks, [1, 2], "固定时钟应按单 tick 发出开始信号。")
	assert_eq(finished_ticks, [1, 2], "固定时钟应按单 tick 发出结束信号。")
	assert_eq(exhausted_reports.size(), 1, "预算不足时应发出诊断信号。")
	assert_true(clock.get_interpolation_alpha() <= 1.0, "插值 alpha 应保持在 0 到 1。")
	assert_eq(clock.get_tick_factor(), clock.get_interpolation_alpha(), "tick_factor 应作为插值比例别名。")


## 验证网络快照可以生成并应用浅层差量。
func test_network_snapshot_delta_round_trips_state() -> void:
	var start := GFNetworkSnapshotBase.new(10, { "hp": 10, "mana": 3 }, 2)
	var target := GFNetworkSnapshotBase.new(12, { "hp": 8, "position": Vector2(1.0, 2.0) }, 2)

	var delta := start.make_delta_to(target)
	var applied := start.apply_delta(delta)

	assert_true(bool(delta["ok"]), "有效目标快照应生成差量。")
	assert_eq(applied.tick, 12, "应用差量后 tick 应更新。")
	assert_eq(applied.get_value(&"hp"), 8, "变更字段应被应用。")
	assert_false(applied.has_value(&"mana"), "目标中不存在的字段应被删除。")
	assert_eq(applied.get_value(&"position"), Vector2(1.0, 2.0), "新增字段应被应用。")


## 验证网络快照差量会保留非字符串删除键。
func test_network_snapshot_delta_preserves_variant_erase_keys() -> void:
	var start := GFNetworkSnapshotBase.new(1, { 7: "old", "hp": 10 }, 2)
	var target := GFNetworkSnapshotBase.new(2, { "hp": 10 }, 2)

	var delta := start.make_delta_to(target)
	var applied := start.apply_delta(delta)

	assert_true(bool(delta["ok"]), "有效目标快照应生成差量。")
	assert_false(applied.state.has(7), "Variant 删除键应按原类型删除。")


## 验证网络历史缓冲按容量保留最新快照并可查询最近 tick。
func test_network_history_buffer_prunes_by_capacity() -> void:
	var history := GFNetworkHistoryBufferBase.new(2)
	history.add_state(1, { "value": 1 })
	history.add_state(2, { "value": 2 })
	history.add_state(3, { "value": 3 })

	var closest := history.get_closest_snapshot(2)
	var latest := history.get_latest_snapshot()

	assert_false(history.has_snapshot(1), "超过容量后最旧快照应被裁剪。")
	assert_eq(history.size(), 2, "历史数量应受 capacity 限制。")
	assert_eq(closest.tick, 2, "应能查询最接近的快照。")
	assert_eq(latest.tick, 3, "最新快照应为最大 tick。")


func test_network_history_buffer_queries_ranges_and_surrounding_snapshots() -> void:
	var history := GFNetworkHistoryBufferBase.new(0)
	history.add_state(1, { "value": 1 })
	history.add_state(3, { "value": 3 })
	history.add_state(5, { "value": 5 })

	var range_snapshots := history.get_snapshots_between(1, 5, false)
	var surrounding := history.get_surrounding_snapshots(4)

	assert_eq(range_snapshots.size(), 1, "开区间查询应只返回边界内快照。")
	assert_eq(range_snapshots[0].tick, 3, "范围查询应按 tick 升序返回快照。")
	assert_eq((surrounding["previous"] as GFNetworkSnapshot).tick, 3, "包围查询应返回前序快照。")
	assert_eq((surrounding["next"] as GFNetworkSnapshot).tick, 5, "包围查询应返回后序快照。")


func test_network_snapshot_schema_encodes_and_decodes_fields() -> void:
	var serializer := GFNetworkFieldSerializerBase.new()
	serializer.value_type = GFNetworkFieldSerializerBase.ValueType.VECTOR2
	serializer.quantize_decimals = 1
	var schema := GFNetworkSnapshotSchemaBase.new()
	schema.set_field_serializer(&"position", serializer)
	var snapshot := GFNetworkSnapshotBase.new(7, {
		&"position": Vector2(1.24, 2.26),
		"name": "unit",
	}, 4)

	var encoded := schema.encode_snapshot(snapshot)
	var decoded := schema.decode_snapshot(encoded)

	assert_eq((encoded["state"] as Dictionary)[&"position"], [1.2, 2.3], "Schema 应按字段编码 Vector2。")
	assert_eq(decoded.tick, 7, "Schema 解码应保留 tick。")
	assert_eq(decoded.peer_id, 4, "Schema 解码应保留 peer。")
	assert_eq(decoded.state[&"position"], Vector2(1.2, 2.3), "Schema 应恢复字段类型。")
	assert_eq(decoded.state["name"], "unit", "未注册字段应按配置原样保留。")
