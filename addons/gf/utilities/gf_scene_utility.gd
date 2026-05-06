## GFSceneUtility: 场景与流程切换管理器。
##
## 封装原生场景切换，支持带有 `loading scene` 的异步加载、PackedScene
## 资源预加载缓存，并可在切换完成后清理不需要跨场景保留的 `System/Model`。
class_name GFSceneUtility
extends GFUtility


# --- 信号 ---

## 当场景异步加载开始时发出。
## @param path: 目标场景路径。
signal scene_load_started(path: String)

## 当场景异步加载进度更新时发出。
## @param path: 目标场景路径。
## @param progress: 当前进度，范围在 `0.0` 到 `1.0` 之间。
signal scene_load_progress(path: String, progress: float)

## 当场景异步加载完成时发出。
## @param path: 目标场景路径。
## @param scene: 已加载完成的场景资源。
signal scene_load_completed(path: String, scene: PackedScene)

## 当场景异步加载失败时发出。
## @param path: 目标场景路径。
signal scene_load_failed(path: String)

## 当场景预加载开始时发出。
## @param path: 目标场景路径。
signal scene_preload_started(path: String)

## 当场景预加载进度更新时发出。
## @param path: 目标场景路径。
## @param progress: 当前进度，范围在 `0.0` 到 `1.0` 之间。
signal scene_preload_progress(path: String, progress: float)

## 当场景预加载完成并进入缓存时发出。
## @param path: 目标场景路径。
## @param scene: 已缓存的场景资源。
signal scene_preload_completed(path: String, scene: PackedScene)

## 当场景预加载失败时发出。
## @param path: 目标场景路径。
signal scene_preload_failed(path: String)

## 当场景预加载被取消时发出。
## @param path: 目标场景路径。
signal scene_preload_cancelled(path: String)


# --- 枚举 ---

## 场景资源在 GFSceneUtility 内部的缓存状态。
enum SceneResourceState {
	## 未加载。
	NOT_LOADED,
	## 正在预加载。
	PRELOADING,
	## 已缓存 PackedScene。
	PRELOADED,
	## 当前 load_scene_async() 正在等待该资源。
	ACTIVE_LOADING,
}


# --- 常量 ---

const GFSceneTransitionConfigBase = preload("res://addons/gf/utilities/gf_scene_transition_config.gd")


# --- 公共变量 ---

## 最多保留的预加载 PackedScene 数量；设为 `0` 表示禁用预加载缓存。
var max_preloaded_scene_resources: int:
	get:
		return _max_preloaded_scene_resources
	set(value):
		_max_preloaded_scene_resources = maxi(value, 0)
		if _max_preloaded_scene_resources == 0:
			clear_preloaded_scenes()
			return
		_evict_preloaded_scenes()

## 通过 load_scene_async() 加载完成的目标场景是否写入预加载缓存。
var cache_loaded_scenes: bool = true


# --- 私有变量 ---

var _max_preloaded_scene_resources: int = 8
var _target_path: String = ""
var _is_loading: bool = false
var _loading_scene_path: String = ""
var _transient_scripts: Array[Script] = []
var _previous_pause_state: bool = false
var _previous_scene_path: String = ""
var _is_showing_loading_scene: bool = false
var _active_load_uses_preload_request: bool = false
var _active_load_cache_loaded_scene: bool = true
var _preload_requests: Dictionary = {}
var _preloaded_scenes: Dictionary = {}
var _preloaded_scene_access_order: Dictionary = {}
var _preloaded_scene_access_serial: int = 0


# --- Godot 生命周期方法 ---

func init() -> void:
	ignore_pause = true


## 推进运行时逻辑。
## @param _delta: 本帧时间增量（秒），默认实现不直接使用。
func tick(_delta: float) -> void:
	_poll_preload_requests()
	_poll_active_scene_load()


func dispose() -> void:
	_reset_loading_state()
	_preload_requests.clear()
	clear_preloaded_scenes()


# --- 公共方法 ---

