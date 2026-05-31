## 测试通用 HTTP 请求构建、响应对象与异步批处理。
extends GutTest


# --- 测试 ---

func test_http_builder_composes_query_headers_and_json_body() -> void:
	var builder: GFHttpRequestBuilder = GFHttpRequestBuilder.new()
	builder = builder.set_url("https://example.invalid/api")
	builder = builder.set_method(GFHttpRequestBuilder.Method.POST)
	builder = builder.add_query_parameter("q", "hello world")
	builder = builder.set_header("Accept", "application/json")
	builder = builder.set_json_body({ "ok": true })

	var request: Dictionary = builder.build_request()
	var headers: PackedStringArray = GFVariantData.get_option_packed_string_array(request, "headers")

	assert_true(GFVariantData.get_option_string(request, "url").contains("q=hello%20world"), "query 参数应被 URL encode。")
	assert_true(headers.has("Accept: application/json"), "请求头应按 HTTPRequest 格式输出。")
	assert_true(headers.has("Content-Type: application/json"), "JSON body 应设置 Content-Type。")
	assert_eq(GFVariantData.get_option_int(request, "method"), GFHttpRequestBuilder.Method.POST, "请求方法应进入快照。")
	assert_true(GFVariantData.get_option_string(request, "body").contains("\"ok\":true"), "JSON body 应序列化。")


func test_http_builder_parses_json_body() -> void:
	var builder: GFHttpRequestBuilder = GFHttpRequestBuilder.new()
	builder = builder.set_parse_mode(GFHttpRequestBuilder.ParseMode.JSON)

	var parsed: Dictionary = builder.parse_body("{\"value\":3}".to_utf8_buffer())
	var data: Dictionary = GFVariantData.get_option_dictionary(parsed, "data")

	assert_true(GFVariantData.get_option_bool(parsed, "ok"), "合法 JSON 应解析成功。")
	assert_eq(GFVariantData.get_option_int(data, "value"), 3, "解析结果应保留 JSON 字段。")


func test_http_response_and_async_batch_complete_together() -> void:
	var response: GFHttpResponse = GFHttpResponse.new()
	response.url = "https://example.invalid/api"
	var batch: GFAsyncBatch = GFAsyncBatch.new()
	var completed_state: CompletionState = CompletionState.new()
	var connect_error: int = batch.completed.connect(func(_results: Dictionary) -> void:
		completed_state.completed = true
	)
	assert_true(connect_error == OK, "测试应能监听批处理完成信号。")

	assert_true(batch.watch_response(response, &"main"), "批处理应能监听响应对象。")
	response.complete_success({
		"status_code": 200,
		"text": "ok",
		"data": "ok",
	})

	assert_true(completed_state.completed, "响应完成后批处理应完成。")
	assert_true(response.is_successful(), "2xx 成功响应应标记为 successful。")
	assert_eq(batch.get_completed_count(), 1, "批处理完成数量应更新。")


func test_http_response_cancel_runs_callback_once_and_ignores_late_completion() -> void:
	var response: GFHttpResponse = GFHttpResponse.new()
	var cancel_count: CounterState = CounterState.new()
	response.cancel_callback = func() -> void:
		cancel_count.value += 1

	response.cancel("user_cancelled")
	response.cancel("late_cancel")
	response.complete_success({
		"status_code": 200,
		"text": "late",
	})

	assert_eq(cancel_count.value, 1, "取消回调应只执行一次。")
	assert_eq(response.state, GFHttpResponse.State.CANCELLED, "取消后的响应状态不应被后续完成覆盖。")
	assert_eq(response.error, "user_cancelled", "取消原因应保留第一次完成状态。")


func test_async_batch_clear_disconnects_watched_response() -> void:
	var response: GFHttpResponse = GFHttpResponse.new()
	response.url = "https://example.invalid/api"
	var batch: GFAsyncBatch = GFAsyncBatch.new()
	var completed_state: CompletionState = CompletionState.new()
	var connect_error: int = batch.completed.connect(func(_results: Dictionary) -> void:
		completed_state.completed = true
	)
	assert_true(connect_error == OK, "测试应能监听批处理完成信号。")

	assert_true(batch.watch_response(response, &"main"), "批处理应能监听响应对象。")
	batch.clear()
	response.complete_success({
		"status_code": 200,
		"text": "late",
	})

	assert_false(completed_state.completed, "清空批处理后旧响应不应再完成批处理。")
	assert_eq(batch.get_count(), 0, "清空后不应保留条目。")


# --- 辅助类 ---

class CompletionState:
	extends RefCounted

	var completed: bool = false


class CounterState:
	extends RefCounted

	var value: int = 0
