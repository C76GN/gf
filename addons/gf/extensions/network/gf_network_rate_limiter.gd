## GFNetworkRateLimiter: 通用令牌桶限流器。
##
## 可用于限制消息发送频率，避免某类同步或 RPC 过量发送。
class_name GFNetworkRateLimiter
extends RefCounted


# --- 公共变量 ---

## 令牌桶容量。
var capacity: float = 10.0:
	set(value):
		capacity = maxf(value, 0.0)
		_tokens = minf(_tokens, capacity)

## 每秒恢复令牌数。
var refill_per_second: float = 10.0:
	set(value):
		refill_per_second = maxf(value, 0.0)


# --- 私有变量 ---

var _tokens: float = capacity


# --- Godot 生命周期方法 ---

func _init(p_capacity: float = 10.0, p_refill_per_second: float = 10.0) -> void:
	capacity = p_capacity
	refill_per_second = p_refill_per_second
	_tokens = capacity


# --- 公共方法 ---

## 推进限流器时间。
## @param delta: 秒数。
func tick(delta: float) -> void:
	_tokens = minf(capacity, _tokens + maxf(delta, 0.0) * refill_per_second)


## 尝试消费令牌。
## @param amount: 令牌数量。
## @return 成功消费返回 true。
func consume(amount: float = 1.0) -> bool:
	var safe_amount := maxf(amount, 0.0)
	if _tokens < safe_amount:
		return false
	_tokens -= safe_amount
	return true


## 获取当前令牌数。
## @return 令牌数。
func get_tokens() -> float:
	return _tokens


## 重置令牌桶。
func reset() -> void:
	_tokens = capacity
