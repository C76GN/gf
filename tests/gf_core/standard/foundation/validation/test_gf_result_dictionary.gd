## 测试通用结果字典常量与轻量工厂。
extends GutTest


# --- 常量 ---

const GF_RESULT_DICTIONARY_BASE := preload("res://addons/gf/standard/foundation/validation/gf_result_dictionary.gd")


# --- 测试方法 ---

func test_make_adds_ok_and_preserves_fields() -> void:
	var data := { "coins": 10 }
	var result := GF_RESULT_DICTIONARY_BASE.make(true, {
		GF_RESULT_DICTIONARY_BASE.KEY_DATA: data,
		GF_RESULT_DICTIONARY_BASE.KEY_METADATA: { "version": 2 },
	})

	assert_true(bool(result[GF_RESULT_DICTIONARY_BASE.KEY_OK]), "make() 应写入 ok 字段。")
	assert_eq(result[GF_RESULT_DICTIONARY_BASE.KEY_DATA], data, "data 字段应保持调用方传入的值。")
	assert_eq((result[GF_RESULT_DICTIONARY_BASE.KEY_METADATA] as Dictionary)["version"], 2, "附加字段应保留。")


func test_make_deep_copies_field_collections() -> void:
	var fields := {
		GF_RESULT_DICTIONARY_BASE.KEY_METADATA: {
			"nested": {
				"value": 1,
			},
		},
	}

	var result := GF_RESULT_DICTIONARY_BASE.make(true, fields)
	((result[GF_RESULT_DICTIONARY_BASE.KEY_METADATA] as Dictionary)["nested"] as Dictionary)["value"] = 2

	assert_eq(((fields[GF_RESULT_DICTIONARY_BASE.KEY_METADATA] as Dictionary)["nested"] as Dictionary)["value"], 1, "结果字段应深拷贝，避免调用方共享集合。")


func test_make_success_uses_common_key_constants() -> void:
	var result := GF_RESULT_DICTIONARY_BASE.make_success({
		GF_RESULT_DICTIONARY_BASE.KEY_INTEGRITY_VALID: true,
	})

	assert_true(bool(result[GF_RESULT_DICTIONARY_BASE.KEY_OK]), "成功结果 ok 应为 true。")
	assert_true(bool(result[GF_RESULT_DICTIONARY_BASE.KEY_INTEGRITY_VALID]), "完整性字段常量应可直接用于结果。")


func test_make_failure_writes_error_without_discarding_fields() -> void:
	var result := GF_RESULT_DICTIONARY_BASE.make_failure("File not found", {
		GF_RESULT_DICTIONARY_BASE.KEY_DATA: {},
	})

	assert_false(bool(result[GF_RESULT_DICTIONARY_BASE.KEY_OK]), "失败结果 ok 应为 false。")
	assert_eq(result[GF_RESULT_DICTIONARY_BASE.KEY_ERROR], "File not found", "失败结果应写入 error。")
	assert_eq(result[GF_RESULT_DICTIONARY_BASE.KEY_REASON], "File not found", "失败结果应写入 reason。")
	assert_eq(result[GF_RESULT_DICTIONARY_BASE.KEY_MESSAGE], "File not found", "失败结果应写入 message。")
	assert_true((result[GF_RESULT_DICTIONARY_BASE.KEY_DATA] as Dictionary).is_empty(), "失败结果应保留调用方提供的 data。")


func test_make_rejected_uses_reason_message_and_error_fallback() -> void:
	var result := GF_RESULT_DICTIONARY_BASE.make_rejected(&"invalid_state", "State is invalid.", {
		GF_RESULT_DICTIONARY_BASE.KEY_METADATA: {
			"state": "boot",
		},
	})

	assert_false(GF_RESULT_DICTIONARY_BASE.is_ok(result), "拒绝结果应失败。")
	assert_eq(result[GF_RESULT_DICTIONARY_BASE.KEY_REASON], "invalid_state", "拒绝结果应写入稳定原因。")
	assert_eq(result[GF_RESULT_DICTIONARY_BASE.KEY_MESSAGE], "State is invalid.", "拒绝结果应写入说明。")
	assert_eq(result[GF_RESULT_DICTIONARY_BASE.KEY_ERROR], "State is invalid.", "未显式 error 时应使用 message。")
	assert_eq((result[GF_RESULT_DICTIONARY_BASE.KEY_METADATA] as Dictionary)["state"], "boot", "元数据应保留。")


func test_make_with_issues_adds_count_and_health() -> void:
	var result := GF_RESULT_DICTIONARY_BASE.make_with_issues(false, [
		{ "kind": "bad_value" },
	])

	assert_false(bool(result[GF_RESULT_DICTIONARY_BASE.KEY_OK]), "带错误的问题结果应失败。")
	assert_eq(int(result[GF_RESULT_DICTIONARY_BASE.KEY_ISSUE_COUNT]), 1, "问题总数应稳定输出。")
	assert_false(bool(result[GF_RESULT_DICTIONARY_BASE.KEY_HEALTHY]), "包含问题时不应健康。")


func test_normalize_copies_metadata_and_derives_standard_fields() -> void:
	var source := {
		GF_RESULT_DICTIONARY_BASE.KEY_ERROR: "Missing config",
		GF_RESULT_DICTIONARY_BASE.KEY_METADATA: {
			"nested": {
				"value": 1,
			},
		},
		GF_RESULT_DICTIONARY_BASE.KEY_ISSUES: [
			{ "kind": "missing_config" },
		],
	}

	var normalized := GF_RESULT_DICTIONARY_BASE.normalize(source, false, {
		"include_healthy": true,
	})
	((normalized[GF_RESULT_DICTIONARY_BASE.KEY_METADATA] as Dictionary)["nested"] as Dictionary)["value"] = 2

	assert_false(bool(normalized[GF_RESULT_DICTIONARY_BASE.KEY_OK]), "缺少 ok 时应使用 default_ok。")
	assert_eq(normalized[GF_RESULT_DICTIONARY_BASE.KEY_REASON], "Missing config", "缺少 reason 时应从 error 派生。")
	assert_eq(normalized[GF_RESULT_DICTIONARY_BASE.KEY_MESSAGE], "Missing config", "缺少 message 时应从 error 派生。")
	assert_eq(int(normalized[GF_RESULT_DICTIONARY_BASE.KEY_ISSUE_COUNT]), 1, "归一化应统计 issues。")
	assert_false(bool(normalized[GF_RESULT_DICTIONARY_BASE.KEY_HEALTHY]), "有问题时 healthy 应为 false。")
	assert_eq(((source[GF_RESULT_DICTIONARY_BASE.KEY_METADATA] as Dictionary)["nested"] as Dictionary)["value"], 1, "归一化不应共享源 metadata。")


func test_merge_metadata_uses_deep_merge() -> void:
	var result := GF_RESULT_DICTIONARY_BASE.make_success({
		GF_RESULT_DICTIONARY_BASE.KEY_METADATA: {
			"nested": {
				"a": 1,
			},
		},
	})

	GF_RESULT_DICTIONARY_BASE.merge_metadata(result, {
		"nested": {
			"b": 2,
		},
	})

	var metadata := result[GF_RESULT_DICTIONARY_BASE.KEY_METADATA] as Dictionary
	assert_eq((metadata["nested"] as Dictionary)["a"], 1, "已有嵌套元数据应保留。")
	assert_eq((metadata["nested"] as Dictionary)["b"], 2, "新嵌套元数据应合并。")
