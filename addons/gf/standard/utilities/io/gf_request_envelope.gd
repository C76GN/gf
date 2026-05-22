## GFRequestEnvelope: 通用可重放请求描述。
##
## 只保存请求方法、地址、载荷、Header、重试与元数据，不绑定具体服务端、
## 账号、鉴权或业务协议。
## [br]
## @api public
## [br]
## @category event_contract
## [br]
## @since 3.17.0
class_name GFRequestEnvelope
extends RefCounted


# --- 公共变量 ---

## 请求稳定标识；为空时由 Outbox 入队时生成。
## [br]
## @api public
var request_id: StringName = &""

## HTTPClient.Method 数值。即使传输层不是 HTTP，也可把它当作通用动作类型使用。
## [br]
## @api public
var method: int = HTTPClient.METHOD_GET

## 请求目标地址或项目自定义端点。
## [br]
## @api public
var url: String = ""

## 请求载荷。框架不解释字段含义。
## [br]
## @api public
## [br]
## @schema body: Dictionary，项目传输层持有的请求载荷。
var body: Dictionary = {}

## 请求 Header，使用 Godot HTTPRequest 兼容的 `Name: Value` 字符串格式。
## [br]
## @api public
var headers: PackedStringArray = PackedStringArray()

## 幂等键；为空时不参与任何框架逻辑。
## [br]
## @api public
var idempotency_key: String = ""

## 创建时间，Unix 秒。
## [br]
## @api public
var created_at_unix: int = 0

## 已尝试次数。
## [br]
## @api public
var attempt_count: int = 0

## 最大尝试次数；小于等于 0 表示不限制。
## [br]
## @api public
var max_attempts: int = 3

## 下一次允许重试的毫秒时间戳，基于 Time.get_ticks_msec()。
## [br]
## @api public
var retry_after_msec: int = 0

## 最近一次失败原因。
## [br]
## @api public
var last_error: String = ""

## 项目自定义元数据。框架不解释该字段。
## [br]
## @api public
## [br]
## @schema metadata: Dictionary，随请求持久化的项目侧元数据。
var metadata: Dictionary = {}


# --- Godot 生命周期方法 ---

func _init(
	p_method: int = HTTPClient.METHOD_GET,
	p_url: String = "",
	p_body: Dictionary = {},
	p_headers: PackedStringArray = PackedStringArray(),
	p_metadata: Dictionary = {}
) -> void:
	configure(p_method, p_url, p_body, p_headers, p_metadata)


# --- 公共方法 ---

## 配置请求并返回自身。
## [br]
## @api public
## [br]
## @param p_method: HTTPClient.Method 数值。
## [br]
## @param p_url: 请求目标地址或项目自定义端点。
## [br]
## @param p_body: 请求载荷。
## [br]
## @param p_headers: 请求 Header。
## [br]
## @param p_metadata: 项目自定义元数据。
## [br]
## @return 当前请求描述。
## [br]
## @schema p_body: Dictionary，项目传输层持有的请求载荷。
## [br]
## @schema p_metadata: Dictionary，随请求持久化的项目侧元数据。
func configure(
	p_method: int,
	p_url: String,
	p_body: Dictionary = {},
	p_headers: PackedStringArray = PackedStringArray(),
	p_metadata: Dictionary = {}
) -> GFRequestEnvelope:
	method = p_method
	url = p_url
	body = p_body.duplicate(true)
	headers = p_headers.duplicate()
	metadata = p_metadata.duplicate(true)
	if created_at_unix <= 0:
		created_at_unix = int(Time.get_unix_time_from_system())
	return self


## 检查请求是否具备最小有效信息。
## [br]
## @api public
## [br]
## @return 有效时返回 true。
func is_valid() -> bool:
	return not url.is_empty()


## 检查当前时刻是否允许再次尝试。
## [br]
## @api public
## [br]
## @param now_msec: 当前毫秒时间戳；小于 0 时自动读取。
## [br]
## @return 可尝试时返回 true。
func can_attempt(now_msec: int = -1) -> bool:
	if not is_valid() or is_exhausted():
		return false
	var effective_now := Time.get_ticks_msec() if now_msec < 0 else now_msec
	return retry_after_msec <= 0 or effective_now >= retry_after_msec


## 检查是否已耗尽尝试次数。
## [br]
## @api public
## [br]
## @return 已耗尽时返回 true。
func is_exhausted() -> bool:
	return max_attempts > 0 and attempt_count >= max_attempts


## 记录一次发送尝试。
## [br]
## @api public
func mark_attempt() -> void:
	attempt_count += 1


## 记录失败并安排下一次重试。
## [br]
## @api public
## [br]
## @param error: 失败原因。
## [br]
## @param retry_delay_msec: 从现在起等待多少毫秒后可重试。
func mark_failure(error: String, retry_delay_msec: int = 0) -> void:
	last_error = error
	if retry_delay_msec <= 0:
		retry_after_msec = 0
		return
	retry_after_msec = Time.get_ticks_msec() + retry_delay_msec


