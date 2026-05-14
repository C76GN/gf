## GFHttpResponse: 通用 HTTP 请求结果。
##
## 以对象形式表达 pending、completed、failed、cancelled 等状态，便于请求构建器、
## 批处理器和项目侧工具统一观察异步结果。
class_name GFHttpResponse
extends RefCounted


# --- 信号 ---

## 响应完成、失败或取消时发出。
## @param response: 当前响应对象。
signal completed(response: GFHttpResponse)


# --- 枚举 ---

enum State {
	## 请求仍在等待完成。
	PENDING,
	## 请求成功完成。
	COMPLETED,
	## 请求失败。
	FAILED,
	## 请求被取消。
	CANCELLED,
}


# --- 公共变量 ---

## 响应状态。
var state: State = State.PENDING

## 原始 URL。
var url: String = ""

## HTTP 状态码。
var status_code: int = 0

## Godot HTTPRequest 结果码。
var result_code: int = HTTPRequest.RESULT_SUCCESS

## 响应头。
var headers: PackedStringArray = PackedStringArray()

## 响应文本。
var text: String = ""

## 响应原始 bytes。
var body: PackedByteArray = PackedByteArray()

## 解析后的数据，例如 JSON 结果。
var data: Variant = null

## 错误说明。
var error: String = ""

## 调用方附加元数据。
var metadata: Dictionary = {}

## 取消请求时执行的底层取消回调。
var cancel_callback: Callable = Callable()


# --- 公共方法 ---

## 请求是否仍在等待。
func is_pending() -> bool:
	return state == State.PENDING


## 请求是否成功。
func is_successful() -> bool:
	return state == State.COMPLETED and status_code >= 200 and status_code < 300 and error.is_empty()


## 请求是否已结束。
func is_finished() -> bool:
	return state != State.PENDING


## 标记请求成功完成。
## @param fields: 需要写入响应对象的字段。
func complete_success(fields: Dictionary = {}) -> void:
	if is_finished():
		return

	_apply_fields(fields)
	state = State.COMPLETED
	error = String(fields.get("error", error))
	cancel_callback = Callable()
	completed.emit(self)


## 标记请求失败。
## @param message: 错误说明。
## @param fields: 需要写入响应对象的字段。
func complete_failure(message: String, fields: Dictionary = {}) -> void:
	if is_finished():
		return

	_apply_fields(fields)
	state = State.FAILED
	error = message
	cancel_callback = Callable()
	completed.emit(self)


## 取消请求。
## @param reason: 取消原因。
func cancel(reason: String = "cancelled") -> void:
	if is_finished():
		return

	var callback := cancel_callback
	cancel_callback = Callable()
	if callback.is_valid():
		callback.call()

	state = State.CANCELLED
	error = reason
	completed.emit(self)


## 转为普通字典。
## @return 响应快照。
func to_dictionary() -> Dictionary:
	return {
		"state": state,
		"state_name": State.keys()[state],
		"ok": is_successful(),
		"url": url,
		"status_code": status_code,
		"result_code": result_code,
		"headers": headers,
		"text": text,
		"body": body,
		"data": data,
		"error": error,
		"metadata": metadata.duplicate(true),
	}


# --- 私有/辅助方法 ---

func _apply_fields(fields: Dictionary) -> void:
	if fields.has("url"):
		url = String(fields["url"])
	if fields.has("status_code"):
		status_code = int(fields["status_code"])
	if fields.has("result_code"):
		result_code = int(fields["result_code"])
	if fields.has("headers"):
		headers = fields["headers"] as PackedStringArray
	if fields.has("text"):
		text = String(fields["text"])
	if fields.has("body"):
		body = fields["body"] as PackedByteArray
	if fields.has("data"):
		data = fields["data"]
	if fields.has("metadata") and fields["metadata"] is Dictionary:
		metadata = (fields["metadata"] as Dictionary).duplicate(true)
