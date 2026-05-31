## 测试 GFStorageCodec 的稳定序列化、校验、压缩和混淆行为。
extends GutTest


# --- 测试方法 ---

func test_json_encoding_sorts_dictionary_keys() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()

	var left: PackedByteArray = codec.encode({ "b": 2, "a": 1 }, { "obfuscation_key": 0 })
	var right: PackedByteArray = codec.encode({ "a": 1, "b": 2 }, { "obfuscation_key": 0 })

	assert_eq(left, right, "JSON 编码应递归排序字典键，保证输出稳定。")


func test_json_encoding_sorts_non_string_dictionary_keys() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()

	var left: PackedByteArray = codec.encode({ 10: "ten", &"2": "two" }, { "obfuscation_key": 0 })
	var right: PackedByteArray = codec.encode({ &"2": "two", 10: "ten" }, { "obfuscation_key": 0 })

	assert_eq(left, right, "JSON 编码应能稳定排序非字符串键。")
	assert_false(left.is_empty(), "非字符串键不应导致 JSON 编码失败。")


func test_checksum_rejects_tampered_payload_in_strict_mode() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()
	var bytes: PackedByteArray = codec.encode({
		"coins": 10,
	}, {
		"include_metadata": true,
		"use_integrity_checksum": true,
		"obfuscation_key": 0,
	})
	var tampered: Dictionary = GFVariantData.get_option_dictionary({
		"payload": JSON.parse_string(bytes.get_string_from_utf8()),
	}, "payload")
	tampered["coins"] = 99

	var result: Dictionary = codec.decode(JSON.stringify(tampered).to_utf8_buffer(), {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"obfuscation_key": 0,
	})

	assert_false(GFVariantData.get_option_bool(result, "ok"), "严格模式下 checksum 不匹配应拒绝读取。")
	assert_false(GFVariantData.get_option_bool(result, "integrity_valid"), "结果应标记完整性失败。")


func test_checksum_accepts_json_roundtrip_large_integers() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()
	var bytes: PackedByteArray = codec.encode({
		"rng_state": 9_223_372_036_854_775_000,
	}, {
		"include_metadata": true,
		"use_integrity_checksum": true,
		"obfuscation_key": 0,
	})

	var result: Dictionary = codec.decode(bytes, {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"obfuscation_key": 0,
	})

	assert_true(GFVariantData.get_option_bool(result, "ok"), "checksum 应按 JSON 写盘后的语义校验，不能把合法大整数 JSON 往返误判为损坏。")
	assert_true(GFVariantData.get_option_bool(result, "integrity_valid"), "大整数 JSON 往返后的 checksum 应保持有效。")


func test_checksum_without_extra_metadata_roundtrips() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()
	var bytes: PackedByteArray = codec.encode({ "coins": 10 }, {
		"include_metadata": false,
		"use_integrity_checksum": true,
		"obfuscation_key": 0,
	})

	var result: Dictionary = codec.decode(bytes, {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"obfuscation_key": 0,
	})

	assert_true(GFVariantData.get_option_bool(result, "ok"), "只启用 checksum 时也应能正常校验并读取。")
	assert_true(GFVariantData.get_option_bool(result, "integrity_valid"), "checksum 应通过校验。")


func test_user_meta_key_roundtrips_with_storage_metadata() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()
	var bytes: PackedByteArray = codec.encode({
		"_meta": {
			"player_note": "keep",
		},
		"coins": 10,
	}, {
		"include_metadata": true,
		"use_integrity_checksum": true,
		"obfuscation_key": 0,
	})

	var result: Dictionary = codec.decode(bytes, {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"obfuscation_key": 0,
	})
	var data: Dictionary = GFVariantData.get_option_dictionary(result, "data")
	var metadata: Dictionary = GFVariantData.get_option_dictionary(result, "metadata")
	var user_meta: Dictionary = GFVariantData.get_option_dictionary(data, "_meta")

	assert_true(GFVariantData.get_option_bool(result, "ok"), "带用户 _meta 的载荷仍应通过存储元数据校验。")
	assert_eq(GFVariantData.get_option_string(user_meta, "player_note"), "keep", "用户 _meta 不应被存储 metadata 覆盖。")
	assert_true(metadata.has(GFStorageCodec.CHECKSUM_KEY), "存储 metadata 应仍包含 checksum。")


func test_checksum_enabled_rejects_missing_checksum_by_default() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()
	var bytes: PackedByteArray = codec.encode({ "coins": 10 }, {
		"obfuscation_key": 0,
	})

	var result: Dictionary = codec.decode(bytes, {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"obfuscation_key": 0,
	})

	assert_false(GFVariantData.get_option_bool(result, "ok"), "启用 checksum 时，缺少 checksum 的载荷默认应被拒绝。")
	assert_false(GFVariantData.get_option_bool(result, "integrity_valid"), "缺少 checksum 应标记完整性失败。")
	assert_eq(GFVariantData.get_option_string(result, "error"), "Integrity checksum missing", "应返回明确的缺失 checksum 错误。")


