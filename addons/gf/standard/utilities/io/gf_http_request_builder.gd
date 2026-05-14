## GFHttpRequestBuilder: 通用 HTTP 请求构建器。
##
## 负责整理 URL、query、headers、body、timeout 和响应解析策略。
## 它只封装 Godot HTTPRequest 的通用流程，不内置任何具体服务、鉴权或业务接口。
class_name GFHttpRequestBuilder
extends RefCounted


# --- 枚举 ---

enum Method {
	## HTTP GET。
	GET,
	## HTTP POST。
	POST,
	## HTTP PUT。
	PUT,
	## HTTP PATCH。
	PATCH,
	## HTTP DELETE。
	DELETE,
	## HTTP HEAD。
	HEAD,
}

enum ParseMode {
	## 不解析响应体。
	NONE,
	## 按 UTF-8 文本解析。
	TEXT,
	## 按 JSON 解析。
	JSON,
}


# --- 常量 ---

const GFHttpResponseBase = preload("res://addons/gf/standard/utilities/io/gf_http_response.gd")


# --- 公共变量 ---

## 请求 URL。
var url: String = ""

## HTTP 方法。
var method: Method = Method.GET

## 响应解析模式。
var parse_mode: ParseMode = ParseMode.TEXT

## 请求超时时间，单位秒。
var timeout_seconds: float = 20.0

## 调用方附加元数据，会复制到 GFHttpResponse。
var metadata: Dictionary = {}


# --- 私有变量 ---

var _headers: Dictionary = {}
var _query_parameters: Array[Dictionary] = []
var _body_text: String = ""


# --- 公共方法 ---

## 设置请求 URL。
## @param next_url: 新 URL。
## @return 当前构建器。
func set_url(next_url: String) -> GFHttpRequestBuilder:
	url = next_url
	return self


## 设置 HTTP 方法。
## @param next_method: HTTP 方法枚举。
## @return 当前构建器。
func set_method(next_method: Method) -> GFHttpRequestBuilder:
	method = next_method
	return self


## 设置响应解析模式。
## @param next_parse_mode: 解析模式。
## @return 当前构建器。
func set_parse_mode(next_parse_mode: ParseMode) -> GFHttpRequestBuilder:
	parse_mode = next_parse_mode
	return self


## 设置请求超时时间。
## @param seconds: 超时秒数。
## @return 当前构建器。
func set_timeout(seconds: float) -> GFHttpRequestBuilder:
	timeout_seconds = maxf(0.0, seconds)
	return self


## 设置或覆盖请求头。
## @param key: 请求头名称。
## @param value: 请求头值。
## @return 当前构建器。
func set_header(key: String, value: String) -> GFHttpRequestBuilder:
	if key.strip_edges().is_empty():
		return self
	_headers[key.strip_edges()] = value
	return self


## 移除请求头。
## @param key: 请求头名称。
## @return 当前构建器。
func remove_header(key: String) -> GFHttpRequestBuilder:
	_headers.erase(key.strip_edges())
	return self


## 添加 query 参数。
## @param key: 参数名。
## @param value: 参数值。
## @return 当前构建器。
func add_query_parameter(key: String, value: Variant) -> GFHttpRequestBuilder:
	if key.strip_edges().is_empty():
		return self
	_query_parameters.append({
		"key": key,
		"value": value,
	})
	return self


## 设置文本请求体。
## @param text: 请求体文本。
## @param content_type: 可选 Content-Type。
## @return 当前构建器。
func set_text_body(text: String, content_type: String = "text/plain; charset=utf-8") -> GFHttpRequestBuilder:
	_body_text = text
	if not content_type.is_empty():
		set_header("Content-Type", content_type)
	return self


## 设置 JSON 请求体。
## @param value: 可被 JSON.stringify() 序列化的数据。
## @return 当前构建器。
func set_json_body(value: Variant) -> GFHttpRequestBuilder:
	_body_text = JSON.stringify(value)
	set_header("Content-Type", "application/json")
	return self


## 构建最终 URL。
## @return 拼接 query 后的 URL。
func build_url() -> String:
	if _query_parameters.is_empty():
		return url

	var pairs := PackedStringArray()
	for parameter: Dictionary in _query_parameters:
		pairs.append("%s=%s" % [
			String(parameter.get("key", "")).uri_encode(),
			str(parameter.get("value", "")).uri_encode(),
		])

	var separator := "&" if url.contains("?") else "?"
	return "%s%s%s" % [url, separator, "&".join(pairs)]


