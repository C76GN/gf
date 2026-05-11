## 测试 GFArchitecture 的声明式依赖诊断报告。
extends GutTest


class DiagnosticModel extends GFModel:
	pass


class DiagnosticUtility extends GFUtility:
	pass


class DiagnosticFactoryObject extends RefCounted:
	pass


class CompleteDiagnosticSystem extends GFSystem:
	func get_required_models() -> Array[Script]:
		return [DiagnosticModel] as Array[Script]

	func get_required_utilities() -> Array[Script]:
		return [DiagnosticUtility] as Array[Script]

	func get_required_factories() -> Array[Script]:
		return [DiagnosticFactoryObject] as Array[Script]


class MissingModelSystem extends GFSystem:
	func get_required_models() -> Array[Script]:
		return [DiagnosticModel] as Array[Script]


class DictionaryDiagnosticSystem extends GFSystem:
	func get_required_dependencies() -> Dictionary:
		return {
			"models": [DiagnosticModel],
			"utilities": [DiagnosticUtility],
		}


class InvalidDiagnosticSystem extends GFSystem:
	func get_required_models() -> Array:
		return ["not a script"]


func test_dependency_diagnostics_reports_registered_dependencies_as_ok() -> void:
	var arch := GFArchitecture.new()
	await arch.register_model_instance(DiagnosticModel.new())
	await arch.register_utility_instance(DiagnosticUtility.new())
	arch.register_factory(DiagnosticFactoryObject, func() -> DiagnosticFactoryObject:
		return DiagnosticFactoryObject.new()
	)
	await arch.register_system_instance(CompleteDiagnosticSystem.new())

	var report := arch.get_dependency_diagnostics()

	assert_true(report["ok"], "所有声明依赖已注册时诊断应通过。")
	assert_eq((report["missing_dependencies"] as Array).size(), 0, "不应报告缺失依赖。")
	assert_eq((report["resolved_dependencies"] as Array).size(), 3, "应报告已解析的声明依赖。")
	arch.dispose()


func test_dependency_diagnostics_reports_missing_dependencies() -> void:
	var arch := GFArchitecture.new()
	await arch.register_system_instance(MissingModelSystem.new())

	var report := arch.get_dependency_diagnostics()

	assert_false(report["ok"], "缺失依赖时诊断不应通过。")
	assert_eq((report["missing_dependencies"] as Array).size(), 1, "应报告一个缺失依赖。")
	assert_eq((report["issue_counts_by_kind"] as Dictionary)["missing_model_dependency"], 1, "问题类别应标记缺失 Model。")
	arch.dispose()


func test_dependency_diagnostics_can_resolve_parent_dependencies() -> void:
	var parent_arch := GFArchitecture.new()
	var child_arch := GFArchitecture.new(parent_arch)
	await parent_arch.register_model_instance(DiagnosticModel.new())
	await child_arch.register_system_instance(MissingModelSystem.new())

	var report := child_arch.get_dependency_diagnostics()
	var resolved := report["resolved_dependencies"] as Array
	var first_dependency := resolved[0] as Dictionary

	assert_true(report["ok"], "默认允许父级回退时，父级依赖应视为已解析。")
	assert_eq(first_dependency["scope"], "parent", "父级解析应标记 scope。")
	child_arch.dispose()
	parent_arch.dispose()


func test_dependency_diagnostics_can_disable_parent_lookup() -> void:
	var parent_arch := GFArchitecture.new()
	var child_arch := GFArchitecture.new(parent_arch)
	await parent_arch.register_model_instance(DiagnosticModel.new())
	await child_arch.register_system_instance(MissingModelSystem.new())

	var report := child_arch.get_dependency_diagnostics({ "include_parent_lookup": false })

	assert_false(report["ok"], "关闭父级查找后，本地缺失依赖应报告错误。")
	assert_eq((report["missing_dependencies"] as Array).size(), 1, "应报告本地缺失依赖。")
	child_arch.dispose()
	parent_arch.dispose()


func test_dependency_diagnostics_warns_about_invalid_hook_values() -> void:
	var arch := GFArchitecture.new()
	await arch.register_system_instance(InvalidDiagnosticSystem.new())

	var report := arch.get_dependency_diagnostics()

	assert_true(report["ok"], "无缺失依赖时，非法声明项只应产生警告。")
	assert_false(report["healthy"], "非法声明项应让报告不健康。")
	assert_eq((report["issue_counts_by_kind"] as Dictionary)["invalid_dependency_type"], 1, "应报告非 Script 依赖声明。")
	arch.dispose()


func test_dependency_diagnostics_reads_dictionary_hook() -> void:
	var arch := GFArchitecture.new()
	await arch.register_model_instance(DiagnosticModel.new())
	await arch.register_utility_instance(DiagnosticUtility.new())
	await arch.register_system_instance(DictionaryDiagnosticSystem.new())

	var report := arch.get_dependency_diagnostics()

	assert_true(report["ok"], "字典式依赖声明应能被解析。")
	assert_eq((report["resolved_dependencies"] as Array).size(), 2, "字典式声明应汇总 Model 和 Utility。")
	arch.dispose()
