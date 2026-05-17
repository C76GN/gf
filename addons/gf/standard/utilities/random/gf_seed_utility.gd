## GFSeedUtility: 全局随机数种子管理器。
##
## 内部维护一个主 RandomNumberGenerator，并支持基于字符串标签派生
## 出独立的子 RNG。子 RNG 的生成不推进主随机序列，可用于保证
## 回放系统的确定性。
class_name GFSeedUtility
extends GFUtility


# --- 常量 ---

const _STATE_SCHEMA_VERSION: int = 2
const _FNV_32_OFFSET: int = 2_166_136_261
const _FNV_32_PRIME: int = 16_777_619
const _UINT_32_MASK: int = 0xffffffff


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
	_ensure_rng()
	_global_seed = seed_hash
	_rng.seed = seed_hash
	_branch_counters.clear()


## 获取当前全局主种子。
func get_global_seed() -> int:
	_ensure_rng()
	return _global_seed


## 获取当前主 RNG 的内部精确状态。
## @return 当前的内部状态值。
func get_state() -> int:
	_ensure_rng()
	return _rng.state


## 恢复主 RNG 的内部精确状态。
## @param state: 要恢复的内部状态值。
func set_state(state: int) -> void:
	_ensure_rng()
	_rng.state = state


## 获取包含主种子、主 RNG 状态与分支计数的完整随机状态。
## 返回的 64 位整数状态会以十进制字符串保存，确保默认 JSON 存储可精确往返。
## @return JSON 安全的完整随机状态。
func get_full_state() -> Dictionary:
	_ensure_rng()
	return {
		&"state_schema_version": _STATE_SCHEMA_VERSION,
		&"global_seed": _int_to_state_text(_global_seed),
		&"rng_state": _int_to_state_text(_rng.state),
		&"branch_counters": _encode_branch_counters(_branch_counters),
	}


## 恢复完整随机状态。
## @param state: get_full_state() 产生的字典。
func set_full_state(state: Dictionary) -> void:
	_ensure_rng()
	_global_seed = _state_value_to_int(_get_state_value(state, &"global_seed", _global_seed), _global_seed)
	_rng.seed = _global_seed
	_rng.state = _state_value_to_int(_get_state_value(state, &"rng_state", _rng.state), _rng.state)

	var branch_counters: Variant = _get_state_value(state, &"branch_counters", {})
	_branch_counters = _decode_branch_counters(branch_counters)


## 基于主 RNG 当前状态与字符串标签，派生出一个独立的子 RNG。
## 每次调用只推进当前标签的分支计数，不推进主 RNG 的随机序列。
## 同一主状态、同一标签和同一调用序号会产生确定的子随机序列。
## @param string_seed: 用于标识子随机流用途的字符串（如 "loot_table"、"enemy_ai"）。
## @return 一个已完成种子初始化的独立 RandomNumberGenerator 实例。
func get_branched_rng(string_seed: String) -> RandomNumberGenerator:
	_ensure_rng()
	var branched := RandomNumberGenerator.new()
	var branch_index: int = int(_branch_counters.get(string_seed, 0))
	_branch_counters[string_seed] = branch_index + 1

	var branch_seed: int = _stable_hash("%d:%d:%s:%d" % [
		_global_seed,
		_rng.state,
		string_seed,
		branch_index,
	])
	branched.seed = branch_seed
	return branched


# --- 私有/辅助方法 ---

func _stable_hash(text: String) -> int:
	var hash_value: int = _FNV_32_OFFSET
	var bytes := text.to_utf8_buffer()
	for value: int in bytes:
		hash_value = ((hash_value ^ value) * _FNV_32_PRIME) & _UINT_32_MASK
	return hash_value


func _encode_branch_counters(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in source.keys():
		result[str(key)] = _int_to_state_text(int(source[key]))
	return result


func _decode_branch_counters(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return {}

	var result: Dictionary = {}
	var dictionary := value as Dictionary
	for key: Variant in dictionary.keys():
		result[str(key)] = _state_value_to_int(dictionary[key], 0)
	return result


func _get_state_value(state: Dictionary, key: StringName, fallback: Variant) -> Variant:
	if state.has(key):
		return state[key]

	var string_key := String(key)
	if state.has(string_key):
		return state[string_key]
	return fallback


func _state_value_to_int(value: Variant, fallback: int) -> int:
	if value == null:
		return fallback
	return int(value)


func _int_to_state_text(value: int) -> String:
	return str(value)


func _ensure_rng() -> void:
	if _rng == null:
		init()
