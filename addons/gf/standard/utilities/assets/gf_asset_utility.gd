## GFAssetUtility: 异步资源加载管理器，带 LRU 缓存。
##
## 封装 Godot 的 threaded `ResourceLoader` 请求，
## 用于避免大资源同步加载阻塞主线程，并在完成后统一分发回调与维护缓存。
class_name GFAssetUtility
extends GFUtility


# --- 信号 ---

## 创建资源句柄时发出。
## @param handle: 新创建的资源句柄。
signal asset_handle_acquired(handle: GFAssetHandle)

## 资源句柄释放时发出。
## @param path: 资源路径。
## @param reference_count: 剩余引用数量。
signal asset_handle_released(path: String, reference_count: int)

## 资源分组预加载完成时发出。
## @param group_id: 分组标识。
## @param report: 预加载报告。
signal asset_group_preloaded(group_id: StringName, report: Dictionary)


# --- 公共变量 ---

## LRU 缓存最大容量；设为 `0` 时表示禁用缓存。
var max_cache_size: int:
	get:
		return _max_cache_size
	set(value):
		_max_cache_size = maxi(value, 0)
		if _max_cache_size == 0:
			clear_cache()
			return

		_evict_lru()


# --- 私有变量 ---

var _max_cache_size: int = 64

## 正在加载中的请求：`path -> { type_hint: String, callbacks: Array[Callable], cancelled: bool }`。
var _pending: Dictionary = {}

## 资源缓存：`path -> Resource`。
var _cache: Dictionary = {}

## LRU 访问序号，数值越大表示越新。
var _cache_access_order: Dictionary = {}
var _cache_access_serial: int = 0
var _pinned_cache_paths: Dictionary = {}
var _reference_counts: Dictionary = {}
var _owner_reference_counts: Dictionary = {}
var _owner_refs: Dictionary = {}
var _owner_release_connected: Dictionary = {}
var _handle_refs: Array[WeakRef] = []
var _group_paths: Dictionary = {}
var _group_pin_counts: Dictionary = {}


# --- Godot 生命周期方法 ---

func init() -> void:
	ignore_pause = true
	_pending = {}
	_cache.clear()
	_cache_access_order.clear()
	_pinned_cache_paths.clear()
	_reference_counts.clear()
	_owner_reference_counts.clear()
	_owner_refs.clear()
	_owner_release_connected.clear()
	_handle_refs.clear()
	_group_paths.clear()
	_group_pin_counts.clear()
	_cache_access_serial = 0


func dispose() -> void:
	_pending.clear()
	_cache.clear()
	_cache_access_order.clear()
	_pinned_cache_paths.clear()
	_reference_counts.clear()
	_owner_reference_counts.clear()
	_owner_refs.clear()
	_owner_release_connected.clear()
	_handle_refs.clear()
	_group_paths.clear()
	_group_pin_counts.clear()
	_cache_access_serial = 0


# --- 公共方法 ---

## 发起异步资源加载。
## @param path: 目标资源路径。
## @param on_loaded: 加载完成后的回调。
## @param type_hint: 可选资源类型提示。
func load_async(path: String, on_loaded: Callable, type_hint: String = "") -> void:
	if path.is_empty() or not on_loaded.is_valid():
		push_error("[GFAssetUtility] 无效的路径或回调。")
		return

	var cached: Resource = get_cached(path)
	if cached != null:
		if not _is_resource_compatible(cached, type_hint):
			push_warning("[GFAssetUtility] 缓存资源类型与请求 type_hint 不匹配：%s (%s)" % [path, type_hint])
			on_loaded.call(null)
			return

		on_loaded.call(cached)
		return

	if _pending.has(path):
		var pending_request := _pending[path] as Dictionary
		var pending_type_hint := String(pending_request.get("type_hint", ""))
		if not _pending_type_hints_are_compatible(pending_type_hint, type_hint):
			push_warning("[GFAssetUtility] 已存在相同路径但 type_hint 不同的加载请求，已拒绝新请求：%s (%s -> %s)" % [path, pending_type_hint, type_hint])
			on_loaded.call(null)
			return

		var callbacks := pending_request.get("callbacks", []) as Array
		if bool(pending_request.get("cancelled", false)):
			callbacks.clear()
			pending_request["cancelled"] = false
		if not _callback_entries_have_callable(callbacks, on_loaded):
			callbacks.append(_make_callback_entry(on_loaded, type_hint))
		return

	var error := _request_threaded(path, type_hint)
	if error != OK:
		push_error("[GFAssetUtility] 无法发起异步加载请求：%s (错误码：%d)" % [path, error])
		on_loaded.call(null)
		return

	_pending[path] = {
		"type_hint": type_hint,
		"callbacks": [_make_callback_entry(on_loaded, type_hint)],
		"cancelled": false,
	}


