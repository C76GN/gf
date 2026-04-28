extends Node


## Gf: 全局入口单例，负责架构生命周期管理。


# --- 常量 ---

## 项目级启动安装器配置。值为 GDScript 路径数组，脚本需继承 GFInstaller。
const INSTALLERS_SETTING: String = "gf/project/installers"
const GFInstallerBase = preload("res://addons/gf/core/gf_installer.gd")
const GFBindingLifetimesBase = preload("res://addons/gf/core/gf_binding_lifetimes.gd")


# --- 私有变量 ---

var _architecture: GFArchitecture = null


# --- 公共变量 ---

## 当前架构实例的只读访问器。
var architecture: GFArchitecture:
	get:
		return get_architecture()


# --- 公共方法 ---

## 检查当前是否已有架构实例。
## @return 已存在架构时返回 true。
func has_architecture() -> bool:
	return _architecture != null


## 获取当前架构；若尚未创建，则自动创建一个默认 GFArchitecture。
## @return 当前可用的 GFArchitecture 实例。
func create_architecture() -> GFArchitecture:
	if _architecture == null:
		_architecture = GFArchitecture.new()
	return _architecture


## 为当前架构创建声明式装配器。
## @return 绑定到当前架构的装配器。
func create_binder() -> Variant:
	return create_architecture().create_binder()


## 获取当前注册的架构实例。
## @return GFArchitecture 实例，如果未注册则返回 null。
func get_architecture() -> GFArchitecture:
	if _architecture == null:
		push_error("[GDCore] 架构尚未初始化，请先注册架构。")
	return _architecture


## 设置并初始化架构实例。该方法内部使用 await，调用方应加 await。
## @param architecture: 要注册的 GFArchitecture 实例。
func set_architecture(architecture_instance: GFArchitecture) -> void:
	if architecture_instance == null:
		push_error("[GDCore] set_architecture 失败：传入的架构实例为空。")
		return
		
	if _architecture != null and _architecture != architecture_instance:
		_architecture.dispose()
	_architecture = architecture_instance
	await _run_project_installers(_architecture)
	if not _architecture.is_inited():
		await _architecture.init()


## 初始化当前架构。若尚未创建架构，则自动创建默认 GFArchitecture。
func init() -> void:
	var current_arch := create_architecture()
	await _run_project_installers(current_arch)
	if not current_arch.is_inited():
		await current_arch.init()


# --- Godot 生命周期方法 ---

## 每帧驱动架构的 tick 循环，由架构分发给 System 与实现 tick() 的 Utility。
func _process(delta: float) -> void:
	if _architecture != null:
		_architecture.tick(delta)


## 每物理帧驱动架构的 physics_tick 循环，由架构分发给 System 与实现 physics_tick() 的 Utility。
func _physics_process(delta: float) -> void:
	if _architecture != null:
		_architecture.physics_tick(delta)


## 节点退出树时清理架构。
func _exit_tree() -> void:
	if _architecture != null:
		_architecture.dispose()
		_architecture = null


## 便捷注册 System 实例。
func register_system(instance: Object) -> void:
	await create_architecture().register_system_instance(instance)

## 便捷注册 Model 实例。
func register_model(instance: Object) -> void:
	await create_architecture().register_model_instance(instance)

## 便捷注册 Utility 实例。
func register_utility(instance: Object) -> void:
	await create_architecture().register_utility_instance(instance)

## 便捷替换 System 实例。
func replace_system(instance: Object) -> void:
	var script := _get_instance_script_or_null(instance, "replace_system")
	if script != null:
		await create_architecture().replace_system(script, instance)

## 便捷替换 Model 实例。
func replace_model(instance: Object) -> void:
	var script := _get_instance_script_or_null(instance, "replace_model")
	if script != null:
		await create_architecture().replace_model(script, instance)

## 便捷替换 Utility 实例。
func replace_utility(instance: Object) -> void:
	var script := _get_instance_script_or_null(instance, "replace_utility")
	if script != null:
		await create_architecture().replace_utility(script, instance)

## 注册短生命周期对象工厂。
func register_factory(
	script_cls: Script,
	factory: Callable,
	lifetime: int = GFBindingLifetimesBase.Lifetime.TRANSIENT
) -> void:
	create_architecture().register_factory(script_cls, factory, lifetime)

## 注册已有实例作为短生命周期工厂入口。
func register_factory_instance(script_cls: Script, instance: Object) -> void:
	create_architecture().register_factory_instance(script_cls, instance)

## 替换短生命周期对象工厂。
func replace_factory(
	script_cls: Script,
	factory: Callable,
	lifetime: int = GFBindingLifetimesBase.Lifetime.TRANSIENT
) -> void:
	create_architecture().replace_factory(script_cls, factory, lifetime)