## 异步切换场景。
## @param path: 目标场景资源路径。
## @param loading_scene_path: 可选的过渡场景路径。
func load_scene_async(path: String, loading_scene_path: String = "") -> void:
	if _is_loading:
		push_warning("[GFSceneUtility] 当前已有场景正在加载中：%s" % _target_path)
		return

	var validation_error := _validate_scene_resource_path(path, "load_scene_async")
	if not validation_error.is_empty():
		push_error(validation_error)
		scene_load_failed.emit(path)
		return

	var effective_loading_scene_path := _resolve_loading_scene_path(loading_scene_path)
	_begin_loading_state(path, effective_loading_scene_path, cache_loaded_scenes)
	scene_load_started.emit(path)

	var cached_scene := get_preloaded_scene(path)
	if cached_scene != null:
		scene_load_progress.emit(path, 1.0)
		_complete_loading(path, cached_scene)
		return

	if is_scene_preloading(path):
		_active_load_uses_preload_request = true
		_show_loading_scene_if_needed()
		return

	var error := ResourceLoader.load_threaded_request(_target_path, "PackedScene")
	if error != OK:
		_fail_loading(path, "[GFSceneUtility] 无法发起场景异步加载：%s (错误码：%d)" % [_target_path, error])
		return

	_show_loading_scene_if_needed()


## 按资源配置切换场景。
## @param config: 场景切换配置。
## @return 发起切换的 Godot Error。
func load_scene_with_transition(config: GFSceneTransitionConfigBase) -> Error:
	if config == null:
		push_error("[GFSceneUtility] load_scene_with_transition 失败：config 为空。")
		scene_load_failed.emit("")
		return ERR_INVALID_PARAMETER

	if config.preload_before_change:
		var preload_error := preload_scene(config.target_scene_path)
		if preload_error != OK:
			return preload_error

	var previous_cache_loaded_scenes := cache_loaded_scenes
	cache_loaded_scenes = config.cache_loaded_scene
	load_scene_async(config.target_scene_path, config.loading_scene_path)
	cache_loaded_scenes = previous_cache_loaded_scenes
	return OK


## 预加载一个场景资源并放入 LRU 缓存。
## @param path: 目标场景资源路径。
## @return 发起请求的 Godot Error。
func preload_scene(path: String) -> Error:
	var validation_error := _validate_scene_resource_path(path, "preload_scene")
	if not validation_error.is_empty():
		push_error(validation_error)
		scene_preload_failed.emit(path)
		return ERR_INVALID_PARAMETER

	if is_scene_preloaded(path):
		_touch_preloaded_scene(path)
		return OK
	if is_scene_preloading(path):
		return OK

	var error := ResourceLoader.load_threaded_request(path, "PackedScene")
	if error != OK:
		push_error("[GFSceneUtility] 无法发起场景预加载：%s (错误码：%d)" % [path, error])
		scene_preload_failed.emit(path)
		return error

	_preload_requests[path] = {
		"progress": 0.0,
		"cancelled": false,
	}
	scene_preload_started.emit(path)
	return OK


## 批量预加载场景资源。
## @param paths: 场景路径数组。
## @return path -> Error 的结果字典。
func preload_scenes(paths: PackedStringArray) -> Dictionary:
	var result: Dictionary = {}
	for path: String in paths:
		result[path] = preload_scene(path)
	return result


## 取消一个仍在进行中的预加载请求。
## @param path: 场景路径。
func cancel_scene_preload(path: String) -> void:
	if not _preload_requests.has(path):
		return

	var request := _preload_requests[path] as Dictionary
	request["cancelled"] = true
	scene_preload_cancelled.emit(path)


## 取消全部正在进行中的预加载请求。
func cancel_all_scene_preloads() -> void:
	for path: String in _preload_requests.keys():
		cancel_scene_preload(path)


## 检查场景是否正在预加载。
## @param path: 场景路径。
## @return 正在预加载时返回 true。
func is_scene_preloading(path: String) -> bool:
	if not _preload_requests.has(path):
		return false
	return not bool((_preload_requests[path] as Dictionary).get("cancelled", false))