## 异步加载资源并在成功后返回所有权句柄。
## @param path: 目标资源路径。
## @param on_loaded: 加载完成回调，签名为 func(handle: GFAssetHandle)；失败时传入 null。
## @param type_hint: 可选资源类型提示。
## @param owner: 可选拥有者。若为 Node，会在退出树时自动释放其持有的句柄引用。
## @param group_id: 可选资源分组。
func load_handle_async(
	path: String,
	on_loaded: Callable,
	type_hint: String = "",
	owner: Object = null,
	group_id: StringName = &""
) -> void:
	if path.is_empty() or not on_loaded.is_valid():
		push_error("[GFAssetUtility] load_handle_async 失败：路径或回调无效。")
		return

	var owner_ref := weakref(owner) if owner != null else null
	var on_resource_loaded := func(resource: Resource) -> void:
		if resource == null:
			on_loaded.call(null)
			return
		var resolved_owner := owner_ref.get_ref() as Object if owner_ref != null else null
		if owner_ref != null and not is_instance_valid(resolved_owner):
			on_loaded.call(null)
			return

		on_loaded.call(acquire_handle(path, resolved_owner, group_id, type_hint, resource))

	load_async(path, on_resource_loaded, type_hint)


## 为已缓存或指定资源创建所有权句柄。
## @param path: 资源路径。
## @param owner: 可选拥有者。若为 Node，会在退出树时自动释放其持有的句柄引用。
## @param group_id: 可选资源分组。
## @param type_hint: 可选资源类型提示。
## @param resource_override: 可选资源实例；为空时使用当前缓存。
## @return 成功时返回句柄；资源不可用时返回 null。
func acquire_handle(
	path: String,
	owner: Object = null,
	group_id: StringName = &"",
	type_hint: String = "",
	resource_override: Resource = null
) -> GFAssetHandle:
	if path.is_empty():
		push_error("[GFAssetUtility] acquire_handle 失败：路径为空。")
		return null

	var resource := resource_override if resource_override != null else get_cached(path)
	if resource == null:
		return null
	if not _is_resource_compatible(resource, type_hint):
		push_warning("[GFAssetUtility] acquire_handle 失败：缓存资源类型与 type_hint 不匹配：%s (%s)" % [path, type_hint])
		return null

	if not is_cached(path):
		put_cache(path, resource)

	var owner_id := _owner_instance_id(owner)
	_increment_reference(path, owner, group_id)

	var handle := GFAssetHandle.new()
	handle._setup(self, path, resource, type_hint, group_id, owner_id)
	_track_handle(handle)
	asset_handle_acquired.emit(handle)
	return handle


## 释放资源句柄。
## @param handle: 要释放的资源句柄。
## @return 释放成功返回 true。
func release_handle(handle: GFAssetHandle) -> bool:
	if handle == null or handle.path.is_empty() or handle.is_released():
		return false

	var path := handle.path
	var remaining := _decrement_reference(path, handle.get_owner_id())
	handle._release_local()
	_prune_handle_refs()
	asset_handle_released.emit(path, remaining)
	return true


## 释放指定 owner 持有的所有资源引用。
## @param owner: 拥有者对象。
## @return 释放的引用数量。
func release_owner(owner: Object) -> int:
	if owner == null:
		return 0
	return _release_owner_id(owner.get_instance_id())


## 获取指定资源路径当前句柄引用数量。
## @param path: 资源路径。
## @return 引用数量。
func get_asset_reference_count(path: String) -> int:
	return int(_reference_counts.get(path, 0))


