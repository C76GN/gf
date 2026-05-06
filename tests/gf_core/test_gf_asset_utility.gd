## 测试 GFAssetUtility 的缓存、异步加载与失败回调行为。
extends GutTest


var _utility: GFAssetUtility


class FailingAssetUtility extends GFAssetUtility:
	var _should_fail_paths: Dictionary = {}

	func fail_path(path: String) -> void:
		_should_fail_paths[path] = true

	func _request_threaded(_path: String, _type_hint: String) -> Error:
		return OK

	func _get_threaded_status(path: String) -> ResourceLoader.ThreadLoadStatus:
		if _should_fail_paths.has(path):
			return ResourceLoader.THREAD_LOAD_FAILED
		return ResourceLoader.THREAD_LOAD_IN_PROGRESS


class TrackingAssetUtility extends GFAssetUtility:
	var requested_type_hints: Array[String] = []

	func _request_threaded(_path: String, type_hint: String) -> Error:
		requested_type_hints.append(type_hint)
		return OK

	func _get_threaded_status(_path: String) -> ResourceLoader.ThreadLoadStatus:
		return ResourceLoader.THREAD_LOAD_IN_PROGRESS


class CompletingAssetUtility extends GFAssetUtility:
	var requested_count: int = 0
	var complete: bool = false
	var loaded_resource: Resource = Resource.new()

	func _request_threaded(_path: String, _type_hint: String) -> Error:
		requested_count += 1
		return OK

	func _get_threaded_status(_path: String) -> ResourceLoader.ThreadLoadStatus:
		return ResourceLoader.THREAD_LOAD_LOADED if complete else ResourceLoader.THREAD_LOAD_IN_PROGRESS

	func _take_threaded_resource(_path: String) -> Resource:
		return loaded_resource


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


func test_reducing_cache_size_evicts_immediately() -> void:
	_utility.put_cache("res://a.tres", Resource.new())
	_utility.put_cache("res://b.tres", Resource.new())
	_utility.put_cache("res://c.tres", Resource.new())

	_utility.max_cache_size = 1

	assert_eq(_utility.get_cache_count(), 1, "缩小缓存上限后应立即执行 LRU 淘汰。")
	assert_true(_utility.is_cached("res://c.tres"), "最近访问的缓存项应被保留。")
	assert_false(_utility.is_cached("res://a.tres"), "较旧的缓存项应被淘汰。")
	assert_false(_utility.is_cached("res://b.tres"), "较旧的缓存项应被淘汰。")


func test_pinned_cache_entry_is_not_lru_evicted() -> void:
	_utility.max_cache_size = 2
	_utility.put_cache("res://a.tres", Resource.new())
	_utility.put_cache("res://b.tres", Resource.new())
	_utility.pin_cache("res://a.tres")
	_utility.put_cache("res://c.tres", Resource.new())

	assert_true(_utility.is_cached("res://a.tres"), "被 pin 的缓存项不应参与 LRU 淘汰。")
	assert_false(_utility.is_cached("res://b.tres"), "未 pin 的最旧缓存项应被淘汰。")
	assert_true(_utility.is_cache_pinned("res://a.tres"), "pin 状态应可查询。")

	_utility.unpin_cache("res://a.tres")
	assert_false(_utility.is_cache_pinned("res://a.tres"), "unpin 后应移除锁定状态。")


func test_setting_cache_size_to_zero_clears_existing_cache() -> void:
	_utility.put_cache("res://a.tres", Resource.new())
	_utility.put_cache("res://b.tres", Resource.new())

	_utility.max_cache_size = 0

	assert_eq(_utility.get_cache_count(), 0, "运行中将缓存上限设为 0 时应立即清空现有缓存。")


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


func test_pending_load_rejects_same_path_with_different_type_hint() -> void:
	_utility = TrackingAssetUtility.new()
	_utility.init()

	var results: Array = []
	var first_callback := func(res: Resource) -> void:
		results.append(res)
	var second_callback := func(res: Resource) -> void:
		results.append(res)

	_utility.load_async("res://same_path.tres", first_callback, "Resource")
	_utility.load_async("res://same_path.tres", second_callback, "PackedScene")

	assert_push_warning("[GFAssetUtility] 已存在相同路径但 type_hint 不同的加载请求，已拒绝新请求：res://same_path.tres (Resource -> PackedScene)")
	assert_eq(results.size(), 1, "不同 type_hint 的第二个请求应立即回调。")
	assert_null(results[0], "被拒绝的 type_hint 冲突请求应收到 null。")
	assert_true(_utility.is_loading("res://same_path.tres", "Resource"), "原请求应继续保留。")
	assert_false(_utility.is_loading("res://same_path.tres", "PackedScene"), "冲突请求不应进入 pending。")
	assert_eq((_utility as TrackingAssetUtility).requested_type_hints, ["Resource"], "同一路径冲突请求不应重复发起 threaded request。")


func test_pending_load_allows_empty_type_hint_with_strong_type_hint() -> void:
	_utility = CompletingAssetUtility.new()
	_utility.init()
	var completing := _utility as CompletingAssetUtility
	var results: Array = []

	_utility.load_async("res://compatible_path.tres", func(res: Resource) -> void:
		results.append({ "generic": res })
	)
	var packed_callback := func(res: Resource) -> void:
		results.append({ "packed": res })
	_utility.load_async("res://compatible_path.tres", packed_callback, "PackedScene")
	completing.complete = true
	_utility.tick()

	assert_eq(completing.requested_count, 1, "兼容 type_hint 的并发请求不应重复发起 threaded request。")
	assert_eq(results.size(), 2, "兼容 type_hint 的并发请求应保留各自回调。")
	assert_eq((results[0] as Dictionary).get("generic"), completing.loaded_resource, "空 type_hint 回调应收到加载资源。")
	assert_null((results[1] as Dictionary).get("packed"), "强 type_hint 回调应按自身类型要求校验资源。")


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

	assert_push_error("[GFAssetUtility] 异步加载失败：res://simulated_failure.tres")
	assert_true(result["called"], "加载失败时也应触发回调。")
	assert_null(result["resource"], "失败回调应收到 null 资源。")


func test_cancel_clears_callbacks_but_reuses_underlying_request_for_retry() -> void:
	_utility = CompletingAssetUtility.new()
	_utility.init()
	var completing := _utility as CompletingAssetUtility
	var results: Array = []

	_utility.load_async("res://retry_resource.tres", func(res: Resource) -> void:
		results.append({ "old": res })
	)
	_utility.cancel("res://retry_resource.tres")

	assert_false(_utility.is_loading("res://retry_resource.tres"), "取消后外部查询不应再视为正在加载。")

	_utility.load_async("res://retry_resource.tres", func(res: Resource) -> void:
		results.append({ "new": res })
	)
	completing.complete = true
	_utility.tick()

	assert_eq(completing.requested_count, 1, "取消后重试应复用仍在进行的底层 threaded request。")
	assert_eq(results.size(), 1, "取消前的旧回调不应再触发。")
	assert_eq((results[0] as Dictionary).get("new"), completing.loaded_resource, "重试回调应收到完成资源。")
	assert_eq(_utility.get_cached("res://retry_resource.tres"), completing.loaded_resource, "底层请求完成后仍应写入缓存。")
