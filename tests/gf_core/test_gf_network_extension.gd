## 测试 GF 网络抽象的消息编码、后端桥接与限流器。
extends GutTest


# --- 常量 ---

const GFNetworkBackendBase = preload("res://addons/gf/extensions/network/gf_network_backend.gd")
const GFNetworkChannelBase = preload("res://addons/gf/extensions/network/gf_network_channel.gd")
const GFENetNetworkBackendBase = preload("res://addons/gf/extensions/network/gf_enet_network_backend.gd")
const GFNetworkMessageBase = preload("res://addons/gf/extensions/network/gf_network_message.gd")
const GFNetworkMessageValidatorBase = preload("res://addons/gf/extensions/network/gf_network_message_validator.gd")
const GFNetworkRateLimiterBase = preload("res://addons/gf/extensions/network/gf_network_rate_limiter.gd")
const GFNetworkSerializerBase = preload("res://addons/gf/extensions/network/gf_network_serializer.gd")
const GFNetworkUtilityBase = preload("res://addons/gf/extensions/network/gf_network_utility.gd")


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


# --- 测试方法 ---

## 验证消息序列化可保留通用元信息与载荷。
func test_network_serializer_round_trips_message() -> void:
	var serializer := GFNetworkSerializerBase.new()
	var message := GFNetworkMessageBase.new(&"state", { "hp": 10 }, 7, 12, 3)

	var decoded := serializer.deserialize_message(serializer.serialize_message(message))

	assert_not_null(decoded, "解码结果不应为空。")
	assert_eq(decoded.message_type, &"state", "消息类型应保留。")
	assert_eq(decoded.sequence, 7, "sequence 应保留。")
	assert_eq(decoded.tick, 12, "tick 应保留。")
	assert_eq(decoded.sender_id, 3, "sender_id 应保留。")
	assert_eq(decoded.payload.get("hp", 0), 10, "payload 应保留。")


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


## 验证 ENet endpoint 解析支持带括号 IPv6 和 options.port。
func test_enet_endpoint_parser_supports_ipv6_forms() -> void:
	var backend := GFENetNetworkBackendBase.new()

	var bracketed := backend._parse_endpoint("[::1]:9000", {})
	var option_port := backend._parse_endpoint("2001:db8::1", { "port": 9001 })

	assert_eq(bracketed.get("address"), "::1", "带括号 IPv6 应去掉括号。")
	assert_eq(int(bracketed.get("port")), 9000, "带括号 IPv6 应解析端口。")
	assert_eq(option_port.get("address"), "2001:db8::1", "未带端口的 IPv6 应保持完整地址。")
	assert_eq(int(option_port.get("port")), 9001, "IPv6 可通过 options.port 指定端口。")


## 验证消息校验器会拒绝不合规消息。
func test_network_message_validator_rejects_invalid_message() -> void:
	var validator := GFNetworkMessageValidatorBase.new()

	var report := validator.validate_message(GFNetworkMessageBase.new(&"", {}))

	assert_false(bool(report["ok"]), "默认校验器不应允许空消息类型。")
	assert_true((report["errors"] as PackedStringArray).has("empty_message_type"), "校验报告应包含 empty_message_type。")


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


## 验证网络工具与可选 ENet 后端提供调试快照。
func test_network_debug_snapshots_are_available() -> void:
	var utility := GFNetworkUtilityBase.new()
	utility.set_backend(FakeBackend.new())

	var utility_snapshot := utility.get_debug_snapshot()
	var enet_snapshot := GFENetNetworkBackendBase.new().get_debug_snapshot()

	assert_true(bool(utility_snapshot["backend_configured"]), "设置后端后快照应标记已配置。")
	assert_eq(enet_snapshot["connection_status_name"], "disconnected", "未连接 ENet 后端应报告 disconnected。")
	assert_eq(int(enet_snapshot["max_packets_per_poll"]), 64, "ENet 快照应包含每帧收包预算。")
