## 测试 GFRemoteCacheUtility 的缓存命中、JSON 解析与失败回退。
extends GutTest


const GFRemoteCacheUtilityBase = preload("res://addons/gf/utilities/gf_remote_cache_utility.gd")


# --- 辅助子类 ---

class FakeRemoteCacheUtility:
	extends GFRemoteCacheUtilityBase

	var responses: Array[Dictionary] = []
	var request_count: int = 0

	func _start_http_request(_request_data: Dictionary) -> Error:
		request_count += 1
		var response := {
			"success": true,
			"response_code": 200,
			"content": "",
			"error": "",
		}
		if not responses.is_empty():
			response = responses.pop_front()

		call_deferred(
			"_complete_active_request",
			bool(response.get("success", true)),
			int(response.get("response_code", 200)),
			String(response.get("content", "")),
			String(response.get("error", ""))
		)
		return OK


# --- 私有变量 ---

var _cache: FakeRemoteCacheUtility


# --- 测试生命周期 ---

func before_each() -> void:
	_cache = FakeRemoteCacheUtility.new()
	_cache.cache_dir_name = "gf_remote_cache_test_%d" % Time.get_ticks_usec()
	_cache.init()
	_cache.clear_cache()


func after_each() -> void:
	if _cache != null:
		_cache.clear_cache()
		_cache.dispose()
		_cache = null


# --- 测试 ---

func test_fetch_text_writes_and_reuses_cache() -> void:
	var results: Array[Dictionary] = []
	_cache.responses.append({
		"success": true,
		"response_code": 200,
		"content": "payload",
	})

	_cache.fetch_text("https://example.test/text", func(result: Dictionary) -> void:
		results.append(result)
	)
	await get_tree().process_frame

	_cache.fetch_text("https://example.test/text", func(result: Dictionary) -> void:
		results.append(result)
	)

	assert_eq(results.size(), 2, "第二次请求应直接命中缓存。")
	assert_eq(_cache.request_count, 1, "缓存命中不应再次启动 HTTP 请求。")
	assert_false(bool(results[0]["from_cache"]), "首次请求不应来自缓存。")
	assert_true(bool(results[1]["from_cache"]), "第二次请求应来自缓存。")
	assert_eq(results[1]["content"], "payload", "缓存内容应保持一致。")


func test_fetch_json_parses_data() -> void:
	var results: Array[Dictionary] = []
	_cache.responses.append({
		"success": true,
		"response_code": 200,
		"content": "{\"value\":3}",
	})

	_cache.fetch_json("https://example.test/json", func(result: Dictionary) -> void:
		results.append(result)
	)
	await get_tree().process_frame

	assert_eq(results.size(), 1, "JSON 请求应返回一次结果。")
	assert_true(bool(results[0]["success"]), "合法 JSON 应返回成功。")
	assert_eq(int((results[0]["data"] as Dictionary)["value"]), 3, "JSON 内容应被解析到 data。")


func test_failed_refresh_uses_stale_cache() -> void:
	var results: Array[Dictionary] = []
	_cache.responses.append({
		"success": true,
		"response_code": 200,
		"content": "old",
	})
	_cache.fetch_text("https://example.test/fallback", func(result: Dictionary) -> void:
		results.append(result)
	)
	await get_tree().process_frame

	_cache.responses.append({
		"success": false,
		"response_code": 500,
		"error": "server failed",
	})
	_cache.fetch_text("https://example.test/fallback", func(result: Dictionary) -> void:
		results.append(result)
	, -1, true)
	await get_tree().process_frame

	assert_eq(results.size(), 2, "刷新失败也应返回回调结果。")
	assert_true(bool(results[1]["success"]), "存在陈旧缓存时刷新失败应回退成功。")
	assert_true(bool(results[1]["from_cache"]), "刷新失败回退结果应来自缓存。")
	assert_true(bool(results[1]["stale"]), "刷新失败回退结果应标记为陈旧缓存。")
	assert_eq(results[1]["content"], "old", "刷新失败应返回此前缓存内容。")