## 检查场景是否已经预加载到缓存。
## @param path: 场景路径。
## @return 已缓存时返回 true。
func is_scene_preloaded(path: String) -> bool:
	return _preloaded_scenes.has(path)


## 获取已预加载的 PackedScene。
## @param path: 场景路径。
## @return 命中缓存时返回 PackedScene，否则返回 null。
func get_preloaded_scene(path: String) -> PackedScene:
	var scene := _preloaded_scenes.get(path) as PackedScene
	if scene != null:
		_touch_preloaded_scene(path)
	return scene


## 手动写入预加载缓存。
## @param path: 场景路径。
## @param scene: PackedScene 实例。
func put_preloaded_scene(path: String, scene: PackedScene) -> void:
	if path.is_empty() or scene == null or max_preloaded_scene_resources <= 0:
		return

	_preloaded_scenes[path] = scene
	_touch_preloaded_scene(path)
	_evict_preloaded_scenes()


## 移除一个预加载场景资源。
## @param path: 场景路径。
func remove_preloaded_scene(path: String) -> void:
	_preloaded_scenes.erase(path)
	_preloaded_scene_access_order.erase(path)


## 清空所有预加载场景资源。
func clear_preloaded_scenes() -> void:
	_preloaded_scenes.clear()
	_preloaded_scene_access_order.clear()
	_preloaded_scene_access_serial = 0


## 获取正在预加载的场景路径列表。
## @return 路径列表。
func get_preloading_scene_paths() -> PackedStringArray:
	var result := PackedStringArray()
	for path: String in _preload_requests.keys():
		if is_scene_preloading(path):
			result.append(path)
	result.sort()
	return result


## 获取场景缓存与加载状态快照。
## @return 调试快照字典。
func get_scene_cache_debug_snapshot() -> Dictionary:
	var preloading_paths := get_preloading_scene_paths()
	return {
		"is_loading": _is_loading,
		"target_path": _target_path,
		"current_scene": _get_current_scene_path(),
		"previous_scene": _previous_scene_path,
		"preload_cache": {
			"size": _preloaded_scenes.size(),
			"max_size": max_preloaded_scene_resources,
			"paths": _get_sorted_string_keys(_preloaded_scenes),
		},
		"preloading": {
			"size": preloading_paths.size(),
			"paths": preloading_paths,
		},
	}


## 获取场景资源状态。
## @param path: 场景路径。
## @return SceneResourceState 枚举值。
func get_scene_resource_state(path: String) -> int:
	if _is_loading and _target_path == path:
		return SceneResourceState.ACTIVE_LOADING
	if is_scene_preloading(path):
		return SceneResourceState.PRELOADING
	if is_scene_preloaded(path):
		return SceneResourceState.PRELOADED
	return SceneResourceState.NOT_LOADED


## 标记一个脚本类型为瞬态实例。
## @param script_cls: 需要在下次切场景时清理的脚本类型。
func mark_transient(script_cls: Script) -> void:
	if not _transient_scripts.has(script_cls):
		_transient_scripts.append(script_cls)


## 取消一个脚本类型的瞬态标记。
## @param script_cls: 要取消标记的脚本类型。
func unmark_transient(script_cls: Script) -> void:
	_transient_scripts.erase(script_cls)


## 立即清理所有瞬态实例。
func cleanup_transients() -> void:
	if _transient_scripts.is_empty():
		return

	var arch: Object = _get_architecture_or_null()
	if arch == null:
		return

	for script_cls: Script in _transient_scripts:
		if arch.has_method("unregister_system"):
			arch.unregister_system(script_cls)
		if arch.has_method("unregister_model"):
			arch.unregister_model(script_cls)

	_transient_scripts.clear()


# --- 私有/辅助方法 ---

