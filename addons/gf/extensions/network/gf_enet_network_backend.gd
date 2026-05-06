## GFENetNetworkBackend: 基于 Godot ENetMultiplayerPeer 的网络后端。
##
## 该后端只实现 GFNetworkBackend 的 bytes 传输边界，不定义房间、同步、
## RPC 或任何项目消息语义。需要更复杂协议时可以继续继承 GFNetworkBackend。
class_name GFENetNetworkBackend
extends GFNetworkBackend


# --- 常量 ---

const BROADCAST_PEER_ID: int = -1


# --- 私有变量 ---

var _peer: ENetMultiplayerPeer
var _last_status: int = MultiplayerPeer.CONNECTION_DISCONNECTED
var _endpoint: String = ""
var _is_server: bool = false


# --- 公共变量 ---

## 每次 poll 最多派发的入站包数量。小于等于 0 表示不限制。
var max_packets_per_poll: int = 64


# --- 公共方法 ---

## 启动 ENet 主机。
## 支持 options: port, max_clients, max_channels, in_bandwidth, out_bandwidth。
## @param options: 操作选项字典。
func host(options: Dictionary = {}) -> Error:
	var port := int(options.get("port", 0))
	if port <= 0:
		return ERR_INVALID_PARAMETER

	_close_peer(false)
	_peer = ENetMultiplayerPeer.new()
	var error := _peer.create_server(
		port,
		int(options.get("max_clients", 32)),
		int(options.get("max_channels", 0)),
		int(options.get("in_bandwidth", 0)),
		int(options.get("out_bandwidth", 0))
	)
	if error != OK:
		_peer = null
		return error

	_endpoint = "0.0.0.0:%d" % port
	_is_server = true
	_connect_peer_signals()
	_last_status = _peer.get_connection_status()
	if _last_status == MultiplayerPeer.CONNECTION_CONNECTED:
		connected.emit()
	return OK


## 连接 ENet 远端。
## endpoint 可传 "host:port"，或通过 options.port 传端口。
## @param endpoint: 网络连接端点。
## @param options: 操作选项字典。
func connect_to_endpoint(endpoint: String, options: Dictionary = {}) -> Error:
	var parsed := _parse_endpoint(endpoint, options)
	var address := String(parsed.get("address", ""))
	var port := int(parsed.get("port", 0))
	if address.is_empty() or port <= 0:
		return ERR_INVALID_PARAMETER

	_close_peer(false)
	_peer = ENetMultiplayerPeer.new()
	var error := _peer.create_client(
		address,
		port,
		int(options.get("max_channels", 0)),
		int(options.get("in_bandwidth", 0)),
		int(options.get("out_bandwidth", 0))
	)
	if error != OK:
		_peer = null
		return error

	_endpoint = "%s:%d" % [address, port]
	_is_server = false
	_connect_peer_signals()
	_last_status = _peer.get_connection_status()
	return OK


## 断开 ENet 连接。
func disconnect_backend() -> void:
	_close_peer(true)


## 发送 bytes。
## options 支持 reliable, transfer_mode, channel。
## @param peer_id: 目标网络 peer 标识。
## @param bytes: 要发送的字节数据。
## @param options: 操作选项字典。
func send_bytes(peer_id: int, bytes: PackedByteArray, options: Dictionary = {}) -> Error:
	if _peer == null:
		return ERR_UNCONFIGURED
	if bytes.is_empty():
		return ERR_INVALID_DATA

	_peer.set_target_peer(_map_target_peer(peer_id))
	_peer.transfer_channel = int(options.get("channel", 0))
	_peer.transfer_mode = _get_transfer_mode(options)
	var error := _peer.put_packet(bytes)
	_peer.set_target_peer(MultiplayerPeer.TARGET_PEER_BROADCAST)
	return error


## 轮询 ENet 事件和收包。
## @param _delta: 本帧时间增量（秒），默认实现不直接使用。
func poll(_delta: float) -> void:
	if _peer == null:
		return

	_peer.poll()
	_update_connection_status()
	var processed_packets := 0
	while (
		_peer != null
		and _peer.get_available_packet_count() > 0
		and (max_packets_per_poll <= 0 or processed_packets < max_packets_per_poll)
	):
		var peer_id := _peer.get_packet_peer()
		var bytes := _peer.get_packet()
		message_received.emit(peer_id, bytes)
		processed_packets += 1


