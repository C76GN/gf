## GFNetworkBackend: 网络后端抽象基类。
##
## 后端负责具体传输协议，框架层只依赖该统一接口与信号。
class_name GFNetworkBackend
extends RefCounted


# --- 信号 ---

## 连接成功后发出。
signal connected

## 断开连接后发出。
signal disconnected(reason: String)

## 远端节点连接后发出。
signal peer_connected(peer_id: int)

## 远端节点断开后发出。
signal peer_disconnected(peer_id: int)

## 收到原始消息 bytes 后发出。
signal message_received(peer_id: int, bytes: PackedByteArray)


# --- 公共方法 ---

## 启动主机。
## @param _options: 后端自定义选项。
## @return Godot Error。
func host(_options: Dictionary = {}) -> Error:
	return ERR_UNAVAILABLE


## 连接远端。
## @param _endpoint: 远端地址。
## @param _options: 后端自定义选项。
## @return Godot Error。
func connect_to_endpoint(_endpoint: String, _options: Dictionary = {}) -> Error:
	return ERR_UNAVAILABLE


## 断开连接。
func disconnect_backend() -> void:
	pass


## 发送 bytes。
## @param _peer_id: 目标 peer；后端可约定 -1 表示广播。
## @param _bytes: 消息 bytes。
## @param _options: 后端自定义发送选项。
## @return Godot Error。
func send_bytes(_peer_id: int, _bytes: PackedByteArray, _options: Dictionary = {}) -> Error:
	return ERR_UNAVAILABLE


## 后端轮询入口。需要轮询的后端可重写。
## @param _delta: 帧间隔。
func poll(_delta: float) -> void:
	pass