func test_missing_checksum_can_be_allowed_for_migration() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()
	var bytes: PackedByteArray = codec.encode({ "coins": 10 }, {
		"obfuscation_key": 0,
	})

	var result: Dictionary = codec.decode(bytes, {
		"use_integrity_checksum": true,
		"strict_integrity": true,
		"require_integrity_checksum": false,
		"obfuscation_key": 0,
	})
	var data: Dictionary = GFVariantData.get_option_dictionary(result, "data")

	assert_true(GFVariantData.get_option_bool(result, "ok"), "迁移旧存档时可显式允许缺少 checksum 的载荷。")
	assert_true(GFVariantData.get_option_bool(result, "integrity_valid"), "显式允许缺少 checksum 时应视为完整性通过。")
	assert_eq(GFVariantData.get_option_int(data, "coins"), 10, "旧载荷数据应保持可读。")


func test_empty_dictionary_is_valid_payload() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()

	var result: Dictionary = codec.decode(codec.encode({}, { "obfuscation_key": 0 }), {
		"obfuscation_key": 0,
	})

	assert_true(GFVariantData.get_option_bool(result, "ok"), "空字典是合法载荷，不应被当作解码失败。")
	var data_value: Variant = GFVariantData.get_option_value(result, "data", {})
	assert_true(data_value is Dictionary, "解码成功时 data 应为字典。")
	if not (data_value is Dictionary):
		return
	var data: Dictionary = GFVariantData.get_option_dictionary(result, "data")
	assert_true(data.is_empty(), "空字典载荷应保持为空字典。")


func test_empty_bytes_are_invalid_payload() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()

	var result: Dictionary = codec.decode(PackedByteArray(), {
		"obfuscation_key": 0,
	})

	assert_false(GFVariantData.get_option_bool(result, "ok"), "空 bytes 不应被当作合法空字典。")
	assert_eq(GFVariantData.get_option_string(result, "error"), "Payload is empty", "空 bytes 应返回明确诊断。")


func test_json_number_normalization_is_disabled_by_default() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()
	var bytes: PackedByteArray = "{\"whole\": 1.0}".to_utf8_buffer()

	var preserved: Dictionary = codec.decode(bytes, {
		"obfuscation_key": 0,
	})
	var normalized: Dictionary = codec.decode(bytes, {
		"obfuscation_key": 0,
		"normalize_json_numbers": true,
	})
	var preserved_data: Dictionary = GFVariantData.get_option_dictionary(preserved, "data")
	var normalized_data: Dictionary = GFVariantData.get_option_dictionary(normalized, "data")

	assert_eq(typeof(GFVariantData.get_option_value(preserved_data, "whole")), TYPE_FLOAT, "2.0 默认应保留 JSON float 类型。")
	assert_eq(typeof(GFVariantData.get_option_value(normalized_data, "whole")), TYPE_INT, "迁移旧整数语义时可显式开启数字归一化。")


func test_legacy_plain_json_fallback_is_disabled_by_default() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()
	var bytes: PackedByteArray = "{\"coins\": 10}".to_utf8_buffer()

	var result: Dictionary = codec.decode(bytes, {
		"obfuscation_key": 77,
	})

	assert_false(GFVariantData.get_option_bool(result, "ok"), "配置混淆密钥后，2.0 默认不应静默读取旧版纯 JSON。")


func test_legacy_plain_json_fallback_can_be_enabled_for_migration() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()
	var bytes: PackedByteArray = "{\"coins\": 10}".to_utf8_buffer()

	var result: Dictionary = codec.decode(bytes, {
		"allow_legacy_plain_json_fallback": true,
		"obfuscation_key": 77,
	})
	var data: Dictionary = GFVariantData.get_option_dictionary(result, "data")

	assert_true(GFVariantData.get_option_bool(result, "ok"), "迁移旧存档时可显式允许旧版纯 JSON 回退。")
	assert_eq(GFVariantData.get_option_int(data, "coins"), 10, "旧版纯 JSON 数据应保持可读。")


func test_compression_and_obfuscation_roundtrip() -> void:
	var codec: GFStorageCodec = GFStorageCodec.new()
	var data: Dictionary = {
		"player": "demo",
		"stats": {
			"hp": 100,
			"mp": 50,
		},
	}

	var bytes: PackedByteArray = codec.encode(data, {
		"use_compression": true,
		"obfuscation_key": 77,
	})
	var result: Dictionary = codec.decode(bytes, {
		"use_compression": true,
		"obfuscation_key": 77,
	})

	assert_true(GFVariantData.get_option_bool(result, "ok"), "压缩和混淆组合应可正常往返。")
	if not GFVariantData.get_option_bool(result, "ok"):
		return

	var loaded_value: Variant = GFVariantData.get_option_value(result, "data", {})
	assert_true(loaded_value is Dictionary, "解码成功时 data 应为字典。")
	if not (loaded_value is Dictionary):
		return

	var loaded: Dictionary = GFVariantData.get_option_dictionary(result, "data")
	var stats: Dictionary = GFVariantData.get_option_dictionary(loaded, "stats")
	assert_eq(GFVariantData.get_option_int(stats, "hp"), 100, "嵌套字典应正确恢复。")