func _poll_active_scene_load() -> void:
	if not _is_loading or _target_path.is_empty():
		return

	if _active_load_uses_preload_request:
		_poll_active_preload_scene()
		return

	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(_target_path, progress)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var ratio: float = progress[0] if progress.size() > 0 else 0.0
			scene_load_progress.emit(_target_path, ratio)

		ResourceLoader.THREAD_LOAD_LOADED:
			var loaded_path := _target_path
			var scene := ResourceLoader.load_threaded_get(loaded_path) as PackedScene
			if scene == null:
				_fail_loading(loaded_path, "[GFSceneUtility] 异步加载完成，但目标资源不是 PackedScene：%s" % loaded_path)
				return

			if _active_load_cache_loaded_scene:
				put_preloaded_scene(loaded_path, scene)
			_complete_loading(loaded_path, scene)

		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_fail_loading(_target_path, "[GFSceneUtility] 场景异步加载失败：%s" % _target_path)


func _poll_active_preload_scene() -> void:
	if not _preload_requests.has(_target_path):
		var cached_scene := get_preloaded_scene(_target_path)
		if cached_scene != null:
			scene_load_progress.emit(_target_path, 1.0)
			_complete_loading(_target_path, cached_scene)
		else:
			_fail_loading(_target_path, "[GFSceneUtility] 场景预加载未完成：%s" % _target_path)
		return

	var request := _preload_requests[_target_path] as Dictionary
	if bool(request.get("cancelled", false)):
		_fail_loading(_target_path, "[GFSceneUtility] 场景预加载已取消：%s" % _target_path)
		return

	scene_load_progress.emit(_target_path, float(request.get("progress", 0.0)))


func _poll_preload_requests() -> void:
	if _preload_requests.is_empty():
		return

	var paths := _preload_requests.keys()
	for path: String in paths:
		if not _preload_requests.has(path):
			continue

		var request := _preload_requests[path] as Dictionary
		var progress: Array = []
		var status := ResourceLoader.load_threaded_get_status(path, progress)
		var ratio: float = progress[0] if progress.size() > 0 else float(request.get("progress", 0.0))
		request["progress"] = ratio

		if not bool(request.get("cancelled", false)):
			scene_preload_progress.emit(path, ratio)

		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				pass

			ResourceLoader.THREAD_LOAD_LOADED:
				var scene := ResourceLoader.load_threaded_get(path) as PackedScene
				_preload_requests.erase(path)
				if bool(request.get("cancelled", false)):
					continue
				if scene == null:
					scene_preload_failed.emit(path)
					continue
				put_preloaded_scene(path, scene)
				scene_preload_completed.emit(path, scene)

			ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				_preload_requests.erase(path)
				if not bool(request.get("cancelled", false)):
					scene_preload_failed.emit(path)


func _begin_loading_state(path: String, loading_scene_path: String, should_cache_loaded_scene: bool) -> void:
	_target_path = path
	_loading_scene_path = loading_scene_path
	_is_loading = true
	_active_load_uses_preload_request = false
	_active_load_cache_loaded_scene = should_cache_loaded_scene
	_previous_pause_state = _get_paused()
	_previous_scene_path = _get_current_scene_path()
	_is_showing_loading_scene = false
	_set_paused(true)


func _resolve_loading_scene_path(loading_scene_path: String) -> String:
	if loading_scene_path.is_empty():
		return ""

	var loading_validation_error := _validate_scene_resource_path(loading_scene_path, "loading_scene")
	if not loading_validation_error.is_empty():
		push_warning(loading_validation_error)
		return ""
	return loading_scene_path


func _show_loading_scene_if_needed() -> void:
	if _loading_scene_path.is_empty():
		return

	if _previous_scene_path.is_empty():
		push_warning("[GFSceneUtility] 当前场景缺少 scene_file_path，跳过 loading scene 以避免失败后无法恢复。")
		return

	var loading_error := _do_change_scene_sync(_loading_scene_path)
	if loading_error == OK:
		_is_showing_loading_scene = true
	else:
		push_error("[GFSceneUtility] 无法切换到 loading scene：%s (错误码：%d)" % [_loading_scene_path, loading_error])


func _complete_loading(path: String, scene: PackedScene) -> void:
	scene_load_completed.emit(path, scene)
	if _do_change_scene(scene):
		_set_paused(_previous_pause_state)
		_reset_loading_state()
	else:
		_fail_loading(path, "")


