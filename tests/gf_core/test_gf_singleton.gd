## 测试 Gf 全局单例的便捷代理方法 (Facade 模式)
extends GutTest


# --- 常量 ---

const INSTALLERS_SETTING: String = "gf/project/installers"
const TEST_INSTALLER_PATH: String = "res://tests/gf_core/fixtures/installers/gf_test_installer.gd"
const ASYNC_BINDING_INSTALLER_PATH: String = "res://tests/gf_core/fixtures/installers/gf_async_binding_installer.gd"
const BLOCKING_BINDING_INSTALLER_PATH: String = "res://tests/gf_core/fixtures/installers/gf_blocking_binding_installer.gd"
const BLOCKING_INSTALLER_STARTED_SETTING: String = "gf/test/blocking_installer_started"
const BLOCKING_INSTALLER_RELEASE_SETTING: String = "gf/test/release_blocking_installer"
const GFNodeContextBase = preload("res://addons/gf/core/gf_node_context.gd")
const InstallerModelFixture = preload("res://tests/gf_core/fixtures/installers/installer_model_fixture.gd")
const AsyncInstallerUtilityFixture = preload("res://tests/gf_core/fixtures/installers/async_installer_utility_fixture.gd")


# --- 辅助类 ---

class DummyModel extends GFModel:
	pass

class DummySystem extends GFSystem:
	pass

class DummyUtility extends GFUtility:
	pass

class NotUtility extends RefCounted:
	pass

class UtilityBase extends GFUtility:
	pass

class ConcreteUtility extends UtilityBase:
	pass

class AlternateConcreteUtility extends UtilityBase:
	pass

class DisposableUtility extends GFUtility:
	var disposed: bool = false

	func dispose() -> void:
		disposed = true

class InjectedUtility extends GFUtility:
	var injected_architecture: GFArchitecture = null

	func inject_dependencies(architecture: GFArchitecture) -> void:
		injected_architecture = architecture

class ParentScopedUtility extends GFUtility:
	var disposed: bool = false

	func dispose() -> void:
		disposed = true

class LocalScopedUtility extends GFUtility:
	var disposed: bool = false

	func dispose() -> void:
		disposed = true

class LocalLookupSystem extends GFSystem:
	var local_utility: LocalScopedUtility = null
	var parent_utility: ParentScopedUtility = null

	func ready() -> void:
		local_utility = get_utility(LocalScopedUtility) as LocalScopedUtility
		parent_utility = get_utility(ParentScopedUtility) as ParentScopedUtility

class ScopedController extends GFController:
	func get_local_utility() -> LocalScopedUtility:
		return get_utility(LocalScopedUtility) as LocalScopedUtility

	func get_parent_utility() -> ParentScopedUtility:
		return get_utility(ParentScopedUtility) as ParentScopedUtility

class ControllerHost extends Node:
	pass

class DerivedControllerHost extends ControllerHost:
	pass

class OtherControllerHost extends Node:
	pass

class ScopedContext extends GFNodeContextBase:
	var local_utility: LocalScopedUtility = null
	var lookup_system: LocalLookupSystem = null

	func _init() -> void:
		scope_mode = GFNodeContextBase.ScopeMode.SCOPED

	func install(architecture_instance: GFArchitecture) -> void:
		local_utility = LocalScopedUtility.new()
		lookup_system = LocalLookupSystem.new()
		architecture_instance.register_utility_instance(local_utility)
		architecture_instance.register_system_instance(lookup_system)

class InheritedContext extends GFNodeContextBase:
	func _init() -> void:
		scope_mode = GFNodeContextBase.ScopeMode.INHERITED

class ParentSlowScopedContext extends GFNodeContextBase:
	var slow_utility: SlowInitUtility = null

	func _init() -> void:
		scope_mode = GFNodeContextBase.ScopeMode.SCOPED

	func install(architecture_instance: GFArchitecture) -> void:
		slow_utility = SlowInitUtility.new()
		architecture_instance.register_utility_instance(slow_utility)

class ParentReadyLookupSystem extends GFSystem:
	var parent_ready_at_ready: bool = false

	func ready() -> void:
		var parent_utility := get_utility(SlowInitUtility) as SlowInitUtility
		parent_ready_at_ready = parent_utility != null and parent_utility.ready_called

class ChildScopedContext extends GFNodeContextBase:
	var lookup_system: ParentReadyLookupSystem = null

	func _init() -> void:
		scope_mode = GFNodeContextBase.ScopeMode.SCOPED

	func install(architecture_instance: GFArchitecture) -> void:
		lookup_system = ParentReadyLookupSystem.new()
		architecture_instance.register_system_instance(lookup_system)

class FactoryCommand extends GFCommand:
	func get_parent_utility_from_command() -> ParentScopedUtility:
		return get_utility(ParentScopedUtility) as ParentScopedUtility

class InjectedFactoryCommand extends GFCommand:
	var injected_architecture: GFArchitecture = null

	func inject_dependencies(architecture: GFArchitecture) -> void:
		super.inject_dependencies(architecture)
		injected_architecture = architecture

class TickUtility extends GFUtility:
	var initialized: bool = false
	var ready_called: bool = false
	var async_ready_called: bool = false
	var tick_count: int = 0
	var last_delta: float = 0.0

	func init() -> void:
		initialized = true

	func async_init() -> void:
		async_ready_called = true

	func ready() -> void:
		ready_called = true

	func tick(delta: float) -> void:
		tick_count += 1
		last_delta = delta


