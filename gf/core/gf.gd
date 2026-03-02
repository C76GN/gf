# addons/gf/core/gf.gd
extends Node


## Gf: 全局入口单例，负责架构生命周期管理。


# --- 私有变量 ---

var _architecture: GFArchitecture = null


# --- 公共方法 ---

## 获取当前注册的架构实例。
## @return GFArchitecture 实例，如果未注册则返回 null。
func get_architecture() -> GFArchitecture:
	if _architecture == null:
		push_error("[GDCore] 架构尚未初始化，请先注册架构。")
	return _architecture


## 设置并初始化架构实例。该方法内部使用 await，调用方应加 await。
## @param architecture: 要注册的 GFArchitecture 实例。
func set_architecture(architecture: GFArchitecture) -> void:
	if _architecture != null and _architecture != architecture:
		_architecture.dispose()
	_architecture = architecture
	if not _architecture.is_inited():
		await _architecture.init()


# --- Godot 生命周期方法 ---

## 每帧驱动架构的 tick 循环，传递给所有已注册的 System。
func _process(delta: float) -> void:
	if _architecture != null:
		_architecture.tick(delta)


## 每物理帧驱动架构的 physics_tick 循环，传递给所有已注册的 System。
func _physics_process(delta: float) -> void:
	if _architecture != null:
		_architecture.physics_tick(delta)


## 节点退出树时清理架构。
func _exit_tree() -> void:
	if _architecture != null:
		_architecture.dispose()
		_architecture = null
