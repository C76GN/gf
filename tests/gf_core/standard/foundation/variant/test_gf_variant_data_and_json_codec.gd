## 测试 GFVariantData 与 GFVariantJsonCodec 的通用 Variant 行为。
extends GutTest


func test_duplicate_variant_deep_copies_collections() -> void:
	var source := {
		"items": [
			{ "value": 1 },
		],
	}
	var copy := GFVariantData.duplicate_variant(source) as Dictionary
	((copy["items"] as Array)[0] as Dictionary)["value"] = 2

	assert_eq(((source["items"] as Array)[0] as Dictionary)["value"], 1, "深拷贝不应共享嵌套集合。")


func test_duplicate_variant_can_optionally_duplicate_resources() -> void:
	var resource := Resource.new()

	assert_same(GFVariantData.duplicate_variant(resource), resource, "默认应保留 Resource 引用。")
	assert_ne(GFVariantData.duplicate_variant(resource, true, true), resource, "显式要求时应复制 Resource。")


func test_deep_merge_defaults_keeps_existing_values() -> void:
	var base := {
		"audio": {
			"volume": 0.5,
		},
	}
	var defaults := {
		"audio": {
			"volume": 1.0,
			"mute": false,
		},
		"language": "zh",
	}

	var merged := GFVariantData.deep_merge_defaults(base, defaults)

	assert_same(merged, base, "默认值合并应原地返回 base。")
	assert_eq((base["audio"] as Dictionary)["volume"], 0.5, "已有字段不应被覆盖。")
	assert_false(bool((base["audio"] as Dictionary)["mute"]), "缺失嵌套字段应被补齐。")
	assert_eq(base["language"], "zh", "顶层缺失字段应被补齐。")


func test_to_dictionary_and_duplicate_metadata_return_copies() -> void:
	var source := {
		"nested": {
			"value": 1,
		},
	}

	var dictionary := GFVariantData.to_dictionary(source)
	var metadata := GFVariantData.duplicate_metadata(source)
	(dictionary["nested"] as Dictionary)["value"] = 2
	(metadata["nested"] as Dictionary)["value"] = 3

	assert_eq((source["nested"] as Dictionary)["value"], 1, "归一化字典和元数据复制不应共享源集合。")
	assert_eq(GFVariantData.to_dictionary("bad", { "fallback": true })["fallback"], true, "非 Dictionary 输入应返回默认字典副本。")


func test_merge_dictionary_supports_recursive_overwrite_and_defaults() -> void:
	var base := {
		"audio": {
			"volume": 0.5,
			"mute": false,
		},
	}

	GFVariantData.merge_dictionary(base, {
		"audio": {
			"volume": 0.75,
			"bus": "Music",
		},
	})

	assert_eq((base["audio"] as Dictionary)["volume"], 0.75, "默认合并应覆盖已有字段。")
	assert_eq((base["audio"] as Dictionary)["bus"], "Music", "递归合并应补入嵌套字段。")
	assert_false(bool((base["audio"] as Dictionary)["mute"]), "未被覆盖的嵌套字段应保留。")

	GFVariantData.merge_dictionary(base, {
		"audio": {
			"volume": 1.0,
		},
		"language": "zh",
	}, false)

	assert_eq((base["audio"] as Dictionary)["volume"], 0.75, "overwrite=false 时已有字段不应被覆盖。")
	assert_eq(base["language"], "zh", "overwrite=false 仍应补齐缺失字段。")


func test_merge_metadata_is_recursive_and_copies_values() -> void:
	var base := {
		"tags": ["base"],
		"nested": {
			"a": 1,
		},
	}
	var source := {
		"tags": ["source"],
		"nested": {
			"b": 2,
		},
	}

	GFVariantData.merge_metadata(base, source)
	(base["tags"] as Array).append("mutated")

	assert_eq((base["nested"] as Dictionary)["a"], 1, "元数据合并应保留已有嵌套字段。")
	assert_eq((base["nested"] as Dictionary)["b"], 2, "元数据合并应写入新嵌套字段。")
	assert_eq((source["tags"] as Array).size(), 1, "元数据合并应复制来源集合。")