class RegisteringUtility extends GFUtility:
	var utility_to_register: TickUtility

	func _init(target_utility: TickUtility) -> void:
		utility_to_register = target_utility

	func ready() -> void:
		Gf.register_utility(utility_to_register)


class SlowInitUtility extends GFUtility:
	signal async_continue

	var initialized: bool = false
	var async_started: bool = false
	var ready_called: bool = false

	func init() -> void:
		initialized = true

	func async_init() -> void:
		async_started = true
		await async_continue

	func ready() -> void:
		ready_called = true


class SlowTickUtility extends SlowInitUtility:
	var tick_count: int = 0

	func tick(_delta: float) -> void:
		tick_count += 1


class RecordingModel extends GFModel:
	var order: Array

	func _init(p_order: Array) -> void:
		order = p_order

	func async_init() -> void:
		order.append("model")


class RecordingUtility extends GFUtility:
	var order: Array

	func _init(p_order: Array) -> void:
		order = p_order

	func async_init() -> void:
		order.append("utility")


class RecordingSystem extends GFSystem:
	var order: Array

	func _init(p_order: Array) -> void:
		order = p_order

	func async_init() -> void:
		order.append("system")


class OwnedEventUtility extends GFUtility:
	var event_count: int = 0

	func ready() -> void:
		register_simple_event(&"owned_event", _on_owned_event)

	func _on_owned_event(_payload: Variant) -> void:
		event_count += 1


class TickVictimSystem extends GFSystem:
	var tick_order: Array

	func _init(p_tick_order: Array) -> void:
		tick_order = p_tick_order

	func tick(_delta: float) -> void:
		tick_order.append("victim")


class UnregisteringTickSystem extends GFSystem:
	var tick_order: Array

	func _init(p_tick_order: Array) -> void:
		tick_order = p_tick_order

	func tick(_delta: float) -> void:
		tick_order.append("unregistering")
		_get_architecture().unregister_system(TickVictimSystem)


class DummyQuery extends GFQuery:
	func execute() -> Variant:
		return "query_success"

class BaseArchitectureEvent extends RefCounted:
	pass

class ChildArchitectureEvent extends BaseArchitectureEvent:
	pass

class FactoryNode extends Node:
	pass

class WrongFactoryNode extends RefCounted:
	pass

class CountingFactory extends RefCounted:
	var call_count: int = 0

	func create() -> Object:
		call_count += 1
		return FactoryNode.new()

class RecoveringFactory extends RefCounted:
	var call_count: int = 0

	func create() -> Object:
		call_count += 1
		if call_count == 1:
			return WrongFactoryNode.new()
		return FactoryNode.new()

# --- Godot 生命周期方法 ---

func before_each() -> void:
	# 重置并初始化一个干净的架构
	var arch := GFArchitecture.new()
	Gf._architecture = arch

	# 注册假数据用于测试
	Gf.register_model(DummyModel.new())
	Gf.register_system(DummySystem.new())
	Gf.register_utility(DummyUtility.new())

	await Gf.set_architecture(arch)

func after_each() -> void:
	if Gf.has_architecture():
		var arch: GFArchitecture = Gf.get_architecture()
		arch.dispose()
		await Gf.set_architecture(GFArchitecture.new())

# --- 测试用例 ---

## 验证 Gf.get_model 正确代理到架构
func test_get_model_proxy() -> void:
	var model = Gf.get_model(DummyModel)
	assert_not_null(model, "通过 Gf.get_model 应该能获取到注册的模型")
	assert_true(model is DummyModel, "获取到的类型应该正确")

## 验证 Gf.get_system 正确代理到架构
func test_get_system_proxy() -> void:
	var sys = Gf.get_system(DummySystem)
	assert_not_null(sys, "通过 Gf.get_system 应该能获取到注册的系统")
	assert_true(sys is DummySystem, "获取到的类型应该正确")

## 验证 Gf.get_utility 正确代理到架构
func test_get_utility_proxy() -> void:
	var util = Gf.get_utility(DummyUtility)
	assert_not_null(util, "通过 Gf.get_utility 应该能获取到注册的工具")
	assert_true(util is DummyUtility, "获取到的类型应该正确")

## 验证 Gf.send_query 正确代理并返回结果
func test_send_query_proxy() -> void:
	var query := DummyQuery.new()
	var result = Gf.send_query(query)
	assert_eq(result, "query_success", "Gf.send_query 应当正确执行并返回结果")


## 验证文档推荐的 register_* -> init 启动流程可用
func test_register_before_init_lazily_creates_architecture() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var model := DummyModel.new()
	var utility := TickUtility.new()

	Gf.register_model(model)
	Gf.register_utility(utility)
	await Gf.init()

	assert_true(Gf.has_architecture(), "register_* 应自动创建默认架构。")
	assert_true(Gf.get_architecture().is_inited(), "Gf.init() 应初始化当前架构。")
	assert_eq(Gf.get_model(DummyModel), model, "懒创建架构后应能取回注册的 Model。")
	assert_true(utility.initialized, "Gf.init() 应调用 Utility.init()。")
	assert_true(utility.ready_called, "Gf.init() 应调用 Utility.ready()。")


