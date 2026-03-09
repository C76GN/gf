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
	
	# 消耗一次随机数来改变状态
	var _first_val := _seed_util._rng.randi()
	var state_to_save := _seed_util.get_state()
	
	# 后续生成的两个数值
	var next_val1 := _seed_util._rng.randi()
	var next_val2 := _seed_util._rng.randi()
	
	# 恢复状态
	_seed_util.set_state(state_to_save)
	
	# 对比恢复后的生成
	var restored_val1 := _seed_util._rng.randi()
	var restored_val2 := _seed_util._rng.randi()
	
	assert_eq(restored_val1, next_val1, "恢复状态后，生成的第一个随机数应与之前一致。")
	assert_eq(restored_val2, next_val2, "恢复状态后，生成的第二个随机数应与之前一致。")


func test_get_global_seed() -> void:
	_seed_util.set_global_seed(98765)
	assert_eq(_seed_util.get_global_seed(), 98765, "get_global_seed 应返回正确的种子值。")
