## GFNetworkChannel: 网络发送通道描述。
##
## 描述一类消息的传输偏好，例如通道编号、可靠性和包体上限。
class_name GFNetworkChannel
extends Resource


# --- 导出变量 ---

## 通道稳定标识。
@export var channel_id: StringName = &""

## 编辑器展示名称。
@export var display_name: String = ""

## 后端传输通道编号。
@export_range(0, 255, 1) var transfer_channel: int = 0

## 默认是否可靠传输。
@export var reliable: bool = true

## 最大包体大小。小于等于 0 表示不限制。
@export var max_packet_size: int = 0

## 项目自定义元数据。框架不解释该字段。
@export var metadata: Dictionary = {}


# --- 公共方法 ---

## 获取展示名称。
## @return 展示名称。
func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	if channel_id != &"":
		return String(channel_id)
	return "Network Channel"


## 构建后端发送选项。
## @param overrides: 项目层额外发送选项。
## @return 后端选项字典。
func build_send_options(overrides: Dictionary = {}) -> Dictionary:
	var result := overrides.duplicate(true)
	if not result.has("channel"):
		result["channel"] = transfer_channel
	if not result.has("reliable"):
		result["reliable"] = reliable
	return result


## 描述通道。
## @return 描述字典。
func describe() -> Dictionary:
	return {
		"channel_id": channel_id,
		"display_name": get_display_name(),
		"transfer_channel": transfer_channel,
		"reliable": reliable,
		"max_packet_size": max_packet_size,
		"metadata": metadata.duplicate(true),
	}