## 验证 Architecture 会统一驱动带 tick() 的 Utility
func test_architecture_ticks_utility() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var utility := TickUtility.new()
	Gf.register_utility(utility)
	await Gf.init()

	Gf.get_architecture().tick(0.25)

	assert_eq(utility.tick_count, 1, "Architecture.tick() 应驱动 Utility.tick()。")
	assert_almost_eq(utility.last_delta, 0.25, 0.001, "Utility.tick() 应接收正确 delta。")


## 验证架构初始化完成后动态注册 Utility，会立即补跑生命周期并参与 tick。
func test_dynamic_register_after_init_runs_lifecycle() -> void:
	if Gf.has_architecture():

		Gf.get_architecture().dispose()
	Gf._architecture = null

	await Gf.init()
	var utility := TickUtility.new()
	await Gf.register_utility(utility)

	assert_true(utility.initialized, "初始化后的动态注册应补跑 Utility.init()。")
	assert_true(utility.ready_called, "初始化后的动态注册应补跑 Utility.ready()。")

	Gf.get_architecture().tick(0.5)
	assert_eq(utility.tick_count, 1, "动态注册后的 Utility 应参与架构 tick。")


## 验证初始化完成后动态注册的慢初始化模块，在 ready 前不会被 tick 驱动。
func test_dynamic_register_after_init_does_not_tick_before_ready() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	await Gf.init()
	var utility := SlowTickUtility.new()
	Gf.register_utility(utility)
	await get_tree().process_frame

	assert_true(utility.async_started, "动态注册应已经进入 async_init 等待。")
	Gf.get_architecture().tick(0.25)
	assert_eq(utility.tick_count, 0, "async_init 未完成前不应被 tick 驱动。")

	utility.async_continue.emit()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(utility.ready_called, "动态注册慢初始化完成后应进入 ready。")
	var tick_count_after_ready := utility.tick_count
	Gf.get_architecture().tick(0.25)
	assert_eq(utility.tick_count, tick_count_after_ready + 1, "ready 后应恢复正常 tick。")


## 验证初始化期间动态注册的 Utility 也会补跑完整生命周期。
func test_register_during_init_receives_full_lifecycle() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var late_utility := TickUtility.new()
	var registering_utility := RegisteringUtility.new(late_utility)

	Gf.register_utility(registering_utility)
	await Gf.init()

	assert_true(late_utility.initialized, "初始化过程中动态注册的 Utility 也应执行 init()。")
	assert_true(late_utility.async_ready_called, "初始化过程中动态注册的 Utility 也应执行 async_init()。")
	assert_true(late_utility.ready_called, "初始化过程中动态注册的 Utility 也应执行 ready()。")

	Gf.get_architecture().tick(0.25)
	assert_eq(late_utility.tick_count, 1, "初始化过程中动态注册的 Utility 完成后应参与后续 tick。")


## 验证三阶段生命周期在每个阶段按 Model -> Utility -> System 推进。
func test_lifecycle_stage_order_prefers_utilities_before_systems() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var order: Array = []
	var arch := GFArchitecture.new()
	await arch.register_model_instance(RecordingModel.new(order))
	await arch.register_system_instance(RecordingSystem.new(order))
	await arch.register_utility_instance(RecordingUtility.new(order))

	await Gf.set_architecture(arch)

	assert_eq(order, ["model", "utility", "system"], "async_init 阶段应先完成 Model，再完成 Utility，最后进入 System。")


## 验证可通过显式 alias 以抽象基类获取具体实现。
func test_register_utility_alias_resolves_base_type() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var concrete := ConcreteUtility.new()
	var alternate := AlternateConcreteUtility.new()

	Gf.register_utility(concrete)
	Gf.register_utility(alternate)
	Gf.register_utility_alias(UtilityBase, ConcreteUtility)
	await Gf.init()

	assert_eq(Gf.get_utility(UtilityBase), concrete, "显式 alias 应让基类查询解析到指定实现。")


## 验证重复注册会给出明确 warning，且 replace_utility 会释放旧实例并接管新实例。
func test_duplicate_register_warns_and_replace_utility() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var old_utility := DisposableUtility.new()
	var duplicate_utility := DisposableUtility.new()

	await Gf.register_utility(old_utility)
	await Gf.register_utility(duplicate_utility)

	assert_push_warning("[GFArchitecture] register_utility：类型已注册，已忽略重复注册。若需要替换，请使用 replace_utility()。")
	assert_eq(Gf.get_utility(DisposableUtility), old_utility, "重复注册不应替换原实例。")

	await Gf.replace_utility(duplicate_utility)

	assert_true(old_utility.disposed, "replace_utility 应释放旧实例。")
	assert_eq(Gf.get_utility(DisposableUtility), duplicate_utility, "replace_utility 应注册新实例。")


## 验证模块可通过 inject_dependencies 接收当前架构引用。
func test_register_injects_architecture_when_hook_exists() -> void:
	var arch := GFArchitecture.new()
	var utility := InjectedUtility.new()

	await arch.register_utility_instance(utility)

	assert_eq(utility.injected_architecture, arch, "注册时应把当前架构注入到模块。")
	arch.dispose()


## 验证子架构未命中本地依赖时会回退到父架构。
func test_child_architecture_falls_back_to_parent() -> void:
	var parent_arch := GFArchitecture.new()
	var parent_utility := ParentScopedUtility.new()
	await parent_arch.register_utility_instance(parent_utility)

	var child_arch := GFArchitecture.new(parent_arch)

	assert_eq(child_arch.get_utility(ParentScopedUtility), parent_utility, "子架构应能回退获取父级 Utility。")

	child_arch.dispose()
	parent_arch.dispose()


