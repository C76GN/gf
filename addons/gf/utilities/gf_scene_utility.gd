# addons/gf/utilities/gf_scene_utility.gd
class_name GFSceneUtility
extends GFUtility

## GFSceneUtility: 场景与流程切换管理器。
##
## 封装原生的场景切换，支持带有加载过渡层的异步加载。
## 提供可选的机制以在切换场景时清理不需要跨场景保留的 System/Model。

# --- 信号 ---

signal scene_load_started(path: String)
signal scene_load_progress(path: String, progress: float)
signal scene_load_completed(path: String, scene: PackedScene)
signal scene_load_failed(path: String)


# --- 私有变量 ---

var _target_path: String = ""
var _is_loading: bool = false
var _loading_scene_path: String = ""
var _transient_scripts: Array[Script] = []


# --- Godot 生命周期方法 ---

func tick(_delta: float) -> void:
	if not _is_loading or _target_path.is_empty():
		return
		
	var progress := []
	var status := ResourceLoader.load_threaded_get_status(_target_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var ratio: float = progress[0] if progress.size() > 0 else 0.0
			scene_load_progress.emit(_target_path, ratio)
			
		ResourceLoader.THREAD_LOAD_LOADED:
			var scene := ResourceLoader.load_threaded_get(_target_path) as PackedScene
			if scene != null:
				scene_load_completed.emit(_target_path, scene)
				_do_change_scene(scene)
			else:
				scene_load_failed.emit(_target_path)
			_is_loading = false
			_target_path = ""
			
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("[GFSceneUtility] 场景异步加载失败：" + _target_path)
			scene_load_failed.emit(_target_path)
			_is_loading = false
			_target_path = ""


# --- 公共方法 ---

## 异步切换场景。可指定加载中显示的过渡场景。
## @param path: 目标场景资源路径。
## @param loading_scene_path: 加载过渡场景资源路径，为空则直接在当前场景后台加载并在完成后硬切换。
func load_scene_async(path: String, loading_scene_path: String = "") -> void:
	if _is_loading:
		push_warning("[GFSceneUtility] 当前已有一个场景正在加载中：" + _target_path)
		return
		
	_target_path = path
	_loading_scene_path = loading_scene_path
	_is_loading = true
	
	scene_load_started.emit(path)
	
	# 如果指定了加载场景，则立即同步切换至该加载场景以作为过度
	if not _loading_scene_path.is_empty():
		_do_change_scene_sync(_loading_scene_path)
		
	# 发起异步加载请求
	var error := ResourceLoader.load_threaded_request(_target_path)
	if error != OK:
		push_error("[GFSceneUtility] 无法发起场景异步加载：" + _target_path)
		_is_loading = false
		_target_path = ""
		scene_load_failed.emit(path)


## 标记指定的 System 或 Model 脚本类型为瞬态。在下一次场景切换时将自动从 Architecture 中注销。
## @param script_cls: 脚本类（如 MySystem, MyModel）
func mark_transient(script_cls: Script) -> void:
	if not _transient_scripts.has(script_cls):
		_transient_scripts.append(script_cls)


## 取消标记，使该脚本类型跨场景保留。
## @param script_cls: 脚本类
func unmark_transient(script_cls: Script) -> void:
	_transient_scripts.erase(script_cls)


## 手动触发清理瞬态实例。通常会在场景异步加载完成后自动调用一次。
func cleanup_transients() -> void:
	if _transient_scripts.is_empty():
		return
		
	if not Gf.has_method("get_architecture"):
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

func _do_change_scene(scene: PackedScene) -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree != null:
		scene_tree.change_scene_to_packed(scene)
	cleanup_transients()


func _do_change_scene_sync(path: String) -> void:
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree != null:
		scene_tree.change_scene_to_file(path)
