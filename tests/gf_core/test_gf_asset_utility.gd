# tests/gf_core/test_gf_asset_utility.gd

## 测试 GFAssetUtility 的 LRU 缓存管理功能。
extends GutTest


# --- 私有变量 ---

var _utility: GFAssetUtility


# --- Godot 生命周期方法 ---

func before_each() -> void:
	_utility = GFAssetUtility.new()
	_utility.max_cache_size = 3
	_utility.init()


func after_each() -> void:
	_utility = null


# --- 测试：缓存基础功能 ---

## 验证手动放入缓存后可取出。
func test_put_and_get_cached() -> void:
	var res := Resource.new()
	_utility.put_cache("res://test.tres", res)
	var cached: Resource = _utility.get_cached("res://test.tres")
	assert_eq(cached, res, "放入缓存后应可取出。")


## 验证未缓存的路径返回 null。
func test_get_uncached_returns_null() -> void:
	var cached: Resource = _utility.get_cached("res://nonexistent.tres")
	assert_null(cached, "未缓存的路径应返回 null。")


## 验证 is_cached 检查。
func test_is_cached() -> void:
	_utility.put_cache("res://a.tres", Resource.new())
	assert_true(_utility.is_cached("res://a.tres"), "已缓存路径应返回 true。")
	assert_false(_utility.is_cached("res://b.tres"), "未缓存路径应返回 false。")


## 验证缓存数量计数。
func test_get_cache_count() -> void:
	_utility.put_cache("res://a.tres", Resource.new())
	_utility.put_cache("res://b.tres", Resource.new())
	assert_eq(_utility.get_cache_count(), 2, "缓存数量应为 2。")


# --- 测试：LRU 淘汰 ---

## 验证超出容量时淘汰最旧的条目。
func test_lru_eviction() -> void:
	_utility.put_cache("res://1.tres", Resource.new())
	_utility.put_cache("res://2.tres", Resource.new())
	_utility.put_cache("res://3.tres", Resource.new())
	_utility.put_cache("res://4.tres", Resource.new())

	assert_eq(_utility.get_cache_count(), 3, "超出容量后应淘汰至最大容量。")
	assert_false(_utility.is_cached("res://1.tres"), "最旧的条目应被淘汰。")
	assert_true(_utility.is_cached("res://4.tres"), "最新的条目应保留。")


## 验证访问刷新顺序后，淘汰的是真正最久未使用的。
func test_lru_access_refreshes_order() -> void:
	_utility.put_cache("res://a.tres", Resource.new())
	_utility.put_cache("res://b.tres", Resource.new())
	_utility.put_cache("res://c.tres", Resource.new())

	_utility.get_cached("res://a.tres")

	_utility.put_cache("res://d.tres", Resource.new())

	assert_true(_utility.is_cached("res://a.tres"), "最近访问的 a 应保留。")
	assert_false(_utility.is_cached("res://b.tres"), "最久未访问的 b 应被淘汰。")
	assert_true(_utility.is_cached("res://c.tres"), "c 应保留。")
	assert_true(_utility.is_cached("res://d.tres"), "新加入的 d 应保留。")


# --- 测试：手动缓存操作 ---

## 验证 remove_cache 移除指定条目。
func test_remove_cache() -> void:
	_utility.put_cache("res://x.tres", Resource.new())
	_utility.remove_cache("res://x.tres")
	assert_false(_utility.is_cached("res://x.tres"), "移除后应不存在。")
	assert_eq(_utility.get_cache_count(), 0, "移除后数量应为 0。")


## 验证 clear_cache 清空所有。
func test_clear_cache() -> void:
	_utility.put_cache("res://a.tres", Resource.new())
	_utility.put_cache("res://b.tres", Resource.new())
	_utility.clear_cache()
	assert_eq(_utility.get_cache_count(), 0, "clear 后数量应为 0。")


## 验证 max_cache_size = 0 时不缓存。
func test_zero_cache_size_disables_caching() -> void:
	_utility.max_cache_size = 0
	_utility.put_cache("res://x.tres", Resource.new())
	assert_eq(_utility.get_cache_count(), 0, "容量为 0 时不应缓存。")