## 验证子架构中的失效 alias 不会遮蔽父架构回退。
func test_stale_child_alias_does_not_shadow_parent_fallback() -> void:
	var parent_arch := GFArchitecture.new()
	var parent_utility := ConcreteUtility.new()
	await parent_arch.register_utility_instance(parent_utility)

	var child_arch := GFArchitecture.new(parent_arch)
	child_arch.register_utility_alias(UtilityBase, ConcreteUtility)

	assert_push_warning("[GFArchitecture] register_utility_alias：目标类型尚未注册，仍会记录别名。")
	assert_eq(child_arch.get_utility(UtilityBase), parent_utility, "子架构失效 alias 不应阻断父架构基类回退。")

	child_arch.dispose()
	parent_arch.dispose()


## 验证注册时会拒绝与目标槽位不匹配的实例。
func test_register_utility_rejects_wrong_base_type() -> void:
	var arch := GFArchitecture.new()

	await arch.register_utility_instance(NotUtility.new())

	assert_push_error("[GFArchitecture] register_utility 失败：实例类型必须继承 GFUtility。")
	assert_null(arch.get_utility(NotUtility), "非 GFUtility 实例不应进入 Utility 注册表。")
	arch.dispose()


## 验证声明式 Binder 可以注册模块、别名与短生命周期工厂。
func test_binder_registers_modules_alias_and_factory_lifetimes() -> void:
	var arch := GFArchitecture.new()
	var binder: Variant = arch.create_binder()
	var utility := ConcreteUtility.new()

	await binder.bind_utility(ConcreteUtility).from_instance(utility).with_alias(UtilityBase).as_singleton()
	binder.bind_factory(InjectedFactoryCommand).from_factory(func() -> Object:
		return InjectedFactoryCommand.new()
	).as_transient()
	binder.bind_factory(FactoryCommand).from_factory(func() -> Object:
		return FactoryCommand.new()
	).as_singleton()

	var transient_a := arch.create_instance(InjectedFactoryCommand) as InjectedFactoryCommand
	var transient_b := arch.create_instance(InjectedFactoryCommand) as InjectedFactoryCommand
	var singleton_a := arch.create_instance(FactoryCommand) as FactoryCommand
	var singleton_b := arch.create_instance(FactoryCommand) as FactoryCommand

	assert_eq(arch.get_utility(UtilityBase), utility, "Binder 应支持模块 alias 注册。")
	assert_ne(transient_a, transient_b, "Transient 工厂每次应返回新实例。")
	assert_eq(transient_a.injected_architecture, arch, "Transient 工厂结果应注入当前架构。")
	assert_eq(singleton_a, singleton_b, "Singleton 工厂应缓存同一实例。")

	arch.dispose()


## 验证项目 Installer 会在 Gf.init() 初始化前自动注册模块。
func test_project_installer_registers_modules_before_init() -> void:
	var previous_installers: Variant = ProjectSettings.get_setting(INSTALLERS_SETTING, [])
	ProjectSettings.set_setting(INSTALLERS_SETTING, [TEST_INSTALLER_PATH])

	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	await Gf.init()

	var installed_model = Gf.get_model(InstallerModelFixture)

	ProjectSettings.set_setting(INSTALLERS_SETTING, previous_installers)

	assert_not_null(installed_model, "项目 Installer 应在初始化前注册 Model。")
	assert_true(installed_model.installed, "Installer 注册的 Model 应保留自身状态。")


## 验证项目 Installer 的异步 install_bindings 会在架构 init 前完成。
func test_project_installer_awaits_async_install_bindings_before_init() -> void:
	var previous_installers: Variant = ProjectSettings.get_setting(INSTALLERS_SETTING, [])
	ProjectSettings.set_setting(INSTALLERS_SETTING, [ASYNC_BINDING_INSTALLER_PATH])

	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	await Gf.init()

	var installed_utility := Gf.get_utility(AsyncInstallerUtilityFixture) as AsyncInstallerUtilityFixture

	ProjectSettings.set_setting(INSTALLERS_SETTING, previous_installers)

	assert_not_null(installed_utility, "异步 install_bindings 注册的 Utility 应在 init 后可获取。")
	assert_true(installed_utility.ready_called, "异步 install_bindings 注册的 Utility 应参与本轮生命周期。")