func test_option_readers_support_string_and_string_name_keys() -> void:
	var options := {
		&"enabled": "off",
		"count": "3",
		&"ratio": "0.5",
		"name": &"player",
		&"metadata": {
			"nested": {
				"value": 1,
			},
		},
		"empty": null,
		"items": [
			{ "id": 1 },
		],
		&"tags": ["a", &"b"],
	}

	var metadata := GFVariantData.get_option_dictionary(options, "metadata")
	var items := GFVariantData.get_option_array(options, &"items")
	(metadata["nested"] as Dictionary)["value"] = 2
	((items[0] as Dictionary))["id"] = 9

	assert_false(GFVariantData.get_option_bool(options, "enabled", true), "bool 读取应支持字符串 false/off。")
	assert_eq(GFVariantData.get_option_int(options, &"count"), 3, "int 读取应支持 String 键和 StringName 查询。")
	assert_almost_eq(GFVariantData.get_option_float(options, "ratio"), 0.5, 0.0001, "float 读取应支持 StringName 键和 String 查询。")
	assert_eq(GFVariantData.get_option_string(options, &"name"), "player", "String 读取应归一文本。")
	assert_eq(GFVariantData.get_option_string_name(options, "name"), &"player", "StringName 读取应归一名称。")
	assert_eq(GFVariantData.get_option_string(options, "empty", "fallback"), "fallback", "显式 null 应使用默认字符串。")
	assert_eq(((options[&"metadata"] as Dictionary)["nested"] as Dictionary)["value"], 1, "Dictionary 选项应返回副本。")
	assert_eq(((options["items"] as Array)[0] as Dictionary)["id"], 1, "Array 选项应返回副本。")
	assert_eq(GFVariantData.get_option_packed_string_array(options, "tags"), PackedStringArray(["a", "b"]), "PackedStringArray 读取应接受普通数组。")
	assert_eq(GFVariantData.get_option_value(options, &"missing", "fallback"), "fallback", "缺失选项应返回默认值。")


func test_vector_and_color_array_roundtrip() -> void:
	assert_eq(GFVariantJsonCodec.array_to_vector2(GFVariantJsonCodec.vector2_to_array(Vector2(1.0, 2.0))), Vector2(1.0, 2.0))
	assert_eq(GFVariantJsonCodec.array_to_vector3(GFVariantJsonCodec.vector3_to_array(Vector3(1.0, 2.0, 3.0))), Vector3(1.0, 2.0, 3.0))
	assert_eq(GFVariantJsonCodec.array_to_color(GFVariantJsonCodec.color_to_array(Color(0.1, 0.2, 0.3, 0.4))), Color(0.1, 0.2, 0.3, 0.4))
	assert_eq(GFVariantJsonCodec.array_to_vector2(["bad"], Vector2.ONE), Vector2.ONE, "非法数组应返回 fallback。")


func test_json_text_helpers_parse_format_and_compact() -> void:
	var source := "{ \"b\": 2, \"a\": [true, \" spaced value \"] }"

	var parsed := GFVariantJsonCodec.parse_json_text(source) as Dictionary
	var formatted := GFVariantJsonCodec.format_json_text(source, "  ", true)
	var compact := GFVariantJsonCodec.compact_json_text(formatted)

	assert_eq(int(parsed["b"]), 2, "JSON 文本解析应返回 Godot JSON 数据。")
	assert_true(formatted.contains("\n"), "格式化 JSON 应包含换行。")
	assert_lt(formatted.find("\"a\""), formatted.find("\"b\""), "启用 sort_keys 时应稳定排序字典键。")
	assert_false(compact.contains("\n"), "压缩 JSON 不应保留换行。")
	assert_true(compact.contains("\" spaced value \""), "压缩 JSON 不应修改字符串内空白。")
	assert_eq(JSON.parse_string(compact), JSON.parse_string(source), "格式化和压缩不应改变 JSON 语义。")


func test_json_text_helpers_return_fallback_on_parse_error() -> void:
	var fallback_data := { "safe": true }

	assert_eq(GFVariantJsonCodec.parse_json_text("{", fallback_data), fallback_data, "解析失败应返回调用方 fallback。")
	assert_eq(GFVariantJsonCodec.format_json_text("{", "\t", false, "invalid"), "invalid", "格式化失败应返回 fallback 文本。")
	assert_eq(GFVariantJsonCodec.compact_json_text("{", false, "invalid"), "invalid", "压缩失败应返回 fallback 文本。")


func test_json_compatible_codec_round_trips_godot_value_types() -> void:
	var source := {
		"position": Vector3(1.0, 2.0, 3.0),
		"cell": Vector2i(4, 5),
		"color": Color(0.2, 0.4, 0.6, 0.8),
		"path": NodePath("Root/Child"),
		"names": PackedStringArray(["a", "b"]),
		"points": PackedVector2Array([Vector2(1.0, 2.0), Vector2(3.0, 4.0)]),
	}

	var encoded: Variant = GFVariantJsonCodec.variant_to_json_compatible(source)
	var decoded: Dictionary = GFVariantJsonCodec.json_compatible_to_variant(JSON.parse_string(JSON.stringify(encoded))) as Dictionary

	assert_eq(decoded["position"], Vector3(1.0, 2.0, 3.0), "Vector3 应可经 JSON 兼容编码往返。")
	assert_eq(decoded["cell"], Vector2i(4, 5), "Vector2i 应保留整数类型。")
	assert_eq(decoded["color"], Color(0.2, 0.4, 0.6, 0.8), "Color 应保留通道值。")
	assert_eq(decoded["path"], NodePath("Root/Child"), "NodePath 应恢复为 NodePath。")
	assert_eq(decoded["names"], PackedStringArray(["a", "b"]), "PackedStringArray 应恢复为 PackedStringArray。")
	assert_eq(decoded["points"], PackedVector2Array([Vector2(1.0, 2.0), Vector2(3.0, 4.0)]), "PackedVector2Array 应恢复。")


