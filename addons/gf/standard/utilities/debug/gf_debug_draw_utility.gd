## GFDebugDrawUtility: 通用调试绘制命令缓冲。
##
## 收集 2D/3D 线段、矩形、圆、文本等即时调试绘制命令。
## Utility 只维护抽象命令和生命周期，具体渲染可由项目层 Overlay/Viewport 适配。
class_name GFDebugDrawUtility
extends GFUtility


# --- 信号 ---

## 绘制命令发生变化时发出。
signal items_changed


# --- 枚举 ---

## 调试绘制命令类型。
enum PrimitiveType {
	LINE_2D,
	RECT_2D,
	CIRCLE_2D,
	TEXT_2D,
	LINE_3D,
	BOX_3D,
	TEXT_3D,
	CUSTOM,
}


# --- 公共变量 ---

## 是否启用调试绘制。
var enabled: bool = true

## 默认生命周期。小于 0 表示永久保留，0 表示等待下一次 tick 后清理。
var default_lifetime_seconds: float = 0.0

## 最大命令数量。小于等于 0 表示不限制。
var max_items: int = 2048


# --- 私有变量 ---

var _items: Array[Dictionary] = []
var _channels_enabled: Dictionary = {}
var _next_item_id: int = 1


# --- Godot 生命周期方法 ---

func init() -> void:
	_items.clear()
	_channels_enabled.clear()
	_next_item_id = 1


func dispose() -> void:
	clear()


## 推进运行时逻辑。
## @param delta: 本帧时间增量（秒）。
func tick(delta: float) -> void:
	_expire_items(delta)


# --- 公共方法 ---

## 绘制 2D 线段。
## @param from: 起点位置。
## @param to: 终点位置。
## @param color: 绘制颜色。
## @param lifetime_seconds: 调试绘制命令保留时间（秒）。
## @param channel: 调试绘制频道。
## @param width: 绘制线宽。
func draw_line_2d(
	from: Vector2,
	to: Vector2,
	color: Color = Color.WHITE,
	lifetime_seconds: float = -1.0,
	channel: StringName = &"default",
	width: float = 1.0
) -> int:
	return push_item({
		"type": PrimitiveType.LINE_2D,
		"channel": channel,
		"from": from,
		"to": to,
		"color": color,
		"width": maxf(width, 0.0),
		"lifetime_seconds": lifetime_seconds,
	})


## 绘制 2D 矩形。
## @param rect: 矩形区域。
## @param color: 绘制颜色。
## @param lifetime_seconds: 调试绘制命令保留时间（秒）。
## @param channel: 调试绘制频道。
## @param filled: 是否填充绘制图形。
## @param width: 绘制线宽。
func draw_rect_2d(
	rect: Rect2,
	color: Color = Color.WHITE,
	lifetime_seconds: float = -1.0,
	channel: StringName = &"default",
	filled: bool = false,
	width: float = 1.0
) -> int:
	return push_item({
		"type": PrimitiveType.RECT_2D,
		"channel": channel,
		"rect": rect,
		"color": color,
		"filled": filled,
		"width": maxf(width, 0.0),
		"lifetime_seconds": lifetime_seconds,
	})


## 绘制 2D 圆。
## @param center: 要绘制圆形的中心点。
## @param radius: 圆形半径。
## @param color: 绘制颜色。
## @param lifetime_seconds: 调试绘制命令保留时间（秒）。
## @param channel: 调试绘制频道。
## @param filled: 是否填充绘制图形。
## @param width: 绘制线宽。
func draw_circle_2d(
	center: Vector2,
	radius: float,
	color: Color = Color.WHITE,
	lifetime_seconds: float = -1.0,
	channel: StringName = &"default",
	filled: bool = false,
	width: float = 1.0
) -> int:
	return push_item({
		"type": PrimitiveType.CIRCLE_2D,
		"channel": channel,
		"center": center,
		"radius": maxf(radius, 0.0),
		"color": color,
		"filled": filled,
		"width": maxf(width, 0.0),
		"lifetime_seconds": lifetime_seconds,
	})


## 绘制 2D 文本。
## @param position: 绘制文本的位置。
## @param text: 要绘制或输出的文本。
## @param color: 绘制颜色。
## @param lifetime_seconds: 调试绘制命令保留时间（秒）。
## @param channel: 调试绘制频道。
## @param font_size: 绘制文本字号。
func draw_text_2d(
	position: Vector2,
	text: String,
	color: Color = Color.WHITE,
	lifetime_seconds: float = -1.0,
	channel: StringName = &"default",
	font_size: int = 16
) -> int:
	return push_item({
		"type": PrimitiveType.TEXT_2D,
		"channel": channel,
		"position": position,
		"text": text,
		"color": color,
		"font_size": maxi(font_size, 1),
		"lifetime_seconds": lifetime_seconds,
	})


## 绘制 3D 线段。
## @param from: 起点位置。
## @param to: 终点位置。
## @param color: 绘制颜色。
## @param lifetime_seconds: 调试绘制命令保留时间（秒）。
## @param channel: 调试绘制频道。
## @param width: 绘制线宽。
func draw_line_3d(
	from: Vector3,
	to: Vector3,
	color: Color = Color.WHITE,
	lifetime_seconds: float = -1.0,
	channel: StringName = &"default",
	width: float = 1.0
) -> int:
	return push_item({
		"type": PrimitiveType.LINE_3D,
		"channel": channel,
		"from": from,
		"to": to,
		"color": color,
		"width": maxf(width, 0.0),
		"lifetime_seconds": lifetime_seconds,
	})