## 验证并发 Gf.init() 会等待正在运行的项目 Installer，而不是跳过未完成的装配。
func test_concurrent_gf_init_waits_for_active_project_installers() -> void:
	var previous_installers: Variant = ProjectSettings.get_setting(INSTALLERS_SETTING, [])
	var previous_started: Variant = ProjectSettings.get_setting(BLOCKING_INSTALLER_STARTED_SETTING, false)
	var previous_release: Variant = ProjectSettings.get_setting(BLOCKING_INSTALLER_RELEASE_SETTING, false)
	ProjectSettings.set_setting(INSTALLERS_SETTING, [BLOCKING_BINDING_INSTALLER_PATH])
	ProjectSettings.set_setting(BLOCKING_INSTALLER_STARTED_SETTING, false)
	ProjectSettings.set_setting(BLOCKING_INSTALLER_RELEASE_SETTING, false)

	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var first_state := { "done": false }
	var second_state := { "done": false }
	_await_gf_init(first_state)
	await get_tree().process_frame
	await get_tree().process_frame
	_await_gf_init(second_state)
	await get_tree().process_frame

	assert_true(ProjectSettings.get_setting(BLOCKING_INSTALLER_STARTED_SETTING, false), "第一轮 init 应已进入阻塞 Installer。")
	assert_false(second_state["done"], "第二个 Gf.init() 不应在 Installer 完成前提前返回。")

	ProjectSettings.set_setting(BLOCKING_INSTALLER_RELEASE_SETTING, true)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame

	var installed_utility := Gf.get_utility(AsyncInstallerUtilityFixture) as AsyncInstallerUtilityFixture

	ProjectSettings.set_setting(INSTALLERS_SETTING, previous_installers)
	ProjectSettings.set_setting(BLOCKING_INSTALLER_STARTED_SETTING, previous_started)
	ProjectSettings.set_setting(BLOCKING_INSTALLER_RELEASE_SETTING, previous_release)

	assert_true(first_state["done"], "第一轮 Gf.init() 应正常完成。")
	assert_true(second_state["done"], "第二个 Gf.init() 应等待同一轮 Installer 和初始化完成。")
	assert_not_null(installed_utility, "阻塞 Installer 完成后注册的 Utility 应可获取。")
	assert_true(installed_utility.ready_called, "阻塞 Installer 注册的 Utility 应参与本轮生命周期。")


## 验证 Scoped NodeContext 会创建局部架构、回退父架构并在退出树时释放局部模块。
func test_scoped_node_context_owns_local_architecture() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var parent_arch := GFArchitecture.new()
	var parent_utility := ParentScopedUtility.new()
	await parent_arch.register_utility_instance(parent_utility)
	await Gf.set_architecture(parent_arch)

	var context := ScopedContext.new()
	var ready_state := { "done": false }
	context.context_ready.connect(func(_architecture: GFArchitecture) -> void: ready_state.done = true)
	add_child(context)
	await get_tree().process_frame

	var local_utility := context.get_utility(LocalScopedUtility) as LocalScopedUtility
	var inherited_utility := context.get_utility(ParentScopedUtility) as ParentScopedUtility
	var lookup_system := context.get_system(LocalLookupSystem) as LocalLookupSystem
	var controller := ScopedController.new()
	context.add_child(controller)
	await get_tree().process_frame

	assert_true(ready_state.done, "Scoped NodeContext 应自动初始化局部架构。")
	assert_not_null(local_utility, "Scoped NodeContext 应注册局部 Utility。")
	assert_eq(inherited_utility, parent_utility, "局部架构应回退获取父架构依赖。")
	assert_eq(lookup_system.local_utility, local_utility, "Scoped System 的基类 get_utility 应优先访问局部架构。")
	assert_eq(lookup_system.parent_utility, parent_utility, "Scoped System 的基类 get_utility 应能回退父架构。")
	assert_eq(controller.get_local_utility(), local_utility, "Scoped Controller 应沿场景树找到局部架构。")
	assert_eq(controller.get_parent_utility(), parent_utility, "Scoped Controller 应通过局部架构回退父架构。")

	context.queue_free()
	await get_tree().process_frame

	assert_true(local_utility.disposed, "Scoped NodeContext 退出树时应释放局部模块。")
	assert_false(parent_utility.disposed, "Scoped NodeContext 不应释放父架构模块。")


## 验证 Controller 可以等待最近的局部上下文完成初始化。
func test_controller_waits_for_context_ready() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var parent_arch := GFArchitecture.new()
	await Gf.set_architecture(parent_arch)

	var context := ScopedContext.new()
	var controller := ScopedController.new()
	add_child(context)
	context.add_child(controller)
	var architecture := await controller.wait_for_context_ready()

	assert_eq(architecture, context.get_architecture(), "Controller 应等待并返回最近上下文的架构。")
	assert_not_null(controller.get_local_utility(), "等待完成后 Controller 应能获取局部依赖。")

	context.queue_free()
	await get_tree().process_frame


## 验证 Controller 默认把父节点解析为宿主节点。
func test_controller_resolves_parent_host_by_default() -> void:
	var host := DerivedControllerHost.new()
	var controller := ScopedController.new()

	add_child(host)
	host.add_child(controller)
	await get_tree().process_frame

	assert_eq(controller.get_host(), host, "Controller 默认应把父节点作为宿主。")
	assert_eq(controller.host, host, "Controller.host 应代理 get_host()。")
	assert_true(controller.has_host(), "父节点存在时 has_host() 应返回 true。")
	assert_eq(controller.get_host_as(ControllerHost), host, "get_host_as() 应支持脚本基类匹配。")
	assert_eq(controller.get_host_as(Node), host, "get_host_as() 应支持 Godot 原生类型匹配。")
	assert_null(controller.get_host_as(OtherControllerHost), "类型不匹配时 get_host_as() 应返回 null。")

	host.queue_free()
	await get_tree().process_frame


## 验证 Controller 可通过 host_node_path 指定非父节点宿主。
func test_controller_resolves_configured_host_path() -> void:
	var scene_root := Node.new()
	var host := ControllerHost.new()
	var branch := Node.new()
	var controller := ScopedController.new()
	host.name = "RuntimeHost"
	branch.name = "ControllerBranch"
	controller.host_node_path = NodePath("../../RuntimeHost")

	add_child(scene_root)
	scene_root.add_child(host)
	scene_root.add_child(branch)
	branch.add_child(controller)
	await get_tree().process_frame

	assert_eq(controller.get_host(), host, "Controller 应按 host_node_path 解析宿主。")

	scene_root.queue_free()
	await get_tree().process_frame


