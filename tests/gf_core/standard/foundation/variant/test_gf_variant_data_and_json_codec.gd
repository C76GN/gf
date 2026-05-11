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
