## GFNetworkUtility: 可插拔网络后端运行时。
##
## 负责把通用 GFNetworkMessage 编码后交给后端发送，并将后端收到的 bytes 解码为消息信号。
class_name GFNetworkUtility
extends GFUtility


# --- 信号 ---

## 收到消息后发出。
signal message_received(peer_id: int, message: GFNetworkMessage)

## 后端连接成功后发出。
signal connected

## 后端断开后发出。
signal disconnected(reason: String)

## 远端节点连接后发出。
signal peer_connected(peer_id: int)

## 远端节点断开后发出。
signal peer_disconnected(peer_id: int)


# --- 公共变量 ---

## 当前网络后端。
var backend: GFNetworkBackend

## 消息编码器。
var serializer: GFNetworkSerializer = GFNetworkSerializer.new()


# --- Godot 生命周期方法 ---

func tick(delta: float) -> void:
	if backend != null:
		backend.poll(delta)


func dispose() -> void:
	set_backend(null)


# --- 公共方法 ---

## 设置网络后端。
## @param next_backend: 新后端。
func set_backend(next_backend: GFNetworkBackend) -> void:
	if backend == next_backend:
		return
	if backend != null:
		_disconnect_backend_signals(backend)
	backend = next_backend
	if backend != null:
		_connect_backend_signals(backend)


## 启动主机。
## @param options: 后端选项。
## @return Godot Error。
func host(options: Dictionary = {}) -> Error:
	if backend == null:
		return ERR_UNCONFIGURED
	return backend.host(options)


## 连接远端。
## @param endpoint: 远端地址。
## @param options: 后端选项。
## @return Godot Error。
func connect_to_endpoint(endpoint: String, options: Dictionary = {}) -> Error:
	if backend == null:
		return ERR_UNCONFIGURED
	return backend.connect_to_endpoint(endpoint, options)


## 断开连接。
func disconnect_network() -> void:
	if backend != null:
		backend.disconnect_backend()


## 发送消息。
## @param peer_id: 目标 peer；后端可约定 -1 表示广播。
## @param message: 消息载体。
## @param options: 后端发送选项。
## @return Godot Error。
func send_message(peer_id: int, message: GFNetworkMessage, options: Dictionary = {}) -> Error:
	if backend == null:
		return ERR_UNCONFIGURED
	if serializer == null:
		return ERR_UNCONFIGURED

	var bytes := serializer.serialize_message(message)
	if bytes.is_empty():
		return ERR_INVALID_DATA
	return backend.send_bytes(peer_id, bytes, options)


# --- 私有/辅助方法 ---

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


func _on_backend_connected() -> void:
	connected.emit()


func _on_backend_disconnected(reason: String) -> void:
	disconnected.emit(reason)


func _on_backend_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id)


func _on_backend_peer_disconnected(peer_id: int) -> void:
	peer_disconnected.emit(peer_id)


func _on_backend_message_received(peer_id: int, bytes: PackedByteArray) -> void:
	if serializer == null:
		return

	var message := serializer.deserialize_message(bytes)
	if message != null:
		message_received.emit(peer_id, message)