## 验证 Controller 宿主路径缺失时安全返回 null。
func test_controller_missing_host_returns_null() -> void:
	var controller := ScopedController.new()
	controller.host_node_path = NodePath("MissingHost")
	add_child(controller)
	await get_tree().process_frame

	assert_null(controller.get_host(), "宿主路径不存在时 get_host() 应返回 null。")
	assert_false(controller.has_host(), "宿主路径不存在时 has_host() 应返回 false。")
	assert_null(controller.get_host_as(Node), "宿主不存在时 get_host_as() 应返回 null。")

	controller.queue_free()
	await get_tree().process_frame


func test_controller_proxy_methods_without_architecture_return_null_silently() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null
	var controller := ScopedController.new()
	add_child(controller)

	assert_null(controller.get_model(DummyModel), "无可用架构时 Controller.get_model 应返回 null。")
	assert_null(controller.get_system(DummySystem), "无可用架构时 Controller.get_system 应返回 null。")
	assert_null(controller.get_utility(DummyUtility), "无可用架构时 Controller.get_utility 应返回 null。")
	assert_null(controller.send_command(GFCommand.new()), "无可用架构时 Controller.send_command 应返回 null。")
	assert_null(controller.send_query(GFQuery.new()), "无可用架构时 Controller.send_query 应返回 null。")
	controller.send_event(GFPayload.new())
	controller.send_simple_event(&"missing_architecture", 1)

	assert_push_error_count(0, "Controller 便捷代理在缺少架构时不应触发全局架构错误。")
	controller.queue_free()
	await get_tree().process_frame


## 验证 Inherited NodeContext 也能等待父架构完成异步初始化。
func test_inherited_context_waits_for_parent_architecture_init() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var parent_arch := GFArchitecture.new()
	var slow_utility := SlowInitUtility.new()
	await parent_arch.register_utility_instance(slow_utility)
	Gf._architecture = parent_arch

	var context := InheritedContext.new()
	add_child(context)
	await get_tree().process_frame

	parent_arch.init()
	await get_tree().process_frame
	assert_true(slow_utility.async_started, "父架构应已进入 async_init 等待。")

	slow_utility.call_deferred("emit_signal", "async_continue")
	var architecture := await context.wait_until_ready()

	assert_eq(architecture, parent_arch, "Inherited NodeContext 应返回继承到的父架构。")
	assert_true(slow_utility.ready_called, "wait_until_ready 应等待父架构 ready 后再返回。")

	context.queue_free()
	await get_tree().process_frame


## 验证等待上下文 ready 时可通过超时失败退出。
func test_context_wait_until_ready_times_out_when_parent_never_initializes() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = GFArchitecture.new()

	var context := InheritedContext.new()
	context.context_wait_timeout_seconds = 0.01
	add_child(context)
	watch_signals(context)

	var architecture := await context.wait_until_ready()

	assert_null(architecture, "父架构一直未初始化时，wait_until_ready 应在超时后返回 null。")
	assert_signal_emitted(context, "context_failed", "等待超时应发出 context_failed。")
	assert_push_warning("[GFNodeContext] 等待上下文初始化超时。")

	context.queue_free()
	await get_tree().process_frame


## 验证子 Scoped NodeContext 初始化前会等待父 Scoped 架构 ready。
func test_child_scoped_context_waits_for_parent_scoped_context_ready() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var parent_context := ParentSlowScopedContext.new()
	var child_context := ChildScopedContext.new()
	parent_context.add_child(child_context)
	add_child(parent_context)
	await get_tree().process_frame

	assert_true(parent_context.slow_utility.async_started, "父 Scoped 架构应已进入 async_init 等待。")
	assert_false(child_context.is_context_ready(), "父架构 ready 前，子 Scoped 上下文不应提前 ready。")

	parent_context.slow_utility.async_continue.emit()
	await child_context.wait_until_ready()

	assert_true(child_context.lookup_system.parent_ready_at_ready, "子 Scoped 模块 ready 时父架构应已经 ready。")

	parent_context.queue_free()
	await get_tree().process_frame


## 验证工厂创建的短生命周期对象会自动注入当前架构。
func test_factory_create_instance_injects_architecture() -> void:
	var parent_arch := GFArchitecture.new()
	var parent_utility := ParentScopedUtility.new()
	await parent_arch.register_utility_instance(parent_utility)

	var child_arch := GFArchitecture.new(parent_arch)
	child_arch.register_factory(FactoryCommand, func() -> Object:
		return FactoryCommand.new()
	)

	var command := child_arch.create_instance(FactoryCommand) as FactoryCommand

	assert_not_null(command, "create_instance 应返回工厂创建的命令。")
	assert_eq(command.get_parent_utility_from_command(), parent_utility, "工厂创建的命令应使用创建它的架构解析依赖。")

	child_arch.dispose()
	parent_arch.dispose()


## 验证父级 transient 工厂被子架构解析时，会注入请求方架构。
func test_parent_transient_factory_injects_requesting_child_architecture() -> void:
	var parent_arch := GFArchitecture.new()
	var child_arch := GFArchitecture.new(parent_arch)
	parent_arch.register_factory(InjectedFactoryCommand, func() -> Object:
		return InjectedFactoryCommand.new()
	)

	var command := child_arch.create_instance(InjectedFactoryCommand) as InjectedFactoryCommand

	assert_not_null(command, "子架构应能通过父级工厂创建对象。")
	assert_eq(command.injected_architecture, child_arch, "父级 transient 工厂结果应注入发起解析的子架构。")

	child_arch.dispose()
	parent_arch.dispose()