func _do_change_scene(scene: PackedScene) -> bool:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		push_error("[GFSceneUtility] 无法获取 SceneTree，场景切换失败。")
		return false

	var error := scene_tree.change_scene_to_packed(scene)
	if error != OK:
		push_error("[GFSceneUtility] 切换到目标场景失败，错误码：%d" % error)
		return false

	cleanup_transients()
	return true


func _do_change_scene_sync(path: String) -> Error:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		return ERR_UNAVAILABLE

	return scene_tree.change_scene_to_file(path)


## 设置全局暂停状态；若未注册 `GFTimeUtility` 则静默跳过。
## @param p_paused: 目标暂停状态。
func _set_paused(p_paused: bool) -> void:
	var arch := _get_architecture_or_null()
	if arch == null:
		return

	var time_util = arch.get_utility(GFTimeUtility)
	if time_util != null:
		time_util.is_paused = p_paused


func _get_paused() -> bool:
	var arch := _get_architecture_or_null()
	if arch == null:
		return false

	var time_util = arch.get_utility(GFTimeUtility)
	return time_util.is_paused if time_util != null else false


func _fail_loading(path: String, message: String) -> void:
	if not message.is_empty():
		push_error(message)

	scene_load_failed.emit(path)
	_restore_previous_scene_if_needed()
	_set_paused(_previous_pause_state)
	_reset_loading_state()


func _restore_previous_scene_if_needed() -> void:
	if not _is_showing_loading_scene:
		return

	if _previous_scene_path.is_empty():
		push_warning("[GFSceneUtility] 无法恢复上一场景：缺少 scene_file_path。")
		return

	var error := _do_change_scene_sync(_previous_scene_path)
	if error != OK:
		push_error("[GFSceneUtility] 恢复上一场景失败：%s (错误码：%d)" % [_previous_scene_path, error])


func _validate_scene_resource_path(path: String, label: String) -> String:
	if path.is_empty():
		return "[GFSceneUtility] %s 失败：path 为空。" % label
	if not ResourceLoader.exists(path):
		return "[GFSceneUtility] %s 失败：资源不存在：%s" % [label, path]

	var extension := path.get_extension().to_lower()
	var scene_extensions := ResourceLoader.get_recognized_extensions_for_type("PackedScene")
	if not scene_extensions.has(extension):
		return "[GFSceneUtility] %s 失败：资源不是 PackedScene：%s" % [label, path]
	return ""


func _reset_loading_state() -> void:
	_is_loading = false
	_target_path = ""
	_loading_scene_path = ""
	_previous_scene_path = ""
	_is_showing_loading_scene = false
	_active_load_uses_preload_request = false
	_active_load_cache_loaded_scene = true


func _get_current_scene_path() -> String:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null or scene_tree.current_scene == null:
		return ""

	return scene_tree.current_scene.scene_file_path


func _touch_preloaded_scene(path: String) -> void:
	_preloaded_scene_access_serial += 1
	_preloaded_scene_access_order[path] = _preloaded_scene_access_serial


func _evict_preloaded_scenes() -> void:
	while _preloaded_scenes.size() > max_preloaded_scene_resources and max_preloaded_scene_resources > 0:
		var oldest_path := _get_oldest_preloaded_scene_path()
		if oldest_path.is_empty():
			return
		remove_preloaded_scene(oldest_path)


func _get_oldest_preloaded_scene_path() -> String:
	var oldest_path := ""
	var oldest_access := 0
	var has_oldest := false
	for path: String in _preloaded_scenes:
		var access := int(_preloaded_scene_access_order.get(path, 0))
		if not has_oldest or access < oldest_access:
			oldest_path = path
			oldest_access = access
			has_oldest = true
	return oldest_path


func _get_sorted_string_keys(data: Dictionary) -> PackedStringArray:
	var result := PackedStringArray()
	for key: Variant in data.keys():
		result.append(String(key))
	result.sort()
	return result
