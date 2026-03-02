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


## 设置并初始化架构实例。
## @param architecture: 要注册的 GFArchitecture 实例。
func set_architecture(architecture: GFArchitecture) -> void:
	if _architecture != null and _architecture != architecture:
		_architecture.dispose()
	_architecture = architecture
	if not _architecture.is_inited():
		_architecture.init()


# --- Godot 生命周期方法 ---

## 节点退出树时清理架构。
func _exit_tree() -> void:
	if _architecture != null:
		_architecture.dispose()
		_architecture = null