## 构建 Godot HTTPRequest 可用的请求头数组。
## @return Header 数组。
func build_headers() -> PackedStringArray:
	var result := PackedStringArray()
	for key: String in _headers.keys():
		result.append("%s: %s" % [key, String(_headers[key])])
	return result


## 构建普通请求字典，适合测试、日志或项目自定义传输层使用。
## @return 请求快照。
func build_request() -> Dictionary:
	return {
		"url": build_url(),
		"method": method,
		"method_name": Method.keys()[method],
		"headers": build_headers(),
		"body": _body_text,
		"timeout_seconds": timeout_seconds,
		"parse_mode": parse_mode,
		"parse_mode_name": ParseMode.keys()[parse_mode],
		"metadata": metadata.duplicate(true),
	}


## 使用 HTTPRequest 执行请求。
## @param parent: HTTPRequest 节点的父节点；为空时尝试挂到当前 SceneTree root。
## @return 响应对象，可监听 completed。
func execute(parent: Node = null) -> GFHttpResponseBase:
	var response: GFHttpResponseBase = GFHttpResponseBase.new()
	response.url = build_url()
	response.metadata = metadata.duplicate(true)

	var host := parent if parent != null else _resolve_default_parent()
	if host == null:
		response.complete_failure("missing_request_parent")
		return response

	var request_node := HTTPRequest.new()
	request_node.timeout = timeout_seconds
	host.add_child(request_node)
	response.cancel_callback = func() -> void:
		if is_instance_valid(request_node):
			request_node.cancel_request()
			request_node.queue_free()

	request_node.request_completed.connect(
		func(
			result_code: int,
			status_code: int,
			response_headers: PackedStringArray,
			body: PackedByteArray
		) -> void:
			_complete_response(response, request_node, result_code, status_code, response_headers, body),
		CONNECT_ONE_SHOT
	)

	var error := request_node.request(build_url(), build_headers(), _to_http_client_method(method), _body_text)
	if error != OK:
		request_node.queue_free()
		response.complete_failure(error_string(error), {
			"result_code": error,
		})
	return response


## 按当前 parse_mode 解析响应体。
## @param body: 响应 bytes。
## @return 解析结果字典。
func parse_body(body: PackedByteArray) -> Dictionary:
	var text := body.get_string_from_utf8()
	match parse_mode:
		ParseMode.NONE:
			return {
				"ok": true,
				"text": "",
				"data": null,
			}
		ParseMode.TEXT:
			return {
				"ok": true,
				"text": text,
				"data": text,
			}
		ParseMode.JSON:
			var parsed: Variant = JSON.parse_string(text)
			if parsed == null and text.strip_edges() != "null":
				return {
					"ok": false,
					"text": text,
					"data": null,
					"error": "invalid_json",
				}
			return {
				"ok": true,
				"text": text,
				"data": parsed,
			}
		_:
			return {
				"ok": false,
				"text": text,
				"data": null,
				"error": "unknown_parse_mode",
			}


# --- 私有/辅助方法 ---

func _complete_response(
	response: GFHttpResponseBase,
	request_node: HTTPRequest,
	result_code: int,
	status_code: int,
	response_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if response.is_finished():
		if is_instance_valid(request_node):
			request_node.queue_free()
		return

	if is_instance_valid(request_node):
		request_node.queue_free()

	var parsed := parse_body(body)
	var fields := {
		"url": response.url,
		"result_code": result_code,
		"status_code": status_code,
		"headers": response_headers,
		"body": body,
		"text": String(parsed.get("text", "")),
		"data": parsed.get("data"),
		"metadata": response.metadata,
	}
	if result_code != HTTPRequest.RESULT_SUCCESS:
		response.complete_failure("request_failed", fields)
		return
	if status_code < 200 or status_code >= 300:
		response.complete_failure("http_status_%d" % status_code, fields)
		return
	if not bool(parsed.get("ok", false)):
		response.complete_failure(String(parsed.get("error", "parse_failed")), fields)
		return
	response.complete_success(fields)


func _resolve_default_parent() -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root


func _to_http_client_method(next_method: Method) -> int:
	match next_method:
		Method.GET:
			return HTTPClient.METHOD_GET
		Method.POST:
			return HTTPClient.METHOD_POST
		Method.PUT:
			return HTTPClient.METHOD_PUT
		Method.PATCH:
			return HTTPClient.METHOD_PATCH
		Method.DELETE:
			return HTTPClient.METHOD_DELETE
		Method.HEAD:
			return HTTPClient.METHOD_HEAD
		_:
			return HTTPClient.METHOD_GET