## 注册资源路径到分组。
## @param group_id: 分组标识。
## @param path: 资源路径。
## @param pin: 是否以分组名义锁定缓存，避免 LRU 淘汰。
func register_group_path(group_id: StringName, path: String, pin: bool = false) -> void:
	if group_id == &"" or path.is_empty():
		return
	if not _group_paths.has(group_id):
		_group_paths[group_id] = {}
	_group_paths[group_id][path] = true
	if pin:
		if not _group_pin_counts.has(group_id):
			_group_pin_counts[group_id] = {}
		var pin_counts := _group_pin_counts[group_id] as Dictionary
		pin_counts[path] = int(pin_counts.get(path, 0)) + 1
		pin_cache(path)


## 获取分组中的资源路径。
## @param group_id: 分组标识。
## @return 路径列表。
func get_group_paths(group_id: StringName) -> PackedStringArray:
	var result := PackedStringArray()
	var paths := _group_paths.get(group_id, {}) as Dictionary
	for path: String in paths.keys():
		result.append(path)
	result.sort()
	return result


## 异步预加载资源分组。
## @param group_id: 分组标识。
## @param entries: 路径字符串，或包含 path/type_hint 字段的字典数组。
## @param on_completed: 完成回调，签名为 func(report: Dictionary)。
## @param options: 可选参数，支持 pin_cache。
func preload_group_async(
	group_id: StringName,
	entries: Array,
	on_completed: Callable = Callable(),
	options: Dictionary = {}
) -> void:
	if group_id == &"":
		push_error("[GFAssetUtility] preload_group_async 失败：group_id 为空。")
		return

	var pin_loaded := bool(options.get("pin_cache", true))
	var report := {
		"ok": true,
		"group_id": group_id,
		"paths": PackedStringArray(),
		"failed_paths": PackedStringArray(),
		"total": entries.size(),
		"completed": 0,
	}
	var finished := [false]
	if entries.is_empty():
		_finish_group_preload(group_id, report, on_completed)
		return

	for entry: Variant in entries:
		var request := _normalize_group_entry(entry)
		var path := String(request.get("path", ""))
		var type_hint := String(request.get("type_hint", ""))
		if path.is_empty():
			report["ok"] = false
			(report["failed_paths"] as PackedStringArray).append(path)
			report["completed"] = int(report["completed"]) + 1
			continue

		var request_path := path
		var request_type_hint := type_hint
		load_async(request_path, func(resource: Resource) -> void:
			if resource == null:
				report["ok"] = false
				(report["failed_paths"] as PackedStringArray).append(request_path)
			else:
				register_group_path(group_id, request_path, pin_loaded)
				(report["paths"] as PackedStringArray).append(request_path)

			report["completed"] = int(report["completed"]) + 1
			if int(report["completed"]) >= int(report["total"]) and not bool(finished[0]):
				finished[0] = true
				_finish_group_preload(group_id, report, on_completed)
		, request_type_hint)

	if int(report["completed"]) >= int(report["total"]) and not bool(finished[0]):
		finished[0] = true
		_finish_group_preload(group_id, report, on_completed)


## 卸载资源分组。
## @param group_id: 分组标识。
## @param remove_unreferenced_cache: 是否移除没有句柄引用的缓存项。
func unload_group(group_id: StringName, remove_unreferenced_cache: bool = false) -> void:
	var paths := _group_paths.get(group_id, {}) as Dictionary
	var pin_counts := _group_pin_counts.get(group_id, {}) as Dictionary
	for path: String in paths.keys():
		var pin_count := int(pin_counts.get(path, 0))
		for _i: int in range(pin_count):
			unpin_cache(path)
		if remove_unreferenced_cache and get_asset_reference_count(path) <= 0:
			remove_cache(path)

	_group_paths.erase(group_id)
	_group_pin_counts.erase(group_id)


## 驱动异步加载轮询。
## @param _delta: 为兼容统一 tick 签名而保留的参数。
func tick(_delta: float = 0.0) -> void:
	_poll_pending()


## 获取缓存中的资源。
## @param path: 资源路径。
## @return 命中缓存时返回资源，否则返回 `null`。
func get_cached(path: String) -> Resource:
	if _cache.has(path):
		_touch_cache(path)
		return _cache[path]

	return null


