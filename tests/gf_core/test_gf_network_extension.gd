## 测试 GF 网络抽象的消息编码、后端桥接与限流器。
extends GutTest


# --- 常量 ---

const GFNetworkBackendBase = preload("res://addons/gf/extensions/network/gf_network_backend.gd")
const GFNetworkMessageBase = preload("res://addons/gf/extensions/network/gf_network_message.gd")
const GFNetworkRateLimiterBase = preload("res://addons/gf/extensions/network/gf_network_rate_limiter.gd")
const GFNetworkSerializerBase = preload("res://addons/gf/extensions/network/gf_network_serializer.gd")
const GFNetworkUtilityBase = preload("res://addons/gf/extensions/network/gf_network_utility.gd")


# --- 辅助类 ---

class FakeBackend extends GFNetworkBackend:
	var sent_peer_id: int = 0
	var sent_bytes: PackedByteArray = PackedByteArray()

	func send_bytes(peer_id: int, bytes: PackedByteArray, _options: Dictionary = {}) -> Error:
		sent_peer_id = peer_id
		sent_bytes = bytes
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
