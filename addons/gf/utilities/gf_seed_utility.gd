## GFSeedUtility: 全局随机数种子管理器。
##
## 内部维护一个主 RandomNumberGenerator，并支持基于字符串标签派生
## 出独立的子 RNG。子 RNG 的生成不推进主随机序列，可用于保证
## 回放系统的确定性。
class_name GFSeedUtility
extends GFUtility


# --- 私有变量 ---

var _rng: RandomNumberGenerator
var _global_seed: int
var _branch_counters: Dictionary = {}


# --- Godot 生命周期方法 ---

## 第一阶段初始化：创建主 RNG 实例。
func init() -> void:
	_rng = RandomNumberGenerator.new()
	_global_seed = 0
	_branch_counters.clear()


# --- 公共方法 ---

## 设置全局主种子，并同步应用到主 RNG。
## @param seed_hash: 用于驱动主随机数序列的整数种子。
func set_global_seed(seed_hash: int) -> void:
	_global_seed = seed_hash
	_rng.seed = seed_hash
	_branch_counters.clear()


## 获取当前全局主种子。
func get_global_seed() -> int:
	return _global_seed


## 获取当前主 RNG 的内部精确状态。
## @return 当前的内部状态值。
func get_state() -> int:
	return _rng.state


## 恢复主 RNG 的内部精确状态。
## @param state: 要恢复的内部状态值。
func set_state(state: int) -> void:
	_rng.state = state


## 基于主 RNG 当前状态与字符串标签，派生出一个独立的子 RNG。
## 每次调用只推进当前标签的分支计数，不推进主 RNG 的随机序列。
## 同一主状态、同一标签和同一调用序号会产生确定的子随机序列。
## @param string_seed: 用于标识子随机流用途的字符串（如 "loot_table"、"enemy_ai"）。
## @return 一个已完成种子初始化的独立 RandomNumberGenerator 实例。
func get_branched_rng(string_seed: String) -> RandomNumberGenerator:
	var branched := RandomNumberGenerator.new()
	var branch_index: int = int(_branch_counters.get(string_seed, 0))
	_branch_counters[string_seed] = branch_index + 1

	var branch_seed: int = hash("%d:%d:%s:%d" % [
		_global_seed,
		_rng.state,
		string_seed,
		branch_index,
	])
	branched.seed = branch_seed
	return branched