## 检查指定路径是否正在加载中。
## @param path: 资源路径。
## @param type_hint: 可选资源类型提示；为空时只检查路径。
## @return 正在加载时返回 `true`。
func is_loading(path: String, type_hint: String = "") -> bool:
	if not _pending.has(path):
		return false
	var pending_request := _pending[path] as Dictionary
	if bool(pending_request.get("cancelled", false)):
		return false
	if type_hint.is_empty():
		return true

	return String(pending_request.get("type_hint", "")) == type_hint


## 检查指定路径是否已缓存。
## @param path: 资源路径。
## @return 已缓存时返回 `true`。
func is_cached(path: String) -> bool:
	return _cache.has(path)


## 取消指定路径的异步加载请求。
## @param path: 资源路径。
## @param type_hint: 可选资源类型提示；为空时取消该路径的当前请求。
func cancel(path: String, type_hint: String = "") -> void:
	if not _pending.has(path):
		return

	var pending_request := _pending[path] as Dictionary
	var pending_type_hint := String(pending_request.get("type_hint", ""))
	if not type_hint.is_empty() and pending_type_hint != type_hint:
		return

	var callbacks := pending_request.get("callbacks", []) as Array
	callbacks.clear()
	pending_request["cancelled"] = true


## 手动写入缓存。
## @param path: 资源路径。
## @param resource: 要缓存的资源实例。
func put_cache(path: String, resource: Resource) -> void:
	if path.is_empty() or resource == null or max_cache_size <= 0:
		return

	_cache[path] = resource
	_touch_cache(path)
	_evict_lru()


## 手动移除缓存项。
## @param path: 资源路径。
func remove_cache(path: String) -> void:
	_cache.erase(path)
	_cache_access_order.erase(path)
	_pinned_cache_paths.erase(path)
	_reference_counts.erase(path)
	_owner_reference_counts.erase(path)


## 清空全部缓存。
func clear_cache() -> void:
	_cache.clear()
	_cache_access_order.clear()
	_pinned_cache_paths.clear()
	_reference_counts.clear()
	_owner_reference_counts.clear()
	_owner_refs.clear()
	_release_all_handles()
	_group_paths.clear()
	_group_pin_counts.clear()
	_cache_access_serial = 0


## 获取当前缓存数量。
## @return 当前缓存中的资源数。
func get_cache_count() -> int:
	return _cache.size()


## 锁定指定缓存路径，使其不参与 LRU 淘汰。
## @param path: 资源路径。
func pin_cache(path: String) -> void:
	if path.is_empty():
		return
	_pinned_cache_paths[path] = int(_pinned_cache_paths.get(path, 0)) + 1


## 解除指定缓存路径的 LRU 锁定。
## @param path: 资源路径。
func unpin_cache(path: String) -> void:
	if not _pinned_cache_paths.has(path):
		return

	var count := int(_pinned_cache_paths.get(path, 0)) - 1
	if count > 0:
		_pinned_cache_paths[path] = count
	else:
		_pinned_cache_paths.erase(path)
	_evict_lru()


## 检查指定缓存路径是否已被锁定。
## @param path: 资源路径。
## @return 已锁定返回 true。
func is_cache_pinned(path: String) -> bool:
	return int(_pinned_cache_paths.get(path, 0)) > 0


## 获取资源加载工具诊断快照。
## @return 诊断快照字典。
func get_debug_snapshot() -> Dictionary:
	var cached_paths := PackedStringArray()
	for path: String in _cache.keys():
		cached_paths.append(path)
	cached_paths.sort()

	var pending_paths := PackedStringArray()
	for path: String in _pending.keys():
		var pending_request := _pending[path] as Dictionary
		if not bool(pending_request.get("cancelled", false)):
			pending_paths.append(path)
	pending_paths.sort()

	var pinned_paths := PackedStringArray()
	for path: String in _pinned_cache_paths.keys():
		if int(_pinned_cache_paths.get(path, 0)) > 0:
			pinned_paths.append(path)
	pinned_paths.sort()

	return {
		"max_cache_size": max_cache_size,
		"cache_count": _cache.size(),
		"cached_paths": cached_paths,
		"pending_count": pending_paths.size(),
		"pending_paths": pending_paths,
		"pinned_count": pinned_paths.size(),
		"pinned_paths": pinned_paths,
		"reference_counts": _reference_counts.duplicate(),
		"group_count": _group_paths.size(),
	}


# --- 私有/辅助方法 ---

