## GFSceneUtility: 场景与流程切换管理器。
##
## 封装原生场景切换，支持带有 `loading scene` 的异步加载，
## 并可在切换完成后清理不需要跨场景保留的 `System/Model`。
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


# --- 私有变量 ---

## 当前正在加载的目标场景路径。
var _target_path: String = ""

## 当前是否处于加载流程中。
var _is_loading: bool = false

## 过渡用 loading scene 路径。
var _loading_scene_path: String = ""

## 下次切场景时要清理的瞬态脚本列表。
var _transient_scripts: Array[Script] = []

## 切场景前的暂停状态。
var _previous_pause_state: bool = false

## 切场景前的场景路径，用于失败回退。
var _previous_scene_path: String = ""

## 当前是否已经切换到了 loading scene。
var _is_showing_loading_scene: bool = false


# --- Godot 生命周期方法 ---

func tick(_delta: float) -> void:
	if not _is_loading or _target_path.is_empty():
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

			scene_load_completed.emit(loaded_path, scene)
			if _do_change_scene(scene):
				_set_paused(_previous_pause_state)
				_reset_loading_state()
			else:
				_fail_loading(loaded_path, "")

		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_fail_loading(_target_path, "[GFSceneUtility] 场景异步加载失败：%s" % _target_path)


# --- 公共方法 ---

## 异步切换场景。
## @param path: 目标场景资源路径。
## @param loading_scene_path: 可选的过渡场景路径。
func load_scene_async(path: String, loading_scene_path: String = "") -> void:
	if _is_loading:
		push_warning("[GFSceneUtility] 当前已有场景正在加载中：%s" % _target_path)
		return

	_target_path = path
	_loading_scene_path = loading_scene_path
	_is_loading = true
	_previous_pause_state = _get_paused()
	_previous_scene_path = _get_current_scene_path()
	_is_showing_loading_scene = false
	_set_paused(true)

	scene_load_started.emit(path)

	var error := ResourceLoader.load_threaded_request(_target_path)
	if error != OK:
		_fail_loading(path, "[GFSceneUtility] 无法发起场景异步加载：%s (错误码：%d)" % [_target_path, error])
		return

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

	if not Gf.has_method("has_architecture") or not Gf.has_architecture():
		return

	var arch: Object = Gf.get_architecture()
	if arch == null:
		return

	for script_cls: Script in _transient_scripts:
		if arch.has_method("unregister_system"):
			arch.unregister_system(script_cls)
		if arch.has_method("unregister_model"):
			arch.unregister_model(script_cls)

	_transient_scripts.clear()


# --- 私有/辅助方法 ---

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
	if not Gf.has_architecture():
		return

	var arch := Gf.get_architecture()
	if arch == null:
		return

	var time_util = arch.get_utility(GFTimeUtility)
	if time_util != null:
		time_util.is_paused = p_paused


func _get_paused() -> bool:
	if not Gf.has_architecture():
		return false

	var arch := Gf.get_architecture()
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


func _reset_loading_state() -> void:
	_is_loading = false
	_target_path = ""
	_loading_scene_path = ""
	_previous_scene_path = ""
	_is_showing_loading_scene = false


func _get_current_scene_path() -> String:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null or scene_tree.current_scene == null:
		return ""

	return scene_tree.current_scene.scene_file_path
