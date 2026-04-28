## 阻塞式声明绑定 Installer，用于验证并发 Gf.init() 会等待同一轮 Installer 完成。
extends "res://addons/gf/core/gf_installer.gd"


# --- 常量 ---

const AsyncInstallerUtilityFixture = preload("res://tests/gf_core/fixtures/installers/async_installer_utility_fixture.gd")
const STARTED_SETTING: String = "gf/test/blocking_installer_started"
const RELEASE_SETTING: String = "gf/test/release_blocking_installer"


# --- 公共方法 ---

func install_bindings(binder: Variant) -> void:
	ProjectSettings.set_setting(STARTED_SETTING, true)
	while not bool(ProjectSettings.get_setting(RELEASE_SETTING, false)):
		await Engine.get_main_loop().process_frame

	await binder.bind_utility(AsyncInstallerUtilityFixture).as_singleton()
