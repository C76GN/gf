## GFSignalUtility: Godot 原生 Signal 的安全连接与链式处理工具。
##
## 用于连接不适合进入 GF 业务事件总线的节点信号，支持 owner 归属清理、
## 默认参数、过滤、映射、延迟、防抖和一次性触发。
class_name GFSignalUtility
extends GFUtility


# --- 私有变量 ---

var _connections: Array[GFSignalConnection] = []


# --- Godot 生命周期方法 ---

func dispose() -> void:
	disconnect_all()


# --- 公共方法 ---

## 安全连接一个 Signal，并返回可继续链式配置的连接对象。
## @param source_signal: 要连接或断开的 Godot 信号。
## @param callback: 操作完成或事件触发时执行的回调。
## @param owner: 监听或连接的拥有者。
## @param default_args: 回调调用时追加的默认参数。
## @param connect_flags: Godot 信号连接标记。
func connect_signal(
	source_signal: Signal,
	callback: Callable,
	owner: Object = null,
	default_args: Array = [],
	connect_flags: int = 0
) -> GFSignalConnection:
	return _connect_signal(source_signal, callback, owner, default_args, connect_flags, false)


## 创建一次性 Signal 连接。
## @param source_signal: 要连接或断开的 Godot 信号。
## @param callback: 操作完成或事件触发时执行的回调。
## @param owner: 监听或连接的拥有者。
## @param default_args: 回调调用时追加的默认参数。
## @param connect_flags: Godot 信号连接标记。
func connect_once(
	source_signal: Signal,
	callback: Callable,
	owner: Object = null,
	default_args: Array = [],
	connect_flags: int = 0
) -> GFSignalConnection:
	return _connect_signal(source_signal, callback, owner, default_args, connect_flags, true)


## 断开指定 Signal 与回调的连接。
## @param source_signal: 要连接或断开的 Godot 信号。
## @param callback: 操作完成或事件触发时执行的回调。
## @param owner: 监听或连接的拥有者。
func disconnect_signal(source_signal: Signal, callback: Callable, owner: Object = null) -> void:
	for i: int in range(_connections.size() - 1, -1, -1):
		var connection := _connections[i]
		if connection == null:
			_connections.remove_at(i)
			continue
		if _connection_matches(connection, source_signal, callback, owner):
			connection.disconnect_signal()
			_connections.remove_at(i)


## 断开某个 owner 拥有的全部连接。
## @param owner: 监听或连接的拥有者。
func disconnect_owner(owner: Object) -> void:
	if owner == null:
		return

	for i: int in range(_connections.size() - 1, -1, -1):
		var connection := _connections[i]
		if connection == null or connection.is_owned_by(owner):
			if connection != null:
				connection.disconnect_signal()
			_connections.remove_at(i)


## 断开所有连接。
func disconnect_all() -> void:
	for connection: GFSignalConnection in _connections:
		if connection != null:
			connection.disconnect_signal()
	_connections.clear()


## 清理已经失效的连接。
func prune_invalid_connections() -> void:
	for i: int in range(_connections.size() - 1, -1, -1):
		var connection := _connections[i]
		if connection == null or connection.prune_if_invalid():
			_connections.remove_at(i)


## 获取当前仍被工具追踪的连接数量。
func get_connection_count() -> int:
	prune_invalid_connections()
	return _connections.size()


# --- 私有/辅助方法 ---

func _connect_signal(
	source_signal: Signal,
	callback: Callable,
	owner: Object,
	default_args: Array,
	connect_flags: int,
	once: bool
) -> GFSignalConnection:
	var existing := _find_connection(source_signal, callback, owner, default_args, connect_flags, once)
	if existing != null:
		return existing

	var connection := GFSignalConnection.new(
		source_signal,
		callback,
		owner,
		default_args,
		connect_flags,
		self
	)
	if once:
		connection.once()
	_connections.append(connection)
	connection.start()
	if not connection.is_active():
		_connections.erase(connection)
	return connection


func _find_connection(
	source_signal: Signal,
	callback: Callable,
	owner: Object,
	default_args: Array,
	connect_flags: int,
	once: bool
) -> GFSignalConnection:
	prune_invalid_connections()
	for connection: GFSignalConnection in _connections:
		if connection._matches_configuration(source_signal, callback, owner, default_args, connect_flags, once):
			return connection
	return null


func _connection_matches(
	connection: GFSignalConnection,
	source_signal: Signal,
	callback: Callable,
	owner: Object
) -> bool:
	if connection == null:
		return false
	return connection.matches(source_signal, callback, owner)


func _untrack_connection(connection: GFSignalConnection) -> void:
	_connections.erase(connection)