## 绘制 3D AABB。
## @param box: 要绘制的 3D 包围盒。
## @param color: 绘制颜色。
## @param lifetime_seconds: 调试绘制命令保留时间（秒）。
## @param channel: 调试绘制频道。
## @param filled: 是否填充绘制图形。
## @param width: 绘制线宽。
func draw_box_3d(
	box: AABB,
	color: Color = Color.WHITE,
	lifetime_seconds: float = -1.0,
	channel: StringName = &"default",
	filled: bool = false,
	width: float = 1.0
) -> int:
	return push_item({
		"type": PrimitiveType.BOX_3D,
		"channel": channel,
		"box": box,
		"color": color,
		"filled": filled,
		"width": maxf(width, 0.0),
		"lifetime_seconds": lifetime_seconds,
	})


## 绘制 3D 文本。
## @param position: 绘制文本的位置。
## @param text: 要绘制或输出的文本。
## @param color: 绘制颜色。
## @param lifetime_seconds: 调试绘制命令保留时间（秒）。
## @param channel: 调试绘制频道。
## @param font_size: 绘制文本字号。
func draw_text_3d(
	position: Vector3,
	text: String,
	color: Color = Color.WHITE,
	lifetime_seconds: float = -1.0,
	channel: StringName = &"default",
	font_size: int = 16
) -> int:
	return push_item({
		"type": PrimitiveType.TEXT_3D,
		"channel": channel,
		"position": position,
		"text": text,
		"color": color,
		"font_size": maxi(font_size, 1),
		"lifetime_seconds": lifetime_seconds,
	})


## 推入自定义调试绘制命令。
## @param item: 命令字典。
## @return 命令 id。
func push_item(item: Dictionary) -> int:
	var stored_item := item.duplicate(true)
	stored_item["id"] = _next_item_id
	stored_item["channel"] = StringName(stored_item.get("channel", &"default"))
	stored_item["created_at_msec"] = Time.get_ticks_msec()
	stored_item["lifetime_seconds"] = _resolve_lifetime(float(stored_item.get("lifetime_seconds", -1.0)))
	stored_item["remaining_seconds"] = stored_item["lifetime_seconds"]
	_next_item_id += 1

	_items.append(stored_item)
	_trim_to_max_items()
	items_changed.emit()
	return int(stored_item["id"])


## 清理命令。
## @param channel: 指定频道；为空时清空全部。
func clear(channel: StringName = &"") -> void:
	if channel == &"":
		if _items.is_empty():
			return
		_items.clear()
		items_changed.emit()
		return

	var changed := false
	for index: int in range(_items.size() - 1, -1, -1):
		if StringName(_items[index].get("channel", &"default")) == channel:
			_items.remove_at(index)
			changed = true
	if changed:
		items_changed.emit()


## 设置频道启用状态。
## @param channel: 频道。
## @param channel_enabled: 是否启用。
func set_channel_enabled(channel: StringName, channel_enabled: bool) -> void:
	_channels_enabled[channel] = channel_enabled
	items_changed.emit()


## 检查频道是否启用。
## @param channel: 频道。
## @return 启用返回 true。
func is_channel_enabled(channel: StringName) -> bool:
	return bool(_channels_enabled.get(channel, true))


## 获取绘制命令。
## @param channel: 指定频道；为空时返回全部频道。
## @param include_disabled: 是否包含已禁用频道或全局禁用状态下的命令。
## @return 命令副本列表。
func get_items(channel: StringName = &"", include_disabled: bool = false) -> Array[Dictionary]:
	if not enabled and not include_disabled:
		return []

	var result: Array[Dictionary] = []
	for item: Dictionary in _items:
		var item_channel := StringName(item.get("channel", &"default"))
		if channel != &"" and item_channel != channel:
			continue
		if not include_disabled and not is_channel_enabled(item_channel):
			continue
		result.append(item.duplicate(true))
	return result


## 获取命令数量。
## @param channel: 指定频道；为空时返回全部。
## @return 数量。
func get_item_count(channel: StringName = &"") -> int:
	return get_items(channel, true).size()


## 获取调试快照。
## @return 快照字典。
func get_debug_snapshot() -> Dictionary:
	var channels: Dictionary = {}
	var primitive_types: Dictionary = {}
	for item: Dictionary in _items:
		var channel := StringName(item.get("channel", &"default"))
		var primitive_type := int(item.get("type", PrimitiveType.CUSTOM))
		channels[channel] = int(channels.get(channel, 0)) + 1
		primitive_types[primitive_type] = int(primitive_types.get(primitive_type, 0)) + 1
	return {
		"enabled": enabled,
		"item_count": _items.size(),
		"channels": channels,
		"primitive_types": primitive_types,
		"max_items": max_items,
	}


# --- 私有/辅助方法 ---

func _resolve_lifetime(lifetime_seconds: float) -> float:
	if lifetime_seconds < 0.0:
		return default_lifetime_seconds
	return lifetime_seconds


func _expire_items(delta: float) -> void:
	if _items.is_empty():
		return

	var changed := false
	for index: int in range(_items.size() - 1, -1, -1):
		var lifetime_seconds := float(_items[index].get("lifetime_seconds", 0.0))
		if lifetime_seconds < 0.0:
			continue
		var remaining_seconds := float(_items[index].get("remaining_seconds", lifetime_seconds)) - maxf(delta, 0.0)
		_items[index]["remaining_seconds"] = remaining_seconds
		if remaining_seconds <= 0.0:
			_items.remove_at(index)
			changed = true
	if changed:
		items_changed.emit()


func _trim_to_max_items() -> void:
	if max_items <= 0:
		return
	while _items.size() > max_items:
		_items.remove_at(0)
