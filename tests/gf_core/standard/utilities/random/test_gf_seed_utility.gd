extends GutTest


var _seed_util: GFSeedUtility


func before_each() -> void:
	_seed_util = GFSeedUtility.new()
	_seed_util.init()


func after_each() -> void:
	_seed_util = null


func test_state_save_and_restore() -> void:
	_seed_util.set_global_seed(12345)
	
	var _first_val := _seed_util._rng.randi()
	var state_to_save := _seed_util.get_state()
	
	var next_val1 := _seed_util._rng.randi()
	var next_val2 := _seed_util._rng.randi()
	
	_seed_util.set_state(state_to_save)
	
	var restored_val1 := _seed_util._rng.randi()
	var restored_val2 := _seed_util._rng.randi()
	
	assert_eq(restored_val1, next_val1, "恢复状态后，生成的第一个随机数应与之前一致。")
	assert_eq(restored_val2, next_val2, "恢复状态后，生成的第二个随机数应与之前一致。")


func test_get_global_seed() -> void:
	_seed_util.set_global_seed(98765)
	assert_eq(_seed_util.get_global_seed(), 98765, "get_global_seed 应返回正确的种子值。")


func test_direct_new_lazily_initializes_rng() -> void:
	var seed_util := GFSeedUtility.new()

	seed_util.set_global_seed(123)
	var state := seed_util.get_state()
	var rng := seed_util.get_branched_rng("lazy")

	assert_eq(seed_util.get_global_seed(), 123, "直接 new 后公共方法应能懒初始化 RNG。")
	assert_eq(typeof(state), TYPE_INT, "懒初始化后应能读取 RNG 状态。")
	assert_true(rng != null, "懒初始化后应能派生子 RNG。")


func test_get_branched_rng_uniqueness() -> void:
	_seed_util.set_global_seed(12345)
	var rng1 := _seed_util.get_branched_rng("test")
	var rng2 := _seed_util.get_branched_rng("test")
	
	assert_ne(rng1.seed, rng2.seed, "连续生成的基于相同标签的子 RNG 应该具有不同的种子。")
	assert_ne(rng1.randi(), rng2.randi(), "连续生成的子 RNG 随机序列应该是不同的。")


func test_get_branched_rng_determinism() -> void:
	_seed_util.set_global_seed(12345)
	var rng1 := _seed_util.get_branched_rng("module_a")
	var val1 := rng1.randi()
	
	_seed_util.set_global_seed(12345)
	var rng2 := _seed_util.get_branched_rng("module_a")
	var val2 := rng2.randi()
	
	assert_eq(val1, val2, "在完全相同的主状态和标签下，生成的子 RNG 序列应当是确定性的。")


func test_get_branched_rng_does_not_advance_main_rng() -> void:
	_seed_util.set_global_seed(24680)
	var state_before := _seed_util.get_state()

	_seed_util.get_branched_rng("loot")
	_seed_util.get_branched_rng("loot")

	assert_eq(_seed_util.get_state(), state_before, "派生子 RNG 不应推进主随机序列状态。")


func test_full_state_restores_branch_counters() -> void:
	_seed_util.set_global_seed(13579)
	_seed_util.get_branched_rng("loot")
	var snapshot := _seed_util.get_full_state()
	var expected_rng := _seed_util.get_branched_rng("loot")
	var expected_value := expected_rng.randi()

	_seed_util.get_branched_rng("loot")
	_seed_util.set_full_state(snapshot)
	var restored_rng := _seed_util.get_branched_rng("loot")

	assert_eq(restored_rng.seed, expected_rng.seed, "完整状态应恢复每个标签的分支计数。")
	assert_eq(restored_rng.randi(), expected_value, "恢复完整状态后，后续子 RNG 序列应保持一致。")


func test_full_state_uses_json_safe_text_numbers() -> void:
	_seed_util.set_global_seed(9_223_372_036_854_775_000)
	_seed_util.get_branched_rng("loot")

	var snapshot := _seed_util.get_full_state()
	var branch_counters := snapshot.get(&"branch_counters") as Dictionary

	assert_eq(int(snapshot.get(&"state_schema_version")), 2, "完整状态 schema 应标记当前版本。")
	assert_false(snapshot.has(&"version"), "完整状态不应使用含义模糊的 version 字段。")
	assert_eq(typeof(snapshot.get(&"global_seed")), TYPE_STRING, "主种子应以文本保存，避免 JSON 精度丢失。")
	assert_eq(typeof(snapshot.get(&"rng_state")), TYPE_STRING, "RNG 状态应以文本保存，避免 JSON 精度丢失。")
	assert_eq(typeof(branch_counters.get("loot")), TYPE_STRING, "分支计数应以文本保存，保证完整状态全量 JSON 安全。")
	assert_false(snapshot.has(&"rng_state_text"), "完整状态不应输出重复的兼容字段。")


func test_full_state_roundtrips_through_json_with_large_64_bit_values() -> void:
	var large_seed := 9_223_372_036_854_775_000
	_seed_util.set_global_seed(large_seed)
	_seed_util._rng.randi()
	_seed_util.get_branched_rng("loot")
	var snapshot := _seed_util.get_full_state()
	var expected_rng := _seed_util.get_branched_rng("loot")
	var expected_rng_seed := expected_rng.seed
	var expected_rng_value := expected_rng.randi()
	var expected_next_main := _seed_util._rng.randi()
	var parsed := JSON.parse_string(JSON.stringify(snapshot)) as Dictionary

	_seed_util.set_global_seed(1)
	_seed_util.get_branched_rng("loot")
	_seed_util.set_full_state(parsed)
	var restored_rng := _seed_util.get_branched_rng("loot")

	assert_eq(_seed_util.get_global_seed(), large_seed, "JSON 往返后应精确恢复 64 位主种子。")
	assert_eq(restored_rng.seed, expected_rng_seed, "JSON 往返后应精确恢复分支计数与分支种子。")
	assert_eq(restored_rng.randi(), expected_rng_value, "JSON 往返后分支 RNG 序列应保持一致。")
	assert_eq(_seed_util._rng.randi(), expected_next_main, "JSON 往返后主 RNG 序列应保持一致。")
