@tool
extends EditorPlugin


## GF Framework 编辑器插件。
## 在启用/禁用插件时自动注册/注销 Gf AutoLoad 单例。


func _enter_tree() -> void:
	add_autoload_singleton("Gf", "res://addons/gf/core/gf.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("Gf")
