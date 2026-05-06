## 测试 GFDebugDrawUtility 的通用命令缓冲行为。
extends GutTest


# --- 常量 ---

const GFDebugDrawUtilityBase = preload("res://addons/gf/utilities/gf_debug_draw_utility.gd")


# --- 测试方法 ---

func test_debug_draw_records_and_expires_items() -> void:
	var utility := GFDebugDrawUtilityBase.new()
	utility.init()

	var item_id := utility.draw_line_2d(Vector2.ZERO, Vector2.ONE, Color.RED, 0.1)

	assert_gt(item_id, 0, "绘制命令应返回稳定 id。")
	assert_eq(utility.get_item_count(), 1, "绘制命令应进入缓冲。")

	utility.tick(0.11)

	assert_eq(utility.get_item_count(), 0, "超过生命周期后绘制命令应被清理。")


func test_debug_draw_filters_disabled_channels() -> void:
	var utility := GFDebugDrawUtilityBase.new()
	utility.init()

	utility.draw_circle_2d(Vector2(4.0, 5.0), 3.0, Color.GREEN, -1.0, &"physics")
	utility.set_channel_enabled(&"physics", false)

	assert_eq(utility.get_items(&"physics").size(), 0, "禁用频道默认不应返回命令。")
	assert_eq(utility.get_items(&"physics", true).size(), 1, "include_disabled=true 时应返回禁用频道命令。")

	utility.clear(&"physics")

	assert_eq(utility.get_item_count(), 0, "按频道清理应只移除对应命令。")
