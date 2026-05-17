## 测试 GFStorageCodec 的稳定序列化、校验、压缩和混淆行为。
extends GutTest


# --- 测试方法 ---

func test_json_encoding_sorts_dictionary_keys() -> void:
	var codec := GFStorageCodec.new()

	var left := codec.encode({ "b": 2, "a": 1 }, { "obfuscation_key": 0 })
	var right := codec.encode({ "a": 1, "b": 2 }, { "obfuscation_key": 0 })

	assert_eq(left, right, "JSON 编码应递归排序字典键，保证输出稳定。")


func test_json_encoding_sorts_non_string_dictionary_keys() -> void:
	var codec := GFStorageCodec.new()

	var left := codec.encode({ 10: "ten", &"2": "two" }, { "obfuscation_key": 0 })
	var right := codec.encode({ &"2": "two", 10: "ten" }, { "obfuscation_key": 0 })

	assert_eq(left, right, "JSON 编码应能稳定排序非字符串键。")
	assert_false(left.is_empty(), "非字符串键不应导致 JSON 编码失败。")


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


func test_checksum_accepts_json_roundtrip_large_integers() -> void:
	var codec := GFStorageCodec.new()
	var bytes := codec.encode({
		"rng_state": 9_223_372_036_854_775_000,
	}, {
		"include_metadata": true,
		"use_integrity_checksum": true,
		"obfuscation_key": 0,
	})

	var result := codec.decode(bytes, {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"obfuscation_key": 0,
	})

	assert_true(bool(result.get("ok")), "checksum 应按 JSON 写盘后的语义校验，不能把合法大整数 JSON 往返误判为损坏。")
	assert_true(bool(result.get("integrity_valid")), "大整数 JSON 往返后的 checksum 应保持有效。")


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


func test_user_meta_key_roundtrips_with_storage_metadata() -> void:
	var codec := GFStorageCodec.new()
	var bytes := codec.encode({
		"_meta": {
			"player_note": "keep",
		},
		"coins": 10,
	}, {
		"include_metadata": true,
		"use_integrity_checksum": true,
		"obfuscation_key": 0,
	})

	var result := codec.decode(bytes, {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"obfuscation_key": 0,
	})
	var data := result.get("data") as Dictionary
	var metadata := result.get("metadata") as Dictionary

	assert_true(bool(result.get("ok")), "带用户 _meta 的载荷仍应通过存储元数据校验。")
	assert_eq((data.get("_meta") as Dictionary).get("player_note"), "keep", "用户 _meta 不应被存储 metadata 覆盖。")
	assert_true(metadata.has(GFStorageCodec.CHECKSUM_KEY), "存储 metadata 应仍包含 checksum。")


func test_checksum_enabled_rejects_missing_checksum_by_default() -> void:
	var codec := GFStorageCodec.new()
	var bytes := codec.encode({ "coins": 10 }, {
		"obfuscation_key": 0,
	})

	var result := codec.decode(bytes, {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"obfuscation_key": 0,
	})

	assert_false(bool(result.get("ok")), "启用 checksum 时，缺少 checksum 的载荷默认应被拒绝。")
	assert_false(bool(result.get("integrity_valid")), "缺少 checksum 应标记完整性失败。")
	assert_eq(String(result.get("error")), "Integrity checksum missing", "应返回明确的缺失 checksum 错误。")


func test_missing_checksum_can_be_allowed_for_migration() -> void:
	var codec := GFStorageCodec.new()
	var bytes := codec.encode({ "coins": 10 }, {
		"obfuscation_key": 0,
	})

	var result := codec.decode(bytes, {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"require_integrity_checksum": false,
		"obfuscation_key": 0,
	})

	assert_true(bool(result.get("ok")), "迁移旧存档时可显式允许缺少 checksum 的载荷。")
	assert_true(bool(result.get("integrity_valid")), "显式允许缺少 checksum 时应视为完整性通过。")
	assert_eq(int((result.get("data") as Dictionary).get("coins")), 10, "旧载荷数据应保持可读。")


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


func test_json_number_normalization_is_disabled_by_default() -> void:
	var codec := GFStorageCodec.new()
	var bytes := "{\"whole\": 1.0}".to_utf8_buffer()

	var preserved := codec.decode(bytes, {
		"obfuscation_key": 0,
	})
	var normalized := codec.decode(bytes, {
		"obfuscation_key": 0,
		"normalize_json_numbers": true,
	})

	assert_eq(typeof((preserved.get("data") as Dictionary).get("whole")), TYPE_FLOAT, "2.0 默认应保留 JSON float 类型。")
	assert_eq(typeof((normalized.get("data") as Dictionary).get("whole")), TYPE_INT, "迁移旧整数语义时可显式开启数字归一化。")


func test_legacy_plain_json_fallback_is_disabled_by_default() -> void:
	var codec := GFStorageCodec.new()
	var bytes := "{\"coins\": 10}".to_utf8_buffer()

	var result := codec.decode(bytes, {
		"obfuscation_key": 77,
	})

	assert_false(bool(result.get("ok")), "配置混淆密钥后，2.0 默认不应静默读取旧版纯 JSON。")


func test_legacy_plain_json_fallback_can_be_enabled_for_migration() -> void:
	var codec := GFStorageCodec.new()
	var bytes := "{\"coins\": 10}".to_utf8_buffer()

	var result := codec.decode(bytes, {
		"allow_legacy_plain_json_fallback": true,
		"obfuscation_key": 77,
	})

	assert_true(bool(result.get("ok")), "迁移旧存档时可显式允许旧版纯 JSON 回退。")
	assert_eq(int((result.get("data") as Dictionary).get("coins")), 10, "旧版纯 JSON 数据应保持可读。")


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