## 验证 has_factory 会查询当前架构与父级架构，且不会创建实例或输出错误。
func test_has_factory_checks_parent_without_instantiating() -> void:
	var parent_arch := GFArchitecture.new()
	var child_arch := GFArchitecture.new(parent_arch)
	var factory_call_count := [0]
	parent_arch.register_factory(InjectedFactoryCommand, func() -> Object:
		factory_call_count[0] += 1
		return InjectedFactoryCommand.new()
	)

	assert_true(child_arch.has_factory(InjectedFactoryCommand), "子架构应能发现父级工厂。")
	assert_false(child_arch.has_factory(FactoryCommand), "未注册工厂应返回 false。")
	assert_eq(factory_call_count[0], 0, "has_factory 不应触发工厂实例化。")

	child_arch.dispose()
	parent_arch.dispose()


## 验证 Singleton 工厂缓存的节点失效后会重新创建实例。
func test_singleton_factory_recreates_freed_cached_instance() -> void:
	var arch := GFArchitecture.new()
	var factory := CountingFactory.new()
	arch.register_factory(FactoryNode, Callable(factory, "create"), GFBindingLifetimes.Lifetime.SINGLETON)

	var first := arch.create_instance(FactoryNode) as FactoryNode
	first.free()
	var second := arch.create_instance(FactoryNode) as FactoryNode

	assert_eq(factory.call_count, 2, "缓存实例失效后 Singleton 工厂应重新调用 provider。")
	assert_true(is_instance_valid(second), "重新创建的 Singleton 实例应有效。")

	second.free()
	arch.dispose()


## 验证 Singleton 工厂失败返回不会被缓存，后续有效返回仍可恢复。
func test_singleton_factory_does_not_cache_wrong_type_failure() -> void:
	var arch := GFArchitecture.new()
	var factory := RecoveringFactory.new()
	arch.register_factory(FactoryNode, Callable(factory, "create"), GFBindingLifetimes.Lifetime.SINGLETON)

	var first := arch.create_instance(FactoryNode)
	var second := arch.create_instance(FactoryNode) as FactoryNode

	assert_null(first, "工厂返回错误类型时应解析失败。")
	assert_push_error("[GFBinding] 绑定来源返回的实例脚本必须继承或等于绑定键。")
	assert_eq(factory.call_count, 2, "失败结果不应写入 Singleton 缓存，下一次应重新调用 provider。")
	assert_not_null(second, "后续 provider 返回正确类型后应能成功解析。")

	second.free()
	arch.dispose()


## 验证父级 Singleton 工厂被子架构解析时，实例归属和注入仍属于父架构。
func test_parent_singleton_factory_keeps_owner_architecture_injection() -> void:
	var parent_arch := GFArchitecture.new()
	var child_arch := GFArchitecture.new(parent_arch)
	parent_arch.register_factory(
		InjectedFactoryCommand,
		func() -> Object:
			return InjectedFactoryCommand.new(),
		GFBindingLifetimes.Lifetime.SINGLETON
	)

	var first := child_arch.create_instance(InjectedFactoryCommand) as InjectedFactoryCommand
	var second := child_arch.create_instance(InjectedFactoryCommand) as InjectedFactoryCommand

	assert_not_null(first, "子架构应能解析父级 Singleton 工厂。")
	assert_eq(first, second, "父级 Singleton 工厂应缓存同一实例。")
	assert_eq(first.injected_architecture, parent_arch, "父级 Singleton 工厂结果应注入拥有该绑定的父架构。")

	child_arch.dispose()
	parent_arch.dispose()


## 验证模块注销会自动清理通过基类注册的事件监听。
func test_unregister_utility_removes_owned_event_listeners() -> void:
	var arch := GFArchitecture.new()
	var utility := OwnedEventUtility.new()
	await arch.register_utility_instance(utility)
	await arch.init()

	arch.send_simple_event(&"owned_event")
	arch.unregister_utility(OwnedEventUtility)
	arch.send_simple_event(&"owned_event")

	assert_eq(utility.event_count, 1, "Utility 注销后不应继续收到 owner-bound 事件。")
	arch.dispose()


## 验证架构可赋值事件监听会接收子类事件。
func test_architecture_assignable_event_listener_receives_child_event() -> void:
	var arch := GFArchitecture.new()
	var state := {"count": 0}
	arch.register_assignable_event(BaseArchitectureEvent, func(_event: BaseArchitectureEvent) -> void:
		state.count += 1
	)

	arch.send_event(ChildArchitectureEvent.new())

	assert_eq(state.count, 1, "架构可赋值事件监听应接收子类事件。")
	arch.dispose()


