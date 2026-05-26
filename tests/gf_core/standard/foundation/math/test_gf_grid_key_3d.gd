## 测试 GFGridKey3D 的坐标打包、反解和位置量化。
extends GutTest


# --- 常量 ---

const GF_GRID_KEY_3D := preload("res://addons/gf/standard/foundation/math/gf_grid_key_3d.gd")


# --- 测试 ---

func test_pack_cell_roundtrips_signed_cells_and_orientation() -> void:
	var cell := Vector3i(-12, 34, -56)
	var key := GF_GRID_KEY_3D.pack_cell(cell, 17)

	assert_ne(key, GF_GRID_KEY_3D.INVALID_KEY)
	assert_eq(GF_GRID_KEY_3D.unpack_cell(key), cell)
	assert_eq(GF_GRID_KEY_3D.unpack_orientation(key), 17)
	assert_eq(GF_GRID_KEY_3D.unpack_key(key)["cell"], cell)


func test_pack_cell_rejects_out_of_range_values() -> void:
	assert_eq(
		GF_GRID_KEY_3D.pack_cell(Vector3i(GF_GRID_KEY_3D.COORDINATE_MAX + 1, 0, 0)),
		GF_GRID_KEY_3D.INVALID_KEY
	)
	assert_eq(
		GF_GRID_KEY_3D.pack_cell(Vector3i.ZERO, GF_GRID_KEY_3D.ORIENTATION_MAX + 1),
		GF_GRID_KEY_3D.INVALID_KEY
	)
	assert_false(GF_GRID_KEY_3D.is_packed_key_valid(GF_GRID_KEY_3D.INVALID_KEY))


func test_pack_position_quantizes_with_origin_and_cell_size() -> void:
	var key := GF_GRID_KEY_3D.pack_position(
		Vector3(13.9, 1.2, 6.1),
		Vector3(2.0, 0.5, 4.0),
		Vector3(10.0, 0.0, -2.0),
		3
	)

	assert_eq(GF_GRID_KEY_3D.unpack_cell(key), Vector3i(1, 2, 2))
	assert_eq(GF_GRID_KEY_3D.unpack_orientation(key), 3)


func test_packed_keys_are_unique_for_orientation() -> void:
	var cell := Vector3i(4, 5, 6)

	assert_ne(GF_GRID_KEY_3D.pack_cell(cell, 1), GF_GRID_KEY_3D.pack_cell(cell, 2))
