## GFNetworkUtility: 可插拔网络后端运行时。
##
## 负责把通用 GFNetworkMessage 编码后交给后端发送，并将后端收到的 bytes 解码为消息信号。
class_name GFNetworkUtility
extends GFUtility


# --- 信号 ---

## 收到消息后发出。
signal message_received(peer_id: int, message: GFNetworkMessage)

## 消息校验失败后发出。
signal message_rejected(peer_id: int, reason: String, details: Dictionary)

## 后端连接成功后发出。
signal connected

## 后端断开后发出。
signal disconnected(reason: String)

## 远端节点连接后发出。
signal peer_connected(peer_id: int)

## 远端节点断开后发出。
signal peer_disconnected(peer_id: int)


# --- 常量 ---

const GFNetworkChannelBase = preload("res://addons/gf/extensions/network/session/gf_network_channel.gd")
const GFNetworkMessageValidatorBase = preload("res://addons/gf/extensions/network/messages/gf_network_message_validator.gd")
const GFNetworkSessionBase = preload("res://addons/gf/extensions/network/session/gf_network_session.gd")


# --- 公共变量 ---

## 当前网络后端。
var backend: GFNetworkBackend

## 消息编码器。
var serializer: GFNetworkSerializer = GFNetworkSerializer.new()

## 消息校验器。
var validator: GFNetworkMessageValidatorBase = GFNetworkMessageValidatorBase.new()

## 当前会话状态。
var session: GFNetworkSessionBase = GFNetworkSessionBase.new()


# --- 私有变量 ---

var _channels: Dictionary = {}


# --- Godot 生命周期方法 ---

func ready() -> void:
	_register_diagnostics_contribution()


## 推进运行时逻辑。
## @param delta: 本帧时间增量（秒）。
func tick(delta: float) -> void:
	if backend != null:
		backend.poll(delta)


func dispose() -> void:
	_unregister_diagnostics_contribution()
	_replace_backend(null, "disposed")
	clear_channels()
	if session != null:
		session.close("disposed")


# --- 公共方法 ---

## 设置网络后端。
## @param next_backend: 新后端。
func set_backend(next_backend: GFNetworkBackend) -> void:
	var close_reason := "backend_replaced" if next_backend != null else "backend_cleared"
	_replace_backend(next_backend, close_reason)


## 注册网络通道。
## @param channel: 通道资源。
func register_channel(channel: GFNetworkChannelBase) -> void:
	if channel == null or channel.channel_id == &"":
		return
	_channels[channel.channel_id] = channel


## 注销网络通道。
## @param channel_id: 通道标识。
func unregister_channel(channel_id: StringName) -> void:
	_channels.erase(channel_id)


## 获取网络通道。
## @param channel_id: 通道标识。
## @return 通道资源。
func get_channel(channel_id: StringName) -> GFNetworkChannelBase:
	return _channels.get(channel_id) as GFNetworkChannelBase


## 获取已注册通道标识。
## @return 排序后的通道标识。
func get_channel_ids() -> PackedStringArray:
	var result := PackedStringArray()
	for channel_id: StringName in _channels.keys():
		result.append(String(channel_id))
	result.sort()
	return result


## 清空网络通道。
func clear_channels() -> void:
	_channels.clear()


## 启动主机。
## @param options: 后端选项。
## @return Godot 错误码。
func host(options: Dictionary = {}) -> Error:
	if backend == null:
		return ERR_UNCONFIGURED

	if session != null:
		session.start_host(options)
	var error := backend.host(options)
	if error != OK and session != null:
		session.close("host_failed")
	elif session != null and not session.is_connected:
		session.mark_connected()
	return error


## 连接远端。
## @param endpoint: 远端地址。
## @param options: 后端选项。
## @return Godot 错误码。
func connect_to_endpoint(endpoint: String, options: Dictionary = {}) -> Error:
	if backend == null:
		return ERR_UNCONFIGURED

	if session != null:
		session.start_client(endpoint, options)
	var error := backend.connect_to_endpoint(endpoint, options)
	if error != OK and session != null:
		session.close("connect_failed")
	return error


## 断开连接。
func disconnect_network() -> void:
	if backend != null:
		backend.disconnect_backend()
	elif session != null:
		session.close("closed")


## 发送消息。
## @param peer_id: 目标 peer；后端可约定 -1 表示广播。
## @param message: 消息载体。
## @param options: 后端发送选项。
## @return Godot 错误码。
func send_message(peer_id: int, message: GFNetworkMessage, options: Dictionary = {}) -> Error:
	return _send_message_internal(peer_id, message, options, null)


## 通过指定通道发送消息。
## @param peer_id: 目标 peer；后端可约定 -1 表示广播。
## @param message: 消息载体。
## @param channel_id: 通道标识。
## @param options: 后端发送选项覆盖。
## @return Godot 错误码。
func send_message_on_channel(
	peer_id: int,
	message: GFNetworkMessage,
	channel_id: StringName,
	options: Dictionary = {}
) -> Error:
	var channel := get_channel(channel_id)
	if channel == null:
		return ERR_DOES_NOT_EXIST
	var channel_message := _copy_message_for_channel(message, channel_id)
	return _send_message_internal(peer_id, channel_message, channel.build_send_options(options), channel)


## 获取网络工具调试快照。
## @return 调试信息字典。
func get_debug_snapshot() -> Dictionary:
	var snapshot := {
		"backend_configured": backend != null,
		"serializer_configured": serializer != null,
		"validator_configured": validator != null,
		"backend": {},
		"session": session.get_debug_snapshot() if session != null else {},
		"channels": _describe_channels(),
		"validator": validator.get_debug_snapshot() if validator != null else {},
	}
	if backend != null:
		snapshot["backend"] = backend.get_debug_snapshot()
	return snapshot


