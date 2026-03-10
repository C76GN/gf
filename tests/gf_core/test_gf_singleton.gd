# tests/gf_core/test_gf_singleton.gd

## 测试 Gf 全局单例的便捷代理方法 (Facade 模式)
extends GutTest

# --- 辅助类 ---

class DummyModel extends GFModel:
	pass

class DummySystem extends GFSystem:
	pass

class DummyUtility extends GFUtility:
	pass

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
	var arch := Gf.get_architecture()
	if arch != null:
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