func test_json_compatible_codec_preserves_unsafe_int64_values() -> void:
	var large_positive := 9_223_372_036_854_775_000
	var large_negative := -9_223_372_036_854_775_000
	var source := {
		"safe": 42,
		"large_positive": large_positive,
		"large_negative": large_negative,
		"packed": PackedInt64Array([large_positive, large_negative]),
	}

	var encoded := GFVariantJsonCodec.variant_to_json_compatible(source) as Dictionary
	var decoded := GFVariantJsonCodec.json_compatible_to_variant(JSON.parse_string(JSON.stringify(encoded))) as Dictionary

	assert_eq(encoded["safe"], 42, "JSON 安全范围内的整数应保持普通数字，方便阅读。")
	assert_true(encoded["large_positive"] is Dictionary, "超出 JSON 安全范围的 64 位整数应写入类型标记。")
	assert_eq(decoded["large_positive"], large_positive, "正向大整数应精确往返。")
	assert_eq(decoded["large_negative"], large_negative, "负向大整数应精确往返。")
	assert_eq(decoded["packed"], PackedInt64Array([large_positive, large_negative]), "PackedInt64Array 中的大整数应精确往返。")


func test_json_compatible_codec_decodes_malformed_typed_marker_values_safely() -> void:
	var marker := {
		GFVariantJsonCodec.JSON_MARKER_KEY: {
			GFVariantJsonCodec.JSON_VERSION_KEY: GFVariantJsonCodec.JSON_SCHEMA_VERSION,
			GFVariantJsonCodec.JSON_TYPE_KEY: "Int64",
			GFVariantJsonCodec.JSON_VALUE_KEY: 42,
		},
	}

	var decoded: Variant = GFVariantJsonCodec.json_compatible_to_variant(marker)

	assert_eq(decoded, 42, "手写 typed marker 使用数字 value 时也不应触发 String(Variant) 转换错误。")


func test_json_compatible_codec_can_preserve_dictionary_keys() -> void:
	var source := {
		Vector2i(1, 2): "cell",
		&"tag": "value",
	}

	var encoded: Variant = GFVariantJsonCodec.variant_to_json_compatible(source, { "encode_dictionary_keys": true })
	var decoded: Dictionary = GFVariantJsonCodec.json_compatible_to_variant(JSON.parse_string(JSON.stringify(encoded))) as Dictionary

	assert_eq(decoded[Vector2i(1, 2)], "cell", "启用字典键编码时应保留非字符串键。")
	assert_eq(decoded[&"tag"], "value", "StringName 字典键应恢复。")


func test_json_compatible_codec_marks_circular_references() -> void:
	var source := {}
	source["self"] = source

	var encoded := GFVariantJsonCodec.variant_to_json_compatible(source) as Dictionary
	var circular_marker := encoded["self"] as Dictionary
	var circular_payload := circular_marker[GFVariantJsonCodec.JSON_MARKER_KEY] as Dictionary
	var json_text := JSON.stringify(encoded)

	assert_eq(circular_payload[GFVariantJsonCodec.JSON_TYPE_KEY], "CircularReference", "循环引用应被标记而不是递归展开。")
	assert_false(json_text.is_empty(), "包含循环引用的结构仍应可被 JSON.stringify 编码。")


func test_json_compatible_codec_marks_circular_array_references() -> void:
	var source := []
	source.append(source)

	var encoded := GFVariantJsonCodec.variant_to_json_compatible(source) as Array
	var circular_marker := encoded[0] as Dictionary
	var circular_payload := circular_marker[GFVariantJsonCodec.JSON_MARKER_KEY] as Dictionary

	assert_eq(circular_payload[GFVariantJsonCodec.JSON_TYPE_KEY], "CircularReference", "数组自引用应被标记。")


func test_json_compatible_codec_does_not_decode_plain_dictionary_type_fields() -> void:
	var source := {
		"_gf_type": "Vector2",
		"value": [1.0, 2.0],
	}

	var decoded := GFVariantJsonCodec.json_compatible_to_variant(source) as Dictionary

	assert_eq(decoded["_gf_type"], "Vector2", "普通业务字典中的旧类型字段不应被误判为 typed marker。")
	assert_eq(decoded["value"], [1.0, 2.0], "普通业务字典中的 value 字段应原样保留。")


func test_json_compatible_codec_only_decodes_dedicated_variant_marker() -> void:
	var marker := GFVariantJsonCodec.variant_to_json_compatible(Vector2(1.0, 2.0)) as Dictionary
	var wrapped_business_data := {
		GFVariantJsonCodec.JSON_MARKER_KEY: marker[GFVariantJsonCodec.JSON_MARKER_KEY],
		"label": "business",
	}

	var decoded_marker: Variant = GFVariantJsonCodec.json_compatible_to_variant(marker)
	var decoded_business_data := GFVariantJsonCodec.json_compatible_to_variant(wrapped_business_data) as Dictionary

	assert_eq(decoded_marker, Vector2(1.0, 2.0), "独立 typed marker 应恢复为对应 Godot 类型。")
	assert_true(decoded_business_data.has("label"), "带有额外业务字段的字典不应被当作 typed marker。")
