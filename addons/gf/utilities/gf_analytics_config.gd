## GFAnalyticsConfig: 通用事件分析配置。
##
## 默认不开启网络依赖；若未配置 endpoint，flush 会以 dry-run 成功完成，
## 便于项目在本地或测试环境中保持同一套调用路径。
class_name GFAnalyticsConfig
extends Resource


# --- 导出变量 ---

## 是否启用事件收集。
@export var enabled: bool = true

## HTTP 上报地址。为空时不会发起网络请求。
@export var endpoint_url: String = ""

## 上报间隔，单位秒。小于等于 0 时不自动上报。
@export var flush_interval_seconds: float = 5.0

## 单批最大事件数。
@export_range(1, 500, 1) var batch_size: int = 20

## 本地队列最大事件数。
@export_range(1, 100000, 1) var max_queue_size: int = 1000

## 是否自动附加运行环境上下文。
@export var auto_capture_context: bool = true

## 可选应用版本。
@export var app_version: String = ""

## 自定义 HTTP Header。
@export var headers: Dictionary = {}


# --- 公共方法 ---

## 构建 HTTP Header 数组。
## @return Header 字符串数组。
func build_headers() -> PackedStringArray:
	var result := PackedStringArray(["Content-Type: application/json"])
	for key: Variant in headers:
		result.append("%s: %s" % [String(key), String(headers[key])])
	return result

