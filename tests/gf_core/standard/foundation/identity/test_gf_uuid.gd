## 测试 GFUuid 的 v4/v7 生成与 canonical UUID 校验。
extends GutTest


# --- 常量 ---

const GF_UUID := preload("res://addons/gf/standard/foundation/identity/gf_uuid.gd")


# --- 测试方法 ---

func test_generate_v4_returns_canonical_rfc_variant_uuid() -> void:
	var uuid := GF_UUID.generate_v4()

	assert_eq(uuid.length(), GF_UUID.CANONICAL_LENGTH)
	assert_true(GF_UUID.is_valid(uuid), "v4 UUID 应满足 canonical 形态。")
	assert_true(GF_UUID.is_valid(uuid, 4), "v4 UUID 应通过版本过滤。")
	assert_eq(uuid.substr(14, 1), "4", "v4 UUID 应写入版本位。")
	assert_true(["8", "9", "a", "b"].has(uuid.substr(19, 1)), "UUID 应写入 RFC 4122 variant 位。")


func test_generate_v7_embeds_timestamp_and_version() -> void:
	var uuid := GF_UUID.generate_v7(0x0123456789ab)

	assert_true(uuid.begins_with("01234567-89ab-7"), "v7 UUID 前 48 位应写入 Unix 毫秒时间戳。")
	assert_true(GF_UUID.is_valid(uuid, 7), "v7 UUID 应通过版本过滤。")


func test_generate_v7_clamps_timestamp_to_48_bits() -> void:
	var uuid := GF_UUID.generate_v7(0x1000000000000)

	assert_true(uuid.begins_with("ffffffff-ffff-7"), "超过 48 位的时间戳应钳制到 v7 可编码上限。")
	assert_true(GF_UUID.is_valid(uuid, 7), "钳制后的 v7 UUID 仍应有效。")


func test_is_valid_rejects_invalid_shape_version_and_variant() -> void:
	assert_false(GF_UUID.is_valid("not-a-uuid"), "非 canonical 字符串应被拒绝。")
	assert_false(GF_UUID.is_valid("01234567-89ab-7cde-7abc-0123456789ab"), "非 RFC variant 应被拒绝。")
	assert_false(GF_UUID.is_valid("01234567-89ab-7cde-8abc-0123456789ab", 4), "版本过滤不匹配时应返回 false。")
	assert_true(GF_UUID.is_valid("01234567-89ab-7cde-8abc-0123456789ab", 7), "版本过滤匹配时应返回 true。")