func _poll_pending() -> void:
	if _pending.is_empty():
		return

	var pending_paths: Array = _pending.keys()
	for path: String in pending_paths:
		if not _pending.has(path):
			continue

		var pending_request := _pending[path] as Dictionary
		var callbacks := (pending_request.get("callbacks", []) as Array).duplicate()
		var cancelled := bool(pending_request.get("cancelled", false))
		var status := _get_threaded_status(path)

		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				var resource := _take_threaded_resource(path)
				_pending.erase(path)
				if resource != null and not cancelled:
					put_cache(path, resource)
				if not cancelled:
					_dispatch_callbacks(callbacks, resource)

			ResourceLoader.THREAD_LOAD_FAILED:
				_pending.erase(path)
				if not cancelled:
					push_error("[GFAssetUtility] 异步加载失败：%s" % path)
					_dispatch_callbacks(callbacks, null)

			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				_pending.erase(path)
				if not cancelled:
					push_error("[GFAssetUtility] 无效资源：%s" % path)
					_dispatch_callbacks(callbacks, null)


func _dispatch_callbacks(callbacks: Array, resource: Resource) -> void:
	for callback_entry: Variant in callbacks:
		var entry := callback_entry as Dictionary
		var callback: Callable = Callable()
		var type_hint := ""
		if entry != null:
			callback = entry.get("callable", Callable())
			type_hint = String(entry.get("type_hint", ""))
		elif callback_entry is Callable:
			callback = callback_entry as Callable
		if callback.is_valid():
			callback.call(resource if resource == null or _is_resource_compatible(resource, type_hint) else null)


func _owner_instance_id(owner: Object) -> int:
	return owner.get_instance_id() if owner != null else 0


func _increment_reference(path: String, owner: Object, group_id: StringName) -> void:
	_reference_counts[path] = int(_reference_counts.get(path, 0)) + 1
	pin_cache(path)
	if group_id != &"":
		register_group_path(group_id, path)

	var owner_id := _owner_instance_id(owner)
	if owner_id == 0:
		return

	if not _owner_reference_counts.has(path):
		_owner_reference_counts[path] = {}
	var owner_counts := _owner_reference_counts[path] as Dictionary
	owner_counts[owner_id] = int(owner_counts.get(owner_id, 0)) + 1
	_track_owner(owner)


func _decrement_reference(path: String, owner_id: int, release_count: int = 1) -> int:
	var count_to_release := maxi(release_count, 1)
	var current_count := int(_reference_counts.get(path, 0))
	var next_count := maxi(current_count - count_to_release, 0)
	if next_count > 0:
		_reference_counts[path] = next_count
	else:
		_reference_counts.erase(path)

	for _i: int in range(current_count - next_count):
		unpin_cache(path)

	if owner_id != 0 and _owner_reference_counts.has(path):
		var owner_counts := _owner_reference_counts[path] as Dictionary
		var owner_count := int(owner_counts.get(owner_id, 0)) - count_to_release
		if owner_count > 0:
			owner_counts[owner_id] = owner_count
		else:
			owner_counts.erase(owner_id)
		if owner_counts.is_empty():
			_owner_reference_counts.erase(path)

	return next_count


func _track_owner(owner: Object) -> void:
	if owner == null:
		return

	var owner_id := owner.get_instance_id()
	_owner_refs[owner_id] = weakref(owner)
	if owner is Node and not bool(_owner_release_connected.get(owner_id, false)):
		(owner as Node).tree_exited.connect(_release_owner_id.bind(owner_id), CONNECT_ONE_SHOT)
		_owner_release_connected[owner_id] = true


func _track_handle(handle: GFAssetHandle) -> void:
	if handle != null:
		_handle_refs.append(weakref(handle))


func _prune_handle_refs() -> void:
	for index: int in range(_handle_refs.size() - 1, -1, -1):
		var handle := _handle_refs[index].get_ref() as GFAssetHandle
		if handle == null or handle.is_released():
			_handle_refs.remove_at(index)


func _release_all_handles() -> void:
	for handle_ref: WeakRef in _handle_refs:
		var handle := handle_ref.get_ref() as GFAssetHandle
		if handle != null:
			handle._release_local()
	_handle_refs.clear()


