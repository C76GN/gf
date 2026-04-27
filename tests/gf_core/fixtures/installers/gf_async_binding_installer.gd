## Gf 异步声明式绑定 Installer 回归测试夹具。
extends "res://addons/gf/core/gf_installer.gd"


# --- 常量 ---

const AsyncInstallerUtilityFixture = preload("res://tests/gf_core/fixtures/installers/async_installer_utility_fixture.gd")


# --- 公共方法 ---

func install_bindings(binder: Variant) -> void:
	await Engine.get_main_loop().process_frame
	await binder.bind_utility(AsyncInstallerUtilityFixture).as_singleton()