## 替换已有实例工厂入口。
func replace_factory_instance(script_cls: Script, instance: Object) -> void:
	create_architecture().replace_factory_instance(script_cls, instance)

## 注销短生命周期对象工厂。
func unregister_factory(script_cls: Script) -> void:
	var arch := _get_architecture_or_null("unregister_factory")
	if arch != null:
		arch.unregister_factory(script_cls)


## 检查当前架构或父级架构是否注册了指定工厂。
func has_factory(script_cls: Script) -> bool:
	var arch := _get_architecture_or_null("has_factory")
	if arch == null:
		return false
	return arch.has_factory(script_cls)


## 创建短生命周期对象实例。
func create_instance(script_cls: Script) -> Object:
	var arch := _get_architecture_or_null("create_instance")
	if arch == null:
		return null
	return arch.create_instance(script_cls)


## 向任意对象注入当前架构依赖。
func inject_object(instance: Object) -> void:
	var arch := _get_architecture_or_null("inject_object")
	if arch != null:
		arch.inject_object(instance)


## 递归向节点树中实现注入 Hook 的节点注入当前架构。
func inject_node_tree(node: Node) -> void:
	var arch := _get_architecture_or_null("inject_node_tree")
	if arch != null:
		arch.inject_node_tree(node)


## 便捷注册 System 实例，并额外登记一个查询别名。
func register_system_as(instance: Object, alias_cls: Script) -> void:
	await create_architecture().register_system_instance_as(instance, alias_cls)

## 便捷注册 Model 实例，并额外登记一个查询别名。
func register_model_as(instance: Object, alias_cls: Script) -> void:
	await create_architecture().register_model_instance_as(instance, alias_cls)

## 便捷注册 Utility 实例，并额外登记一个查询别名。
func register_utility_as(instance: Object, alias_cls: Script) -> void:
	await create_architecture().register_utility_instance_as(instance, alias_cls)

## 为已注册 System 添加查询别名。
func register_system_alias(alias_cls: Script, target_cls: Script) -> void:
	var arch := _get_architecture_or_null("register_system_alias")
	if arch != null:
		arch.register_system_alias(alias_cls, target_cls)

## 为已注册 Model 添加查询别名。
func register_model_alias(alias_cls: Script, target_cls: Script) -> void:
	var arch := _get_architecture_or_null("register_model_alias")
	if arch != null:
		arch.register_model_alias(alias_cls, target_cls)

## 为已注册 Utility 添加查询别名。
func register_utility_alias(alias_cls: Script, target_cls: Script) -> void:
	var arch := _get_architecture_or_null("register_utility_alias")
	if arch != null:
		arch.register_utility_alias(alias_cls, target_cls)

## 获取 System 实例。
func get_system(script_cls: Script) -> Object:
	var arch := _get_architecture_or_null("get_system")
	if arch == null:
		return null
	return arch.get_system(script_cls)

## 获取 Model 实例。
func get_model(script_cls: Script) -> Object:
	var arch := _get_architecture_or_null("get_model")
	if arch == null:
		return null
	return arch.get_model(script_cls)

## 获取 Utility 实例。
func get_utility(script_cls: Script) -> Object:
	var arch := _get_architecture_or_null("get_utility")
	if arch == null:
		return null
	return arch.get_utility(script_cls)

## 便捷发送全局命令。
func send_command(command: Object) -> Variant:
	var arch := _get_architecture_or_null("send_command")
	if arch == null:
		return null
	return arch.send_command(command)

## 便捷发送查询。
func send_query(query: Object) -> Variant:
	var arch := _get_architecture_or_null("send_query")
	if arch == null:
		return null
	return arch.send_query(query)

## 便捷发送带载体的强类型事件。
func send_event(event_instance: Object) -> void:
	var arch := _get_architecture_or_null("send_event")
	if arch != null:
		arch.send_event(event_instance)

## 便捷发送无参数的轻量级事件。
func send_simple_event(event_id: StringName, payload: Variant = null) -> void:
	var arch := _get_architecture_or_null("send_simple_event")
	if arch != null:
		arch.send_simple_event(event_id, payload)

## 快捷注册类型事件监听（别名：listen）。
func listen(event_type: Script, on_event: Callable, priority: int = 0) -> void:
	var arch := _get_architecture_or_null("listen")
	if arch != null:
		arch.register_event(event_type, on_event, priority)

## 快捷注册带拥有者的类型事件监听。
func listen_owned(listener_owner: Object, event_type: Script, on_event: Callable, priority: int = 0) -> void:
	var arch := _get_architecture_or_null("listen_owned")
	if arch != null:
		arch.register_event_owned(listener_owner, event_type, on_event, priority)