func _release_owner_handles(owner_id: int) -> void:
	for index: int in range(_handle_refs.size() - 1, -1, -1):
		var handle := _handle_refs[index].get_ref() as GFAssetHandle
		if handle == null or handle.is_released():
			_handle_refs.remove_at(index)
		elif handle.get_owner_id() == owner_id:
			handle._release_local()
			_handle_refs.remove_at(index)


func _release_owner_id(owner_id: int) -> int:
	if owner_id == 0:
		return 0

	var released_count := 0
	var paths: Array = _owner_reference_counts.keys()
	for path: String in paths:
		if not _owner_reference_counts.has(path):
			continue

		var owner_counts := _owner_reference_counts[path] as Dictionary
		if not owner_counts.has(owner_id):
			continue

		var count := int(owner_counts.get(owner_id, 0))
		released_count += count
		var remaining := _decrement_reference(path, owner_id, count)
		asset_handle_released.emit(path, remaining)

	_release_owner_handles(owner_id)
	_owner_refs.erase(owner_id)
	_owner_release_connected.erase(owner_id)
	return released_count


func _normalize_group_entry(entry: Variant) -> Dictionary:
	if entry is Dictionary:
		var data := entry as Dictionary
		return {
			"path": String(data.get("path", "")),
			"type_hint": String(data.get("type_hint", "")),
		}

	return {
		"path": String(entry),
		"type_hint": "",
	}


func _finish_group_preload(group_id: StringName, report: Dictionary, on_completed: Callable) -> void:
	var paths: PackedStringArray = report.get("paths", PackedStringArray())
	paths.sort()
	report["paths"] = paths

	var failed_paths: PackedStringArray = report.get("failed_paths", PackedStringArray())
	failed_paths.sort()
	report["failed_paths"] = failed_paths

	var report_copy := report.duplicate(true)
	asset_group_preloaded.emit(group_id, report_copy)
	if on_completed.is_valid():
		on_completed.call(report_copy.duplicate(true))


func _is_resource_compatible(resource: Resource, type_hint: String) -> bool:
	if resource == null:
		return false
	if type_hint.is_empty() or resource.is_class(type_hint):
		return true

	var script := resource.get_script() as Script
	while script != null:
		if String(script.get_global_name()) == type_hint or script.resource_path == type_hint:
			return true
		script = script.get_base_script()
	return false


func _pending_type_hints_are_compatible(pending_type_hint: String, requested_type_hint: String) -> bool:
	return (
		pending_type_hint == requested_type_hint
		or pending_type_hint.is_empty()
		or requested_type_hint.is_empty()
	)


func _make_callback_entry(callback: Callable, type_hint: String) -> Dictionary:
	return {
		"callable": callback,
		"type_hint": type_hint,
	}


func _callback_entries_have_callable(callbacks: Array, callback: Callable) -> bool:
	for callback_entry: Variant in callbacks:
		var entry := callback_entry as Dictionary
		if entry != null and entry.get("callable", Callable()) == callback:
			return true
		if callback_entry is Callable and callback_entry == callback:
			return true
	return false


func _touch_cache(path: String) -> void:
	_cache_access_serial += 1
	_cache_access_order[path] = _cache_access_serial


func _evict_lru() -> void:
	while _cache.size() > max_cache_size and max_cache_size > 0:
		var oldest_path := _get_oldest_cached_path()
		if oldest_path.is_empty() or not _cache.has(oldest_path):
			return

		_cache.erase(oldest_path)
		_cache_access_order.erase(oldest_path)


func _get_oldest_cached_path() -> String:
	var oldest_path := ""
	var oldest_access := 0
	var has_oldest := false
	for path: String in _cache:
		if is_cache_pinned(path):
			continue
		var access := int(_cache_access_order.get(path, 0))
		if not has_oldest or access < oldest_access:
			oldest_path = path
			oldest_access = access
			has_oldest = true

	return oldest_path


func _request_threaded(path: String, type_hint: String) -> Error:
	if type_hint.is_empty():
		return ResourceLoader.load_threaded_request(path)

	return ResourceLoader.load_threaded_request(path, type_hint)


func _get_threaded_status(path: String) -> ResourceLoader.ThreadLoadStatus:
	return ResourceLoader.load_threaded_get_status(path)


func _take_threaded_resource(path: String) -> Resource:
	return ResourceLoader.load_threaded_get(path)
