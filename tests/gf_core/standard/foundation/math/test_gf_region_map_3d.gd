extends GutTest


const GFRegionMap3DBase := preload("res://addons/gf/standard/foundation/math/gf_region_map_3d.gd")


func test_region_key_supports_negative_cells() -> void:
	var region_map := GFRegionMap3DBase.new()
	region_map.region_size = Vector3i(4, 4, 4)

	assert_eq(region_map.get_region_key_for_cell(Vector3i(-1, 0, 0)), Vector3i(-1, 0, 0))
	assert_eq(region_map.get_region_key_for_cell(Vector3i(4, 4, 4)), Vector3i(1, 1, 1))


func test_set_get_dirty_regions_and_clear_specific_region() -> void:
	var region_map := GFRegionMap3DBase.new()
	region_map.region_size = Vector3i(4, 4, 4)

	region_map.set_cell(Vector3i(1, 1, 1), "a")
	region_map.set_cell(Vector3i(5, 1, 1), "b")

	assert_eq(region_map.get_cell(Vector3i(1, 1, 1)), "a")
	assert_eq(region_map.get_cell(Vector3i(5, 1, 1)), "b")
	assert_eq(region_map.get_dirty_region_keys().size(), 2)

	region_map.clear_dirty(Vector3i(0, 0, 0))

	assert_false(region_map.get_dirty_region_keys().has(Vector3i(0, 0, 0)))
	assert_true(region_map.get_dirty_region_keys().has(Vector3i(1, 0, 0)))


func test_region_keys_for_cell_bounds_returns_touched_regions() -> void:
	var region_map := GFRegionMap3DBase.new()
	region_map.region_size = Vector3i(4, 4, 4)

	var keys := region_map.get_region_keys_for_cell_bounds(Vector3i(4, 0, 4), Vector3i(3, 0, 3))

	assert_eq(keys.size(), 4)
	assert_true(keys.has(Vector3i(0, 0, 0)))
	assert_true(keys.has(Vector3i(0, 0, 1)))
	assert_true(keys.has(Vector3i(1, 0, 0)))
	assert_true(keys.has(Vector3i(1, 0, 1)))


func test_erase_removes_empty_region_and_marks_dirty() -> void:
	var region_map := GFRegionMap3DBase.new()
	region_map.region_size = Vector3i(4, 4, 4)

	region_map.set_cell(Vector3i(2, 2, 2), 42)
	region_map.clear_dirty()

	assert_true(region_map.erase_cell(Vector3i(2, 2, 2)))
	assert_false(region_map.has_cell(Vector3i(2, 2, 2)))
	assert_eq(region_map.get_region_keys().size(), 0)
	assert_true(region_map.get_dirty_region_keys().has(Vector3i(0, 0, 0)))


func test_duplicate_values_prevents_external_mutation() -> void:
	var region_map := GFRegionMap3DBase.new()
	var payload := {"count": 1, "tags": ["a"]}

	region_map.set_cell(Vector3i.ZERO, payload)
	payload["count"] = 2
	payload["tags"].append("b")

	var stored: Dictionary = region_map.get_cell(Vector3i.ZERO)
	stored["count"] = 3
	stored["tags"].append("c")

	assert_eq(region_map.get_cell(Vector3i.ZERO), {"count": 1, "tags": ["a"]})
