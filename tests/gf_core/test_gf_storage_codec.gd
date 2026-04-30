## 测试 GFStorageCodec 的稳定序列化、校验、压缩和混淆行为。
extends GutTest


# --- 测试方法 ---

func test_json_encoding_sorts_dictionary_keys() -> void:
	var codec := GFStorageCodec.new()

	var left := codec.encode({ "b": 2, "a": 1 }, { "obfuscation_key": 0 })
	var right := codec.encode({ "a": 1, "b": 2 }, { "obfuscation_key": 0 })

	assert_eq(left, right, "JSON 编码应递归排序字典键，保证输出稳定。")


func test_checksum_rejects_tampered_payload_in_strict_mode() -> void:
	var codec := GFStorageCodec.new()
	var bytes := codec.encode({
		"coins": 10,
	}, {
		"include_metadata": true,
		"use_integrity_checksum": true,
		"obfuscation_key": 0,
	})
	var tampered := JSON.parse_string(bytes.get_string_from_utf8()) as Dictionary
	tampered["coins"] = 99

	var result := codec.decode(JSON.stringify(tampered).to_utf8_buffer(), {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"obfuscation_key": 0,
	})

	assert_false(bool(result.get("ok")), "严格模式下 checksum 不匹配应拒绝读取。")
	assert_false(bool(result.get("integrity_valid")), "结果应标记完整性失败。")


func test_checksum_without_extra_metadata_roundtrips() -> void:
	var codec := GFStorageCodec.new()
	var bytes := codec.encode({ "coins": 10 }, {
		"include_metadata": false,
		"use_integrity_checksum": true,
		"obfuscation_key": 0,
	})

	var result := codec.decode(bytes, {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"obfuscation_key": 0,
	})

	assert_true(bool(result.get("ok")), "只启用 checksum 时也应能正常校验并读取。")
	assert_true(bool(result.get("integrity_valid")), "checksum 应通过校验。")


func test_empty_dictionary_is_valid_payload() -> void:
	var codec := GFStorageCodec.new()

	var result := codec.decode(codec.encode({}, { "obfuscation_key": 0 }), {
		"obfuscation_key": 0,
	})

	assert_true(bool(result.get("ok")), "空字典是合法载荷，不应被当作解码失败。")
	var data_value: Variant = result.get("data", {})
	assert_true(data_value is Dictionary, "解码成功时 data 应为字典。")
	if not (data_value is Dictionary):
		return
	assert_true((data_value as Dictionary).is_empty(), "空字典载荷应保持为空字典。")


func test_empty_bytes_are_invalid_payload() -> void:
	var codec := GFStorageCodec.new()

	var result := codec.decode(PackedByteArray(), {
		"obfuscation_key": 0,
	})

	assert_false(bool(result.get("ok")), "空 bytes 不应被当作合法空字典。")
	assert_eq(String(result.get("error")), "Payload is empty", "空 bytes 应返回明确诊断。")


func test_compression_and_obfuscation_roundtrip() -> void:
	var codec := GFStorageCodec.new()
	var data := {
		"player": "demo",
		"stats": {
			"hp": 100,
			"mp": 50,
		},
	}

	var bytes := codec.encode(data, {
		"use_compression": true,
		"obfuscation_key": 77,
	})
	var result := codec.decode(bytes, {
		"use_compression": true,
		"obfuscation_key": 77,
	})

	assert_true(bool(result.get("ok")), "压缩和混淆组合应可正常往返。")
	if not bool(result.get("ok")):
		return

	var loaded_value: Variant = result.get("data", {})
	assert_true(loaded_value is Dictionary, "解码成功时 data 应为字典。")
	if not (loaded_value is Dictionary):
		return

	var loaded := loaded_value as Dictionary
	assert_eq((loaded.get("stats") as Dictionary).get("hp"), 100, "嵌套字典应正确恢复。")
