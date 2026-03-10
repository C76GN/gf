# tests/gf_core/test_gf_seed_utility.gd
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