## 记录成功状态。
## [br]
## @api public
func mark_success() -> void:
	last_error = ""
	retry_after_msec = 0


## 复制请求描述。
## [br]
## @api public
## [br]
## @return 新请求描述。
func duplicate_request() -> GFRequestEnvelope:
	var duplicated := (get_script() as Script).new() as GFRequestEnvelope
	duplicated.apply_dict(to_dict())
	return duplicated


## 转为字典。
## [br]
## @api public
## [br]
## @param json_compatible: 为 true 时会把载荷与元数据转换为 JSON 兼容值。
## [br]
## @return 请求字典。
## [br]
## @schema return: Dictionary，包含 request_id、method、method_name、url、body、headers、idempotency_key、重试字段、last_error 和 metadata。
func to_dict(json_compatible: bool = false) -> Dictionary:
	return {
		"request_id": String(request_id),
		"method": method,
		"method_name": get_method_name(),
		"url": url,
		"body": GFVariantJsonCodec.variant_to_json_compatible(body) if json_compatible else body.duplicate(true),
		"headers": _headers_to_array(),
		"idempotency_key": idempotency_key,
		"created_at_unix": created_at_unix,
		"attempt_count": attempt_count,
		"max_attempts": max_attempts,
		"retry_after_msec": retry_after_msec,
		"last_error": last_error,
		"metadata": GFVariantJsonCodec.variant_to_json_compatible(metadata) if json_compatible else metadata.duplicate(true),
	}


## 从字典恢复。
## [br]
## @api public
## [br]
## @param data: 请求字典。
## [br]
## @param json_compatible: 为 true 时会先恢复类型化 JSON 值。
## [br]
## @schema data: Dictionary，包含 request_id、method、url、body、headers、idempotency_key、重试字段、last_error 和 metadata。
func apply_dict(data: Dictionary, json_compatible: bool = false) -> void:
	request_id = StringName(String(data.get("request_id", "")))
	method = int(data.get("method", HTTPClient.METHOD_GET))
	url = String(data.get("url", ""))
	var raw_body: Variant = data.get("body", {})
	var body_value: Variant = GFVariantJsonCodec.json_compatible_to_variant(raw_body) if json_compatible else GFVariantData.duplicate_variant(raw_body)
	if body_value is Dictionary:
		body = body_value as Dictionary
	else:
		body = {}
	headers = _headers_from_variant(data.get("headers", []))
	idempotency_key = String(data.get("idempotency_key", ""))
	created_at_unix = int(data.get("created_at_unix", 0))
	attempt_count = int(data.get("attempt_count", 0))
	max_attempts = int(data.get("max_attempts", 3))
	retry_after_msec = int(data.get("retry_after_msec", 0))
	last_error = String(data.get("last_error", ""))
	var raw_metadata: Variant = data.get("metadata", {})
	var metadata_value: Variant = GFVariantJsonCodec.json_compatible_to_variant(raw_metadata) if json_compatible else GFVariantData.duplicate_variant(raw_metadata)
	if metadata_value is Dictionary:
		metadata = metadata_value as Dictionary
	else:
		metadata = {}


## 获取方法名称。
## [br]
## @api public
## [br]
## @return 方法名称。
func get_method_name() -> String:
	match method:
		HTTPClient.METHOD_GET:
			return "GET"
		HTTPClient.METHOD_HEAD:
			return "HEAD"
		HTTPClient.METHOD_POST:
			return "POST"
		HTTPClient.METHOD_PUT:
			return "PUT"
		HTTPClient.METHOD_DELETE:
			return "DELETE"
		HTTPClient.METHOD_OPTIONS:
			return "OPTIONS"
		HTTPClient.METHOD_TRACE:
			return "TRACE"
		HTTPClient.METHOD_CONNECT:
			return "CONNECT"
		HTTPClient.METHOD_PATCH:
			return "PATCH"
	return "METHOD_%d" % method


## 从字典创建请求描述。
## [br]
## @api public
## [br]
## @param data: 请求字典。
## [br]
## @param json_compatible: 为 true 时会先恢复类型化 JSON 值。
## [br]
## @return 请求描述。
## [br]
## @schema data: Dictionary，包含 request_id、method、url、body、headers、idempotency_key、重试字段、last_error 和 metadata。
static func from_dict(data: Dictionary, json_compatible: bool = false) -> GFRequestEnvelope:
	var envelope := GFRequestEnvelope.new()
	envelope.apply_dict(data, json_compatible)
	return envelope


# --- 私有/辅助方法 ---

func _headers_to_array() -> Array[String]:
	var result: Array[String] = []
	for header: String in headers:
		result.append(header)
	return result


func _headers_from_variant(value: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	if value is PackedStringArray:
		return (value as PackedStringArray).duplicate()
	if value is Array:
		for header: Variant in value as Array:
			result.append(String(header))
	return result
