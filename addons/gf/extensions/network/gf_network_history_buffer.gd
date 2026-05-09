## GFNetworkHistoryBuffer: 按 tick 保存网络快照的环形历史。
##
## 用于插值、重放、状态对账或项目自定义同步流程；不会自动执行预测、回滚或冲突解决。
class_name GFNetworkHistoryBuffer
extends RefCounted


# --- 公共变量 ---

## 最大保存快照数量。小于等于 0 表示不限制。
var capacity: int = 120


# --- 私有变量 ---

var _snapshots: Dictionary = {}
var _tick_order: Array[int] = []


# --- Godot 生命周期方法 ---

func _init(p_capacity: int = 120) -> void:
	capacity = p_capacity


# --- 公共方法 ---

## 添加快照。
## @param snapshot: 快照。
## @return 添加成功返回 true。
func add_snapshot(snapshot: GFNetworkSnapshot) -> bool:
	if snapshot == null:
		return false

	_snapshots[snapshot.tick] = snapshot.duplicate_snapshot()
	if not _tick_order.has(snapshot.tick):
		_tick_order.append(snapshot.tick)
		_tick_order.sort()
	_prune_to_capacity()
	return true


## 添加状态字典并返回生成的快照。
## @param tick: 快照 tick。
## @param state: 状态字典。
## @param peer_id: 来源 peer。
## @param metadata: 元数据。
## @return 新快照。
func add_state(
	tick: int,
	state: Dictionary,
	peer_id: int = -1,
	metadata: Dictionary = {}
) -> GFNetworkSnapshot:
	var snapshot := GFNetworkSnapshot.new(tick, state, peer_id, metadata)
	add_snapshot(snapshot)
	return snapshot


## 检查指定 tick 是否存在快照。
## @param tick: 快照 tick。
## @return 存在返回 true。
func has_snapshot(tick: int) -> bool:
	return _snapshots.has(tick)


## 获取指定 tick 的快照副本。
## @param tick: 快照 tick。
## @return 快照副本；不存在时返回 null。
func get_snapshot(tick: int) -> GFNetworkSnapshot:
	var snapshot := _snapshots.get(tick, null) as GFNetworkSnapshot
	return snapshot.duplicate_snapshot() if snapshot != null else null


## 获取最新快照副本。
## @return 最新快照；不存在时返回 null。
func get_latest_snapshot() -> GFNetworkSnapshot:
	if _tick_order.is_empty():
		return null
	return get_snapshot(_tick_order[_tick_order.size() - 1])


## 获取最早快照副本。
## @return 最早快照；不存在时返回 null。
func get_earliest_snapshot() -> GFNetworkSnapshot:
	if _tick_order.is_empty():
		return null
	return get_snapshot(_tick_order[0])


## 获取最接近指定 tick 的快照副本。
## @param tick: 查询 tick。
## @param prefer_older: 距离相同时是否优先旧快照。
## @return 快照副本；不存在时返回 null。
func get_closest_snapshot(tick: int, prefer_older: bool = true) -> GFNetworkSnapshot:
	if _tick_order.is_empty():
		return null

	var best_tick := _tick_order[0]
	var best_distance := absi(best_tick - tick)
	for candidate_tick: int in _tick_order:
		var distance := absi(candidate_tick - tick)
		if distance < best_distance:
			best_tick = candidate_tick
			best_distance = distance
		elif distance == best_distance:
			if prefer_older and candidate_tick < best_tick:
				best_tick = candidate_tick
			elif not prefer_older and candidate_tick > best_tick:
				best_tick = candidate_tick
	return get_snapshot(best_tick)


## 获取已保存 tick 列表。
## @return tick 列表。
func get_ticks() -> PackedInt64Array:
	var result := PackedInt64Array()
	for tick: int in _tick_order:
		result.append(tick)
	return result


## 删除指定 tick 之前的快照。
## @param tick: 保留起点 tick。
## @return 删除数量。
func prune_before(tick: int) -> int:
	var removed_count := 0
	for index: int in range(_tick_order.size() - 1, -1, -1):
		var stored_tick := _tick_order[index]
		if stored_tick >= tick:
			continue
		_snapshots.erase(stored_tick)
		_tick_order.remove_at(index)
		removed_count += 1
	return removed_count


## 清空历史。
func clear() -> void:
	_snapshots.clear()
	_tick_order.clear()


## 获取快照数量。
## @return 快照数量。
func size() -> int:
	return _tick_order.size()


## 获取调试快照。
## @return 调试信息字典。
func get_debug_snapshot() -> Dictionary:
	return {
		"capacity": capacity,
		"size": size(),
		"earliest_tick": _tick_order[0] if not _tick_order.is_empty() else -1,
		"latest_tick": _tick_order[_tick_order.size() - 1] if not _tick_order.is_empty() else -1,
	}


# --- 私有/辅助方法 ---

func _prune_to_capacity() -> void:
	if capacity <= 0:
		return

	while _tick_order.size() > capacity:
		var oldest_tick := _tick_order.pop_front()
		_snapshots.erase(oldest_tick)
