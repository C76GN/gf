## GFNetworkBackend: 网络后端抽象基类。
##
## 后端负责具体传输协议，框架层只依赖该统一接口与信号。
## [br]
## @api public
## [br]
## @category protocol
## [br]
## @since 3.17.0
class_name GFNetworkBackend
extends RefCounted


# --- 信号 ---

## 连接成功后发出。
## [br]
## @api public
signal connected

## 断开连接后发出。
## [br]
## @api public
## [br]
## @param reason: 断开原因。
signal disconnected(reason: String)

## 远端节点连接后发出。
## [br]
## @api public
## [br]
## @param peer_id: 远端 peer 标识。
signal peer_connected(peer_id: int)

## 远端节点断开后发出。
## [br]
## @api public
## [br]
## @param peer_id: 远端 peer 标识。
signal peer_disconnected(peer_id: int)

## 收到原始消息 bytes 后发出。
## [br]
## @api public
## [br]
## @param peer_id: 远端 peer 标识。
## [br]
## @param bytes: 原始消息 bytes。
signal message_received(peer_id: int, bytes: PackedByteArray)


# --- 公共方法 ---

## 启动主机。
## [br]
## @api public
## [br]
## @param _options: 后端自定义选项。
## [br]
## @return Godot 错误码。
## [br]
## @schema _options: Dictionary，后端自定义启动选项。
func host(_options: Dictionary = {}) -> Error:
	return ERR_UNAVAILABLE


## 连接远端。
## [br]
## @api public
## [br]
## @param _endpoint: 远端地址。
## [br]
## @param _options: 后端自定义选项。
## [br]
## @return Godot 错误码。
## [br]
## @schema _options: Dictionary，后端自定义连接选项。
func connect_to_endpoint(_endpoint: String, _options: Dictionary = {}) -> Error:
	return ERR_UNAVAILABLE


## 断开连接。
## [br]
## @api public
func disconnect_backend() -> void:
	pass


## 发送 bytes。
## [br]
## @api public
## [br]
## @param _peer_id: 目标 peer；后端可约定 -1 表示广播。
## [br]
## @param _bytes: 消息 bytes。
## [br]
## @param _options: 后端自定义发送选项。
## [br]
## @return Godot 错误码。
## [br]
## @schema _options: Dictionary，后端自定义发送选项。
func send_bytes(_peer_id: int, _bytes: PackedByteArray, _options: Dictionary = {}) -> Error:
	return ERR_UNAVAILABLE


## 后端轮询入口。需要轮询的后端可重写。
## [br]
## @api public
## [br]
## @param _delta: 帧间隔。
func poll(_delta: float) -> void:
	pass


## 获取后端调试快照。
## [br]
## @api public
## [br]
## @return 调试信息字典。
## [br]
## @schema return: Dictionary，包含 backend、available 以及后端自定义状态字段。
func get_debug_snapshot() -> Dictionary:
	return {
		"backend": get_script().resource_path if get_script() != null else "",
		"available": false,
	}
