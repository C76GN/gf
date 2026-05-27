## 测试 GFRefCountedPool 的借出、归还、重置协议和容量限制。
extends GutTest


# --- 常量 ---

const GFRefCountedPoolBase = preload("res://addons/gf/standard/utilities/pooling/gf_ref_counted_pool.gd")


# --- 辅助类型 ---

class PooledItem extends RefCounted:
	var value: int = 0
	var acquire_count: int = 0
	var release_count: int = 0
	var reset_count: int = 0

	func on_gf_pool_acquire() -> void:
		acquire_count += 1

	func on_gf_pool_release() -> void:
		release_count += 1

	func reset_for_pool() -> void:
		value = 0
		reset_count += 1


class CallbackResetItem extends RefCounted:
	var value: int = 0


# --- 测试方法 ---

func test_ref_counted_pool_reuses_released_item() -> void:
	var pool := GFRefCountedPoolBase.new(func() -> RefCounted:
		return PooledItem.new()
	)

	var first := pool.acquire() as PooledItem
	first.value = 7
	var released := pool.release(first)
	var second := pool.acquire() as PooledItem

	assert_true(released, "有效对象应能归还对象池。")
	assert_same(second, first, "归还后再次借出应复用同一对象。")
	assert_eq(second.value, 0, "归还时 reset_for_pool 应清理对象状态。")
	assert_eq(second.acquire_count, 2, "每次借出都应调用 acquire hook。")
	assert_eq(second.release_count, 1, "归还时应调用 release hook。")
	assert_eq(second.reset_count, 1, "归还时应调用 reset hook。")


func test_ref_counted_pool_uses_reset_callback() -> void:
	var pool := GFRefCountedPoolBase.new(
		func() -> RefCounted:
			return CallbackResetItem.new(),
		func(item: RefCounted) -> void:
			(item as CallbackResetItem).value = -1
	)

	var item := pool.acquire() as CallbackResetItem
	item.value = 5
	pool.release(item)
	var reused := pool.acquire() as CallbackResetItem

	assert_same(reused, item, "对象应被复用。")
	assert_eq(reused.value, -1, "reset_callback 应能清理不实现 hook 的对象。")


func test_ref_counted_pool_respects_max_available() -> void:
	var pool := GFRefCountedPoolBase.new(func() -> RefCounted:
		return PooledItem.new()
	)
	pool.max_available = 1

	var first := pool.acquire()
	var second := pool.acquire()
	pool.release(first)
	pool.release(second)

	assert_eq(pool.available_count, 1, "可用对象数量不应超过 max_available。")
	assert_eq(pool.active_count, 0, "归还后不应保留 active 记录。")


func test_ref_counted_pool_prewarms_and_reports_snapshot() -> void:
	var pool := GFRefCountedPoolBase.new(func() -> RefCounted:
		return PooledItem.new()
	)
	pool.max_available = 2

	var created := pool.prewarm(4)
	var snapshot := pool.get_debug_snapshot()

	assert_eq(created, 2, "预热应受 max_available 限制。")
	assert_eq(pool.available_count, 2, "预热后可用数量应正确。")
	assert_eq(int(snapshot["created_count"]), 2, "调试快照应包含累计创建数量。")
	assert_eq(int(snapshot["available_count"]), 2, "调试快照应包含可用数量。")


func test_ref_counted_pool_rejects_invalid_factory() -> void:
	var pool := GFRefCountedPoolBase.new()

	var item := pool.acquire()

	assert_null(item, "无效 factory 不应创建对象。")
	assert_push_error("[GFRefCountedPool] factory 无效，无法创建对象。")
