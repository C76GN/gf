## GFBinding: 描述一个工厂绑定的来源、生命周期与依赖注入策略。
class_name GFBinding
extends RefCounted


# --- 常量 ---

const GFBindingLifetimesBase = preload("res://addons/gf/core/gf_binding_lifetimes.gd")


# --- 公共变量 ---

## 绑定键，通常为脚本类型。
var key: Variant

## 绑定来源，可以是 Callable 工厂或 Object 实例。
var provider: Variant

## 生命周期策略。
var lifetime: int = GFBindingLifetimesBase.Lifetime.TRANSIENT


# --- 私有变量 ---

var _owner_architecture: GFArchitecture = null
var _cached_instance: Object = null
var _has_cached_instance: bool = false
var _should_auto_inject: bool = true


# --- Godot 生命周期方法 ---

func _init(
	p_key: Variant,
	p_provider: Variant,
	p_owner_architecture: GFArchitecture,
	p_lifetime: int = GFBindingLifetimesBase.Lifetime.TRANSIENT,
	p_should_auto_inject: bool = true
) -> void:
	key = p_key
	provider = p_provider
	_owner_architecture = p_owner_architecture
	lifetime = p_lifetime
	_should_auto_inject = p_should_auto_inject


# --- 公共方法 ---

## 按当前生命周期解析实例。
## @param requesting_architecture: 发起解析的架构。Transient 会优先注入它，Singleton 始终注入拥有该绑定的架构。
## @return 解析出的 Object 实例；失败时返回 null。
func get_instance(requesting_architecture: GFArchitecture = null) -> Object:
	match lifetime:
		GFBindingLifetimesBase.Lifetime.SINGLETON:
			if _has_cached_instance:
				return _cached_instance

			_cached_instance = _provide(_owner_architecture)
			_has_cached_instance = true
			return _cached_instance

		GFBindingLifetimesBase.Lifetime.TRANSIENT:
			var injection_architecture := requesting_architecture
			if injection_architecture == null:
				injection_architecture = _owner_architecture
			return _provide(injection_architecture)

		_:
			push_error("[GFBinding] 未知生命周期：%s" % str(lifetime))
			return null


# --- 私有/辅助方法 ---

func _provide(injection_architecture: GFArchitecture) -> Object:
	var value: Variant
	if provider is Callable:
		value = (provider as Callable).call()
	else:
		value = provider

	if not value is Object:
		push_error("[GFBinding] 绑定来源必须返回 Object 实例。")
		return null

	var instance := value as Object
	if _should_auto_inject:
		_inject_if_needed(instance, injection_architecture)

	return instance


func _inject_if_needed(instance: Object, architecture: GFArchitecture) -> void:
	if instance == null or architecture == null:
		return

	if instance.has_method("inject_dependencies"):
		instance.inject_dependencies(architecture)
	if instance.has_method("inject"):
		instance.inject(architecture)
