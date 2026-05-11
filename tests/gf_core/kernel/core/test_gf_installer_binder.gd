## 测试 GFInstaller 生命周期钩子与 GFBinder 返回的绑定构建器。
extends GutTest


class TestProjectInstaller extends GFInstaller:
	func install_bindings(_binder: Variant) -> void:
		await _binder.bind_utility(GFSeedUtility).as_singleton()


func test_installer_bindings_register_utility_through_binder() -> void:
	var inst := TestProjectInstaller.new()
	var arch := GFArchitecture.new()

	await inst.install_bindings(arch.create_binder())

	assert_true(arch.get_utility(GFSeedUtility) is GFSeedUtility, "Installer 应能通过 Binder 注册 Utility。")


func test_binder_bind_utility_returns_bind_builder() -> void:
	var arch := GFArchitecture.new()
	var binder := GFBinder.new(arch)
	var builder: Variant = binder.bind_utility(preload("res://addons/gf/standard/utilities/random/gf_seed_utility.gd"))
	assert_true(builder is GFBindBuilder, "bind_utility 应返回 GFBindBuilder。")
