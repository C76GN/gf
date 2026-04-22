## 测试 Gf 全局单例的便捷代理方法 (Facade 模式)
extends GutTest

# --- 辅助类 ---

class DummyModel extends GFModel:
	pass

class DummySystem extends GFSystem:
	pass

class DummyUtility extends GFUtility:
	pass

class UtilityBase extends GFUtility:
	pass

class ConcreteUtility extends UtilityBase:
	pass

class AlternateConcreteUtility extends UtilityBase:
	pass

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

class DummyQuery extends GFQuery:
	func execute() -> Variant:
		return "query_success"

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
		var arch := Gf.get_architecture()
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
