## GFBinder: 面向 Installer 的声明式装配入口。
class_name GFBinder
extends RefCounted


# --- 常量 ---

const GFBindBuilderBase = preload("res://addons/gf/core/gf_bind_builder.gd")


# --- 私有变量 ---

var _architecture: GFArchitecture = null


# --- Godot 生命周期方法 ---

func _init(architecture: GFArchitecture) -> void:
	_architecture = architecture


# --- 公共方法 ---

## 声明一个 Model 绑定。
## @param script_cls: Model 脚本类型。
## @return 绑定构建器。
func bind_model(script_cls: Script) -> Variant:
	return GFBindBuilderBase.new(_architecture, GFBindBuilderBase.TargetKind.MODEL, script_cls)


## 声明一个 System 绑定。
## @param script_cls: System 脚本类型。
## @return 绑定构建器。
func bind_system(script_cls: Script) -> Variant:
	return GFBindBuilderBase.new(_architecture, GFBindBuilderBase.TargetKind.SYSTEM, script_cls)


## 声明一个 Utility 绑定。
## @param script_cls: Utility 脚本类型。
## @return 绑定构建器。
func bind_utility(script_cls: Script) -> Variant:
	return GFBindBuilderBase.new(_architecture, GFBindBuilderBase.TargetKind.UTILITY, script_cls)


## 声明一个短生命周期对象工厂绑定。
## @param script_cls: 要创建的脚本类型。
## @return 绑定构建器。
func bind_factory(script_cls: Script) -> Variant:
	return GFBindBuilderBase.new(_architecture, GFBindBuilderBase.TargetKind.FACTORY, script_cls)
