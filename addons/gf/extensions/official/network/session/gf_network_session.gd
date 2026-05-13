## GFNetworkSession: 网络会话状态快照。
##
## 记录当前网络工具的主机/客户端意图与连接状态，不绑定房间、账号或匹配逻辑。
class_name GFNetworkSession
extends RefCounted


# --- 信号 ---

## 会话开始时发出。
signal session_started(mode: int, endpoint: String)

## 会话连接成功时发出。
signal session_connected(local_peer_id: int)

## 会话关闭时发出。
signal session_closed(reason: String)


# --- 枚举 ---

## 会话模式。
enum Mode {
	NONE,
	HOST,
	CLIENT,
}


# --- 公共变量 ---

## 当前模式。
var mode: Mode = Mode.NONE

## 会话端点。
var endpoint: String = ""

## 本地 peer 标识。
var local_peer_id: int = -1

## 最大远端数量。
var max_peers: int = 0

## 会话是否已经启动。
var is_active: bool = false

## 后端是否已报告连接成功。
var is_connected: bool = false

## 启动时间。
var started_at_unix: float = 0.0

## 项目自定义元数据。
var metadata: Dictionary = {}


# --- 公共方法 ---

## 标记主机会话已开始。
## @param options: 启动选项。
func start_host(options: Dictionary = {}) -> void:
	mode = Mode.HOST
	endpoint = String(options.get("endpoint", "0.0.0.0:%d" % int(options.get("port", 0))))
	max_peers = int(options.get("max_clients", options.get("max_peers", 0)))
	local_peer_id = int(options.get("local_peer_id", 1))
	metadata = _get_metadata_copy(options)
	is_active = true
	is_connected = true
	started_at_unix = Time.get_unix_time_from_system()
	session_started.emit(mode, endpoint)
	session_connected.emit(local_peer_id)


## 标记客户端会话已开始。
## @param next_endpoint: 远端端点。
## @param options: 连接选项。
func start_client(next_endpoint: String, options: Dictionary = {}) -> void:
	mode = Mode.CLIENT
	endpoint = next_endpoint
	max_peers = int(options.get("max_peers", 0))
	local_peer_id = int(options.get("local_peer_id", -1))
	metadata = _get_metadata_copy(options)
	is_active = true
	is_connected = false
	started_at_unix = Time.get_unix_time_from_system()
	session_started.emit(mode, endpoint)


## 标记后端已经连接。
## @param next_local_peer_id: 本地 peer；小于 0 时保留原值。
func mark_connected(next_local_peer_id: int = -1) -> void:
	if next_local_peer_id >= 0:
		local_peer_id = next_local_peer_id
	is_connected = true
	session_connected.emit(local_peer_id)


## 关闭会话。
## @param reason: 关闭原因。
func close(reason: String = "closed") -> void:
	if not is_active and mode == Mode.NONE:
		return

	mode = Mode.NONE
	endpoint = ""
	local_peer_id = -1
	max_peers = 0
	is_active = false
	is_connected = false
	started_at_unix = 0.0
	metadata.clear()
	session_closed.emit(reason)


## 获取调试快照。
## @return 会话状态字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"mode": mode,
		"mode_name": _get_mode_name(mode),
		"endpoint": endpoint,
		"local_peer_id": local_peer_id,
		"max_peers": max_peers,
		"is_active": is_active,
		"is_connected": is_connected,
		"started_at_unix": started_at_unix,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _get_mode_name(query_mode: Mode) -> String:
	match query_mode:
		Mode.HOST:
			return "host"
		Mode.CLIENT:
			return "client"
		_:
			return "none"


func _get_metadata_copy(options: Dictionary) -> Dictionary:
	var metadata_variant: Variant = options.get("metadata", {})
	if metadata_variant is Dictionary:
		return (metadata_variant as Dictionary).duplicate(true)
	return {}