# --- 私有/辅助方法 ---

func _send_message_internal(
	peer_id: int,
	message: GFNetworkMessage,
	options: Dictionary,
	channel: GFNetworkChannelBase
) -> Error:
	if backend == null:
		return ERR_UNCONFIGURED
	if serializer == null:
		return ERR_UNCONFIGURED
	if validator != null:
		var message_report: Dictionary = validator.validate_message(message)
		if not bool(message_report.get("ok", false)):
			message_rejected.emit(peer_id, "invalid_message", message_report)
			return ERR_INVALID_DATA

	var bytes := serializer.serialize_message(message)
	if bytes.is_empty():
		return ERR_INVALID_DATA
	if validator != null:
		var bytes_report: Dictionary = validator.validate_bytes(bytes, channel)
		if not bool(bytes_report.get("ok", false)):
			message_rejected.emit(peer_id, "invalid_packet", bytes_report)
			return ERR_INVALID_DATA
	return backend.send_bytes(peer_id, bytes, options)


func _connect_backend_signals(target_backend: GFNetworkBackend) -> void:
	target_backend.connected.connect(_on_backend_connected)
	target_backend.disconnected.connect(_on_backend_disconnected)
	target_backend.peer_connected.connect(_on_backend_peer_connected)
	target_backend.peer_disconnected.connect(_on_backend_peer_disconnected)
	target_backend.message_received.connect(_on_backend_message_received)


func _disconnect_backend_signals(target_backend: GFNetworkBackend) -> void:
	if target_backend.connected.is_connected(_on_backend_connected):
		target_backend.connected.disconnect(_on_backend_connected)
	if target_backend.disconnected.is_connected(_on_backend_disconnected):
		target_backend.disconnected.disconnect(_on_backend_disconnected)
	if target_backend.peer_connected.is_connected(_on_backend_peer_connected):
		target_backend.peer_connected.disconnect(_on_backend_peer_connected)
	if target_backend.peer_disconnected.is_connected(_on_backend_peer_disconnected):
		target_backend.peer_disconnected.disconnect(_on_backend_peer_disconnected)
	if target_backend.message_received.is_connected(_on_backend_message_received):
		target_backend.message_received.disconnect(_on_backend_message_received)


func _replace_backend(next_backend: GFNetworkBackend, close_reason: String) -> void:
	if backend == next_backend:
		return

	var previous_backend := backend
	if previous_backend != null:
		_disconnect_backend_signals(previous_backend)
		previous_backend.disconnect_backend()
		if session != null:
			session.close(close_reason)

	backend = next_backend
	if backend != null:
		_connect_backend_signals(backend)


func _on_backend_connected() -> void:
	if session != null:
		if not session.is_connected:
			session.mark_connected()
	connected.emit()


func _on_backend_disconnected(reason: String) -> void:
	if session != null:
		session.close(reason)
	disconnected.emit(reason)


func _on_backend_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id)


func _on_backend_peer_disconnected(peer_id: int) -> void:
	peer_disconnected.emit(peer_id)


func _on_backend_message_received(peer_id: int, bytes: PackedByteArray) -> void:
	if serializer == null:
		return
	if validator != null:
		var bytes_report: Dictionary = validator.validate_bytes(bytes)
		if not bool(bytes_report.get("ok", false)):
			message_rejected.emit(peer_id, "invalid_packet", bytes_report)
			return

	var message := serializer.deserialize_message(bytes)
	if message == null:
		message_rejected.emit(peer_id, "decode_failed", {})
		return
	if validator != null:
		var channel := _resolve_inbound_channel(message)
		if channel != null:
			var channel_bytes_report: Dictionary = validator.validate_bytes(bytes, channel)
			if not bool(channel_bytes_report.get("ok", false)):
				message_rejected.emit(peer_id, "invalid_packet", channel_bytes_report)
				return
		var message_report: Dictionary = validator.validate_message(message)
		if not bool(message_report.get("ok", false)):
			message_rejected.emit(peer_id, "invalid_message", message_report)
			return
	message_received.emit(peer_id, message)


func _describe_channels() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for channel: GFNetworkChannelBase in _channels.values():
		if channel != null:
			result.append(channel.describe())
	return result


func _resolve_inbound_channel(message: GFNetworkMessage) -> GFNetworkChannelBase:
	if message == null:
		return null
	if message.channel_id != &"" and _channels.has(message.channel_id):
		return _channels[message.channel_id] as GFNetworkChannelBase
	if _channels.has(message.message_type):
		return _channels[message.message_type] as GFNetworkChannelBase
	return null


func _copy_message_for_channel(message: GFNetworkMessage, channel_id: StringName) -> GFNetworkMessage:
	if message == null:
		return null

	return GFNetworkMessage.new(
		message.message_type,
		message.payload,
		message.sequence,
		message.tick,
		message.sender_id,
		channel_id
	)


func _register_diagnostics_contribution() -> void:
	var diagnostics := get_utility(GFDiagnosticsUtility) as GFDiagnosticsUtility
	if diagnostics == null:
		return

	diagnostics.register_snapshot_section_provider(&"network", Callable(self, "get_debug_snapshot"))


func _unregister_diagnostics_contribution() -> void:
	var diagnostics := get_utility(GFDiagnosticsUtility) as GFDiagnosticsUtility
	if diagnostics == null:
		return

	diagnostics.unregister_snapshot_section_provider(&"network")
