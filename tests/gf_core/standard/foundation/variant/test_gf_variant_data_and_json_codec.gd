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


func test_vector_and_color_array_roundtrip() -> void:
	assert_eq(GFVariantJsonCodec.array_to_vector2(GFVariantJsonCodec.vector2_to_array(Vector2(1.0, 2.0))), Vector2(1.0, 2.0))
	assert_eq(GFVariantJsonCodec.array_to_vector3(GFVariantJsonCodec.vector3_to_array(Vector3(1.0, 2.0, 3.0))), Vector3(1.0, 2.0, 3.0))
	assert_eq(GFVariantJsonCodec.array_to_color(GFVariantJsonCodec.color_to_array(Color(0.1, 0.2, 0.3, 0.4))), Color(0.1, 0.2, 0.3, 0.4))
	assert_eq(GFVariantJsonCodec.array_to_vector2(["bad"], Vector2.ONE), Vector2.ONE, "非法数组应返回 fallback。")


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