## 获取后端调试快照。
func get_debug_snapshot() -> Dictionary:
	var status := MultiplayerPeer.CONNECTION_DISCONNECTED if _peer == null else _peer.get_connection_status()
	return {
		"backend": "GFENetNetworkBackend",
		"available": _peer != null,
		"endpoint": _endpoint,
		"is_server": _is_server,
		"connection_status": status,
		"connection_status_name": _get_status_name(status),
		"available_packet_count": 0 if _peer == null else _peer.get_available_packet_count(),
		"max_packets_per_poll": max_packets_per_poll,
	}


# --- 私有/辅助方法 ---

func _connect_peer_signals() -> void:
	if _peer == null:
		return
	if not _peer.peer_connected.is_connected(_on_peer_connected):
		_peer.peer_connected.connect(_on_peer_connected)
	if not _peer.peer_disconnected.is_connected(_on_peer_disconnected):
		_peer.peer_disconnected.connect(_on_peer_disconnected)


func _disconnect_peer_signals() -> void:
	if _peer == null:
		return
	if _peer.peer_connected.is_connected(_on_peer_connected):
		_peer.peer_connected.disconnect(_on_peer_connected)
	if _peer.peer_disconnected.is_connected(_on_peer_disconnected):
		_peer.peer_disconnected.disconnect(_on_peer_disconnected)


func _close_peer(emit_signal: bool) -> void:
	if _peer == null:
		return

	_disconnect_peer_signals()
	_peer.close()
	_peer = null
	_last_status = MultiplayerPeer.CONNECTION_DISCONNECTED
	_endpoint = ""
	_is_server = false
	if emit_signal:
		disconnected.emit("closed")


func _parse_endpoint(endpoint: String, options: Dictionary) -> Dictionary:
	var address := endpoint.strip_edges()
	var port := int(options.get("port", 0))
	if address.begins_with("["):
		var bracket_index := address.find("]")
		if bracket_index > 0:
			var host := address.substr(1, bracket_index - 1)
			if bracket_index < address.length() - 2 and address.substr(bracket_index + 1, 1) == ":":
				port = int(address.substr(bracket_index + 2))
			address = host
	elif port <= 0:
		var separator_index := address.rfind(":")
		if (
			separator_index > 0
			and separator_index < address.length() - 1
			and address.find(":") == separator_index
		):
			port = int(address.substr(separator_index + 1))
			address = address.substr(0, separator_index)
	return {
		"address": address,
		"port": port,
	}


func _map_target_peer(peer_id: int) -> int:
	if peer_id == BROADCAST_PEER_ID:
		return MultiplayerPeer.TARGET_PEER_BROADCAST
	return peer_id


func _get_transfer_mode(options: Dictionary) -> int:
	if options.has("transfer_mode"):
		return int(options["transfer_mode"])
	if bool(options.get("reliable", true)):
		return MultiplayerPeer.TRANSFER_MODE_RELIABLE
	return MultiplayerPeer.TRANSFER_MODE_UNRELIABLE


func _update_connection_status() -> void:
	if _peer == null:
		return

	var status := _peer.get_connection_status()
	if status == _last_status:
		return

	_last_status = status
	match status:
		MultiplayerPeer.CONNECTION_CONNECTED:
			connected.emit()
		MultiplayerPeer.CONNECTION_DISCONNECTED:
			disconnected.emit("connection_status_disconnected")


func _get_status_name(status: int) -> String:
	match status:
		MultiplayerPeer.CONNECTION_DISCONNECTED:
			return "disconnected"
		MultiplayerPeer.CONNECTION_CONNECTING:
			return "connecting"
		MultiplayerPeer.CONNECTION_CONNECTED:
			return "connected"
		_:
			return "unknown"


func _on_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	peer_disconnected.emit(peer_id)
