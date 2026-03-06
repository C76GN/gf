# tests/gf_core/test_gf_scene_utility.gd
extends GutTest


var _scene_util: GFSceneUtility


class DummyModel extends GFModel:
	var disposed := false
	func dispose() -> void:
		disposed = true


func before_each() -> void:
	var arch := GFArchitecture.new()
	Gf._architecture = arch
	
	_scene_util = GFSceneUtility.new()
	Gf.register_utility(_scene_util)
	
	await Gf.set_architecture(arch)


func after_each() -> void:
	var arch := Gf.get_architecture()
	if arch != null:
		arch.dispose()
		await Gf.set_architecture(GFArchitecture.new())


func test_transient_cleanup() -> void:
	var model := DummyModel.new()
	Gf.register_model(model)
	
	_scene_util.mark_transient(DummyModel)
	
	# Manually trigger cleanup
	_scene_util.cleanup_transients()
	
	var arch := Gf.get_architecture()
	assert_null(arch.get_model(DummyModel), "标记为瞬态的 Model 应被注销。")
	assert_true(model.disposed, "注销时应调用其 dispose() 方法。")


func test_unmark_transient() -> void:
	var model := DummyModel.new()
	Gf.register_model(model)
	
	_scene_util.mark_transient(DummyModel)
	_scene_util.unmark_transient(DummyModel)
	
	_scene_util.cleanup_transients()
	
	var arch := Gf.get_architecture()
	assert_not_null(arch.get_model(DummyModel), "取消标记的 Model 不应被注销。")
	assert_false(model.disposed, "取消标记的模型不应调用 dispose()。")
