## 测试 GFAssetUtility 的缓存、异步加载与失败回调行为。
extends GutTest


var _utility: GFAssetUtility


class FailingAssetUtility extends GFAssetUtility:
	var _should_fail_paths: Dictionary = {}

	func fail_path(path: String) -> void:
		_should_fail_paths[path] = true

	func _request_threaded(path: String, _type_hint: String) -> Error:
		return OK

	func _get_threaded_status(path: String) -> ResourceLoader.ThreadLoadStatus:
		if _should_fail_paths.has(path):
			return ResourceLoader.THREAD_LOAD_FAILED
		return ResourceLoader.THREAD_LOAD_IN_PROGRESS


func before_each() -> void:
	_utility = GFAssetUtility.new()
	_utility.max_cache_size = 3
	_utility.init()


func after_each() -> void:
	if _utility != null:
		_utility.dispose()
	_utility = null
	await get_tree().process_frame


func test_put_and_get_cached() -> void:
	var res := Resource.new()
	_utility.put_cache("res://test.tres", res)
	var cached: Resource = _utility.get_cached("res://test.tres")
	assert_eq(cached, res, "写入缓存后应能正常读取。")


func test_get_uncached_returns_null() -> void:
	var cached: Resource = _utility.get_cached("res://nonexistent.tres")
	assert_null(cached, "未缓存的路径应返回 null。")


func test_is_cached() -> void:
	_utility.put_cache("res://a.tres", Resource.new())
	assert_true(_utility.is_cached("res://a.tres"), "已缓存路径应返回 true。")
	assert_false(_utility.is_cached("res://b.tres"), "未缓存路径应返回 false。")


func test_get_cache_count() -> void:
	_utility.put_cache("res://a.tres", Resource.new())
	_utility.put_cache("res://b.tres", Resource.new())
	assert_eq(_utility.get_cache_count(), 2, "缓存数量应为 2。")


func test_lru_eviction() -> void:
	_utility.put_cache("res://1.tres", Resource.new())
	_utility.put_cache("res://2.tres", Resource.new())
	_utility.put_cache("res://3.tres", Resource.new())
	_utility.put_cache("res://4.tres", Resource.new())

	assert_eq(_utility.get_cache_count(), 3, "超过容量后应自动淘汰最旧资源。")
	assert_false(_utility.is_cached("res://1.tres"), "最旧资源应被淘汰。")
	assert_true(_utility.is_cached("res://4.tres"), "最新资源应保留。")


func test_lru_access_refreshes_order() -> void:
	_utility.put_cache("res://a.tres", Resource.new())
	_utility.put_cache("res://b.tres", Resource.new())
	_utility.put_cache("res://c.tres", Resource.new())

	_utility.get_cached("res://a.tres")
	_utility.put_cache("res://d.tres", Resource.new())

	assert_true(_utility.is_cached("res://a.tres"), "最近访问的资源不应被淘汰。")
	assert_false(_utility.is_cached("res://b.tres"), "最长时间未访问的资源应被淘汰。")
	assert_true(_utility.is_cached("res://c.tres"), "其他新资源应保留。")
	assert_true(_utility.is_cached("res://d.tres"), "刚写入的资源应保留。")


func test_remove_cache() -> void:
	_utility.put_cache("res://x.tres", Resource.new())
	_utility.remove_cache("res://x.tres")
	assert_false(_utility.is_cached("res://x.tres"), "remove_cache 后应不存在该条目。")
	assert_eq(_utility.get_cache_count(), 0, "移除后缓存数量应归零。")


func test_clear_cache() -> void:
	_utility.put_cache("res://a.tres", Resource.new())
	_utility.put_cache("res://b.tres", Resource.new())
	_utility.clear_cache()
	assert_eq(_utility.get_cache_count(), 0, "clear_cache 后缓存数量应为 0。")


func test_zero_cache_size_disables_caching() -> void:
	_utility.max_cache_size = 0
	_utility.put_cache("res://x.tres", Resource.new())
	assert_eq(_utility.get_cache_count(), 0, "max_cache_size 为 0 时不应缓存。")


func test_pending_load_keeps_multiple_callbacks() -> void:
	var callback_count := [0]
	var callback := func(_res: Resource) -> void:
		callback_count[0] += 1

	_utility.load_async("res://icon.svg", callback)
	_utility.load_async("res://icon.svg", func(_res: Resource) -> void:
		callback_count[0] += 1
	)

	for _i in range(60):
		_utility.tick()
		if callback_count[0] >= 2:
			break
		await get_tree().process_frame

	assert_eq(callback_count[0], 2, "同一路径的并发加载请求应回调所有监听者。")


func test_failed_load_notifies_callback_with_null() -> void:
	_utility = FailingAssetUtility.new()
	_utility.init()
	(_utility as FailingAssetUtility).fail_path("res://simulated_failure.tres")

	var result := {"called": false, "resource": null}

	_utility.load_async("res://simulated_failure.tres", func(res: Resource) -> void:
		result["called"] = true
		result["resource"] = res
	)

	for _i in range(20):
		_utility.tick()
		if result["called"]:
			break
		await get_tree().process_frame

	assert_true(result["called"], "加载失败时也应触发回调。")
	assert_null(result["resource"], "失败回调应收到 null 资源。")
