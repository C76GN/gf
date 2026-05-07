## 测试 GFDiagnosticsUtility 的快照与命令调度。
extends GutTest


## 验证诊断命令注册后可统一执行。
func test_diagnostics_command_executes() -> void:
	var diagnostics := GFDiagnosticsUtility.new()
	diagnostics.init()

	var result := diagnostics.execute_command(&"diagnostics.performance")

	assert_true(bool(result["ok"]), "内置性能诊断命令应执行成功。")
	assert_true((result["value"] as Dictionary).has("fps"), "性能快照应包含 fps。")


## 验证诊断命令等级默认只允许观察类命令。
func test_diagnostics_command_tier_denies_control_by_default() -> void:
	var diagnostics := GFDiagnosticsUtility.new()
	diagnostics.register_command(
		&"runtime.pause",
		func(_args: Dictionary) -> Dictionary:
			return { "paused": true },
		"暂停运行时。",
		GFDiagnosticsUtility.CommandTier.CONTROL
	)

	var result := diagnostics.execute_command(&"runtime.pause")

	assert_false(bool(result["ok"]), "默认等级不应允许 CONTROL 命令。")
	assert_eq((result["metadata"] as Dictionary).get("tier_name"), "control", "失败结果应包含命令等级。")


## 验证诊断命令可要求 token 认证。
func test_diagnostics_command_requires_auth_token() -> void:
	var diagnostics := GFDiagnosticsUtility.new()
	diagnostics.set_auth_token("secret")
	diagnostics.register_command(&"diagnostics.test", func(_args: Dictionary) -> String:
		return "ok"
	)

	var rejected := diagnostics.execute_command(&"diagnostics.test")
	var accepted := diagnostics.execute_command(&"diagnostics.test", { "auth_token": "secret" })

	assert_false(bool(rejected["ok"]), "缺少 token 时命令应被拒绝。")
	assert_true(bool(accepted["ok"]), "提供正确 token 时命令应执行。")


## 验证诊断快照可读取架构生命周期状态。
func test_diagnostics_collects_architecture_snapshot() -> void:
	var arch := GFArchitecture.new()
	var diagnostics := GFDiagnosticsUtility.new()
	await arch.register_utility_instance(diagnostics)
	await arch.init()

	var snapshot := diagnostics.collect_snapshot({
		"include_recent_logs": false,
	})
	var architecture := snapshot["architecture"] as Dictionary

	assert_true(architecture.has("utilities"), "架构快照应包含 Utility 状态。")

	arch.dispose()


## 验证诊断监控注册表可采样、预设和导出。
func test_diagnostics_monitor_registry_collects_custom_monitor() -> void:
	var diagnostics := GFDiagnosticsUtility.new()
	diagnostics.init()
	var provider := func() -> int:
		return 7

	assert_true(diagnostics.register_monitor(&"test.value", provider, {
		"label": "Value",
		"group": "Tests",
	}), "有效监控项应注册成功。")
	assert_true(diagnostics.register_monitor_preset(&"test", PackedStringArray(["test.value"])), "监控预设应注册成功。")

	var snapshot := diagnostics.collect_monitor_snapshot(PackedStringArray(["test.value"]))
	var monitors := snapshot["monitors"] as Dictionary
	var sample := monitors[&"test.value"] as Dictionary
	var preset_snapshot := diagnostics.collect_monitor_preset(&"test")
	var exported_text := diagnostics.export_monitor_snapshot(preset_snapshot, &"text")

	assert_eq(sample["value"], 7, "监控快照应包含 provider 返回值。")
	assert_eq(preset_snapshot["preset_id"], &"test", "预设快照应记录预设 id。")
	assert_true("Value" in exported_text, "文本导出应包含监控标签。")
