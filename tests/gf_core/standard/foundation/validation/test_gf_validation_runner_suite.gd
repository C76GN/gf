## 测试 GFValidationSuite、GFValidationRule、GFValidationRunner 与 JUnit 导出。
extends GutTest


const GFValidationJUnitExporterBase = preload("res://addons/gf/standard/foundation/validation/gf_validation_junit_exporter.gd")
const VALIDATION_SCAN_ROOT: String = "user://gf_validation_suite_scan"


# --- Godot 生命周期方法 ---

func after_each() -> void:
	_remove_validation_scan_root()


# --- 测试 ---


func test_validation_runner_executes_callable_rules_on_targets() -> void:
	var rule := GFValidationRule.new().configure(
		&"name_required",
		func(target: Variant, validation_report: GFValidationReport, _context: Dictionary) -> Variant:
			var target_node := target as Node
			if target_node != null and String(target_node.name) == "Invalid":
				validation_report.add_error(&"invalid_name", "Node name is invalid.")
			return null,
		{ "target_kind": GFValidationRule.TargetKind.NODE }
	)
	var suite := GFValidationSuite.new()
	suite.suite_id = &"scene_health"
	suite.add_rule(rule)
	var node := Node.new()
	node.name = "Invalid"
	add_child_autofree(node)

	var runner_report := GFValidationRunner.new().run_targets([node], suite)

	assert_false(runner_report.is_ok(), "规则应能把目标问题写入聚合报告。")
	assert_eq(runner_report.get_error_count(), 1, "无效节点名应生成一个错误。")


func test_validation_suite_collects_matching_paths_with_excludes() -> void:
	var suite := GFValidationSuite.new()
	suite.include_paths = PackedStringArray(["res://tests/gf_core/fixtures"])
	suite.exclude_paths = PackedStringArray(["res://tests/gf_core/fixtures/scene_signal_audit_ignored/*"])
	suite.scene_extensions = PackedStringArray(["tscn"])
	suite.resource_extensions = PackedStringArray()

	var paths := suite.collect_paths()

	assert_true(paths.has("res://tests/gf_core/fixtures/scene_signal_audit_valid.tscn"), "套件应收集匹配扩展名的场景。")
	assert_false(paths.has("res://tests/gf_core/fixtures/scene_signal_audit_ignored/ignored_scene.tscn"), "排除通配模式应生效。")


func test_validation_suite_collect_paths_respects_scan_depth_limit() -> void:
	_prepare_validation_scan_tree()
	var suite := GFValidationSuite.new()
	suite.include_paths = PackedStringArray([VALIDATION_SCAN_ROOT])
	suite.scene_extensions = PackedStringArray()
	suite.resource_extensions = PackedStringArray(["tres"])
	suite.max_scan_depth = 1

	var paths := suite.collect_paths()

	assert_true(paths.has(VALIDATION_SCAN_ROOT.path_join("root.tres")), "根目录文件应被收集。")
	assert_true(paths.has(VALIDATION_SCAN_ROOT.path_join("a/child.tres")), "深度限制内的子目录文件应被收集。")
	assert_false(paths.has(VALIDATION_SCAN_ROOT.path_join("a/b/grand.tres")), "超过 max_scan_depth 的目录应被跳过。")
	assert_push_warning("[GFValidationSuite] collect_paths 已达到 max_scan_depth=1")


func test_validation_suite_collect_paths_respects_collected_path_limit() -> void:
	_prepare_validation_scan_tree()
	var suite := GFValidationSuite.new()
	suite.include_paths = PackedStringArray([VALIDATION_SCAN_ROOT])
	suite.scene_extensions = PackedStringArray()
	suite.resource_extensions = PackedStringArray(["tres"])
	suite.max_collected_paths = 2

	var paths := suite.collect_paths()

	assert_eq(paths.size(), 2, "collect_paths 应按 max_collected_paths 截断收集结果。")
	assert_push_warning("[GFValidationSuite] collect_paths 已达到 max_collected_paths=2")


func test_validation_suite_duplicate_preserves_scan_limits() -> void:
	var suite := GFValidationSuite.new()
	suite.max_scan_depth = 4
	suite.max_collected_paths = 8

	var duplicated := suite.duplicate_suite()

	assert_eq(duplicated.max_scan_depth, 4, "duplicate_suite 应复制扫描深度上限。")
	assert_eq(duplicated.max_collected_paths, 8, "duplicate_suite 应复制路径数量上限。")


func test_validation_runner_promotes_warnings_when_requested() -> void:
	var rule := GFValidationRule.new().configure(
		&"soft_issue",
		func(_target: Variant, validation_report: GFValidationReport, _context: Dictionary) -> Variant:
			validation_report.add_warning(&"soft_issue", "Soft issue.")
			return null,
		{}
	)
	var suite := GFValidationSuite.new()
	suite.treat_warnings_as_errors = true
	suite.add_rule(rule)

	var runner_report := GFValidationRunner.new().run_targets([{}], suite)

	assert_eq(runner_report.get_warning_count(), 0, "开启提升后不应保留 warning。")
	assert_eq(runner_report.get_error_count(), 1, "warning 应提升为 error。")


func test_validation_junit_exporter_writes_failure_cases() -> void:
	var validation_report := GFValidationReport.new("Config")
	validation_report.add_error(&"invalid_value", "Value < 0.", "score")

	var xml: String = GFValidationJUnitExporterBase.export_report(validation_report, { "suite_name": "GF Checks" })

	assert_true(xml.contains("<testsuite"), "导出文本应包含 testsuite。")
	assert_true(xml.contains("failures=\"1\""), "错误应计为 failure。")
	assert_true(xml.contains("Value &lt; 0."), "XML 文本应转义问题消息。")


# --- 私有/辅助方法 ---

func _prepare_validation_scan_tree() -> void:
	_remove_validation_scan_root()
	var nested_dir := VALIDATION_SCAN_ROOT.path_join("a/b")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(nested_dir))
	_write_validation_scan_file(VALIDATION_SCAN_ROOT.path_join("root.tres"))
	_write_validation_scan_file(VALIDATION_SCAN_ROOT.path_join("a/child.tres"))
	_write_validation_scan_file(VALIDATION_SCAN_ROOT.path_join("a/b/grand.tres"))


func _write_validation_scan_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file, "测试应能创建临时校验资源文件。")
	if file == null:
		return
	file.store_string("{}")


func _remove_validation_scan_root() -> void:
	var file_paths := [
		VALIDATION_SCAN_ROOT.path_join("a/b/grand.tres"),
		VALIDATION_SCAN_ROOT.path_join("a/child.tres"),
		VALIDATION_SCAN_ROOT.path_join("root.tres"),
	]
	for path: String in file_paths:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	var directory_paths := [
		VALIDATION_SCAN_ROOT.path_join("a/b"),
		VALIDATION_SCAN_ROOT.path_join("a"),
		VALIDATION_SCAN_ROOT,
	]
	for path: String in directory_paths:
		if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path)):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
