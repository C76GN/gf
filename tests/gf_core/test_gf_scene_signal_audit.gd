extends GutTest


# --- 常量 ---

const VALID_SCENE: String = "res://tests/gf_core/fixtures/scene_signal_audit_valid.tscn"
const MISSING_METHOD_SCENE: String = "res://tests/gf_core/fixtures/scene_signal_audit_missing_method.tscn"
const MISSING_TARGET_SCENE: String = "res://tests/gf_core/fixtures/scene_signal_audit_missing_target.tscn"
const PARAMETER_MISMATCH_SCENE: String = "res://tests/gf_core/fixtures/scene_signal_audit_parameter_mismatch.tscn"
const GF_SCENE_SIGNAL_AUDIT := preload("res://addons/gf/editor/gf_scene_signal_audit.gd")


# --- 测试用例 ---

func test_audit_scene_accepts_valid_editor_connection() -> void:
	var issues: Array[Dictionary] = GF_SCENE_SIGNAL_AUDIT.audit_scene(VALID_SCENE)

	assert_eq(issues, [], "有效编辑器连接不应产生审计问题。")


func test_audit_scene_reports_missing_method() -> void:
	var issues: Array[Dictionary] = GF_SCENE_SIGNAL_AUDIT.audit_scene(MISSING_METHOD_SCENE)

	assert_eq(issues.size(), 1, "缺失目标方法应产生一个问题。")
	assert_eq(issues[0]["type"], GF_SCENE_SIGNAL_AUDIT.IssueType.MISSING_METHOD, "问题类型应为缺失方法。")
	assert_eq(issues[0]["method_name"], "missing_method", "报告应保留缺失的方法名。")


func test_audit_scene_reports_missing_target() -> void:
	var issues: Array[Dictionary] = GF_SCENE_SIGNAL_AUDIT.audit_scene(MISSING_TARGET_SCENE)

	assert_eq(issues.size(), 1, "缺失目标节点应产生一个问题。")
	assert_eq(issues[0]["type"], GF_SCENE_SIGNAL_AUDIT.IssueType.MISSING_TARGET, "问题类型应为缺失目标。")
	assert_eq(issues[0]["target_node_path"], "MissingReceiver", "报告应保留缺失的节点路径。")


func test_audit_scene_reports_parameter_mismatch() -> void:
	var issues: Array[Dictionary] = GF_SCENE_SIGNAL_AUDIT.audit_scene(PARAMETER_MISMATCH_SCENE)

	assert_eq(issues.size(), 1, "信号参数不足时应产生一个问题。")
	assert_eq(issues[0]["type"], GF_SCENE_SIGNAL_AUDIT.IssueType.PARAMETER_COUNT_MISMATCH, "问题类型应为参数数量不匹配。")
	assert_eq(issues[0]["delivered_arg_count"], 0, "Button.pressed 不传入参数。")
	assert_eq(issues[0]["required_arg_count"], 1, "目标方法需要一个必填参数。")


func test_audit_scene_paths_returns_summary() -> void:
	var report: Dictionary = GF_SCENE_SIGNAL_AUDIT.audit_scene_paths(PackedStringArray([
		VALID_SCENE,
		MISSING_METHOD_SCENE,
		PARAMETER_MISMATCH_SCENE,
	]))

	assert_false(report["ok"], "包含问题场景时汇总应标记失败。")
	assert_eq(report["scene_count"], 3, "汇总应记录扫描场景数。")
	assert_eq(report["issue_count"], 2, "汇总应统计所有问题。")
	assert_eq(report["scanned_paths"].size(), 3, "汇总应保留已扫描路径。")


func test_collect_scene_paths_respects_gdignore() -> void:
	var paths: PackedStringArray = GF_SCENE_SIGNAL_AUDIT.collect_scene_paths("res://tests/gf_core/fixtures")

	assert_true(paths.has(VALID_SCENE), "收集器应包含普通 fixture 场景。")
	assert_false(paths.has("res://tests/gf_core/fixtures/scene_signal_audit_ignored/ignored_scene.tscn"), "默认应跳过包含 .gdignore 的目录。")