## 快捷注销类型事件监听（别名：unlisten）。
func unlisten(event_type: Script, on_event: Callable) -> void:
	var arch := _get_architecture_or_null("unlisten")
	if arch != null:
		arch.unregister_event(event_type, on_event)

## 快捷注册轻量事件监听（别名：listen_simple）。
func listen_simple(event_id: StringName, on_event: Callable) -> void:
	var arch := _get_architecture_or_null("listen_simple")
	if arch != null:
		arch.register_simple_event(event_id, on_event)

## 快捷注册带拥有者的轻量事件监听。
func listen_simple_owned(listener_owner: Object, event_id: StringName, on_event: Callable) -> void:
	var arch := _get_architecture_or_null("listen_simple_owned")
	if arch != null:
		arch.register_simple_event_owned(listener_owner, event_id, on_event)

## 快捷注销轻量事件监听（别名：unlisten_simple）。
func unlisten_simple(event_id: StringName, on_event: Callable) -> void:
	var arch := _get_architecture_or_null("unlisten_simple")
	if arch != null:
		arch.unregister_simple_event(event_id, on_event)

## 快捷注销某个拥有者注册过的所有事件监听。
func unlisten_owner(listener_owner: Object) -> void:
	var arch := _get_architecture_or_null("unlisten_owner")
	if arch != null:
		arch.unregister_owner_events(listener_owner)

## 注销 System 实例。
func unregister_system(script_cls: Script) -> void:
	var arch := _get_architecture_or_null("unregister_system")
	if arch != null:
		arch.unregister_system(script_cls)

## 注销 Model 实例。
func unregister_model(script_cls: Script) -> void:
	var arch := _get_architecture_or_null("unregister_model")
	if arch != null:
		arch.unregister_model(script_cls)

## 注销 Utility 实例。
func unregister_utility(script_cls: Script) -> void:
	var arch := _get_architecture_or_null("unregister_utility")
	if arch != null:
		arch.unregister_utility(script_cls)


# --- 私有/辅助方法 ---

func _get_architecture_or_null(context: String) -> GFArchitecture:
	if _architecture == null:
		push_error("[GDCore] %s 失败：架构尚未初始化，请先注册架构。" % context)
		return null
	return _architecture


func _get_instance_script_or_null(instance: Object, context: String) -> Script:
	if instance == null:
		push_error("[GDCore] %s 失败：实例为空。" % context)
		return null
	var script := instance.get_script() as Script
	if script == null:
		push_error("[GDCore] %s 失败：实例未附加脚本。" % context)
		return null
	return script


func _run_project_installers(architecture_instance: GFArchitecture) -> void:
	if architecture_instance == null or architecture_instance.has_project_installers_applied():
		return

	if architecture_instance.is_project_installers_running():
		await architecture_instance.project_installers_finished
		return

	if not architecture_instance.begin_project_installers():
		return

	var installer_paths := _get_project_installer_paths()
	for path: String in installer_paths:
		var installer: Object = _create_installer(path)
		if installer != null:
			await installer.install(architecture_instance)
			if not architecture_instance.is_project_installers_running():
				return
			if installer.has_method("install_bindings"):
				await installer.install_bindings(architecture_instance.create_binder())
		if not architecture_instance.is_project_installers_running():
			return

	architecture_instance.finish_project_installers()


func _get_project_installer_paths() -> Array[String]:
	var raw_paths: Variant = ProjectSettings.get_setting(INSTALLERS_SETTING, [])
	var installer_paths: Array[String] = []

	if raw_paths is PackedStringArray:
		for path: String in raw_paths:
			installer_paths.append(path)
		return installer_paths

	if raw_paths is Array:
		for path_variant: Variant in raw_paths:
			if typeof(path_variant) == TYPE_STRING:
				installer_paths.append(String(path_variant))
			else:
				push_warning("[GDCore] 项目 Installer 配置包含非字符串项，已跳过。")
		return installer_paths

	push_error("[GDCore] 项目 Installer 配置必须是路径数组。")
	return installer_paths


func _create_installer(path: String) -> Object:
	if path.is_empty():
		push_error("[GDCore] 项目 Installer 路径为空。")
		return null

	var installer_script := load(path) as Script
	if installer_script == null:
		push_error("[GDCore] 无法加载项目 Installer：%s" % path)
		return null

	if not installer_script.can_instantiate():
		push_error("[GDCore] 项目 Installer 无法实例化：%s" % path)
		return null

	var instance: Object = installer_script.new()
	if not (instance is GFInstallerBase):
		push_error("[GDCore] 项目 Installer 必须继承 GFInstaller：%s" % path)
		return null

	return instance