## 验证架构诊断快照会报告模块生命周期与工厂绑定状态。
func test_architecture_debug_lifecycle_state_reports_modules_and_factories() -> void:
	var arch := GFArchitecture.new()
	var utility := TickUtility.new()
	await arch.register_utility_instance(utility)
	arch.register_factory(
		FactoryCommand,
		func() -> Object:
			return FactoryCommand.new(),
		GFBindingLifetimes.Lifetime.SINGLETON
	)

	var before_init := arch.get_debug_lifecycle_state()
	var before_utilities := before_init.get("utilities", {}) as Dictionary
	var before_utility_entry := before_utilities.values()[0] as Dictionary

	assert_false(bool(before_init.get("inited", true)), "初始化前诊断快照应报告未初始化。")
	assert_eq(int(before_utility_entry.get("stage")), 0, "初始化前模块应停留在 registered 阶段。")

	await arch.init()
	var after_init := arch.get_debug_lifecycle_state()
	var after_utilities := after_init.get("utilities", {}) as Dictionary
	var after_factories := after_init.get("factories", {}) as Dictionary
	var after_utility_entry := after_utilities.values()[0] as Dictionary
	var factory_entry := after_factories.values()[0] as Dictionary

	assert_true(bool(after_init.get("inited", false)), "初始化后诊断快照应报告已初始化。")
	assert_eq(int(after_utility_entry.get("stage")), 3, "初始化后模块应进入 ready 阶段。")
	assert_true(bool(after_utility_entry.get("has_tick", false)), "诊断快照应报告 tick 能力。")
	assert_eq(int(factory_entry.get("lifetime")), GFBindingLifetimes.Lifetime.SINGLETON, "诊断快照应报告工厂生命周期。")

	arch.dispose()


## 验证同一帧 tick 中被提前注销的模块不会继续从旧缓存中被驱动。
func test_tick_skips_module_unregistered_earlier_in_same_frame() -> void:
	var arch := GFArchitecture.new()
	var tick_order: Array = []
	await arch.register_system_instance(UnregisteringTickSystem.new(tick_order))
	await arch.register_system_instance(TickVictimSystem.new(tick_order))
	await arch.init()

	arch.tick(0.016)

	assert_eq(tick_order, ["unregistering"], "同一帧内已被注销的 System 不应继续 tick。")
	arch.dispose()


## 验证并发 init 调用会等待同一轮初始化完成。
func test_concurrent_init_waits_for_active_initialization() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var arch := GFArchitecture.new()
	var slow_utility := SlowInitUtility.new()
	await arch.register_utility_instance(slow_utility)

	var first_state := { "done": false }
	var second_state := { "done": false }
	_await_arch_init(arch, first_state)
	await get_tree().process_frame
	_await_arch_init(arch, second_state)
	await get_tree().process_frame

	assert_true(slow_utility.async_started, "第一轮初始化应已进入 async_init。")
	assert_false(second_state["done"], "第二个 init 调用不应在初始化完成前提前返回。")

	slow_utility.async_continue.emit()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(first_state["done"], "第一轮 init 应正常完成。")
	assert_true(second_state["done"], "第二个 init 调用应在同一轮初始化完成后返回。")
	assert_true(arch.is_inited(), "架构应处于已初始化状态。")
	assert_true(slow_utility.ready_called, "慢初始化 Utility 最终应进入 ready 阶段。")


## 验证 dispose 会唤醒等待中的并发 init 调用，且旧初始化恢复后不会写回状态。
func test_dispose_during_init_cancels_waiters_and_stale_resume() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var arch := GFArchitecture.new()
	var slow_utility := SlowInitUtility.new()
	await arch.register_utility_instance(slow_utility)

	var first_state := { "done": false }
	var second_state := { "done": false }
	_await_arch_init(arch, first_state)
	await get_tree().process_frame
	_await_arch_init(arch, second_state)
	await get_tree().process_frame

	arch.dispose()
	await get_tree().process_frame

	assert_true(second_state["done"], "dispose 应唤醒正在等待初始化完成的并发调用。")
	assert_false(arch.is_inited(), "dispose 后架构不应被标记为已初始化。")

	slow_utility.async_continue.emit()
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(first_state["done"], "旧初始化 await 恢复后应安全退出。")
	assert_false(arch.is_inited(), "旧初始化恢复后不应重新写回已初始化状态。")
	assert_false(slow_utility.ready_called, "被 dispose 中断的模块不应继续进入 ready。")


## 验证无架构时 Gf 门面方法只报错并返回空值，不发生空引用崩溃。
func test_facade_returns_null_when_architecture_missing() -> void:
	if Gf.has_architecture():
		Gf.get_architecture().dispose()
	Gf._architecture = null

	var model = Gf.get_model(DummyModel)

	assert_push_error("[GDCore] get_model 失败：架构尚未初始化，请先注册架构。")
	assert_null(model, "架构缺失时 get_model 应安全返回 null。")


## 验证核心架构对空输入进行防御，不发生空引用崩溃。
func test_architecture_null_inputs_are_rejected() -> void:
	var arch := GFArchitecture.new()

	var command_result: Variant = arch.send_command(null)
	var query_result: Variant = arch.send_query(null)
	arch.send_event(null)
	await arch.register_utility_instance_as(null, UtilityBase)

	assert_null(command_result, "空 command 应返回 null。")
	assert_null(query_result, "空 query 应返回 null。")
	assert_push_error("[GFArchitecture] send_command 失败：command 为空。")
	assert_push_error("[GFArchitecture] send_query 失败：query 为空。")
	assert_push_error("[GFArchitecture] send_event 失败：event_instance 为空。")
	assert_push_error("[GFArchitecture] register_utility_instance_as 失败：实例为空。")
	arch.dispose()


func _await_arch_init(arch: GFArchitecture, state: Dictionary) -> void:
	await arch.init()
	state["done"] = true


func _await_gf_init(state: Dictionary) -> void:
	await Gf.init()
	state["done"] = true
