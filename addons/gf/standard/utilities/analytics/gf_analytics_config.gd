## GFAnalyticsConfig: 通用事件分析配置。
##
## 默认不开启网络依赖；若未配置 endpoint，flush 会以 dry-run 成功完成，
## 便于项目在本地或测试环境中保持同一套调用路径。
## [br]
## @api public
## [br]
## @category resource_definition
## [br]
## @since 3.17.0
class_name GFAnalyticsConfig
extends Resource


# --- 导出变量 ---

## 是否启用事件收集。
## [br]
## @api public
@export var enabled: bool = true

## HTTP 上报地址。为空时不会发起网络请求。
## [br]
## @api public
@export var endpoint_url: String = ""

## 上报间隔，单位秒。小于等于 0 时不自动上报。
## [br]
## @api public
@export var flush_interval_seconds: float = 5.0:
	set(value):
		flush_interval_seconds = maxf(value, 0.0)

## 单批最大事件数。
## [br]
## @api public
@export_range(1, 500, 1) var batch_size: int = 20:
	set(value):
		batch_size = maxi(value, 1)

## 本地队列最大事件数。
## [br]
## @api public
@export_range(1, 100000, 1) var max_queue_size: int = 1000:
	set(value):
		max_queue_size = maxi(value, 1)

## 是否自动附加运行环境上下文。
## [br]
## @api public
@export var auto_capture_context: bool = true

## 可选应用版本。
## [br]
## @api public
@export var app_version: String = ""

## 是否持久化匿名 client id。
## [br]
## @api public
@export var persist_client_id: bool = true

## client id 持久化文件路径。
## [br]
## @api public
@export var client_id_storage_path: String = "user://gf_analytics_client.cfg"

## 应用关闭通知到来时是否尝试 flush 剩余事件。
## [br]
## @api public
@export var flush_on_shutdown: bool = true

## 是否使用 gzip 压缩 HTTP 上报请求体。
## [br]
## @api public
## [br]
## @since 3.20.0
@export var compress_payload: bool = false

## 自定义 HTTP Header。
## [br]
## @api public
## [br]
## @schema headers: Dictionary[String, String] mapping header names to header values.
@export var headers: Dictionary = {}


# --- 公共方法 ---

## 构建 HTTP Header 数组。
## [br]
## @api public
## [br]
## @return Header 字符串数组。
func build_headers() -> PackedStringArray:
	var result := PackedStringArray(["Content-Type: application/json"])
	for key: Variant in headers:
		var header_name := String(key).strip_edges()
		var header_value := String(headers[key])
		if not _is_valid_header(header_name, header_value):
			push_warning("[GFAnalyticsConfig] 忽略非法 HTTP Header：%s" % _escape_header_for_log(header_name))
			continue
		if compress_payload and _is_same_header_name(header_name, "Content-Encoding"):
			push_warning("[GFAnalyticsConfig] compress_payload 已启用，忽略自定义 Content-Encoding。")
			continue
		result.append("%s: %s" % [header_name, header_value])
	if compress_payload:
		result.append("Content-Encoding: gzip")
	return result


# --- 私有/辅助方法 ---

func _is_valid_header(header_name: String, header_value: String) -> bool:
	if header_name.is_empty():
		return false
	return (
		not header_name.contains("\r")
		and not header_name.contains("\n")
		and not header_value.contains("\r")
		and not header_value.contains("\n")
	)


func _is_same_header_name(header_name: String, expected_name: String) -> bool:
	return header_name.to_lower() == expected_name.to_lower()


func _escape_header_for_log(header_name: String) -> String:
	return header_name.replace("\r", "\\r").replace("\n", "\\n")
