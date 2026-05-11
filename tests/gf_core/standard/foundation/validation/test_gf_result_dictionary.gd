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
	assert_true((result[GF_RESULT_DICTIONARY_BASE.KEY_DATA] as Dictionary).is_empty(), "失败结果应保留调用方提供的 data。")
