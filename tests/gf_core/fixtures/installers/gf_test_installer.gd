## Gf 项目级 Installer 回归测试夹具。
extends "res://addons/gf/core/gf_installer.gd"


const InstallerModelFixture = preload("res://tests/gf_core/fixtures/installers/installer_model_fixture.gd")


func install(architecture: GFArchitecture) -> void:
	architecture.register_model_instance(InstallerModelFixture.new())
